#ifndef ARRAYPARTITION_ANALYSIS_H
#define ARRAYPARTITION_ANALYSIS_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "includes/dhirOps.h"

#include <optional>
#include <limits>
#include <string>

namespace mlir
{
    namespace dhir
    {
        struct ArrayPartitioningInfo
        {
            enum PartitioningStrategy
            {
                NO_PARTITION,  // Replicate
                ROW_PARTITION, // Split by rows (or 1D partition)
                COL_PARTITION, // Split by columns
            };

            PartitioningStrategy strategy;
            Value memref;
            int partitionDimension;
            int haloLeft;
            int haloRight;
            std::string partitionReason;

            ArrayPartitioningInfo()
                : strategy(NO_PARTITION), partitionDimension(-1), haloLeft(0),
                  haloRight(0), partitionReason("not analyzed") {}
        };

        class ArrayPartitioningAnalysis
        {
        public:
            mlir::Operation *rootOp;
            Value partitionedIV;

            ArrayPartitioningAnalysis(mlir::Operation *rootOp, mlir::Value partitionedIV) : rootOp(rootOp), partitionedIV(partitionedIV) {}

            ArrayPartitioningInfo analyzeArray(Value memref)
            {
                ArrayPartitioningInfo info;
                info.memref = memref;

                // Collect accesses (both affine and regular memref ops)
                llvm::SmallVector<Operation *> loads;
                llvm::SmallVector<Operation *> stores;

                // Affine loads/stores
                rootOp->walk([&](mlir::affine::AffineLoadOp loadOp)
                             {
                    if (loadOp.getMemRef() == memref)
                        loads.push_back(loadOp.getOperation()); });

                rootOp->walk([&](mlir::affine::AffineStoreOp storeOp)
                             {
                    if (storeOp.getMemRef() == memref)
                        stores.push_back(storeOp.getOperation()); });

                // Regular memref loads/stores
                rootOp->walk([&](mlir::memref::LoadOp loadOp)
                             {
                    if (loadOp.getMemRef() == memref)
                        loads.push_back(loadOp.getOperation()); });

                rootOp->walk([&](mlir::memref::StoreOp storeOp)
                             {
                    if (storeOp.getMemRef() == memref)
                        stores.push_back(storeOp.getOperation()); });

                bool isInput = stores.empty();
                bool isOutput = !stores.empty();

                auto memrefType = dyn_cast<mlir::MemRefType>(memref.getType());
                if (!memrefType)
                {
                    info.partitionReason = "operand is not a ranked memref";
                    return info;
                }

                int rank = memrefType.getRank();
                if (rank < 1 || rank > 3)
                {
                    llvm::errs() << "Warning: Unsupported array rank: " << rank << "\n";
                    info.partitionReason = "only rank-1, rank-2, and rank-3 memrefs are supported";
                    return info;
                }

                // A dimension-0 subview needs concrete sizes for every trailing
                // dimension. Keeping such an operand whole is still correct; the
                // per-access rebaser will restore the global IV where needed.
                for (int dim = 1; dim < rank; ++dim)
                {
                    if (memrefType.isDynamicDim(dim))
                    {
                        info.partitionReason =
                            "dynamic trailing dimensions cannot form a static row slice";
                        return info;
                    }
                }

                if (!partitionedIV)
                {
                    info.partitionReason = "no partitioned loop induction variable";
                    return info;
                }

                if (loads.empty() && stores.empty())
                {
                    info.partitionReason = "memref has no accesses in the partitioned loop";
                    return info;
                }

                int partitionDim = -1;
                bool sawExactIVAccess = false;
                bool sawInvariantAccess = false;
                bool sawUnsupportedIVAccess = false;
                bool inconsistentDimension = false;
                bool sawOffsetAccess = false;

                auto inspectAccess = [&](Operation *access)
                {
                    auto exact = getUnitStrideDimensionAndOffset(access, partitionedIV);
                    if (!exact)
                    {
                        if (getDimensionForIV(access, partitionedIV) >= 0)
                            sawUnsupportedIVAccess = true;
                        else
                            sawInvariantAccess = true;
                        return;
                    }

                    sawExactIVAccess = true;
                    int dimension = exact->first;
                    int64_t offset = exact->second;
                    sawOffsetAccess |= offset != 0;
                    if (partitionDim < 0)
                        partitionDim = dimension;
                    else if (partitionDim != dimension)
                        inconsistentDimension = true;
                };

                for (Operation *load : loads)
                    inspectAccess(load);
                for (Operation *store : stores)
                    inspectAccess(store);

                llvm::errs() << "=== Array Partition Analysis ===\n";
                llvm::errs() << "Rank: " << rank << ", Is input: " << isInput
                             << ", Is output: " << isOutput
                             << ", Partition dimension: " << partitionDim << "\n";

                // Preserve stencil metadata even though the current lowerer does not
                // yet materialize halos.
                if (rank == 1)
                    computeHaloForAccesses(loads, stores, partitionedIV, info);

                if (sawUnsupportedIVAccess)
                {
                    info.partitionReason =
                        "partitioned IV appears in a non-unit or compound index expression";
                }
                else if (!sawExactIVAccess)
                {
                    info.partitionReason = isOutput
                        ? "reduction dimension: output accesses are invariant in the partitioned IV"
                        : "input is invariant in the partitioned IV (replicated)";
                }
                else if (sawInvariantAccess || inconsistentDimension)
                {
                    info.partitionReason =
                        "inconsistent access dimensions for the partitioned IV";
                }
                else if (sawOffsetAccess || info.haloLeft > 0 || info.haloRight > 0)
                {
                    info.partitionReason = "halo/stencil access requires deferred halo exchange";
                }
                else if (partitionDim == 0)
                {
                    info.strategy = ArrayPartitioningInfo::ROW_PARTITION;
                    info.partitionDimension = 0;
                    info.partitionReason = "all accesses use the partitioned IV on dimension 0";
                }
                else if (partitionDim == 1 && rank == 2)
                {
                    // The MPI lowering gathers contiguous row slices through raw
                    // pointers. A column view is strided, so advertising
                    // COL_PARTITION here would be a strategy the lowerer cannot emit.
                    info.partitionReason = isInput
                        ? "column-accessed input is replicated; strided transfers are deferred"
                        : "column partitioning requires strided transfers and is deferred";
                }
                else
                {
                    info.partitionReason =
                        "only leading-dimension row partitioning is currently supported";
                }

                if (info.strategy == ArrayPartitioningInfo::ROW_PARTITION)
                    llvm::errs() << "→ ROW_PARTITION (" << info.partitionReason << ")\n";
                else
                    llvm::errs() << "→ NO_PARTITION (" << info.partitionReason << ")\n";

                return info;
            }

        public:

            // Return the memref dimension and constant offset when an access uses
            // the partitioned IV in the only form that can be rebased safely:
            // IV itself, or IV +/- a constant. A missing result means either that
            // the IV is not used by this access or that the expression is too
            // general to transform conservatively.
            std::optional<std::pair<int, int64_t>>
            getUnitStrideDimensionAndOffset(Operation *memOp, Value targetIV)
            {
                if (auto affineLoad = dyn_cast<mlir::affine::AffineLoadOp>(memOp))
                {
                    AffineMap map = affineLoad.getAffineMap();
                    auto operands = affineLoad.getMapOperands();
                    std::optional<std::pair<int, int64_t>> result;
                    for (unsigned dim = 0; dim < map.getNumResults(); ++dim)
                    {
                        for (unsigned operandPos = 0; operandPos < operands.size(); ++operandPos)
                        {
                            int64_t operandOffset = 0;
                            if (!getOffsetFromIV(operands[operandPos], targetIV, operandOffset))
                                continue;
                            int64_t offset = 0;
                            if (getSimpleAffineIVOffset(map.getResult(dim), operandPos,
                                                        map.getNumDims(), offset))
                            {
                                if (result)
                                    return std::nullopt;
                                __int128 combined = static_cast<__int128>(offset) +
                                                    operandOffset;
                                if (combined < std::numeric_limits<int64_t>::min() ||
                                    combined > std::numeric_limits<int64_t>::max())
                                    return std::nullopt;
                                result = std::make_pair(static_cast<int>(dim),
                                                        static_cast<int64_t>(combined));
                            }
                        }
                    }
                    return result;
                }

                if (auto affineStore = dyn_cast<mlir::affine::AffineStoreOp>(memOp))
                {
                    AffineMap map = affineStore.getAffineMap();
                    auto operands = affineStore.getMapOperands();
                    std::optional<std::pair<int, int64_t>> result;
                    for (unsigned dim = 0; dim < map.getNumResults(); ++dim)
                    {
                        for (unsigned operandPos = 0; operandPos < operands.size(); ++operandPos)
                        {
                            int64_t operandOffset = 0;
                            if (!getOffsetFromIV(operands[operandPos], targetIV, operandOffset))
                                continue;
                            int64_t offset = 0;
                            if (getSimpleAffineIVOffset(map.getResult(dim), operandPos,
                                                        map.getNumDims(), offset))
                            {
                                if (result)
                                    return std::nullopt;
                                __int128 combined = static_cast<__int128>(offset) +
                                                    operandOffset;
                                if (combined < std::numeric_limits<int64_t>::min() ||
                                    combined > std::numeric_limits<int64_t>::max())
                                    return std::nullopt;
                                result = std::make_pair(static_cast<int>(dim),
                                                        static_cast<int64_t>(combined));
                            }
                        }
                    }
                    return result;
                }

                llvm::SmallVector<Value> indices;
                if (auto load = dyn_cast<mlir::memref::LoadOp>(memOp))
                    indices.append(load.getIndices().begin(), load.getIndices().end());
                else if (auto store = dyn_cast<mlir::memref::StoreOp>(memOp))
                    indices.append(store.getIndices().begin(), store.getIndices().end());
                else
                    return std::nullopt;

                std::optional<std::pair<int, int64_t>> result;
                for (unsigned dim = 0; dim < indices.size(); ++dim)
                {
                    int64_t offset = 0;
                    if (getOffsetFromIV(indices[dim], targetIV, offset))
                    {
                        if (result)
                            return std::nullopt;
                        result = std::make_pair(static_cast<int>(dim), offset);
                    }
                }
                return result;
            }

            bool getSimpleAffineIVOffset(AffineExpr expr, unsigned ivPos,
                                         unsigned numDims, int64_t &offset)
            {
                bool foundIV = false;
                __int128 wideOffset = 0;
                std::function<bool(AffineExpr)> visit = [&](AffineExpr current) -> bool {
                    if (auto dim = dyn_cast<AffineDimExpr>(current))
                    {
                        if (ivPos >= numDims || dim.getPosition() != ivPos || foundIV)
                            return false;
                        foundIV = true;
                        return true;
                    }
                    if (auto symbol = dyn_cast<AffineSymbolExpr>(current))
                    {
                        if (ivPos < numDims ||
                            symbol.getPosition() != ivPos - numDims || foundIV)
                            return false;
                        foundIV = true;
                        return true;
                    }
                    if (auto constant = dyn_cast<AffineConstantExpr>(current))
                    {
                        wideOffset += constant.getValue();
                        return true;
                    }
                    auto binary = dyn_cast<AffineBinaryOpExpr>(current);
                    if (!binary)
                        return false;

                    if (binary.getKind() == AffineExprKind::Add)
                        return visit(binary.getLHS()) && visit(binary.getRHS());

                    if (binary.getKind() == AffineExprKind::Mul)
                    {
                        auto lhsConst = dyn_cast<AffineConstantExpr>(binary.getLHS());
                        auto rhsConst = dyn_cast<AffineConstantExpr>(binary.getRHS());
                        if (lhsConst && lhsConst.getValue() == 1)
                            return visit(binary.getRHS());
                        if (rhsConst && rhsConst.getValue() == 1)
                            return visit(binary.getLHS());
                    }
                    return false;
                };

                if (!visit(expr) || !foundIV ||
                    wideOffset < std::numeric_limits<int64_t>::min() ||
                    wideOffset > std::numeric_limits<int64_t>::max())
                    return false;
                offset = static_cast<int64_t>(wideOffset);
                return true;
            }

            bool getConstantOffsetFromIV(Value index, Value targetIV, int64_t &offset)
            {
                return getOffsetFromIV(index, targetIV, offset);
            }

        private:

            // Extract the constant integer offset of an index expression relative to
            // a loop IV. Handles the common stencil patterns:
            //   a[i]     → offset 0   (direct use of IV)
            //   a[i + c] → offset +c  (addi where one operand is IV)
            //   a[i - c] → offset -c  (subi where first operand is IV)
            //   a[c + i] → offset +c  (addi, commuted)
            // For affine accesses the offset is read directly from the affine map.
            // Returns true and sets `offset` when the pattern is recognised,
            // returns false when the index does not involve the IV at all.
            bool getOffsetFromIV(Value index, Value targetIV, int64_t &offset)
            {
                // Direct use: a[i]
                if (index == targetIV)
                {
                    offset = 0;
                    return true;
                }

                Operation *defOp = index.getDefiningOp();
                if (!defOp)
                    return false;

                auto getConstant = [](Value value, int64_t &constant) {
                    if (auto constOp = dyn_cast_or_null<mlir::arith::ConstantIndexOp>(
                            value.getDefiningOp()))
                    {
                        constant = constOp.value();
                        return true;
                    }
                    if (auto constOp = dyn_cast_or_null<mlir::arith::ConstantIntOp>(
                            value.getDefiningOp()))
                    {
                        constant = constOp.value();
                        return true;
                    }
                    return false;
                };
                auto checkedAdd = [](int64_t lhs, int64_t rhs, int64_t &sum) {
                    __int128 wide = static_cast<__int128>(lhs) + rhs;
                    if (wide < std::numeric_limits<int64_t>::min() ||
                        wide > std::numeric_limits<int64_t>::max())
                        return false;
                    sum = static_cast<int64_t>(wide);
                    return true;
                };

                // arith.addi  →  i + c  or  c + i
                if (auto addOp = dyn_cast<mlir::arith::AddIOp>(defOp))
                {
                    int64_t baseOffset = 0;
                    int64_t constant = 0;
                    if (getOffsetFromIV(addOp.getLhs(), targetIV, baseOffset) &&
                        getConstant(addOp.getRhs(), constant))
                        return checkedAdd(baseOffset, constant, offset);
                    if (getConstant(addOp.getLhs(), constant) &&
                        getOffsetFromIV(addOp.getRhs(), targetIV, baseOffset))
                        return checkedAdd(baseOffset, constant, offset);
                }

                // arith.subi  →  i - c
                if (auto subOp = dyn_cast<mlir::arith::SubIOp>(defOp))
                {
                    int64_t baseOffset = 0;
                    int64_t constant = 0;
                    if (!getOffsetFromIV(subOp.getLhs(), targetIV, baseOffset) ||
                        !getConstant(subOp.getRhs(), constant))
                        return false;
                    __int128 wide = static_cast<__int128>(baseOffset) - constant;
                    if (wide < std::numeric_limits<int64_t>::min() ||
                        wide > std::numeric_limits<int64_t>::max())
                        return false;
                    offset = static_cast<int64_t>(wide);
                    return true;
                }

                return false;
            }

            // Walk all loads and stores for a 1D array, compute the offset of each
            // index expression relative to the loop IV, and fill in haloLeft / haloRight.
            //
            //   offset < 0  →  left halo  (e.g. a[i-1] gives offset -1)
            //   offset > 0  →  right halo (e.g. a[i+1] gives offset +1)
            //   offset == 0 →  no halo for this access
            //
            // haloLeft  = max(0, -min_offset)
            // haloRight = max(0,  max_offset)
            void computeHaloForAccesses(llvm::SmallVector<Operation *> &loads,
                                        llvm::SmallVector<Operation *> &stores,
                                        Value loopIV,
                                        ArrayPartitioningInfo &info)
            {
                int64_t minOffset = 0;
                int64_t maxOffset = 0;
                bool anyFound = false;

                auto processOp = [&](Operation *memOp)
                {
                    auto access = getUnitStrideDimensionAndOffset(memOp, loopIV);
                    if (access && access->first == 0)
                    {
                        int64_t offset = access->second;
                        anyFound = true;
                        minOffset = std::min(minOffset, offset);
                        maxOffset = std::max(maxOffset, offset);
                        llvm::errs() << "  Access offset: " << offset << "\n";
                    }
                };

                for (Operation *op : loads)  processOp(op);
                for (Operation *op : stores) processOp(op);

                if (anyFound)
                {
                    __int128 left = minOffset < 0
                        ? -static_cast<__int128>(minOffset)
                        : 0;
                    __int128 right = maxOffset > 0 ? maxOffset : 0;
                    info.haloLeft = static_cast<int>(std::min<__int128>(
                        left, std::numeric_limits<int>::max()));
                    info.haloRight = static_cast<int>(std::min<__int128>(
                        right, std::numeric_limits<int>::max()));

                    llvm::errs() << "Halo: left=" << info.haloLeft
                                 << ", right=" << info.haloRight << "\n";

                    if (info.haloLeft == 0 && info.haloRight == 0)
                        llvm::errs() << "→ No halo needed (accesses match loop IV exactly)\n";
                    else
                    {
                        info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                        llvm::errs() << "→ Halo required (stencil pattern detected)\n";
                        llvm::errs() << "→ No Partition\n";
                    }
                }
            }

            // Find the outermost loop IV (works for both affine and scf loops)
            Value findOutermostLoopIV(llvm::SmallVector<Operation *> &loads,
                                      llvm::SmallVector<Operation *> &stores)
            {
                Operation *accessOp = nullptr;
                if (!loads.empty())
                    accessOp = loads[0];
                else if (!stores.empty())
                    accessOp = stores[0];

                if (!accessOp)
                    return Value();

                Value outermostIV;
                Operation *op = accessOp;

                // Walk up to find the outermost loop
                while (op)
                {
                    if (auto affineFor = dyn_cast<mlir::affine::AffineForOp>(op))
                    {
                        outermostIV = affineFor.getInductionVar();
                        op = op->getParentOp();
                    }
                    else if (auto scfFor = dyn_cast<mlir::scf::ForOp>(op))
                    {
                        outermostIV = scfFor.getInductionVar();
                        op = op->getParentOp();
                    }
                    else if (auto scfParallel = dyn_cast<mlir::scf::ParallelOp>(op))
                    {
                        // For parallel, use the first IV
                        if (!scfParallel.getInductionVars().empty())
                            outermostIV = scfParallel.getInductionVars()[0];
                        op = op->getParentOp();
                    }
                    else if (isa<mlir::dhir::ReplicateOp>(op))
                    {
                        break;
                    }
                    else
                    {
                        op = op->getParentOp();
                    }
                }

                return outermostIV;
            }
            
            // Find the loop IV that actually accesses the array (for 1D arrays)
            Value findLoopIVForArrayAccess(llvm::SmallVector<Operation *> &loads,
                                          llvm::SmallVector<Operation *> &stores)
            {
                Operation *accessOp = nullptr;
                if (!loads.empty())
                    accessOp = loads[0];
                else if (!stores.empty())
                    accessOp = stores[0];

                if (!accessOp)
                    return Value();

                llvm::SmallVector<Value> loopIVs;
                Operation *op = accessOp;

                // Walk up and collect all loop IVs (innermost to outermost)
                while (op)
                {
                    if (auto affineFor = dyn_cast<mlir::affine::AffineForOp>(op))
                    {
                        loopIVs.push_back(affineFor.getInductionVar());
                        op = op->getParentOp();
                    }
                    else if (auto scfFor = dyn_cast<mlir::scf::ForOp>(op))
                    {
                        loopIVs.push_back(scfFor.getInductionVar());
                        op = op->getParentOp();
                    }
                    else if (auto scfParallel = dyn_cast<mlir::scf::ParallelOp>(op))
                    {
                        if (!scfParallel.getInductionVars().empty())
                            loopIVs.push_back(scfParallel.getInductionVars()[0]);
                        op = op->getParentOp();
                    }
                    else if (isa<mlir::dhir::ReplicateOp>(op))
                    {
                        break;
                    }
                    else
                    {
                        op = op->getParentOp();
                    }
                }

                if (loopIVs.empty())
                    return Value();

                // Try to find which loop IV is actually used in array access
                // Start from innermost (first in the list)
                for (Value iv : loopIVs)
                {
                    // Check if this IV is used in any array access
                    for (Operation *loadOp : loads)
                    {
                        if (getDimensionForIV(loadOp, iv) >= 0)
                            return iv;  // This IV is used
                    }
                    for (Operation *storeOp : stores)
                    {
                        if (getDimensionForIV(storeOp, iv) >= 0)
                            return iv;  // This IV is used
                    }
                }

                // If no IV is found to be used, return the outermost one
                return loopIVs.back();
            }

        public:
            // Get which dimension uses a specific IV
            int getDimensionForIV(Operation *memOp, Value targetIV)
            {
                llvm::SmallVector<Value> indices;

                // Extract indices based on operation type
                if (auto affineLoad = dyn_cast<mlir::affine::AffineLoadOp>(memOp))
                {
                    indices.append(affineLoad.getMapOperands().begin(),
                                   affineLoad.getMapOperands().end());
                }
                else if (auto affineStore = dyn_cast<mlir::affine::AffineStoreOp>(memOp))
                {
                    indices.append(affineStore.getMapOperands().begin(),
                                   affineStore.getMapOperands().end());
                }
                else if (auto load = dyn_cast<mlir::memref::LoadOp>(memOp))
                {
                    indices.append(load.getIndices().begin(),
                                   load.getIndices().end());
                }
                else if (auto store = dyn_cast<mlir::memref::StoreOp>(memOp))
                {
                    indices.append(store.getIndices().begin(),
                                   store.getIndices().end());
                }

                // Find which dimension uses the target IV
                for (int dim = 0; dim < (int)indices.size(); ++dim)
                {
                    Value idx = indices[dim];

                    // Direct match
                    if (idx == targetIV) {
                        return dim;
                    }

                    // Check if it's derived from the IV (through arith ops)
                    if (isDerivedFromValue(idx, targetIV)) {
                        return dim;
                    }
                }

                return -1;
            }

            // Check if a value is derived from another (simple version)
            bool isDerivedFromValue(Value derived, Value source, int maxDepth = 5)
            {
                if (derived == source)
                    return true;

                if (maxDepth <= 0) 
                    return false;

                // Handle block arguments by looking at the parent loop's iter_args/yields
                if (auto blockArg = mlir::dyn_cast<mlir::BlockArgument>(derived)) {
                    mlir::Operation *parentOp = blockArg.getOwner()->getParentOp();
                    if (auto forOp = mlir::dyn_cast<mlir::scf::ForOp>(parentOp)) {
                        if (blockArg.getArgNumber() > 0) { // arg 0 is IV
                            Value initVal = forOp.getInitArgs()[blockArg.getArgNumber() - 1];
                            if (isDerivedFromValue(initVal, source, maxDepth - 1)) return true;
                            if (auto yieldOp = mlir::dyn_cast_or_null<mlir::scf::YieldOp>(forOp.getBody()->getTerminator())) {
                                Value yieldVal = yieldOp.getOperand(blockArg.getArgNumber() - 1);
                                if (isDerivedFromValue(yieldVal, source, maxDepth - 1)) return true;
                            }
                        }
                    } else if (auto affineFor = mlir::dyn_cast<mlir::affine::AffineForOp>(parentOp)) {
                        if (blockArg.getArgNumber() > 0) { // arg 0 is IV
                            Value initVal = affineFor.getInits()[blockArg.getArgNumber() - 1];
                            if (isDerivedFromValue(initVal, source, maxDepth - 1)) return true;
                            if (auto yieldOp = mlir::dyn_cast_or_null<mlir::affine::AffineYieldOp>(affineFor.getBody()->getTerminator())) {
                                Value yieldVal = yieldOp.getOperand(blockArg.getArgNumber() - 1);
                                if (isDerivedFromValue(yieldVal, source, maxDepth - 1)) return true;
                            }
                        }
                    }
                }

                // Check if it's an arithmetic operation using the source
                if (auto defOp = derived.getDefiningOp())
                {
                    for (Value operand : defOp->getOperands())
                    {
                        if (operand == source)
                            return true;
                        // Recursive check 
                        if (isDerivedFromValue(operand, source, maxDepth - 1))
                            return true;
                    }
                }

                return false;
            }
        };

        ArrayPartitioningInfo analyzeArrayForPartitioning(mlir::Operation *op, Value memref)
        {
            mlir::Value partitionedIV;
            op->walk<mlir::WalkOrder::PreOrder>([&](mlir::Operation *childOp) {
                if (partitionedIV) return mlir::WalkResult::interrupt();
                if (auto affineFor = mlir::dyn_cast<mlir::affine::AffineForOp>(childOp)) {
                    partitionedIV = affineFor.getInductionVar();
                    return mlir::WalkResult::interrupt();
                }
                if (auto scfFor = mlir::dyn_cast<mlir::scf::ForOp>(childOp)) {
                    partitionedIV = scfFor.getInductionVar();
                    return mlir::WalkResult::interrupt();
                }
                if (auto scfParallel = mlir::dyn_cast<mlir::scf::ParallelOp>(childOp)) {
                    partitionedIV = scfParallel.getInductionVars()[0];
                    return mlir::WalkResult::interrupt();
                }
                return mlir::WalkResult::advance();
            });

            ArrayPartitioningAnalysis analysis(op, partitionedIV);
            return analysis.analyzeArray(memref);
        }

    } // namespace dhir
} // namespace mlir

#endif

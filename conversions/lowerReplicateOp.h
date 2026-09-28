#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Conversion/Passes.h"

#include "includes/dhirDialect.h"
#include "includes/dhirTypes.h"
#include "includes/utils.h"
#include "analysis/arrayPartitionAnalysis.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/OpenMP/OpenMPDialect.h"
#include "mlir/Dialect/Math/IR/Math.h"
#include "mlir/Dialect/Index/IR/IndexDialect.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"

#include "analysis/insoutAnalysis.h"
#include "analysis/broadcastAnalysis.h"
#include "analysis/syncHoisting.h"

#include <cmath>
#include <functional>
#include <limits>
#include <map>
#include <optional>
#include <set>

using namespace mlir;

struct ConvertReplicateOp : public OpConversionPattern<mlir::dhir::ReplicateOp>
{
    using OpConversionPattern::OpConversionPattern;

    LogicalResult matchAndRewrite(
        mlir::dhir::ReplicateOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {

        mlir::Operation *module = op;
        while (module && !mlir::isa<mlir::ModuleOp>(module))
            module = module->getParentOp();

        mlir::Operation *schOp = op;
        while (schOp && !mlir::isa<mlir::dhir::ScheduleOp>(schOp))
        {
            if (mlir::isa<mlir::ModuleOp>(schOp))
            {
                op.emitError("cannot lower dhir.replicate outside a dhir.schedule");
                return failure();
            }

            schOp = schOp->getParentOp();
        }

        auto deviceVec = extractTargetDeviceSpecs(llvm::dyn_cast<mlir::ModuleOp>(module));
        llvm::errs() << "Device Count: " << deviceVec.size();
        int64_t constupperBound = 0;
        int64_t constlowerBound = 0;
        // Set when the partitioning loop's trip count is only known at run
        // time (e.g. the bound is an index_cast of a kernel argument).  The
        // shard ranges are then materialised as SSA index values and flow
        // through the task op, so distribution still happens across devices -
        // it is simply decided at run time instead of at compile time.
        bool dynamicBounds = false;
        mlir::Value dynLowerVal;
        mlir::Value dynUpperVal;
        mlir::scf::ForOp outerScfFor = nullptr;
        mlir::affine::AffineForOp outerAffineFor = nullptr;
        bool foundOuterLoop = false;

        for (auto &innerOp : op.getBody().front().getOperations())
        {
            if (mlir::isa<mlir::scf::ForOp>(innerOp))
            {
                if (foundOuterLoop)
                {
                    llvm::errs() << "Error: Replicate body has multiple top-level loops; cannot choose a single partitioning loop\n";
                    return failure();
                }
                outerScfFor = mlir::dyn_cast<mlir::scf::ForOp>(innerOp);
                foundOuterLoop = true;

                auto constUB = mlir::dyn_cast_or_null<mlir::arith::ConstantIndexOp>(
                    outerScfFor.getUpperBound().getDefiningOp());
                auto constLB = mlir::dyn_cast_or_null<mlir::arith::ConstantIndexOp>(
                    outerScfFor.getLowerBound().getDefiningOp());

                if (constUB && constLB)
                {
                    constupperBound = constUB.value();
                    constlowerBound = constLB.value();
                }
                else
                {
                    // Runtime trip count.  Keep both bounds as SSA values and
                    // let the partitioning below be computed at run time; a
                    // constant side is still a legal SSA operand.
                    dynamicBounds = true;
                    dynLowerVal = outerScfFor.getLowerBound();
                    dynUpperVal = outerScfFor.getUpperBound();
                }

                if (outerScfFor.getStep().getDefiningOp() == nullptr ||
                    !mlir::isa<mlir::arith::ConstantIndexOp>(outerScfFor.getStep().getDefiningOp()) ||
                    mlir::cast<mlir::arith::ConstantIndexOp>(outerScfFor.getStep().getDefiningOp()).value() != 1)
                {
                    llvm::errs() << "Error: Only unit-step scf.for loops can be partitioned\n";
                    return failure();
                }

                if (!outerScfFor.getInitArgs().empty())
                {
                    llvm::errs() << "Error: scf.for loops with iter_args cannot be partitioned\n";
                    return failure();
                }
            }
            else if (mlir::isa<mlir::affine::AffineForOp>(innerOp))
            {
                if (foundOuterLoop)
                {
                    llvm::errs() << "Error: Replicate body has multiple top-level loops; cannot choose a single partitioning loop\n";
                    return failure();
                }
                outerAffineFor = mlir::dyn_cast<mlir::affine::AffineForOp>(innerOp);
                foundOuterLoop = true;

                AffineMap ubMap = outerAffineFor.getUpperBoundMap();
                AffineMap lbMap = outerAffineFor.getLowerBoundMap();

                if (ubMap.getNumResults() == 1 && ubMap.getNumSymbols() == 0 &&
                    ubMap.getNumDims() == 0)
                {
                    if (auto constExpr = mlir::dyn_cast<AffineConstantExpr>(ubMap.getResult(0)))
                        constupperBound = constExpr.getValue();
                    else
                    {
                        llvm::errs() << "Error: affine.for upper bound must be constant\n";
                        return failure();
                    }
                }
                else
                {
                    llvm::errs() << "Error: affine.for upper bound must be constant\n";
                    return failure();
                }

                if (lbMap.getNumResults() == 1 && lbMap.getNumSymbols() == 0 &&
                    lbMap.getNumDims() == 0)
                {
                    if (auto constExpr = mlir::dyn_cast<AffineConstantExpr>(lbMap.getResult(0)))
                        constlowerBound = constExpr.getValue();
                    else
                    {
                        llvm::errs() << "Error: affine.for lower bound must be constant\n";
                        return failure();
                    }
                }
                else
                {
                    llvm::errs() << "Error: affine.for lower bound must be constant\n";
                    return failure();
                }

                if (outerAffineFor.getStepAsInt() != 1)
                {
                    llvm::errs() << "Error: Only unit-step affine.for loops can be partitioned\n";
                    return failure();
                }

                if (outerAffineFor.getNumRegionIterArgs() != 0)
                {
                    llvm::errs() << "Error: affine.for loops with iter_args cannot be partitioned\n";
                    return failure();
                }
            }
        }

        if (!foundOuterLoop)
        {
            llvm::errs() << "Error: Replicate body does not contain a supported top-level loop\n";
            return failure();
        }

        int64_t ub = constupperBound;
        int64_t lb = constlowerBound;
        int64_t num_devices = deviceVec.size();
        if (num_devices == 0)
        {
            llvm::errs() << "Error: No target devices are configured\n";
            return failure();
        }
        if (!dynamicBounds && ub < lb)
        {
            llvm::errs() << "Error: Replicate loop upper bound is below its lower bound\n";
            return failure();
        }
        llvm::SmallVector<mlir::dhir::ArrayPartitioningInfo> arrayPartitionInfoInVec;
        llvm::SmallVector<mlir::dhir::ArrayPartitioningInfo> arrayPartitionInfoOutVec;

        int64_t total_iters = 0;
        if (!dynamicBounds)
        {
            __int128 totalItersWide = static_cast<__int128>(ub) - static_cast<__int128>(lb);
            if (totalItersWide > std::numeric_limits<int64_t>::max())
            {
                llvm::errs() << "Error: Replicate loop iteration count is too large\n";
                return failure();
            }
            total_iters = static_cast<int64_t>(totalItersWide);
        }

        // weight = 1/cost for each node, cost cannot be 0
        std::vector<double> weights;
        double weight_sum = 0.0;

        for (int i = 0; i < num_devices; i++)
        {
            double cost = 1.0;
            if (auto costAttr = mlir::dyn_cast<mlir::FloatAttr>(getDeviceAttribute(deviceVec[i], "cost")))
            {
                cost = costAttr.getValue().convertToDouble();
            }

            if (!std::isfinite(cost) || cost <= 0.0)
            {
                llvm::errs() << "Error: device cost must be finite and > 0\n";
                return failure();
            }

            double weight = 1.0 / cost;
            weights.push_back(weight);
            weight_sum += weight;
        }

        if (!std::isfinite(weight_sum) || weight_sum <= 0.0)
        {
            llvm::errs() << "Error: device costs produce an invalid shard weighting\n";
            return failure();
        }

        std::vector<int64_t> chunk_sizes;
        // Fixed-point cumulative shard boundaries for the runtime-trip-count
        // path.  They are compile-time constants derived from the device costs,
        // so every rank derives the identical partition while the trip count
        // itself remains a runtime value.  Shard i covers
        //   [ lb + (total * num[i]) / S, lb + (total * num[i+1]) / S )
        // with S = kPartitionScale, which is contiguous, monotone and covers
        // the whole iteration space exactly (num[num_devices] == S).
        std::vector<int64_t> fractionNumerators;
        constexpr int64_t kPartitionShift = 20;
        constexpr int64_t kPartitionScale = int64_t(1) << kPartitionShift;

        if (dynamicBounds)
        {
            fractionNumerators.reserve(num_devices + 1);
            fractionNumerators.push_back(0);
            double cumulative = 0.0;
            for (int i = 0; i < num_devices; i++)
            {
                cumulative += weights[i] / weight_sum;
                int64_t numerator = static_cast<int64_t>(
                    std::llround(cumulative * static_cast<double>(kPartitionScale)));
                numerator = std::max<int64_t>(numerator, fractionNumerators.back());
                numerator = std::min<int64_t>(numerator, kPartitionScale);
                fractionNumerators.push_back(numerator);
            }
            // Land the final boundary exactly on the total so the union of all
            // shards is the entire iteration space.
            fractionNumerators[num_devices] = kPartitionScale;
        }
        else
        {
            int64_t assigned_iters = 0;

            for (int i = 0; i < num_devices; i++)
            {
                int64_t chunk = static_cast<int64_t>(
                    (weights[i] / weight_sum) * static_cast<double>(total_iters));
                chunk_sizes.push_back(chunk);
                assigned_iters += chunk;
            }

            // handle remainder iterations by adding 1 iteration to each device till all remainder iterations are assigned
            int64_t remainder = total_iters - assigned_iters;
            if (remainder < 0 || remainder >= num_devices)
            {
                llvm::errs() << "Error: shard weighting did not produce a valid remainder\n";
                return failure();
            }

            for (int i = 0; i < remainder; i++)
            {
                chunk_sizes[i % num_devices]++;
            }
        }

        llvm::SmallVector<mlir::Value> insVec(op.getReads().begin(),
                                              op.getReads().end());
        llvm::SmallVector<mlir::Value> outsVec(op.getWrites().begin(),
                                               op.getWrites().end());

        bool isSingleLoop = false;

        bool isStencil = false;
        if (auto stencilAttr = op->getAttrOfType<StringAttr>("pattern"))
        {
            if (stencilAttr.getValue() == "stencil")
                isStencil = true;
        }

        // Find the for loop (scf or affine) and determine if it's single or nested
        for (auto &innerOp : op.getBody().front().getOperations())
        {
            if (auto forOp = mlir::dyn_cast<mlir::scf::ForOp>(innerOp))
            {
                outerScfFor = forOp;
                isSingleLoop = true;
                for (auto &nestedOp : forOp.getBody()->getOperations())
                {
                    if (mlir::isa<mlir::scf::ForOp>(nestedOp) ||
                        mlir::isa<mlir::affine::AffineForOp>(nestedOp))
                    {
                        isSingleLoop = false;
                        break;
                    }
                }
                break;
            }
            else if (auto affineFor = mlir::dyn_cast<mlir::affine::AffineForOp>(innerOp))
            {
                outerAffineFor = affineFor;
                isSingleLoop = true;
                for (auto &nestedOp : affineFor.getBody()->getOperations())
                {
                    if (mlir::isa<mlir::scf::ForOp>(nestedOp) ||
                        mlir::isa<mlir::affine::AffineForOp>(nestedOp))
                    {
                        isSingleLoop = false;
                        break;
                    }
                }
                break;
            }
        }

        // Use whichever loop op we found as the root for array partition analysis
        mlir::Operation *outerForOp =
            outerScfFor ? outerScfFor.getOperation() : outerAffineFor ? outerAffineFor.getOperation()
                                                                      : nullptr;

        if (outerForOp)
        {
            if (isSingleLoop)
                llvm::errs() << "Analyzing 1D array partitioning (single for loop)...\n";
            else
                llvm::errs() << "Analyzing 2D array partitioning (nested for loops)...\n";

            for (Value memref : insVec)
            {
                mlir::dhir::ArrayPartitioningAnalysis analysis(outerForOp, (outerScfFor ? outerScfFor.getInductionVar() : outerAffineFor.getInductionVar()));
                arrayPartitionInfoInVec.push_back(analysis.analyzeArray(memref));
            }

            for (Value memref : outsVec)
            {
                mlir::dhir::ArrayPartitioningAnalysis analysis(outerForOp, (outerScfFor ? outerScfFor.getInductionVar() : outerAffineFor.getInductionVar()));
                arrayPartitionInfoOutVec.push_back(analysis.analyzeArray(memref));
            }
        }
        else
        {
            llvm::errs() << "Warning: No for loop found in schedule body\n";
        }

        int64_t stencilPartitionDim = -1;
        int64_t stencilHaloLeft = 0;
        int64_t stencilHaloRight = 0;
        auto collectHalo = [&](const auto &info) {
            if (info.haloLeft == 0 && info.haloRight == 0)
                return;
            if (stencilPartitionDim < 0)
                stencilPartitionDim = info.partitionDimension;
            else if (stencilPartitionDim != info.partitionDimension)
                stencilPartitionDim = -2;
            stencilHaloLeft = std::max<int64_t>(stencilHaloLeft, info.haloLeft);
            stencilHaloRight = std::max<int64_t>(stencilHaloRight, info.haloRight);
        };
        for (const auto &info : arrayPartitionInfoInVec)
            collectHalo(info);
        for (const auto &info : arrayPartitionInfoOutVec)
            collectHalo(info);
        if (isStencil && stencilPartitionDim == -2)
        {
            op.emitError("stencil operands require halos on inconsistent dimensions");
            return failure();
        }

        Value partitionedIV = outerScfFor ? outerScfFor.getInductionVar()
                                          : outerAffineFor.getInductionVar();

        // MPIToLLVM can transfer both contiguous slabs and strided views through
        // a derived datatype. Keep the structural checks here: the partitioner
        // supports ranked memrefs up to rank three and cannot form a useful
        // subview through a statically empty dimension.
        auto supportsPartitionTransfer = [](MemRefType type) {
            if (type.getRank() < 1 || type.getRank() > 3)
                return false;
            for (int64_t dim = 0; dim < type.getRank(); ++dim)
                if (type.isDynamicDim(dim))
                    continue;
                else if (type.getDimSize(dim) == 0)
                    return false;
            return true;
        };

        // DHIR-to-MPI gathers every task output as a run of elements on
        // dimension 0.  A store is gather-safe when its dimension-0 index
        // advances one-for-one with the partitioned IV, even when the index is
        // written as `iv*stride + inner`, where `inner` ranges over exactly
        // [0, stride) across the loop nest.  In that form the whole shard
        // [start,end) is still covered contiguously, because the inner terms of
        // consecutive iterations tile the gap between `iv` and `iv+1` with no
        // hole.  Rejecting that shape would refuse kernels the gather can
        // already move correctly.
        //
        // True when `value` is defined in terms of the partitioned IV (directly
        // or through any chain of pure operations).
        std::function<bool(Value)> valueDependsOnIV = [&](Value value) -> bool {
            if (!value)
                return false;
            if (value == partitionedIV)
                return true;
            Operation *def = value.getDefiningOp();
            if (!def || !mlir::isMemoryEffectFree(def))
                return false;
            for (Value operand : def->getOperands())
                if (valueDependsOnIV(operand))
                    return true;
            return false;
        };

        // Returns true when `index` is an affine expression in `partitionedIV`
        // whose coefficient is a positive loop-invariant constant.  The
        // multiplicative constant is *not* resolved: a positive coefficient is
        // enough because it means the shard's covered range stays contiguous.
        std::function<bool(Value, int64_t &)> indexAdvancesWithIV =
            [&](Value index, int64_t &coefficient) -> bool {
            coefficient = 0;
            if (index == partitionedIV) {
                coefficient = 1;
                return true;
            }
            Operation *def = index.getDefiningOp();
            if (!def)
                return false;

            if (auto add = dyn_cast<mlir::arith::AddIOp>(def)) {
                int64_t lhs = 0, rhs = 0;
                bool lhsHasIV = indexAdvancesWithIV(add.getLhs(), lhs);
                bool rhsHasIV = indexAdvancesWithIV(add.getRhs(), rhs);
                if (lhsHasIV && rhsHasIV)
                    return false; // two IV-dependent terms: not a simple ramp
                if (lhsHasIV) { coefficient = lhs; return true; }
                if (rhsHasIV) { coefficient = rhs; return true; }
                return false;
            }
            if (auto mul = dyn_cast<mlir::arith::MulIOp>(def)) {
                // Exactly one side must be an IV-dependent ramp and the other a
                // value provably free of the IV for the product to stay a ramp.
                int64_t lhs = 0, rhs = 0;
                bool lhsHasIV = indexAdvancesWithIV(mul.getLhs(), lhs);
                bool rhsHasIV = indexAdvancesWithIV(mul.getRhs(), rhs);
                if (lhsHasIV == rhsHasIV)
                    return false;
                Value other = lhsHasIV ? mul.getRhs() : mul.getLhs();
                if (valueDependsOnIV(other))
                    return false;
                coefficient = lhsHasIV ? lhs : rhs;
                return true;
            }
            if (auto sub = dyn_cast<mlir::arith::SubIOp>(def)) {
                int64_t lhs = 0;
                // Only `ramp - invariant` keeps the index advancing with the IV.
                if (indexAdvancesWithIV(sub.getLhs(), lhs) && !valueDependsOnIV(sub.getRhs())) {
                    coefficient = lhs;
                    return true;
                }
                return false;
            }
            // Widening/narrowing casts of the IV preserve the ramp structure.
            if (auto castOp = dyn_cast<mlir::arith::IndexCastOp>(def))
                return indexAdvancesWithIV(castOp.getIn(), coefficient);
            if (auto ext = dyn_cast<mlir::arith::ExtSIOp>(def))
                return indexAdvancesWithIV(ext.getIn(), coefficient);
            if (auto ext = dyn_cast<mlir::arith::ExtUIOp>(def))
                return indexAdvancesWithIV(ext.getIn(), coefficient);
            if (auto tr = dyn_cast<mlir::arith::TruncIOp>(def))
                return indexAdvancesWithIV(tr.getIn(), coefficient);
            return false;
        };
        // Some outputs cannot be gathered as a slab at all: their store index is
        // data dependent (histogram bins, permuted rows, cluster ids).  Those are
        // still parallelisable, but they are reductions rather than slabs: each
        // shard accumulates into a private buffer and the buffers are summed.
        // Seeding shard 0's buffer with the output as it stands and zeroing the
        // others makes that sum exactly the sequential result, both for
        // read-modify-write accumulation and for disjoint overwrite.
        llvm::SmallVector<bool> partialReduceOut(outsVec.size(), false);
        bool hasPartialReduceOutput = false;

        for (size_t outIdx = 0; outIdx < outsVec.size(); ++outIdx) {
            Value out = outsVec[outIdx];
            auto type = dyn_cast<MemRefType>(out.getType());
            if (!type || !supportsPartitionTransfer(type)) {
                op.emitError("output cannot be represented as a supported partition view");
                return failure();
            }

            bool sawStore = false;
            bool unsupportedStore = false;

            outerForOp->walk([&](Operation *nestedOp) {
                Value storedMemref;
                if (auto store = dyn_cast<mlir::affine::AffineStoreOp>(nestedOp))
                    storedMemref = store.getMemRef();
                else if (auto store = dyn_cast<mlir::memref::StoreOp>(nestedOp))
                    storedMemref = store.getMemRef();
                else
                    return;

                if (storedMemref != out)
                    return;
                sawStore = true;

                // Rank-0 (flat) outputs are gathered whole on dimension 0.
                // Their store index is the flattened address, so the ramp test
                // below would demand the IV appear unmultiplied, which is not
                // the form a flattened 2D/3D kernel produces.  Validate them
                // with the existing affine analysis instead.
                SmallVector<Value> indices;
                if (auto store = dyn_cast<mlir::affine::AffineStoreOp>(nestedOp))
                    indices.assign(store.getMapOperands().begin(),
                                   store.getMapOperands().end());
                else if (auto store = dyn_cast<mlir::memref::StoreOp>(nestedOp))
                    indices.assign(store.getIndices().begin(),
                                   store.getIndices().end());

                bool rampSafe = false;
                for (Value index : indices) {
                    int64_t coefficient = 0;
                    if (indexAdvancesWithIV(index, coefficient) && coefficient != 0) {
                        rampSafe = true;
                        break;
                    }
                }
                if (!rampSafe) {
                    mlir::dhir::ArrayPartitioningAnalysis outputAnalysis(
                        outerForOp, partitionedIV);
                    auto access = outputAnalysis.getUnitStrideDimensionAndOffset(
                        nestedOp, partitionedIV);
                    rampSafe = access && access->first == 0 && access->second == 0;
                }
                if (!rampSafe)
                    unsupportedStore = true;
            });

            if (!sawStore) {
                op.emitError("replicate output is never stored to");
                return failure();
            }
            // A store that does not advance with the partitioned IV makes the
            // whole output a reduction target.
            if (unsupportedStore) {
                partialReduceOut[outIdx] = true;
                hasPartialReduceOutput = true;
            }
        }

        // Decide which whole operands need an explicit shard-start rebase when
        // another operand is represented by a row subview. The old implementation
        // demoted every operand if one access was whole; that was correct only for
        // the narrowest case and unnecessarily removed legal slices.
        llvm::SmallVector<Value> unslicedIVMemrefs;
        bool forceAbsoluteBounds = false;
        // A partial-reduce output is written with global indices into a private
        // buffer, so its shard must iterate the absolute range: slicing any
        // other operand would put the body in shard-local coordinates.
        if (hasPartialReduceOutput)
            forceAbsoluteBounds = true;
        mlir::dhir::ArrayPartitioningAnalysis *partitionAnalysis = nullptr;
        std::optional<mlir::dhir::ArrayPartitioningAnalysis> analysisStorage;

        auto isReplicateOperand = [&](Value memref) {
            return llvm::is_contained(insVec, memref) || llvm::is_contained(outsVec, memref);
        };
        auto isSlicedOperand = [&](Value memref) {
            for (size_t i = 0; i < insVec.size(); ++i)
                if (insVec[i] == memref &&
                    arrayPartitionInfoInVec[i].strategy !=
                        mlir::dhir::ArrayPartitioningInfo::NO_PARTITION &&
                    arrayPartitionInfoInVec[i].haloLeft == 0 &&
                    arrayPartitionInfoInVec[i].haloRight == 0)
                    return true;
            for (size_t i = 0; i < outsVec.size(); ++i)
                if (outsVec[i] == memref &&
                    arrayPartitionInfoOutVec[i].strategy !=
                        mlir::dhir::ArrayPartitioningInfo::NO_PARTITION)
                    return true;
            return false;
        };

        if (partitionedIV) {
            analysisStorage.emplace(outerForOp, partitionedIV);
            partitionAnalysis = &*analysisStorage;

            std::function<bool(Value, llvm::SmallVectorImpl<Value> &)> supportedIVUse;
            supportedIVUse = [&](Value value, llvm::SmallVectorImpl<Value> &seen) -> bool {
                if (llvm::is_contained(seen, value))
                    return true;
                seen.push_back(value);
                for (Operation *user : value.getUsers()) {
                    if (user == outerForOp)
                        continue;

                    if (auto load = dyn_cast<mlir::affine::AffineLoadOp>(user)) {
                        if (llvm::is_contained(load.getMapOperands(), value) &&
                            partitionAnalysis->getUnitStrideDimensionAndOffset(user, value))
                            continue;
                        return false;
                    }
                    if (auto store = dyn_cast<mlir::affine::AffineStoreOp>(user)) {
                        if (llvm::is_contained(store.getMapOperands(), value) &&
                            partitionAnalysis->getUnitStrideDimensionAndOffset(user, value))
                            continue;
                        return false;
                    }
                    if (auto load = dyn_cast<mlir::memref::LoadOp>(user)) {
                        if (llvm::is_contained(load.getIndices(), value) &&
                            partitionAnalysis->getUnitStrideDimensionAndOffset(user, value))
                            continue;
                        return false;
                    }
                    if (auto store = dyn_cast<mlir::memref::StoreOp>(user)) {
                        if (llvm::is_contained(store.getIndices(), value) &&
                            partitionAnalysis->getUnitStrideDimensionAndOffset(user, value))
                            continue;
                        return false;
                    }

                    if (auto add = dyn_cast<mlir::arith::AddIOp>(user)) {
                        int64_t offset = 0;
                        if (partitionAnalysis->getConstantOffsetFromIV(
                                add.getResult(), partitionedIV, offset)) {
                            if (supportedIVUse(add.getResult(), seen))
                                continue;
                        }
                        return false;
                    }
                    if (auto sub = dyn_cast<mlir::arith::SubIOp>(user)) {
                        int64_t offset = 0;
                        if (partitionAnalysis->getConstantOffsetFromIV(
                                sub.getResult(), partitionedIV, offset)) {
                            if (supportedIVUse(sub.getResult(), seen))
                                continue;
                        }
                        return false;
                    }
                    return false;
                }
                return true;
            };

            llvm::SmallVector<Value> seen;
            if (!supportedIVUse(partitionedIV, seen)) {
                forceAbsoluteBounds = true;
                llvm::errs() << "Partitioned IV escapes supported memory indices; "
                                "disabling slicing for this replicate\n";
            }

            auto collectUnsliced = [&](Value memref, bool sliced) {
                if (!isReplicateOperand(memref) || sliced ||
                    llvm::is_contained(unslicedIVMemrefs, memref))
                    return;
                bool usesIV = false;
                op.getBody().front().walk([&](Operation *nestedOp) {
                    if (auto load = dyn_cast<mlir::affine::AffineLoadOp>(nestedOp))
                        usesIV |= load.getMemRef() == memref &&
                                  partitionAnalysis->getDimensionForIV(nestedOp, partitionedIV) >= 0;
                    else if (auto store = dyn_cast<mlir::affine::AffineStoreOp>(nestedOp))
                        usesIV |= store.getMemRef() == memref &&
                                  partitionAnalysis->getDimensionForIV(nestedOp, partitionedIV) >= 0;
                    else if (auto load = dyn_cast<mlir::memref::LoadOp>(nestedOp))
                        usesIV |= load.getMemRef() == memref &&
                                  partitionAnalysis->getDimensionForIV(nestedOp, partitionedIV) >= 0;
                    else if (auto store = dyn_cast<mlir::memref::StoreOp>(nestedOp))
                        usesIV |= store.getMemRef() == memref &&
                                  partitionAnalysis->getDimensionForIV(nestedOp, partitionedIV) >= 0;
                });
                if (usesIV)
                    unslicedIVMemrefs.push_back(memref);
            };

            for (size_t i = 0; i < insVec.size(); ++i)
                collectUnsliced(insVec[i], isSlicedOperand(insVec[i]));
            for (size_t i = 0; i < outsVec.size(); ++i)
                collectUnsliced(outsVec[i], isSlicedOperand(outsVec[i]));
        }

        if (forceAbsoluteBounds) {
            for (auto &info : arrayPartitionInfoInVec) {
                info.strategy = mlir::dhir::ArrayPartitioningInfo::NO_PARTITION;
                info.partitionReason = "partitioned IV escapes supported memory-index forms";
            }
            for (auto &info : arrayPartitionInfoOutVec) {
                info.strategy = mlir::dhir::ArrayPartitioningInfo::NO_PARTITION;
                info.partitionReason = "partitioned IV escapes supported memory-index forms";
            }
            unslicedIVMemrefs.clear();
        }

        llvm::SmallVector<mlir::Value> subViewIns;
        llvm::SmallVector<mlir::Value> subViewOuts;

        // Runtime-trip-count plumbing: total = ub - lb, and a boundary helper
        // that returns lb + (total * numerator) / S as an index value.  All of
        // this is emitted once per replicate and dominates every shard task, so
        // each device still receives its own distinct slice - the partition is
        // simply materialised at run time.
        // Loop bounds are frequently defined *inside* the replicate region
        // (the constant 0, or an affine combination of kernel arguments).  Any
        // value created in the parent scope must not reference region-local
        // values, otherwise the shard would use a value that dies with the
        // region.  Re-materialise such bound expressions in the parent scope.
        std::function<Value(Value)> materializeOutsideRegion =
            [&](Value value) -> Value {
            if (!value)
                return Value();
            Operation *def = value.getDefiningOp();
            if (!def)
                return value; // block argument, already outer
            if (!op->isAncestor(def))
                return value; // already defined outside the region
            if (!mlir::isMemoryEffectFree(def))
                return Value(); // side-effecting/region-local: cannot hoist

            llvm::SmallVector<Value, 4> newOperands;
            for (Value operand : def->getOperands())
            {
                Value mapped = materializeOutsideRegion(operand);
                if (!mapped)
                    return Value();
                newOperands.push_back(mapped);
            }

            OpBuilder::InsertionGuard hoistGuard(rewriter);
            rewriter.setInsertionPoint(op);
            IRMapping hoistMapping;
            for (auto [original, replacement] : llvm::zip(def->getOperands(), newOperands))
                hoistMapping.map(original, replacement);
            Operation *cloned = rewriter.clone(*def, hoistMapping);
            return cloned->getResult(0);
        };

        Value dynTotalVal;
        if (dynamicBounds)
        {
            OpBuilder::InsertionGuard dynGuard(rewriter);
            rewriter.setInsertionPoint(op);
            Value lowerOutside = materializeOutsideRegion(dynLowerVal);
            Value upperOutside = materializeOutsideRegion(dynUpperVal);
            if (!lowerOutside || !upperOutside)
            {
                op.emitError("partitioning loop bounds cannot be materialised "
                             "outside the replicate region");
                return failure();
            }
            dynLowerVal = lowerOutside;
            dynUpperVal = upperOutside;
            Value rawTotal =
                rewriter.create<arith::SubIOp>(op.getLoc(), dynUpperVal, dynLowerVal);
            // A runtime upper bound may legitimately be below the lower bound
            // (empty iteration space).  The boundary helper scales by a fixed
            // point fraction and logical-shifts right, so a negative total
            // would wrap into an enormous offset.  Clamp to zero instead: an
            // empty space then yields empty shards rather than wild subviews.
            Value zeroTotal = rewriter.create<arith::ConstantIndexOp>(op.getLoc(), 0);
            dynTotalVal =
                rewriter.create<arith::MaxSIOp>(op.getLoc(), rawTotal, zeroTotal);
        }

        auto emitDynamicBoundary = [&](int64_t numerator) -> Value {
            // The two extreme fractions need no scaling: numerator 0 lands on
            // the lower bound and numerator S lands on the upper bound, so the
            // common case of the first shard and the last shard costs nothing.
            if (numerator == 0)
                return dynLowerVal;
            if (numerator == kPartitionScale)
                // Use lb + clampedTotal rather than raw upper bound. For ub >= lb
                // both values match, but for a valid zero-trip loop (ub < lb),
                // total clamps to 0 across intermediate boundaries while raw ub remains
                // below lb. Returning raw ub would assign a negative extent to the last
                // shard, triggering MPI_ERR_COUNT at runtime even if the body never runs.
                return rewriter.create<arith::AddIOp>(op.getLoc(), dynLowerVal,
                                                      dynTotalVal);
                     
            Value numVal = rewriter.create<arith::ConstantIndexOp>(op.getLoc(), numerator);
            Value scaled = rewriter.create<arith::MulIOp>(op.getLoc(), dynTotalVal, numVal);
            Value shift = rewriter.create<arith::ConstantIndexOp>(op.getLoc(), kPartitionShift);
            Value shifted = rewriter.create<arith::ShRUIOp>(op.getLoc(), scaled, shift);
            return rewriter.create<arith::AddIOp>(op.getLoc(), dynLowerVal, shifted);
        };

        // Private accumulation buffers for outputs that are not row slabs: one
        // buffer per such output, shared by every shard task.  Each rank runs at
        // most one shard of a replicate, so one buffer per replicate is enough
        // and costs one output-sized allocation instead of num_devices of them.
        llvm::SmallVector<Value> privateOutBuffers(outsVec.size());
        if (hasPartialReduceOutput)
        {
            OpBuilder::InsertionGuard privGuard(rewriter);
            rewriter.setInsertionPoint(op);
            for (size_t i = 0; i < outsVec.size(); ++i)
            {
                if (!partialReduceOut[i])
                    continue;
                auto ty = cast<MemRefType>(outsVec[i].getType());
                SmallVector<Value> dynSizes;
                for (unsigned d = 0; d < (unsigned)ty.getRank(); ++d)
                    if (ty.isDynamicDim(d))
                        dynSizes.push_back(
                            rewriter.create<memref::DimOp>(op.getLoc(), outsVec[i], (int64_t)d));
                privateOutBuffers[i] =
                    rewriter.create<memref::AllocOp>(op.getLoc(), ty, dynSizes);
            }
        }

        // Zero every element of a private buffer.  Emitted as nested loops so it
        // works for any rank and any dynamic extent, and stays inside the
        // memref/scf/arith dialects the rest of this pipeline already lowers.
        std::function<void(OpBuilder &, Value, unsigned, llvm::SmallVectorImpl<Value> &)>
            emitZeroFill = [&](OpBuilder &builder, Value memref, unsigned dim,
                               llvm::SmallVectorImpl<Value> &indices) {
                auto type = cast<MemRefType>(memref.getType());
                if (dim == (unsigned)type.getRank())
                {
                    Value zero = builder.create<arith::ConstantOp>(
                        op.getLoc(), builder.getZeroAttr(type.getElementType()));
                    builder.create<memref::StoreOp>(op.getLoc(), zero, memref, indices);
                    return;
                }
                Value lower = builder.create<arith::ConstantIndexOp>(op.getLoc(), 0);
                Value upper;
                if (type.isDynamicDim(dim))
                    upper = builder.create<memref::DimOp>(op.getLoc(), memref, (int64_t)dim);
                else
                    upper = builder.create<arith::ConstantIndexOp>(
                        op.getLoc(), type.getDimSize(dim));
                Value step = builder.create<arith::ConstantIndexOp>(op.getLoc(), 1);
                auto forOp = builder.create<scf::ForOp>(op.getLoc(), lower, upper, step);
                builder.setInsertionPointToStart(forOp.getBody());
                indices.push_back(forOp.getInductionVar());
                emitZeroFill(builder, memref, dim + 1, indices);
                indices.pop_back();
                builder.setInsertionPointAfter(forOp);
            };

        // Decided once, before any shard is emitted: the legality walk inspects
        // the enclosing loop for accesses to the buffer, and a shard body
        // already lowered into that loop would look like one.
        mlir::Operation *deferSyncLoop = nullptr;
        const bool shardIsSlabLocal =
            mlir::dhir::canDeferSyncOutOfLoop(op, deferSyncLoop);

        int64_t current = constlowerBound;
        for (int i = 0; i < num_devices; ++i)
        {
            int64_t chunk = 0;
            int64_t start = 0;
            int64_t end = 0;
            Value startVal;
            Value chunkVal;
            Value endVal;
            Value shardZeroVal;

            IRMapping mapping;
            PatternRewriter::InsertionGuard guard(rewriter);
            rewriter.setInsertionPoint(op);

            if (dynamicBounds)
            {
                startVal = emitDynamicBoundary(fractionNumerators[i]);
                endVal = emitDynamicBoundary(fractionNumerators[i + 1]);
                chunkVal = rewriter.create<arith::SubIOp>(op.getLoc(), endVal, startVal);
                // Materialise the shard-local lower bound here, while the
                // insertion point is still in front of the task op.  A value
                // created afterwards would be referenced from inside the task
                // region without dominating it (the rebased shards begin at 0).
                shardZeroVal = rewriter.create<arith::ConstantIndexOp>(op.getLoc(), 0);
            }
            else
            {
                chunk = chunk_sizes[i];
                start = current;
                end = start + chunk;
                current = end;
            }

            bool needBroadcast = false;

            // Tracks whether any operand was replaced by a subview along the
            // partitioned dimension. If so the task body indexes the slice from
            // 0, so the loop must run over [0, chunk). If nothing was
            // subviewed the task still indexes the full array, so the loop must
            // run over the absolute range [start, end).
            bool indicesRebased = false;

            auto createPartitionSubview = [&](Value buffer,
                                              const auto &partitionInfo) -> Value {
                auto memrefType = dyn_cast<MemRefType>(buffer.getType());
                if (!memrefType || partitionInfo.partitionDimension < 0 ||
                    partitionInfo.partitionDimension >= memrefType.getRank())
                    return Value();

                SmallVector<OpFoldResult> offsets, sizes, strides;
                for (int64_t d = 0; d < memrefType.getRank(); ++d)
                {
                    bool partitioned = d == partitionInfo.partitionDimension;
                    offsets.push_back(partitioned
                        ? (dynamicBounds
                               ? OpFoldResult(startVal)
                               : OpFoldResult(rewriter.getIndexAttr(
                                     std::max<int64_t>(0, start))))
                        : OpFoldResult(rewriter.getIndexAttr(0)));

                    if (partitioned)
                        sizes.push_back(dynamicBounds
                            ? OpFoldResult(chunkVal)
                            : OpFoldResult(rewriter.getIndexAttr(chunk)));
                    else if (memrefType.isDynamicDim(d))
                        sizes.push_back(OpFoldResult(rewriter.create<memref::DimOp>(
                            op.getLoc(), buffer, d)));
                    else
                        sizes.push_back(
                            OpFoldResult(rewriter.getIndexAttr(memrefType.getDimSize(d))));
                    strides.push_back(rewriter.getIndexAttr(1));
                }

                return rewriter.create<memref::SubViewOp>(
                    op.getLoc(), buffer, offsets, sizes, strides);
            };

            for (int i = 0; i < (int)insVec.size(); ++i)
            {
                auto in = insVec[i];
                auto partitionInfo = arrayPartitionInfoInVec[i];

                if (partitionInfo.strategy != partitionInfo.NO_PARTITION &&
                    partitionInfo.haloLeft == 0 && partitionInfo.haloRight == 0)
                {
                    Value subview = createPartitionSubview(in, partitionInfo);
                    if (subview)
                    {
                        subViewIns.push_back(subview);
                        mapping.map(in, subview);
                        indicesRebased = true;
                    }
                }
                else
                {
                    mapping.map(in, in);
                    subViewIns.push_back(in);
                }
            }

            needBroadcast = false;
            llvm::SmallVector<int64_t, 4> partialReduceIdx;
            llvm::SmallVector<int64_t, 4> outputPartitionDims;
            for (int i = 0; i < (int)outsVec.size(); ++i)
            {
                auto out = outsVec[i];
                auto partitionInfo = arrayPartitionInfoOutVec[i];

                if (partialReduceOut[i])
                {
                    // Accumulate into this shard's private buffer.  The buffer
                    // spans the whole output and the body keeps global indices,
                    // so no rebasing is needed for it.
                    subViewOuts.push_back(privateOutBuffers[i]);
                    mapping.map(out, privateOutBuffers[i]);
                    partialReduceIdx.push_back(i);
                    outputPartitionDims.push_back(-1);
                }
                else if (partitionInfo.strategy != partitionInfo.NO_PARTITION)
                {
                    Value subview = createPartitionSubview(out, partitionInfo);
                    if (!subview)
                    {
                        op.emitError("failed to create output partition subview");
                        return failure();
                    }

                    subViewOuts.push_back(subview);
                    mapping.map(out, subview);
                    indicesRebased = true;
                    outputPartitionDims.push_back(partitionInfo.partitionDimension);
                }

                else
                {
                    subViewOuts.push_back(out);
                    mapping.map(out, out);
                    // No local subview for this output: either replicated, or
                    // slicing was disabled (forceAbsoluteBounds) while the
                    // iteration is still sharded on the analyzed axis.  Using
                    // dim 0 there reassembles the wrong axis — heap corruption
                    // when it's larger (leukocyte np=4 crash).  Use the analyzed
                    // dim when real (>=0), else 0 for replicated outputs.
                    if (forceAbsoluteBounds &&
                        partitionInfo.partitionDimension >= 0)
                        outputPartitionDims.push_back(
                            partitionInfo.partitionDimension);
                    else
                        outputPartitionDims.push_back(0);
                }

                if (op->hasAttr("forceBroadcast") ||
                    mlir::dhir::doesOutputNeedBroadcast(op, out))
                    needBroadcast = true;
            }

            // A shard in a serial loop is synced every iteration in case it
            // feeds the next one.  When every access stays in this rank's own
            // slab that is redundant, so mark the task and let dhir-to-mpi
            // emit one sync after the loop instead.
            bool deferSync = needBroadcast && shardIsSlabLocal;
            if (deferSync && i == 0)
                llvm::errs() << "Shard is slab-local across its enclosing serial "
                                "loop; deferring sync until after the loop\n";


            // Runtime shards carry their [start, end) range as operands so the
            // gather/scatter extent can be sliced dynamically downstream; the
            // compile-time attributes remain authoritative for the static path
            // and its codegen is left untouched.
            mlir::DenseI64ArrayAttr outRanges = dynamicBounds
                                                    ? rewriter.getDenseI64ArrayAttr({0, 0})
                                                    : rewriter.getDenseI64ArrayAttr({start, end});
            // Own the operands: a ValueRange built from an initializer list
            // only borrows storage that dies at the end of its statement.
            llvm::SmallVector<mlir::Value, 2> shardRangeStorage;
            if (dynamicBounds)
            {
                shardRangeStorage.push_back(startVal);
                shardRangeStorage.push_back(endVal);
            }
            auto taskOp = rewriter.create<dhir::TaskOp>(
                op.getLoc(),
                dhir::TaskRefType::get(rewriter.getContext()),
                deviceVec[i],
                ValueRange(subViewIns), rewriter.getDenseI64ArrayAttr({0, 0}),
                ValueRange(subViewOuts), outRanges, ValueRange{outsVec},
                ValueRange(shardRangeStorage));
            taskOp->setAttr("name", rewriter.getStringAttr(std::to_string(i)));
            taskOp->setAttr("needBroadcast", rewriter.getBoolAttr(needBroadcast));

            // dhir-to-mpi still has the last word: it emits the sync inline
            // anyway if the values the gather needs cannot leave the loop.
            if (deferSync)
                taskOp->setAttr("deferSync", rewriter.getUnitAttr());
            mlir::IntegerAttr repIdAttr;
            if (auto attr = op->getAttrOfType<mlir::IntegerAttr>("replicateID"))
                repIdAttr = attr;
            else
            {
                llvm::errs() << "Error: ReplicateOp is missing replicateID\n";
                return failure();
            }
            taskOp->setAttr("repId", repIdAttr);
            taskOp->setAttr("shardGroup", repIdAttr);

            if (!partialReduceIdx.empty())
                taskOp->setAttr("partialReduce",
                                rewriter.getDenseI64ArrayAttr(partialReduceIdx));
            taskOp->setAttr("outputPartitionDims",
                            rewriter.getDenseI64ArrayAttr(outputPartitionDims));
            if (isStencil && stencilPartitionDim >= 0)
            {
                taskOp->setAttr("stencil", rewriter.getUnitAttr());
                taskOp->setAttr("stencilPartitionDim",
                                rewriter.getI64IntegerAttr(stencilPartitionDim));
                taskOp->setAttr("haloLeft",
                                rewriter.getI64IntegerAttr(stencilHaloLeft));
                taskOp->setAttr("haloRight",
                                rewriter.getI64IntegerAttr(stencilHaloRight));
            }

            if (taskOp.getRegion().empty())
                rewriter.createBlock(&taskOp.getRegion());

            rewriter.setInsertionPointToStart(&taskOp.getRegion().front());

            // Initialise the private buffers before the body runs: shard 0
            // starts from the output as it stands, every other shard from zero.
            // Their sum is therefore the sequential result.
            for (int64_t reduceIdx : partialReduceIdx)
            {
                Value priv = privateOutBuffers[reduceIdx];
                if (i == 0)
                    rewriter.create<memref::CopyOp>(op.getLoc(), outsVec[reduceIdx], priv);
                else
                {
                    llvm::SmallVector<Value, 4> zeroIndices;
                    emitZeroFill(rewriter, priv, 0, zeroIndices);
                }
            }
            // The zero-fill loops moved the insertion point inside them; put
            // it back at the END of the task body so the cloned body follows
            // the initialisation.  setInsertionPointToStart would insert the
            // body before the init ops, letting the compute run first and the
            // copy/zero-fill clobber every partial (e.g. spmv, histo).
            rewriter.setInsertionPointToEnd(&taskOp.getRegion().front());

            //   rebased  -> [0,chunk)
            //   otherwise -> [start,end), global
            // The second case covers any replicate who uses NO_PARTITION.
            // The runtime path keeps the identical two cases, with the bounds
            // expressed as SSA values so the shard still iterates exactly its
            // own slice of the (runtime sized) iteration space.
            const int64_t loopLb = indicesRebased ? 0 : start;
            const int64_t loopUb = indicesRebased ? chunk : end;
            Value dynamicLoopLb;
            Value dynamicLoopUb;
            if (dynamicBounds)
            {
                if (indicesRebased)
                {
                    // Both bounds must already dominate the task region; the
                    // zero was created above, before the task op.
                    dynamicLoopLb = shardZeroVal;
                    dynamicLoopUb = chunkVal;
                }
                else
                {
                    dynamicLoopLb = startVal;
                    dynamicLoopUb = endVal;
                }
            }

            if (!indicesRebased)
                llvm::errs() << "No operand was partitioned; task " << i
                             << " iterates the absolute range [" << loopLb << ", "
                             << loopUb << ")\n";

            auto isUnslicedMemref = [&](Value value) {
                for (Value original : unslicedIVMemrefs) {
                    if (mapping.lookupOrDefault(original) == value)
                        return true;
                }
                return false;
            };

            // Once a legal operand is represented by a subview, its accesses are
            // expressed in the local [0, chunk) coordinate system. Whole operands
            // must be rebased at the individual access that still uses the outer
            // IV; accesses through another (e.g. inner-loop) IV remain untouched.
            auto rebaseUnslicedAccesses = [&](Operation *container, Value localIV) {
                if (!indicesRebased || unslicedIVMemrefs.empty())
                    return;

                container->walk([&](Operation *nestedOp) {
                    if (auto load = dyn_cast<mlir::affine::AffineLoadOp>(nestedOp)) {
                        if (!isUnslicedMemref(load.getMemRef()))
                            return;
                        auto access = partitionAnalysis
                            ? partitionAnalysis->getUnitStrideDimensionAndOffset(
                                  load.getOperation(), localIV)
                            : std::nullopt;
                        if (!access)
                            return;

                        AffineMap map = load.getAffineMap();
                        SmallVector<AffineExpr> results(map.getResults().begin(),
                                                         map.getResults().end());
                        bool changed = false;
                        auto operands = load.getMapOperands();
                        for (unsigned operandPos = 0; operandPos < operands.size(); ++operandPos) {
                            int64_t operandOffset = 0;
                            if (!partitionAnalysis->getConstantOffsetFromIV(
                                    operands[operandPos], localIV, operandOffset))
                                continue;
                            int64_t mapOffset = 0;
                            unsigned dim = static_cast<unsigned>(access->first);
                            if (partitionAnalysis->getSimpleAffineIVOffset(
                                    results[dim], operandPos, map.getNumDims(), mapOffset)) {
                                if (dynamicBounds) {
                                    rewriter.setInsertionPoint(load);
                                    Value globalOperand = rewriter.create<arith::AddIOp>(
                                        load.getLoc(), operands[operandPos], startVal);
                                    load->setOperand(1 + operandPos, globalOperand);
                                } else {
                                    results[dim] = results[dim] + start;
                                }
                                changed = true;
                                break;
                            }
                        }
                        if (changed && !dynamicBounds)
                            load.setMap(AffineMap::get(map.getNumDims(), map.getNumSymbols(),
                                                       results, load.getContext()));
                        return;
                    }
                    if (auto store = dyn_cast<mlir::affine::AffineStoreOp>(nestedOp)) {
                        if (!isUnslicedMemref(store.getMemRef()))
                            return;
                        auto access = partitionAnalysis
                            ? partitionAnalysis->getUnitStrideDimensionAndOffset(
                                  store.getOperation(), localIV)
                            : std::nullopt;
                        if (!access)
                            return;

                        AffineMap map = store.getAffineMap();
                        SmallVector<AffineExpr> results(map.getResults().begin(),
                                                         map.getResults().end());
                        bool changed = false;
                        auto operands = store.getMapOperands();
                        for (unsigned operandPos = 0; operandPos < operands.size(); ++operandPos) {
                            int64_t operandOffset = 0;
                            if (!partitionAnalysis->getConstantOffsetFromIV(
                                    operands[operandPos], localIV, operandOffset))
                                continue;
                            int64_t mapOffset = 0;
                            unsigned dim = static_cast<unsigned>(access->first);
                            if (partitionAnalysis->getSimpleAffineIVOffset(
                                    results[dim], operandPos, map.getNumDims(), mapOffset)) {
                                if (dynamicBounds) {
                                    rewriter.setInsertionPoint(store);
                                    Value globalOperand = rewriter.create<arith::AddIOp>(
                                        store.getLoc(), operands[operandPos], startVal);
                                    store->setOperand(2 + operandPos, globalOperand);
                                } else {
                                    results[dim] = results[dim] + start;
                                }
                                changed = true;
                                break;
                            }
                        }
                        if (changed && !dynamicBounds)
                            store.setMap(AffineMap::get(map.getNumDims(), map.getNumSymbols(),
                                                        results, store.getContext()));
                        return;
                    }
                    if (auto load = dyn_cast<mlir::memref::LoadOp>(nestedOp)) {
                        if (!isUnslicedMemref(load.getMemRef()))
                            return;
                        auto access = partitionAnalysis
                            ? partitionAnalysis->getUnitStrideDimensionAndOffset(
                                  load.getOperation(), localIV)
                            : std::nullopt;
                        if (!access)
                            return;
                        unsigned dim = static_cast<unsigned>(access->first);
                        Value index = load.getIndices()[dim];
                        rewriter.setInsertionPoint(load);
                        Value offset = dynamicBounds
                            ? startVal
                            : Value(rewriter.create<arith::ConstantIndexOp>(
                                  load.getLoc(), start));
                        Value rebased = rewriter.create<arith::AddIOp>(
                            load.getLoc(), index, offset);
                        load->setOperand(1 + dim, rebased);
                        return;
                    }
                    if (auto store = dyn_cast<mlir::memref::StoreOp>(nestedOp)) {
                        if (!isUnslicedMemref(store.getMemRef()))
                            return;
                        auto access = partitionAnalysis
                            ? partitionAnalysis->getUnitStrideDimensionAndOffset(
                                  store.getOperation(), localIV)
                            : std::nullopt;
                        if (!access)
                            return;
                        unsigned dim = static_cast<unsigned>(access->first);
                        Value index = store.getIndices()[dim];
                        rewriter.setInsertionPoint(store);
                        Value offset = dynamicBounds
                            ? startVal
                            : Value(rewriter.create<arith::ConstantIndexOp>(
                                  store.getLoc(), start));
                        Value rebased = rewriter.create<arith::AddIOp>(
                            store.getLoc(), index, offset);
                        // memref.store operands are value, memref, then indices;
                        // the index list therefore starts at operand two.
                        store->setOperand(2 + dim, rebased);
                    }
                });
            };

            for (auto &innerOp : op.getRegion().front().without_terminator())
            {
                auto cloned = rewriter.clone(innerOp, mapping);

                // -- scf.for --
                if (auto clonedScfFor = mlir::dyn_cast<mlir::scf::ForOp>(cloned))
                {
                    auto ubOp = clonedScfFor.getUpperBound().getDefiningOp();
                    auto lbOp = clonedScfFor.getLowerBound().getDefiningOp();

                    // A runtime trip count is expected on the dynamic path:
                    // the shard's bounds are supplied explicitly below.
                    if (!dynamicBounds &&
                        (!mlir::isa_and_nonnull<mlir::arith::ConstantIndexOp>(ubOp) ||
                         !mlir::isa_and_nonnull<mlir::arith::ConstantIndexOp>(lbOp)))
                    {
                        llvm::errs() << "Error: Not a constant loop bound!\n";
                        return failure();
                    }
                    // Emit fresh independent constants for loop bounds,
                    // otherwise overwriting causes bugs
                    // Eg: operand (a [1, N) loop with step 1 shares the value),
                    // overwriting it in place would silently rewrite the step also
                    // (on the dynamic path the bounds are re-used SSA values).
                    //
                    // These constants must be emitted *before* the cloned loop.
                    // Because clonedScfFor already sits at the insertion point,
                    // newly created constants would otherwise be inserted after it.
                    // While harmless when replacing the loop with scf.parallel,
                    // the partialReduce path retains clonedScfFor and updates its
                    // operands, causing an SSA dominance violation where operands
                    // do not dominate their use (e.g. constant-trip `A[0] += B[i]`).
                    Value lbVal;
                    Value ubVal;
                    {
                        OpBuilder::InsertionGuard boundGuard(rewriter);
                        rewriter.setInsertionPoint(clonedScfFor);
                        lbVal = dynamicBounds
                                    ? dynamicLoopLb
                                    : rewriter.create<arith::ConstantIndexOp>(
                                          clonedScfFor.getLoc(), loopLb);
                        ubVal = dynamicBounds
                                    ? dynamicLoopUb
                                    : rewriter.create<arith::ConstantIndexOp>(
                                          clonedScfFor.getLoc(), loopUb);
                    }

                    // A scatter output (partialReduce) is updated through a
                    // data-dependent index via plain load/modify/store, so
                    // concurrent iterations would lose updates.  The shard is
                    // already the unit of MPI parallelism; keep its own loop
                    // serial rather than emitting a racy scf.parallel.
                    if (hasPartialReduceOutput)
                    {
                        clonedScfFor.getLowerBoundMutable().assign(lbVal);
                        clonedScfFor.getUpperBoundMutable().assign(ubVal);
                        rebaseUnslicedAccesses(clonedScfFor,
                                               clonedScfFor.getInductionVar());
                        continue;
                    }

                    auto parallelOp = rewriter.create<scf::ParallelOp>(
                        clonedScfFor.getLoc(),
                        ValueRange{lbVal},
                        ValueRange{ubVal},
                        ValueRange{clonedScfFor.getStep()},
                        ValueRange{});

                    rewriter.setInsertionPointToStart(parallelOp.getBody());
                    mapping.map(clonedScfFor.getInductionVar(),
                                parallelOp.getInductionVars()[0]);

                    for (auto &bodyOp : clonedScfFor.getBody()->without_terminator())
                        rewriter.clone(bodyOp, mapping);

                    rebaseUnslicedAccesses(parallelOp, parallelOp.getInductionVars()[0]);

                    rewriter.eraseOp(clonedScfFor);
                }
                // ── affine.for ───────────────────────────────────────────────
                else if (auto clonedAffineFor = mlir::dyn_cast<mlir::affine::AffineForOp>(cloned))
                {
                    // Applied the exact same [loopLb, loopUb) logic to the
                    // affine.for lowering path by updating its AffineMaps
                    clonedAffineFor.setLowerBoundMap(
                        AffineMap::getConstantMap(loopLb, rewriter.getContext()));
                    clonedAffineFor.setUpperBoundMap(
                        AffineMap::getConstantMap(loopUb, rewriter.getContext()));

                    // Build an scf.parallel with the same trip count so downstream
                    // lowering can parallelise it the same way as the scf.for path.
                    Value lbVal = rewriter.create<arith::ConstantIndexOp>(
                        clonedAffineFor.getLoc(), loopLb);
                    Value ubVal = rewriter.create<arith::ConstantIndexOp>(
                        clonedAffineFor.getLoc(), loopUb);
                    Value stepVal = rewriter.create<arith::ConstantIndexOp>(
                        clonedAffineFor.getLoc(), clonedAffineFor.getStepAsInt());

                    // Same scatter race as the scf.for path above: keep the
                    // shard's loop serial when an output is updated through a
                    // data-dependent index.
                    if (hasPartialReduceOutput)
                    {
                        rebaseUnslicedAccesses(clonedAffineFor,
                                               clonedAffineFor.getInductionVar());
                        continue;
                    }

                    auto parallelOp = rewriter.create<scf::ParallelOp>(
                        clonedAffineFor.getLoc(),
                        ValueRange{lbVal},
                        ValueRange{ubVal},
                        ValueRange{stepVal},
                        ValueRange{});

                    rewriter.setInsertionPointToStart(parallelOp.getBody());
                    mapping.map(clonedAffineFor.getInductionVar(),
                                parallelOp.getInductionVars()[0]);

                    for (auto &bodyOp : clonedAffineFor.getBody()->without_terminator())
                        rewriter.clone(bodyOp, mapping);

                    rebaseUnslicedAccesses(parallelOp, parallelOp.getInductionVars()[0]);

                    rewriter.eraseOp(clonedAffineFor);
                }
            }

            rewriter.setInsertionPointToEnd(&taskOp.getRegion().front());
            rewriter.create<dhir::YieldOp>(rewriter.getUnknownLoc());

            subViewIns.clear();
            subViewOuts.clear();
        }

        rewriter.eraseOp(op);
        return success();
    }
};

namespace mlir
{
    namespace dhir
    {
#define GEN_PASS_DEF_LOWERREPLICATEOPPASS
#include "dialect/Passes.h.inc"
        struct LowerReplicateOpPass
            : public mlir::dhir::impl::LowerReplicateOpPassBase<LowerReplicateOpPass>
        {
            using LowerReplicateOpPassBase::LowerReplicateOpPassBase;

            void runOnOperation() override
            {
                mlir::MLIRContext *context = &getContext();
                auto *module = getOperation();

                std::map<mlir::Operation *, std::set<int64_t>> scheduleReplicateIds;
                bool invalidReplicateId = false;
                module->walk([&](mlir::dhir::ReplicateOp replicate) {
                    auto schedule = replicate->getParentOfType<mlir::dhir::ScheduleOp>();
                    auto idAttr = replicate->getAttrOfType<mlir::IntegerAttr>("replicateID");
                    if (!schedule || !idAttr || idAttr.getInt() < 0)
                    {
                        replicate.emitError("must have a non-negative replicateID and be nested in a ScheduleOp");
                        invalidReplicateId = true;
                        return;
                    }

                    auto &ids = scheduleReplicateIds[schedule.getOperation()];
                    if (!ids.insert(idAttr.getInt()).second)
                    {
                        replicate.emitError("duplicate replicateID in one schedule");
                        invalidReplicateId = true;
                    }
                });
                if (invalidReplicateId)
                {
                    signalPassFailure();
                    return;
                }

                ConversionTarget targetReplicateOp(getContext());

                targetReplicateOp.addLegalDialect<mlir::arith::ArithDialect>();
                targetReplicateOp.addLegalDialect<mlir::scf::SCFDialect>();
                targetReplicateOp.addLegalDialect<mlir::affine::AffineDialect>();
                // Cloning a replicate body copies whatever the kernel actually
                // uses.  Marking only arith/scf/affine illegalized ordinary
                // kernel ops such as math.sqrt, so a legal body could still be
                // reported as "failed to legalize".  These dialects are
                // pass-through here: nothing in this pass rewrites them.
                targetReplicateOp.addLegalDialect<mlir::math::MathDialect>();
                targetReplicateOp.addLegalDialect<mlir::index::IndexDialect>();
                targetReplicateOp.addLegalDialect<mlir::LLVM::LLVMDialect>();
                targetReplicateOp.addLegalDialect<mlir::gpu::GPUDialect>();
                targetReplicateOp.addLegalOp<mlir::dhir::TaskOp>();
                targetReplicateOp.addIllegalOp<dhir::ReplicateOp>();
                targetReplicateOp.addLegalOp<mlir::dhir::YieldOp>();
                targetReplicateOp.addLegalDialect<mlir::memref::MemRefDialect>();

                RewritePatternSet dhirpatterns(context);
                dhirpatterns.add<ConvertReplicateOp>(context);

                if (failed(applyPartialConversion(module, targetReplicateOp, std::move(dhirpatterns))))
                    signalPassFailure();
            }
        };
    }
}

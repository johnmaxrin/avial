#ifndef ARRAYPARTITION_ANALYSIS_H
#define ARRAYPARTITION_ANALYSIS_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/BuiltinOps.h"

namespace mlir
{
    namespace avial
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
        };

        class ArrayPartitioningAnalysis
        {
        public:
            ArrayPartitioningAnalysis(mlir::Operation *rootOp) : rootOp(rootOp) {}

            ArrayPartitioningInfo analyzeArray(Value memref)
            {
                ArrayPartitioningInfo info;
                info.memref = memref;
                info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                info.partitionDimension = -1;

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
                    info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                    return info;
                }

                int rank = memrefType.getRank();
                
                // ===== Handle 1D arrays (single for loop case) =====
                if (rank == 1)
                {
                    llvm::errs() << "=== 1D Array Analysis ===\n";
                    llvm::errs() << "Is input: " << isInput << ", Is output: " << isOutput << "\n";
                    
                    // Find the loop IV that actually accesses the array
                    Value loopIV = findLoopIVForArrayAccess(loads, stores);
                    
                    if (!loopIV)
                    {
                        llvm::errs() << "→ NO_PARTITION (no loop IV found)\n";
                        info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                        return info;
                    }
                    
                    llvm::errs() << "Found loop IV for array access\n";
                    
                    // Check if the array is accessed using the loop IV
                    bool usesLoopIV = false;
                    
                    // Check loads
                    for (Operation *loadOp : loads)
                    {
                        int dim = getDimensionForIV(loadOp, loopIV);
                        llvm::errs() << "  Load uses dim: " << dim << "\n";
                        if (dim == 0)
                        {
                            usesLoopIV = true;
                            break;
                        }
                    }
                    
                    // Check stores
                    if (!usesLoopIV)
                    {
                        for (Operation *storeOp : stores)
                        {
                            int dim = getDimensionForIV(storeOp, loopIV);
                            llvm::errs() << "  Store uses dim: " << dim << "\n";
                            if (dim == 0)
                            {
                                usesLoopIV = true;
                                break;
                            }
                        }
                    }
                    
                    if (usesLoopIV)
                    {
                        // Partition along dimension 0 (the only dimension)
                        info.strategy = ArrayPartitioningInfo::ROW_PARTITION;
                        info.partitionDimension = 0;
                        llvm::errs() << "→ ROW_PARTITION (1D array, loop-indexed)\n";
                    }
                    else
                    {
                        // Array doesn't use loop IV - replicate
                        info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                        llvm::errs() << "→ NO_PARTITION (1D array, not loop-indexed)\n";
                    }
                    
                    return info;
                }
                
                // ===== Handle 2D arrays (nested for loop case) =====
                if (rank != 2)
                {
                    llvm::errs() << "Warning: Unsupported array rank: " << rank << "\n";
                    info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                    return info;
                }

                // Find the outermost loop (affine or scf)
                Value outerIV = findOutermostLoopIV(loads, stores);

                if (!outerIV)
                {
                    info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                    return info;
                }

                // Check which dimension uses the outer IV
                int partitionDim = -1;

                if (isOutput && !stores.empty())
                {
                    partitionDim = getDimensionForIV(stores[0], outerIV);
                }
                else if (isInput && !loads.empty())
                {
                    partitionDim = getDimensionForIV(loads[0], outerIV);
                }

                if (partitionDim != -1)
                {
                    // Check all other accesses to ensure they use the same pattern
                    auto checkConsistency = [&](const llvm::SmallVector<Operation *> &ops)
                    {
                        for (Operation *op : ops)
                        {
                            int dim = getDimensionForIV(op, outerIV);
                            if (dim != partitionDim)
                            {
                                return false; // Inconsistent!
                            }
                        }
                        return true;
                    };

                    if (!checkConsistency(loads) || !checkConsistency(stores))
                    {
                        partitionDim = -1; // Fall back to NO_PARTITION
                        llvm::errs() << "→ Inconsistent access pattern detected\n";
                    }
                }

                llvm::errs() << "=== 2D Array Analysis ===\n";
                llvm::errs() << "Is input: " << isInput << ", Is output: " << isOutput << "\n";
                llvm::errs() << "Partition dimension: " << partitionDim << "\n";

                if (partitionDim == 0)
                {
                    info.strategy = ArrayPartitioningInfo::ROW_PARTITION;
                    info.partitionDimension = 0;
                    llvm::errs() << "→ ROW_PARTITION\n";
                }
                else if (partitionDim == 1)
                {
                    if (isInput)
                    {
                        info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                        llvm::errs() << "→ REPLICATE (column-accessed input)\n";
                    }
                    else
                    {
                        info.strategy = ArrayPartitioningInfo::COL_PARTITION;
                        info.partitionDimension = 1;
                        llvm::errs() << "→ COL_PARTITION\n";
                    }
                }
                else
                {
                    info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                    llvm::errs() << "→ NO_PARTITION\n";
                }

                return info;
            }

        private:
            mlir::Operation *rootOp;

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
                for (int dim = 0; dim < indices.size(); ++dim)
                {
                    Value idx = indices[dim];

                    // Direct match
                    if (idx == targetIV)
                        return dim;

                    // Check if it's derived from the IV (through arith ops)
                    if (isDerivedFromValue(idx, targetIV))
                        return dim;
                }

                return -1;
            }

            // Check if a value is derived from another (simple version)
            bool isDerivedFromValue(Value derived, Value source)
            {
                if (derived == source)
                    return true;

                // Check if it's an arithmetic operation using the source
                if (auto defOp = derived.getDefiningOp())
                {
                    for (Value operand : defOp->getOperands())
                    {
                        if (operand == source)
                            return true;
                        // Recursive check (limit depth to avoid infinite loops)
                        if (operand.getDefiningOp() &&
                            isDerivedFromValue(operand, source))
                            return true;
                    }
                }

                return false;
            }
        };

        ArrayPartitioningInfo analyzeArrayForPartitioning(mlir::Operation *op, Value memref)
        {
            ArrayPartitioningAnalysis analysis(op);
            return analysis.analyzeArray(memref);
        }

    } // namespace avial
} // namespace mlir

#endif
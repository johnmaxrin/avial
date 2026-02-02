#include "mlir/Dialect/Affine/IR/AffineOps.h"
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
                NO_PARTITION,    // Replicate
                ROW_PARTITION,   // Split by rows
                COL_PARTITION,   // Split by columns
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

                // Collect accesses
                llvm::SmallVector<mlir::affine::AffineLoadOp> loads;
                llvm::SmallVector<mlir::affine::AffineStoreOp> stores;

                rootOp->walk([&](mlir::affine::AffineLoadOp loadOp) {
                    if (loadOp.getMemRef() == memref)
                        loads.push_back(loadOp);
                });

                rootOp->walk([&](mlir::affine::AffineStoreOp storeOp) {
                    if (storeOp.getMemRef() == memref)
                        stores.push_back(storeOp);
                });

                bool isInput = stores.empty();
                bool isOutput = !stores.empty();

                auto memrefType = dyn_cast<mlir::MemRefType>(memref.getType());
                if (!memrefType || memrefType.getRank() != 2) {
                    info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                    return info;
                }

                // Find which dimension uses the outermost loop IV
                mlir::affine::AffineForOp outermostLoop = nullptr;
                
                if (!loads.empty()) {
                    Operation *op = loads[0].getOperation();
                    while (auto parent = op->getParentOfType<mlir::affine::AffineForOp>()) {
                        outermostLoop = parent;
                        op = parent.getOperation();
                    }
                } else if (!stores.empty()) {
                    Operation *op = stores[0].getOperation();
                    while (auto parent = op->getParentOfType<mlir::affine::AffineForOp>()) {
                        outermostLoop = parent;
                        op = parent.getOperation();
                    }
                }

                if (!outermostLoop) {
                    info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                    return info;
                }

                Value outerIV = outermostLoop.getInductionVar();

                // Check which dimension uses the outer IV
                auto checkIndices = [&](mlir::Operation::operand_range indices) -> int {
                    int dim = 0;
                    for (Value idx : indices) {
                        if (idx == outerIV)
                            return dim;
                        dim++;
                    }
                    return -1;
                };

                int partitionDim = -1;

                if (isOutput && !stores.empty()) {
                    partitionDim = checkIndices(stores[0].getMapOperands());
                } else if (isInput && !loads.empty()) {
                    partitionDim = checkIndices(loads[0].getMapOperands());
                }

                llvm::errs() << "=== Simple Analysis ===\n";
                llvm::errs() << "Is input: " << isInput << ", Is output: " << isOutput << "\n";
                llvm::errs() << "Partition dimension: " << partitionDim << "\n";

                if (partitionDim == 0) {
                    info.strategy = ArrayPartitioningInfo::ROW_PARTITION;
                    info.partitionDimension = 0;
                    llvm::errs() << "→ ROW_PARTITION\n";
                } else if (partitionDim == 1) {
                    // Column access - replicate for inputs
                    if (isInput) {
                        info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                        llvm::errs() << "→ REPLICATE (column-accessed input)\n";
                    } else {
                        info.strategy = ArrayPartitioningInfo::COL_PARTITION;
                        info.partitionDimension = 1;
                        llvm::errs() << "→ COL_PARTITION\n";
                    }
                } else {
                    info.strategy = ArrayPartitioningInfo::NO_PARTITION;
                    llvm::errs() << "→ NO_PARTITION (no clear dimension)\n";
                }

                return info;
            }

        private:
            mlir::Operation *rootOp;
        };

        ArrayPartitioningInfo analyzeArrayForPartitioning(mlir::Operation *op, Value memref)
        {
            ArrayPartitioningAnalysis analysis(op);
            return analysis.analyzeArray(memref);
        }

    } // namespace avial
} // namespace mlir
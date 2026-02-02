#include "mlir/Pass/PassManager.h"
#include "mlir/IR/PatternMatch.h"

#include "includes/avialDialect.h"
#include "includes/avialTypes.h"

#include "mlir/Transforms/DialectConversion.h"

#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/Passes.h"

#include "llvm/Support/Casting.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"

#include "includes/avialDialect.h"
#include "includes/avialOps.h"
#include "includes/avialTypes.h"
#include "includes/utils.h"

#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/IR/Builders.h"

#include "mlir/Conversion/Passes.h"

#include "analysis/polyhedralAnalysis.h"

#include <string>

using namespace mlir;
using namespace avial;

namespace mlir
{
    namespace avial
    {

#define GEN_PASS_DEF_CONVERTAFFINETOAVIALPASS

#include "dialect/Passes.h.inc"

        struct ConvertAffineToAvialPass : public mlir::avial::impl::ConvertAffineToAvialPassBase<ConvertAffineToAvialPass>
        {
            using ConvertAffineToAvialPassBase::ConvertAffineToAvialPassBase;
            void runOnOperation() override
            {
                mlir::MLIRContext *context = &getContext();
                auto *module = getOperation();
                mlir::OpBuilder builder(context);

                llvm::SmallVector<mlir::Operation *, 4> toReplicateVector;
                llvm::SmallVector<mlir::Operation *, 4> toTaskVector;
                module->walk<mlir::WalkOrder::PreOrder>([&](mlir::Operation *op)
                                                        {
    if (mlir::isa<func::FuncOp>(op))
    {
        auto funcOp = mlir::dyn_cast<func::FuncOp>(op);
        Block &blck = funcOp.getBody().front();

        for (auto &op : blck.getOperations())
        {
            if (mlir::isa<affine::AffineForOp>(op))
            {
                mlir::affine::AffineForOp forOp = mlir::dyn_cast<mlir::affine::AffineForOp>(op);
                
                if (checkLoopDependence(forOp)) // Dependence exists
                {
                    llvm::outs() << "Dependence is there!!\n";
                    toTaskVector.push_back(forOp);
                }
                else
                {
                    // No Dependence - can replicate
                    toReplicateVector.push_back(forOp);
                }
                
                // FIXED: Find all memrefs that are written to in this loop
                llvm::SmallPtrSet<Value, 4> writtenMemrefs;
                
                forOp.walk([&](mlir::affine::AffineLoadOp storeOp) {
                    writtenMemrefs.insert(storeOp.getMemRef());
                });
                
                // Analyze each output memref
                for (Value memref : writtenMemrefs) {
                    llvm::errs() << "=== Analyzing memref ===\n";
                    
                    // Create analysis with the forOp as the root
                    ArrayPartitioningAnalysis analysis(forOp);
                    auto partitionInfo = analysis.analyzeArray(memref);
                    
                    // Print memref type for debugging
                    if (auto memrefType = dyn_cast<mlir::MemRefType>(memref.getType())) {
                        llvm::errs() << "Memref type: ";
                        memrefType.print(llvm::errs());
                        llvm::errs() << "\n";
                    }
                    
                    switch (partitionInfo.strategy)
                    {
                    case ArrayPartitioningInfo::NO_PARTITION:
                        llvm::errs() << "Replicating array - no partitioning needed\n";
                        break;

                    case ArrayPartitioningInfo::ROW_PARTITION:
                        llvm::errs() << "Partitioning by rows (dimension 0)\n";
                        break;

                    case ArrayPartitioningInfo::COL_PARTITION:
                        llvm::errs() << "Partitioning by columns (dimension 1)\n";
                        break;

                    
                    }

                    
                }
            }
        }
    } });

                int repId = 1; // For uniquely identifying each replicateOp.

                for (auto op : toReplicateVector)
                {

                    affine::AffineForOp forOp = mlir::dyn_cast<affine::AffineForOp>(op);
                    builder.setInsertionPoint(forOp);
                    auto replicateOp = builder.create<mlir::avial::ReplicateOp>(forOp.getLoc());
                    replicateOp->setAttr("replicateID", builder.getI64IntegerAttr(repId));

                    mlir::Region &replicateRegion = replicateOp.getBodyRegion();
                    mlir::Block *newBlock = builder.createBlock(&replicateRegion);

                    forOp->moveBefore(newBlock, newBlock->end());
                    builder.create<mlir::avial::YieldOp>(builder.getUnknownLoc());
                    ++repId;
                }
            }
        };
    }

}
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


#include "analysis/polyHedralAnalysis.h"


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

                llvm::SmallVector<mlir::Operation *, 4>toReplicateVector;
                llvm::SmallVector<mlir::Operation *, 4>toTaskVector;
                module->walk<mlir::WalkOrder::PreOrder>([&](mlir::Operation *op)
                {


                    if(mlir::isa<func::FuncOp>(op))
                    {

                        // Do the analysis on ForLoop and if there isn't any dependence, a particular nest, Wrap it with avial.replicate 
                        auto funcOp = mlir::dyn_cast<func::FuncOp>(op);

                        Block &blck = funcOp.getBody().front();

                        for(auto &op : blck.getOperations())
                        {

                            if(mlir::isa<affine::AffineForOp>(op))
                            {
                                mlir::affine::AffineForOp forOp = mlir::dyn_cast<mlir::affine::AffineForOp>(op);
                                if(checkLoopDependence(forOp)) // Dependecne free in the outer loop. 
                                {
                                    // Wrap the for-loop with Tas
                        
                                    llvm::outs() << "Dependece is there\n";
                                    toTaskVector.push_back(forOp);

                                }

                                else
                                {
                                    // No Dependence
                                    // Wrap the forloop with replicate.
                                    toReplicateVector.push_back(forOp);
                                    llvm::outs() << "Dependence free\n";
                                    


                                }
                            }
                        }

                        
                    }
                    
                });

                for(auto op : toReplicateVector)
                {

                    affine::AffineForOp forOp = mlir::dyn_cast<affine::AffineForOp>(op);
                    builder.setInsertionPoint(forOp);
                    auto replicateOp = builder.create<mlir::avial::ReplicateOp>(forOp.getLoc());
                    mlir::Region &replicateRegion = replicateOp.getBodyRegion();
                    mlir::Block *newBlock = builder.createBlock(&replicateRegion);

                    forOp->moveBefore(newBlock, newBlock->end());
                    builder.create<mlir::avial::YieldOp>(builder.getUnknownLoc());                 
                    replicateOp.dump();

                }

                

            }
        };
    }

}
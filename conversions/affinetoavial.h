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
            
            // Helper function to check if a loop is independent (considering only its own iterations)
            // This checks the loop in isolation, not in the context of parent loops
            bool isLoopIndependent(mlir::affine::AffineForOp loop)
            {
                llvm::SmallVector<mlir::Operation *, 4> memOpVector;
                
                // Collect only memory operations directly within this loop
                // Do NOT walk into nested loops - we only care about this loop's own dependencies
                loop.getBody()->walk([&](mlir::Operation *op) {
                    if (mlir::isa<mlir::affine::AffineLoadOp>(op) || 
                        mlir::isa<mlir::affine::AffineStoreOp>(op)) {
                        memOpVector.push_back(op);
                    }
                });
                
                // Check for loop-carried dependencies at this loop's level only
                llvm::SmallVector<mlir::Operation *, 4> forLoopOpVector;
                forLoopOpVector.push_back(loop.getOperation());
                
                affine::FlatAffineValueConstraints constraints;
                affine::getIndexSet(forLoopOpVector, &constraints);
                
                llvm::errs() << "---- Checking Inner Loop Independence (Isolated) ----\n";
                
                for (int i = 0; i < memOpVector.size(); ++i)
                {
                    for (int j = 0; j < memOpVector.size(); ++j)
                    {
                        if (i == j) continue;
                        
                        mlir::affine::MemRefAccess src(memOpVector[i]);
                        mlir::affine::MemRefAccess dst(memOpVector[j]);
                        SmallVector<mlir::affine::DependenceComponent, 2> comps;
                        
                        mlir::affine::DependenceResult res = 
                            mlir::affine::checkMemrefAccessDependence(src, dst, 1, &constraints, &comps);
                        
                        if (res.value == mlir::affine::DependenceResult::HasDependence)
                        {
                            if (comps.size() > 0)
                            {
                                auto &comp = comps[0];
                                if (!(comp.lb == 0 && comp.ub == 0))
                                {
                                    llvm::errs() << "Loop carries dependence (isolated check)\n";
                                    llvm::errs() << "---- End Checking Inner Loop Independence ----\n";
                                    return false; // Has loop-carried dependence
                                }
                            }
                        }
                        else if (res.value == mlir::affine::DependenceResult::Failure)
                        {
                            llvm::errs() << "Dependence check failed - assuming dependent\n";
                            llvm::errs() << "---- End Checking Inner Loop Independence ----\n";
                            return false; // Conservative: assume dependent
                        }
                    }
                }
                
                llvm::errs() << "No loop-carried dependence found - loop is independent!\n";
                llvm::errs() << "---- End Checking Inner Loop Independence ----\n";
                return true; // No loop-carried dependence
            }
            
            // Helper function to wrap independent loops with ReplicateOp
            void wrapIndependentLoopsInFixedPoint(mlir::affine::AffineForOp outerLoop, 
                                                   mlir::OpBuilder &builder, 
                                                   int &repId)
            {
                llvm::SmallVector<mlir::affine::AffineForOp> allInnerLoops;
                
                // Collect all direct child loops of the outer loop
                // We need to check them at the same nesting level
                for (auto &op : outerLoop.getBody()->getOperations())
                {
                    if (auto innerLoop = mlir::dyn_cast<mlir::affine::AffineForOp>(op))
                    {
                        allInnerLoops.push_back(innerLoop);
                    }
                }
                
                // Now check each inner loop for independence (in isolation)
                llvm::SmallVector<mlir::affine::AffineForOp> independentLoops;
                for (auto innerLoop : allInnerLoops)
                {
                    if (isLoopIndependent(innerLoop))
                    {
                        independentLoops.push_back(innerLoop);
                    }
                }
                
                llvm::errs() << "Found " << independentLoops.size() 
                             << " independent inner loops to wrap\n";
                
                // Wrap each independent loop with ReplicateOp
                for (auto forOp : independentLoops)
                {
                    auto insouts = InsOutsAnalysis::getInsandOut(forOp);
                    
                    builder.setInsertionPoint(forOp);
                    auto replicateOp = builder.create<mlir::avial::ReplicateOp>(forOp.getLoc(), insouts[0], insouts[1]);
                    replicateOp->setAttr("replicateID", builder.getI64IntegerAttr(repId));
                    
                    mlir::Region &replicateRegion = replicateOp.getBodyRegion();
                    mlir::Block *newBlock = builder.createBlock(&replicateRegion);
                    
                    forOp->moveBefore(newBlock, newBlock->end());
                    builder.setInsertionPointToEnd(newBlock);
                    builder.create<mlir::avial::YieldOp>(builder.getUnknownLoc());
                    
                    llvm::errs() << "Wrapped loop with ReplicateOp (replicateID=" << repId << ")\n";
                    ++repId;
                }
            }
            
            void runOnOperation() override
            {
                mlir::MLIRContext *context = &getContext();
                auto *module = getOperation();
                mlir::OpBuilder builder(context);

                llvm::SmallVector<mlir::Operation *, 4> toReplicateVector;
                llvm::SmallVector<mlir::Operation *, 4> toFixedPointVector;
                
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
                                
                                // Check dependence at depth 1 (outer loop)
                                int outerDep = checkLoopDependence(forOp, 1);
                                
                                if (outerDep == 1) // Outer loop has dependence
                                {
                                    // Collect all inner loops
                                    llvm::SmallVector<mlir::affine::AffineForOp> innerLoops;
                                    forOp.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineForOp innerOp)
                                    {
                                        if (innerOp != forOp) // Skip the outer loop itself
                                        {
                                            innerLoops.push_back(innerOp);
                                        }
                                    });

                                    // Check if any inner loop is parallelizable
                                    bool hasParallelizableInner = false;
                                    for (auto innerLoop : innerLoops)
                                    {
                                        if (isLoopIndependent(innerLoop))
                                        {
                                            hasParallelizableInner = true;
                                            break;
                                        }
                                    }
                                    
                                    // Wrap with FixedPointOp if there are parallelizable inner loops
                                    if(hasParallelizableInner)
                                        toFixedPointVector.push_back(forOp);
                                }
                                else if (outerDep == 0) // No dependence in outer loop
                                {
                                    // Fully parallelizable - wrap with ReplicateOp
                                    toReplicateVector.push_back(forOp);
                                }
                                else // outerDep == 2, dependence check failed
                                {
                                    llvm::errs() << "Dependence Analysis Failed!\n";
                                    exit(0);    
                                }
                            }
                        }
                    }
                });

                // Create ReplicateOp for fully parallelizable loops
                int repId = 1;
                for (auto op : toReplicateVector)
                {
                    affine::AffineForOp forOp = mlir::dyn_cast<affine::AffineForOp>(op);
                    auto insouts = InsOutsAnalysis::getInsandOut(forOp);

                    builder.setInsertionPoint(forOp);
                    auto replicateOp = builder.create<mlir::avial::ReplicateOp>(forOp.getLoc(), insouts[0], insouts[1]);
                    replicateOp->setAttr("replicateID", builder.getI64IntegerAttr(repId));

                    mlir::Region &replicateRegion = replicateOp.getBodyRegion();
                    mlir::Block *newBlock = builder.createBlock(&replicateRegion);

                    forOp->moveBefore(newBlock, newBlock->end());
                    builder.setInsertionPointToEnd(newBlock);
                    builder.create<mlir::avial::YieldOp>(builder.getUnknownLoc());
                    ++repId;
                }

                // Create FixedPointOp for loops with dependencies
                int taskId = 1;
                for (auto op : toFixedPointVector)
                {
                    affine::AffineForOp forOp = mlir::dyn_cast<affine::AffineForOp>(op);
                    
                    // FIRST: Wrap independent inner loops with ReplicateOp
                    // This must be done BEFORE creating FixedPointOp
                    wrapIndependentLoopsInFixedPoint(forOp, builder, repId);
                    
                    // NOW: Create the FixedPointOp and move the outer loop into it
                    auto insouts = InsOutsAnalysis::getInsandOut(forOp);

                    builder.setInsertionPoint(forOp);
                    auto fixedPointOp = builder.create<mlir::avial::FixedPointOp>(forOp.getLoc(), insouts[0], insouts[1]);
                    fixedPointOp->setAttr("fixedPointID", builder.getI64IntegerAttr(taskId));

                    mlir::Region &fixedPointRegion = fixedPointOp.getBodyRegion();
                    mlir::Block *newBlock = builder.createBlock(&fixedPointRegion);

                    forOp->moveBefore(newBlock, newBlock->end());
                    builder.setInsertionPointToEnd(newBlock);
                    builder.create<mlir::avial::YieldOp>(builder.getUnknownLoc());
                    
                    ++taskId;
                }
            }
        };
    }
}
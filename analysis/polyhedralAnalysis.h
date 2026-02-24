#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"

#include "mlir/IR/Builders.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/BuiltinOps.h"

#include "mlir/Dialect/Affine/Analysis/AffineStructures.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Dialect/Affine/Analysis/AffineAnalysis.h"
#include "mlir/IR/AffineMap.h"
#include "mlir/Analysis/Presburger/PresburgerSpace.h"

namespace mlir
{
    namespace avial
    {
        int checkLoopDependence(mlir::affine::AffineForOp op, int depth)
        {
            // Check for dependence in this loop nest.
            llvm::SmallVector<mlir::Operation *, 4> forLoopOpVector;
            llvm::SmallVector<mlir::Operation *, 4> memOpVector;

            op.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineForOp op)
                                               { forLoopOpVector.push_back(op); });

            op.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineLoadOp op)
                                               {
                memOpVector.push_back(op);
            });

            op.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineStoreOp op)
                                               {
                memOpVector.push_back(op);
            });

            affine::FlatAffineValueConstraints constraints;
            affine::getIndexSet(forLoopOpVector, &constraints);
                                            

            llvm::errs() << "---- Checking Loop Dependence ----\n";
            for (int i = 0; i < memOpVector.size(); ++i)
            {
                for (int j = 0; j < memOpVector.size(); ++j)
                {
                    if (i == j)
                        continue;
                    mlir::affine::MemRefAccess src(memOpVector[i]); // src
                    mlir::affine::MemRefAccess dst(memOpVector[j]); // src

                    SmallVector<mlir::affine::DependenceComponent, 2> comps;
                    mlir::affine::DependenceResult res = mlir::affine::checkMemrefAccessDependence(src, dst, depth, &constraints, &comps, true);

                    for(auto comp: comps)
                        llvm::errs() << "(" <<comp.lb<<", "<<comp.ub<<")\n";


                    if (res.value == mlir::affine::DependenceResult::HasDependence)
                    {

                        if (comps.size() < depth)
                            continue;

                        bool prefixZero = true;

                        for (unsigned k = 0; k < depth - 1; ++k)
                        {
                            if (!(comps[k].lb == 0 && comps[k].ub == 0))
                            {
                                prefixZero = false;
                                break;
                            }
                        }

                        if (!prefixZero)
                            continue;

                        auto &comp = comps[depth - 1];

                        if (!(comp.lb == 0 && comp.ub == 0))
                        {
                            llvm::errs() << "Loop carries dependence @" << depth << "\n";
                            
                            llvm::errs() << "---- End Checking Loop Dependence ----\n";
                            return 1;
                        }
                    }
                    else if (res.value == mlir::affine::DependenceResult::Failure)
                    {
                        llvm::errs() << "Dependence check failed\n";
                        
                        llvm::errs() << "---- End Checking Loop Dependence ----\n";
                        return 2;
                    }
                }
            }
            
            llvm::errs() << "---- End Checking Loop Dependence ----\n";
            return 0;
        }
    }
}

// Create an analysis to figure out the if we need to split an array of not to be sent to different nodes.
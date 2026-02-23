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
<<<<<<< HEAD
        int checkLoopDependence(mlir::affine::AffineForOp op, int depth)
=======
        int checkLoopDependence(mlir::affine::AffineForOp op)
>>>>>>> 0920839270064ffad0692e53a08c3dab224c8f34
        {
            // Check for dependence in this loop nest.
            llvm::SmallVector<mlir::Operation *, 4> forLoopOpVector;
            llvm::SmallVector<mlir::Operation *, 4> memOpVector;

            op.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineForOp op)
                                               { forLoopOpVector.push_back(op); });

            op.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineLoadOp op)
                                               {
                memOpVector.push_back(op);
<<<<<<< HEAD
            });
=======
                loadVector.insert(op.getMemRef()); });
>>>>>>> 0920839270064ffad0692e53a08c3dab224c8f34

            op.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineStoreOp op)
                                               {
                memOpVector.push_back(op);
<<<<<<< HEAD
            });

            affine::FlatAffineValueConstraints constraints;
=======
                storeVector.insert(op.getMemRef()); });

            llvm::SmallVector<Operation *> filteredMemOps;
            for (Operation *op : memOpVector)
            {
                if (auto load = llvm::dyn_cast<mlir::affine::AffineLoadOp>(op))
                {
                    if (storeVector.contains(load.getMemRef()))
                        filteredMemOps.push_back(op);
                }
                else if (auto store = llvm::dyn_cast<mlir::affine::AffineStoreOp>(op))
                {
                    if (loadVector.contains(store.getMemRef()))
                        filteredMemOps.push_back(op);
                }
            }

            affine::FlatAffineValueConstraints constraints;

>>>>>>> 0920839270064ffad0692e53a08c3dab224c8f34
            affine::getIndexSet(forLoopOpVector, &constraints);
                                            

<<<<<<< HEAD
            llvm::errs() << "---- Checking Loop Dependence ----\n";
=======
            llvm::errs() << "Constraints\n";
            constraints.print(llvm::errs());

            llvm::errs() << "Constraint Space\n";
            constraints.printSpace(llvm::errs());

>>>>>>> 0920839270064ffad0692e53a08c3dab224c8f34
            for (int i = 0; i < memOpVector.size(); ++i)
            {
                for (int j = 0; j < memOpVector.size(); ++j)
                {
                    if (i == j)
                        continue;
                    mlir::affine::MemRefAccess src(memOpVector[i]); // src
                    mlir::affine::MemRefAccess dst(memOpVector[j]); // src

<<<<<<< HEAD
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
=======
                    mlir::presburger::PresburgerSpace space = mlir::presburger::PresburgerSpace::getRelationSpace();
                    mlir::presburger::IntegerRelation srcRel(space), dstRel(space);

                    if (failed(src.getAccessRelation(srcRel)))
                        return mlir::affine::DependenceResult::Failure;

                    if (failed(dst.getAccessRelation(dstRel)))
                        return mlir::affine::DependenceResult::Failure;

                    affine::FlatAffineValueConstraints srcDomain(srcRel.getDomainSet());
                    affine::FlatAffineValueConstraints dstDomain(dstRel.getDomainSet());

                   

                


                    mlir::affine::DependenceResult res = mlir::affine::checkMemrefAccessDependence(src, dst, 1, &constraints, nullptr);

                    if (res.value == mlir::affine::DependenceResult::HasDependence)
                        return 1;
                    else if (res.value == mlir::affine::DependenceResult::Failure)
                        return 2;
                }
            }
>>>>>>> 0920839270064ffad0692e53a08c3dab224c8f34
            return 0;
        }
    }
}

// Create an analysis to figure out the if we need to split an array of not to be sent to different nodes.
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
        int checkLoopDependence(mlir::affine::AffineForOp op)
        {
            // Check for dependence in this loop nest.
            llvm::SmallVector<mlir::Operation *, 4> forLoopOpVector;
            llvm::SmallDenseSet<mlir::Value> loadVector;
            llvm::SmallDenseSet<mlir::Value> storeVector;
            llvm::SmallVector<mlir::Operation *, 4> memOpVector;

            op.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineForOp op)
                                               { forLoopOpVector.push_back(op); });

            op.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineLoadOp op)
                                               {
                memOpVector.push_back(op);
                loadVector.insert(op.getMemRef()); });

            op.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineStoreOp op)
                                               {
                memOpVector.push_back(op);
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

            affine::getIndexSet(forLoopOpVector, &constraints);

            llvm::errs() << "Constraints\n";
            constraints.print(llvm::errs());

            llvm::errs() << "Constraint Space\n";
            constraints.printSpace(llvm::errs());

            for (int i = 0; i < memOpVector.size(); ++i)
            {
                for (int j = 0; j < memOpVector.size(); ++j)
                {
                    if (i == j)
                        continue;
                    mlir::affine::MemRefAccess src(memOpVector[i]); // src
                    mlir::affine::MemRefAccess dst(memOpVector[j]); // src

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
            return 0;
        }
    }
}

// Create an analysis to figure out the if we need to split an array of not to be sent to different nodes.
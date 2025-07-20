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
            llvm::SmallVector<mlir::Operation *, 4> memOpVector;


            op.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineForOp op){
                forLoopOpVector.push_back(op);
            });

           



            op.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineLoadOp op){
                memOpVector.push_back(op);
            });

            op.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineStoreOp op){
                memOpVector.push_back(op);
            });

            affine::FlatAffineValueConstraints constraints; 
            affine::FlatAffineValueConstraints memconstraints; 

            affine::getIndexSet(forLoopOpVector, &constraints);
            constraints.dump();

            mlir::affine::MemRefAccess src(memOpVector[0]); // src
            mlir::affine::MemRefAccess dst(memOpVector[0]); // src


            mlir::presburger::PresburgerSpace space = mlir::presburger::PresburgerSpace::getRelationSpace();
            mlir::presburger::IntegerRelation srcRel(space), dstRel(space);
            
            if (failed(src.getAccessRelation(srcRel)))
                return mlir::affine::DependenceResult::Failure;
            
                if (failed(dst.getAccessRelation(dstRel)))
                return mlir::affine::DependenceResult::Failure;

            affine::FlatAffineValueConstraints srcDomain(srcRel.getDomainSet());
            affine::FlatAffineValueConstraints dstDomain(dstRel.getDomainSet());


            srcDomain.dump();
            dstDomain.dump();

  
            mlir::affine::DependenceResult res =  mlir::affine::checkMemrefAccessDependence(src, dst,1, &constraints, nullptr);
    
            if(res.value == mlir::affine::DependenceResult::HasDependence)
                return 1;
            else if(res.value == mlir::affine::DependenceResult::Failure)
                return 2;
            else
                return 0;

            return 2;
       } 
    }
}
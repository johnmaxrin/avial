#pragma once

#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/AffineExpr.h"
#include "mlir/IR/AffineMap.h"

namespace mlir
{
    namespace dhir
    {

        inline int64_t getOperandSliceDim(linalg::LinalgOp op, OpOperand &opd, int64_t dp)
        {
            AffineMap m = op.getMatchingIndexingMap(&opd);
            for (auto [i, r] : llvm::enumerate(m.getResults()))
                if (auto d = mlir::dyn_cast<AffineDimExpr>(r))
                    if (d.getPosition() == static_cast<unsigned>(dp))
                        return static_cast<int64_t>(i);
            return -1;
        }

        // Returns the loop dim to distribute, or -1 for a single unpartitioned task.
        inline int64_t chooseParallelDim(linalg::LinalgOp op)
        {
            if (op.getNumDpsInits() == 0)
                return -1;
            for (Type t : op->getOperandTypes())
                if (mlir::isa<TensorType>(t))
                    return -1;

            AffineMap m0 = op.getMatchingIndexingMap(op.getDpsInitOperand(0));
            if (m0.getNumResults() == 0)
                return -1;
            auto e = mlir::dyn_cast<AffineDimExpr>(m0.getResult(0));
            if (!e)
                return -1;
            int64_t d = e.getPosition();

            auto iters = op.getIteratorTypesArray();
            auto ranges = op.getStaticLoopRanges();
            if (d >= static_cast<int64_t>(iters.size()) || iters[d] != utils::IteratorType::parallel)
                return -1;
            if (ShapedType::isDynamic(ranges[d]) || ranges[d] < 2)
                return -1;

            for (OpOperand &opd : op->getOpOperands())
            {
                AffineMap m = op.getMatchingIndexingMap(&opd);
                int count = 0;
                for (AffineExpr r : m.getResults())
                {
                    if (auto de = mlir::dyn_cast<AffineDimExpr>(r);
                        de && de.getPosition() == static_cast<unsigned>(d))
                        ++count;
                    else if (r.isFunctionOfDim(d))
                        return -1;
                }
                if (count > 1)
                    return -1;
                if (op.isDpsInit(&opd) && getOperandSliceDim(op, opd, d) != 0)
                    return -1;
            }
            return d;
        }

        inline bool linalgOutputNeedsBroadcast(linalg::LinalgOp producer, Value out)
        {
            Operation *scope = producer->getParentOfType<func::FuncOp>();
            if (!scope)
                scope = producer->getParentOp();
            if (!scope)
                return false;

            bool producerPartitioned = chooseParallelDim(producer) >= 0;
            bool seen = false, need = false;
            scope->walk([&](linalg::LinalgOp op) {
                if (op.getOperation() == producer.getOperation())
                {
                    seen = true;
                    return;
                }
                if (!seen || need)
                    return;
                int64_t dp = chooseParallelDim(op);
                for (OpOperand &opd : op->getOpOperands())
                {
                    if (opd.get() != out || dp < 0)
                        continue;
                    if (!producerPartitioned || getOperandSliceDim(op, opd, dp) != 0)
                        need = true;
                }
            });
            return need;
        }

    } // namespace dhir
} // namespace mlir

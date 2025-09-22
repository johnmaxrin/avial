// Create a new analysis for getting the ins and outs of a task;
// We will only worry about the global objects for now;
// We will only worry about the loads and stores ops for now;

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"

#include "mlir/IR/Builders.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/BuiltinOps.h"

#include "includes/avialOps.h"
#include "includes/avialDialect.h"

struct InsOutsAnalysis
{
    llvm::SmallDenseSet<mlir::Value> ins;
    llvm::SmallDenseSet<mlir::Value> outs;

    InsOutsAnalysis(mlir::Operation *op)
    {
        if (auto schOp = mlir::dyn_cast<mlir::avial::ScheduleOp>(op))
        {
            if (mlir::Block *block = &schOp.getRegion().front())
            {
                llvm::SmallVector<mlir::Value> schArgs(block->args_begin(), block->args_end()); // Global Objects
                schOp.walk([&](mlir::Operation *nestedOp)
                           {
                    if(auto load = mlir::dyn_cast<mlir::memref::LoadOp>(nestedOp))
                        collect(nestedOp, schArgs,ins);
                    
                    else if(auto store = mlir::dyn_cast<mlir::memref::StoreOp>(nestedOp))
                        collect(nestedOp,schArgs,outs); });
            }
            else
                llvm::errs() << "InsOuts Analysis Error: Empty Region!\n";
        }
        else
            llvm::errs() << "Use InsOuts Analysis with ScheduleOp!\n";
    }

    void collect(mlir::Operation *op, llvm::ArrayRef<mlir::Value> schArgs, llvm::SmallDenseSet<mlir::Value> &vec)
    {
        for (auto operand : op->getOperands())
        {
            for (auto arg : schArgs)
            {
                if (operand == arg)
                    vec.insert(arg);
            }
        }
    }

    void print(llvm::raw_ostream &os) const
    {
        os << "=== Ins (block args used in loads) ===\n";
        for (auto v : ins)
        {
            v.print(os);
            os << "\n";
        }

        os << "=== Outs (block args used in stores) ===\n";
        for (auto v : outs)
        {
            v.print(os);
            os << "\n";
        }
    }
};

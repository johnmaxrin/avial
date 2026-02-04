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

    // Create a function that will return all reads and writes inside a
    // certain Op. Say Affine.for
    // If a memref is in both read and write, it only appears in write
    // Returns: result[0] = reads (ins), result[1] = writes (outs)
    static llvm::SmallVector<llvm::SmallVector<mlir::Value>> getInsandOut(mlir::Operation *op)
    {
        llvm::SmallVector<llvm::SmallVector<mlir::Value>> result(2);
        llvm::SmallDenseSet<mlir::Value> insSet;
        llvm::SmallDenseSet<mlir::Value> outsSet;

        // Walk through all nested operations
        op->walk([&](mlir::Operation *nestedOp)
                 {
      // Check for affine load operations (reads)
      if (auto affineLoad = mlir::dyn_cast<mlir::affine::AffineLoadOp>(nestedOp)) {
        insSet.insert(affineLoad.getMemRef());
      }
      // Check for affine store operations (writes)
      else if (auto affineStore = mlir::dyn_cast<mlir::affine::AffineStoreOp>(nestedOp)) {
        outsSet.insert(affineStore.getMemRef());
      }
      // Check for memref load operations (reads)
      else if (auto memrefLoad = mlir::dyn_cast<mlir::memref::LoadOp>(nestedOp)) {
        insSet.insert(memrefLoad.getMemRef());
      }
      // Check for memref store operations (writes)
      else if (auto memrefStore = mlir::dyn_cast<mlir::memref::StoreOp>(nestedOp)) {
        outsSet.insert(memrefStore.getMemRef());
      } });

        // If a memref is in both read and write, keep it only in write
        // Remove from insSet any memref that is also in outsSet
        llvm::SmallVector<mlir::Value> toRemove;
        for (auto val : insSet)
        {
            if (outsSet.contains(val))
            {
                toRemove.push_back(val);
            }
        }

        for (auto val : toRemove)
        {
            insSet.erase(val);
        }

        // Convert sets to vectors
        result[0].assign(insSet.begin(), insSet.end());
        result[1].assign(outsSet.begin(), outsSet.end());

        return result;
    }
};

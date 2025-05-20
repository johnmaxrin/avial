#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"

#include "includes/avialDialect.h"
#include "includes/avialOps.h"

struct TaskOpInfo
{
  mlir::Operation *op;
  llvm::SmallVector<mlir::Value> reads;
  llvm::SmallVector<mlir::Value> writes;
  llvm::SmallVector<TaskOpInfo *> deps;
};

namespace mlir
{
  namespace avial
  {

    struct DependencyGraph
    {
      std::vector<TaskOpInfo> tasks;

      void build(avial::ScheduleOp schedule)
      {
        llvm::outs() << "-- Data Dependence Analysis\n";

        for (TaskOp task : schedule.getBody().getOps<TaskOp>())
        {

          TaskOpInfo info;
          info.op = task;
          for (auto in : task.getInputs())
            info.reads.push_back(in);

          for (auto out : task.getOutputs())
            info.writes.push_back(out);

          tasks.push_back(info);
        }

        // Build the dependency Graph.
        for (size_t i = 0; i < tasks.size(); ++i)
        {
          for (size_t j = i + 1; j < tasks.size(); ++j)
          {
            bool depends = false;
            for (auto outi : tasks[i].writes)
            {
              for (auto inj : tasks[j].reads)
              {
                if (outi == inj)
                {
                  depends = true;
                  break;
                }
              }

              for (auto outj : tasks[j].writes)
              {
                if (outi == outj)
                {
                  depends = true;
                  break;
                }
              }

              if (depends)
                tasks[j].deps.push_back(&tasks[i]);
            }
          }
        }

        llvm::outs() << "digraph TaskGraph {\n";
        for (auto &task : tasks)
        {
          auto nameAttr = task.op->getAttrOfType<mlir::StringAttr>("name");
          std::string name = nameAttr ? nameAttr.getValue().str() : "unnamed";

          for (auto *dep : task.deps)
          {
            auto nameAttr = dep->op->getAttrOfType<mlir::StringAttr>("name");
            std::string depName = nameAttr ? nameAttr.getValue().str() : "unnamed";
            llvm::outs() << "  \"" << depName << "\" -> \"" << name << "\";\n";
          }
        }
        llvm::outs() << "}\n";
      }
    };

  }
}

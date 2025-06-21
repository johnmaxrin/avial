#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"

#include "includes/avialDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
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
      //std::vector<TargetOp> targets;
      std::vector<mlir::memref::AllocaOp> allocs;

      std::vector<std::vector<TaskOpInfo *>> levelVector;

      void build(avial::ScheduleOp schedule)
      {
        llvm::outs() << "-- Building task dependency graph\n";

        // for(TargetOp target: schedule.getBody().getOps<TargetOp>())
        //   targets.push_back(target);

        for(memref::AllocaOp alloc : schedule.getBody().getOps<memref::AllocaOp>())
        {
          if (alloc->getParentOp() == schedule) 
            allocs.push_back(alloc);
          
        }



        for (TaskOp task : schedule.getBody().getOps<TaskOp>())
        {

          TaskOpInfo info;
          info.op = task.getOperation();
          for (auto in : task.getInputs())
            info.reads.push_back(in);

          for (auto out : task.getOutputs())
            info.writes.push_back(out);

          tasks.push_back(std::move(info));
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
      }

      void printDiGraph()
      {
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

      void schedule()
      {
        std::map<TaskOpInfo *, int> inDegree;
        std::map<TaskOpInfo *, int> outDegree;
        std::set<TaskOpInfo *> scheduled;

        for (auto &task : tasks)
        {
          outDegree[&task] = 0;
          inDegree[&task] = 0;

          inDegree[&task] = task.deps.size();
          for (auto &dep : task.deps)
            outDegree[dep]++;
        }

        int cnt = 0;
        while (true)
        {
          std::vector<TaskOpInfo *> currentLevel;

          for (TaskOpInfo &task : tasks)
          {
            if (inDegree[&task] == 0 && !scheduled.count(&task))
            {
              currentLevel.push_back(&task);
            }
          }

          if (scheduled.size() == tasks.size())
            break;
          
          for (auto *t : currentLevel)
          {
            scheduled.insert(t);
            for (auto &task : tasks)
            {
              if (std::find(task.deps.begin(), task.deps.end(), t) != task.deps.end())
                inDegree[&task]--;
            }
          }

        levelVector.push_back(currentLevel);

          
        }

      }
    };

  }
}

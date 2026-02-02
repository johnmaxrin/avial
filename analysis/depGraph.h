#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"

#include "includes/avialDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "includes/avialOps.h"

enum class TargetType
{
  CPU,
  GPU
};

struct TaskOpInfo
{
  mlir::Operation *op;
  llvm::SmallVector<mlir::Value> reads;
  llvm::SmallVector<mlir::Value> writes;
  llvm::SmallVector<mlir::Value> actualBuffer;

  llvm::SmallVector<TaskOpInfo *> deps;
  TargetType target;

  bool isGPU() const { return target == TargetType::GPU; }
  bool isCPU() const { return target == TargetType::CPU; }
};

TargetType getTargetTypeFromAttr(mlir::Attribute attr)
{

  if (!attr)
    return TargetType::CPU;

  if (auto dltiAttr = mlir::dyn_cast<mlir::TargetDeviceSpecAttr>(attr))
  {
    auto gpucntAttr = mlir::dyn_cast<mlir::IntegerAttr>(dltiAttr.getEntries()[4].getValue());
    return (gpucntAttr.getInt() > 0 ? TargetType::GPU : TargetType::CPU);
  }

  return TargetType::CPU;
}


bool rangesOverlap(const std::vector<int64_t> &offset1, const std::vector<int64_t> &size1,
                   const std::vector<int64_t> &offset2, const std::vector<int64_t> &size2)
{
  if (offset1.size() != offset2.size() || size1.size() != size2.size())
    return false;

  for (size_t dim = 0; dim < offset1.size(); ++dim)
  {
    int64_t start1 = offset1[dim];
    int64_t end1 = start1 + size1[dim];
    int64_t start2 = offset2[dim];
    int64_t end2 = start2 + size2[dim];

    // No overlap in this dimension means no overall overlap
    if (end1 <= start2 || end2 <= start1)
      return false;
  }

  return true;
}

// Helper function to get base memref and range from a value
struct MemRefAccess
{
  mlir::Value baseMemRef;
  std::vector<int64_t> offsets;
  std::vector<int64_t> sizes;
  bool isSubview;
};

MemRefAccess getMemRefAccess(mlir::Value val)
{
  MemRefAccess access;
  access.isSubview = false;

  // Check if this is a subview
  if (auto defOp = val.getDefiningOp())
  {
    if (auto subviewOp = mlir::dyn_cast<mlir::memref::SubViewOp>(defOp))
    {
      access.isSubview = true;
      access.baseMemRef = subviewOp.getSource();

      // Extract offsets
      auto offsetsAttr = subviewOp.getStaticOffsets();
      for (auto offset : offsetsAttr)
        access.offsets.push_back(offset);

      // Extract sizes
      auto sizesAttr = subviewOp.getStaticSizes();
      for (auto size : sizesAttr)
        access.sizes.push_back(size);
    }
    else
    {
      // Not a subview, just a regular memref
      access.baseMemRef = val;
    }
  }
  else
  {
    // Block argument or other source
    access.baseMemRef = val;
  }

  return access;
}

// Helper function to check if two memory accesses conflict
bool memoryAccessesConflict(mlir::Value val1, mlir::Value val2)
{
  MemRefAccess access1 = getMemRefAccess(val1);
  MemRefAccess access2 = getMemRefAccess(val2);

  // Check if they refer to the same base array
  if (access1.baseMemRef != access2.baseMemRef)
    return false;

  // Same base array - now check ranges
  if (!access1.isSubview && !access2.isSubview)
  {
    // Both access the entire array
    return true;
  }
  else if (!access1.isSubview || !access2.isSubview)
  {
    // One is subview, one is full array - they conflict
    return true;
  }
  else
  {
    // Both are subviews - check if ranges overlap
    return rangesOverlap(access1.offsets, access1.sizes,
                         access2.offsets, access2.sizes);
  }
}



namespace mlir
{
  namespace avial
  {

    struct DependencyGraph
    {
      std::vector<TaskOpInfo> tasks;
      // std::vector<TargetOp> targets;
      std::vector<mlir::memref::AllocaOp> allocs;

      std::vector<std::vector<TaskOpInfo *>> levelVector;

      void build(avial::ScheduleOp schedule)
      {
        llvm::errs() << "-- Building task dependency graph\n";

        // for(TargetOp target: schedule.getBody().getOps<TargetOp>())
        //   targets.push_back(target);

        for (memref::AllocaOp alloc : schedule.getBody().getOps<memref::AllocaOp>())
        {
          if (alloc->getParentOp() == schedule)
            allocs.push_back(alloc);
        }

        for (TaskOp task : schedule.getBody().getOps<TaskOp>())
        {

          TaskOpInfo info;
          info.target = getTargetTypeFromAttr(task->getAttr("target"));

          info.op = task.getOperation();
          for (auto in : task.getInputs())
            info.reads.push_back(in);

          for (auto out : task.getOutputs())
            info.writes.push_back(out);

          for (auto actual : task.getOutputs())
            info.actualBuffer.push_back(actual);

          tasks.push_back(std::move(info));
        }

        // Build the dependency Graph.
        for (size_t i = 0; i < tasks.size(); ++i)
        {
          for (size_t j = i + 1; j < tasks.size(); ++j)
          {
            bool depends = false;
            auto repIdI = tasks[i].op->getAttrOfType<mlir::IntegerAttr>("repId");
            auto repIdJ = tasks[j].op->getAttrOfType<mlir::IntegerAttr>("repId");

            // Skip if same repId (same iteration/replica)
            if (repIdI.getInt() == repIdJ.getInt())
              continue;

            // Check Read-After-Write (RAW): task[j] reads what task[i] writes
            for (auto outi : tasks[i].writes)
            {
              for (auto inj : tasks[j].reads)
              {
                if (memoryAccessesConflict(outi, inj))
                {
                  llvm::errs() << "RAW dependency detected\n";
                  depends = true;
                  break;
                }
              }
              if (depends)
                break;
            }

            // Check Write-After-Write (WAW): both tasks write to same/overlapping location
            if (!depends)
            {
              for (auto outi : tasks[i].writes)
              {
                for (auto outj : tasks[j].writes)
                {
                  if (memoryAccessesConflict(outi, outj))
                  {
                    llvm::errs() << "WAW dependency detected\n";
                    depends = true;
                    break;
                  }
                }
                if (depends)
                  break;
              }
            }

            // Check Write-After-Read (WAR): task[j] writes what task[i] reads
            if (!depends)
            {
              for (auto ini : tasks[i].reads)
              {
                for (auto outj : tasks[j].writes)
                {
                  if (memoryAccessesConflict(ini, outj))
                  {
                    llvm::errs() << "WAR dependency detected\n";
                    depends = true;
                    break;
                  }
                }
                if (depends)
                  break;
              }
            }

            if (depends)
            {
              llvm::errs() << "Task J (dependent)\n";
              llvm::errs() << tasks[j].op->getAttr("repId") << "\n";
              llvm::errs() << "Task I (must execute first)\n";
              llvm::errs() << tasks[i].op->getAttr("repId") << "\n";

              tasks[j].deps.push_back(&tasks[i]);
            }
          }
        }
      }

      void printDiGraph()
      {
        llvm::errs() << "digraph TaskGraph {\n";
        for (auto &task : tasks)
        {
          auto nameAttr = task.op->getAttrOfType<mlir::StringAttr>("name");
          std::string name = nameAttr ? nameAttr.getValue().str() : "unnamed";

          for (auto *dep : task.deps)
          {
            auto nameAttr = dep->op->getAttrOfType<mlir::StringAttr>("name");
            std::string depName = nameAttr ? nameAttr.getValue().str() : "unnamed";
            llvm::errs() << "  \"" << depName << "\" -> \"" << name << "\";\n";
          }
        }
        llvm::errs() << "}\n";
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



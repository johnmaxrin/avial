#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"

#include "includes/dhirDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "includes/dhirOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "includes/utils.h"

#include <functional>
#include <limits>
#include <optional>

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
  
  int64_t repId;  // Which replicate this task came from
  std::optional<int64_t> shardGroup;  // Present only on lowered replicate shards
  size_t emissionGroup;  // Consecutive tasks that can share one emission point

  bool isGPU() const { return target == TargetType::GPU; }
  bool isCPU() const { return target == TargetType::CPU; }
};

TargetType getTargetTypeFromAttr(mlir::Attribute attr)
{

  if (!attr)
    return TargetType::CPU;

  if (auto dltiAttr = mlir::dyn_cast<mlir::TargetDeviceSpecAttr>(attr))
  {
    if (auto gpucntAttr = mlir::dyn_cast_or_null<mlir::IntegerAttr>(getDeviceAttribute(dltiAttr, "gpu_count"))) {
      return (gpucntAttr.getInt() > 0 ? TargetType::GPU : TargetType::CPU);
    }
  }

  return TargetType::CPU;
}


bool rangesOverlap(const std::vector<int64_t> &offset1, const std::vector<int64_t> &size1,
                   const std::vector<int64_t> &offset2, const std::vector<int64_t> &size2)
{
  if (offset1.size() != offset2.size() || size1.size() != size2.size())
    return true;

  for (size_t dim = 0; dim < offset1.size(); ++dim)
  {
    if (size1[dim] <= 0 || size2[dim] <= 0)
      return false;

    // Keep interval arithmetic from wrapping on extreme offsets.
    __int128 start1 = offset1[dim];
    __int128 end1 = start1 + static_cast<__int128>(size1[dim]);
    __int128 start2 = offset2[dim];
    __int128 end2 = start2 + static_cast<__int128>(size2[dim]);

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
  bool rangeKnown;
};

MemRefAccess getMemRefAccess(mlir::Value val)
{
  MemRefAccess access;
  access.isSubview = false;
  access.rangeKnown = true;

  // Check if this is a subview
  if (auto defOp = val.getDefiningOp())
  {
    if (auto subviewOp = mlir::dyn_cast<mlir::memref::SubViewOp>(defOp))
    {
      access.isSubview = true;
      MemRefAccess source = getMemRefAccess(subviewOp.getSource());
      access.baseMemRef = source.baseMemRef;
      access.rangeKnown = source.rangeKnown;

      auto offsetsAttr = subviewOp.getStaticOffsets();
      auto sizesAttr = subviewOp.getStaticSizes();
      auto stridesAttr = subviewOp.getStaticStrides();

      // Only static, unit-stride, rank-preserving views can be compared
      // exactly.  Dynamic metadata is conservatively considered overlapping.
      if (offsetsAttr.size() != sizesAttr.size() ||
          offsetsAttr.size() != stridesAttr.size() ||
          (!source.offsets.empty() && source.offsets.size() != offsetsAttr.size()))
      {
        access.rangeKnown = false;
        return access;
      }

      for (unsigned i = 0; i < offsetsAttr.size(); ++i)
      {
        if (offsetsAttr[i] == mlir::ShapedType::kDynamic ||
            sizesAttr[i] == mlir::ShapedType::kDynamic ||
            stridesAttr[i] == mlir::ShapedType::kDynamic ||
            stridesAttr[i] != 1)
        {
          access.rangeKnown = false;
          return access;
        }

        int64_t baseOffset = source.offsets.empty() ? 0 : source.offsets[i];
        __int128 combinedOffset = static_cast<__int128>(baseOffset) + offsetsAttr[i];
        if (combinedOffset < std::numeric_limits<int64_t>::min() ||
            combinedOffset > std::numeric_limits<int64_t>::max())
        {
          access.rangeKnown = false;
          return access;
        }
        access.offsets.push_back(static_cast<int64_t>(combinedOffset));
        access.sizes.push_back(sizesAttr[i]);
      }

      if (!source.offsets.empty())
      {
        for (unsigned i = 0; i < access.sizes.size(); ++i)
        {
          if (access.offsets[i] < source.offsets[i] ||
              access.offsets[i] - source.offsets[i] > source.sizes[i] ||
              access.sizes[i] > source.sizes[i] - (access.offsets[i] - source.offsets[i]))
          {
            access.rangeKnown = false;
            return access;
          }
        }
      }
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
    if (!access1.rangeKnown || !access2.rangeKnown)
      return true;

    // Both are subviews - check if ranges overlap
    return rangesOverlap(access1.offsets, access1.sizes,
                         access2.offsets, access2.sizes);
  }
}



namespace mlir
{
  namespace dhir
  {

    struct DependencyGraph
    {
      std::vector<TaskOpInfo> tasks;
      std::vector<mlir::memref::AllocaOp> allocs;
      std::vector<std::vector<TaskOpInfo *>> levelVector;
      
      void build(dhir::ScheduleOp schedule)
      {
        llvm::errs() << "-- Building task dependency graph\n";

        tasks.clear();
        allocs.clear();
        levelVector.clear();

        llvm::DenseMap<mlir::Operation *, size_t> taskEmissionGroups;
        size_t nextEmissionGroup = 0;

        auto isSetup = [](mlir::Operation *op) {
          return mlir::isMemoryEffectFree(op) ||
                 mlir::isa<mlir::memref::AllocOp, mlir::memref::AllocaOp>(op);
        };

        std::function<void(mlir::Block &)> assignEmissionGroups =
            [&](mlir::Block &body) {
          std::optional<size_t> activeGroup;

          for (mlir::Operation &bodyOp : body)
          {
            if (mlir::isa<mlir::dhir::YieldOp, mlir::scf::YieldOp>(bodyOp) ||
                isSetup(&bodyOp))
              continue;

            if (mlir::isa<mlir::dhir::TaskOp>(bodyOp))
            {
              if (!activeGroup)
                activeGroup = nextEmissionGroup++;
              taskEmissionGroups[&bodyOp] = *activeGroup;
              continue;
            }

            if (auto forOp = mlir::dyn_cast<mlir::scf::ForOp>(bodyOp))
            {
              bool wrapsTasks = false;
              forOp.walk([&](mlir::dhir::TaskOp) { wrapsTasks = true; });
              if (wrapsTasks)
              {
                activeGroup.reset();
                assignEmissionGroups(*forOp.getBody());
                activeGroup.reset();
                continue;
              }
            }

            // Serial work and unsupported control flow are ordering barriers.
            activeGroup.reset();
          }
        };

        assignEmissionGroups(schedule.getBody().front());

        // Collect allocations
        for (memref::AllocaOp alloc : schedule.getBody().getOps<memref::AllocaOp>())
        {
          if (alloc->getParentOp() == schedule)
            allocs.push_back(alloc);
        }

        // Collect all tasks (they may be inside a loop)
        schedule.getBody().walk([&](TaskOp task) {
          TaskOpInfo info;
          info.target = getTargetTypeFromAttr(task->getAttr("target"));
          info.op = task.getOperation();
          auto groupIt = taskEmissionGroups.find(task.getOperation());
          if (groupIt == taskEmissionGroups.end())
            llvm::report_fatal_error(
                "Task is nested in control flow unsupported by DHIR-to-MPI");
          info.emissionGroup = groupIt->second;
          
          // Get repId
          auto repIdAttr = task->getAttrOfType<mlir::IntegerAttr>("repId");
          info.repId = repIdAttr ? repIdAttr.getInt() : -1;
          if (auto shardGroupAttr = task->getAttrOfType<mlir::IntegerAttr>("shardGroup"))
            info.shardGroup = shardGroupAttr.getInt();
          
          // Get inputs and outputs
          for (auto in : task.getInputs())
            info.reads.push_back(in);

          for (auto out : task.getOutputs())
            info.writes.push_back(out);

          for (auto actual : task.getOutputs())
            info.actualBuffer.push_back(actual);

          tasks.push_back(std::move(info));
        });
        
        llvm::errs() << "Collected " << tasks.size() << " tasks\n";

        // Build the dependency graph
        buildDependencies();
      }
      
      void buildDependencies()
      {
        llvm::errs() << "-- Analyzing task dependencies\n";
        
        for (size_t i = 0; i < tasks.size(); ++i)
        {
          for (size_t j = i + 1; j < tasks.size(); ++j)
          {
            bool depends = false;
            
            int64_t repIdI = tasks[i].repId;
            int64_t repIdJ = tasks[j].repId;

            llvm::errs() << "\nChecking dependency: Task " << i << " (repId=" << repIdI 
                         << ") -> Task " << j << " (repId=" << repIdJ << ")\n";

            // A level is emitted at the position of its first task. Tasks in
            // different program-order groups therefore cannot share a level;
            // this covers sibling loops, tasks before/after a loop, and serial
            // work between otherwise independent replicates.
            if (tasks[i].emissionGroup != tasks[j].emissionGroup)
            {
              depends = true;
              llvm::errs() << "  Different emission groups - preserve program order\n";
            }
            else if (tasks[i].shardGroup && tasks[j].shardGroup &&
                     tasks[i].shardGroup == tasks[j].shardGroup)
            {
              llvm::errs() << "  Same shard group - no dependency (parallel shards)\n";
              continue;
            }
            else
            {
              depends = checkMemoryDependency(tasks[i], tasks[j]);
              if (depends)
                llvm::errs() << "  Memory dependency detected\n";
            }

            if (depends)
            {
              tasks[j].deps.push_back(&tasks[i]);
              
              auto nameAttrI = tasks[i].op->getAttrOfType<mlir::StringAttr>("name");
              auto nameAttrJ = tasks[j].op->getAttrOfType<mlir::StringAttr>("name");
              std::string nameI = nameAttrI ? nameAttrI.getValue().str() : "unnamed";
              std::string nameJ = nameAttrJ ? nameAttrJ.getValue().str() : "unnamed";
              
              llvm::errs() << "  ✓ Dependency: " << nameI << " (repId=" << repIdI 
                           << ") -> " << nameJ << " (repId=" << repIdJ << ")\n";
            }
          }
        }
      }
      
      bool checkMemoryDependency(TaskOpInfo &taskI, TaskOpInfo &taskJ)
      {
        // Check Read-After-Write (RAW): task j reads what task i writes
        for (auto outi : taskI.writes)
        {
          for (auto inj : taskJ.reads)
          {
            if (memoryAccessesConflict(outi, inj))
            {
              llvm::errs() << "    RAW dependency detected\n";
              return true;
            }
          }
        }

        // Check Write-After-Write (WAW): both tasks write to same/overlapping location
        for (auto outi : taskI.writes)
        {
          for (auto outj : taskJ.writes)
          {
            if (memoryAccessesConflict(outi, outj))
            {
              llvm::errs() << "    WAW dependency detected\n";
              return true;
            }
          }
        }

        // Check Write-After-Read (WAR): task j writes what task i reads
        for (auto ini : taskI.reads)
        {
          for (auto outj : taskJ.writes)
          {
            if (memoryAccessesConflict(ini, outj))
            {
              llvm::errs() << "    WAR dependency detected\n";
              return true;
            }
          }
        }
        
        return false;
      }

      void printDiGraph()
      {
        llvm::errs() << "\n-- Task Dependency Graph (DOT format) --\n";
        llvm::errs() << "digraph TaskGraph {\n";
        llvm::errs() << "  rankdir=LR;\n";
        llvm::errs() << "  node [shape=box];\n";
        
        // Add node labels with repId information
        for (auto &task : tasks)
        {
          auto nameAttr = task.op->getAttrOfType<mlir::StringAttr>("name");
          std::string name = nameAttr ? nameAttr.getValue().str() : "unnamed";
          
          std::string label = name + "\\nrepId=" + std::to_string(task.repId);
          std::string color = task.isGPU() ? "lightblue" : "lightgray";
          
          llvm::errs() << "  \"" << name << "_" << task.repId << "\" [label=\"" 
                       << label << "\", style=filled, fillcolor=" << color << "];\n";
        }
        
        llvm::errs() << "\n";
        
        // Add edges for dependencies
        for (auto &task : tasks)
        {
          auto nameAttr = task.op->getAttrOfType<mlir::StringAttr>("name");
          std::string name = nameAttr ? nameAttr.getValue().str() : "unnamed";

          for (auto *dep : task.deps)
          {
            auto depNameAttr = dep->op->getAttrOfType<mlir::StringAttr>("name");
            std::string depName = depNameAttr ? depNameAttr.getValue().str() : "unnamed";
            
            llvm::errs() << "  \"" << depName << "_" << dep->repId << "\" -> \"" 
                         << name << "_" << task.repId << "\";\n";
          }
        }
        
        // Add subgraph clusters for each repId
        std::map<int64_t, std::vector<TaskOpInfo*>> repIdGroups;
        for (auto &task : tasks)
        {
          repIdGroups[task.repId].push_back(&task);
        }
        
        llvm::errs() << "\n  // Replicate groups\n";
        for (auto &[repId, taskList] : repIdGroups)
        {
          llvm::errs() << "  subgraph cluster_rep" << repId << " {\n";
          llvm::errs() << "    label=\"Replicate " << repId << "\";\n";
          llvm::errs() << "    style=dashed;\n";
          
          for (auto *task : taskList)
          {
            auto nameAttr = task->op->getAttrOfType<mlir::StringAttr>("name");
            std::string name = nameAttr ? nameAttr.getValue().str() : "unnamed";
            llvm::errs() << "    \"" << name << "_" << task->repId << "\";\n";
          }
          
          llvm::errs() << "  }\n";
        }
        
        llvm::errs() << "}\n";
        llvm::errs() << "-- End Task Dependency Graph --\n\n";
      }

      void schedule()
      {
        llvm::errs() << "-- Scheduling tasks using topological sort\n";
        
        std::map<TaskOpInfo *, int> inDegree;
        std::map<TaskOpInfo *, int> outDegree;
        std::set<TaskOpInfo *> scheduled;

        // Initialize in-degree and out-degree
        for (auto &task : tasks)
        {
          outDegree[&task] = 0;
          inDegree[&task] = task.deps.size();
          
          for (auto *dep : task.deps)
            outDegree[dep]++;
        }

        // Topological sort with level-by-level scheduling
        int level = 0;
        while (scheduled.size() < tasks.size())
        {
          std::vector<TaskOpInfo *> currentLevel;

          // Find all tasks with in-degree 0 (ready to execute)
          for (TaskOpInfo &task : tasks)
          {
            if (inDegree[&task] == 0 && !scheduled.count(&task))
            {
              currentLevel.push_back(&task);
            }
          }

          if (currentLevel.empty() && scheduled.size() < tasks.size())
          {
            llvm::errs() << "ERROR: Cycle detected in dependency graph!\n";
            break;
          }

          llvm::errs() << "Level " << level << ": " << currentLevel.size() << " tasks\n";
          
          // Print tasks in this level
          for (auto *t : currentLevel)
          {
            auto nameAttr = t->op->getAttrOfType<mlir::StringAttr>("name");
            std::string name = nameAttr ? nameAttr.getValue().str() : "unnamed";
            llvm::errs() << "  - Task " << name << " (repId=" << t->repId << ")\n";
          }

          // Mark tasks as scheduled and update in-degrees
          for (auto *t : currentLevel)
          {
            scheduled.insert(t);
            
            // Decrease in-degree of dependent tasks
            for (auto &task : tasks)
            {
              if (std::find(task.deps.begin(), task.deps.end(), t) != task.deps.end())
              {
                inDegree[&task]--;
              }
            }
          }

          levelVector.push_back(currentLevel);
          level++;
        }
        
        llvm::errs() << "Scheduling complete: " << level << " levels\n";
      }
    };

  }
}

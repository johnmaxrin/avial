#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"

#include "includes/avialDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "includes/avialOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"

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
  bool insideLoop;  // Whether this task is inside a loop

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
      std::vector<mlir::memref::AllocaOp> allocs;
      std::vector<std::vector<TaskOpInfo *>> levelVector;
      
      bool hasLoop;  // Whether tasks are inside a loop
      mlir::scf::ForOp forLoop;  // The loop containing tasks (if any)

      void build(avial::ScheduleOp schedule)
      {
        llvm::errs() << "-- Building task dependency graph\n";

        hasLoop = false;
        
        // Check if tasks are inside a for loop
        schedule.getBody().walk([&](mlir::scf::ForOp loop) {
          hasLoop = true;
          forLoop = loop;
          llvm::errs() << "Found tasks inside scf.for loop\n";
        });

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
          info.insideLoop = hasLoop;
          
          // Get repId
          auto repIdAttr = task->getAttrOfType<mlir::IntegerAttr>("repId");
          info.repId = repIdAttr ? repIdAttr.getInt() : -1;
          
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

            // Dependency rules based on repId and loop context
            if (hasLoop)
            {
              // Tasks are inside a loop - different rules apply
              
              if (repIdI == repIdJ)
              {
                // Same repId means same replicate (iteration)
                // These tasks can execute in parallel within the same iteration
                llvm::errs() << "  Same repId - no dependency (parallel within iteration)\n";
                continue;
              }
              else
              {
                // Different repId means different replicates
                // Check for loop-carried dependencies
                
                // If repIdI < repIdJ, task i executes before task j in each iteration
                // Need to check if j depends on i's output from the SAME iteration
                
                depends = checkMemoryDependency(tasks[i], tasks[j]);
                
                if (depends)
                {
                  llvm::errs() << "  Loop-carried dependency detected (repId " 
                               << repIdI << " -> " << repIdJ << ")\n";
                }
              }
            }
            else
            {
              // Tasks are NOT inside a loop
              // Standard sequential dependency checking
              
              if (repIdI == repIdJ)
              {
                // Same repId - these are from the same replicate, no dependency
                llvm::errs() << "  Same repId - no dependency\n";
                continue;
              }
              
              depends = checkMemoryDependency(tasks[i], tasks[j]);
              
              if (depends)
              {
                llvm::errs() << "  Sequential dependency detected\n";
              }
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
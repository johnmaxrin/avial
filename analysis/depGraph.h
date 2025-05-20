#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"

#include "includes/avialDialect.h"
#include "includes/avialOps.h"

namespace mlir
{
    namespace avial
    {

        struct DependencyGraph {
            llvm::DenseMap<Value, int> bufferUsage;
          
            void build(avial::ScheduleOp schedule) {
                llvm::outs() << "-- Data Dependence Analysis\n";

              for (TaskOp task : schedule.getBody().getOps<TaskOp>()) {
                llvm::outs() << "[TASK]: \n";
                task.getType().dump();

                llvm::outs() << "[READS]: \n";
                for (Value v : task.getInputs())
                  v.dump();
                
                llvm::outs() << "[WRITES]: \n";
                for (Value v : task.getInputs())
                  v.dump();
                
                
              }
            }
          };
          
    }
}

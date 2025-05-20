#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"

#include "includes/avialDialect.h"
#include "includes/avialOps.h"

namespace mlir
{
    namespace avial
    {

        struct ScheduleAnalysis {
            llvm::DenseMap<Value, int> bufferUsage;
          
            void run(avial::ScheduleOp schedule) {
                llvm::outs() << "Hello.!!\n";

              for (TaskOp task : schedule.getBody().getOps<TaskOp>()) {
                for (Value v : task.getOperands())
                  bufferUsage[v]++;
              }
            }
          };
          
    }
}

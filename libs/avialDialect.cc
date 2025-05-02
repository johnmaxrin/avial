#include "includes/avialDialect.h"
#include "includes/avialOps.h"

#include "dialect/Dialect.cpp.inc"

#include "llvm/ADT/TypeSwitch.h"
#include "mlir/IR/Builders.h"



#define GET_OP_CLASSES
#include "dialect/Ops.cpp.inc"


namespace mlir
{
    namespace avial 
    {

        void AvialDialect::initialize()
        {

            addOperations<
                #define GET_OP_LIST
                #include "dialect/Ops.cpp.inc"
                >();  
        }

        
    }


}

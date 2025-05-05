#include "includes/avialDialect.h"
#include "includes/avialOps.h"
#include "includes/avialTypes.h"

#include "dialect/Dialect.cpp.inc"

#include "llvm/ADT/TypeSwitch.h"
#include "mlir/IR/Builders.h"

#define GET_TYPEDEF_CLASSES
#include "dialect/Types.cpp.inc"

#define GET_OP_CLASSES
#include "dialect/Ops.cpp.inc"

#include "dialect/Enums.cpp.inc"

namespace mlir
{
    namespace avial
    {

        void AvialDialect::initialize()
        {

            addTypes<
#define GET_TYPEDEF_LIST
#include "dialect/Types.cpp.inc"
                >();

            addOperations<
#define GET_OP_LIST
#include "dialect/Ops.cpp.inc"
                >();
        }


    }

}

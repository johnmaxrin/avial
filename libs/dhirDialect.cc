#include "includes/dhirDialect.h"
#include "includes/dhirOps.h"
#include "includes/dhirTypes.h"



#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Attributes.h"

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
    namespace dhir
    {

        void DhirDialect::initialize()
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

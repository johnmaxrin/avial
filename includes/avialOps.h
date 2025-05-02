#ifndef AVIALOPS
#define AVIALOPS

#include "avialDialect.h"

#include "mlir/IR/BuiltinOps.h"    // from @llvm-project
#include "mlir/IR/BuiltinTypes.h"  // from @llvm-project
#include "mlir/IR/Dialect.h"       // from @llvm-project

#include "mlir/IR/SymbolTable.h"
#include "mlir/Interfaces/CallInterfaces.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "mlir/Interfaces/FunctionInterfaces.h"
#include "mlir/Interfaces/CastInterfaces.h"


#define GET_OP_CLASSES
#include "dialect/Ops.h.inc"


 


#endif  // AVIALOPS
#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/Dialect/DLTI/Traits.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Attributes.h"

void attachDLTISpec(mlir::ModuleOp module, mlir::MLIRContext *context /* Receive Info as Params */);
void extractTargetDeviceSpecs(mlir::ModuleOp module);
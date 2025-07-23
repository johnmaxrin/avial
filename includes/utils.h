#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/Dialect/DLTI/Traits.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Attributes.h"
#include "includes/avialDialect.h"
#include "includes/avialOps.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/IR/IRMapping.h"


void attachDLTISpec(mlir::ModuleOp module, mlir::MLIRContext *context /* Receive Info as Params */);
llvm::SmallVector<mlir::TargetDeviceSpecAttr> extractTargetDeviceSpecs(mlir::ModuleOp module);

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
#include <fstream>

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/MPI/IR/MPI.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/BuiltinOps.h"
#include "llvm/Support/raw_ostream.h"
#include <vector>

#include "json.hpp"
#include "system_config.h"

void attachDLTISpec(mlir::ModuleOp module, mlir::MLIRContext *context, SystemTopology);
llvm::SmallVector<mlir::TargetDeviceSpecAttr> extractTargetDeviceSpecs(mlir::ModuleOp module);
SystemTopology parseSystemConfig();

void generateBroadcastCommunication(
    mlir::OpBuilder &rewriter,
    mlir::Location loc,
    llvm::SmallVectorImpl<mlir::Value> &toBroadcast,
    mlir::Value rank,
    mlir::Value zero,
    mlir::Value comm,
    mlir::Type retVal,
    mlir::Value tag,
    mlir::Value numRanks);

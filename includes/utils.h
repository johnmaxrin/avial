#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/Dialect/DLTI/Traits.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Attributes.h"
#include "includes/dhirDialect.h"
#include "includes/dhirOps.h"
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
mlir::Attribute getDeviceAttribute(mlir::TargetDeviceSpecAttr deviceSpec, llvm::StringRef key);
SystemTopology parseSystemConfig(llvm::StringRef configFile);

void generateBroadcastCommunication(
    mlir::OpBuilder &rewriter,
    mlir::Location loc,
    llvm::SmallVectorImpl<mlir::Value> &toBroadcast,
    mlir::Value rank,
    mlir::Value rootRank,
    mlir::Value comm,
    mlir::Type retVal,
    mlir::Value tag,
    mlir::Value numRanks,
    // Set when this site runs once per iteration of an enclosing rebuilt loop,
    // which is the gate on lowering the fan-out to a collective.  Deliberately
    // has no default: every call site must decide consciously, because getting
    // it wrong on a site that is not uniformly reached is a silent hang.
    bool perIteration);

// Emit one MPI_Allgatherv assembling a dim-0 partitioned buffer in place.
// startByNode/sizeByNode are per-node shard dim-0 offset and row count;
// nodeToRankMap maps node index -> MPI rank.  See the definition for the
// element scaling and the all-ranks-reachability contract.
void generateAllgathervCommunication(
    mlir::OpBuilder &rewriter,
    mlir::Location loc,
    mlir::Value baseBuffer,
    llvm::ArrayRef<mlir::Value> startByNode,
    llvm::ArrayRef<mlir::Value> sizeByNode,
    mlir::Value nodeToRankMap,
    mlir::Value comm);
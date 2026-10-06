#pragma once

#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/Dialect/DLTI/Traits.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Attributes.h"
#include "mlir/IR/PatternMatch.h"
#include "includes/dhirDialect.h"
#include "includes/dhirOps.h"
#include "includes/dhirTypes.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/IR/IRMapping.h"
#include <fstream>

#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/MPI/IR/MPI.h"
#include "mlir/Dialect/Utils/StaticValueUtils.h"
#include "mlir/IR/MLIRContext.h"
#include "llvm/Support/raw_ostream.h"
#include <optional>
#include <string>
#include <vector>

#include "json.hpp"
#include "system_config.h"

void attachDLTISpec(mlir::ModuleOp module, mlir::MLIRContext *context, SystemTopology);
llvm::SmallVector<mlir::TargetDeviceSpecAttr> extractTargetDeviceSpecs(mlir::ModuleOp module);
mlir::Attribute getDeviceAttribute(mlir::TargetDeviceSpecAttr deviceSpec, llvm::StringRef key);
SystemTopology parseSystemConfig(llvm::StringRef configFile);

mlir::FailureOr<llvm::SmallVector<mlir::TargetDeviceSpecAttr>>
getTargetDevices(mlir::Operation *anchor);

struct DeviceChunk
{
    int64_t start;
    int64_t end;
    mlir::TargetDeviceSpecAttr device;
    int deviceIndex;
};

mlir::FailureOr<llvm::SmallVector<DeviceChunk>>
computeCostBasedChunks(mlir::Operation *anchor,
                       llvm::ArrayRef<mlir::TargetDeviceSpecAttr> devices,
                       int64_t lb, int64_t ub);

int64_t nextRepId(mlir::Operation *root);

mlir::Value makeSliceAlongDim(mlir::RewriterBase &rw, mlir::Location loc,
                              mlir::Value v, int64_t dim, int64_t start,
                              int64_t size);

struct TaskSpec
{
    mlir::TargetDeviceSpecAttr device;
    llvm::SmallVector<mlir::Value> reads;
    llvm::SmallVector<mlir::Value> writes;
    llvm::SmallVector<mlir::Value> bases;
    int64_t outStart = 0;
    int64_t outEnd = 0;
    mlir::IntegerAttr repId;
    bool needBroadcast = false;
    std::string name;
    std::optional<bool> partitioned;
};

// Body block contains only dhir.yield; insert the body before its terminator.
mlir::dhir::TaskOp createTaskShell(mlir::RewriterBase &rw, mlir::Location loc,
                                   const TaskSpec &spec);

mlir::FailureOr<mlir::Value>
getTaskOutputRegion(mlir::OpBuilder &b, mlir::Location loc, mlir::Value written,
                    llvm::ArrayRef<int64_t> outRanges);

mlir::LogicalResult checkContiguousForMPI(mlir::Location loc, mlir::Value buf);

mlir::LogicalResult generateBroadcastCommunication(
    mlir::OpBuilder &rewriter,
    mlir::Location loc,
    llvm::SmallVectorImpl<mlir::Value> &toBroadcast,
    mlir::Value rank,
    mlir::Value rootRank,
    mlir::Value comm,
    mlir::Type retVal,
    mlir::Value tag,
    mlir::Value numRanks);

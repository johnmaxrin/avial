#pragma once

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/Builders.h"
#include "mlir/Pass/Pass.h"

#include "includes/dhirDialect.h"
#include "includes/dhirOps.h"
#include "includes/dhirTypes.h"
#include "includes/utils.h"
#include "analysis/linalgPartition.h"
#include "analysis/broadcastAnalysis.h"

using namespace mlir;
using namespace dhir;

namespace mlir {
namespace dhir {

#define GEN_PASS_DEF_CONVERTLINALGTODHIRPASS
#include "dialect/Passes.h.inc"

// linalg.index is tile-relative after slicing; shift it back to the global index.
static void rebaseLinalgIndex(Operation *tiled, int64_t dim, int64_t offset,
                              RewriterBase &rw) {
  if (offset == 0)
    return;
  SmallVector<linalg::IndexOp> idxOps;
  tiled->walk([&](linalg::IndexOp i) {
    if (i.getDim() == static_cast<uint64_t>(dim))
      idxOps.push_back(i);
  });
  for (auto i : idxOps) {
    OpBuilder::InsertionGuard g(rw);
    rw.setInsertionPointAfter(i);
    Value c = rw.create<arith::ConstantIndexOp>(i.getLoc(), offset);
    Value add = rw.create<arith::AddIOp>(i.getLoc(), i.getResult(), c);
    i.getResult().replaceAllUsesExcept(add, add.getDefiningOp());
  }
}

static LogicalResult
lowerLinalgOpToTasks(linalg::LinalgOp op,
                     ArrayRef<TargetDeviceSpecAttr> devices, int64_t repId,
                     RewriterBase &rw) {
  Location loc = op.getLoc();
  Operation *raw = op.getOperation();

  for (Type t : raw->getOperandTypes())
    if (isa<TensorType>(t))
      return op->emitError("linalg-to-dhir requires bufferized (memref) linalg ops");

  // Must run before any IR changes: it inspects the later, still-unconverted linalg ops.
  bool needBroadcast = false;
  for (Value out : op.getDpsInits())
    if (doesOutputNeedBroadcast(raw, out))
      needBroadcast = true;

  IntegerAttr repIdAttr = rw.getI64IntegerAttr(repId);
  SmallVector<Value> bases(op.getDpsInits().begin(), op.getDpsInits().end());
  int64_t dp = chooseParallelDim(op);

  if (dp < 0) {
    rw.setInsertionPoint(raw);

    TaskSpec spec;
    spec.device = devices[0];
    for (OpOperand &opd : raw->getOpOperands())
      (op.isDpsInit(&opd) ? spec.writes : spec.reads).push_back(opd.get());
    spec.bases = bases;
    spec.outStart = 0;
    spec.outEnd = 0;
    spec.repId = repIdAttr;
    spec.needBroadcast = needBroadcast;
    spec.name = "unpartitioned";
    spec.partitioned = false;

    auto task = createTaskShell(rw, loc, spec);
    rw.moveOpBefore(raw, task.getRegion().front().getTerminator());
    return success();
  }

  int64_t extent = op.getStaticLoopRanges()[dp];
  auto chunksOr = computeCostBasedChunks(raw, devices, 0, extent);
  if (failed(chunksOr))
    return failure();

  for (const DeviceChunk &c : *chunksOr) {
    rw.setInsertionPoint(raw);
    int64_t size = c.end - c.start;

    TaskSpec spec;
    spec.device = c.device;
    SmallVector<Value> views;
    for (OpOperand &opd : raw->getOpOperands()) {
      Value view = opd.get();
      int64_t sd = getOperandSliceDim(op, opd, dp);
      if (sd >= 0 && isa<MemRefType>(view.getType()))
        view = makeSliceAlongDim(rw, loc, view, sd, c.start, size);
      views.push_back(view);
      (op.isDpsInit(&opd) ? spec.writes : spec.reads).push_back(view);
    }
    spec.bases = bases;
    spec.outStart = c.start;
    spec.outEnd = c.end;
    spec.repId = repIdAttr;
    spec.needBroadcast = needBroadcast;
    spec.name = std::to_string(c.deviceIndex);
    spec.partitioned = true;

    auto task = createTaskShell(rw, loc, spec);
    rw.setInsertionPoint(task.getRegion().front().getTerminator());

    // Rewire by operand position: one buffer may appear twice with different views.
    Operation *tiled = rw.clone(*raw);
    for (auto [i, v] : llvm::enumerate(views))
      tiled->setOperand(i, v);
    rebaseLinalgIndex(tiled, dp, c.start, rw);
  }

  rw.eraseOp(raw);
  return success();
}

struct ConvertLinalgToDhirPass
    : public mlir::dhir::impl::ConvertLinalgToDhirPassBase<
          ConvertLinalgToDhirPass> {
  using ConvertLinalgToDhirPassBase::ConvertLinalgToDhirPassBase;

  void getDependentDialects(DialectRegistry &registry) const override {
    ConvertLinalgToDhirPassBase::getDependentDialects(registry);
    registry.insert<memref::MemRefDialect, arith::ArithDialect>();
  }

  void runOnOperation() override {
    Operation *module = getOperation();

    auto devicesOr = getTargetDevices(module);
    if (failed(devicesOr) || devicesOr->empty()) {
      module->emitError("linalg-to-dhir: no target devices found");
      return signalPassFailure();
    }

    SmallVector<linalg::LinalgOp> ops;
    module->walk([&](linalg::LinalgOp op) { ops.push_back(op); });

    IRRewriter rewriter(&getContext());
    int64_t repId = nextRepId(module);
    for (linalg::LinalgOp op : ops)
      if (failed(lowerLinalgOpToTasks(op, *devicesOr, repId++, rewriter)))
        return signalPassFailure();
  }
};

} // namespace dhir
} // namespace mlir

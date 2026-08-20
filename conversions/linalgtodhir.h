#pragma once

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/IR/Builders.h"
#include "mlir/Pass/Pass.h"

#include "includes/dhirDialect.h"
#include "includes/dhirOps.h"
#include "includes/dhirTypes.h"
#include "includes/utils.h"
#include <llvm/ADT/SmallVector.h>

using namespace mlir;
using namespace dhir;

namespace mlir {
namespace dhir {

#define GEN_PASS_DEF_CONVERTLINALGTODHIRPASS
#include "dialect/Passes.h.inc"

struct ConvertLinalgToDhirPass
    : public mlir::dhir::impl::ConvertLinalgToDhirPassBase<
          ConvertLinalgToDhirPass> {
  using ConvertLinalgToDhirPassBase::ConvertLinalgToDhirPassBase;

  void runOnOperation() override {
    mlir::MLIRContext *context = &getContext();
    auto *module = getOperation();
    mlir::OpBuilder builder(context);

    llvm::SmallVector<mlir::linalg::GenericOp, 4> toReplicateVector;
    llvm::SmallVector<mlir::linalg::GenericOp, 4> toStubTaskVector;

    module->walk([&](mlir::linalg::GenericOp genericOp) {
      auto iteratorTypes = genericOp.getIteratorTypesArray();

      if (iteratorTypes.empty()) {
        llvm::errs() << "Wrapping scalar linalg.generic (no iterators) as "
                        "single unpartitioned task: "
                     << genericOp << "\n";
        toStubTaskVector.push_back(genericOp);
        return;
      }

      bool outerIsReduction =
          !iteratorTypes.empty() &&
          iteratorTypes.front() == utils::IteratorType::reduction;

      if (!outerIsReduction) {
        toReplicateVector.push_back(genericOp);
      } else {
        llvm::errs() << "Wrapping linalg.generic with reduction outer dim as "
                        "single unpartitioned task: "
                     << genericOp << "\n";
        toStubTaskVector.push_back(genericOp);
      }
    });

    int repId = 1;
    for (auto genericOp : toReplicateVector) {
      builder.setInsertionPoint(genericOp);

      llvm::SmallVector<mlir::Value> ins(genericOp.getDpsInputs());
      llvm::SmallVector<mlir::Value> outs(genericOp.getDpsInits().begin(),
                                          genericOp.getDpsInits().end());

      auto replicateOp = builder.create<mlir::dhir::ReplicateOp>(
          genericOp.getLoc(), ins, outs);
      replicateOp->setAttr("replicateID", builder.getI64IntegerAttr(repId));
      replicateOp->setAttr("pattern", builder.getStringAttr("default"));

      mlir::Region &replicateRegion = replicateOp.getBodyRegion();
      mlir::Block *newBlock = builder.createBlock(&replicateRegion);

      genericOp->moveBefore(newBlock, newBlock->end());
      builder.setInsertionPointToEnd(newBlock);
      builder.create<mlir::dhir::YieldOp>(builder.getUnknownLoc());

      ++repId;
    }

    // stub single-device TaskOp wrapping
    auto deviceVec =
        extractTargetDeviceSpecs(llvm::dyn_cast<mlir::ModuleOp>(module));
    if (deviceVec.empty()) {
      llvm::errs() << "Error: no target devices found; cannot wrap unsupported "
                      "linalg.generic ops.\n";
      return signalPassFailure();
    }

    for (auto genericOp : toStubTaskVector) {
      builder.setInsertionPoint(genericOp);

      llvm::SmallVector<mlir::Value> ins(genericOp.getDpsInputs());
      llvm::SmallVector<mlir::Value> outs(genericOp.getDpsInits().begin(),
                                          genericOp.getDpsInits().end());

      // TODO: outRanges is a placeholder {0, 0}. dhir-to-mpi's gather/broadcast
      // will need the real output extent here before the stub can run through
      // MPI lowering correctly.
      auto taskOp = builder.create<dhir::TaskOp>(
          genericOp.getLoc(), dhir::TaskRefType::get(builder.getContext()),
          deviceVec[0], ValueRange(ins), builder.getDenseI64ArrayAttr({0, 0}),
          ValueRange(outs), builder.getDenseI64ArrayAttr({0, 0}),
          ValueRange(outs));
      taskOp->setAttr("name", builder.getStringAttr("unpartitioned"));
      taskOp->setAttr("needBroadcast", builder.getBoolAttr(false));
      taskOp->setAttr("partitioned", builder.getBoolAttr(false));

      if (taskOp.getRegion().empty())
        builder.createBlock(&taskOp.getRegion());

      builder.setInsertionPointToStart(&taskOp.getRegion().front());
      genericOp->moveBefore(&taskOp.getRegion().front(),
                            taskOp.getRegion().front().end());
      builder.setInsertionPointToEnd(&taskOp.getRegion().front());
      builder.create<dhir::YieldOp>(builder.getUnknownLoc());
    }
  }
};

} // namespace dhir
} // namespace mlir

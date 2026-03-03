#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Conversion/Passes.h"

#include "includes/avialDialect.h"
#include "includes/avialTypes.h"
#include "includes/utils.h"
#include "analysis/arrayPartitionAnalysis.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/OpenMP/OpenMPDialect.h"

#include "analysis/insoutAnalysis.h"
#include "analysis/broadcastAnalysis.h"

using namespace mlir;

struct ConvertReplicateOp : public OpConversionPattern<mlir::avial::ReplicateOp>
{
    using OpConversionPattern::OpConversionPattern;

    LogicalResult matchAndRewrite(
        mlir::avial::ReplicateOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {

        mlir::Operation *module = op;
        while (module && !mlir::isa<mlir::ModuleOp>(module))
            module = module->getParentOp();

        mlir::Operation *schOp = op;
        while (schOp && !mlir::isa<mlir::avial::ScheduleOp>(schOp))
        {
            if (mlir::isa<mlir::ModuleOp>(schOp))
            {
                llvm::errs() << "Lowering Replicate Op too early! Replicate Op needs schedule op to get lowered correctly.\n";
                exit(0);
            }

            schOp = schOp->getParentOp();
        }

        auto deviceVec = extractTargetDeviceSpecs(llvm::dyn_cast<mlir::ModuleOp>(module));
        llvm::errs() << "Device Count: " << deviceVec.size();
        int64_t constupperBound = 0;
        int64_t constlowerBound = 0;
        mlir::scf::ForOp outerScfFor = nullptr;
        mlir::affine::AffineForOp outerAffineFor = nullptr;

        for (auto &innerOp : op.getBody().front().getOperations())
        {
            if (mlir::isa<mlir::scf::ForOp>(innerOp))
            {
                outerScfFor = mlir::dyn_cast<mlir::scf::ForOp>(innerOp);

                if (mlir::isa<mlir::arith::ConstantIndexOp>(outerScfFor.getUpperBound().getDefiningOp()))
                {
                    auto constUB = mlir::dyn_cast<mlir::arith::ConstantIndexOp>(outerScfFor.getUpperBound().getDefiningOp());
                    auto constLB = mlir::dyn_cast<mlir::arith::ConstantIndexOp>(outerScfFor.getLowerBound().getDefiningOp());
                    constupperBound = constUB.value();
                    constlowerBound = constLB.value();
                }
                else
                {
                    llvm::errs() << "Error: Not a constant upper bound bro!\n";
                    return failure();
                }
            }
            else if (mlir::isa<mlir::affine::AffineForOp>(innerOp))
            {
                outerAffineFor = mlir::dyn_cast<mlir::affine::AffineForOp>(innerOp);

                AffineMap ubMap = outerAffineFor.getUpperBoundMap();
                AffineMap lbMap = outerAffineFor.getLowerBoundMap();

                if (ubMap.getNumResults() == 1 && ubMap.getNumSymbols() == 0 &&
                    ubMap.getNumDims() == 0)
                {
                    if (auto constExpr = mlir::dyn_cast<AffineConstantExpr>(ubMap.getResult(0)))
                        constupperBound = constExpr.getValue();
                    else
                    {
                        llvm::errs() << "Error: Not a constant upper bound bro!\n";
                        return failure();
                    }
                }
                else
                {
                    llvm::errs() << "Error: Not a constant upper bound bro!\n";
                    return failure();
                }

                if (lbMap.getNumResults() == 1 && lbMap.getNumSymbols() == 0 &&
                    lbMap.getNumDims() == 0)
                {
                    if (auto constExpr = mlir::dyn_cast<AffineConstantExpr>(lbMap.getResult(0)))
                        constlowerBound = constExpr.getValue();
                    else
                    {
                        llvm::errs() << "Error: Not a constant lower bound bro!\n";
                        return failure();
                    }
                }
                else
                {
                    llvm::errs() << "Error: Not a constant lower bound bro!\n";
                    return failure();
                }
            }
        }

        if (!constupperBound)
        {
            llvm::errs() << "Error: Upper Bound cannot be Zero. UB: " << constupperBound << "\n";
            return failure();
        }

        int64_t ub = constupperBound;
        int64_t lb = constlowerBound;
        int64_t num_devices = deviceVec.size();
        llvm::SmallVector<mlir::avial::ArrayPartitioningInfo> arrayPartitionInfoInVec;
        llvm::SmallVector<mlir::avial::ArrayPartitioningInfo> arrayPartitionInfoOutVec;

        int64_t total_iters = ub - lb;
        int64_t base_chunk = total_iters / num_devices;
        int64_t remainder = total_iters % num_devices;

        llvm::SmallVector<mlir::Value> insVec(op.getReads().begin(),
                                              op.getReads().end());
        llvm::SmallVector<mlir::Value> outsVec(op.getWrites().begin(),
                                               op.getWrites().end());

        bool isSingleLoop = false;

        bool isStencil = false;
        if (auto stencilAttr = op->getAttrOfType<StringAttr>("pattern"))
        {
            if (stencilAttr.getValue() == "stencil")
                isStencil = true;
        }

        // Find the for loop (scf or affine) and determine if it's single or nested
        for (auto &innerOp : op.getBody().front().getOperations())
        {
            if (auto forOp = mlir::dyn_cast<mlir::scf::ForOp>(innerOp))
            {
                outerScfFor = forOp;
                isSingleLoop = true;
                for (auto &nestedOp : forOp.getBody()->getOperations())
                {
                    if (mlir::isa<mlir::scf::ForOp>(nestedOp) ||
                        mlir::isa<mlir::affine::AffineForOp>(nestedOp))
                    {
                        isSingleLoop = false;
                        break;
                    }
                }
                break;
            }
            else if (auto affineFor = mlir::dyn_cast<mlir::affine::AffineForOp>(innerOp))
            {
                outerAffineFor = affineFor;
                isSingleLoop = true;
                for (auto &nestedOp : affineFor.getBody()->getOperations())
                {
                    if (mlir::isa<mlir::scf::ForOp>(nestedOp) ||
                        mlir::isa<mlir::affine::AffineForOp>(nestedOp))
                    {
                        isSingleLoop = false;
                        break;
                    }
                }
                break;
            }
        }

        // Use whichever loop op we found as the root for array partition analysis
        mlir::Operation *outerForOp =
            outerScfFor ? outerScfFor.getOperation() : outerAffineFor ? outerAffineFor.getOperation()
                                                                      : nullptr;

        if (outerForOp)
        {
            if (isSingleLoop)
                llvm::errs() << "Analyzing 1D array partitioning (single for loop)...\n";
            else
                llvm::errs() << "Analyzing 2D array partitioning (nested for loops)...\n";

            for (Value memref : insVec)
            {
                mlir::avial::ArrayPartitioningAnalysis analysis(outerForOp);
                arrayPartitionInfoInVec.push_back(analysis.analyzeArray(memref));
            }

            for (Value memref : outsVec)
            {
                mlir::avial::ArrayPartitioningAnalysis analysis(outerForOp);
                arrayPartitionInfoOutVec.push_back(analysis.analyzeArray(memref));
            }
        }
        else
        {
            llvm::errs() << "Warning: No for loop found in schedule body\n";
        }

        llvm::SmallVector<mlir::Value> subViewIns;
        llvm::SmallVector<mlir::Value> subViewOuts;

        int64_t current = constlowerBound;
        for (int i = 0; i < num_devices; ++i)
        {
            int64_t chunk = base_chunk + (i < remainder ? 1 : 0);
            int64_t start = current;
            int64_t end = start + chunk;
            current = end;

            IRMapping mapping;
            PatternRewriter::InsertionGuard guard(rewriter);
            rewriter.setInsertionPoint(op);

            bool needBroadcast = false;

            for (int i = 0; i < (int)insVec.size(); ++i)
            {
                auto in = insVec[i];
                auto partitionInfo = arrayPartitionInfoInVec[i];

                if (partitionInfo.strategy == partitionInfo.ROW_PARTITION && !isStencil)
                {
                    auto memrefType = dyn_cast<MemRefType>(in.getType());

                    if (memrefType && memrefType.getRank() > 0)
                    {
                        auto shape = memrefType.getShape();

                        SmallVector<OpFoldResult> offsets, sizes, strides;

                        offsets.push_back(rewriter.getIndexAttr(std::max<int64_t>(0, start)));
                        for (size_t d = 1; d < shape.size(); ++d)
                            offsets.push_back(rewriter.getIndexAttr(0));

                        sizes.push_back(rewriter.getIndexAttr(chunk));
                        for (size_t d = 1; d < shape.size(); ++d)
                            sizes.push_back(rewriter.getIndexAttr(shape[d]));

                        for (size_t d = 0; d < shape.size(); ++d)
                            strides.push_back(rewriter.getIndexAttr(1));

                        auto subview = rewriter.create<memref::SubViewOp>(
                            op.getLoc(), in, offsets, sizes, strides);

                        subViewIns.push_back(subview);
                        mapping.map(in, subview);
                    }
                }
                else
                {
                    mapping.map(in, in);
                    subViewIns.push_back(in);
                }
            }

            needBroadcast = false;
            for (int i = 0; i < (int)outsVec.size(); ++i)
            {
                auto out = outsVec[i];
                auto partitionInfo = arrayPartitionInfoOutVec[i];

                if (partitionInfo.strategy == partitionInfo.ROW_PARTITION && !isStencil)
                {
                    auto memrefType = cast<MemRefType>(out.getType());
                    llvm::errs() << "Memref Type: " << memrefType << "\n";
                    auto shape = memrefType.getShape();

                    SmallVector<OpFoldResult> offsets, sizes, strides;

                    offsets.push_back(rewriter.getIndexAttr(std::max<int64_t>(0, start)));
                    for (size_t d = 1; d < shape.size(); ++d)
                        offsets.push_back(rewriter.getIndexAttr(0));

                    sizes.push_back(rewriter.getIndexAttr(chunk));
                    for (size_t d = 1; d < shape.size(); ++d)
                        sizes.push_back(rewriter.getIndexAttr(shape[d]));

                    for (size_t d = 0; d < shape.size(); ++d)
                        strides.push_back(rewriter.getIndexAttr(1));

                    auto subview = rewriter.create<memref::SubViewOp>(
                        op.getLoc(), out, offsets, sizes, strides);

                    subViewOuts.push_back(subview);
                    mapping.map(out, subview);
                }

                else
                {
                    subViewOuts.push_back(out);
                    mapping.map(out, out);
                }

                if (mlir::avial::doesOutputNeedBroadcast(op, out))
                    needBroadcast = true;
            }

            mlir::DenseI64ArrayAttr outRanges = rewriter.getDenseI64ArrayAttr({start, end});
            auto taskOp = rewriter.create<avial::TaskOp>(
                op.getLoc(),
                avial::TaskRefType::get(rewriter.getContext()),
                deviceVec[i],
                ValueRange(subViewIns), rewriter.getDenseI64ArrayAttr({0, 0}),
                ValueRange(subViewOuts), outRanges, ValueRange{outsVec});
            taskOp->setAttr("name", rewriter.getStringAttr(std::to_string(i)));
            taskOp->setAttr("needBroadcast", rewriter.getBoolAttr(needBroadcast));

            mlir::IntegerAttr repIdAttr;
            if (auto attr = op->getAttrOfType<mlir::IntegerAttr>("replicateID"))
                repIdAttr = attr;
            else
                repIdAttr = rewriter.getI32IntegerAttr(0);
            taskOp->setAttr("repId", repIdAttr);

            if (taskOp.getRegion().empty())
                rewriter.createBlock(&taskOp.getRegion());

            rewriter.setInsertionPointToStart(&taskOp.getRegion().front());

            for (auto &innerOp : op.getRegion().front().without_terminator())
            {
                auto cloned = rewriter.clone(innerOp, mapping);

                // ── scf.for ──────────────────────────────────────────────────
                if (auto clonedScfFor = mlir::dyn_cast<mlir::scf::ForOp>(cloned))
                {
                    auto ubOp = clonedScfFor.getUpperBound().getDefiningOp();
                    auto lbOp = clonedScfFor.getLowerBound().getDefiningOp();

                    if (isStencil)
                    {
                        if (mlir::isa<mlir::arith::ConstantIndexOp>(ubOp))
                        {
                            mlir::dyn_cast<mlir::arith::ConstantIndexOp>(ubOp)
                                .setValueAttr(rewriter.getIndexAttr(end));

                            mlir::dyn_cast<mlir::arith::ConstantIndexOp>(lbOp)
                                .setValueAttr(rewriter.getIndexAttr(start));
                        }

                        else
                        {
                            llvm::errs() << "Error: Not a constant upper bound!\n";
                            exit(0);
                        }
                    }
                    else
                    {
                        if (mlir::isa<mlir::arith::ConstantIndexOp>(ubOp))
                        {
                            mlir::dyn_cast<mlir::arith::ConstantIndexOp>(ubOp)
                                .setValueAttr(rewriter.getIndexAttr(chunk));

                            if (i != 0)
                                mlir::dyn_cast<mlir::arith::ConstantIndexOp>(lbOp)
                                    .setValueAttr(rewriter.getIndexAttr(0));
                        }
                    }
                    auto parallelOp = rewriter.create<scf::ParallelOp>(
                        clonedScfFor.getLoc(),
                        ValueRange{clonedScfFor.getLowerBound()},
                        ValueRange{clonedScfFor.getUpperBound()},
                        ValueRange{clonedScfFor.getStep()},
                        ValueRange{});

                    rewriter.setInsertionPointToStart(parallelOp.getBody());
                    mapping.map(clonedScfFor.getInductionVar(),
                                parallelOp.getInductionVars()[0]);

                    for (auto &bodyOp : clonedScfFor.getBody()->without_terminator())
                        rewriter.clone(bodyOp, mapping);

                    rewriter.eraseOp(clonedScfFor);
                }
                // ── affine.for ───────────────────────────────────────────────
                else if (auto clonedAffineFor = mlir::dyn_cast<mlir::affine::AffineForOp>(cloned))
                {
                    // Rewrite the bounds to [0, chunk) so each task only sees its slice.
                    // affine.for bounds live in the AffineMap, not in SSA constants,
                    // so we replace the maps directly.
                    clonedAffineFor.setLowerBoundMap(
                        AffineMap::getConstantMap(0, rewriter.getContext()));
                    clonedAffineFor.setUpperBoundMap(
                        AffineMap::getConstantMap(chunk, rewriter.getContext()));

                    // Build an scf.parallel with the same trip count so downstream
                    // lowering can parallelise it the same way as the scf.for path.
                    Value zeroVal = rewriter.create<arith::ConstantIndexOp>(
                        clonedAffineFor.getLoc(), 0);
                    Value chunkVal = rewriter.create<arith::ConstantIndexOp>(
                        clonedAffineFor.getLoc(), chunk);
                    Value stepVal = rewriter.create<arith::ConstantIndexOp>(
                        clonedAffineFor.getLoc(), clonedAffineFor.getStepAsInt());

                    auto parallelOp = rewriter.create<scf::ParallelOp>(
                        clonedAffineFor.getLoc(),
                        ValueRange{zeroVal},
                        ValueRange{chunkVal},
                        ValueRange{stepVal},
                        ValueRange{});

                    rewriter.setInsertionPointToStart(parallelOp.getBody());
                    mapping.map(clonedAffineFor.getInductionVar(),
                                parallelOp.getInductionVars()[0]);

                    for (auto &bodyOp : clonedAffineFor.getBody()->without_terminator())
                        rewriter.clone(bodyOp, mapping);

                    rewriter.eraseOp(clonedAffineFor);
                }
            }

            rewriter.setInsertionPointToEnd(&taskOp.getRegion().front());
            rewriter.create<avial::YieldOp>(rewriter.getUnknownLoc());

            subViewIns.clear();
            subViewOuts.clear();
        }

        rewriter.eraseOp(op);
        return success();
    }
};

namespace mlir
{
    namespace avial
    {
#define GEN_PASS_DEF_LOWERREPLICATEOPPASS
#include "dialect/Passes.h.inc"
        struct LowerReplicateOpPass
            : public mlir::avial::impl::LowerReplicateOpPassBase<LowerReplicateOpPass>
        {
            using LowerReplicateOpPassBase::LowerReplicateOpPassBase;

            void runOnOperation() override
            {
                mlir::MLIRContext *context = &getContext();
                auto *module = getOperation();
                ConversionTarget targetReplicateOp(getContext());

                targetReplicateOp.addLegalDialect<mlir::arith::ArithDialect>();
                targetReplicateOp.addLegalDialect<mlir::scf::SCFDialect>();
                targetReplicateOp.addLegalDialect<mlir::affine::AffineDialect>();
                targetReplicateOp.addLegalOp<mlir::avial::TaskOp>();
                targetReplicateOp.addIllegalOp<avial::ReplicateOp>();
                targetReplicateOp.addLegalOp<mlir::avial::YieldOp>();
                targetReplicateOp.addLegalDialect<mlir::memref::MemRefDialect>();

                RewritePatternSet avialpatterns(context);
                avialpatterns.add<ConvertReplicateOp>(context);

                if (failed(applyPartialConversion(module, targetReplicateOp, std::move(avialpatterns))))
                    signalPassFailure();
            }
        };
    }
}
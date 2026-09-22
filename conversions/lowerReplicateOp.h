#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Conversion/Passes.h"

#include "includes/dhirDialect.h"
#include "includes/dhirTypes.h"
#include "includes/utils.h"
#include "analysis/arrayPartitionAnalysis.h"
#include "analysis/broadcastAnalysis.h"
#include "analysis/insoutAnalysis.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/OpenMP/OpenMPDialect.h"
#include "mlir/Dialect/Utils/StaticValueUtils.h"

using namespace mlir;

static Operation *findOuterLoop(Block &body)
{
    for (Operation &inner : body.without_terminator())
        if (isa<scf::ForOp, affine::AffineForOp>(inner))
            return &inner;
    return nullptr;
}

static LogicalResult getStaticLoopBounds(Operation *loop, int64_t &lb, int64_t &ub)
{
    if (auto f = dyn_cast<scf::ForOp>(loop))
    {
        auto l = getConstantIntValue(f.getLowerBound());
        auto u = getConstantIntValue(f.getUpperBound());
        if (!l || !u)
            return loop->emitError("dhir.replicate: loop bounds must be constants");
        if (f.getNumResults() != 0)
            return loop->emitError("dhir.replicate: loops with iter_args are not supported");
        lb = *l;
        ub = *u;
        return success();
    }
    auto a = cast<affine::AffineForOp>(loop);
    if (!a.hasConstantLowerBound() || !a.hasConstantUpperBound())
        return loop->emitError("dhir.replicate: loop bounds must be constants");
    lb = a.getConstantLowerBound();
    ub = a.getConstantUpperBound();
    return success();
}

struct ConvertReplicateOp : public OpConversionPattern<mlir::dhir::ReplicateOp>
{
    using OpConversionPattern::OpConversionPattern;

    LogicalResult matchAndRewrite(
        mlir::dhir::ReplicateOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {
        if (!op->getParentOfType<mlir::dhir::ScheduleOp>())
            return op.emitError("dhir.replicate lowered before being nested in dhir.schedule");

        auto devicesOr = getTargetDevices(op);
        if (failed(devicesOr))
            return failure();

        Block &body = op.getRegion().front();
        Operation *outerLoop = findOuterLoop(body);
        if (!outerLoop)
            return op.emitError("dhir.replicate body has no scf.for/affine.for");

        int64_t lb = 0, ub = 0;
        if (failed(getStaticLoopBounds(outerLoop, lb, ub)))
            return failure();

        auto chunksOr = computeCostBasedChunks(op, *devicesOr, lb, ub);
        if (failed(chunksOr))
            return failure();

        llvm::SmallVector<mlir::Value> insVec(op.getReads().begin(), op.getReads().end());
        llvm::SmallVector<mlir::Value> outsVec(op.getWrites().begin(), op.getWrites().end());

        bool isStencil = false;
        if (auto a = op->getAttrOfType<StringAttr>("pattern"))
            isStencil = a.getValue() == "stencil";

        llvm::SmallVector<mlir::dhir::ArrayPartitioningInfo> inInfo, outInfo;
        for (Value m : insVec)
        {
            mlir::dhir::ArrayPartitioningAnalysis analysis(outerLoop);
            inInfo.push_back(analysis.analyzeArray(m));
        }
        for (Value m : outsVec)
        {
            mlir::dhir::ArrayPartitioningAnalysis analysis(outerLoop);
            outInfo.push_back(analysis.analyzeArray(m));
        }

        bool needBroadcast = false;
        for (Value out : outsVec)
            if (mlir::dhir::doesOutputNeedBroadcast(op, out))
                needBroadcast = true;

        IntegerAttr repIdAttr;
        if (auto a = op->getAttrOfType<IntegerAttr>("replicateID"))
            repIdAttr = a;
        else
            repIdAttr = rewriter.getI32IntegerAttr(0);

        Location loc = op.getLoc();
        const auto rowPartition = mlir::dhir::ArrayPartitioningInfo::ROW_PARTITION;

        for (const DeviceChunk &c : *chunksOr)
        {
            OpBuilder::InsertionGuard guard(rewriter);
            rewriter.setInsertionPoint(op);
            int64_t chunk = c.end - c.start;

            IRMapping mapping;
            TaskSpec spec;
            spec.device = c.device;
            spec.outStart = c.start;
            spec.outEnd = c.end;
            spec.repId = repIdAttr;
            spec.needBroadcast = needBroadcast;
            spec.name = std::to_string(c.deviceIndex);

            for (size_t i = 0; i < insVec.size(); ++i)
            {
                Value v = insVec[i];
                if (inInfo[i].strategy == rowPartition && !isStencil)
                    v = makeSliceAlongDim(rewriter, loc, insVec[i], 0, c.start, chunk);
                mapping.map(insVec[i], v);
                spec.reads.push_back(v);
            }
            for (size_t i = 0; i < outsVec.size(); ++i)
            {
                Value v = outsVec[i];
                if (outInfo[i].strategy == rowPartition && !isStencil)
                    v = makeSliceAlongDim(rewriter, loc, outsVec[i], 0, c.start, chunk);
                mapping.map(outsVec[i], v);
                spec.writes.push_back(v);
            }
            spec.bases = outsVec;

            auto task = createTaskShell(rewriter, loc, spec);
            rewriter.setInsertionPoint(task.getRegion().front().getTerminator());

            for (Operation &inner : body.without_terminator())
            {
                if (&inner != outerLoop)
                {
                    rewriter.clone(inner, mapping);
                    continue;
                }

                // Partitioned arrays are subviews, so they iterate [0, chunk); stencils index full arrays.
                Value stepV;
                Block *loopBody;
                Value iv;
                if (auto f = dyn_cast<scf::ForOp>(inner))
                {
                    stepV = mapping.lookupOrDefault(f.getStep());
                    loopBody = f.getBody();
                    iv = f.getInductionVar();
                }
                else
                {
                    auto a = cast<affine::AffineForOp>(inner);
                    stepV = rewriter.create<arith::ConstantIndexOp>(loc, a.getStepAsInt());
                    loopBody = a.getBody();
                    iv = a.getInductionVar();
                }
                Value lbV = rewriter.create<arith::ConstantIndexOp>(loc, isStencil ? c.start : 0);
                Value ubV = rewriter.create<arith::ConstantIndexOp>(loc, isStencil ? c.end : chunk);

                auto par = rewriter.create<scf::ParallelOp>(
                    loc, ValueRange{lbV}, ValueRange{ubV}, ValueRange{stepV}, ValueRange{});
                {
                    OpBuilder::InsertionGuard g(rewriter);
                    rewriter.setInsertionPointToStart(par.getBody());
                    mapping.map(iv, par.getInductionVars()[0]);
                    for (Operation &b : loopBody->without_terminator())
                        rewriter.clone(b, mapping);
                }
            }
        }

        rewriter.eraseOp(op);
        return success();
    }
};

namespace mlir
{
    namespace dhir
    {
#define GEN_PASS_DEF_LOWERREPLICATEOPPASS
#include "dialect/Passes.h.inc"
        struct LowerReplicateOpPass
            : public mlir::dhir::impl::LowerReplicateOpPassBase<LowerReplicateOpPass>
        {
            using LowerReplicateOpPassBase::LowerReplicateOpPassBase;

            void runOnOperation() override
            {
                mlir::MLIRContext *context = &getContext();
                auto *module = getOperation();
                ConversionTarget target(getContext());

                target.addLegalDialect<mlir::arith::ArithDialect>();
                target.addLegalDialect<mlir::scf::SCFDialect>();
                target.addLegalDialect<mlir::affine::AffineDialect>();
                target.addLegalOp<mlir::dhir::TaskOp>();
                target.addIllegalOp<dhir::ReplicateOp>();
                target.addLegalOp<mlir::dhir::YieldOp>();
                target.addLegalDialect<mlir::memref::MemRefDialect>();

                RewritePatternSet patterns(context);
                patterns.add<ConvertReplicateOp>(context);

                if (failed(applyPartialConversion(module, target, std::move(patterns))))
                    signalPassFailure();
            }
        };
    }
}

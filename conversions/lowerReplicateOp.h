#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Conversion/Passes.h"

#include "includes/dhirDialect.h"
#include "includes/dhirTypes.h"
#include "includes/utils.h"
#include "analysis/arrayPartitionAnalysis.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/OpenMP/OpenMPDialect.h"

#include "analysis/insoutAnalysis.h"
#include "analysis/broadcastAnalysis.h"

#include <cmath>
#include <limits>
#include <map>
#include <set>

using namespace mlir;

struct ConvertReplicateOp : public OpConversionPattern<mlir::dhir::ReplicateOp>
{
    using OpConversionPattern::OpConversionPattern;

    LogicalResult matchAndRewrite(
        mlir::dhir::ReplicateOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {

        mlir::Operation *module = op;
        while (module && !mlir::isa<mlir::ModuleOp>(module))
            module = module->getParentOp();

        mlir::Operation *schOp = op;
        while (schOp && !mlir::isa<mlir::dhir::ScheduleOp>(schOp))
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
        bool foundOuterLoop = false;

        for (auto &innerOp : op.getBody().front().getOperations())
        {
            if (mlir::isa<mlir::scf::ForOp>(innerOp))
            {
                if (foundOuterLoop)
                {
                    llvm::errs() << "Error: Replicate body has multiple top-level loops; cannot choose a single partitioning loop\n";
                    return failure();
                }
                outerScfFor = mlir::dyn_cast<mlir::scf::ForOp>(innerOp);
                foundOuterLoop = true;

                if (mlir::isa<mlir::arith::ConstantIndexOp>(outerScfFor.getUpperBound().getDefiningOp()) &&
                    mlir::isa<mlir::arith::ConstantIndexOp>(outerScfFor.getLowerBound().getDefiningOp()))
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

                if (outerScfFor.getStep().getDefiningOp() == nullptr ||
                    !mlir::isa<mlir::arith::ConstantIndexOp>(outerScfFor.getStep().getDefiningOp()) ||
                    mlir::cast<mlir::arith::ConstantIndexOp>(outerScfFor.getStep().getDefiningOp()).value() != 1)
                {
                    llvm::errs() << "Error: Only unit-step scf.for loops can be partitioned\n";
                    return failure();
                }
            }
            else if (mlir::isa<mlir::affine::AffineForOp>(innerOp))
            {
                if (foundOuterLoop)
                {
                    llvm::errs() << "Error: Replicate body has multiple top-level loops; cannot choose a single partitioning loop\n";
                    return failure();
                }
                outerAffineFor = mlir::dyn_cast<mlir::affine::AffineForOp>(innerOp);
                foundOuterLoop = true;

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

                if (outerAffineFor.getStepAsInt() != 1)
                {
                    llvm::errs() << "Error: Only unit-step affine.for loops can be partitioned\n";
                    return failure();
                }
            }
        }

        if (!foundOuterLoop)
        {
            llvm::errs() << "Error: Replicate body does not contain a supported top-level loop\n";
            return failure();
        }

        int64_t ub = constupperBound;
        int64_t lb = constlowerBound;
        int64_t num_devices = deviceVec.size();
        if (num_devices == 0)
        {
            llvm::errs() << "Error: No target devices are configured\n";
            return failure();
        }
        if (ub < lb)
        {
            llvm::errs() << "Error: Replicate loop upper bound is below its lower bound\n";
            return failure();
        }
        llvm::SmallVector<mlir::dhir::ArrayPartitioningInfo> arrayPartitionInfoInVec;
        llvm::SmallVector<mlir::dhir::ArrayPartitioningInfo> arrayPartitionInfoOutVec;

        __int128 totalItersWide = static_cast<__int128>(ub) - static_cast<__int128>(lb);
        if (totalItersWide > std::numeric_limits<int64_t>::max())
        {
            llvm::errs() << "Error: Replicate loop iteration count is too large\n";
            return failure();
        }
        int64_t total_iters = static_cast<int64_t>(totalItersWide);

        // weight = 1/cost for each node, cost cannot be 0
        std::vector<double> weights;
        double weight_sum = 0.0;

        for (int i = 0; i < num_devices; i++)
        {
            double cost = 1.0;
            if (auto costAttr = mlir::dyn_cast<mlir::FloatAttr>(getDeviceAttribute(deviceVec[i], "cost")))
            {
                cost = costAttr.getValue().convertToDouble();
            }

            if (!std::isfinite(cost) || cost <= 0.0)
            {
                llvm::errs() << "Error: device cost must be finite and > 0\n";
                return failure();
            }

            double weight = 1.0 / cost;
            weights.push_back(weight);
            weight_sum += weight;
        }

        if (!std::isfinite(weight_sum) || weight_sum <= 0.0)
        {
            llvm::errs() << "Error: device costs produce an invalid shard weighting\n";
            return failure();
        }

        std::vector<int64_t> chunk_sizes;
        int64_t assigned_iters = 0;

        for (int i = 0; i < num_devices; i++)
        {
            int64_t chunk = static_cast<int64_t>(
                (weights[i] / weight_sum) * static_cast<double>(total_iters));
            chunk_sizes.push_back(chunk);
            assigned_iters += chunk;
        }

        // handle remainder iterations by adding 1 iteration to each device till all remainder iterations are assigned
        int64_t remainder = total_iters - assigned_iters;
        if (remainder < 0 || remainder >= num_devices)
        {
            llvm::errs() << "Error: shard weighting did not produce a valid remainder\n";
            return failure();
        }

        for (int i = 0; i < remainder; i++)
        {
            chunk_sizes[i % num_devices]++;
        }

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
                mlir::dhir::ArrayPartitioningAnalysis analysis(outerForOp, (outerScfFor ? outerScfFor.getInductionVar() : outerAffineFor.getInductionVar()));
                arrayPartitionInfoInVec.push_back(analysis.analyzeArray(memref));
            }

            for (Value memref : outsVec)
            {
                mlir::dhir::ArrayPartitioningAnalysis analysis(outerForOp, (outerScfFor ? outerScfFor.getInductionVar() : outerAffineFor.getInductionVar()));
                arrayPartitionInfoOutVec.push_back(analysis.analyzeArray(memref));
            }
        }
        else
        {
            llvm::errs() << "Warning: No for loop found in schedule body\n";
        }

        // R1: Check for per-access rebasing
        bool hasUnslicedAccessOnPartitionedIV = false;
        Value partitionedIV = outerForOp ? 
            (outerScfFor ? outerScfFor.getInductionVar() : outerAffineFor.getInductionVar()) 
            : nullptr;

        if (partitionedIV) {
            mlir::dhir::ArrayPartitioningAnalysis analysis(outerForOp, partitionedIV);
            
            auto checkAccess = [&](Value memref, mlir::Operation* nestedOp) {
                // Local scratch buffers are cloned into every task and do not
                // participate in the replicate operand rebasing contract.
                bool isReplicateOperand = false;
                for (Value input : insVec)
                    isReplicateOperand |= input == memref;
                for (Value output : outsVec)
                    isReplicateOperand |= output == memref;
                if (!isReplicateOperand)
                    return;

                bool isSliced = false;
                for (size_t i = 0; i < insVec.size(); ++i) {
                    if (insVec[i] == memref && arrayPartitionInfoInVec[i].strategy == mlir::dhir::ArrayPartitioningInfo::ROW_PARTITION)
                        isSliced = true;
                }
                for (size_t i = 0; i < outsVec.size(); ++i) {
                    if (outsVec[i] == memref && arrayPartitionInfoOutVec[i].strategy == mlir::dhir::ArrayPartitioningInfo::ROW_PARTITION)
                        isSliced = true;
                }
                if (isSliced) return;

                if (analysis.getDimensionForIV(nestedOp, partitionedIV) >= 0) {
                    hasUnslicedAccessOnPartitionedIV = true;
                }
            };
            
            op.getBody().front().walk([&](mlir::Operation* nestedOp) {
                if (auto load = dyn_cast<mlir::affine::AffineLoadOp>(nestedOp)) checkAccess(load.getMemRef(), nestedOp);
                else if (auto store = dyn_cast<mlir::affine::AffineStoreOp>(nestedOp)) checkAccess(store.getMemRef(), nestedOp);
                else if (auto load = dyn_cast<mlir::memref::LoadOp>(nestedOp)) checkAccess(load.getMemRef(), nestedOp);
                else if (auto store = dyn_cast<mlir::memref::StoreOp>(nestedOp)) checkAccess(store.getMemRef(), nestedOp);
            });

            if (hasUnslicedAccessOnPartitionedIV) {
                llvm::errs() << "Found unsliced access on partitioned IV. Falling back to NO_PARTITION for all arrays to prevent partial rebasing.\n";
                for (auto &info : arrayPartitionInfoInVec) info.strategy = mlir::dhir::ArrayPartitioningInfo::NO_PARTITION;
                for (auto &info : arrayPartitionInfoOutVec) info.strategy = mlir::dhir::ArrayPartitioningInfo::NO_PARTITION;
            }
        }

        llvm::SmallVector<mlir::Value> subViewIns;
        llvm::SmallVector<mlir::Value> subViewOuts;

        int64_t current = constlowerBound;
        for (int i = 0; i < num_devices; ++i)
        {
            int64_t chunk = chunk_sizes[i];
            int64_t start = current;
            int64_t end = start + chunk;
            current = end;

            IRMapping mapping;
            PatternRewriter::InsertionGuard guard(rewriter);
            rewriter.setInsertionPoint(op);

            bool needBroadcast = false;

            // Tracks whether any operand was replaced by a subview along the
            // partitioned dimension. If so the task body indexes the slice from
            // 0, so the loop must run over [0, chunk). If nothing was
            // subviewed the task still indexes the full array, so the loop must
            // run over the absolute range [start, end).
            bool indicesRebased = false;

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
                        indicesRebased = true;
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
                    indicesRebased = true;
                }

                else
                {
                    subViewOuts.push_back(out);
                    mapping.map(out, out);
                }

                if (mlir::dhir::doesOutputNeedBroadcast(op, out))
                    needBroadcast = true;
            }

            mlir::DenseI64ArrayAttr outRanges = rewriter.getDenseI64ArrayAttr({start, end});
            auto taskOp = rewriter.create<dhir::TaskOp>(
                op.getLoc(),
                dhir::TaskRefType::get(rewriter.getContext()),
                deviceVec[i],
                ValueRange(subViewIns), rewriter.getDenseI64ArrayAttr({0, 0}),
                ValueRange(subViewOuts), outRanges, ValueRange{outsVec});
            taskOp->setAttr("name", rewriter.getStringAttr(std::to_string(i)));
            taskOp->setAttr("needBroadcast", rewriter.getBoolAttr(needBroadcast));

            mlir::IntegerAttr repIdAttr;
            if (auto attr = op->getAttrOfType<mlir::IntegerAttr>("replicateID"))
                repIdAttr = attr;
            else
            {
                llvm::errs() << "Error: ReplicateOp is missing replicateID\n";
                return failure();
            }
            taskOp->setAttr("repId", repIdAttr);
            taskOp->setAttr("shardGroup", repIdAttr);

            if (taskOp.getRegion().empty())
                rewriter.createBlock(&taskOp.getRegion());

            rewriter.setInsertionPointToStart(&taskOp.getRegion().front());

            //   rebased  -> [0,chunk)
            //   otherwise -> [start,end), global
            // The second case covers any replicate who uses NO_PARTITION
            const int64_t loopLb = indicesRebased ? 0 : start;
            const int64_t loopUb = indicesRebased ? chunk : end;

            if (!indicesRebased)
                llvm::errs() << "No operand was partitioned; task " << i
                             << " iterates the absolute range [" << loopLb << ", "
                             << loopUb << ")\n";

            for (auto &innerOp : op.getRegion().front().without_terminator())
            {
                auto cloned = rewriter.clone(innerOp, mapping);

                // -- scf.for --
                if (auto clonedScfFor = mlir::dyn_cast<mlir::scf::ForOp>(cloned))
                {
                    auto ubOp = clonedScfFor.getUpperBound().getDefiningOp();
                    auto lbOp = clonedScfFor.getLowerBound().getDefiningOp();

                    if (!mlir::isa_and_nonnull<mlir::arith::ConstantIndexOp>(ubOp) ||
                        !mlir::isa_and_nonnull<mlir::arith::ConstantIndexOp>(lbOp))
                    {
                        llvm::errs() << "Error: Not a constant loop bound!\n";
                        return failure();
                    }
                    // Emit fresh independent constants for loop bounds,
                    // otherwise overwriting causes bugs
                    // Eg: operand (a [1, N) loop with step 1 shares the value),
                    // overwriting it in place would silently rewrite the step also
                    Value lbVal = rewriter.create<arith::ConstantIndexOp>(
                        clonedScfFor.getLoc(), loopLb);
                    Value ubVal = rewriter.create<arith::ConstantIndexOp>(
                        clonedScfFor.getLoc(), loopUb);

                    auto parallelOp = rewriter.create<scf::ParallelOp>(
                        clonedScfFor.getLoc(),
                        ValueRange{lbVal},
                        ValueRange{ubVal},
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
                    // Applied the exact same [loopLb, loopUb) logic to the
                    // affine.for lowering path by updating its AffineMaps
                    clonedAffineFor.setLowerBoundMap(
                        AffineMap::getConstantMap(loopLb, rewriter.getContext()));
                    clonedAffineFor.setUpperBoundMap(
                        AffineMap::getConstantMap(loopUb, rewriter.getContext()));

                    // Build an scf.parallel with the same trip count so downstream
                    // lowering can parallelise it the same way as the scf.for path.
                    Value lbVal = rewriter.create<arith::ConstantIndexOp>(
                        clonedAffineFor.getLoc(), loopLb);
                    Value ubVal = rewriter.create<arith::ConstantIndexOp>(
                        clonedAffineFor.getLoc(), loopUb);
                    Value stepVal = rewriter.create<arith::ConstantIndexOp>(
                        clonedAffineFor.getLoc(), clonedAffineFor.getStepAsInt());

                    auto parallelOp = rewriter.create<scf::ParallelOp>(
                        clonedAffineFor.getLoc(),
                        ValueRange{lbVal},
                        ValueRange{ubVal},
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
            rewriter.create<dhir::YieldOp>(rewriter.getUnknownLoc());

            subViewIns.clear();
            subViewOuts.clear();
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

                std::map<mlir::Operation *, std::set<int64_t>> scheduleReplicateIds;
                bool invalidReplicateId = false;
                module->walk([&](mlir::dhir::ReplicateOp replicate) {
                    auto schedule = replicate->getParentOfType<mlir::dhir::ScheduleOp>();
                    auto idAttr = replicate->getAttrOfType<mlir::IntegerAttr>("replicateID");
                    if (!schedule || !idAttr || idAttr.getInt() < 0)
                    {
                        replicate.emitError("must have a non-negative replicateID and be nested in a ScheduleOp");
                        invalidReplicateId = true;
                        return;
                    }

                    auto &ids = scheduleReplicateIds[schedule.getOperation()];
                    if (!ids.insert(idAttr.getInt()).second)
                    {
                        replicate.emitError("duplicate replicateID in one schedule");
                        invalidReplicateId = true;
                    }
                });
                if (invalidReplicateId)
                {
                    signalPassFailure();
                    return;
                }

                ConversionTarget targetReplicateOp(getContext());

                targetReplicateOp.addLegalDialect<mlir::arith::ArithDialect>();
                targetReplicateOp.addLegalDialect<mlir::scf::SCFDialect>();
                targetReplicateOp.addLegalDialect<mlir::affine::AffineDialect>();
                targetReplicateOp.addLegalOp<mlir::dhir::TaskOp>();
                targetReplicateOp.addIllegalOp<dhir::ReplicateOp>();
                targetReplicateOp.addLegalOp<mlir::dhir::YieldOp>();
                targetReplicateOp.addLegalDialect<mlir::memref::MemRefDialect>();

                RewritePatternSet dhirpatterns(context);
                dhirpatterns.add<ConvertReplicateOp>(context);

                if (failed(applyPartialConversion(module, targetReplicateOp, std::move(dhirpatterns))))
                    signalPassFailure();
            }
        };
    }
}

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

// Right Now we just have Replicate Op to be lowered to another dhir op.
// In future, we might need to change the name , if more ops has to be converted to
// same dhir dialect op but lower abstraction.

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

        /*
            InsOutsAnalysis
            Add Desc
        */

        // InsOutsAnalysis insoutAnalysis(schOp);
        // insoutAnalysis.print(llvm::errs());

        // End of InsOutAnalysis

        auto deviceVec = extractTargetDeviceSpecs(llvm::dyn_cast<mlir::ModuleOp>(module));
        llvm::errs() << "Device Count: "<< deviceVec.size();
        int64_t constupperBound = 0;
        mlir::scf::ForOp outerFor = nullptr;

        for (auto &innerOp : op.getBody().front().getOperations())
        {
            if (mlir::isa<mlir::scf::ForOp>(innerOp))
            {
                outerFor = mlir::dyn_cast<mlir::scf::ForOp>(innerOp);

                // Array Partition Analysis

                if (mlir::isa<mlir::arith::ConstantIndexOp>(outerFor.getUpperBound().getDefiningOp()))
                {
                    auto constUB = mlir::dyn_cast<mlir::arith::ConstantIndexOp>(outerFor.getUpperBound().getDefiningOp());
                    constupperBound = constUB.value();
                }
                else
                {
                    llvm::errs() << "Error: Not a constant upper bound bro!\n";
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
        int64_t num_devices = deviceVec.size();
        llvm::SmallVector<mlir::avial::ArrayPartitioningInfo> arrayPartitionInfoVec;

        int64_t total_iters = ub;
        int64_t base_chunk = total_iters / num_devices;
        int64_t remainder = total_iters % num_devices;

        llvm::SmallVector<mlir::Value> insVec(op.getReads().begin(),
                                              op.getReads().end());
        llvm::SmallVector<mlir::Value> outsVec(op.getWrites().begin(),
                                               op.getWrites().end());

        

        // Array Partition Analysis
        for (auto &innerOp : op.getBody().front().getOperations())
        {
            if (mlir::isa<mlir::scf::ForOp>(innerOp))
            {
                outerFor = mlir::dyn_cast<mlir::scf::ForOp>(innerOp);

                // Analyze each output memref
                for (Value memref : insVec)
                {
                    mlir::avial::ArrayPartitioningAnalysis analysis(outerFor);
                    auto partitionInfo = analysis.analyzeArray(memref);
                    arrayPartitionInfoVec.push_back(partitionInfo);
                }

                for (Value memref : outsVec)
                {
                    mlir::avial::ArrayPartitioningAnalysis analysis(outerFor);
                    auto partitionInfo = analysis.analyzeArray(memref);
                    arrayPartitionInfoVec.push_back(partitionInfo);
                }
            }
        }

        llvm::SmallVector<mlir::Value> subViewIns;
        llvm::SmallVector<mlir::Value> subViewOuts;

        int64_t current = 0;
        for (int i = 0; i < num_devices; ++i)
        {
            int64_t chunk = base_chunk + (i < remainder ? 1 : 0); // distribute remainder
            int64_t start = current;
            int64_t end = start + chunk;
            current = end;

            IRMapping mapping;
            PatternRewriter::InsertionGuard guard(rewriter);
            rewriter.setInsertionPoint(op);

            // TODO:  Take this device's DLTI. So that we can generate gpu.alloc() correctly.

            bool needBroadcast = false;

            // Create Subviews and add It to local Mappings.
            for (int i = 0; i < insVec.size(); ++i)
            {
                auto in = insVec[i];
                auto partitionInfo = arrayPartitionInfoVec[i];

                if (partitionInfo.strategy == partitionInfo.ROW_PARTITION)
                {
                    auto memrefType = dyn_cast<MemRefType>(in.getType());
                    if (memrefType && memrefType.getRank() > 0)
                    {
                        // Create subview for input (if it's split along first dimension)
                        auto shape = memrefType.getShape();

                        SmallVector<OpFoldResult> offsets, sizes, strides;

                        offsets.push_back(rewriter.getIndexAttr(start));
                        for (size_t d = 1; d < shape.size(); ++d)
                        {
                            offsets.push_back(rewriter.getIndexAttr(0));
                        }

                        sizes.push_back(rewriter.getIndexAttr(chunk));
                        for (size_t d = 1; d < shape.size(); ++d)
                        {
                            sizes.push_back(rewriter.getIndexAttr(shape[d]));
                        }

                        for (size_t d = 0; d < shape.size(); ++d)
                        {
                            strides.push_back(rewriter.getIndexAttr(1));
                        }

                        auto subview = rewriter.create<memref::SubViewOp>(
                            op.getLoc(), in, offsets, sizes, strides);

                        subViewIns.push_back(subview);
                        mapping.map(in, subview);

                        llvm::errs() << "Hi\n";
                    }
                }
                else
                {
                    mapping.map(in,in);
                    subViewIns.push_back(in);
                }
            }

            needBroadcast = false;
            for (auto out : outsVec)
            {
                auto memrefType = cast<MemRefType>(out.getType());
                auto shape = memrefType.getShape();

                SmallVector<OpFoldResult> offsets, sizes, strides;

                offsets.push_back(rewriter.getIndexAttr(start));
                for (size_t d = 1; d < shape.size(); ++d)
                {
                    offsets.push_back(rewriter.getIndexAttr(0));
                }

                sizes.push_back(rewriter.getIndexAttr(chunk));
                for (size_t d = 1; d < shape.size(); ++d)
                {
                    sizes.push_back(rewriter.getIndexAttr(shape[d]));
                }

                for (size_t d = 0; d < shape.size(); ++d)
                {
                    strides.push_back(rewriter.getIndexAttr(1));
                }

                auto subview = rewriter.create<memref::SubViewOp>(
                    op.getLoc(), out, offsets, sizes, strides);

                subViewOuts.push_back(subview);
                mapping.map(out, subview);
             
                if(mlir::avial::doesOutputNeedBroadcast(op,out))
                    needBroadcast = true;

            }



            // Check if this task's output is being used somewhere? after this task.
            // If yes, check if that access needs partitoning or not. If no partition,
            // then we have  to broadcast, so that all nodes will get the processed data. 
            

        

            
            mlir::DenseI64ArrayAttr outRanges = rewriter.getDenseI64ArrayAttr({start, end});
            auto taskOp = rewriter.create<avial::TaskOp>(
                op.getLoc(),
                avial::TaskRefType::get(rewriter.getContext()),
                deviceVec[i],
                ValueRange(subViewIns), rewriter.getDenseI64ArrayAttr({0, 0}), ValueRange(subViewOuts), outRanges, ValueRange{outsVec});
            taskOp->setAttr("name", rewriter.getStringAttr(std::to_string(i)));

            // Broadcast Stuff
            if(needBroadcast)
                taskOp->setAttr("needBroadcast",rewriter.getBoolAttr(true));
            else
                taskOp->setAttr("needBroadcast",rewriter.getBoolAttr(false));

            mlir::IntegerAttr repIdAttr;
            if (auto attr = op->getAttrOfType<mlir::IntegerAttr>("replicateID"))
                repIdAttr = attr;
            else
                repIdAttr = rewriter.getI32IntegerAttr(0);

            taskOp->setAttr("repId", repIdAttr);

            if (taskOp.getRegion().empty())
                rewriter.createBlock(&taskOp.getRegion());

            // Change insertion point to the start of the new block
            rewriter.setInsertionPointToStart(&taskOp.getRegion().front());

            // Create some ops in the task region
            for (auto &innerOp : op.getRegion().front().without_terminator())
            {
                auto cloned = rewriter.clone(innerOp, mapping);
                if (mlir::isa<mlir::scf::ForOp>(cloned))
                {
                    scf::ForOp outerFor = mlir::dyn_cast<mlir::scf::ForOp>(cloned);

                    auto ub = outerFor.getUpperBound().getDefiningOp();
                    auto lb = outerFor.getLowerBound().getDefiningOp();
                    if (mlir::isa<mlir::arith::ConstantIndexOp>(ub))
                    {
                        mlir::arith::ConstantIndexOp constUBIdx = mlir::dyn_cast<mlir::arith::ConstantIndexOp>(ub);
                        mlir::arith::ConstantIndexOp constLBIdx = mlir::dyn_cast<mlir::arith::ConstantIndexOp>(lb);

                        constUBIdx.setValueAttr(rewriter.getIndexAttr(chunk));
                        constLBIdx.setValueAttr(rewriter.getIndexAttr(0));
                    }

                    // Let's create the parallel Op
                    auto parallelOp = rewriter.create<scf::ParallelOp>(outerFor.getLoc(),
                                                                       ValueRange{mlir::dyn_cast<mlir::arith::ConstantIndexOp>(lb)},
                                                                       ValueRange{mlir::dyn_cast<mlir::arith::ConstantIndexOp>(ub)},
                                                                       ValueRange{outerFor.getStep()},
                                                                       ValueRange{});

                    rewriter.setInsertionPointToStart(parallelOp.getBody());
                    mapping.map(outerFor.getInductionVar(), parallelOp.getInductionVars()[0]);

                    for (auto &bodyOp : outerFor.getBody()->without_terminator())
                        rewriter.clone(bodyOp, mapping);

                    rewriter.eraseOp(outerFor);
                }
            }

            rewriter.setInsertionPointToEnd(&taskOp.getRegion().front());
            rewriter.create<avial::YieldOp>(rewriter.getUnknownLoc());

            subViewIns.clear();
            subViewOuts.clear();
        }

        rewriter.eraseOp(op); // Erase the old op safely

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
                {
                    signalPassFailure();
                }
            }
        };

    }
}
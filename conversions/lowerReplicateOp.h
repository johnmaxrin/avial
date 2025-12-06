#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Conversion/Passes.h"

#include "includes/avialDialect.h"
#include "includes/avialTypes.h"
#include "includes/utils.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/OpenMP/OpenMPDialect.h"

#include "analysis/insoutAnalysis.h"

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

        InsOutsAnalysis insoutAnalysis(schOp);
        insoutAnalysis.print(llvm::errs());

        // End of InsOutAnalysis

        auto deviceVec = extractTargetDeviceSpecs(llvm::dyn_cast<mlir::ModuleOp>(module));
        auto &replicateRegion = op.getRegion();
        auto &replicateBody = replicateRegion.front();

        auto archAttr = rewriter.getStringAttr("arch"); // Use the Module Attrs
        auto archVal = rewriter.getStringAttr("sm_90");
        auto entry1 = mlir::DataLayoutEntryAttr::get(archAttr, archVal);
        auto targetDlti = mlir::TargetDeviceSpecAttr::get(op.getContext(), {entry1});

        int64_t constupperBound = 0;
        mlir::scf::ForOp outerFor = nullptr;

        for (auto &innerOp : op.getBody().front().getOperations())
        {
            if (mlir::isa<mlir::scf::ForOp>(innerOp))
            {
                outerFor = mlir::dyn_cast<mlir::scf::ForOp>(innerOp);
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

        int64_t total_iters = ub;
        int64_t base_chunk = total_iters / num_devices;
        int64_t remainder = total_iters % num_devices;

        llvm::SmallVector<mlir::Value> insVec(insoutAnalysis.ins.begin(),
                                              insoutAnalysis.ins.end());
        llvm::SmallVector<mlir::Value> outsVec(insoutAnalysis.outs.begin(),
                                               insoutAnalysis.outs.end());

        int64_t current = 0;
        for (int i = 0; i < num_devices; ++i)
        {
            int64_t chunk = base_chunk + (i < remainder ? 1 : 0); // distribute remainder
            int64_t start = current;
            int64_t end = start + chunk;
            current = end;

            IRMapping mapping;
            PatternRewriter::InsertionGuard guard(rewriter);
            rewriter.setInsertionPointAfter(op);

            mlir::DenseI64ArrayAttr outRanges = rewriter.getDenseI64ArrayAttr({start, end});
            auto taskOp = rewriter.create<avial::TaskOp>(
                op.getLoc(),
                avial::TaskRefType::get(rewriter.getContext()),
                targetDlti,
                ValueRange(insVec), rewriter.getDenseI64ArrayAttr({0, 0}), ValueRange(outsVec), outRanges);
            taskOp->setAttr("name", rewriter.getStringAttr(std::to_string(i)));

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
                mlir:
                    scf::ForOp outerFor = mlir::dyn_cast<mlir::scf::ForOp>(cloned);
                    auto ub = outerFor.getUpperBound().getDefiningOp();
                    auto lb = outerFor.getLowerBound().getDefiningOp();
                    if (mlir::isa<mlir::arith::ConstantIndexOp>(ub))
                    {
                        mlir::arith::ConstantIndexOp constUBIdx = mlir::dyn_cast<mlir::arith::ConstantIndexOp>(ub);
                        mlir::arith::ConstantIndexOp constLBIdx = mlir::dyn_cast<mlir::arith::ConstantIndexOp>(lb);

                        constUBIdx.setValueAttr(rewriter.getIndexAttr(end));
                        constLBIdx.setValueAttr(rewriter.getIndexAttr(start));
                    }
                }
            }

            rewriter.create<avial::YieldOp>(rewriter.getUnknownLoc());
        }

        rewriter.eraseOp(op); // Erase the old op safely

        // module->dumpPretty();

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
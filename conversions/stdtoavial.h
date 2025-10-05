#include "mlir/Pass/PassManager.h"
#include "mlir/IR/PatternMatch.h"

#include "includes/avialDialect.h"
#include "includes/avialTypes.h"

#include "mlir/Transforms/DialectConversion.h"

#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/Passes.h"

#include "llvm/Support/Casting.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"

#include "includes/avialDialect.h"
#include "includes/avialOps.h"
#include "includes/avialTypes.h"

#include "includes/utils.h"

#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/IR/Builders.h"

#include "mlir/Conversion/Passes.h"


#include <string>

using namespace mlir;
using namespace avial;

struct ConvertToAvial : public OpConversionPattern<mlir::func::FuncOp>
{
    using OpConversionPattern::OpConversionPattern;

    LogicalResult matchAndRewrite(
        mlir::func::FuncOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {
        // Replace this with scheduleOp.
        auto args = op.getArguments();
        int idx = 0;
        SmallVector<mlir::Attribute, 4> argsAttr;

        mlir::Region &oldRegion = op.getBody();

        mlir::IRMapping mapping;
        
        mlir::StringAttr schName = rewriter.getStringAttr(op.getName());

        for (auto arg : args)
        {
            std::string nameStr = "arg" + std::to_string(idx);
            mlir::NamedAttribute nameAttr = rewriter.getNamedAttr("name", rewriter.getStringAttr(nameStr));
            mlir::NamedAttribute typeAttr = rewriter.getNamedAttr("type", mlir::TypeAttr::get(arg.getType()));
            mlir::DictionaryAttr dictAttr = rewriter.getDictionaryAttr({nameAttr, typeAttr});
            argsAttr.push_back(dictAttr);

            ++idx;
        }
        mlir::ArrayAttr insAttr = rewriter.getArrayAttr(argsAttr);

        rewriter.setInsertionPoint(op);
        auto schOp = rewriter.create<avial::ScheduleOp>(rewriter.getUnknownLoc(), insAttr, rewriter.getStringAttr(op.getName()));

        for (const auto &arg : llvm::enumerate(op.getRegion().getBlocks().front().getArguments()))
        {
            mapping.map(arg.value(), schOp.getRegion().getBlocks().front().getArgument(arg.index()));
        }

        rewriter.setInsertionPointToStart(&schOp.getBodyRegion().getBlocks().front());

        Block &funcBlock = op.getBody().front();
        Block &schBlock = schOp.getBodyRegion().front();

        for (Operation &innerop : funcBlock.getOperations())
        {

            if (mlir::isa<mlir::func::ReturnOp>(innerop))
                continue;

            if(innerop.hasAttr("task"))
            {
                // Create the taskOp
                auto archAttr = rewriter.getStringAttr("arch");
                auto archVal = rewriter.getStringAttr("sm_90");
                auto entry1 = mlir::DataLayoutEntryAttr::get(archAttr, archVal);
                auto targetDlti = mlir::TargetDeviceSpecAttr::get(innerop.getContext(), {entry1});
                auto taskOp = rewriter.create<avial::TaskOp>(innerop.getLoc(), avial::TaskRefType::get(rewriter.getContext()), targetDlti, mlir::ValueRange{},mlir::DenseI64ArrayAttr{}, mlir::ValueRange{}, mlir::DenseI64ArrayAttr{});

                rewriter.setInsertionPointToStart(&taskOp.getBodyRegion().getBlocks().front());

                innerop.removeAttr("task");
                Operation *cloned = rewriter.clone(innerop, mapping);
                rewriter.create<mlir::avial::YieldOp>(rewriter.getUnknownLoc());
            }
            else
                Operation *cloned = rewriter.clone(innerop, mapping);
        
            rewriter.setInsertionPointToEnd(&schOp.getBodyRegion().getBlocks().front());
        }




        rewriter.setInsertionPointToEnd(&schOp.getBodyRegion().getBlocks().front());
        rewriter.create<mlir::avial::YieldOp>(rewriter.getUnknownLoc());


        rewriter.eraseOp(op);
        return success();
    }
};



namespace mlir
{
    namespace avial
    {
#define GEN_PASS_DEF_CONVERTSTDTOAVIALPASS
#include "dialect/Passes.h.inc"

        struct ConvertStdToAvialPass : public mlir::avial::impl::ConvertStdToAvialPassBase<ConvertStdToAvialPass>
        {
            using ConvertStdToAvialPassBase::ConvertStdToAvialPassBase;
            void runOnOperation() override
            {
                mlir::MLIRContext *context = &getContext();
                auto *module = getOperation();


                ConversionTarget target(getContext());
                target.addIllegalOp<func::FuncOp>();

                target.addLegalDialect<avial::AvialDialect>();
                target.markUnknownOpDynamicallyLegal([](Operation *op) { return true; });


                RewritePatternSet patterns(context);

                patterns.add<ConvertToAvial>(context);

                if (failed(applyPartialConversion(module, target, std::move(patterns))))
                {
                    signalPassFailure();
                }

                // module->walk<mlir::WalkOrder::PreOrder>([&](mlir::Operation *op)
                // {
                //     if (mlir::isa<mlir::func::FuncOp>(op))
                //     {

                //         auto funcOp = llvm::dyn_cast<mlir::func::FuncOp>(op);

                //         // auto archAttr = builder.getStringAttr("arch");
                //         // auto archVal = builder.getStringAttr("sm_90");
                //         // auto entry1 = mlir::DataLayoutEntryAttr::get(archAttr, archVal);
                //         // auto targetDlti = mlir::TargetDeviceSpecAttr::get(context, {entry1});

                //         // auto cpu = builder.create<avial::TargetOp>(builder.getUnknownLoc(), avial::TargetRefType::get(builder.getContext(), "CPU"), "CPU", "0", targetDlti);
                //         // mlir::TargetDeviceSpecAttr tar =  mlir::dyn_cast<mlir::TargetDeviceSpecAttr>(cpu->getAttr("dlti"));

                //         // auto mapAttr = tar.getSpecForIdentifier(builder.getStringAttr("arch"));
                //         // mapAttr.getValue().dump();

                //         // DictionaryAttr arg1 = builder.getDictionaryAttr({builder.getNamedAttr("name", builder.getStringAttr("inp1")),
                //         //                             builder.getNamedAttr("type", TypeAttr::get(memrefType))});
                //         // ArrayAttr insAttr
                //         // ***** Generate Schedule OP ***** //

                //         auto args = funcOp.getArguments();
                //         int idx = 0;
                //         SmallVector<mlir::Attribute, 4> argsAttr;

                //         for(auto arg: args)
                //         {
                //             std::string nameStr = "arg" + std::to_string(idx);
                //             mlir::NamedAttribute nameAttr = builder.getNamedAttr("name", builder.getStringAttr(nameStr));
                //             mlir::NamedAttribute typeAttr = builder.getNamedAttr("type", mlir::TypeAttr::get(arg.getType()));
                //             mlir::DictionaryAttr dictAttr = builder.getDictionaryAttr({nameAttr, typeAttr});
                //             argsAttr.push_back(dictAttr);

                //             ++idx;
                //         }

                //         mlir::ArrayAttr insAttr = builder.getArrayAttr(argsAttr);
                //         auto schOp = builder.create<avial::ScheduleOp>(builder.getUnknownLoc(),insAttr,
                //             [&](mlir::OpBuilder &builder, mlir::Location loc, mlir::Value value, mlir::ValueRange args)
                //             {

                //             });

                //             schOp.dump();
                //         // ***** Generate Schedule OP end * //

                //             // op->dumpPretty();

                //             // Take Every Functions.
                //             // Check if we have CPU_ or GPU_
                //             // If we don;t have, emit the same IR.
                //             // If we have any functions like that, distribute it!
                //     }

                // });
            }
        };
    }

}

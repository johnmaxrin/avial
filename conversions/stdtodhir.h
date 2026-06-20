#include "mlir/Pass/PassManager.h"
#include "mlir/IR/PatternMatch.h"

#include "includes/dhirDialect.h"
#include "includes/dhirTypes.h"

#include "mlir/Transforms/DialectConversion.h"

#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/Passes.h"

#include "llvm/Support/Casting.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"

#include "includes/dhirDialect.h"
#include "includes/dhirOps.h"
#include "includes/dhirTypes.h"

#include "includes/utils.h"

#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/IR/Builders.h"

#include "mlir/Conversion/Passes.h"


#include <string>

using namespace mlir;
using namespace dhir;

struct ConvertToDhir : public OpConversionPattern<mlir::func::FuncOp>
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
        auto schOp = rewriter.create<dhir::ScheduleOp>(rewriter.getUnknownLoc(), insAttr, rewriter.getStringAttr(op.getName()));

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
                auto archVal = rewriter.getStringAttr("sm_61");
                auto entry1 = mlir::DataLayoutEntryAttr::get(archAttr, archVal);
                auto targetDlti = mlir::TargetDeviceSpecAttr::get(innerop.getContext(), {entry1});
                auto taskOp = rewriter.create<dhir::TaskOp>(innerop.getLoc(), dhir::TaskRefType::get(rewriter.getContext()), targetDlti, mlir::ValueRange{},mlir::DenseI64ArrayAttr{}, mlir::ValueRange{}, mlir::DenseI64ArrayAttr{}, mlir::ValueRange{});

                rewriter.setInsertionPointToStart(&taskOp.getBodyRegion().getBlocks().front());

                innerop.removeAttr("task");
                Operation *cloned = rewriter.clone(innerop, mapping);
                rewriter.create<mlir::dhir::YieldOp>(rewriter.getUnknownLoc());
            }
            else
                Operation *cloned = rewriter.clone(innerop, mapping);
        
            rewriter.setInsertionPointToEnd(&schOp.getBodyRegion().getBlocks().front());
        }




        rewriter.setInsertionPointToEnd(&schOp.getBodyRegion().getBlocks().front());
        rewriter.create<mlir::dhir::YieldOp>(rewriter.getUnknownLoc());


        rewriter.eraseOp(op);
        return success();
    }
};



namespace mlir
{
    namespace dhir
    {
#define GEN_PASS_DEF_CONVERTSTDTODHIRPASS
#include "dialect/Passes.h.inc"

        struct ConvertStdToDhirPass : public mlir::dhir::impl::ConvertStdToDhirPassBase<ConvertStdToDhirPass>
        {
            using ConvertStdToDhirPassBase::ConvertStdToDhirPassBase;
            void runOnOperation() override
            {
                mlir::MLIRContext *context = &getContext();
                auto *module = getOperation();


                ConversionTarget target(getContext());
                target.addIllegalOp<func::FuncOp>();

                target.addLegalDialect<dhir::DhirDialect>();
                target.markUnknownOpDynamicallyLegal([](Operation *op) { return true; });


                RewritePatternSet patterns(context);

                patterns.add<ConvertToDhir>(context);

                if (failed(applyPartialConversion(module, target, std::move(patterns))))
                {
                    signalPassFailure();
                }

            }
        };
    }

}

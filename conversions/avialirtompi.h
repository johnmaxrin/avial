#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/IR/PatternMatch.h"

#include "includes/avialDialect.h"
#include "includes/avialTypes.h"

#include "mlir/Transforms/DialectConversion.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Conversion/Passes.h"

#include "mlir/IR/PatternMatch.h"
#include "llvm/Support/Casting.h"

#include "analysis/depGraph.h"

using namespace mlir;
using namespace avial;

// class AvialtoMPITypeConverter : public TypeConverter
// {
// public:
//     AvialtoMPITypeConverter(MLIRContext *ctx)
//     {

//         addConversion([ctx](Type type)
//                    { return type; });

//         addConversion([ctx](){return ;});

//         // addConversion([ctx](mlir::avial::TaskRef) -> Type
//         //               { return 0; });

//         // addTargetMaterialization(
//         //     [ctx](OpBuilder &builder, Type type, ValueRange inputs, Location loc) -> std::optional<Value>
//         //     {
//         //         if (type.isa<mlir::avial::taskref>() &&
//         //             inputs.size() == 1 &&
//         //             inputs[0].getType().isa<MemRefType>())
//         //         {
//         //             return inputs[0]; // just forward the memref
//         //         }
//         //         return std::nullopt;
//         //     });

//     }
// };

struct ConvertScheduleOp : public OpConversionPattern<mlir::avial::ScheduleOp>
{
    using OpConversionPattern::OpConversionPattern;

    LogicalResult matchAndRewrite(
        mlir::avial::ScheduleOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {

        // Do the dependence analysis. 
        DependencyGraph dependencyGraph;
        dependencyGraph.build(op);
        dependencyGraph.printDiGraph();
        dependencyGraph.schedule();

        // Now that we have the level vector. Let's generate code for it! 


        llvm::SmallVector<mlir::Type> inputTypes;
        auto loc = op.getLoc();
        auto module = op->getParentOfType<mlir::ModuleOp>();
        auto oldInps = op.getInputs();

        for (auto inputAttr : oldInps)
        {
            auto dict = llvm::cast<mlir::DictionaryAttr>(inputAttr); 
            if (!dict)
                continue;

            auto typeAttr = llvm::cast< mlir::TypeAttr> (dict.get("type"));
            if (typeAttr)
                inputTypes.push_back(typeAttr.getValue());
        }

        auto funcType = mlir::FunctionType::get(rewriter.getContext(), inputTypes, {});
        auto func = rewriter.create<mlir::func::FuncOp>(loc, "main", funcType);

        Block *block = func.addEntryBlock();
        rewriter.setInsertionPointToEnd(block);

        for(auto op : dependencyGraph.allocs)
            rewriter.clone(*op.getOperation());

        rewriter.create<func::ReturnOp>(loc);

        //block->getOperations().push_back(op3);

        // for(mlir::memref::AllocaOp op : dependencyGraph.allocs)
        // {
        //     memref::AllocaOp *clonedAlloc = rewriter.clone(*op.getOperation());
        //     block->getOperations().push_back(clonedAlloc);
        // } 


        //rewriter.inlineRegionBefore(op.getRegion(), func.getBody(), func.end());

        //func.setVisibility(mlir::SymbolTable::Visibility::Private);

        rewriter.eraseOp(op);

        return success();
    }
};



void memAllocs()
{

}

namespace mlir
{
    namespace avial
    {
#define GEN_PASS_DEF_CONVERTAVIALIRTOMPIPASS
#include "dialect/Passes.h.inc"

        struct ConvertAvialIRToMPIPass : public mlir::avial::impl::ConvertAvialIRToMPIPassBase<ConvertAvialIRToMPIPass>
        {
            using ConvertAvialIRToMPIPassBase::ConvertAvialIRToMPIPassBase;
            void runOnOperation() override
            {
                mlir::MLIRContext *context = &getContext();
                auto *module = getOperation();

                ConversionTarget target(getContext());
                target.addLegalDialect<mlir::scf::SCFDialect>();
                target.addLegalDialect<mlir::memref::MemRefDialect>();
                target.addLegalDialect<mlir::arith::ArithDialect>();
                target.addLegalDialect<mlir::LLVM::LLVMDialect>();
                target.addLegalDialect<mlir::func::FuncDialect>();

                target.addIllegalOp<avial::ScheduleOp>();

                RewritePatternSet patterns(context);
                patterns.add<ConvertScheduleOp>(context);

                if (failed(applyPartialConversion(module, target, std::move(patterns))))
                {
                    signalPassFailure();
                }
            }
        };

    }

}
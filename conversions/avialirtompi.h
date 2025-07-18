#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/IR/PatternMatch.h"

#include "includes/avialDialect.h"
#include "includes/avialTypes.h"
#include "includes/utils.h"

#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"

#include "mlir/Conversion/Passes.h"
#include "mlir/Conversion/MPIToLLVM/MPIToLLVM.h"

#include "mlir/IR/PatternMatch.h"
#include "llvm/Support/Casting.h"

#include "analysis/depGraph.h"

#include "mlir/Dialect/DLTI/DLTI.h"

// Dialects
#include "mlir/Dialect/MPI/IR/MPI.h"

using namespace mlir;
using namespace avial;

struct LowerMPIDialectToLLVMPass
    : public PassWrapper<LowerMPIDialectToLLVMPass, OperationPass<ModuleOp>>
{

    void runOnOperation() override
    {
        ModuleOp module = getOperation();

        // Step 1: Set up conversion target
        MLIRContext *context = &getContext();
        LLVMConversionTarget target(*context);
        target.addLegalDialect<LLVM::LLVMDialect>();
        target.addIllegalDialect<mpi::MPIDialect>();

        // Step 2: Type converter
        LLVMTypeConverter typeConverter(context);

        // Step 3: Populate patterns
        RewritePatternSet patterns(context);
        mpi::populateMPIToLLVMConversionPatterns(typeConverter, patterns);
        mlir::populateFinalizeMemRefToLLVMConversionPatterns(typeConverter, patterns);

        // Step 4: Apply conversion
        if (failed(applyPartialConversion(module, target, std::move(patterns))))
        {
            signalPassFailure();
        }
    }
};

std::unique_ptr<Pass> createLowerMPIPass()
{
    return std::make_unique<LowerMPIDialectToLLVMPass>();
}

struct ConvertReplicateOp : public OpConversionPattern<mlir::avial::ReplicateOp>
{
    using OpConversionPattern::OpConversionPattern;

    LogicalResult matchAndRewrite(
        mlir::avial::ReplicateOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {
        mlir::IRMapping mapping;

        auto archAttr = rewriter.getStringAttr("arch");
        auto archVal = rewriter.getStringAttr("sm_90");
        auto entry1 = mlir::DataLayoutEntryAttr::get(archAttr, archVal);
        auto targetDlti = mlir::TargetDeviceSpecAttr::get(op.getContext(), {entry1});

        
        auto parentOp = op->getParentOp();


        rewriter.setInsertionPointAfter(op); 

        rewriter.create<mlir::arith::ConstantOp>(rewriter.getUnknownLoc(), rewriter.getI32Type(), rewriter.getI32IntegerAttr(33));

        rewriter.eraseOp(op);
        llvm::errs() << "***************\n";
        parentOp->dump();
        llvm::errs() << "***************\n";
    


        return success();
    }
};

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

        

        mlir::IRMapping mapping;

        for (auto inputAttr : oldInps)
        {
            auto dict = llvm::cast<mlir::DictionaryAttr>(inputAttr);
            if (!dict)
                continue;

            auto typeAttr = llvm::cast<mlir::TypeAttr>(dict.get("type"));
            if (typeAttr)
                inputTypes.push_back(typeAttr.getValue());
        }

        auto funcType = mlir::FunctionType::get(rewriter.getContext(), inputTypes, {});
        auto func = rewriter.create<mlir::func::FuncOp>(loc, "testFunc", funcType);

        Block *block = func.addEntryBlock();

        for (const auto& arg : llvm::enumerate(op.getRegion().getBlocks().front().getArguments())) {
            mapping.map(arg.value(), block->getArgument(arg.index()));
        }

        rewriter.setInsertionPointToEnd(block);

        for (auto op : dependencyGraph.allocs)
        {
            auto newOp = rewriter.clone(*op.getOperation());
            op.getResult().replaceAllUsesWith(newOp->getResult(0));
        }

        // MPI Boilerplate
        auto retVal = mlir::mpi::RetvalType::get(rewriter.getContext());
        rewriter.create<mlir::mpi::InitOp>(loc, retVal);
        auto comm = rewriter.create<mlir::mpi::CommWorldOp>(loc, mlir::mpi::CommType::get(rewriter.getContext()));
        auto rank = rewriter.create<mpi::CommRankOp>(loc, rewriter.getI32Type(), comm->getResult(0));
        auto getNodes = rewriter.create<mpi::CommSizeOp>(loc, mpi::RetvalType::get(rewriter.getContext()), rewriter.getI32Type(), comm->getResult(0));

        // End of MPI Boilerplate


        // Clone all variables
        for(auto &innerOp : op.getBodyRegion().front().getOperations())
        {
            if(mlir::isa<mlir::avial::TaskOp>(innerOp) || mlir::isa<mlir::avial::YieldOp>(innerOp))
                continue;
            
            Operation *cloned = rewriter.clone(innerOp, mapping);
        }


        // Lower the tasks
        for (std::vector<TaskOpInfo *> level : dependencyGraph.levelVector)
        {
            int taskId = 0;
            for (auto task : level)
            {
                // Lower Task
                // Assigned Node

                auto taskIDOp = rewriter.create<mlir::arith::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(taskId));
                auto taskIdModNodes = rewriter.create<mlir::arith::RemSIOp>(loc, taskIDOp->getResult(0), getNodes->getResult(1));
                auto cond = rewriter.create<arith::CmpIOp>(loc, rewriter.getI1Type(), arith::CmpIPredicate::eq, rank.getResult(0), taskIdModNodes.getResult());
                rewriter.create<mlir::scf::IfOp>(loc, cond, [&](OpBuilder &builder, Location loc)
                                                 {
                    // Add Task Args to IfOp Mappings

                    
                    Block &taskBlock = task->op->getRegion(0).front(); 
                    Block *thenBlock = builder.getBlock();

                    for (auto &op : taskBlock) {
                        if (mlir::isa<mlir::avial::YieldOp>(op))
                            continue;
                    
                        Operation *clonedOp = rewriter.clone(op, mapping);
                    } 


                    
                    rewriter.create<mlir::scf::YieldOp>(loc); 
                });

                ++taskId;
            }

            rewriter.create<mpi::Barrier>(loc, retVal, comm->getResult(0));
        }

        // End of Lowering the tasks

        rewriter.create<func::ReturnOp>(loc);
        rewriter.eraseOp(op);

        func.dump();

        return success();
    }
};

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
                ConversionTarget targetReplicateOp(getContext());
                target.addLegalDialect<mlir::scf::SCFDialect>();
                target.addLegalDialect<mlir::memref::MemRefDialect>();
                target.addLegalDialect<mlir::arith::ArithDialect>();
                target.addLegalDialect<mlir::LLVM::LLVMDialect>();
                target.addLegalDialect<mlir::func::FuncDialect>();
                target.addLegalDialect<mlir::mpi::MPIDialect>();

                target.addIllegalOp<avial::ScheduleOp>();

                targetReplicateOp.addLegalDialect<mlir::arith::ArithDialect>();
                targetReplicateOp.addLegalDialect<mlir::avial::AvialDialect>(); // Now this will work!! Idiot!! 
                targetReplicateOp.addIllegalOp<avial::ReplicateOp>();

                RewritePatternSet avialpatterns(context);
                avialpatterns.add<ConvertReplicateOp>(context);

                if (failed(applyPartialConversion(module, targetReplicateOp, std::move(avialpatterns))))
                {
                    signalPassFailure();
                }

                module->dump();

                RewritePatternSet patterns(context);
                patterns.add<ConvertScheduleOp>(context);
                patterns.add<ConvertReplicateOp>(context);
               
                if (failed(applyPartialConversion(module, target, std::move(patterns))))
                {
                    signalPassFailure();
                }
            }
        };

    }

}
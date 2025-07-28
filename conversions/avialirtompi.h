#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/Verifier.h"

#include "includes/avialDialect.h"
#include "includes/avialTypes.h"
#include "includes/utils.h"

#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/OpenMP/OpenMPDialect.h"

#include "mlir/Conversion/Passes.h"
#include "mlir/Conversion/MPIToLLVM/MPIToLLVM.h"

#include "mlir/IR/PatternMatch.h"
#include "llvm/Support/Casting.h"

#include "analysis/depGraph.h"

#include "mlir/Dialect/DLTI/DLTI.h"

// Dialects
#include "mlir/Dialect/MPI/IR/MPI.h"


#include "llvm/ADT/STLExtras.h" // for llvm::to_vector

mlir::Value materializeOpFoldResult(mlir::OpFoldResult ofr, mlir::ConversionPatternRewriter &rewriter);


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


struct ConvertTaskOp : public OpConversionPattern<mlir::avial::TaskOp>
{
    using OpConversionPattern::OpConversionPattern;
    LogicalResult matchAndRewrite(
        mlir::avial::TaskOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {
        //Rewrite Pattern for Converting Task's outermost forloop based on dlti info
        // 1. Get Task block. 
        // 2. Convert the outermost affine.for to omp/gpu

        // Get the outermost affine for. 
        mlir::affine::AffineForOp affineForOp = nullptr;

        for(auto &innerOp : op.getBody().front().getOperations())
        {
            if(mlir::isa<mlir::affine::AffineForOp>(innerOp))
                affineForOp = mlir::dyn_cast<mlir::affine::AffineForOp>(innerOp);
        }

        mlir::SmallVector<mlir::Value> outForLowerBound;
        mlir::SmallVector<mlir::Value> outForUpperBound;
        mlir::SmallVector<mlir::Value> steps;


       std::optional<llvm::SmallVector<OpFoldResult>> maybeLowerBounds = affineForOp.getLoopLowerBounds();
       std::optional<llvm::SmallVector<OpFoldResult>> maybeUpperBounds = affineForOp.getLoopLowerBounds();
       std::optional<llvm::SmallVector<OpFoldResult>> maybeSteps = affineForOp.getLoopSteps();
       
       llvm::outs() << "CheckL\n";
       for(auto [lb, ub, step] : llvm::zip_equal(*maybeLowerBounds, *maybeUpperBounds, *maybeSteps))
       {
                //llvm::errs() << step.
                outForLowerBound.push_back(materializeOpFoldResult(lb, rewriter));
                outForUpperBound.push_back(materializeOpFoldResult(ub, rewriter));
                steps.push_back(materializeOpFoldResult(step, rewriter));

       }

        

        if(affineForOp == nullptr)
        {
            llvm::errs() << "Affine Loop Cannot be empty!\n";
            exit(0);
        }

        
        rewriter.setInsertionPointToStart(&op.getBody().front());

        auto parallelOp = rewriter.create<mlir::omp::ParallelOp>(rewriter.getUnknownLoc());

        mlir::Block *parallelBlock = rewriter.createBlock(&parallelOp.getRegion());
        rewriter.setInsertionPointToStart(parallelBlock);

        auto wsLoopOp = rewriter.create<mlir::omp::WsloopOp>(rewriter.getUnknownLoc());
        mlir::Block *wsLoopBlock = rewriter.createBlock(&wsLoopOp.getRegion());
        rewriter.setInsertionPointToStart(wsLoopBlock);

        mlir::omp::LoopNestOperands loopNestOperands;
        loopNestOperands.loopLowerBounds = outForLowerBound;
        loopNestOperands.loopUpperBounds = outForUpperBound;

        

        //loopNestOperands.loopLowerBounds = rewrtier.create<mlir::scf::>
        auto parallelLoopOp = rewriter.create<mlir::omp::LoopNestOp>(rewriter.getUnknownLoc(), loopNestOperands);
        
        op.dump(); 
        //rewriter.eraseOp(op);
    }

};


mlir::Value materializeOpFoldResult(OpFoldResult ofr, ConversionPatternRewriter &rewriter) {
    if (auto val = ofr.dyn_cast<mlir::Value>())
        return val;
    if (auto attr = mlir::dyn_cast<mlir::Attribute>(ofr))
    {
        mlir::IntegerAttr intAttr =  mlir::dyn_cast<mlir::IntegerAttr>(ofr.get<Attribute>());
        return rewriter.create<arith::ConstantIndexOp>(rewriter.getUnknownLoc(), intAttr.getValue().getSExtValue()); 
    }
    
    llvm_unreachable("Unsupported OpFoldResult kind");
}


struct ConvertReplicateOp : public OpConversionPattern<mlir::avial::ReplicateOp>
{
    using OpConversionPattern::OpConversionPattern;

    LogicalResult matchAndRewrite(
        mlir::avial::ReplicateOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {

        mlir::IRMapping mapping;

        auto &replicateRegion = op.getRegion();
        auto &replicateBody = replicateRegion.front();
        
        auto archAttr = rewriter.getStringAttr("arch");
        auto archVal = rewriter.getStringAttr("sm_90");
        auto entry1 = mlir::DataLayoutEntryAttr::get(archAttr, archVal);
        auto targetDlti = mlir::TargetDeviceSpecAttr::get(op.getContext(), {entry1});

        int64_t constupperBound = 0;

        
        mlir::Operation *module = op;
        while (module && !mlir::isa<mlir::ModuleOp>(module)) {
            module = module->getParentOp();
        }

        auto deviceVec = extractTargetDeviceSpecs(llvm::dyn_cast<mlir::ModuleOp>(module));

        // Extract the outer loop bound. 
        for(auto &innerOp : op.getBody().front().getOperations())
        {
            if(mlir::isa<mlir::affine::AffineForOp>(innerOp))
            {   

                
                constupperBound = (mlir::dyn_cast<mlir::affine::AffineForOp>(innerOp)).getConstantUpperBound();
                if(!constupperBound)
                {
                    llvm::errs() << "Error: Not a Contant Upper Bound";
                    exit(0);
                }
            }
        }
        


        
        auto parentOp = op->getParentOp();

        
        rewriter.setInsertionPointAfter(op); 

        int64_t ub = constupperBound;
        int64_t num_devices =  deviceVec.size();
        

        int64_t total_iters = ub;
        int64_t base_chunk = total_iters / num_devices;
        int64_t remainder = total_iters % num_devices;

        // Chunk Calculation
        llvm::SmallVector<std::pair<int64_t, int64_t>> ranges; 
        int64_t current = 0;
        for (int i = 0; i < num_devices; ++i) {
            int64_t chunk = base_chunk + (i < remainder ? 1 : 0); // distribute remainder
            int64_t start = current;
            int64_t end = start + chunk;
            ranges.emplace_back(start, end);
            current = end;
        }

        
        // Represent the number of devices - Done
        // Compute the chunk size - Done
        // compute start and end - Done
        // repalce the loop bounds. - Done 

        for(int i=0 ;i<deviceVec.size(); ++i)
        {

            auto taskOp = rewriter.create<avial::TaskOp>(op.getLoc(), avial::TaskRefType::get(rewriter.getContext()), targetDlti, mlir::ValueRange{}, mlir::ValueRange{});
        
            auto &taskRegion = taskOp.getRegion();
            auto &taskBlock = taskRegion.front();

            for (auto [oldArg, type] : llvm::zip(replicateBody.getArguments(), replicateBody.getArgumentTypes())) {
                Value newArg = taskBlock.addArgument(type, op.getLoc());
                mapping.map(oldArg, newArg);
            }
            
            for (Operation &innerOp : replicateBody.without_terminator()) {
                auto cloned = innerOp.clone();
                
                if(mlir::isa<mlir::affine::AffineForOp>(cloned))
                {
                    mlir::affine::AffineForOp forOp = mlir::dyn_cast<mlir::affine::AffineForOp>(cloned);
                    forOp.setConstantLowerBound(ranges[i].first);
                    forOp.setConstantUpperBound(ranges[i].second);
                }
                taskBlock.push_back(cloned);
            }
        } 
        rewriter.eraseOp(op);

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
                // Lower 
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
                ConversionTarget targetTaskOp(getContext());
                target.addLegalDialect<mlir::scf::SCFDialect>();
                target.addLegalDialect<mlir::memref::MemRefDialect>();
                target.addLegalDialect<mlir::arith::ArithDialect>();
                target.addLegalDialect<mlir::LLVM::LLVMDialect>();
                target.addLegalDialect<mlir::func::FuncDialect>();
                target.addLegalDialect<mlir::mpi::MPIDialect>();
                target.addLegalDialect<mlir::affine::AffineDialect>();

                target.addIllegalOp<avial::ScheduleOp>();

                targetReplicateOp.addLegalDialect<mlir::arith::ArithDialect>();
                targetReplicateOp.addLegalOp<mlir::avial::TaskOp>();
                targetReplicateOp.addIllegalOp<avial::ReplicateOp>();

                targetTaskOp.addLegalDialect<mlir::omp::OpenMPDialect>();


                RewritePatternSet avialpatterns(context);
                avialpatterns.add<ConvertReplicateOp>(context);

                if (failed(applyPartialConversion(module, targetReplicateOp, std::move(avialpatterns))))
                {
                    signalPassFailure();
                }

                module->dump();

                RewritePatternSet taskPattern(context);
                taskPattern.add<ConvertTaskOp>(context);

                if (failed(applyPartialConversion(module, targetTaskOp, std::move(taskPattern))))
                {
                    signalPassFailure();
                }

                module->dump();



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
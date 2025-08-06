#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/Verifier.h"

#include "includes/avialDialect.h"
#include "includes/avialTypes.h"
#include "includes/utils.h"

#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/OpenMP/OpenMPDialect.h"

#include "mlir/Conversion/Passes.h"
#include "mlir/Conversion/MPIToLLVM/MPIToLLVM.h"
#include "mlir/Conversion/AffineToStandard/AffineToStandard.h"

#include "mlir/IR/PatternMatch.h"
#include "llvm/Support/Casting.h"

#include "analysis/depGraph.h"

#include "mlir/Dialect/DLTI/DLTI.h"

// Dialects
#include "mlir/Dialect/MPI/IR/MPI.h"


#include "llvm/ADT/STLExtras.h" // for llvm::to_vector

mlir::Value materializeOpFoldResult(mlir::OpFoldResult ofr, mlir::ConversionPatternRewriter &rewriter);
static mlir::SmallVector<mlir::Value> materializeOpFoldResults(mlir::PatternRewriter &rewriter, mlir::ArrayRef<mlir::OpFoldResult> ofrs);


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
        
        //rewriter.eraseOp(op);
    }

};


mlir::Value materializeOpFoldResult(OpFoldResult ofr, PatternRewriter &rewriter) {
    if (auto val = ofr.dyn_cast<mlir::Value>())
        return val;
    if (auto attr = mlir::dyn_cast<mlir::Attribute>(ofr))
    {
        mlir::IntegerAttr intAttr =  mlir::dyn_cast<mlir::IntegerAttr>(ofr.get<Attribute>());
        return rewriter.create<arith::ConstantIndexOp>(rewriter.getUnknownLoc(), intAttr.getValue().getSExtValue()); 
    }
    
    llvm_unreachable("Unsupported OpFoldResult kind");
}

static SmallVector<Value> materializeOpFoldResults(PatternRewriter &rewriter, ArrayRef<OpFoldResult> ofrs) {
    SmallVector<Value> values;
    values.reserve(ofrs.size());
    for (OpFoldResult ofr : ofrs)
        values.push_back(materializeOpFoldResult(ofr, rewriter));
    return values;
}


struct ConvertOuterForOp : public OpConversionPattern<mlir::scf::ForOp>
{
    using OpConversionPattern::OpConversionPattern;

    LogicalResult matchAndRewrite(
        mlir::scf::ForOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {
        IRMapping mapping;
        if(mlir::isa<mlir::avial::TaskOp>(op->getParentOp()))
        {
            PatternRewriter::InsertionGuard guard(rewriter);
            rewriter.setInsertionPointAfter(op);
            auto &outerForRegion = op.getRegion();
            
            
            auto parallelOp = rewriter.create<mlir::omp::ParallelOp>(rewriter.getUnknownLoc()); 
            auto &parallelRegion = parallelOp.getRegion();
            if(parallelRegion.empty())
                parallelRegion.emplaceBlock();
            auto &parallelBlock = parallelRegion.front(); 
            
            rewriter.setInsertionPointToStart(&parallelBlock);
            
            auto wsloopOp = rewriter.create<mlir::omp::WsloopOp>(rewriter.getUnknownLoc());
            auto &wsloopRegion = wsloopOp.getRegion();
            if(wsloopRegion.empty())
                wsloopRegion.emplaceBlock();
            auto &wsloopBlock = wsloopRegion.front();

            rewriter.setInsertionPointToStart(&wsloopBlock);
            {
                auto lbs = materializeOpFoldResults(rewriter, *op.getLoopLowerBounds());
                auto ubs = materializeOpFoldResults(rewriter, *op.getLoopUpperBounds());
                auto steps = materializeOpFoldResults(rewriter, *op.getLoopSteps());

                omp::LoopNestOperands loopNestOperands;
                loopNestOperands.loopLowerBounds = lbs;
                loopNestOperands.loopUpperBounds = ubs;
                loopNestOperands.loopSteps = steps;
                auto loopNestOp = rewriter.create<mlir::omp::LoopNestOp>(rewriter.getUnknownLoc(), loopNestOperands);
                auto &loopNestRegion = loopNestOp.getRegion();
                if(loopNestRegion.empty())
                    loopNestRegion.emplaceBlock();
                auto &loopNestBlock = loopNestRegion.front();

                llvm::errs() << "Segfault\n";
                Value newIV = loopNestBlock.addArgument(rewriter.getIndexType(), rewriter.getUnknownLoc());
                mapping.map(op.getInductionVar(), newIV);

                
                rewriter.setInsertionPointToStart(&loopNestBlock);
                {
                    {

                        auto dummyIdx = rewriter.create<arith::ConstantIndexOp>(op.getLoc(), 0);
                        mapping.map(op.getInductionVar(), dummyIdx);

                        for(auto &innerOps : op.getRegion().front().without_terminator())
                        {
                            auto clonedOp = rewriter.clone(innerOps, mapping);
                            llvm::errs() << "Op: ";
                            clonedOp->dump();
                            llvm::errs()  << "\n";
                        }

                        rewriter.create<mlir::omp::YieldOp>(rewriter.getUnknownLoc());
                    }
                }
                
                // rewriter.setInsertionPointToEnd(&wsloopBlock);
                // rewriter.create<omp::TerminatorOp>(rewriter.getUnknownLoc()); 
            }
            rewriter.setInsertionPointToEnd(&parallelBlock);
            rewriter.create<omp::TerminatorOp>(rewriter.getUnknownLoc()); 

            rewriter.eraseOp(op);
            parallelOp.dump();
            verify(parallelOp);
            return success();
        }

        return failure();



    
    }
};


struct ConvertReplicateOp : public OpConversionPattern<mlir::avial::ReplicateOp>
{
    using OpConversionPattern::OpConversionPattern;

    LogicalResult matchAndRewrite(
        mlir::avial::ReplicateOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {


          mlir::Operation *module = op;
        while (module && !mlir::isa<mlir::ModuleOp>(module)) {
            module = module->getParentOp();
        }
        auto deviceVec = extractTargetDeviceSpecs(llvm::dyn_cast<mlir::ModuleOp>(module));
        auto &replicateRegion = op.getRegion();
        auto &replicateBody = replicateRegion.front();
        
        auto archAttr = rewriter.getStringAttr("arch");
        auto archVal = rewriter.getStringAttr("sm_90");
        auto entry1 = mlir::DataLayoutEntryAttr::get(archAttr, archVal);
        auto targetDlti = mlir::TargetDeviceSpecAttr::get(op.getContext(), {entry1});

        
        int64_t constupperBound=0;
        mlir::scf::ForOp outerFor = nullptr;

        for(auto &innerOp : op.getBody().front().getOperations())
        {
            if(mlir::isa<mlir::scf::ForOp>(innerOp))
            {
                outerFor = mlir::dyn_cast<mlir::scf::ForOp>(innerOp);
                if(mlir::isa<mlir::arith::ConstantIndexOp>(outerFor.getUpperBound().getDefiningOp()))
                {
                    auto constUB = mlir::dyn_cast<mlir::arith::ConstantIndexOp>(outerFor.getUpperBound().getDefiningOp());
                    llvm::errs() << "UB: "<<constUB.value();
                    constupperBound = constUB.value();
                }
                else
                {
                    llvm::errs() << "Error: Not a constant upper bound!\n";
                    return failure();
                }
            }
        }

        if(!constupperBound)
        {
            llvm::errs() << "Error: Upper Bound cannot be Zero. UB: "<<constupperBound <<"\n";

            return failure();
        }

        int64_t ub = constupperBound;
        int64_t num_devices =  deviceVec.size();
        

        int64_t total_iters = ub;
        int64_t base_chunk = total_iters / num_devices;
        int64_t remainder = total_iters % num_devices;

        int64_t current = 0;
        for (int i = 0; i < num_devices; ++i) {
            int64_t chunk = base_chunk + (i < remainder ? 1 : 0); // distribute remainder
            int64_t start = current;
            int64_t end = start + chunk;
            current = end;

            IRMapping mapping;
            PatternRewriter::InsertionGuard guard(rewriter);
            rewriter.setInsertionPointAfter(op);

            auto taskOp = rewriter.create<avial::TaskOp>(
            op.getLoc(),
            avial::TaskRefType::get(rewriter.getContext()),
            targetDlti,
            ValueRange{}, ValueRange{});

            if (taskOp.getRegion().empty())
                rewriter.createBlock(&taskOp.getRegion());

            // Change insertion point to the start of the new block
            rewriter.setInsertionPointToStart(&taskOp.getRegion().front());

            // Create some ops in the task region
            for(auto &innerOp : op.getRegion().front().without_terminator())
            {
                auto cloned = rewriter.clone(innerOp, mapping);
                if(mlir::isa<mlir::scf::ForOp>(cloned))
                {
                    mlir:scf::ForOp outerFor = mlir::dyn_cast<mlir::scf::ForOp>(cloned);
                    auto ub = outerFor.getUpperBound().getDefiningOp();
                    auto lb = outerFor.getLowerBound().getDefiningOp();
                    if(mlir::isa<mlir::arith::ConstantIndexOp>(ub))
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
                target.addLegalDialect<mlir::omp::OpenMPDialect>();

                target.addIllegalOp<avial::ScheduleOp>();

                targetReplicateOp.addLegalDialect<mlir::arith::ArithDialect>();
                targetReplicateOp.addLegalDialect<mlir::scf::SCFDialect>();

                targetReplicateOp.addLegalOp<mlir::avial::TaskOp>();
                targetReplicateOp.addIllegalOp<avial::ReplicateOp>();
                targetReplicateOp.addLegalOp<mlir::avial::YieldOp>();
                targetReplicateOp.addLegalDialect<mlir::memref::MemRefDialect>();


                targetTaskOp.addLegalDialect<mlir::omp::OpenMPDialect>();
            //    targetTaskOp.addIllegalDialect<mlir::scf::SCFDialect>();
                targetTaskOp.addIllegalOp<mlir::scf::ForOp>();
                targetTaskOp.addLegalOp<mlir::omp::ParallelOp>();
                targetTaskOp.markOpRecursivelyLegal<mlir::omp::ParallelOp>();
                targetTaskOp.addLegalDialect<mlir::avial::AvialDialect>();
                targetTaskOp.addLegalDialect<mlir::arith::ArithDialect>();


                RewritePatternSet avialpatterns(context);
                avialpatterns.add<ConvertReplicateOp>(context);

                if (failed(applyPartialConversion(module, targetReplicateOp, std::move(avialpatterns))))
                {
                    signalPassFailure();
                }
                
                llvm::errs() << "After Converting Replicate Op\n";

                RewritePatternSet taskPattern(context);
                taskPattern.add<ConvertOuterForOp>(context);

                if (failed(applyPartialConversion(module, targetTaskOp, std::move(taskPattern))))
                {
                    signalPassFailure();
                }


                // llvm::errs() << "After Converting Outermost ForLoop\n";
                // module->dump();


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
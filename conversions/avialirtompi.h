#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/Verifier.h"

#include "includes/avialDialect.h"
#include "includes/avialTypes.h"
#include "includes/utils.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"

#include "mlir/Dialect/Index/IR/IndexDialect.h"

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

#include "mlir/Conversion/SCFToGPU/SCFToGPUPass.h"

#include "analysis/depGraph.h"

#include "mlir/Dialect/DLTI/DLTI.h"

#include "includes/utils.h"

// Dialects
#include "mlir/Dialect/MPI/IR/MPI.h"

#include "llvm/ADT/STLExtras.h" // for llvm::to_vector

mlir::Value materializeOpFoldResult(mlir::OpFoldResult ofr, mlir::ConversionPatternRewriter &rewriter);
static mlir::SmallVector<mlir::Value> materializeOpFoldResults(mlir::ConversionPatternRewriter &rewriter, mlir::ArrayRef<mlir::OpFoldResult> ofrs);

using namespace mlir;
using namespace avial;

#include "mlir/Dialect/GPU/Transforms/ParallelLoopMapper.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/SCF/IR/SCF.h"

namespace
{

    // Copy these from the ParallelLoopMapper.cpp since they're in anonymous namespace
    enum MappingLevel
    {
        MapGrid = 0,
        MapBlock = 1,
        Sequential = 2
    };
    enum class MappingPolicy
    {
        OutermostFirst,
        InnermostFirst
    };

    static constexpr int kNumHardwareIds = 3;

    static MappingLevel &operator++(MappingLevel &mappingLevel)
    {
        if (mappingLevel < Sequential)
        {
            mappingLevel = static_cast<MappingLevel>(mappingLevel + 1);
        }
        return mappingLevel;
    }

    static mlir::gpu::Processor getHardwareIdForMapping(MappingLevel level, int dimension)
    {
        if (dimension >= kNumHardwareIds || level == Sequential)
            return mlir::gpu::Processor::Sequential;

        switch (level)
        {
        case MapGrid:
            switch (dimension)
            {
            case 0:
                return mlir::gpu::Processor::BlockX;
            case 1:
                return mlir::gpu::Processor::BlockY;
            case 2:
                return mlir::gpu::Processor::BlockZ;
            default:
                return mlir::gpu::Processor::Sequential;
            }
        case MapBlock:
            switch (dimension)
            {
            case 0:
                return mlir::gpu::Processor::ThreadX;
            case 1:
                return mlir::gpu::Processor::ThreadY;
            case 2:
                return mlir::gpu::Processor::ThreadZ;
            default:
                return mlir::gpu::Processor::Sequential;
            }
        default:
            return mlir::gpu::Processor::Sequential;
        }
    }

    static void mapParallelOp(mlir::scf::ParallelOp parallelOp,
                              MappingLevel mappingLevel = MapGrid,
                              MappingPolicy mappingPolicy = MappingPolicy::OutermostFirst)
    {
        // Do not try to add a mapping to already mapped loops or nested loops.
        if (parallelOp->getAttr(mlir::gpu::getMappingAttrName()) ||
            ((mappingLevel == MapGrid) && parallelOp->getParentOfType<mlir::scf::ParallelOp>()))
            return;

        const int numLoops = static_cast<int>(parallelOp.getNumLoops());
        const int loopsToMap = std::min(numLoops, kNumHardwareIds);

        mlir::MLIRContext *ctx = parallelOp.getContext();
        mlir::Builder b(ctx);
        llvm::SmallVector<mlir::gpu::ParallelLoopDimMappingAttr, 4> attrs;
        attrs.reserve(numLoops);

        for (int i = 0; i < numLoops; ++i)
        {
            int hwMapping = kNumHardwareIds;
            if (i < loopsToMap)
            {
                hwMapping = (mappingPolicy == MappingPolicy::OutermostFirst)
                                ? i
                                : (loopsToMap - 1 - i);
            }

            attrs.push_back(b.getAttr<mlir::gpu::ParallelLoopDimMappingAttr>(
                getHardwareIdForMapping(mappingLevel, hwMapping),
                b.getDimIdentityMap(),
                b.getDimIdentityMap()));
        }

        (void)mlir::gpu::setMappingAttr(parallelOp, attrs);

        ++mappingLevel;
        // Parallel loop operations are immediately nested
        for (mlir::Operation &op : *parallelOp.getBody())
        {
            if (auto nested = llvm::dyn_cast<mlir::scf::ParallelOp>(op))
                mapParallelOp(nested, mappingLevel, mappingPolicy);
        }
    }

    struct SelectiveGPUConversionPass
        : public mlir::PassWrapper<SelectiveGPUConversionPass,
                                   mlir::OperationPass<mlir::ModuleOp>>
    {
        MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(SelectiveGPUConversionPass)

        void runOnOperation() override
        {
            mlir::ModuleOp module = getOperation();

            module.walk([&](TaskOp taskOp)
                        {
      if (!hasGPU(taskOp)) {
        return;
      }
      
      // Map parallel loops in this GPU task
      taskOp.walk([&](mlir::scf::ParallelOp parallelOp) {
        mapParallelOp(parallelOp, MapGrid, MappingPolicy::OutermostFirst);
      }); });
        }

    private:
        bool hasGPU(TaskOp taskOp)
        {
            auto attr = taskOp->getAttrOfType<mlir::TargetDeviceSpecAttr>("target");
            if (!attr)
                return false;

            if (auto dltiAttr = mlir::dyn_cast<mlir::TargetDeviceSpecAttr>(attr))
            {
                // Safely access the gpu_count entry
                auto entries = dltiAttr.getEntries();
                if (entries.size() > 4)
                {
                    if (auto gpuCntAttr = mlir::dyn_cast<mlir::IntegerAttr>(entries[4].getValue()))
                    {
                        return gpuCntAttr.getInt() > 0;
                    }
                }
            }
            return false;
        }
    };

} // namespace

std::unique_ptr<mlir::Pass> createSelectiveGPUConversionPass()
{
    return std::make_unique<SelectiveGPUConversionPass>();
}

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
        target.addLegalDialect<gpu::GPUDialect>();
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

std::unique_ptr<Pass> createConvertMPItoLLVM()
{
    return std::make_unique<LowerMPIDialectToLLVMPass>();
}

mlir::Value materializeOpFoldResult(OpFoldResult ofr, ConversionPatternRewriter &rewriter)
{
    if (auto val = ofr.dyn_cast<mlir::Value>())
        return val;
    if (auto attr = mlir::dyn_cast<mlir::Attribute>(ofr))
    {
        mlir::IntegerAttr intAttr = mlir::dyn_cast<mlir::IntegerAttr>(ofr.get<Attribute>());
        return rewriter.create<arith::ConstantIndexOp>(rewriter.getUnknownLoc(), intAttr.getValue().getSExtValue());
    }

    llvm_unreachable("Unsupported OpFoldResult kind");
}

static SmallVector<Value> materializeOpFoldResults(ConversionPatternRewriter &rewriter, ArrayRef<OpFoldResult> ofrs)
{
    SmallVector<Value> values;
    values.reserve(ofrs.size());
    for (OpFoldResult ofr : ofrs)
        values.push_back(materializeOpFoldResult(ofr, rewriter));
    return values;
}


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
        auto func = rewriter.create<mlir::func::FuncOp>(loc, op.getScheduleName(), funcType);

        Block *block = func.addEntryBlock();

        for (const auto &arg : llvm::enumerate(op.getRegion().getBlocks().front().getArguments()))
        {
            mapping.map(arg.value(), block->getArgument(arg.index()));
        }

        rewriter.setInsertionPointToEnd(block);

        for (auto allocOp : dependencyGraph.allocs)
        {
            auto newOp = rewriter.clone(*allocOp.getOperation());
            allocOp.getResult().replaceAllUsesWith(newOp->getResult(0));
        }

        // MPI Boilerplate
        auto retVal = mlir::mpi::RetvalType::get(rewriter.getContext());
        rewriter.create<mlir::mpi::InitOp>(loc, retVal);
        auto comm = rewriter.create<mlir::mpi::CommWorldOp>(loc, mlir::mpi::CommType::get(rewriter.getContext()));
        auto rank = rewriter.create<mpi::CommRankOp>(loc, rewriter.getI32Type(), comm->getResult(0));
        auto getNodes = rewriter.create<mpi::CommSizeOp>(loc, mpi::RetvalType::get(rewriter.getContext()), rewriter.getI32Type(), comm->getResult(0));

        // End of MPI Boilerplate

        // Check if there's a scf.for loop wrapping the tasks
        mlir::scf::ForOp outerLoop = nullptr;
        for (auto &innerOp : op.getBodyRegion().front().getOperations())
        {
            if (auto forOp = mlir::dyn_cast<mlir::scf::ForOp>(innerOp))
            {
                outerLoop = forOp;
                llvm::errs() << "Found scf.for loop wrapping tasks\n";
                break;
            }
        }

        // Clone constants and non-task, non-loop operations
        for (auto &innerOp : op.getBodyRegion().front().getOperations())
        {
            if (mlir::isa<mlir::avial::TaskOp>(innerOp) || 
                mlir::isa<mlir::avial::YieldOp>(innerOp) || 
                mlir::isa<mlir::scf::ForOp>(innerOp))
                continue;

            Operation *cloned = rewriter.clone(innerOp, mapping);
        }

        // If there's a loop, clone it and set insertion point inside
        mlir::scf::ForOp newForOp = nullptr;
        if (outerLoop)
        {
            llvm::errs() << "Cloning scf.for loop structure\n";
            
            // Map loop bounds
            Value lowerBound = mapping.lookupOrDefault(outerLoop.getLowerBound());
            Value upperBound = mapping.lookupOrDefault(outerLoop.getUpperBound());
            Value step = mapping.lookupOrDefault(outerLoop.getStep());
            
            // Create new loop
            newForOp = rewriter.create<mlir::scf::ForOp>(loc, lowerBound, upperBound, step);
            
            // Map the induction variable
            mapping.map(outerLoop.getInductionVar(), newForOp.getInductionVar());
            
            // Clone operations inside the loop (subviews, constants, etc.) EXCEPT tasks
            Block *loopBody = newForOp.getBody();
            rewriter.setInsertionPointToStart(loopBody);
            
            for (auto &loopOp : outerLoop.getBody()->getOperations())
            {
                if (mlir::isa<mlir::scf::YieldOp>(loopOp) || mlir::isa<mlir::avial::TaskOp>(loopOp))
                    continue;
                
                Operation *clonedOp = rewriter.clone(loopOp, mapping);
            }
            
            // Set insertion point at the END of loop body, before the yield
            // This is where we'll insert task execution and communication
            rewriter.setInsertionPoint(loopBody->getTerminator());
            
            llvm::errs() << "Insertion point set inside loop body\n";
        }

        llvm::errs() << "Size: " << dependencyGraph.levelVector.size() << "\n";

        // Lower the tasks (they will be inserted at current insertion point)
        for (std::vector<TaskOpInfo *> level : dependencyGraph.levelVector)
        {
            llvm::DenseMap<Value, Value> gpuBufferMap;
            llvm::SmallVector<Value> toBroadcast;
            int taskId = 0;
            
            for (auto task : level)
            {
                auto taskIDOp = rewriter.create<mlir::arith::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(taskId));
                auto taskIdModNodes = rewriter.create<mlir::arith::RemSIOp>(loc, taskIDOp->getResult(0), getNodes->getResult(1));
                auto cond = rewriter.create<arith::CmpIOp>(loc, rewriter.getI1Type(), arith::CmpIPredicate::eq, rank.getResult(0), taskIdModNodes.getResult());
                
                rewriter.create<mlir::scf::IfOp>(loc, cond, [&](OpBuilder &ifbuilder, Location loc)
                {
                    Block &taskBlock = task->op->getRegion(0).front(); 
                    IRMapping rankMapping = mapping; 

                    if (task->isGPU())
                    {
                        // Process all writes
                        for (auto writeOp : task->writes)
                        {
                            Value buffer = rankMapping.lookupOrNull(writeOp);
                            if (!buffer)
                                continue;
                                
                            auto subviewType = cast<MemRefType>(buffer.getType());
                            SmallVector<Value> dynamicSizes;
                            
                            for (int64_t i = 0; i < subviewType.getRank(); ++i)
                            {
                                if (subviewType.isDynamicDim(i))
                                {
                                    Value dimSize = ifbuilder.create<memref::DimOp>(loc, buffer, i);
                                    dynamicSizes.push_back(dimSize);
                                }
                            }
                            
                            auto cleanType = MemRefType::get(
                                subviewType.getShape(),
                                subviewType.getElementType(),
                                MemRefLayoutAttrInterface{},
                                subviewType.getMemorySpace());
                                
                            Value newBuffer = ifbuilder.create<memref::AllocOp>(loc, cleanType, dynamicSizes);
                            ifbuilder.create<memref::CopyOp>(loc, buffer, newBuffer);
                            
                            auto gpuAlloc = ifbuilder.create<gpu::AllocOp>(loc, TypeRange(newBuffer), 
                                                                        ValueRange{}, dynamicSizes, ValueRange{});
                            Value gpuBuffer = gpuAlloc.getMemref();
                            ifbuilder.create<gpu::MemcpyOp>(loc, TypeRange{}, ValueRange{}, gpuBuffer, newBuffer);
                            
                            gpuBufferMap[gpuBuffer] = newBuffer;
                            rankMapping.map(writeOp, gpuBuffer);
                        }
                        
                        // Process all reads
                        for (auto readOp : task->reads)
                        {
                            Value buffer = rankMapping.lookupOrNull(readOp);
                            if (!buffer)
                                continue;
                                
                            auto subviewType = cast<MemRefType>(buffer.getType());
                            SmallVector<Value> dynamicSizes;
                            
                            for (int64_t i = 0; i < subviewType.getRank(); ++i)
                            {
                                if (subviewType.isDynamicDim(i))
                                {
                                    Value dimSize = ifbuilder.create<memref::DimOp>(loc, buffer, i);
                                    dynamicSizes.push_back(dimSize);
                                }
                            }
                            
                            auto cleanType = MemRefType::get(
                                subviewType.getShape(),
                                subviewType.getElementType(),
                                MemRefLayoutAttrInterface{},
                                subviewType.getMemorySpace());
                                
                            Value newBuffer = ifbuilder.create<memref::AllocOp>(loc, cleanType, dynamicSizes);
                            ifbuilder.create<memref::CopyOp>(loc, buffer, newBuffer);
                            
                            auto gpuAlloc = ifbuilder.create<gpu::AllocOp>(loc, TypeRange(newBuffer), 
                                                                        ValueRange{}, dynamicSizes, ValueRange{});
                            Value gpuBuffer = gpuAlloc.getMemref();
                            ifbuilder.create<gpu::MemcpyOp>(loc, TypeRange{}, ValueRange{}, gpuBuffer, newBuffer);
                            
                            gpuBufferMap[gpuBuffer] = newBuffer;
                            rankMapping.map(readOp, gpuBuffer);
                        }
                    } 

                    for (auto &op : taskBlock) {
                        if (mlir::isa<mlir::avial::YieldOp>(op))
                            continue;
                    
                        Operation *clonedOp = ifbuilder.clone(op, rankMapping);
                    } 

                    if(task->isGPU())
                    {
                        // Process all writes - copy back from GPU to host
                        for (auto writeOp : task->writes)
                        {
                            Value gpuBuffer = rankMapping.lookupOrNull(writeOp);
                            if (!gpuBuffer)
                                continue;
                                
                            ifbuilder.create<gpu::MemcpyOp>(loc, TypeRange{}, ValueRange{}, 
                                                            gpuBufferMap[gpuBuffer], gpuBuffer);
                            
                            ifbuilder.create<memref::CopyOp>(loc, gpuBufferMap[gpuBuffer], 
                                                            mapping.lookupOrNull(writeOp));
                        }
                    }

                    ifbuilder.create<mlir::scf::YieldOp>(loc);
                });

                ++taskId;
            }

            rewriter.create<mpi::Barrier>(loc, retVal, comm->getResult(0));

            // Communication code
            auto one = rewriter.create<mlir::arith::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(1));
            auto zero = rewriter.create<mlir::arith::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(0));
            auto tag = rewriter.create<mlir::arith::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(0));

            taskId = 0;

            for (auto task : level)
            {
                auto taskOp = dyn_cast<mlir::avial::TaskOp>(task->op);
                llvm::ArrayRef outRanges = taskOp.getOutRanges();
                
                // Get the base buffer from mapping (now subviews are in mapping!)
                Value buffer = mapping.lookupOrNull(task->writes[0]);
                
                if (!buffer) {
                    llvm::errs() << "ERROR: Buffer not found in mapping\n";
                    return failure();
                }

                Value sourceBuffer = buffer;
                
                // Unwrap subviews to get base buffer
                while (auto defOp = sourceBuffer.getDefiningOp())
                {
                    if (auto subviewOp = mlir::dyn_cast<memref::SubViewOp>(defOp))
                        sourceBuffer = subviewOp.getSource();
                    else
                        break;
                }

                auto sourceType = cast<MemRefType>(sourceBuffer.getType());
                int64_t sourceRank = sourceType.getRank();

                SmallVector<OpFoldResult> offsets;
                SmallVector<OpFoldResult> sizes;
                SmallVector<OpFoldResult> strides;
                
                if (sourceRank == 1)
                {
                    offsets.push_back(rewriter.getIndexAttr(outRanges[0]));
                    sizes.push_back(rewriter.getIndexAttr(outRanges[1] - outRanges[0]));
                    strides.push_back(rewriter.getIndexAttr(1));
                }
                else if(sourceRank == 2)
                {
                    offsets = {
                        rewriter.getIndexAttr(outRanges[0]),
                        rewriter.getIndexAttr(0)
                    };
                    sizes = {
                        rewriter.getIndexAttr((outRanges[1] - outRanges[0]) * 1000),
                        rewriter.getIndexAttr(1000)
                    };
                    strides = {
                        rewriter.getIndexAttr(1),
                        rewriter.getIndexAttr(1)
                    };
                }
                else
                {
                    llvm::errs() << "[Error] Unsupported Memref rank\n";
                    return failure();
                }

                Value subBuffer = rewriter.create<memref::SubViewOp>(
                    loc, sourceBuffer, offsets, sizes, strides);

                // Default Communication
                auto cond = rewriter.create<arith::CmpIOp>(loc, rewriter.getI1Type(), arith::CmpIPredicate::eq, rank.getResult(0), zero.getResult());
                auto ifOp = rewriter.create<mlir::scf::IfOp>(loc, mlir::TypeRange{}, cond, true);
                OpBuilder thenBuilder = ifOp.getThenBodyBuilder(rewriter.getListener());
                OpBuilder elseBuilder = ifOp.getElseBodyBuilder(rewriter.getListener());

                // Receive
                auto taskIDOp = thenBuilder.create<mlir::arith::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(taskId));
                auto taskIdModNodes = thenBuilder.create<mlir::arith::RemSIOp>(loc, taskIDOp->getResult(0), getNodes->getResult(1));
                auto innercond = thenBuilder.create<arith::CmpIOp>(loc, rewriter.getI1Type(), arith::CmpIPredicate::ne, zero.getResult(), taskIdModNodes.getResult());
                auto innerIf = thenBuilder.create<mlir::scf::IfOp>(loc, mlir::TypeRange{}, innercond, false);
                auto innerThenBuilder = innerIf.getThenBodyBuilder(thenBuilder.getListener());

                auto recvOp = innerThenBuilder.create<mlir::mpi::RecvOp>(
                    loc, retVal, subBuffer, tag.getResult(), taskIdModNodes->getResult(0), comm->getResult(0));

                // Send
                auto elsetaskIDOp = elseBuilder.create<mlir::arith::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(taskId));
                auto elsetaskIdModNodes = elseBuilder.create<mlir::arith::RemSIOp>(loc, elsetaskIDOp->getResult(0), getNodes->getResult(1));
                auto elsecond = elseBuilder.create<arith::CmpIOp>(loc, rewriter.getI1Type(), arith::CmpIPredicate::eq, rank.getResult(0), elsetaskIdModNodes.getResult());
                auto elseinnerIf = elseBuilder.create<mlir::scf::IfOp>(loc, mlir::TypeRange{}, elsecond, false);
                auto elseinnerThenBuilder = elseinnerIf.getThenBodyBuilder(elseBuilder.getListener());

                auto sendOp = elseinnerThenBuilder.create<mlir::mpi::SendOp>(
                    loc, retVal, subBuffer, tag.getResult(), zero, comm->getResult(0));

                // Broadcast
                BoolAttr needBroadcast = mlir::dyn_cast<mlir::BoolAttr>(taskOp->getAttr("needBroadcast"));
                if (needBroadcast && needBroadcast.getValue())
                    toBroadcast.push_back(subBuffer);

                ++taskId;
            }

            generateBroadcastCommunication(
                rewriter, loc, toBroadcast, rank.getResult(0), zero.getResult(),
                comm->getResult(0), retVal, tag.getResult(), getNodes->getResult(1));

            toBroadcast.clear();
        }

        // If we created a loop, close it
        if (newForOp)
        {
            // Insertion point is already before the loop's yield, so we're good
            llvm::errs() << "Loop structure complete\n";
            // Set insertion point after the loop for final barrier and return
            rewriter.setInsertionPointAfter(newForOp.getOperation());
        }
        else
        {
            // No loop case - insertion point is already at end of block
            llvm::errs() << "No loop - continuing at end of block\n";
        }

        // Final barrier and return (outside the loop or at end of function)
        rewriter.create<mpi::Barrier>(loc, retVal, comm->getResult(0));
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

            void getDependentDialects(DialectRegistry &registry) const override
            {
                registry.insert<
                    mlir::gpu::GPUDialect,
                    mlir::memref::MemRefDialect,
                    mlir::arith::ArithDialect,
                    mlir::scf::SCFDialect,
                    mlir::func::FuncDialect,
                    mlir::mpi::MPIDialect,
                    mlir::LLVM::LLVMDialect>();
            }

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
                target.addLegalDialect<mlir::gpu::GPUDialect>();

                target.addIllegalOp<avial::ScheduleOp>();

                targetReplicateOp.addLegalDialect<mlir::arith::ArithDialect>();
                targetReplicateOp.addLegalDialect<mlir::scf::SCFDialect>();

                targetReplicateOp.addLegalOp<mlir::avial::TaskOp>();
                targetReplicateOp.addIllegalOp<avial::ReplicateOp>();
                targetReplicateOp.addLegalOp<mlir::avial::YieldOp>();
                targetReplicateOp.addLegalDialect<mlir::memref::MemRefDialect>();

                targetTaskOp.addLegalDialect<mlir::omp::OpenMPDialect>();
                // targetTaskOp.addIllegalDialect<mlir::scf::SCFDialect>();
                // targetTaskOp.addIllegalOp<mlir::scf::ForOp>();
                targetTaskOp.addLegalOp<mlir::omp::ParallelOp>();
                targetTaskOp.markOpRecursivelyLegal<mlir::omp::ParallelOp>();
                targetTaskOp.addLegalDialect<mlir::avial::AvialDialect>();
                targetTaskOp.addLegalDialect<mlir::arith::ArithDialect>();

                // RewritePatternSet avialpatterns(context);
                // avialpatterns.add<ConvertReplicateOp>(context);

                // if (failed(applyPartialConversion(module, targetReplicateOp, std::move(avialpatterns))))
                // {
                //     signalPassFailure();
                // }

                // RewritePatternSet taskPattern(context);
                // taskPattern.add<ConvertTaskOp>(context);

                // if (failed(applyPartialConversion(module, targetTaskOp, std::move(taskPattern))))
                // {
                //     signalPassFailure();
                // }

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
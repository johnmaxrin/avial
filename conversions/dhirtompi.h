#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"
#include <functional>
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/Verifier.h"

#include "includes/dhirDialect.h"
#include "includes/dhirTypes.h"
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
using namespace dhir;

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
                if (auto gpuCntAttr = mlir::dyn_cast_or_null<mlir::IntegerAttr>(getDeviceAttribute(dltiAttr, "gpu_count"))) {
                    return gpuCntAttr.getInt() > 0;
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

static Value createRuntimeTopology(ModuleOp module, ConversionPatternRewriter &rewriter, Location loc)
{
    auto devicesAttr = module->getAttrOfType<ArrayAttr>("dhir.target_devices");
    assert(devicesAttr && "No dhir.target_devices attribute found");

    struct NodeInfo
    {
        std::string nodeIdGlobalName;
        std::string archGlobalName;
        int gpuCount;
        float cost;
    };

    SmallVector<NodeInfo> nodes;

    auto ptrTy = LLVM::LLVMPointerType::get(rewriter.getContext());

    // create LLVM structs to pass on to buildRankNodeMaps - has to mirror RuntimeNode/RuntimeTopology memory layout expected by runtime library
    auto runtimeNodeTy = LLVM::LLVMStructType::getLiteral(rewriter.getContext(), {ptrTy, ptrTy, rewriter.getI32Type(), rewriter.getF32Type()});
    auto runtimeTopologyTy = LLVM::LLVMStructType::getLiteral(rewriter.getContext(), {rewriter.getI32Type(), ptrTy});

    auto llvmI8Type = IntegerType::get(rewriter.getContext(), 8);

    int nodeIdx = 0;

    for (auto deviceAttr : devicesAttr)
    {
        auto targetSpec = cast<mlir::TargetDeviceSpecAttr>(deviceAttr);
        auto nodeIdAttr = getDeviceAttribute(targetSpec, "node_id");
        auto archAttr = getDeviceAttribute(targetSpec, "arch");
        auto gpuCountAttr = getDeviceAttribute(targetSpec, "gpu_count");
        auto costAttr = getDeviceAttribute(targetSpec, "cost");

        std::string nodeIdTerminated = cast<StringAttr>(nodeIdAttr).getValue().str();
        nodeIdTerminated.push_back('\0');

        std::string archTerminated = cast<StringAttr>(archAttr).getValue().str();
        archTerminated.push_back('\0');

        std::string nodeIdGlobalName = "node_str_" + std::to_string(nodeIdx);
        std::string archGlobalName = "arch_str_" + std::to_string(nodeIdx);
        auto nodeIdStringType = LLVM::LLVMArrayType::get(llvmI8Type, nodeIdTerminated.size());
        auto nodeIdStringAttr = StringAttr::get(rewriter.getContext(), StringRef(nodeIdTerminated.data(), nodeIdTerminated.size()));
        auto archStringType = LLVM::LLVMArrayType::get(llvmI8Type, archTerminated.size());
        auto archStringAttr = StringAttr::get(rewriter.getContext(), StringRef(archTerminated.data(), archTerminated.size()));

        if (!module.lookupSymbol<LLVM::GlobalOp>(nodeIdGlobalName))
        {
            OpBuilder::InsertionGuard guard(rewriter);
            rewriter.setInsertionPointToStart(module.getBody());

            // emit global string constants containing node hostnames
            rewriter.create<LLVM::GlobalOp>(loc, nodeIdStringType, true, LLVM::Linkage::Internal, nodeIdGlobalName, nodeIdStringAttr);
        }

        if (!module.lookupSymbol<LLVM::GlobalOp>(archGlobalName))
        {
            OpBuilder::InsertionGuard guard(rewriter);
            rewriter.setInsertionPointToStart(module.getBody());

            // emit global string constants containing node cpu arch
            rewriter.create<LLVM::GlobalOp>(loc, archStringType, true, LLVM::Linkage::Internal, archGlobalName, archStringAttr);
        }

        NodeInfo info;

        info.nodeIdGlobalName = nodeIdGlobalName;
        info.archGlobalName = archGlobalName;
        info.gpuCount = cast<IntegerAttr>(gpuCountAttr).getInt();
        info.cost = cast<FloatAttr>(costAttr).getValueAsDouble();

        nodes.push_back(info);
        nodeIdx++;
    }

    // allocate RuntimeNode[] on the stack
    Value numNodes = rewriter.create<LLVM::ConstantOp>(loc, rewriter.getI64Type(), rewriter.getI64IntegerAttr(nodes.size()));
    Value nodeArray = rewriter.create<LLVM::AllocaOp>(loc, ptrTy, runtimeNodeTy, numNodes);

    Value zeroI64 = rewriter.create<LLVM::ConstantOp>(loc, rewriter.getI64Type(), rewriter.getI64IntegerAttr(0));
    Value zeroI32 = rewriter.create<LLVM::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(0));
    Value oneI64 = rewriter.create<LLVM::ConstantOp>(loc, rewriter.getI64Type(), rewriter.getI64IntegerAttr(1));
    Value oneI32 = rewriter.create<LLVM::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(1));
    Value twoI32 = rewriter.create<LLVM::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(2));
    Value threeI32 = rewriter.create<LLVM::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(3));

    // populate RuntimeNode entries from collected topology information
    for (size_t i = 0; i < nodes.size(); i++)
    {
        Value nodeIndex = rewriter.create<LLVM::ConstantOp>(loc, rewriter.getI64Type(), rewriter.getI64IntegerAttr(i));
        Value nodePtr = rewriter.create<LLVM::GEPOp>(loc, ptrTy, runtimeNodeTy, nodeArray, ValueRange{nodeIndex});
        Value nodeString = rewriter.create<LLVM::AddressOfOp>(loc, ptrTy, nodes[i].nodeIdGlobalName);
        Value archString = rewriter.create<LLVM::AddressOfOp>(loc, ptrTy, nodes[i].archGlobalName);
        Value nodeIdField = rewriter.create<LLVM::GEPOp>(loc, ptrTy, runtimeNodeTy, nodePtr, ValueRange{zeroI64, zeroI32});
        Value archField = rewriter.create<LLVM::GEPOp>(loc, ptrTy, runtimeNodeTy, nodePtr, ValueRange{zeroI64, oneI32});
        Value gpuCountField = rewriter.create<LLVM::GEPOp>(loc, ptrTy, runtimeNodeTy, nodePtr, ValueRange{zeroI64, twoI32});
        Value costField = rewriter.create<LLVM::GEPOp>(loc, ptrTy, runtimeNodeTy, nodePtr, ValueRange{zeroI64, threeI32});

        rewriter.create<LLVM::StoreOp>(loc, nodeString, nodeIdField);
        rewriter.create<LLVM::StoreOp>(loc, archString, archField);
        rewriter.create<LLVM::StoreOp>(loc, rewriter.create<LLVM::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(nodes[i].gpuCount)), gpuCountField);
        rewriter.create<LLVM::StoreOp>(loc, rewriter.create<LLVM::ConstantOp>(loc, rewriter.getF32Type(), rewriter.getF32FloatAttr(nodes[i].cost)), costField);
    }

    // build RuntimeTopology pointing at the node array
    Value topology = rewriter.create<LLVM::AllocaOp>(loc, ptrTy, runtimeTopologyTy, oneI64);

    Value numNodesField = rewriter.create<LLVM::GEPOp>(loc, ptrTy, runtimeTopologyTy, topology, ValueRange{zeroI64, zeroI32});

    Value nodesField = rewriter.create<LLVM::GEPOp>(loc, ptrTy, runtimeTopologyTy, topology, ValueRange{zeroI64, oneI32});

    Value numNodesConst = rewriter.create<LLVM::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(nodes.size()));

    rewriter.create<LLVM::StoreOp>(loc, numNodesConst, numNodesField);
    rewriter.create<LLVM::StoreOp>(loc, nodeArray, nodesField);

    return topology;
}

struct ConvertScheduleOp : public OpConversionPattern<mlir::dhir::ScheduleOp>
{
    using OpConversionPattern::OpConversionPattern;

    LogicalResult matchAndRewrite(
        mlir::dhir::ScheduleOp op, OpAdaptor adaptor,
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

        Value topology = createRuntimeTopology(module, rewriter, loc);

        auto devicesAttr = module->getAttrOfType<ArrayAttr>("dhir.target_devices");
        int numNodes = devicesAttr.size();

        auto mapType = MemRefType::get({numNodes}, rewriter.getI32Type());

        // allocate rank-node mapping tables for runtime initialization
        Value rankToNodeMap = rewriter.create<memref::AllocOp>(loc, mapType);
        Value nodeToRankMap = rewriter.create<memref::AllocOp>(loc, mapType);

        auto ptrTy = LLVM::LLVMPointerType::get(rewriter.getContext());

        // extract aligned pointers so we can pass raw pointers instead of a memref descriptor to the runtime function
        Value rankMapIdxPtr = rewriter.create<memref::ExtractAlignedPointerAsIndexOp>(loc, rankToNodeMap);
        Value nodeMapIdxPtr = rewriter.create<memref::ExtractAlignedPointerAsIndexOp>(loc, nodeToRankMap);

        Value rankMapI64 = rewriter.create<arith::IndexCastOp>(loc, rewriter.getI64Type(), rankMapIdxPtr);
        Value nodeMapI64 = rewriter.create<arith::IndexCastOp>(loc, rewriter.getI64Type(), nodeMapIdxPtr);

        Value rankMapPtr = rewriter.create<LLVM::IntToPtrOp>(loc, ptrTy, rankMapI64);
        Value nodeMapPtr = rewriter.create<LLVM::IntToPtrOp>(loc, ptrTy, nodeMapI64);

        auto runtimeFunc = module.lookupSymbol<func::FuncOp>("buildRankNodeMaps");

        // declare the runtime helper if it has not been emitted yet
        if (!runtimeFunc)
        {
            OpBuilder::InsertionGuard guard(rewriter);
            rewriter.setInsertionPointToStart(&module.getBodyRegion().front());

            auto fnType = rewriter.getFunctionType({topology.getType(), ptrTy, ptrTy}, {});
            runtimeFunc = rewriter.create<func::FuncOp>(loc, "buildRankNodeMaps", fnType);
            runtimeFunc.setPrivate();
        }

        // emit a call to the runtime function buildRankNodeMaps
        rewriter.create<func::CallOp>(loc, runtimeFunc, ValueRange{topology, rankMapPtr, nodeMapPtr});

        Value rankIndex = rewriter.create<arith::IndexCastOp>(loc, rewriter.getIndexType(), rank.getResult(0));
        Value rankNode = rewriter.create<memref::LoadOp>(loc, rankToNodeMap, ValueRange{rankIndex});

        // we take target device information from the taskOp rather than relying on ordering in the DLTI attributes
        DenseMap<Attribute, int> deviceToIndex;

        for (auto [idx, dev] : llvm::enumerate(devicesAttr))
            deviceToIndex[dev] = idx;

        llvm::errs() << "Size: " << dependencyGraph.levelVector.size() << "\n";

        // Which scheduling level each task belongs to, so that walking the body
        // in program order can emit a level the moment its first task is
        // reached.
        llvm::DenseMap<mlir::Operation *, size_t> taskToLevel;
        for (size_t li = 0; li < dependencyGraph.levelVector.size(); ++li)
            for (auto *task : dependencyGraph.levelVector[li])
                taskToLevel[task->op] = li;

        std::vector<bool> levelEmitted(dependencyGraph.levelVector.size(), false);

        // Lower one level: task bodies, barrier, gather, broadcast. Emitted at
        // whatever the current insertion point is.
        auto emitLevel = [&](const std::vector<TaskOpInfo *> &level) -> LogicalResult
        {
            llvm::DenseMap<Value, Value> gpuBufferMap;
            llvm::SmallVector<Value> toBroadcast;

            for (auto task : level)
            {
                auto taskOp = dyn_cast<dhir::TaskOp>(task->op);
                Attribute targetDevice = taskOp.getTarget();

                // if task target device has no matches in the deviceToIndex map, something is broken on our end.
                // this should not create UB on the users' end
                assert(deviceToIndex.count(targetDevice) && "Task target device not found in deviceToIndex map");

                int targetNodeIdx = deviceToIndex[targetDevice];

                auto targetNode = rewriter.create<arith::ConstantIntOp>(loc, targetNodeIdx, 32);
                auto cond = rewriter.create<arith::CmpIOp>(loc, rewriter.getI1Type(), arith::CmpIPredicate::eq, rankNode, targetNode);

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
                        if (mlir::isa<mlir::dhir::YieldOp>(op))
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

                    ifbuilder.create<mlir::scf::YieldOp>(loc); });
            }

            rewriter.create<mpi::Barrier>(loc, retVal, comm->getResult(0));

            // Communication code
            auto tag = rewriter.create<mlir::arith::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(0));

            for (auto task : level)
            {
                auto taskOp = dyn_cast<mlir::dhir::TaskOp>(task->op);
                Attribute targetDevice = taskOp.getTarget();

                assert(deviceToIndex.count(targetDevice) && "Task target device not found in deviceToIndex map");

                int targetNodeIdx = deviceToIndex[targetDevice];

                llvm::ArrayRef outRanges = taskOp.getOutRanges();
                
                // Get the base buffer from mapping (now subviews are in mapping!)
                for (auto writeOp : task->writes)
                {
                    Value buffer = mapping.lookupOrNull(writeOp);

                    if (!buffer)
                    {
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
                    else if (sourceRank == 2)
                    {
                        auto shape = sourceType.getShape();
                        offsets = {
                            rewriter.getIndexAttr(outRanges[0]),
                            rewriter.getIndexAttr(0)
                        };
                        sizes = {
                            rewriter.getIndexAttr((outRanges[1] - outRanges[0])),
                            rewriter.getIndexAttr(shape[1])
                        };
                        strides = {
                            rewriter.getIndexAttr(1),
                            rewriter.getIndexAttr(1)
                        };
                    }
                    else if (sourceRank == 3)
                    {
                        // Partition along dim 0 (i), communicate the [start, end) slice.
                        // dims 1 (j) and 2 (k) are transferred in full, matching the
                        // same pattern used for rank-2 above.
                        auto shape = sourceType.getShape();
                        offsets = {
                            rewriter.getIndexAttr(outRanges[0]),
                            rewriter.getIndexAttr(0),
                            rewriter.getIndexAttr(0)
                        };
                        sizes = {
                            rewriter.getIndexAttr(outRanges[1] - outRanges[0]),
                            rewriter.getIndexAttr(shape[1]),
                            rewriter.getIndexAttr(shape[2])
                        };
                        strides = {
                            rewriter.getIndexAttr(1),
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

                    // gather non-root results onto node 0
                    if (targetNodeIdx != 0)
                    {
                        Value rootNodeIndex = rewriter.create<arith::ConstantIndexOp>(loc, 0);
                        Value rootRank = rewriter.create<memref::LoadOp>(loc, nodeToRankMap, ValueRange{rootNodeIndex});

                        Value ownerNodeIndex = rewriter.create<arith::ConstantIndexOp>(loc, targetNodeIdx);
                        Value ownerRank = rewriter.create<memref::LoadOp>(loc, nodeToRankMap, ValueRange{ownerNodeIndex});

                        auto isRoot = rewriter.create<arith::CmpIOp>(loc, rewriter.getI1Type(), arith::CmpIPredicate::eq, rank.getResult(0), rootRank);
                        auto isOwner = rewriter.create<arith::CmpIOp>(loc, rewriter.getI1Type(), arith::CmpIPredicate::eq, rank.getResult(0), ownerRank);

                        auto ifOp = rewriter.create<mlir::scf::IfOp>(loc, mlir::TypeRange{}, isRoot, true);
                        OpBuilder thenBuilder = ifOp.getThenBodyBuilder(rewriter.getListener());
                        OpBuilder elseBuilder = ifOp.getElseBodyBuilder(rewriter.getListener());

                        thenBuilder.create<mlir::mpi::RecvOp>(loc, retVal, subBuffer, tag.getResult(), ownerRank, comm->getResult(0));

                        auto sendIf = elseBuilder.create<mlir::scf::IfOp>(loc, mlir::TypeRange{}, isOwner, false);
                        auto sendBuilder = sendIf.getThenBodyBuilder(elseBuilder.getListener());
                        sendBuilder.create<mlir::mpi::SendOp>(loc, retVal, subBuffer, tag.getResult(), rootRank, comm->getResult(0));
                    }

                    // Broadcast
                    BoolAttr needBroadcast = mlir::dyn_cast<mlir::BoolAttr>(taskOp->getAttr("needBroadcast"));
                    if (needBroadcast && needBroadcast.getValue())
                        toBroadcast.push_back(subBuffer);
                }
            }

            Value broadcastRootNodeIndex = rewriter.create<arith::ConstantIndexOp>(loc, 0);
            Value broadcastRootRank = rewriter.create<memref::LoadOp>(loc, nodeToRankMap, ValueRange{broadcastRootNodeIndex});

            generateBroadcastCommunication(
                rewriter, loc, toBroadcast, rank.getResult(0), broadcastRootRank,
                comm->getResult(0), retVal, tag.getResult(), getNodes->getResult(1));

            toBroadcast.clear();

            return success();
        };

        // Emit a block in program order.
        //
        // Two passes, because the block mixes two kinds of operation with
        // different requirements:
        //
        //   setup (constants, subviews, buffers) is referenced by tasks that
        //   may appear anywhere later, so it must all be available before the
        //   first level is emitted;
        //
        //   real computation must keep its position relative to the tasks.
        // 
        //   atax's converge body is
        //     replicate(tmp[i] += A[i][j]*x[j]) ; for j { y[j] += A[i][j]*tmp[i] }
        //   second loop depends on that prev replicate, so cant mess ordering
        //   atax failed due to this, fixed after fixing ordering
        //
        // Order also settles nesting depth: a replicate that was a
        // sibling of the converge loop is reached before the loop is entered,
        // so it is emitted once rather than once per iteration.
        auto isSetup = [](Operation *o) {
            return mlir::isMemoryEffectFree(o) ||
                   mlir::isa<mlir::memref::AllocOp, mlir::memref::AllocaOp>(o);
        };

        std::function<LogicalResult(Block &)> emitBody = [&](Block &body) -> LogicalResult
        {
            for (Operation &bodyOp : body)
            {
                if (mlir::isa<mlir::dhir::TaskOp>(bodyOp) ||
                    mlir::isa<mlir::dhir::YieldOp>(bodyOp) ||
                    mlir::isa<mlir::scf::YieldOp>(bodyOp))
                    continue;
                if (isSetup(&bodyOp))
                    rewriter.clone(bodyOp, mapping);
            }

            for (Operation &bodyOp : body)
            {
                if (mlir::isa<mlir::dhir::YieldOp>(bodyOp) ||
                    mlir::isa<mlir::scf::YieldOp>(bodyOp))
                    continue;

                if (mlir::isa<mlir::dhir::TaskOp>(bodyOp))
                {
                    // Tasks of one level are independent, so the whole level is
                    // emitted as a group at the position of its first task.
                    auto it = taskToLevel.find(&bodyOp);
                    if (it == taskToLevel.end() || levelEmitted[it->second])
                        continue;

                    levelEmitted[it->second] = true;
                    if (failed(emitLevel(dependencyGraph.levelVector[it->second])))
                        return failure();
                    continue;
                }

                if (isSetup(&bodyOp))
                    continue; // already cloned above

                if (auto forOp = mlir::dyn_cast<mlir::scf::ForOp>(bodyOp))
                {
                    bool wrapsTasks = false;
                    forOp.walk([&](mlir::dhir::TaskOp) { wrapsTasks = true; });

                    if (wrapsTasks)
                    {
                        llvm::errs() << "Rebuilding scf.for that wraps tasks\n";

                        Value lb = mapping.lookupOrDefault(forOp.getLowerBound());
                        Value ub = mapping.lookupOrDefault(forOp.getUpperBound());
                        Value step = mapping.lookupOrDefault(forOp.getStep());

                        auto newForOp = rewriter.create<mlir::scf::ForOp>(loc, lb, ub, step);
                        mapping.map(forOp.getInductionVar(), newForOp.getInductionVar());

                        rewriter.setInsertionPoint(newForOp.getBody()->getTerminator());

                        if (failed(emitBody(*forOp.getBody())))
                            return failure();

                        rewriter.setInsertionPointAfter(newForOp.getOperation());
                        continue;
                    }
                    // A loop with no tasks is redundant work that every rank
                    // repeats; clone it where it stands.
                }

                rewriter.clone(bodyOp, mapping);
            }
            return success();
        };

        if (failed(emitBody(op.getBodyRegion().front())))
            return failure();

        // Final barrier and return
        rewriter.create<mpi::Barrier>(loc, retVal, comm->getResult(0));
        rewriter.create<func::ReturnOp>(loc);
        rewriter.eraseOp(op);

        return success();
    }
};

namespace mlir
{
    namespace dhir
    {
#define GEN_PASS_DEF_CONVERTDHIRTOMPIPASS
#include "dialect/Passes.h.inc"

        struct ConvertDhirToMPIPass : public mlir::dhir::impl::ConvertDhirToMPIPassBase<ConvertDhirToMPIPass>
        {
            using ConvertDhirToMPIPassBase::ConvertDhirToMPIPassBase;

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

                target.addIllegalOp<dhir::ScheduleOp>();

                targetReplicateOp.addLegalDialect<mlir::arith::ArithDialect>();
                targetReplicateOp.addLegalDialect<mlir::scf::SCFDialect>();

                targetReplicateOp.addLegalOp<mlir::dhir::TaskOp>();
                targetReplicateOp.addIllegalOp<dhir::ReplicateOp>();
                targetReplicateOp.addLegalOp<mlir::dhir::YieldOp>();
                targetReplicateOp.addLegalDialect<mlir::memref::MemRefDialect>();

                targetTaskOp.addLegalDialect<mlir::omp::OpenMPDialect>();
                // targetTaskOp.addIllegalDialect<mlir::scf::SCFDialect>();
                // targetTaskOp.addIllegalOp<mlir::scf::ForOp>();
                targetTaskOp.addLegalOp<mlir::omp::ParallelOp>();
                targetTaskOp.markOpRecursivelyLegal<mlir::omp::ParallelOp>();
                targetTaskOp.addLegalDialect<mlir::dhir::DhirDialect>();
                targetTaskOp.addLegalDialect<mlir::arith::ArithDialect>();

                // RewritePatternSet dhirpatterns(context);
                // dhirpatterns.add<ConvertReplicateOp>(context);

                // if (failed(applyPartialConversion(module, targetReplicateOp, std::move(dhirpatterns))))
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
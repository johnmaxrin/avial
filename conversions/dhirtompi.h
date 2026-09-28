#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"
#include <cmath>
#include <functional>
#include <limits>
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/Verifier.h"

#include "includes/dhirDialect.h"
#include "includes/dhirTypes.h"
#include "includes/utils.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"

#include "mlir/Dialect/Index/IR/IndexDialect.h"
#include "mlir/Dialect/Math/IR/Math.h"

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
#include "analysis/syncHoisting.h"
#include "analysis/ownership.h"

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

// Allocate a buffer with the same type and runtime extents as `like`.  Used as
// the receive side of a reduction combine, so it must match element for element
// or the transfer count would disagree with the sender's.
static Value createMirrorBuffer(OpBuilder &builder, Location loc, Value like)
{
    auto type = cast<MemRefType>(like.getType());
    SmallVector<Value> dynSizes;
    for (unsigned dim = 0; dim < (unsigned)type.getRank(); ++dim)
        if (type.isDynamicDim(dim))
            dynSizes.push_back(builder.create<memref::DimOp>(loc, like, (int64_t)dim));
    return builder.create<memref::AllocOp>(loc, type, dynSizes);
}

// dst[i] += src[i] over the whole extent of both.
//
// The addition is modular across all bitwidths to preserve `arith.addi` semantics:
// signless i8/i16 does not imply unsigned saturation, and unflagged integer additions
// wrap on overflow. Inferring saturating behavior solely from narrow bitwidths
// miscompiled valid arithmetic — e.g., four i8 additions of 100 evaluate to 144
// (modular wrap), not a saturated 255.
//
// Saturating accumulation belongs to a different reduction algebra. Supporting it
// requires explicit proof from the source operation (such as a clamped RMW attribute),
// rather than an assumption based on type width.
static void emitElementwiseAccumulate(OpBuilder &builder, Location loc,
                                      Value dst, Value src)
{
    auto dstType = cast<MemRefType>(dst.getType());
    Type elemType = dstType.getElementType();

    SmallVector<Value> indices;
    std::function<void(unsigned)> emitDim = [&](unsigned dim) {
        if (dim == (unsigned)dstType.getRank())
        {
            Value current = builder.create<memref::LoadOp>(loc, dst, indices);
            Value incoming = builder.create<memref::LoadOp>(loc, src, indices);
            Value sum;
            if (isa<FloatType>(elemType))
                sum = builder.create<arith::AddFOp>(loc, current, incoming);
            else
                sum = builder.create<arith::AddIOp>(loc, current, incoming);
            builder.create<memref::StoreOp>(loc, sum, dst, indices);
            return;
        }

        Value lower = builder.create<arith::ConstantIndexOp>(loc, 0);
        Value upper;
        if (dstType.isDynamicDim(dim))
            upper = builder.create<memref::DimOp>(loc, dst, (int64_t)dim);
        else
            upper = builder.create<arith::ConstantIndexOp>(loc, dstType.getDimSize(dim));
        Value step = builder.create<arith::ConstantIndexOp>(loc, 1);
        auto forOp = builder.create<scf::ForOp>(loc, lower, upper, step);
        builder.setInsertionPointToStart(forOp.getBody());
        indices.push_back(forOp.getInductionVar());
        emitDim(dim + 1);
        indices.pop_back();
        builder.setInsertionPointAfter(forOp);
    };
    emitDim(0);
}

struct ConvertScheduleOp : public OpConversionPattern<mlir::dhir::ScheduleOp>
{
    using OpConversionPattern::OpConversionPattern;

    LogicalResult matchAndRewrite(
        mlir::dhir::ScheduleOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {

        bool unsupportedTaskNesting = false;
        op.walk([&](mlir::dhir::TaskOp task) {
            for (Operation *ancestor = task->getParentOp(); ancestor && ancestor != op;
                 ancestor = ancestor->getParentOp()) {
                if (!isa<mlir::scf::ForOp, mlir::scf::IfOp,
                         mlir::scf::WhileOp>(ancestor)) {
                    task.emitError("task is nested in unsupported control flow; "
                                   "expected scf.for/scf.if/scf.while ancestors");
                    unsupportedTaskNesting = true;
                    return;
                }
            }
        });
        if (unsupportedTaskNesting)
            return failure();

        auto module = op->getParentOfType<mlir::ModuleOp>();
        if (!module)
        {
            op.emitError("must be nested in a builtin.module");
            return failure();
        }

        // Do the dependence analysis.
        DependencyGraph dependencyGraph;
        dependencyGraph.build(op);
        dependencyGraph.printDiGraph();
        dependencyGraph.schedule();

        auto devicesAttr = module->getAttrOfType<ArrayAttr>("dhir.target_devices");
        if (!devicesAttr || devicesAttr.empty())
        {
            op.emitError("requires a non-empty dhir.target_devices attribute");
            return failure();
        }
        if (devicesAttr.size() > std::numeric_limits<int32_t>::max())
        {
            op.emitError("has too many target devices for the i32 runtime topology");
            return failure();
        }
        for (Attribute device : devicesAttr)
        {
            auto target = dyn_cast<TargetDeviceSpecAttr>(device);
            auto gpuCount = target ? getDeviceAttribute(target, "gpu_count") : Attribute();
            auto cost = target ? getDeviceAttribute(target, "cost") : Attribute();
            bool valid = target &&
                isa_and_nonnull<StringAttr>(getDeviceAttribute(target, "node_id")) &&
                isa_and_nonnull<StringAttr>(getDeviceAttribute(target, "arch")) &&
                isa_and_nonnull<IntegerAttr>(gpuCount) &&
                isa_and_nonnull<FloatAttr>(cost);
            if (valid)
            {
                valid = cast<IntegerAttr>(gpuCount).getInt() >= 0;
                double costValue = cast<FloatAttr>(cost).getValueAsDouble();
                valid = valid && std::isfinite(costValue) && costValue > 0.0;
            }
            if (!valid)
            {
                op.emitError("target devices require valid node_id, arch, gpu_count, and positive finite cost entries");
                return failure();
            }
        }

        // Now that we have the level vector. Let's generate code for it!

        llvm::SmallVector<mlir::Type> inputTypes;
        auto loc = op.getLoc();
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

        // MPI Boilerplate
        auto retVal = mlir::mpi::RetvalType::get(rewriter.getContext());
        rewriter.create<mlir::mpi::InitOp>(loc, retVal);
        auto comm = rewriter.create<mlir::mpi::CommWorldOp>(loc, mlir::mpi::CommType::get(rewriter.getContext()));
        auto rank = rewriter.create<mpi::CommRankOp>(loc, rewriter.getI32Type(), comm->getResult(0));
        auto getNodes = rewriter.create<mpi::CommSizeOp>(loc, mpi::RetvalType::get(rewriter.getContext()), rewriter.getI32Type(), comm->getResult(0));

        // End of MPI Boilerplate

        Value topology = createRuntimeTopology(module, rewriter, loc);

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
        if (deviceToIndex.size() != devicesAttr.size())
        {
            op.emitError("dhir.target_devices contains duplicate device specifications");
            return failure();
        }

        llvm::errs() << "Size: " << dependencyGraph.levelVector.size() << "\n";

        // Which scheduling level each task belongs to. A level becomes ready
        // when its last source task is reached, then ready levels are emitted
        // in topological order.
        llvm::DenseMap<mlir::Operation *, size_t> taskToLevel;
        std::vector<size_t> levelTasksRemaining(dependencyGraph.levelVector.size(), 0);
        for (size_t li = 0; li < dependencyGraph.levelVector.size(); ++li)
            for (auto *task : dependencyGraph.levelVector[li])
            {
                taskToLevel[task->op] = li;
                ++levelTasksRemaining[li];
            }

        std::vector<bool> levelEmitted(dependencyGraph.levelVector.size(), false);
        size_t nextLevelToEmit = 0;

        auto cloneAndMapResults = [&](OpBuilder &builder, Operation &source,
                                      IRMapping &valueMapping) {
            Operation *cloned = builder.clone(source, valueMapping);
            for (auto pair : llvm::zip(source.getResults(), cloned->getResults()))
                valueMapping.map(std::get<0>(pair), std::get<1>(pair));
            return cloned;
        };

        // ------------------------------------------------------------------
        // Deferred synchronization.
        //
        // A shard nested in a serial loop is synced once per iteration because
        // its output may feed the next one.  When the replicate lowering has
        // proved the shard slab-local (it sets `deferSync`; see
        // analysis/syncHoisting.h) that is pure waste: the rank only touches
        // its own slab, so one sync after the loop is enough.  The loop op is
        // not addressable while its body is built -- scf.for's body builder
        // runs off an OperationState -- so a frame records the body *block*,
        // collects the levels owing a sync, and is flushed once the rebuilt
        // loop materializes.
        // ------------------------------------------------------------------
        struct DeferFrame
        {
            Operation *originalLoop = nullptr; // the loop in the schedule IR
            Block *newBody = nullptr;          // the block being filled
            llvm::SmallVector<size_t> levels;  // levels owing a sync
            // True if this loop is a resident-stencil loop where input ghost
            // rows are exchanged inline each iteration and level gathers are
            // deferred until after loop exit. Determined purely from IR properties.
            bool resident = false;
        };
        llvm::SmallVector<DeferFrame> deferFrames;

        // Is `value` defined in `block`, or in a region nested inside it? Asked
        // while `block` is still being filled, so it climbs blocks rather than
        // asking the not-yet-created loop op for its region.
        auto definedInsideBlock = [](Value value, Block *block) -> bool {
            if (!block || !value)
                return false;
            Block *cur = nullptr;
            if (auto arg = dyn_cast<BlockArgument>(value))
                cur = arg.getOwner();
            else if (Operation *def = value.getDefiningOp())
                cur = def->getBlock();
            while (cur)
            {
                if (cur == block)
                    return true;
                Operation *parent = cur->getParentOp();
                cur = parent ? parent->getBlock() : nullptr;
            }
            return false;
        };

        // Could `value` be rebuilt after the loop whose body is `block`? Only
        // pure computation qualifies: a load could observe a later store, and a
        // value that bottoms out in the loop's induction variable or one of its
        // iteration arguments has no meaning outside the loop at all.
        std::function<bool(Value, Block *)> canRematerialize =
            [&](Value value, Block *block) -> bool {
            if (!definedInsideBlock(value, block))
                return true;
            Operation *def = value.getDefiningOp();
            if (!def || !mlir::isPure(def))
                return false;
            for (Value operand : def->getOperands())
                if (!canRematerialize(operand, block))
                    return false;
            return true;
        };

        // May this level's sync move out of `frame`'s loop? Slab locality was
        // settled by the replicate lowering; what is checked here is that the
        // emission can follow — the level defers as a whole, its shape is one a
        // single post-loop exchange still models, and every value the gather
        // needs survives outside the loop.
        auto canHoistLevelSync = [&](const std::vector<TaskOpInfo *> &level,
                                     const DeferFrame &frame) -> bool {
            if (level.empty() || !frame.newBody || !frame.originalLoop)
                return false;

            for (TaskOpInfo *task : level)
            {
                auto taskOp = dyn_cast<dhir::TaskOp>(task->op);
                if (!taskOp)
                    return false;

                if (frame.resident)
                {
                    // In resident-stencil loops, input ghost rows are exchanged
                    // inline each iteration; only the final full-array gather is
                    // deferred. Partial reductions reinitialize private buffers
                    // every iteration and cannot be deferred past the loop.
                    if (taskOp->hasAttr("partialReduce"))
                        return false;
                }
                else
                {
                    // The barrier and the broadcast are per level, so a level
                    // that is not uniformly deferrable stays where it is.
                    if (!taskOp->hasAttr("deferSync"))
                        return false;

                    // Partial reductions and standard stencils require immediate
                    // per-iteration boundary or accumulation synchronization.
                    if (taskOp->hasAttr("partialReduce") || taskOp->hasAttr("stencil"))
                        return false;
                }

                // The sync must land after the very loop the legality walk
                // inspected. Levels are released in topological order, which
                // can be a different place than where the task sits.
                if (mlir::dhir::nearestEnclosingSerialLoop(task->op) !=
                    frame.originalLoop)
                    return false;

                for (Value rangeOperand : taskOp.getRangeOperands())
                    if (!canRematerialize(mapping.lookupOrDefault(rangeOperand),
                                          frame.newBody))
                        return false;

                for (Value writeOp : task->writes)
                {
                    Value buffer = mapping.lookupOrNull(writeOp);
                    if (!buffer)
                        return false;
                    // The gather addresses the base allocation the shard view
                    // was carved from; a base created inside the loop dies with
                    // the iteration.
                    while (auto subview = dyn_cast_or_null<memref::SubViewOp>(
                               buffer.getDefiningOp()))
                        buffer = subview.getSource();
                    if (definedInsideBlock(buffer, frame.newBody))
                        return false;
                }
            }
            return true;
        };

        // The task bodies of one level, each guarded by a rank check. Emitted at
        // whatever the current insertion point is.
        auto emitLevelBodies = [&](const std::vector<TaskOpInfo *> &level) -> LogicalResult
        {
            llvm::DenseMap<Value, Value> gpuBufferMap;

            for (auto task : level)
            {
                auto taskOp = dyn_cast<dhir::TaskOp>(task->op);
                Attribute targetDevice = taskOp.getTarget();

                if (!deviceToIndex.count(targetDevice))
                {
                    taskOp.emitError("target device is not present in dhir.target_devices");
                    return failure();
                }

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
                    
                        cloneAndMapResults(ifbuilder, op, rankMapping);
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

            return success();
        };

        // The barrier, halo exchange, gather and broadcast of one level.
        // `hoistedOutOf` is null at the level's own position. When the sync was
        // deferred it is the body block of the loop it was lifted out of: the
        // shared mapping still holds that loop's in-flight clones, so every
        // value the exchange needs is rebuilt here instead of read from it.
        auto emitLevelSync = [&](const std::vector<TaskOpInfo *> &level,
                                 Block *hoistedOutOf) -> LogicalResult
        {
            llvm::SmallVector<Value> toBroadcast;

            llvm::DenseMap<Value, Value> rematerialized;
            std::function<Value(Value)> rematerialize = [&](Value value) -> Value {
                if (!definedInsideBlock(value, hoistedOutOf))
                    return value;
                if (Value cached = rematerialized.lookup(value))
                    return cached;
                Operation *def = value.getDefiningOp();
                if (!def || !mlir::isPure(def))
                    return Value();
                IRMapping operandMap;
                for (Value operand : def->getOperands())
                {
                    Value outer = rematerialize(operand);
                    if (!outer)
                        return Value();
                    operandMap.map(operand, outer);
                }
                Operation *cloned = rewriter.clone(*def, operandMap);
                for (auto pair : llvm::zip(def->getResults(), cloned->getResults()))
                    rematerialized[std::get<0>(pair)] = std::get<1>(pair);
                return rematerialized.lookup(value);
            };

            // A schedule value in a form that is usable at this insertion
            // point. Null only when a deferred sync needs something the loop
            // cannot give up, which the hoist check should already have
            // refused.
            auto syncValue = [&](Value original) -> Value {
                Value mapped = mapping.lookupOrDefault(original);
                if (!hoistedOutOf)
                    return mapped;
                return rematerialize(mapped);
            };
            rewriter.create<mpi::Barrier>(loc, retVal, comm->getResult(0));

            // Communication code
            auto tag = rewriter.create<mlir::arith::ConstantOp>(loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(0));

            auto getTaskNodeIndex = [&](dhir::TaskOp taskOp) -> std::optional<int> {
                auto it = deviceToIndex.find(taskOp.getTarget());
                if (it == deviceToIndex.end())
                    return std::nullopt;
                return it->second;
            };

            auto getTaskRange = [&](dhir::TaskOp taskOp) {
                std::pair<Value, Value> range;
                auto rangeOperands = taskOp.getRangeOperands();
                if (rangeOperands.size() == 2)
                {
                    range.first = syncValue(rangeOperands[0]);
                    range.second = syncValue(rangeOperands[1]);
                }
                else
                {
                    ArrayRef<int64_t> staticRange = taskOp.getOutRanges();
                    range.first = rewriter.create<arith::ConstantIndexOp>(
                        loc, staticRange[0]);
                    range.second = rewriter.create<arith::ConstantIndexOp>(
                        loc, staticRange[1]);
                }
                return range;
            };

            auto createAxisSubview = [&](Value buffer, int64_t partitionDim,
                                         Value start, Value size) -> Value {
                auto type = cast<MemRefType>(buffer.getType());
                SmallVector<OpFoldResult> offsets, sizes, strides;
                for (int64_t d = 0; d < type.getRank(); ++d)
                {
                    if (d == partitionDim)
                    {
                        offsets.push_back(start);
                        sizes.push_back(size);
                    }
                    else
                    {
                        offsets.push_back(rewriter.getIndexAttr(0));
                        sizes.push_back(type.isDynamicDim(d)
                            ? OpFoldResult(rewriter.create<memref::DimOp>(
                                  loc, buffer, d))
                            : OpFoldResult(rewriter.getIndexAttr(
                                  type.getDimSize(d))));
                    }
                    strides.push_back(rewriter.getIndexAttr(1));
                }
                return rewriter.create<memref::SubViewOp>(
                    loc, buffer, offsets, sizes, strides);
            };

            auto emitNeighborTransfer = [&](int senderNode, int receiverNode,
                                            Value sendView, Value recvView) {
                Value senderIndex = rewriter.create<arith::ConstantIndexOp>(
                    loc, senderNode);
                Value receiverIndex = rewriter.create<arith::ConstantIndexOp>(
                    loc, receiverNode);
                Value senderRank = rewriter.create<memref::LoadOp>(
                    loc, nodeToRankMap, ValueRange{senderIndex});
                Value receiverRank = rewriter.create<memref::LoadOp>(
                    loc, nodeToRankMap, ValueRange{receiverIndex});
                Value isSender = rewriter.create<arith::CmpIOp>(
                    loc, rewriter.getI1Type(), arith::CmpIPredicate::eq,
                    rank.getResult(0), senderRank);
                Value isReceiver = rewriter.create<arith::CmpIOp>(
                    loc, rewriter.getI1Type(), arith::CmpIPredicate::eq,
                    rank.getResult(0), receiverRank);

                auto ifOp = rewriter.create<scf::IfOp>(
                    loc, TypeRange{}, isSender, true);
                ifOp.getThenBodyBuilder(rewriter.getListener())
                    .create<mpi::SendOp>(loc, retVal, sendView,
                                         tag.getResult(), receiverRank,
                                         comm->getResult(0));
                OpBuilder elseBuilder =
                    ifOp.getElseBodyBuilder(rewriter.getListener());
                auto recvIf = elseBuilder.create<scf::IfOp>(
                    loc, TypeRange{}, isReceiver, true);
                recvIf.getThenBodyBuilder(elseBuilder.getListener())
                    .create<mpi::RecvOp>(loc, retVal, recvView,
                                         tag.getResult(), senderRank,
                                         comm->getResult(0));
                (void)recvIf.getElseBodyBuilder(elseBuilder.getListener());
            };

            // Stencil tasks keep inputs in global coordinates and write only
            // their owned output slab.  Exchange newly written boundary slabs
            // with adjacent owners before the gather, as two ordered blocking
            // handshakes per boundary (avoids send/send deadlock).
            bool emittedHaloExchange = false;
            for (TaskOpInfo *rightInfo : level)
            {
                // Skip output halo exchange when hoisted outside a loop:
                // resident-stencil loops already perform per-iteration input
                // halo exchanges inline, making a post-loop output halo redundant.
                if (hoistedOutOf)
                    break;
                auto rightTask = dyn_cast<dhir::TaskOp>(rightInfo->op);
                if (!rightTask || !rightTask->hasAttr("stencil"))
                    continue;
                std::optional<int> rightNode = getTaskNodeIndex(rightTask);
                if (!rightNode || *rightNode == 0)
                    continue;

                auto rightRepId = rightTask->getAttrOfType<IntegerAttr>("repId");
                TaskOpInfo *leftInfo = nullptr;
                dhir::TaskOp leftTask;
                for (TaskOpInfo *candidateInfo : level)
                {
                    auto candidate = dyn_cast<dhir::TaskOp>(candidateInfo->op);
                    if (!candidate || !candidate->hasAttr("stencil") ||
                        candidate->getAttrOfType<IntegerAttr>("repId") != rightRepId)
                        continue;
                    std::optional<int> candidateNode = getTaskNodeIndex(candidate);
                    if (candidateNode && *candidateNode == *rightNode - 1)
                    {
                        leftInfo = candidateInfo;
                        leftTask = candidate;
                        break;
                    }
                }
                if (!leftInfo)
                    continue;

                int64_t partitionDim = rightTask
                    ->getAttrOfType<IntegerAttr>("stencilPartitionDim").getInt();
                int64_t leftHaloRight = leftTask
                    ->getAttrOfType<IntegerAttr>("haloRight").getInt();
                int64_t rightHaloLeft = rightTask
                    ->getAttrOfType<IntegerAttr>("haloLeft").getInt();
                auto leftRange = getTaskRange(leftTask);
                auto rightRange = getTaskRange(rightTask);
                Value leftChunk = rewriter.create<arith::SubIOp>(
                    loc, leftRange.second, leftRange.first);
                Value rightChunk = rewriter.create<arith::SubIOp>(
                    loc, rightRange.second, rightRange.first);

                size_t outputCount = std::min(leftTask.getActualBuffer().size(),
                                              rightTask.getActualBuffer().size());
                auto leftDims = leftTask->getAttrOfType<DenseI64ArrayAttr>(
                    "outputPartitionDims");
                auto rightDims = rightTask->getAttrOfType<DenseI64ArrayAttr>(
                    "outputPartitionDims");
                for (size_t output = 0; output < outputCount; ++output)
                {
                    if (!leftDims || !rightDims ||
                        leftDims[output] != partitionDim ||
                        rightDims[output] != partitionDim ||
                        leftTask.getActualBuffer()[output] !=
                            rightTask.getActualBuffer()[output])
                        continue;

                    Value baseBuffer = syncValue(
                        leftTask.getActualBuffer()[output]);
                    if (rightHaloLeft > 0)
                    {
                        Value requested = rewriter.create<arith::ConstantIndexOp>(
                            loc, rightHaloLeft);
                        Value width = rewriter.create<arith::MinUIOp>(
                            loc, requested, leftChunk);
                        Value start = rewriter.create<arith::SubIOp>(
                            loc, leftRange.second, width);
                        Value sendView = createAxisSubview(
                            baseBuffer, partitionDim, start, width);
                        Value recvView = createAxisSubview(
                            baseBuffer, partitionDim, start, width);
                        emitNeighborTransfer(*rightNode - 1, *rightNode,
                                             sendView, recvView);
                        emittedHaloExchange = true;
                    }
                    if (leftHaloRight > 0)
                    {
                        Value requested = rewriter.create<arith::ConstantIndexOp>(
                            loc, leftHaloRight);
                        Value width = rewriter.create<arith::MinUIOp>(
                            loc, requested, rightChunk);
                        Value start = rightRange.first;
                        Value sendView = createAxisSubview(
                            baseBuffer, partitionDim, start, width);
                        Value recvView = createAxisSubview(
                            baseBuffer, partitionDim, start, width);
                        emitNeighborTransfer(*rightNode, *rightNode - 1,
                                             sendView, recvView);
                        emittedHaloExchange = true;
                    }
                }
            }
            if (emittedHaloExchange)
                rewriter.create<mpi::Barrier>(loc, retVal, comm->getResult(0));

            for (auto task : level)
            {
                auto taskOp = dyn_cast<mlir::dhir::TaskOp>(task->op);
                Attribute targetDevice = taskOp.getTarget();

                if (!deviceToIndex.count(targetDevice))
                {
                    taskOp.emitError("target device is not present in dhir.target_devices");
                    return failure();
                }

                int targetNodeIdx = deviceToIndex[targetDevice];

                llvm::ArrayRef outRanges = taskOp.getOutRanges();
                llvm::SmallVector<int64_t, 4> outputPartitionDims(
                    task->writes.size(), 0);
                if (auto dimsAttr = taskOp->getAttrOfType<mlir::DenseI64ArrayAttr>(
                        "outputPartitionDims"))
                {
                    if (dimsAttr.size() != task->writes.size())
                    {
                        taskOp.emitError("outputPartitionDims must match task outputs");
                        return failure();
                    }
                    outputPartitionDims.assign(dimsAttr.asArrayRef().begin(),
                                               dimsAttr.asArrayRef().end());
                }
                
                // Which of this task's write operands are reduction targets
                // rather than row slabs.  Recorded by the replicate lowering.
                llvm::SmallVector<int64_t, 4> partialReduceWriteIdx;
                if (auto reduceAttr =
                        taskOp->getAttrOfType<mlir::DenseI64ArrayAttr>("partialReduce"))
                    partialReduceWriteIdx.assign(reduceAttr.asArrayRef().begin(),
                                                 reduceAttr.asArrayRef().end());

                // Get the base buffer from mapping (now subviews are in mapping!)
                for (auto [writeIndex, writeOp] : llvm::enumerate(task->writes))
                {
                    Value buffer = mapping.lookupOrNull(writeOp);

                    if (!buffer)
                    {
                        llvm::errs() << "ERROR: Buffer not found in mapping\n";
                        return failure();
                    }

                    // A reduction shard accumulated into a private buffer.  The
                    // combine is a sum: shard 0's buffer already holds the
                    // output as it was plus its own partials, so the root copies
                    // it over the real output and adds every other shard's
                    // buffer to it.  Summing is exactly the sequential result
                    // for both read-modify-write accumulation and disjoint
                    // overwrite.
                    if (llvm::is_contained(partialReduceWriteIdx, (int64_t)writeIndex))
                    {
                        Value actualOut = syncValue(
                            taskOp.getActualBuffer()[writeIndex]);

                        Value reduceRootIdx = rewriter.create<arith::ConstantIndexOp>(loc, 0);
                        Value reduceRootRank = rewriter.create<memref::LoadOp>(
                            loc, nodeToRankMap, ValueRange{reduceRootIdx});
                        Value isReduceRoot = rewriter.create<arith::CmpIOp>(
                            loc, rewriter.getI1Type(), arith::CmpIPredicate::eq,
                            rank.getResult(0), reduceRootRank);

                        if (targetNodeIdx == 0)
                        {
                            auto copyIf = rewriter.create<mlir::scf::IfOp>(
                                loc, mlir::TypeRange{}, isReduceRoot, true);
                            copyIf.getThenBodyBuilder(rewriter.getListener())
                                .create<memref::CopyOp>(loc, buffer, actualOut);
                            (void)copyIf.getElseBodyBuilder(rewriter.getListener());
                        }
                        else
                        {
                            Value reduceOwnerIdx =
                                rewriter.create<arith::ConstantIndexOp>(loc, targetNodeIdx);
                            Value reduceOwnerRank = rewriter.create<memref::LoadOp>(
                                loc, nodeToRankMap, ValueRange{reduceOwnerIdx});
                            Value isReduceOwner = rewriter.create<arith::CmpIOp>(
                                loc, rewriter.getI1Type(), arith::CmpIPredicate::eq,
                                rank.getResult(0), reduceOwnerRank);

                            auto recvIf = rewriter.create<mlir::scf::IfOp>(
                                loc, mlir::TypeRange{}, isReduceRoot, true);
                            OpBuilder thenBuilder = recvIf.getThenBodyBuilder(rewriter.getListener());
                            Value incoming = createMirrorBuffer(thenBuilder, loc, buffer);
                            thenBuilder.create<mlir::mpi::RecvOp>(
                                loc, retVal, incoming, tag.getResult(),
                                reduceOwnerRank, comm->getResult(0));
                            emitElementwiseAccumulate(thenBuilder, loc, actualOut, incoming);

                            OpBuilder elseBuilder = recvIf.getElseBodyBuilder(rewriter.getListener());
                            auto sendIf = elseBuilder.create<mlir::scf::IfOp>(
                                loc, mlir::TypeRange{}, isReduceOwner, true);
                            sendIf.getThenBodyBuilder(elseBuilder.getListener())
                                .create<mlir::mpi::SendOp>(
                                    loc, retVal, buffer, tag.getResult(),
                                    reduceRootRank, comm->getResult(0));
                            (void)sendIf.getElseBodyBuilder(elseBuilder.getListener());
                        }

                        BoolAttr reduceBroadcast =
                            mlir::dyn_cast<mlir::BoolAttr>(taskOp->getAttr("needBroadcast"));
                        if (reduceBroadcast && reduceBroadcast.getValue())
                            toBroadcast.push_back(actualOut);
                        continue;
                    }

                    // -------- Per-output ownership decision (alias-aware) -----
                    // Determines whether this shard requires communication. Only a
                    // provably same-owner, loop-carried intermediate is preserved
                    // in-place (skipping gather and broadcast); all other cases follow
                    // the standard assemble-then-maybe-broadcast path below. The
                    // analysis conservatively defaults to materialize-on-all if any
                    // condition is unproven, ensuring safe transfer elision.
                    mlir::dhir::OutputOwnership ownership =
                        mlir::dhir::decideOutputOwnership(
                            dependencyGraph, *task, writeIndex,
                            outputPartitionDims[writeIndex]);
                    llvm::errs() << "[ownership] repId="
                                 << task->repId << " out#" << writeIndex << " -> "
                                 << mlir::dhir::ownershipKindName(ownership.kind)
                                 << " (" << ownership.reason << ")\n";
                    if (ownership.kind == mlir::dhir::OwnershipKind::RetainOwnedShard)
                        // Each rank already retains the exact slab read by its later
                        // same-owner consumer: omit both gather and broadcast for this version.
                        continue;

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
                    // The gather addresses this base allocation after the loop
                    // the sync was lifted out of, so it has to outlive it.
                    if (hoistedOutOf &&
                        definedInsideBlock(sourceBuffer, hoistedOutOf))
                    {
                        taskOp.emitError("gather base buffer is defined inside "
                                         "the loop this task's sync was "
                                         "deferred past");
                        return failure();
                    }
                    int64_t sourceRank = sourceType.getRank();
                    int64_t partitionDim = outputPartitionDims[writeIndex];
                    if (partitionDim < 0 || partitionDim >= sourceRank)
                    {
                        taskOp.emitError("invalid output partition dimension for gather");
                        return failure();
                    }

                    SmallVector<OpFoldResult> offsets;
                    SmallVector<OpFoldResult> sizes;
                    SmallVector<OpFoldResult> strides;

                    // A shard whose partition was decided at run time carries
                    // its (start, end) range as operands; otherwise the range
                    // is the compile-time attribute as before.
                    OpFoldResult rangeStart;
                    OpFoldResult rangeSize;
                    auto shardRangeOps = taskOp.getRangeOperands();
                    if (shardRangeOps.size() == 2)
                    {
                        // These operands are defined in the schedule body that
                        // is being replaced, so they must be carried through
                        // the value mapping into the emitted function.
                        Value shardStart = syncValue(shardRangeOps[0]);
                        Value shardEnd = syncValue(shardRangeOps[1]);
                        if (!shardStart || !shardEnd)
                        {
                            taskOp.emitError("shard range cannot be rebuilt "
                                             "outside the loop this task's sync "
                                             "was deferred past");
                            return failure();
                        }
                        rangeStart = shardStart;
                        Value spanLen = rewriter.create<arith::SubIOp>(
                            loc, shardEnd, shardStart);
                        rangeSize = spanLen;
                    }
                    else
                    {
                        rangeStart = rewriter.getIndexAttr(outRanges[0]);
                        rangeSize = rewriter.getIndexAttr(outRanges[1] - outRanges[0]);
                    }

                    if (sourceRank < 1 || sourceRank > 3)
                    {
                        llvm::errs() << "[Error] Unsupported Memref rank\n";
                        return failure();
                    }
                    for (int64_t d = 0; d < sourceRank; ++d)
                    {
                        if (d == partitionDim)
                        {
                            offsets.push_back(rangeStart);
                            sizes.push_back(rangeSize);
                        }
                        else
                        {
                            offsets.push_back(rewriter.getIndexAttr(0));
                            sizes.push_back(sourceType.isDynamicDim(d)
                                ? OpFoldResult(rewriter.create<memref::DimOp>(
                                      loc, sourceBuffer, d))
                                : OpFoldResult(rewriter.getIndexAttr(
                                      sourceType.getDimSize(d))));
                        }
                        strides.push_back(rewriter.getIndexAttr(1));
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

                        auto sendIf = elseBuilder.create<mlir::scf::IfOp>(loc, mlir::TypeRange{}, isOwner, true);
                        auto sendBuilder = sendIf.getThenBodyBuilder(elseBuilder.getListener());
                        sendBuilder.create<mlir::mpi::SendOp>(loc, retVal, subBuffer, tag.getResult(), rootRank, comm->getResult(0));
                        (void)sendIf.getElseBodyBuilder(elseBuilder.getListener());
                    }

                    // Broadcast
                    BoolAttr needBroadcast = mlir::dyn_cast<mlir::BoolAttr>(taskOp->getAttr("needBroadcast"));
                    if (needBroadcast && needBroadcast.getValue())
                        // Broadcast the assembled base allocation, never a
                        // shard view: shard views lose the partition axis and
                        // cannot be concatenated for column/higher-rank
                        // partitions.
                        toBroadcast.push_back(sourceBuffer);
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
        
        // ------------------------------------------------------------------
        // Resident-stencil per-iteration input halo exchange.
        //
        // Stencil tasks read loop-carried state arrays with halos. While local
        // owned slabs are updated in place, ghost rows residing on adjacent
        // ranks become stale. This helper emits inline point-to-point transfers
        // for boundary ghost rows at the beginning of each loop iteration,
        // preceding task body execution, avoiding full-array transfers.
        //
        // Views are constructed on the input base buffer in global coordinates
        // along the partitioned dimension, with exchange widths clamped to
        // neighbor slab boundaries to prevent out-of-bounds reads.
        // ------------------------------------------------------------------
        auto emitStencilInputHalo = [&](const std::vector<TaskOpInfo *> &level,
                                        Operation *originalLoop) -> LogicalResult
        {
            bool anyStencil = false;
            for (TaskOpInfo *info : level)
                if (auto t = dyn_cast<dhir::TaskOp>(info->op))
                    if (t->hasAttr("stencil")) { anyStencil = true; break; }
            if (!anyStencil)
                return success();

            auto tag = rewriter.create<arith::ConstantOp>(
                loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(0));

            auto nodeIndexOf = [&](dhir::TaskOp t) -> std::optional<int> {
                auto it = deviceToIndex.find(t.getTarget());
                if (it == deviceToIndex.end())
                    return std::nullopt;
                return it->second;
            };
            auto taskRange = [&](dhir::TaskOp t) -> std::pair<Value, Value> {
                auto ro = t.getRangeOperands();
                if (ro.size() == 2)
                    return {mapping.lookupOrDefault(ro[0]),
                            mapping.lookupOrDefault(ro[1])};
                ArrayRef<int64_t> sr = t.getOutRanges();
                return {rewriter.create<arith::ConstantIndexOp>(loc, sr[0]),
                        rewriter.create<arith::ConstantIndexOp>(loc, sr[1])};
            };
            auto axisSubview = [&](Value buffer, int64_t dim, Value start,
                                   Value size) -> Value {
                auto type = cast<MemRefType>(buffer.getType());
                SmallVector<OpFoldResult> offsets, sizes, strides;
                for (int64_t d = 0; d < type.getRank(); ++d)
                {
                    if (d == dim)
                    {
                        offsets.push_back(start);
                        sizes.push_back(size);
                    }
                    else
                    {
                        offsets.push_back(rewriter.getIndexAttr(0));
                        sizes.push_back(type.isDynamicDim(d)
                            ? OpFoldResult(rewriter.create<memref::DimOp>(loc, buffer, d))
                            : OpFoldResult(rewriter.getIndexAttr(type.getDimSize(d))));
                    }
                    strides.push_back(rewriter.getIndexAttr(1));
                }
                return rewriter.create<memref::SubViewOp>(loc, buffer, offsets,
                                                          sizes, strides);
            };
            auto neighborTransfer = [&](int senderNode, int receiverNode,
                                        Value sendView, Value recvView) {
                Value sIdx = rewriter.create<arith::ConstantIndexOp>(loc, senderNode);
                Value rIdx = rewriter.create<arith::ConstantIndexOp>(loc, receiverNode);
                Value sRank = rewriter.create<memref::LoadOp>(loc, nodeToRankMap, ValueRange{sIdx});
                Value rRank = rewriter.create<memref::LoadOp>(loc, nodeToRankMap, ValueRange{rIdx});
                Value isS = rewriter.create<arith::CmpIOp>(loc, rewriter.getI1Type(),
                    arith::CmpIPredicate::eq, rank.getResult(0), sRank);
                auto ifOp = rewriter.create<scf::IfOp>(loc, TypeRange{}, isS, true);
                ifOp.getThenBodyBuilder(rewriter.getListener())
                    .create<mpi::SendOp>(loc, retVal, sendView, tag.getResult(), rRank, comm->getResult(0));
                OpBuilder eb = ifOp.getElseBodyBuilder(rewriter.getListener());
                Value isR = eb.create<arith::CmpIOp>(loc, rewriter.getI1Type(),
                    arith::CmpIPredicate::eq, rank.getResult(0), rRank);
                auto rIf = eb.create<scf::IfOp>(loc, TypeRange{}, isR, true);
                rIf.getThenBodyBuilder(eb.getListener())
                    .create<mpi::RecvOp>(loc, retVal, recvView, tag.getResult(), sRank, comm->getResult(0));
                (void)rIf.getElseBodyBuilder(eb.getListener());
            };

            rewriter.create<mpi::Barrier>(loc, retVal, comm->getResult(0));
            bool emitted = false;
            for (TaskOpInfo *rightInfo : level)
            {
                auto rightTask = dyn_cast<dhir::TaskOp>(rightInfo->op);
                if (!rightTask || !rightTask->hasAttr("stencil"))
                    continue;
                std::optional<int> rightNode = nodeIndexOf(rightTask);
                if (!rightNode || *rightNode == 0)
                    continue;
                auto rightRepId = rightTask->getAttrOfType<IntegerAttr>("repId");

                dhir::TaskOp leftTask;
                for (TaskOpInfo *ci : level)
                {
                    auto c = dyn_cast<dhir::TaskOp>(ci->op);
                    if (!c || !c->hasAttr("stencil") ||
                        c->getAttrOfType<IntegerAttr>("repId") != rightRepId)
                        continue;
                    auto cn = nodeIndexOf(c);
                    if (cn && *cn == *rightNode - 1) { leftTask = c; break; }
                }
                if (!leftTask)
                    continue;

                // Retrieve the loop-carried input state array; if null, the input
                // is non-resident and left for deferred gather.
                Value carried = mlir::dhir::stencilCarriedInput(rightTask, originalLoop);
                if (!carried)
                    continue;
                Value baseBuffer = mapping.lookupOrDefault(carried);

                int64_t partitionDim = rightTask
                    ->getAttrOfType<IntegerAttr>("stencilPartitionDim").getInt();
                int64_t leftHaloRight = leftTask
                    ->getAttrOfType<IntegerAttr>("haloRight").getInt();
                int64_t rightHaloLeft = rightTask
                    ->getAttrOfType<IntegerAttr>("haloLeft").getInt();
                auto lr = taskRange(leftTask);
                auto rr = taskRange(rightTask);
                Value leftChunk = rewriter.create<arith::SubIOp>(loc, lr.second, lr.first);
                Value rightChunk = rewriter.create<arith::SubIOp>(loc, rr.second, rr.first);

                // Transfer ghost rows from the left neighbor's upper boundary
                // into the right rank's lower ghost region.
                if (rightHaloLeft > 0)
                {
                    Value req = rewriter.create<arith::ConstantIndexOp>(loc, rightHaloLeft);
                    Value width = rewriter.create<arith::MinUIOp>(loc, req, leftChunk);
                    Value start = rewriter.create<arith::SubIOp>(loc, lr.second, width);
                    neighborTransfer(*rightNode - 1, *rightNode,
                                     axisSubview(baseBuffer, partitionDim, start, width),
                                     axisSubview(baseBuffer, partitionDim, start, width));
                    emitted = true;
                }
                // Transfer ghost rows from the right neighbor's lower boundary
                // into the left rank's upper ghost region.
                if (leftHaloRight > 0)
                {
                    Value req = rewriter.create<arith::ConstantIndexOp>(loc, leftHaloRight);
                    Value width = rewriter.create<arith::MinUIOp>(loc, req, rightChunk);
                    Value start = rr.first;
                    neighborTransfer(*rightNode, *rightNode - 1,
                                     axisSubview(baseBuffer, partitionDim, start, width),
                                     axisSubview(baseBuffer, partitionDim, start, width));
                    emitted = true;
                }
            }
            if (emitted)
                rewriter.create<mpi::Barrier>(loc, retVal, comm->getResult(0));
            return success();
        };
        // Emit level `levelIdx` here. Its sync follows immediately unless the
        // level is slab-local across the rebuilt loop we are inside, in which
        // case the enclosing frame collects it and emits it once after the loop.
        auto emitLevelOrDefer = [&](size_t levelIdx) -> LogicalResult
        {
            const std::vector<TaskOpInfo *> &level =
                dependencyGraph.levelVector[levelIdx];
            // In resident-stencil loops, exchange input ghost rows inline
            // before running task bodies for the iteration.
            if (!deferFrames.empty() && deferFrames.back().resident)
                if (failed(emitStencilInputHalo(level,
                                                deferFrames.back().originalLoop)))
                    return failure();
            if (failed(emitLevelBodies(level)))
                return failure();
            if (!deferFrames.empty() &&
                canHoistLevelSync(level, deferFrames.back()))
            {
                deferFrames.back().levels.push_back(levelIdx);
                return success();
            }
            return emitLevelSync(level, /*hoistedOutOf=*/nullptr);
        };
        // Emit a block in program order. Setup operations are ordinary SSA
        // definitions, not a module-wide prologue: moving a pure definition
        // before preceding serial work can change the value seen by a task (and
        // can even violate dominance for values defined in nested control flow).
        //
        //   atax's converge body is
        //     replicate(tmp[i] += A[i][j]*x[j]) ; for j { y[j] += A[i][j]*tmp[i] }
        //   second loop depends on that prev replicate, so cant mess ordering
        //   atax failed due to this, fixed after fixing ordering
        //
        // Order also settles nesting depth: a replicate that was a
        // sibling of the converge loop is reached before the loop is entered,
        // so it is emitted once rather than once per iteration.
        std::function<LogicalResult(Block &)> emitBody = [&](Block &body) -> LogicalResult
        {
            for (Operation &bodyOp : body)
            {
                // Terminators are re-created by their own handlers
                // (scf.for/scf.if yields, scf.while conditions); cloning them
                // here would leave the rebuilt block with two terminators.
                if (mlir::isa<mlir::dhir::YieldOp>(bodyOp) ||
                    mlir::isa<mlir::scf::YieldOp>(bodyOp) ||
                    mlir::isa<mlir::scf::ConditionOp>(bodyOp))
                    continue;

                if (mlir::isa<mlir::dhir::TaskOp>(bodyOp))
                {
                    // Tasks of one level are independent, so the whole level is
                    // ready as a group at the position of its last task.
                    auto it = taskToLevel.find(&bodyOp);
                    if (it == taskToLevel.end() || levelEmitted[it->second])
                        continue;

                    if (levelTasksRemaining[it->second] == 0) {
                        bodyOp.emitError("task scheduling level was visited more than once");
                        return failure();
                    }
                    --levelTasksRemaining[it->second];

                    // Topological levels can interleave in source order. For
                    // example, A and C may be independent while B (between
                    // them) depends on A, producing levels {A,C}, {B}. Mark
                    // levels ready at their last source task, but release them
                    // only in topological order so B cannot run first.
                    while (nextLevelToEmit < dependencyGraph.levelVector.size() &&
                           levelTasksRemaining[nextLevelToEmit] == 0) {
                        levelEmitted[nextLevelToEmit] = true;
                        if (failed(emitLevelOrDefer(nextLevelToEmit)))
                            return failure();
                        ++nextLevelToEmit;
                    }
                    continue;
                }

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

                        SmallVector<Value> initArgs;
                        for (Value init : forOp.getInitArgs())
                            initArgs.push_back(mapping.lookupOrDefault(init));
                        // Levels emitted inside this loop may owe their sync to
                        // the point after it. The frame collects them because
                        // the loop op is not addressable until its builder
                        // returns.
                        deferFrames.emplace_back();
                        deferFrames.back().originalLoop = forOp.getOperation();
                        // Check if the loop qualifies as a resident-stencil
                        // loop based on IR properties (stencil tasks operating
                        // on loop-carried state).
                        deferFrames.back().resident =
                            mlir::dhir::isResidentStencilLoop(forOp.getOperation());
                        // The region builder returns void, so a failure in the
                        // recursion has to be carried out by hand; dropping it
                        // left a half-built loop to fail obscurely later.
                        LogicalResult bodyResult = success();
                        auto newForOp = rewriter.create<mlir::scf::ForOp>(
                            loc, lb, ub, step, initArgs,
                            [&](OpBuilder &bodyBuilder, Location bodyLoc,
                                Value newIV, ValueRange newIterArgs) {
                                deferFrames.back().newBody =
                                    bodyBuilder.getInsertionBlock();
                                mapping.map(forOp.getInductionVar(), newIV);
                                for (auto pair : llvm::zip(
                                         forOp.getRegionIterArgs(), newIterArgs))
                                    mapping.map(std::get<0>(pair), std::get<1>(pair));

                                rewriter.setInsertionPointToEnd(
                                    bodyBuilder.getInsertionBlock());
                                if (failed(emitBody(*forOp.getBody())))
                                {
                                    bodyResult = failure();
                                    return;
                                }

                                auto oldYield = cast<mlir::scf::YieldOp>(
                                    forOp.getBody()->getTerminator());
                                SmallVector<Value> yieldValues;
                                for (Value value : oldYield.getOperands())
                                    yieldValues.push_back(
                                        mapping.lookupOrDefault(value));
                                rewriter.setInsertionPointToEnd(
                                    bodyBuilder.getInsertionBlock());
                                rewriter.create<mlir::scf::YieldOp>(bodyLoc,
                                                                     yieldValues);
                            },
                            forOp.getUnsignedCmp());
                        DeferFrame frame = deferFrames.pop_back_val();
                        if (failed(bodyResult))
                            return failure();
                        for (auto pair : llvm::zip(forOp.getResults(),
                                                  newForOp.getResults()))
                            mapping.map(std::get<0>(pair), std::get<1>(pair));

                        rewriter.setInsertionPointAfter(newForOp.getOperation());
                        
                        // The loop exists now, so the syncs it owes can be
                        // emitted after it — once each, instead of once per
                        // iteration.
                        for (size_t levelIdx : frame.levels)
                            if (failed(emitLevelSync(
                                    dependencyGraph.levelVector[levelIdx],
                                    frame.newBody)))
                                return failure();
                        continue;
                    }
                    // A loop with no tasks is redundant work that every rank
                    // repeats; clone it where it stands.
                }

                if (auto ifOp = mlir::dyn_cast<mlir::scf::IfOp>(bodyOp))
                {
                    bool wrapsTasks = false;
                    ifOp.walk([&](mlir::dhir::TaskOp) { wrapsTasks = true; });
                    if (wrapsTasks)
                    {
                        Value condition = mapping.lookupOrDefault(ifOp.getCondition());
                        bool hasElse = !ifOp.getElseRegion().empty();
                        // A result-producing scf.if needs an else region to
                        // reconstruct; without one the rebuilt op would fail
                        // obscurely in the verifier — reject it clearly.
                        if (!ifOp.getResultTypes().empty() && !hasElse)
                        {
                            ifOp.emitError(
                                "scf.if that wraps tasks produces results but has "
                                "no else region; unsupported");
                            return failure();
                        }
                        auto newIfOp = rewriter.create<mlir::scf::IfOp>(
                            loc, ifOp.getResultTypes(), condition, true, hasElse);

                        auto rebuildBranch = [&](Block &oldBlock,
                                                 Block &newBlock) -> LogicalResult {
                            rewriter.setInsertionPointToStart(&newBlock);
                            if (failed(emitBody(oldBlock)))
                                return failure();
                            auto oldYield = cast<mlir::scf::YieldOp>(
                                oldBlock.getTerminator());
                            SmallVector<Value> yieldValues;
                            for (Value value : oldYield.getOperands())
                                yieldValues.push_back(mapping.lookupOrDefault(value));
                            if (auto existing = dyn_cast_or_null<mlir::scf::YieldOp>(
                                    newBlock.getTerminator()))
                            {
                                existing->setOperands(yieldValues);
                            }
                            else
                            {
                                // IfOp's block-creating builder leaves fresh
                                // regions unterminated, and emitBody may end in
                                // a collective or an empty branch, so never
                                // assume a source yield was cloned.
                                rewriter.setInsertionPointToEnd(&newBlock);
                                rewriter.create<mlir::scf::YieldOp>(loc,
                                                                     yieldValues);
                            }
                            return success();
                        };

                        if (failed(rebuildBranch(ifOp.getThenRegion().front(),
                                                 newIfOp.getThenRegion().front())))
                            return failure();
                        if (hasElse &&
                            failed(rebuildBranch(ifOp.getElseRegion().front(),
                                                 newIfOp.getElseRegion().front())))
                            return failure();
                        for (auto pair : llvm::zip(ifOp.getResults(),
                                                  newIfOp.getResults()))
                            mapping.map(std::get<0>(pair), std::get<1>(pair));
                        rewriter.setInsertionPointAfter(newIfOp);
                        continue;
                    }
                }

                if (auto whileOp = mlir::dyn_cast<mlir::scf::WhileOp>(bodyOp))
                {
                    bool wrapsTasks = false;
                    whileOp.walk([&](mlir::dhir::TaskOp) { wrapsTasks = true; });
                    if (wrapsTasks)
                    {
                        SmallVector<Value> inits;
                        for (Value init : whileOp.getInits())
                            inits.push_back(mapping.lookupOrDefault(init));
                        auto newWhileOp = rewriter.create<mlir::scf::WhileOp>(
                            loc, whileOp.getResultTypes(), inits,
                            ArrayRef<NamedAttribute>{});

                        Block *newBefore = rewriter.createBlock(
                            &newWhileOp.getBefore(), {},
                            whileOp.getBeforeBody()->getArgumentTypes(),
                            SmallVector<Location>(
                                whileOp.getBeforeBody()->getNumArguments(), loc));
                        Block *newAfter = rewriter.createBlock(
                            &newWhileOp.getAfter(), {},
                            whileOp.getAfterBody()->getArgumentTypes(),
                            SmallVector<Location>(
                                whileOp.getAfterBody()->getNumArguments(), loc));
                        for (auto pair : llvm::zip(
                                 whileOp.getBeforeBody()->getArguments(),
                                 newBefore->getArguments()))
                            mapping.map(std::get<0>(pair), std::get<1>(pair));
                        for (auto pair : llvm::zip(
                                 whileOp.getAfterBody()->getArguments(),
                                 newAfter->getArguments()))
                            mapping.map(std::get<0>(pair), std::get<1>(pair));

                        rewriter.setInsertionPointToStart(newBefore);
                        if (failed(emitBody(*whileOp.getBeforeBody())))
                            return failure();
                        auto oldCondition = whileOp.getConditionOp();
                        SmallVector<Value> conditionArgs;
                        for (Value value : oldCondition.getArgs())
                            conditionArgs.push_back(mapping.lookupOrDefault(value));
                        rewriter.setInsertionPointToEnd(newBefore);
                        rewriter.create<mlir::scf::ConditionOp>(
                            loc, mapping.lookupOrDefault(oldCondition.getCondition()),
                            conditionArgs);

                        rewriter.setInsertionPointToStart(newAfter);
                        if (failed(emitBody(*whileOp.getAfterBody())))
                            return failure();
                        auto oldYield = whileOp.getYieldOp();
                        SmallVector<Value> yieldValues;
                        for (Value value : oldYield.getOperands())
                            yieldValues.push_back(mapping.lookupOrDefault(value));
                        rewriter.setInsertionPointToEnd(newAfter);
                        rewriter.create<mlir::scf::YieldOp>(loc, yieldValues);

                        for (auto pair : llvm::zip(whileOp.getResults(),
                                                  newWhileOp.getResults()))
                            mapping.map(std::get<0>(pair), std::get<1>(pair));
                        rewriter.setInsertionPointAfter(newWhileOp);
                        continue;
                    }
                }

                // Fallback: an ordinary op with no tasks is cloned verbatim.
                // A task still inside means the dispatch above cannot rebuild
                // it (only scf.for/scf.if/scf.while are handled); fail with a
                // clear error at the offending op instead of cloning an
                // unconverted dhir.task.
                bool clonesTask = false;
                bodyOp.walk([&](mlir::dhir::TaskOp) { clonesTask = true; });
                if (clonesTask)
                {
                    bodyOp.emitError(
                        "task is wrapped in a construct the dhir-to-mpi rebuild "
                        "cannot reconstruct; only scf.for/scf.if/scf.while may "
                        "wrap tasks");
                    return failure();
                }

                cloneAndMapResults(rewriter, bodyOp, mapping);
            }
            return success();
        };

        if (failed(emitBody(op.getBodyRegion().front())))
            return failure();
        if (nextLevelToEmit != dependencyGraph.levelVector.size()) {
            op.emitError("not all task scheduling levels were emitted");
            return failure();
        }

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
                // Kernel bodies carry ops from these dialects unchanged; the
                // schedule lowering copies them verbatim, so they must be legal
                // here or an otherwise-correct schedule reports as
                // "failed to legalize".
                target.addLegalDialect<mlir::math::MathDialect>();
                target.addLegalDialect<mlir::index::IndexDialect>();
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

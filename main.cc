#include "mlir/IR/Builders.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Attributes.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/Support/FileUtilities.h"
#include "llvm/Support/SourceMgr.h"
#include "mlir/Parser/Parser.h"
#include "mlir/IR/Verifier.h"
#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/Conversion/Passes.h"
#include "mlir/Transforms/Passes.h"
// Compatibility shim for prebuilt LLVM static libs referencing glibc >= 2.32
extern "C" char __libc_single_threaded = 0;
#include <iostream>

#include "includes/dhirDialect.h"
#include "includes/dhirOps.h"
#include "includes/dhirTypes.h"
#include "includes/utils.h"

#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Math/IR/Math.h"
#include "mlir/Dialect/OpenMP/OpenMPDialect.h"
#include "mlir/Dialect/MemRef/Transforms/Passes.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/GPU/Transforms/Passes.h"
#include "mlir/Dialect/LLVMIR/NVVMDialect.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"

#include "conversions/dhirtompi.h"
#include "conversions/lowerReplicateOp.h"
#include "analysis/costModel.h"
#include "conversions/lowerConvergeOp.h"
#include "conversions/affinetodhir.h"
#include "conversions/stdtodhir.h"
#include "conversions/ompCostModelPass.h"

#include "mlir/Conversion/LLVMCommon/TypeConverter.h"
#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/MemRefToLLVM/MemRefToLLVM.h"
#include "mlir/Conversion/SCFToOpenMP/SCFToOpenMP.h"
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/Conversion/OpenMPToLLVM/ConvertOpenMPToLLVM.h"
#include "mlir/Conversion/MPIToLLVM/MPIToLLVM.h"
#include "mlir/Conversion/UBToLLVM/UBToLLVM.h"
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVM.h"
#include "mlir/Conversion/VectorToLLVM/ConvertVectorToLLVM.h"

#include "mlir/Conversion/GPUToNVVM/GPUToNVVMPass.h"
#include "mlir/Conversion/GPUCommon/GPUCommonPass.h"
#include "mlir/Conversion/SCFToGPU/SCFToGPUPass.h"

#include "mlir/Target/LLVMIR/Dialect/Builtin/BuiltinToLLVMIRTranslation.h"
#include "mlir/Target/LLVMIR/Dialect/NVVM/NVVMToLLVMIRTranslation.h"
#include "mlir/Target/LLVMIR/Dialect/LLVMIR/LLVMToLLVMIRTranslation.h"
#include "mlir/Target/LLVMIR/Dialect/GPU/GPUToLLVMIRTranslation.h"
#include "mlir/Target/LLVM/NVVM/Target.h"

#include <thread>

using namespace std;
using namespace mlir;

// Command-line options
static llvm::cl::opt<std::string> inpFileName(
    llvm::cl::Positional,
    llvm::cl::desc("<MLIR Input File>"),
    llvm::cl::Required);

static llvm::cl::opt<std::string> configFileName(
    llvm::cl::Positional,
    llvm::cl::desc("<Cluster Config File>"),
    llvm::cl::Required);


static llvm::cl::opt<bool> dhirToMPI(
    "dhir-to-mpi",
    llvm::cl::desc("Enable DHIR to MPI conversion"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> lowerReplicate(
    "lower-replicate",
    llvm::cl::desc("Enable replicate operation lowering"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> lowerConverge(
    "lower-converge",
    llvm::cl::desc("Enable converge operation lowering"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> affineTodhir(
    "affine-to-dhir",
    llvm::cl::desc("Enable Affine to DHIR conversion"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> ompCostModelReport(
    "dhir-omp-cost-model-report",
    llvm::cl::desc("Print OpenMP-aware work, memory traffic, broadcast scaling, "
                   "and dynamic entries at the DHIR boundary"),
    llvm::cl::init(false));

static llvm::cl::opt<int> ompThreads(
    "dhir-omp-threads",
    llvm::cl::desc("OpenMP thread count for cost model estimation (0 = from config/default)"),
    llvm::cl::init(0));

static llvm::cl::opt<int64_t> ompLLCBytes(
    "dhir-omp-llc-bytes",
    llvm::cl::desc("Shared LLC capacity for OpenMP cost model (0 = detect host)"),
    llvm::cl::init(0));

static llvm::cl::opt<int64_t> ompL1Bytes(
    "dhir-omp-l1-bytes",
    llvm::cl::desc("L1 data cache capacity for OpenMP cost model (0 = detect host)"),
    llvm::cl::init(0));

static llvm::cl::opt<bool> stdTodhir(
    "std-to-dhir",
    llvm::cl::desc("Enable Std Dialects to DHIR conversion"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> lowerTollvm(
    "lower-to-llvm",
    llvm::cl::desc("Lower everything to LLVM IR"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> commReport(
    "dhir-comm-report",
    llvm::cl::desc("Print every emitted MPI operation with its static payload "
                   "and dynamic multiplicity, plus the modelled cost under the "
                   "config's network parameters"),
    llvm::cl::init(false));

int main(int argc, char *argv[])
{
    // Parse command-line options
    llvm::cl::ParseCommandLineOptions(argc, argv, "DHIR OPT Tool\n");

    mlir::DialectRegistry registry;
    registry.insert<mlir::dhir::DhirDialect, mlir::affine::AffineDialect, mlir::memref::MemRefDialect, mlir::func::FuncDialect, mlir::arith::ArithDialect, mlir::scf::SCFDialect, mlir::DLTIDialect, mlir::gpu::GPUDialect>();

    mlir::MLIRContext context(registry);
    context.loadAllAvailableDialects();

    llvm::SourceMgr sourceMgr;
    mlir::SourceMgrDiagnosticHandler sourceMgrHandler(sourceMgr, &context);

    // Load the target MLIR source buffer
    std::string errorMessage;
    auto file = mlir::openInputFile(inpFileName, &errorMessage);
    if (!file)
    {
        llvm::errs() << errorMessage << "\n";
        return 1;
    }

    sourceMgr.AddNewSourceBuffer(std::move(file), llvm::SMLoc());

    // Construct the top-level ModuleOp from the input source
    mlir::OwningOpRef<mlir::ModuleOp> module = mlir::parseSourceFile<mlir::ModuleOp>(sourceMgr, &context);
    if (!module)
    {
        llvm::errs() << "Error parsing MLIR file.\n";
        return 1;
    }

    SystemTopology sys_topo = parseSystemConfig(configFileName);

    // Add DLTI specifications
    attachDLTISpec(llvm::dyn_cast<mlir::ModuleOp>(module->getOperation()), &context, sys_topo);
    auto vec = extractTargetDeviceSpecs(llvm::dyn_cast<mlir::ModuleOp>(module->getOperation()));

    // Set up pass manager
    PassManager pm(&context);
    // context.disableMultithreading();
    // pm.enableIRPrinting();

    if (ompCostModelReport)
    {
        pm.addPass(mlir::dhir::createConvertAffineToDhirPass());

        // Construct the target hardware capability profile upfront and supply it to the pass.
        // Parameterizing analytical rates and cache limits ensures profiling reflects the
        // intended deployment architecture rather than host build environment properties;
        // host queries serve strictly as a fallback when profile capacities are omitted.
        mlir::dhir::MachineModel machine;
        auto &cal = sys_topo.machine;
        machine.rate[mlir::dhir::CC_Dram] = cal.r_strided;
        machine.rate[mlir::dhir::CC_Llc] = cal.r_llc;
        machine.rate[mlir::dhir::CC_L1] = cal.r_l1;
        machine.rate[mlir::dhir::CC_Contiguous] = cal.r_contiguous;
        machine.serialRate[mlir::dhir::CC_Dram] = cal.r_strided_serial;
        machine.serialRate[mlir::dhir::CC_Llc] = cal.r_llc_serial;
        machine.serialRate[mlir::dhir::CC_L1] = cal.r_l1_serial;
        machine.serialRate[mlir::dhir::CC_Contiguous] = cal.r_contiguous_serial;
        machine.bandwidth = cal.memory_bandwidth;
        machine.startup = cal.overhead;
        machine.firstEntry = cal.h_first_parallel_entry;
        machine.entry = cal.h_parallel_entry;
        machine.l1Bytes = cal.l1_bytes;
        machine.llcBytes = cal.llc_bytes;
        machine.memoryBytes = cal.memory_bytes;
        machine.threads = cal.threads;

        if (!sys_topo.nodes.empty())
        {
            const auto &node = sys_topo.nodes.begin()->second;
            auto preferNode = [](double &target, double value) {
                if (target <= 0.0 && value > 0.0) target = value;
            };
            preferNode(machine.rate[mlir::dhir::CC_Dram], node.compute_rate_strided);
            preferNode(machine.rate[mlir::dhir::CC_Llc], node.compute_rate_llc);
            preferNode(machine.rate[mlir::dhir::CC_L1], node.compute_rate_l1);
            preferNode(machine.rate[mlir::dhir::CC_Contiguous], node.compute_rate_contiguous);
            preferNode(machine.serialRate[mlir::dhir::CC_Dram], node.compute_rate_strided_serial);
            preferNode(machine.serialRate[mlir::dhir::CC_Llc], node.compute_rate_llc_serial);
            preferNode(machine.serialRate[mlir::dhir::CC_L1], node.compute_rate_l1_serial);
            preferNode(machine.serialRate[mlir::dhir::CC_Contiguous], node.compute_rate_contiguous_serial);
            preferNode(machine.bandwidth, node.memory_bandwidth);
            preferNode(machine.startup, node.overhead);
            preferNode(machine.firstEntry, node.omp_first_entry_latency);
            preferNode(machine.entry, node.omp_entry_latency);
            if (machine.l1Bytes <= 0) machine.l1Bytes = node.l1_bytes;
            if (machine.llcBytes <= 0) machine.llcBytes = node.llc_bytes;
            if (machine.memoryBytes <= 0) machine.memoryBytes = node.memory_bytes;
            if (machine.threads <= 0) machine.threads = node.threads;
        }

        // Command-line options override settings specified in configuration files.
        if (ompThreads > 0) machine.threads = ompThreads;
        if (ompLLCBytes > 0) machine.llcBytes = ompLLCBytes;
        if (ompL1Bytes > 0) machine.l1Bytes = ompL1Bytes;

        if (machine.llcBytes <= 0)
            machine.llcBytes = mlir::dhir::detectHostLastLevelCacheBytes();
        if (machine.l1Bytes <= 0)
            machine.l1Bytes = mlir::dhir::detectHostL1DataCacheBytes();
        if (machine.threads <= 0)
            machine.threads = int(std::thread::hardware_concurrency());
        if (machine.threads <= 0) machine.threads = 1;

        pm.addPass(mlir::dhir::createOMPCostModelReportPass(machine));
        if (affineTodhir)
        {
            pm.addPass(mlir::createLowerAffinePass());
        }
    }
    else if (affineTodhir)
    {
        pm.addPass(mlir::dhir::createConvertAffineToDhirPass());
        pm.addPass(mlir::createLowerAffinePass());
    }

    if (stdTodhir)
        pm.addPass(mlir::dhir::createConvertStdToDhirPass());

    if (lowerReplicate)
    {
        pm.addPass(mlir::dhir::createLowerReplicateOpPass());
    }

    if(lowerConverge)
    {
        pm.addPass(mlir::dhir::createLowerConvergeOpPass());
    }

    if (dhirToMPI)
    {
        pm.addPass(createSelectiveGPUConversionPass());
        pm.addPass(mlir::dhir::createConvertDhirToMPIPass());

        // GPU Related lowering

        // pm.nest<func::FuncOp>().addPass(createGpuMapParallelLoopsPass());
        pm.addPass(mlir::createConvertParallelLoopToGpuPass());
        pm.addPass(createGpuKernelOutliningPass());

        // Attach NVVM target with correct libdevice path
        GpuNVVMAttachTargetOptions gputargetOptions;
        gputargetOptions.chip = "sm_61";
        gputargetOptions.triple = "nvptx64-nvidia-cuda";
        pm.addPass(createGpuNVVMAttachTarget(gputargetOptions));
        pm.nest<mlir::gpu::GPUModuleOp>().addPass(mlir::createLowerAffinePass());
        pm.nest<mlir::gpu::GPUModuleOp>().addPass(createSCFToControlFlowPass());
        pm.nest<mlir::gpu::GPUModuleOp>().addPass(mlir::memref::createExpandStridedMetadataPass());
        pm.nest<mlir::gpu::GPUModuleOp>().addPass(createConvertGpuOpsToNVVMOps());
        pm.nest<mlir::gpu::GPUModuleOp>().addPass(createArithToLLVMConversionPass());
        pm.nest<mlir::gpu::GPUModuleOp>().addPass(createConvertIndexToLLVMPass());
        pm.nest<mlir::gpu::GPUModuleOp>().addPass(createUBToLLVMConversionPass());

        // Multi-Core Related Passes
        pm.addPass(mlir::createConvertSCFToOpenMPPass());
    }

    if (lowerTollvm)
    {

        pm.addNestedPass<func::FuncOp>(createGpuAsyncRegionPass());
        pm.addPass(mlir::createGpuDecomposeMemrefsPass());
        pm.addPass(createGpuToLLVMConversionPass());

        pm.addPass(createConvertNVVMToLLVMPass());
        // pm.addPass(mlir::createLowerAffinePass());

        pm.addPass(mlir::memref::createExpandStridedMetadataPass());
        pm.addPass(createSCFToControlFlowPass());
        pm.addPass(createConvertMPItoLLVM());
        pm.addPass(createArithToLLVMConversionPass());
        pm.addPass(mlir::createConvertIndexToLLVMPass());

        // pm.addPass(createUBToLLVMConversionPass());

        pm.addPass(createConvertToLLVMPass());
        pm.addPass(createGpuModuleToBinaryPass());

        pm.addPass(mlir::createConvertOpenMPToLLVMPass());
        pm.addPass(createFinalizeMemRefToLLVMConversionPass());

        pm.addPass(createConvertFuncToLLVMPass());
        pm.addPass(createConvertControlFlowToLLVMPass());
        pm.addPass(mlir::createReconcileUnrealizedCastsPass());

        // pm.addPass(createCanonicalizerPass());
    }

    // Run passes
    if (failed(pm.run(module->getOperation())))
    {
        llvm::errs() << "Failed to run passes\n";
        return 1;
    }

    // Verify the module
    if (failed(mlir::verify(module->getOperation())))
    {
        llvm::errs() << "Module verification failed\n";
        return 1;
    }
    
    // Profile emitted MPI communication primitives directly against calibrated interconnect metrics.
    // Inspecting generated IR operations is necessary because collective operations are lowered into
    // sequential loops of blocking point-to-point transfers centered at rank 0, requiring spoke-by-spoke
    // cost accumulation rather than idealized collective formulas.
    if (commReport)
    {
        const double alpha = sys_topo.network.alpha_seconds;
        const double beta = sys_topo.network.beta_seconds_per_byte;
        const double barrierCost = sys_topo.network.barrier_seconds;
        const int64_t worldSize = sys_topo.cluster.world_size;

        // Computes composite iteration multiplicity across parent loops. Dynamic upper bounds
        // signify rank-iterating broadcast loops (`0..comm_size`); executing across world_size
        // steps where an `i != root` conditional produces world_size - 1 active transmissions.
        auto multiplicity = [&](mlir::Operation *op, bool &overRanks) {
            int64_t entries = 1;
            overRanks = false;
            for (mlir::Operation *p = op->getParentOp(); p; p = p->getParentOp())
            {
                std::optional<int64_t> trip;
                if (auto affineFor = mlir::dyn_cast<mlir::affine::AffineForOp>(p))
                {
                    if (auto t = mlir::affine::getConstantTripCount(affineFor))
                        trip = int64_t(*t);
                }
                else if (auto scfFor = mlir::dyn_cast<mlir::scf::ForOp>(p))
                {
                    auto lo = mlir::getConstantIntValue(scfFor.getLowerBound());
                    auto hi = mlir::getConstantIntValue(scfFor.getUpperBound());
                    auto st = mlir::getConstantIntValue(scfFor.getStep());
                    if (lo && hi && st && *st > 0)
                        trip = (*hi - *lo + *st - 1) / *st;
                    else
                    {
                        overRanks = true;
                        trip = worldSize > 1 ? worldSize - 1 : 0;
                    }
                }
                else
                    continue;
                entries *= trip.value_or(0);
            }
            return entries;
        };

        auto payloadBytes = [](mlir::Value ref) -> int64_t {
            auto type = mlir::dyn_cast<mlir::MemRefType>(ref.getType());
            if (!type || !type.hasStaticShape()) return -1;
            int64_t elems = 1;
            for (int64_t d : type.getShape()) elems *= d;
            int64_t width = type.getElementTypeBitWidth() / 8;
            return width > 0 ? elems * width : -1;
        };

        // Establish individual point-to-point latency (alpha) and transfer costs (beta) for ranks 1..worldSize-1
        std::vector<double> spokeAlphas;
        std::vector<double> spokeBetas;
        for (int64_t r = 1; r < worldSize; ++r) {
            double a = alpha;
            double b = beta;
            if (r < int64_t(sys_topo.cluster.node_ids.size())) {
                const auto &nodeId = sys_topo.cluster.node_ids[r];
                auto it = sys_topo.nodes.find(nodeId);
                if (it != sys_topo.nodes.end() && it->second.network.calibrated) {
                    a = it->second.network.alpha_seconds;
                    b = it->second.network.beta_seconds_per_byte;
                }
            }
            spokeAlphas.push_back(a);
            spokeBetas.push_back(b);
        }

        int64_t sends = 0, recvs = 0, barriers = 0, sendBytes = 0, unknown = 0;
        double modelled = 0.0;
        module->walk([&](mlir::Operation *op) {
            bool overRanks = false;
            if (auto send = mlir::dyn_cast<mlir::mpi::SendOp>(op))
            {
                int64_t count = multiplicity(op, overRanks);
                int64_t bytes = payloadBytes(send.getRef());
                if (bytes < 0) { ++unknown; return; }
                sends += count;
                sendBytes += count * bytes;
                if (overRanks && !spokeAlphas.empty())
                {
                    int64_t rounds = count / int64_t(spokeAlphas.size());
                    if (rounds < 1) rounds = 1;
                    double roundCost = 0.0;
                    for (size_t i = 0; i < spokeAlphas.size(); ++i)
                        roundCost += (spokeAlphas[i] + spokeBetas[i] * double(bytes));
                    modelled += double(rounds) * roundCost;
                }
                else
                {
                    modelled += count * (alpha + beta * double(bytes));
                }
                llvm::outs() << "COMM kind=send bytes=" << bytes
                             << " messages=" << count
                             << " over_ranks=" << (overRanks ? 1 : 0) << "\n";
            }
            else if (auto recv = mlir::dyn_cast<mlir::mpi::RecvOp>(op))
            {
                int64_t count = multiplicity(op, overRanks);
                int64_t bytes = payloadBytes(recv.getRef());
                recvs += count;
                llvm::outs() << "COMM kind=recv bytes=" << bytes
                             << " messages=" << count
                             << " over_ranks=" << (overRanks ? 1 : 0) << "\n";
            }
            else if (mlir::isa<mlir::mpi::Barrier>(op))
            {
                barriers += multiplicity(op, overRanks);
            }
        });
        modelled += double(barriers) * barrierCost;

        llvm::outs() << "COMM_TOTAL sends=" << sends << " recvs=" << recvs
                     << " barriers=" << barriers
                     << " send_bytes=" << sendBytes
                     << " unknown_payloads=" << unknown
                     << " world_size=" << worldSize
                     << " network_calibrated=" << (sys_topo.network.calibrated ? 1 : 0)
                     << " alpha=" << llvm::format("%.6g", alpha)
                     << " beta=" << llvm::format("%.6g", beta)
                     << " barrier=" << llvm::format("%.6g", barrierCost)
                     << " modelled_seconds=" << llvm::format("%.6g", modelled)
                     << "\n";
    }

    // Print the transformed module
    module->print(llvm::outs());

    return 0;
}

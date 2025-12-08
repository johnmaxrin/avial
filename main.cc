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

#include <iostream>

#include "includes/avialDialect.h"
#include "includes/avialOps.h"
#include "includes/avialTypes.h"
#include "includes/utils.h"

#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Math/IR/Math.h"
#include "mlir/Dialect/OpenMP/OpenMPDialect.h"

#include "conversions/avialirtompi.h"
#include "conversions/lowerReplicateOp.h"
#include "conversions/affinetoavial.h"
#include "conversions/stdtoavial.h"

#include "mlir/Conversion/LLVMCommon/TypeConverter.h"
#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/MemRefToLLVM/MemRefToLLVM.h"
#include "mlir/Conversion/SCFToOpenMP/SCFToOpenMP.h"
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/Conversion/OpenMPToLLVM/ConvertOpenMPToLLVM.h"
#include "mlir/Conversion/MPIToLLVM/MPIToLLVM.h"

using namespace std;
using namespace mlir;

// Command-line options
static llvm::cl::opt<std::string> inpFileName(
    llvm::cl::Positional,
    llvm::cl::desc("<MLIR Input File>"),
    llvm::cl::Required);

static llvm::cl::opt<bool> dhirToMPI(
    "dhir-to-mpi",
    llvm::cl::desc("Enable DHIR to MPI conversion"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> lowerReplicate(
    "lower-replicate",
    llvm::cl::desc("Enable replicate operation lowering"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> affineTodhir(
    "affine-to-dhir",
    llvm::cl::desc("Enable Affine to DHIR conversion"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> stdTodhir(
    "std-to-dhir",
    llvm::cl::desc("Enable Std Dialects to DHIR conversion"),
    llvm::cl::init(false));

int main(int argc, char *argv[])
{
    // Parse command-line options
    llvm::cl::ParseCommandLineOptions(argc, argv, "DHIR OPT Tool\n");

    mlir::DialectRegistry registry;
    registry.insert<mlir::func::FuncDialect>();
    registry.insert<mlir::memref::MemRefDialect>();
    registry.insert<mlir::scf::SCFDialect>();
    registry.insert<mlir::arith::ArithDialect>();
    registry.insert<mlir::DLTIDialect>();
    registry.insert<mlir::affine::AffineDialect>();
    registry.insert<mlir::math::MathDialect>();
    registry.insert<mlir::omp::OpenMPDialect>();

    MLIRContext context;
    context.allowUnregisteredDialects();
    context.appendDialectRegistry(registry);
    context.getOrLoadDialect<mlir::DLTIDialect>();
    context.printOpOnDiagnostic(true);

    // Open input file
    std::string errorMsg;
    auto mlirFile = mlir::openInputFile(inpFileName, &errorMsg);

    if (!mlirFile)
    {
        llvm::errs() << "Failed to open file: " << errorMsg << "\n";
        return 1;
    }

    SystemTopology sys_topo = parseSystemConfig();

    llvm::SourceMgr sourceMgr;
    sourceMgr.AddNewSourceBuffer(std::move(mlirFile), llvm::SMLoc());

    // Parse MLIR module
    OwningOpRef<ModuleOp> module = mlir::parseSourceFile<mlir::ModuleOp>(sourceMgr, &context);

    if (!module)
    {
        llvm::errs() << "Failed to parse the MLIR file.\n";
        return 2;
    }

    // Add DLTI specifications
    attachDLTISpec(llvm::dyn_cast<mlir::ModuleOp>(module->getOperation()), &context, sys_topo);
    auto vec = extractTargetDeviceSpecs(llvm::dyn_cast<mlir::ModuleOp>(module->getOperation()));

    // Set up pass manager
    PassManager pm(&context);

    if (affineTodhir)
    {
        pm.addPass(mlir::avial::createConvertAffineToAvialPass());
        pm.addPass(mlir::createLowerAffinePass());
    }

    if (stdTodhir)
        pm.addPass(mlir::avial::createConvertStdToAvialPass());

    if (lowerReplicate)
        pm.addPass(mlir::avial::createLowerReplicateOpPass());

    if (dhirToMPI)
    {
        pm.addPass(mlir::avial::createConvertAvialIRToMPIPass());
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

    // Print the transformed module
    module->print(llvm::outs());

    return 0;
}
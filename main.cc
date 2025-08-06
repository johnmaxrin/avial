#include "mlir/IR/Builders.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Attributes.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/Support/FileUtilities.h"
#include "llvm/Support/SourceMgr.h"
#include "mlir/Parser/Parser.h"
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
#include "conversions/stdtoavial.h"
#include "conversions/affinetoavial.h"

// #include "mlir/Conversion/MPIToLLVM/MPIToLLVM.h"

#include "mlir/Conversion/LLVMCommon/TypeConverter.h"
#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/MemRefToLLVM/MemRefToLLVM.h"
#include "mlir/Conversion/SCFToOpenMP/SCFToOpenMP.h"
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/Conversion/OpenMPToLLVM/ConvertOpenMPToLLVM.h"

using namespace std;
using namespace mlir;

int main(int argc, char *argv[])
{
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
    llvm::cl::opt<std::string> inpFileName(llvm::cl::Positional, llvm::cl::desc("<MLIR INP File>"), llvm::cl::Required);
    llvm::cl::ParseCommandLineOptions(argc, argv, "CL Parser\n");

    std::string errorMsg;
    auto mlirFile = mlir::openInputFile(inpFileName, &errorMsg);

    if (!mlirFile)
    {
        llvm::errs() << "Failed to open file: " << errorMsg << "\n";
        return 1;
    }

    llvm::SourceMgr sourceMgr;

    sourceMgr.AddNewSourceBuffer(std::move(mlirFile), llvm::SMLoc());

    // OwningOpRef<ModuleOp> module2 = ModuleOp::create(UnknownLoc::get(&context));
    OwningOpRef<ModuleOp> module = mlir::parseSourceFile<mlir::ModuleOp>(sourceMgr, &context);

    // Add Information about the devices available. 
    attachDLTISpec(llvm::dyn_cast<mlir::ModuleOp>(module->getOperation()),&context);
    auto vec = extractTargetDeviceSpecs(llvm::dyn_cast<mlir::ModuleOp>(module->getOperation())); 

    if (!module) {
        llvm::errs() << "Failed to parse the MLIR file.\n";
        return 2;
    }

    PassManager pm(&context);
    //context.disableMultithreading();

    
    pm.addPass(mlir::avial::createConvertAffineToAvialPass());
    pm.addPass(mlir::createLowerAffinePass());

    pm.addPass(mlir::avial::createConvertStdToAvialPass());
    pm.addPass(mlir::avial::createConvertAvialIRToMPIPass());


    if (failed(pm.run(module->getOperation()))) {
        llvm::errs() << "Failed to run passes\n";
        return 1;
    }



    module->dump();


    return 0;
}
#include "mlir/IR/Builders.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/Verifier.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/OpenMP/OpenMPDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/SCF/IR/SCF.h"

#include "mlir/Dialect/MPI/IR/MPI.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"

#include "mlir/Conversion/MPIToLLVM/MPIToLLVM.h"

#include "mlir/Conversion/LLVMCommon/TypeConverter.h"
#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/MemRefToLLVM/MemRefToLLVM.h"
#include "mlir/Conversion/SCFToOpenMP/SCFToOpenMP.h"
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/Conversion/OpenMPToLLVM/ConvertOpenMPToLLVM.h"

#include "mlir/Support/FileUtilities.h"
#include "mlir/Support/LogicalResult.h"
#include "llvm/Support/ToolOutputFile.h"

#include "mlir/Transforms/Passes.h"

#include "mlir/Dialect/DLTI/DLTI.h"

#include "mlir/Transforms/DialectConversion.h" // from @llvm-project

using namespace mlir;
void insertPrintf(OpBuilder &builder, Location loc, Value rankVal, LLVM::LLVMFuncOp printFunc, LLVM::GlobalOp globalStr, int len);

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
    target.addLegalDialect<mlir::DLTIDialect>();
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

int main()
{
  MLIRContext context;
  context.getOrLoadDialect<mlir::mpi::MPIDialect>();
  context.getOrLoadDialect<mlir::LLVM::LLVMDialect>();
  context.getOrLoadDialect<mlir::func::FuncDialect>();
  context.getOrLoadDialect<mlir::memref::MemRefDialect>();
  context.getOrLoadDialect<mlir::arith::ArithDialect>();
  context.getOrLoadDialect<mlir::scf::SCFDialect>();
  context.getOrLoadDialect<mlir::omp::OpenMPDialect>();

  mlir::OpBuilder builder(&context);
  mlir::ModuleOp module = builder.create<mlir::ModuleOp>(builder.getUnknownLoc());
  auto loc = builder.getUnknownLoc();

  mlir::Location dummyLoc = mlir::FileLineColLoc::get(builder.getStringAttr("dummy.mlir"), 0, 0);
  // Print

  auto i8Type = builder.getI8Type();
  auto i32Type = builder.getI32Type();

  auto i8PtrType = mlir::LLVM::LLVMPointerType::get(&context);
  const char *str = "Val: %d\n\0";
  size_t len = strlen(str);
  auto arrayType = mlir::LLVM::LLVMArrayType::get(i8Type, len);

  auto globalStr = builder.create<mlir::LLVM::GlobalOp>(
      builder.getUnknownLoc(), arrayType, true,
      mlir::LLVM::Linkage::Internal, ".str",
      builder.getStringAttr(str));
  module.push_back(globalStr);

  auto printfType = mlir::LLVM::LLVMFunctionType::get(i8PtrType, {i8PtrType, i32Type}, true);
  auto printfFunc = builder.create<mlir::LLVM::LLVMFuncOp>(
      builder.getUnknownLoc(), "printf", printfType);
  module.push_back(printfFunc);

  // Print

  auto fnType = LLVM::LLVMFunctionType::get(builder.getI32Type(), {});
  auto mainFn = builder.create<LLVM::LLVMFuncOp>(loc, "main", fnType);

  Region &mainFnBody = mainFn.getBody();
  Block *entryBlock = builder.createBlock(&mainFnBody);

  // Set insertion point to the start of the block
  builder.setInsertionPointToStart(entryBlock);

  auto zero = builder.create<LLVM::ConstantOp>(loc, builder.getI32Type(), builder.getI32IntegerAttr(0));
  auto one = builder.create<LLVM::ConstantOp>(loc, builder.getI32Type(), builder.getI32IntegerAttr(1));
  auto ten = builder.create<LLVM::ConstantOp>(loc, builder.getI32Type(), builder.getI32IntegerAttr(10));

  auto initOp = builder.create<mpi::InitOp>(loc, mpi::RetvalType::get(&context));
  auto comm = builder.create<mpi::CommWorldOp>(loc, mpi::CommType::get(builder.getContext()));
  auto rank = builder.create<mpi::CommRankOp>(loc, builder.getI32Type(), comm->getResult(0));
  auto getNodes = builder.create<mpi::CommSizeOp>(loc, mpi::RetvalType::get(&context), builder.getI32Type(), comm->getResult(0));
  
  


  mlir::MemRefType scalarMemRef = mlir::MemRefType::get({1}, builder.getI32Type());
  mlir::MemRefType vectorMemRef = mlir::MemRefType::get({10}, builder.getI32Type());

  auto allocRef = builder.create<memref::AllocaOp>(loc, scalarMemRef);
  auto allocVectorRef = builder.create<memref::AllocaOp>(loc, vectorMemRef);
  auto recvRef = builder.create<memref::AllocaOp>(loc, scalarMemRef);

  auto indexZero = builder.create<arith::ConstantIndexOp>(loc, 0);
  auto indexOne = builder.create<arith::ConstantIndexOp>(loc, 1);
  auto indexTen = builder.create<arith::ConstantIndexOp>(loc, 10);

  builder.create<mlir::memref::StoreOp>(loc, one, recvRef, llvm::ArrayRef<mlir::Value>{indexZero});

  auto rankCond = builder.create<arith::CmpIOp>(loc,builder.getI1Type(), arith::CmpIPredicate::eq, rank.getResult(0), zero.getResult());
  
  builder.create<scf::IfOp>(loc, rankCond, [&](OpBuilder &builder, Location loc){
  builder.create<mpi::SendOp>(loc, mpi::RetvalType::get(&context), allocRef, zero, one, comm.getResult());
  builder.create<scf::YieldOp>(loc);
  },[&](OpBuilder &builder, Location loc){
  builder.create<mpi::RecvOp>(loc, mpi::RetvalType::get(&context), recvRef, zero, zero, comm.getResult());
  builder.create<scf::YieldOp>(loc);
  });

  auto recVal = builder.create<memref::LoadOp>(loc, builder.getI32Type(), recvRef, mlir::ValueRange{indexZero}, false);
  auto cond = builder.create<arith::CmpIOp>(loc,builder.getI1Type(), arith::CmpIPredicate::eq, rank.getResult(0), zero.getResult());
  builder.create<scf::IfOp>(loc, cond, [&](OpBuilder &builder, Location loc){
    //insertPrintf(builder, loc, recVal->getResult(0), printfFunc, globalStr, len);
    //insertPrintf(builder, loc, rank->getResult(0), printfFunc, globalStr, len);
    builder.create<scf::YieldOp>(loc);

  });
  
  //insertPrintf(builder,loc,rank->getResult(0),printfFunc, globalStr, len);
  
  SmallVector<Value> lbs = {indexZero};
  SmallVector<Value> ubs = {indexTen};
  SmallVector<Value> steps = {indexOne};

  auto scfLoop = builder.create<scf::ParallelOp>(loc, lbs, ubs, steps,
                                                 [&](OpBuilder &taskBuilder, Location loc, ValueRange ivs)
                                                 {
                                                   builder.create<mlir::memref::StoreOp>(loc, recVal, allocVectorRef, llvm::ArrayRef<mlir::Value>{ivs[0]});
                                                   auto loadedVal = builder.create<mlir::memref::LoadOp>(loc, allocVectorRef, llvm::ArrayRef<mlir::Value>{ivs[0]});
                                                   insertPrintf(builder, loc, recVal->getResult(0), printfFunc, globalStr, len);
                                                 });

  
  
  //builder.create<mpi::FinalizeOp>(loc, mpi::RetvalType::get(builder.getContext()));
  builder.create<LLVM::ReturnOp>(loc, zero);

  module.push_back(mainFn);

  auto verRet = verify(module);
  module.dump();

  PassManager pm(&context);

  DialectRegistry registry;
  mpi::registerConvertMPIToLLVMInterface(registry);

  context.appendDialectRegistry(registry);

  pm.addPass(createConvertSCFToOpenMPPass());
  pm.addPass(createSCFToControlFlowPass());
  pm.addPass(createConvertControlFlowToLLVMPass());
  pm.addPass(createConvertOpenMPToLLVMPass());
  pm.addPass(createLowerMPIPass());
  pm.addPass(createFinalizeMemRefToLLVMConversionPass());
  pm.addPass(createArithToLLVMConversionPass());

  pm.run(module);


  // File Handling 
  std::string errorMessage;
  auto output = mlir::openOutputFile("op.mlir", &errorMessage);
  if (!output)
  {
    llvm::errs() << "Error opening file: " << errorMessage << "\n";
    return 0;
  }

  module.print(output->os());
  output->keep();

  // File Handling 
  return 0;
}

void insertPrintf(OpBuilder &builder, Location loc, Value rankVal, LLVM::LLVMFuncOp printFunc, LLVM::GlobalOp globalStr, int len)
{
  MLIRContext *context = builder.getContext();

  auto i8Type = builder.getI8Type();
  auto i32Type = builder.getI32Type();

  auto i8PtrType = mlir::LLVM::LLVMPointerType::get(context);
  auto printfType = mlir::LLVM::LLVMFunctionType::get(i8PtrType, {i8PtrType, i32Type}, true);
  auto arrayType = mlir::LLVM::LLVMArrayType::get(i8Type, len);

  auto zero = builder.create<mlir::LLVM::ConstantOp>(
      builder.getUnknownLoc(), i32Type, builder.getI32IntegerAttr(0));
  auto strPtr = builder.create<mlir::LLVM::AddressOfOp>(
      builder.getUnknownLoc(), globalStr);
  auto gep = builder.create<mlir::LLVM::GEPOp>(
      builder.getUnknownLoc(), i8PtrType, arrayType, strPtr,
      mlir::ValueRange{zero, zero});

  builder.create<mlir::LLVM::CallOp>(
      builder.getUnknownLoc(), printFunc, mlir::ValueRange{gep, rankVal});
}
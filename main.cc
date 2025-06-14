#include "mlir/IR/Builders.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/MLIRContext.h"


#include <iostream>

#include "includes/avialDialect.h"
#include "includes/avialOps.h"
#include "includes/avialTypes.h"

#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"

#include "conversions/avialirtompi.h"
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

int main()
{
    MLIRContext context;
    OwningOpRef<ModuleOp> module = ModuleOp::create(UnknownLoc::get(&context));
    OpBuilder builder(&context);

    context.getOrLoadDialect<avial::AvialDialect>();
    context.getOrLoadDialect<memref::MemRefDialect>();
    context.getOrLoadDialect<scf::SCFDialect>();
    context.getOrLoadDialect<arith::ArithDialect>();
    


    // Generate a Sample Avial IR

    // Create inputs and Outputs.
    MemRefType memrefType = MemRefType::get({20}, builder.getI64Type());

    DictionaryAttr arg1 = builder.getDictionaryAttr({builder.getNamedAttr("name", builder.getStringAttr("inp1")),
                                                     builder.getNamedAttr("type", TypeAttr::get(memrefType))});

    DictionaryAttr arg2 = builder.getDictionaryAttr({builder.getNamedAttr("name", builder.getStringAttr("inp2")),
                                                     builder.getNamedAttr("type", TypeAttr::get(memrefType))});


    DictionaryAttr arg3 = builder.getDictionaryAttr({builder.getNamedAttr("name", builder.getStringAttr("inp3")),
                                                     builder.getNamedAttr("type", TypeAttr::get(memrefType))});
    ArrayAttr insAttr = builder.getArrayAttr({arg1, arg2, arg3});
    auto schOp = builder.create<avial::ScheduleOp>(builder.getUnknownLoc(),insAttr, 
        [&](mlir::OpBuilder &builder, mlir::Location loc, mlir::Value value, mlir::ValueRange args)
        {
            auto cpu = builder.create<avial::TargetOp>(builder.getUnknownLoc(), avial::TargetRefType::get(builder.getContext(), "CPU"), "CPU", "0");
            auto t1 = builder.create<avial::TaskOp>(builder.getUnknownLoc(),avial::TaskRefType::get(builder.getContext()),cpu.getResult(), mlir::ValueRange{args[0], args[1] }, mlir::ValueRange{args[2]}, 
                [&](mlir::OpBuilder &builder, mlir::Location loc, mlir::Value value, mlir::ValueRange taskargs){
                    // Create a parallel for all from 0 to 20 and add everything.
                    auto constZero = builder.create<arith::ConstantOp>(loc, builder.getI64Type(), builder.getI64IntegerAttr(0));
                    auto upb = builder.create<arith::ConstantOp>(loc, builder.getI64Type(), builder.getI64IntegerAttr(20));
                    auto step = builder.create<arith::ConstantOp>(loc, builder.getI64Type(), builder.getI64IntegerAttr(1));
                    builder.create<scf::ForOp>(loc, constZero, upb, step, mlir::ValueRange{args},
                        [&](mlir::OpBuilder &builder, mlir::Location nestedLoc, mlir::Value iv, mlir::ValueRange iterArgs){
                            auto indexIv = builder.create<arith::IndexCastOp>(nestedLoc, builder.getIndexType(), iv);
                            auto val1 = builder.create<memref::LoadOp>(nestedLoc, builder.getI64Type(), iterArgs[0], mlir::ValueRange{indexIv}, builder.getBoolAttr(0));
                            auto val2 = builder.create<memref::LoadOp>(nestedLoc, builder.getI64Type(), iterArgs[1], mlir::ValueRange{indexIv}, builder.getBoolAttr(0));

                            auto addVal = builder.create<arith::AddIOp>(nestedLoc, builder.getI64Type(), val1, val2);
                            
                            builder.create<memref::StoreOp>(nestedLoc, addVal.getResult(), iterArgs[2], mlir::ValueRange{indexIv}, builder.getBoolAttr(0));
                            builder.create<mlir::scf::YieldOp>(loc, mlir::ValueRange{iterArgs}); 
                        });

                    builder.create<mlir::avial::YieldOp>(loc);
                });

            t1->setAttr("name", builder.getStringAttr("task1"));
            auto inp2 = builder.create<memref::AllocaOp>(loc,memrefType);
            auto inp3 = builder.create<memref::AllocaOp>(loc,memrefType);
        
            auto t2 = builder.create<avial::TaskOp>(builder.getUnknownLoc(),avial::TaskRefType::get(builder.getContext()),cpu.getResult(), mlir::ValueRange{args[0], inp3->getResult(0) }, mlir::ValueRange{inp2}, 
                [&](mlir::OpBuilder &builder, mlir::Location loc, mlir::Value value, mlir::ValueRange taskargs){
                    // Create a parallel for all from 0 to 20 and add everything.
                    auto constZero = builder.create<arith::ConstantOp>(loc, builder.getI64Type(), builder.getI64IntegerAttr(0));
                    auto upb = builder.create<arith::ConstantOp>(loc, builder.getI64Type(), builder.getI64IntegerAttr(20));
                    auto step = builder.create<arith::ConstantOp>(loc, builder.getI64Type(), builder.getI64IntegerAttr(1));
                    builder.create<scf::ForOp>(loc, constZero, upb, step, mlir::ValueRange{args},
                        [&](mlir::OpBuilder &builder, mlir::Location nestedLoc, mlir::Value iv, mlir::ValueRange iterArgs){
                            auto indexIv = builder.create<arith::IndexCastOp>(nestedLoc, builder.getIndexType(), iv);
                            auto val1 = builder.create<memref::LoadOp>(nestedLoc, builder.getI64Type(), iterArgs[0], mlir::ValueRange{indexIv}, builder.getBoolAttr(0));
                            auto val2 = builder.create<memref::LoadOp>(nestedLoc, builder.getI64Type(), iterArgs[1], mlir::ValueRange{indexIv}, builder.getBoolAttr(0));

                            auto addVal = builder.create<arith::AddIOp>(nestedLoc, builder.getI64Type(), val1, val2);
                            
                            builder.create<memref::StoreOp>(nestedLoc, addVal.getResult(), iterArgs[2], mlir::ValueRange{indexIv}, builder.getBoolAttr(0));
                            builder.create<mlir::scf::YieldOp>(loc, mlir::ValueRange{iterArgs}); 
                        });

                    builder.create<mlir::avial::YieldOp>(loc);
                });
                t2->setAttr("name", builder.getStringAttr("task2"));

                builder.create<mlir::avial::YieldOp>(loc);
        });
    module->push_back(schOp);
    module->dump();

    // End of generating a Sample Avial IR
    DialectRegistry registry;
    // mpi::registerConvertMPIToLLVMInterface(registry);
  
    context.appendDialectRegistry(registry);
    

    // Lowerings.
    PassManager pm(&context);
    pm.addPass(mlir::avial::createConvertAvialIRToMPIPass());

    if (failed(pm.run(module->getOperation()))) {
        llvm::errs() << "Failed to run passes\n";
        return 1;
    }

    


    module->dump();

    // // Lower Everything to LLVM
    PassManager pm2(&context);
    
    pm2.addPass(createConvertFuncToLLVMPass());
    pm2.addPass(createArithToLLVMConversionPass());
    pm2.addPass(createConvertSCFToOpenMPPass());
    pm2.addPass(createSCFToControlFlowPass());
    pm2.addPass(createConvertControlFlowToLLVMPass());
    pm2.addPass(createConvertOpenMPToLLVMPass());
    //pm2.addPass(createLowerMPIPass());  
    pm2.addPass(createFinalizeMemRefToLLVMConversionPass());

    if (failed(pm2.run(module->getOperation()))) {
        llvm::errs() << "Failed to run 2 passes\n";
        return 1;
    }
    
    
    module->dump();
    
    
    return 0;
}
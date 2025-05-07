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

using namespace std;
using namespace mlir;

int main()
{
    MLIRContext context;
    OwningOpRef<ModuleOp> module = ModuleOp::create(UnknownLoc::get(&context));
    OpBuilder builder(&context);

    context.getOrLoadDialect<avial::AvialDialect>();
    context.getOrLoadDialect<memref::MemRefDialect>();

    auto gpu = builder.create<avial::TargetOp>(builder.getUnknownLoc(), avial::TargetRefType::get(builder.getContext(), "CPU"), "CPU", "0");
    module->push_back(gpu);

    // Create inputs and Outputs.
    Type memrefType = MemRefType::get({4}, builder.getF32Type());

    DictionaryAttr arg1 = builder.getDictionaryAttr({builder.getNamedAttr("name", builder.getStringAttr("inp1")),
                                                     builder.getNamedAttr("type", TypeAttr::get(memrefType))});

    ArrayAttr insAttr = builder.getArrayAttr({arg1});

    auto schOp = builder.create<avial::ScheduleOp>(builder.getUnknownLoc(),insAttr, [&](mlir::OpBuilder &builder, mlir::Location loc, mlir::Value value, mlir::ValueRange args)
                                                   {
    auto inputa = builder.create<memref::AllocaOp>(builder.getUnknownLoc(), MemRefType::get({2,2}, builder.getI64Type()));
    auto inputb = builder.create<memref::AllocaOp>(builder.getUnknownLoc(), MemRefType::get({2,2}, builder.getI64Type()));
    auto outputa = builder.create<memref::AllocaOp>(builder.getUnknownLoc(), MemRefType::get({2,2}, builder.getI64Type()));

    auto constOp = builder.create<avial::TaskOp>(builder.getUnknownLoc(),avial::TaskRefType::get(builder.getContext()),gpu.getResult(), mlir::ValueRange{inputa->getResult(0), inputb->getResult(0) }, mlir::ValueRange{outputa->getResult(0)}, [&](mlir::OpBuilder &builder, mlir::Location loc, mlir::Value value, mlir::ValueRange args){

        builder.create<avial::TaskGraphOp>(loc, avial::TaskRefType::get(builder.getContext()));
    }); });

    module->push_back(schOp);

    module->dump();

    return 0;
}
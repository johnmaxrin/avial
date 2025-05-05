#include "mlir/IR/Builders.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/MLIRContext.h"

#include<iostream>

#include "includes/avialDialect.h"
#include "includes/avialOps.h"
#include "includes/avialTypes.h"



using namespace std;
using namespace mlir;

int main()
{
    MLIRContext context;
    OwningOpRef<ModuleOp> module = ModuleOp::create(UnknownLoc::get(&context));
    OpBuilder builder(&context);

    context.getOrLoadDialect<avial::AvialDialect>();

    auto gpu = builder.create<avial::TargetOp>(builder.getUnknownLoc(), avial::TargetRefType::get(builder.getContext(), "GPU"), "CPU", "0");
    module->push_back(gpu);
    
    auto constOp = builder.create<avial::TaskOp>(builder.getUnknownLoc(),avial::TaskRefType::get(builder.getContext()),"CPU" , [&](mlir::OpBuilder &builder, mlir::Location loc, mlir::Value value, mlir::ValueRange args){

        builder.create<avial::TaskGraphOp>(loc, avial::TaskRefType::get(builder.getContext()));
    });

    // auto constOp = builder.create<avial::TaskOp>(builder.getUnknownLoc(),avial::TaskRefType::get(builder.getContext()),avial::MyEnumAttr::get(builder.getContext(), mlir::avial::MyEnum::First));
    module->push_back(constOp);
    module->dump();

    
    return 0;    
}
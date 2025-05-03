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
    
    auto constOp = builder.create<avial::TaskOp>(builder.getUnknownLoc(), [&](mlir::OpBuilder &builder, mlir::Location loc, mlir::Value value, mlir::ValueRange args){

        builder.create<avial::TaskGraphOp>(loc, avial::TargetType::get(builder.getContext(), "cuda"));
    });

    module->push_back(constOp);
    module->dump();

    
    return 0;    
}
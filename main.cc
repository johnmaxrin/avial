#include "mlir/IR/Builders.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/MLIRContext.h"

#include<iostream>

#include "includes/avialDialect.h"
#include "includes/avialOps.h"


using namespace std;
using namespace mlir;

int main()
{
    MLIRContext context;
    OwningOpRef<ModuleOp> module = ModuleOp::create(UnknownLoc::get(&context));
    OpBuilder builder(&context);

    context.getOrLoadDialect<avial::AvialDialect>();
    
    auto constOp = builder.create<avial::AvialConst>(builder.getUnknownLoc());

    module->push_back(constOp);
    module->dump();

    
    return 0;    
}
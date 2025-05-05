#include "includes/avialOps.h"

using namespace mlir;
using namespace mlir::avial;

void mlir::avial::TaskOp::build(OpBuilder &builder, OperationState &state, TaskRefType resType, StringRef arch,
                   function_ref<void(OpBuilder &, Location,  mlir::Value, mlir::ValueRange)> bodyBuilder) {
  state.addTypes(resType);
  state.getOrAddProperties<Properties>().arch = builder.getStringAttr(arch);


  Region *region = state.addRegion();
  Block *block = new Block();
  region->push_back(block);

  if (bodyBuilder) {
    OpBuilder::InsertionGuard guard(builder);
    builder.setInsertionPointToStart(block);
    bodyBuilder(builder, state.location, Value(), ValueRange());
  }
}

#include "includes/avialOps.h"

using namespace mlir;
using namespace mlir::avial;

void mlir::avial::TaskOp::build(OpBuilder &builder, OperationState &state,
                   function_ref<void(OpBuilder &, Location,  mlir::Value, mlir::ValueRange)> bodyBuilder) {
  state.addTypes(builder.getNoneType());

  Region *region = state.addRegion();
  Block *block = new Block();
  region->push_back(block);

  if (bodyBuilder) {
    OpBuilder::InsertionGuard guard(builder);
    builder.setInsertionPointToStart(block);
    bodyBuilder(builder, state.location, Value(), ValueRange());
  }
}

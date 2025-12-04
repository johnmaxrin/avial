#include "includes/avialOps.h"

using namespace mlir;
using namespace mlir::avial;

void mlir::avial::TaskOp::build(OpBuilder &builder, OperationState &state, TaskRefType resType, mlir::Attribute target, ::mlir::ValueRange inputs, mlir::DenseI64ArrayAttr inpRanges, ::mlir::ValueRange outputs, mlir::DenseI64ArrayAttr outRanges,
                                function_ref<void(OpBuilder &, Location, mlir::Value, mlir::ValueRange)> bodyBuilder)
{
  state.addTypes(resType);
  state.addAttribute("target", target);


  state.addAttribute("inpRanges", inpRanges);
  state.addAttribute("outRanges", outRanges);
  

  state.addOperands(inputs);
  state.addOperands(outputs);
  ::llvm::copy(::llvm::ArrayRef<int32_t>({static_cast<int32_t>(inputs.size()), static_cast<int32_t>(outputs.size())}), state.getOrAddProperties<Properties>().operandSegmentSizes.begin());

  Region *region = state.addRegion();
  Block *block = new Block();

  for (auto arg : inputs)
    block->addArgument(arg.getType(), builder.getUnknownLoc());

  for (auto arg : outputs)
    block->addArgument(arg.getType(), builder.getUnknownLoc());

  region->push_back(block);

  if (bodyBuilder)
  {
    OpBuilder::InsertionGuard guard(builder);
    builder.setInsertionPointToStart(block);
    bodyBuilder(builder, state.location, Value(), ValueRange());
  }
}

void mlir::avial::ScheduleOp::build(OpBuilder &builder, OperationState &state, ::mlir::ArrayAttr inputs, ::mlir::StringAttr schName,
                                    function_ref<void(OpBuilder &, Location, mlir::Value, mlir::ValueRange)> bodyBuilder)
{

  state.addAttribute("scheduleName", schName);
  state.getOrAddProperties<Properties>().inputs = inputs;
  llvm::SmallVector<mlir::Type> inputTypes;
  for (mlir::Attribute attr : inputs)
  {
    auto dictAttr = mlir::cast<DictionaryAttr>(attr);
    auto typeAttr = mlir::cast<TypeAttr>(dictAttr.get("type"));
    inputTypes.push_back(typeAttr.getValue());
  }

  Region *region = state.addRegion();
  Block *block = new Block();

  for (auto arg : inputTypes)
    block->addArgument(arg, builder.getUnknownLoc());

  region->push_back(block);

  if (bodyBuilder)
  {
    OpBuilder::InsertionGuard guard(builder);
    builder.setInsertionPointToStart(block);
    bodyBuilder(builder, state.location, Value(), block->getArguments());
  }
}

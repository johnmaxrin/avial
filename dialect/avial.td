
include "mlir/IR/DialectBase.td"
include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/SymbolInterfaces.td"
include "mlir/IR/OpBase.td"
include "mlir/IR/BuiltinAttributes.td"
include "mlir/IR/EnumAttr.td"

include "mlir/Pass/PassBase.td"

include "passes.td"

def AvialDialect : Dialect {
    let summary = "A sample dialect for understanding";
    let name = "avial";
    let cppNamespace = "mlir::avial";
    let useDefaultTypePrinterParser = 1;
}

// Types 




class AvialDialectType<string name, string typeMnemonic, list<Trait> traits = []>
    : TypeDef<AvialDialect, name, traits> {
  let mnemonic = typeMnemonic;
}


def TaskRef : AvialDialectType<"TaskRef", "taskref"> {
  let summary = "Task Ref";
}

def TargetRef : AvialDialectType<"TargetRef", "targetref"> {
  let summary = "Target Ref";
  let parameters = (ins StringRefParameter<"arch">:$value);
  let assemblyFormat = " `<` $value `>` ";
}


// End of types



// Ops
class AvialDialectOp<string mnemonic> : Op<AvialDialect, mnemonic>
{
  let summary = "Operation Class";
}

def TaskOp : Op<AvialDialect, "task", [AttrSizedOperandSegments, SingleBlockImplicitTerminator<"YieldOp">]>
{
  let summary = "Task Operation"; 
  let arguments = (
                   ins AnyAttr : $target,  
                   Variadic<AnyType>: $inputs,
                   DenseI64ArrayAttr:$inpRanges,
                   Variadic<AnyType>: $outputs,
                   DenseI64ArrayAttr:$outRanges,
                   Variadic<AnyType>: $actualBuffer
                   );

  let results = (outs TaskRef : $result);
  let regions = (region SizedRegion<1> : $body);

  let builders = [
    OpBuilder<(ins "TaskRefType":$taskref, "mlir::Attribute":$target, "ValueRange":$inputs, "mlir::DenseI64ArrayAttr":$inpRanges, "ValueRange":$outputs, "mlir::DenseI64ArrayAttr":$outRanges, "ValueRange": $actualBuffer,
      CArg<"function_ref<void(OpBuilder &, Location, Value, ValueRange)>",
           "nullptr">)>
  ];

}


def ScheduleOp : Op<AvialDialect, "schedule", [IsolatedFromAbove,SingleBlockImplicitTerminator<"YieldOp">]>
{
  let summary = "ScheduleOp"; 
  let regions = (region SizedRegion<1> : $body); 

  let arguments = (ins ArrayAttr:$inputs, StrAttr:$scheduleName);

  let builders = [
    OpBuilder<(ins  "::mlir::ArrayAttr":$inputs,"::mlir::StringAttr":$scheduleName, 
      CArg<"function_ref<void(OpBuilder &, Location, Value, ValueRange)>",
           "nullptr">)>
  ];

}

def ReplicateOp : Op<AvialDialect, "replicate", [AttrSizedOperandSegments, SingleBlockImplicitTerminator<"YieldOp">]>
{
  let summary = "ReplicateOp"; 
  let arguments = (ins
                   Variadic<AnyType>: $reads,
                   Variadic<AnyType>: $writes );

  let regions = (region SizedRegion<1> : $body); 
}

def ConvergeOp : Op<AvialDialect, "converge", [AttrSizedOperandSegments, SingleBlockImplicitTerminator<"YieldOp">]>
{
  let summary = "Converge"; 
  let arguments = (ins
                   Variadic<AnyType>: $reads,
                   Variadic<AnyType>: $writes
                    );

  let regions = (region SizedRegion<1> : $body); 
}


def YieldOp : Op<AvialDialect, "yield", [Terminator]>
{
  let summary = "A Terminator";
}

def TaskGraphOp : AvialDialectOp<"taskGraph">
{
  let summary = "Task Operation"; 
  let results = (outs AnyType);
}



// End of Ops


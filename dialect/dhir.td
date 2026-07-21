
include "mlir/IR/DialectBase.td"
include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/SymbolInterfaces.td"
include "mlir/IR/OpBase.td"
include "mlir/IR/BuiltinAttributes.td"
include "mlir/IR/EnumAttr.td"

include "mlir/Pass/PassBase.td"

include "passes.td"

def DhirDialect : Dialect {
    let summary = "A sample dialect for understanding";
    let name = "dhir";
    let cppNamespace = "mlir::dhir";
    let useDefaultTypePrinterParser = 1;
}

// Types 




class DhirDialectType<string name, string typeMnemonic, list<Trait> traits = []>
    : TypeDef<DhirDialect, name, traits> {
  let mnemonic = typeMnemonic;
}


def TaskRef : DhirDialectType<"TaskRef", "taskref"> {
  let summary = "Task Ref";
}

def TargetRef : DhirDialectType<"TargetRef", "targetref"> {
  let summary = "Target Ref";
  let parameters = (ins StringRefParameter<"arch">:$value);
  let assemblyFormat = " `<` $value `>` ";
}


// End of types



// Ops
class DhirDialectOp<string mnemonic> : Op<DhirDialect, mnemonic>
{
  let summary = "Operation Class";
}

def TaskOp : Op<DhirDialect, "task", [AttrSizedOperandSegments, SingleBlockImplicitTerminator<"YieldOp">]>
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


def ScheduleOp : Op<DhirDialect, "schedule", [IsolatedFromAbove,SingleBlockImplicitTerminator<"YieldOp">]>
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

def ReplicateOp : Op<DhirDialect, "replicate", [AttrSizedOperandSegments, SingleBlockImplicitTerminator<"YieldOp">]>
{
  let summary = "ReplicateOp"; 
  let arguments = (ins
                   Variadic<AnyType>: $reads,
                   Variadic<AnyType>: $writes );

  let regions = (region SizedRegion<1> : $body); 
}

def ConvergeOp : Op<DhirDialect, "converge", [AttrSizedOperandSegments, SingleBlockImplicitTerminator<"YieldOp">]>
{
  let summary = "Converge"; 
  let arguments = (ins
                   Variadic<AnyType>: $reads,
                   Variadic<AnyType>: $writes
                    );

  let regions = (region SizedRegion<1> : $body); 
}


def YieldOp : Op<DhirDialect, "yield", [Terminator]>
{
  let summary = "A Terminator";
}

def TaskGraphOp : DhirDialectOp<"taskGraph">
{
  let summary = "Task Operation"; 
  let results = (outs AnyType);
}



// End of Ops



include "mlir/IR/DialectBase.td"
include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/SymbolInterfaces.td"
include "mlir/IR/OpBase.td"
include "mlir/IR/BuiltinAttributes.td"

include "mlir/Pass/PassBase.td"

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
def TaskType : AvialDialectType<"Task", "task"> {
  let summary = "Task type";
}
// End of types



// Ops
class AvialDialectOp<string mnemonic> : Op<AvialDialect, mnemonic>
{
  let summary = "Operation Class";
}

def TaskOp : Op<AvialDialect, "task", [SingleBlockImplicitTerminator<"YieldOp">]>
{
  let summary = "Task Operation"; 
  let results = (outs AnyType);
  let regions = (region SizedRegion<1>);

  let builders = [
    OpBuilder<(ins 
      CArg<"function_ref<void(OpBuilder &, Location, Value, ValueRange)>",
           "nullptr">)>
  ];

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

def TaskScheduleOp : AvialDialectOp<"taskSchedule">
{
  let summary = "Task Operation"; 
  let results = (outs AnyType);
}

// End of Ops



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
}


class AvialDialectOp<string mnemonic> : Op<AvialDialect, mnemonic>
{
  let summary = "Operation Class";
}

def AvialConst : AvialDialectOp<"const">
{
  let summary = "Returns a constant"; 
}


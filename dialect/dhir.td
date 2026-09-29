
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
                   Variadic<AnyType>: $actualBuffer,
                   // Runtime partition range of this shard, as (start, end) index
                   // values in the *base* buffer coordinate space.  It is
                   // populated only when the partitioned loop's trip count is
                   // not known at compile time; otherwise the compile-time
                   // inpRanges/outRanges attributes above describe the shard
                   // and this list stays empty.  Keeping the dynamic case out
                   // of the attributes is what lets a shard's gather/scatter
                   // extent be computed at run time.
                   Variadic<Index>: $rangeOperands
                   );

  let results = (outs TaskRef : $result);
  let regions = (region SizedRegion<1> : $body);

  let builders = [
    OpBuilder<(ins "TaskRefType":$taskref, "mlir::Attribute":$target, "ValueRange":$inputs, "mlir::DenseI64ArrayAttr":$inpRanges, "ValueRange":$outputs, "mlir::DenseI64ArrayAttr":$outRanges, "ValueRange": $actualBuffer,
      "ValueRange":$rangeOperands,
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


//===----------------------------------------------------------------------===//
// Collective Operations
//===----------------------------------------------------------------------===//
//
// The upstream MLIR MPI dialect provides basic point-to-point primitives,
// allreduce, and barrier, but lacks collective operations such as broadcast
// or generalized all-gather variants. The operations below bridge collective
// semantics from the DHIR-to-MPI lowering stage to MPIToLLVM.cc, which lowers
// each operation directly to MPI runtime calls in a manner analogous to
// `MPI_Init` and `MPI_Allreduce`.
//
// Note: Collective operations are not rank-guarded. Every rank in the
// communicator must execute the operation in the same sequence, with matching
// element counts and datatypes. Emitting a collective operation inside a
// rank-conditional block (e.g., `scf.if`) causes non-participating ranks to
// deadlock without diagnostics. Consequently, emitters must only schedule
// these operations at program points where an unconditional `mpi.barrier` is valid.

def BcastOp : Op<DhirDialect, "bcast">
{
  let summary = "One-to-all broadcast of a whole buffer (MPI_Bcast)";
  let description = [{
    Replaces a root-side fan-out loop of point-to-point sends.  `root` is an
    actual MPI rank -- logical node 0 already mapped through the rank/node map
    -- not a node index.  `buffer` is the assembled base allocation, never a
    shard view: a shard loses the partition axis and cannot be concatenated for
    column or higher-rank partitions.
  }];
  let arguments = (ins AnyMemRef:$buffer, I32:$root, AnyType:$comm);
  let assemblyFormat =
      "`(` $buffer `,` $root `,` $comm `)` attr-dict `:` type($buffer) `,` type($comm)";
}

def AllgathervOp : Op<DhirDialect, "allgatherv">
{
  let summary = "In-place all-gather of unevenly sized dim-0 shards (MPI_Allgatherv)";
  let description = [{
    Replaces a gather-to-root followed by a broadcast-to-all of the same base
    allocation -- which is what `MPI_Allgatherv` already is -- and so removes
    the root as a serial bottleneck on both legs, not just on the fan-out.

    Lowers with `MPI_IN_PLACE` as the send buffer: each rank's own shard is
    already sitting at its own displacement inside `buffer`, which is exactly
    the precondition MPI states for in-place all-gather.  `counts` and
    `displacements` are `memref<?xi32>` indexed BY MPI RANK (not by node index),
    counted in elements, and must tile `buffer` exactly -- an off-by-one in
    displacements is a silent wrong answer, not a crash.  The emitter builds
    both from the partitioner's own shard arithmetic.

    Only valid for a partition of dim 0 of a row-major buffer, where a shard is
    a contiguous slab and rank-order concatenation reproduces the whole array.
  }];
  let arguments = (ins AnyMemRef:$buffer, AnyMemRef:$counts,
                       AnyMemRef:$displacements, AnyType:$comm);
  let assemblyFormat =
      "`(` $buffer `,` $counts `,` $displacements `,` $comm `)` attr-dict `:` "
      "type($buffer) `,` type($counts) `,` type($displacements) `,` type($comm)";
}


// End of Ops


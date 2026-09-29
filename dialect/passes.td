def ConvertDhirToMPIPass : Pass<"dhir-to-mpi">{
  let summary = "DHIR to MPI";

  let dependentDialects = ["mlir::dhir::DhirDialect", 
  "::mlir::scf::SCFDialect", "::mlir::memref::MemRefDialect", "mlir::arith::ArithDialect", "mlir::LLVM::LLVMDialect", "mlir::func::FuncDialect", "mlir::mpi::MPIDialect", "mlir::omp::OpenMPDialect"];

}

def ConvertStdToDhirPass : Pass<"std-to-dhir">{
  let summary = "Standard Dialects to DHIR";

  let dependentDialects = ["mlir::dhir::DhirDialect", 
  "::mlir::scf::SCFDialect", "::mlir::memref::MemRefDialect", "mlir::arith::ArithDialect", "mlir::LLVM::LLVMDialect", "mlir::func::FuncDialect", "mlir::mpi::MPIDialect", "mlir::DLTIDialect"];

}


def ConvertAffineToDhirPass : Pass<"affine-to-dhir">{
  let summary = "Affine Dialects to DHIR";

  let dependentDialects = ["mlir::dhir::DhirDialect", 
  "mlir::affine::AffineDialect", "mlir::DLTIDialect"];

}

def UpliftWhileToForPass : Pass<"uplift-while-to-for">
{
  let summary = "Uplift a counted scf.while timestep loop to scf.for";
  let description = [{
    Rewrites an `scf.while` that is a counted timestep loop into an `scf.for`,
    so the distribution machinery -- which dispatches on `scf::ForOp` and only
    pushes a deferred-sync frame there -- can reach it at all.

    Deliberately conservative.  The `before` region must be pure derived ops
    plus one `arith.cmpi slt/ult` of the induction variable against a
    loop-invariant bound; `after` must be a single block ending in an
    `arith.addi` IV increment at its top level with a loop-invariant positive
    constant step; and the body must contain an array-sweeping `for` nest.
    Everything is decided from IR properties; no kernel names are consulted.

    The exit induction value is reconstructed as
    `lb + max(0, ceildiv(ub - lb, step)) * step`, which is the value the
    `scf.while` carries out.  The stock LLVM 22.1.8 uplift computes the last
    *executed* IV and omits the zero-trip clamp, which runs one extra timestep
    whenever the trip count is even.
  }];
  let dependentDialects = ["::mlir::scf::SCFDialect", "mlir::arith::ArithDialect",
    "mlir::affine::AffineDialect", "mlir::memref::MemRefDialect",
    "mlir::dhir::DhirDialect"];
}

def LowerReplicateOpPass : Pass<"lower-replicate-op">
{
  let summary = "Lower Dhir Dialects to Dhir";
  let dependentDialects = ["mlir::dhir::DhirDialect"];
}


def LowerConvergeOpPass : Pass<"lower-converge-op">
{
  let summary = "Lower Converge Op; Basically enable broadcast flag at the end of last set of tasks";
  let dependentDialects = ["mlir::dhir::DhirDialect"];
}

def LocalWorksharePass : Pass<"local-workshare"> {
  let summary = "Share independent local rows while retaining MPI ownership";
  let dependentDialects = ["mlir::dhir::DhirDialect", "mlir::scf::SCFDialect",
    "mlir::memref::MemRefDialect", "mlir::arith::ArithDialect"];
}

def OMPCostModelReportPass : Pass<"dhir-omp-cost-model-report">{
  let summary = "Report OpenMP-aware work/traffic at the DHIR boundary";
  let dependentDialects = ["mlir::dhir::DhirDialect", "mlir::affine::AffineDialect",
    "mlir::func::FuncDialect", "mlir::DLTIDialect"];
}
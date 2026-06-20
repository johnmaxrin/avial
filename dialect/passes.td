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
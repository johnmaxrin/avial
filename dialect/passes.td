def ConvertAvialIRToMPIPass : Pass<"avialir-to-mpi">{
  let summary = "Avial IR to MPI";

  let dependentDialects = ["mlir::avial::AvialDialect", 
  "::mlir::scf::SCFDialect", "::mlir::memref::MemRefDialect", "mlir::arith::ArithDialect", "mlir::LLVM::LLVMDialect", "mlir::func::FuncDialect", "mlir::mpi::MPIDialect", "mlir::omp::OpenMPDialect"];

}

def ConvertStdToAvialPass : Pass<"std-to-avialir">{
  let summary = "Standard Dialects to Avial IR";

  let dependentDialects = ["mlir::avial::AvialDialect", 
  "::mlir::scf::SCFDialect", "::mlir::memref::MemRefDialect", "mlir::arith::ArithDialect", "mlir::LLVM::LLVMDialect", "mlir::func::FuncDialect", "mlir::mpi::MPIDialect", "mlir::DLTIDialect"];

}


def ConvertAffineToAvialPass : Pass<"affine-to-avialir">{
  let summary = "Affine Dialects to Avial IR";

  let dependentDialects = ["mlir::avial::AvialDialect", 
  "mlir::affine::AffineDialect", "mlir::DLTIDialect"];

}

def LowerReplicateOpPass : Pass<"lower-replicate-op">
{
  let summary = "Lower Avial Dialects to Avial";
  let dependentDialects = ["mlir::avial::AvialDialect"];
}


def LowerConvergeOpPass : Pass<"lower-converge-op">
{
  let summary = "Lower Converge Op; Basically enable broadcast flag at the end of last set of tasks";
  let dependentDialects = ["mlir::avial::AvialDialect"];
}
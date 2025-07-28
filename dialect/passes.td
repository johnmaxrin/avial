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
def ConvertAvialIRToMPIPass : Pass<"avialir-to-mpi">{
  let summary = "Avial IR to MPI";

  let dependentDialects = ["mlir::avial::AvialDialect", 
  "::mlir::scf::SCFDialect", "::mlir::memref::MemRefDialect", "mlir::arith::ArithDialect", "mlir::LLVM::LLVMDialect", "mlir::func::FuncDialect"];

}

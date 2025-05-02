set(LLVM_TARGET_DEFINITIONS avial.td)
mlir_tablegen(Dialect.h.inc -gen-dialect-decls -dialect=avial)
mlir_tablegen(Dialect.cpp.inc -gen-dialect-defs -dialect=avial)
mlir_tablegen(Ops.h.inc -gen-op-decls)
mlir_tablegen(Ops.cpp.inc -gen-op-defs)


add_public_tablegen_target(MLIRAvialDialectIncGen)


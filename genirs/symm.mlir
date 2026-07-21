module attributes {dhir.target_devices = [#dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 1.000000e+00 : f32, "node_id" = "node0", "gpu_count" = 0 : i32, "gpu_arch" = [], "gpu_id" = []>, #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 1.000000e+00 : f32, "node_id" = "node1", "gpu_count" = 0 : i32, "gpu_arch" = [], "gpu_id" = []>, #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 1.000000e+00 : f32, "node_id" = "node2", "gpu_count" = 0 : i32, "gpu_arch" = [], "gpu_id" = []>, #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 1.000000e+00 : f32, "node_id" = "node3", "gpu_count" = 0 : i32, "gpu_arch" = [], "gpu_id" = []>]} {
  llvm.func @MPI_Barrier(i32) -> i32
  llvm.func @MPI_Init(!llvm.ptr, !llvm.ptr) -> i32
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @buildRankNodeMaps(!llvm.ptr, !llvm.ptr, !llvm.ptr) attributes {sym_visibility = "private"}
  llvm.mlir.global internal constant @arch_str_3("x86_64\00") {addr_space = 0 : i32}
  llvm.mlir.global internal constant @node_str_3("node3\00") {addr_space = 0 : i32}
  llvm.mlir.global internal constant @arch_str_2("x86_64\00") {addr_space = 0 : i32}
  llvm.mlir.global internal constant @node_str_2("node2\00") {addr_space = 0 : i32}
  llvm.mlir.global internal constant @arch_str_1("x86_64\00") {addr_space = 0 : i32}
  llvm.mlir.global internal constant @node_str_1("node1\00") {addr_space = 0 : i32}
  llvm.mlir.global internal constant @arch_str_0("x86_64\00") {addr_space = 0 : i32}
  llvm.mlir.global internal constant @node_str_0("node0\00") {addr_space = 0 : i32}
  llvm.func @kernel_symm(%arg0: i32, %arg1: i32, %arg2: f32, %arg3: f32, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: i64, %arg10: i64, %arg11: !llvm.ptr, %arg12: !llvm.ptr, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: i64, %arg18: !llvm.ptr, %arg19: !llvm.ptr, %arg20: i64, %arg21: i64, %arg22: i64, %arg23: i64, %arg24: i64) {
    %0 = llvm.mlir.zero : !llvm.ptr
    %1 = llvm.mlir.constant(4 : i64) : i64
    %2 = llvm.mlir.constant(0 : i32) : i32
    %3 = llvm.mlir.constant(1 : i64) : i64
    %4 = llvm.mlir.addressof @node_str_0 : !llvm.ptr
    %5 = llvm.mlir.addressof @arch_str_0 : !llvm.ptr
    %6 = llvm.mlir.constant(1.000000e+00 : f32) : f32
    %7 = llvm.mlir.addressof @node_str_1 : !llvm.ptr
    %8 = llvm.mlir.addressof @arch_str_1 : !llvm.ptr
    %9 = llvm.mlir.addressof @node_str_2 : !llvm.ptr
    %10 = llvm.mlir.addressof @arch_str_2 : !llvm.ptr
    %11 = llvm.mlir.addressof @node_str_3 : !llvm.ptr
    %12 = llvm.mlir.addressof @arch_str_3 : !llvm.ptr
    %13 = llvm.mlir.constant(4 : i32) : i32
    %14 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %15 = llvm.mlir.constant(0 : index) : i64
    %16 = llvm.mlir.constant(1000 : index) : i64
    %17 = llvm.mlir.constant(1 : index) : i64
    %18 = llvm.mlir.constant(-1 : index) : i64
    %19 = llvm.mlir.zero : !llvm.ptr
    %20 = llvm.call @MPI_Init(%19, %19) : (!llvm.ptr, !llvm.ptr) -> i32
    %21 = llvm.mlir.constant(1140850688 : i64) : i64
    %22 = llvm.alloca %1 x !llvm.struct<(ptr, ptr, i32, f32)> : (i64) -> !llvm.ptr
    %23 = llvm.getelementptr %22[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %24 = llvm.getelementptr %22[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %25 = llvm.getelementptr %22[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %26 = llvm.getelementptr %22[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %4, %23 : !llvm.ptr, !llvm.ptr
    llvm.store %5, %24 : !llvm.ptr, !llvm.ptr
    llvm.store %2, %25 : i32, !llvm.ptr
    llvm.store %6, %26 : f32, !llvm.ptr
    %27 = llvm.getelementptr %22[1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %28 = llvm.getelementptr %27[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %29 = llvm.getelementptr %27[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %30 = llvm.getelementptr %27[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %31 = llvm.getelementptr %27[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %7, %28 : !llvm.ptr, !llvm.ptr
    llvm.store %8, %29 : !llvm.ptr, !llvm.ptr
    llvm.store %2, %30 : i32, !llvm.ptr
    llvm.store %6, %31 : f32, !llvm.ptr
    %32 = llvm.getelementptr %22[2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %33 = llvm.getelementptr %32[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %34 = llvm.getelementptr %32[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %35 = llvm.getelementptr %32[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %36 = llvm.getelementptr %32[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %9, %33 : !llvm.ptr, !llvm.ptr
    llvm.store %10, %34 : !llvm.ptr, !llvm.ptr
    llvm.store %2, %35 : i32, !llvm.ptr
    llvm.store %6, %36 : f32, !llvm.ptr
    %37 = llvm.getelementptr %22[3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %38 = llvm.getelementptr %37[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %39 = llvm.getelementptr %37[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %40 = llvm.getelementptr %37[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %41 = llvm.getelementptr %37[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %11, %38 : !llvm.ptr, !llvm.ptr
    llvm.store %12, %39 : !llvm.ptr, !llvm.ptr
    llvm.store %2, %40 : i32, !llvm.ptr
    llvm.store %6, %41 : f32, !llvm.ptr
    %42 = llvm.alloca %3 x !llvm.struct<(i32, ptr)> : (i64) -> !llvm.ptr
    %43 = llvm.getelementptr %42[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(i32, ptr)>
    %44 = llvm.getelementptr %42[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(i32, ptr)>
    llvm.store %13, %43 : i32, !llvm.ptr
    llvm.store %22, %44 : !llvm.ptr, !llvm.ptr
    %45 = llvm.getelementptr %0[4] : (!llvm.ptr) -> !llvm.ptr, i32
    %46 = llvm.ptrtoint %45 : !llvm.ptr to i64
    %47 = llvm.call @malloc(%46) : (i64) -> !llvm.ptr
    %48 = llvm.getelementptr %0[4] : (!llvm.ptr) -> !llvm.ptr, i32
    %49 = llvm.ptrtoint %48 : !llvm.ptr to i64
    %50 = llvm.call @malloc(%49) : (i64) -> !llvm.ptr
    %51 = llvm.ptrtoint %47 : !llvm.ptr to i64
    %52 = llvm.ptrtoint %50 : !llvm.ptr to i64
    %53 = llvm.inttoptr %51 : i64 to !llvm.ptr
    %54 = llvm.inttoptr %52 : i64 to !llvm.ptr
    llvm.call @buildRankNodeMaps(%42, %53, %54) : (!llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.br ^bb1(%15 : i64)
  ^bb1(%55: i64):  // 2 preds: ^bb0, ^bb8
    %56 = llvm.icmp "slt" %55, %16 : i64
    llvm.cond_br %56, ^bb2, ^bb9
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%15 : i64)
  ^bb3(%57: i64):  // 2 preds: ^bb2, ^bb7
    %58 = llvm.icmp "slt" %57, %16 : i64
    llvm.cond_br %58, ^bb4, ^bb8
  ^bb4:  // pred: ^bb3
    %59 = llvm.add %57, %18 : i64
    llvm.br ^bb5(%15, %14 : i64, f32)
  ^bb5(%60: i64, %61: f32):  // 2 preds: ^bb4, ^bb6
    %62 = llvm.icmp "slt" %60, %59 : i64
    llvm.cond_br %62, ^bb6, ^bb7
  ^bb6:  // pred: ^bb5
    %63 = llvm.mul %60, %16 overflow<nsw, nuw> : i64
    %64 = llvm.add %63, %55 overflow<nsw, nuw> : i64
    %65 = llvm.getelementptr inbounds|nuw %arg12[%64] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %66 = llvm.load %65 : !llvm.ptr -> f32
    %67 = llvm.fmul %arg2, %66 : f32
    %68 = llvm.mul %55, %16 overflow<nsw, nuw> : i64
    %69 = llvm.add %68, %57 overflow<nsw, nuw> : i64
    %70 = llvm.getelementptr inbounds|nuw %arg19[%69] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %71 = llvm.load %70 : !llvm.ptr -> f32
    %72 = llvm.fmul %67, %71 : f32
    %73 = llvm.mul %60, %16 overflow<nsw, nuw> : i64
    %74 = llvm.add %73, %57 overflow<nsw, nuw> : i64
    %75 = llvm.getelementptr inbounds|nuw %arg5[%74] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %76 = llvm.load %75 : !llvm.ptr -> f32
    %77 = llvm.fadd %76, %72 : f32
    %78 = llvm.mul %60, %16 overflow<nsw, nuw> : i64
    %79 = llvm.add %78, %57 overflow<nsw, nuw> : i64
    %80 = llvm.getelementptr inbounds|nuw %arg5[%79] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %77, %80 : f32, !llvm.ptr
    %81 = llvm.mul %60, %16 overflow<nsw, nuw> : i64
    %82 = llvm.add %81, %57 overflow<nsw, nuw> : i64
    %83 = llvm.getelementptr inbounds|nuw %arg19[%82] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %84 = llvm.load %83 : !llvm.ptr -> f32
    %85 = llvm.mul %60, %16 overflow<nsw, nuw> : i64
    %86 = llvm.add %85, %55 overflow<nsw, nuw> : i64
    %87 = llvm.getelementptr inbounds|nuw %arg12[%86] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %88 = llvm.load %87 : !llvm.ptr -> f32
    %89 = llvm.fmul %84, %88 : f32
    %90 = llvm.fadd %61, %89 : f32
    %91 = llvm.add %60, %17 : i64
    llvm.br ^bb5(%91, %90 : i64, f32)
  ^bb7:  // pred: ^bb5
    %92 = llvm.mul %55, %16 overflow<nsw, nuw> : i64
    %93 = llvm.add %92, %57 overflow<nsw, nuw> : i64
    %94 = llvm.getelementptr inbounds|nuw %arg5[%93] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %95 = llvm.load %94 : !llvm.ptr -> f32
    %96 = llvm.fmul %arg3, %95 : f32
    %97 = llvm.mul %55, %16 overflow<nsw, nuw> : i64
    %98 = llvm.add %97, %55 overflow<nsw, nuw> : i64
    %99 = llvm.getelementptr inbounds|nuw %arg12[%98] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %100 = llvm.load %99 : !llvm.ptr -> f32
    %101 = llvm.fmul %arg2, %100 : f32
    %102 = llvm.mul %55, %16 overflow<nsw, nuw> : i64
    %103 = llvm.add %102, %57 overflow<nsw, nuw> : i64
    %104 = llvm.getelementptr inbounds|nuw %arg19[%103] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %105 = llvm.load %104 : !llvm.ptr -> f32
    %106 = llvm.fmul %101, %105 : f32
    %107 = llvm.fadd %96, %106 : f32
    %108 = llvm.fmul %arg2, %61 : f32
    %109 = llvm.fadd %107, %108 : f32
    %110 = llvm.mul %55, %16 overflow<nsw, nuw> : i64
    %111 = llvm.add %110, %57 overflow<nsw, nuw> : i64
    %112 = llvm.getelementptr inbounds|nuw %arg5[%111] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %109, %112 : f32, !llvm.ptr
    %113 = llvm.add %57, %17 : i64
    llvm.br ^bb3(%113 : i64)
  ^bb8:  // pred: ^bb3
    %114 = llvm.add %55, %17 : i64
    llvm.br ^bb1(%114 : i64)
  ^bb9:  // pred: ^bb1
    %115 = llvm.trunc %21 : i64 to i32
    %116 = llvm.call @MPI_Barrier(%115) : (i32) -> i32
    llvm.return
  }
}

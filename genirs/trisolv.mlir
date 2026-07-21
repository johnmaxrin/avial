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
  llvm.func @kernel_trisolv(%arg0: i32, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: !llvm.ptr, %arg9: !llvm.ptr, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: !llvm.ptr, %arg14: !llvm.ptr, %arg15: i64, %arg16: i64, %arg17: i64) {
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
    %14 = llvm.mlir.constant(0 : index) : i64
    %15 = llvm.mlir.constant(1000 : index) : i64
    %16 = llvm.mlir.constant(1 : index) : i64
    %17 = llvm.mlir.zero : !llvm.ptr
    %18 = llvm.call @MPI_Init(%17, %17) : (!llvm.ptr, !llvm.ptr) -> i32
    %19 = llvm.mlir.constant(1140850688 : i64) : i64
    %20 = llvm.alloca %1 x !llvm.struct<(ptr, ptr, i32, f32)> : (i64) -> !llvm.ptr
    %21 = llvm.getelementptr %20[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %22 = llvm.getelementptr %20[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %23 = llvm.getelementptr %20[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %24 = llvm.getelementptr %20[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %4, %21 : !llvm.ptr, !llvm.ptr
    llvm.store %5, %22 : !llvm.ptr, !llvm.ptr
    llvm.store %2, %23 : i32, !llvm.ptr
    llvm.store %6, %24 : f32, !llvm.ptr
    %25 = llvm.getelementptr %20[1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %26 = llvm.getelementptr %25[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %27 = llvm.getelementptr %25[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %28 = llvm.getelementptr %25[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %29 = llvm.getelementptr %25[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %7, %26 : !llvm.ptr, !llvm.ptr
    llvm.store %8, %27 : !llvm.ptr, !llvm.ptr
    llvm.store %2, %28 : i32, !llvm.ptr
    llvm.store %6, %29 : f32, !llvm.ptr
    %30 = llvm.getelementptr %20[2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %31 = llvm.getelementptr %30[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %32 = llvm.getelementptr %30[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %33 = llvm.getelementptr %30[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %34 = llvm.getelementptr %30[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %9, %31 : !llvm.ptr, !llvm.ptr
    llvm.store %10, %32 : !llvm.ptr, !llvm.ptr
    llvm.store %2, %33 : i32, !llvm.ptr
    llvm.store %6, %34 : f32, !llvm.ptr
    %35 = llvm.getelementptr %20[3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %36 = llvm.getelementptr %35[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %37 = llvm.getelementptr %35[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %38 = llvm.getelementptr %35[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %39 = llvm.getelementptr %35[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %11, %36 : !llvm.ptr, !llvm.ptr
    llvm.store %12, %37 : !llvm.ptr, !llvm.ptr
    llvm.store %2, %38 : i32, !llvm.ptr
    llvm.store %6, %39 : f32, !llvm.ptr
    %40 = llvm.alloca %3 x !llvm.struct<(i32, ptr)> : (i64) -> !llvm.ptr
    %41 = llvm.getelementptr %40[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(i32, ptr)>
    %42 = llvm.getelementptr %40[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(i32, ptr)>
    llvm.store %13, %41 : i32, !llvm.ptr
    llvm.store %20, %42 : !llvm.ptr, !llvm.ptr
    %43 = llvm.getelementptr %0[4] : (!llvm.ptr) -> !llvm.ptr, i32
    %44 = llvm.ptrtoint %43 : !llvm.ptr to i64
    %45 = llvm.call @malloc(%44) : (i64) -> !llvm.ptr
    %46 = llvm.getelementptr %0[4] : (!llvm.ptr) -> !llvm.ptr, i32
    %47 = llvm.ptrtoint %46 : !llvm.ptr to i64
    %48 = llvm.call @malloc(%47) : (i64) -> !llvm.ptr
    %49 = llvm.ptrtoint %45 : !llvm.ptr to i64
    %50 = llvm.ptrtoint %48 : !llvm.ptr to i64
    %51 = llvm.inttoptr %49 : i64 to !llvm.ptr
    %52 = llvm.inttoptr %50 : i64 to !llvm.ptr
    llvm.call @buildRankNodeMaps(%40, %51, %52) : (!llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.br ^bb1(%14 : i64)
  ^bb1(%53: i64):  // 2 preds: ^bb0, ^bb5
    %54 = llvm.icmp "slt" %53, %15 : i64
    llvm.cond_br %54, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    %55 = llvm.getelementptr inbounds|nuw %arg14[%53] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %56 = llvm.load %55 : !llvm.ptr -> f32
    %57 = llvm.getelementptr inbounds|nuw %arg9[%53] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %56, %57 : f32, !llvm.ptr
    llvm.br ^bb3(%14 : i64)
  ^bb3(%58: i64):  // 2 preds: ^bb2, ^bb4
    %59 = llvm.icmp "slt" %58, %53 : i64
    llvm.cond_br %59, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %60 = llvm.getelementptr inbounds|nuw %arg9[%53] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %61 = llvm.load %60 : !llvm.ptr -> f32
    %62 = llvm.mul %53, %15 overflow<nsw, nuw> : i64
    %63 = llvm.add %62, %58 overflow<nsw, nuw> : i64
    %64 = llvm.getelementptr inbounds|nuw %arg2[%63] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %65 = llvm.load %64 : !llvm.ptr -> f32
    %66 = llvm.getelementptr inbounds|nuw %arg9[%58] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %67 = llvm.load %66 : !llvm.ptr -> f32
    %68 = llvm.fmul %65, %67 : f32
    %69 = llvm.fsub %61, %68 : f32
    %70 = llvm.getelementptr inbounds|nuw %arg9[%53] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %69, %70 : f32, !llvm.ptr
    %71 = llvm.add %58, %16 : i64
    llvm.br ^bb3(%71 : i64)
  ^bb5:  // pred: ^bb3
    %72 = llvm.getelementptr inbounds|nuw %arg9[%53] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %73 = llvm.load %72 : !llvm.ptr -> f32
    %74 = llvm.mul %53, %15 overflow<nsw, nuw> : i64
    %75 = llvm.add %74, %53 overflow<nsw, nuw> : i64
    %76 = llvm.getelementptr inbounds|nuw %arg2[%75] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %77 = llvm.load %76 : !llvm.ptr -> f32
    %78 = llvm.fdiv %73, %77 : f32
    %79 = llvm.getelementptr inbounds|nuw %arg9[%53] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %78, %79 : f32, !llvm.ptr
    %80 = llvm.add %53, %16 : i64
    llvm.br ^bb1(%80 : i64)
  ^bb6:  // pred: ^bb1
    %81 = llvm.trunc %19 : i64 to i32
    %82 = llvm.call @MPI_Barrier(%81) : (i32) -> i32
    llvm.return
  }
}

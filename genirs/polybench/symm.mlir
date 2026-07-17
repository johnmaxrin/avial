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
    %18 = llvm.mlir.zero : !llvm.ptr
    %19 = llvm.call @MPI_Init(%18, %18) : (!llvm.ptr, !llvm.ptr) -> i32
    %20 = llvm.mlir.constant(1140850688 : i64) : i64
    %21 = llvm.alloca %1 x !llvm.struct<(ptr, ptr, i32, f32)> : (i64) -> !llvm.ptr
    %22 = llvm.getelementptr %21[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %23 = llvm.getelementptr %21[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %24 = llvm.getelementptr %21[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %25 = llvm.getelementptr %21[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %4, %22 : !llvm.ptr, !llvm.ptr
    llvm.store %5, %23 : !llvm.ptr, !llvm.ptr
    llvm.store %2, %24 : i32, !llvm.ptr
    llvm.store %6, %25 : f32, !llvm.ptr
    %26 = llvm.getelementptr %21[1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %27 = llvm.getelementptr %26[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %28 = llvm.getelementptr %26[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %29 = llvm.getelementptr %26[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %30 = llvm.getelementptr %26[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %7, %27 : !llvm.ptr, !llvm.ptr
    llvm.store %8, %28 : !llvm.ptr, !llvm.ptr
    llvm.store %2, %29 : i32, !llvm.ptr
    llvm.store %6, %30 : f32, !llvm.ptr
    %31 = llvm.getelementptr %21[2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %32 = llvm.getelementptr %31[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %33 = llvm.getelementptr %31[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %34 = llvm.getelementptr %31[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %35 = llvm.getelementptr %31[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %9, %32 : !llvm.ptr, !llvm.ptr
    llvm.store %10, %33 : !llvm.ptr, !llvm.ptr
    llvm.store %2, %34 : i32, !llvm.ptr
    llvm.store %6, %35 : f32, !llvm.ptr
    %36 = llvm.getelementptr %21[3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %37 = llvm.getelementptr %36[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %38 = llvm.getelementptr %36[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %39 = llvm.getelementptr %36[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %40 = llvm.getelementptr %36[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %11, %37 : !llvm.ptr, !llvm.ptr
    llvm.store %12, %38 : !llvm.ptr, !llvm.ptr
    llvm.store %2, %39 : i32, !llvm.ptr
    llvm.store %6, %40 : f32, !llvm.ptr
    %41 = llvm.alloca %3 x !llvm.struct<(i32, ptr)> : (i64) -> !llvm.ptr
    %42 = llvm.getelementptr %41[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(i32, ptr)>
    %43 = llvm.getelementptr %41[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(i32, ptr)>
    llvm.store %13, %42 : i32, !llvm.ptr
    llvm.store %21, %43 : !llvm.ptr, !llvm.ptr
    %44 = llvm.getelementptr %0[4] : (!llvm.ptr) -> !llvm.ptr, i32
    %45 = llvm.ptrtoint %44 : !llvm.ptr to i64
    %46 = llvm.call @malloc(%45) : (i64) -> !llvm.ptr
    %47 = llvm.getelementptr %0[4] : (!llvm.ptr) -> !llvm.ptr, i32
    %48 = llvm.ptrtoint %47 : !llvm.ptr to i64
    %49 = llvm.call @malloc(%48) : (i64) -> !llvm.ptr
    %50 = llvm.ptrtoint %46 : !llvm.ptr to i64
    %51 = llvm.ptrtoint %49 : !llvm.ptr to i64
    %52 = llvm.inttoptr %50 : i64 to !llvm.ptr
    %53 = llvm.inttoptr %51 : i64 to !llvm.ptr
    llvm.call @buildRankNodeMaps(%41, %52, %53) : (!llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.br ^bb1(%15 : i64)
  ^bb1(%54: i64):  // 2 preds: ^bb0, ^bb8
    %55 = llvm.icmp "slt" %54, %16 : i64
    llvm.cond_br %55, ^bb2, ^bb9
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%15 : i64)
  ^bb3(%56: i64):  // 2 preds: ^bb2, ^bb7
    %57 = llvm.icmp "slt" %56, %16 : i64
    llvm.cond_br %57, ^bb4, ^bb8
  ^bb4:  // pred: ^bb3
    llvm.br ^bb5(%15, %14 : i64, f32)
  ^bb5(%58: i64, %59: f32):  // 2 preds: ^bb4, ^bb6
    %60 = llvm.icmp "slt" %58, %54 : i64
    llvm.cond_br %60, ^bb6, ^bb7
  ^bb6:  // pred: ^bb5
    %61 = llvm.mul %58, %16 overflow<nsw, nuw> : i64
    %62 = llvm.add %61, %54 overflow<nsw, nuw> : i64
    %63 = llvm.getelementptr inbounds|nuw %arg12[%62] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %64 = llvm.load %63 : !llvm.ptr -> f32
    %65 = llvm.fmul %arg2, %64 : f32
    %66 = llvm.mul %54, %16 overflow<nsw, nuw> : i64
    %67 = llvm.add %66, %56 overflow<nsw, nuw> : i64
    %68 = llvm.getelementptr inbounds|nuw %arg19[%67] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %69 = llvm.load %68 : !llvm.ptr -> f32
    %70 = llvm.fmul %65, %69 : f32
    %71 = llvm.mul %58, %16 overflow<nsw, nuw> : i64
    %72 = llvm.add %71, %56 overflow<nsw, nuw> : i64
    %73 = llvm.getelementptr inbounds|nuw %arg5[%72] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %74 = llvm.load %73 : !llvm.ptr -> f32
    %75 = llvm.fadd %74, %70 : f32
    %76 = llvm.mul %58, %16 overflow<nsw, nuw> : i64
    %77 = llvm.add %76, %56 overflow<nsw, nuw> : i64
    %78 = llvm.getelementptr inbounds|nuw %arg5[%77] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %75, %78 : f32, !llvm.ptr
    %79 = llvm.mul %58, %16 overflow<nsw, nuw> : i64
    %80 = llvm.add %79, %56 overflow<nsw, nuw> : i64
    %81 = llvm.getelementptr inbounds|nuw %arg19[%80] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %82 = llvm.load %81 : !llvm.ptr -> f32
    %83 = llvm.mul %58, %16 overflow<nsw, nuw> : i64
    %84 = llvm.add %83, %54 overflow<nsw, nuw> : i64
    %85 = llvm.getelementptr inbounds|nuw %arg12[%84] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %86 = llvm.load %85 : !llvm.ptr -> f32
    %87 = llvm.fmul %82, %86 : f32
    %88 = llvm.fadd %59, %87 : f32
    %89 = llvm.add %58, %17 : i64
    llvm.br ^bb5(%89, %88 : i64, f32)
  ^bb7:  // pred: ^bb5
    %90 = llvm.mul %54, %16 overflow<nsw, nuw> : i64
    %91 = llvm.add %90, %56 overflow<nsw, nuw> : i64
    %92 = llvm.getelementptr inbounds|nuw %arg5[%91] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %93 = llvm.load %92 : !llvm.ptr -> f32
    %94 = llvm.fmul %arg3, %93 : f32
    %95 = llvm.mul %54, %16 overflow<nsw, nuw> : i64
    %96 = llvm.add %95, %54 overflow<nsw, nuw> : i64
    %97 = llvm.getelementptr inbounds|nuw %arg12[%96] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %98 = llvm.load %97 : !llvm.ptr -> f32
    %99 = llvm.fmul %arg2, %98 : f32
    %100 = llvm.mul %54, %16 overflow<nsw, nuw> : i64
    %101 = llvm.add %100, %56 overflow<nsw, nuw> : i64
    %102 = llvm.getelementptr inbounds|nuw %arg19[%101] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %103 = llvm.load %102 : !llvm.ptr -> f32
    %104 = llvm.fmul %99, %103 : f32
    %105 = llvm.fadd %94, %104 : f32
    %106 = llvm.fmul %arg2, %59 : f32
    %107 = llvm.fadd %105, %106 : f32
    %108 = llvm.mul %54, %16 overflow<nsw, nuw> : i64
    %109 = llvm.add %108, %56 overflow<nsw, nuw> : i64
    %110 = llvm.getelementptr inbounds|nuw %arg5[%109] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %107, %110 : f32, !llvm.ptr
    %111 = llvm.add %56, %17 : i64
    llvm.br ^bb3(%111 : i64)
  ^bb8:  // pred: ^bb3
    %112 = llvm.add %54, %17 : i64
    llvm.br ^bb1(%112 : i64)
  ^bb9:  // pred: ^bb1
    %113 = llvm.trunc %20 : i64 to i32
    %114 = llvm.call @MPI_Barrier(%113) : (i32) -> i32
    llvm.return
  }
}

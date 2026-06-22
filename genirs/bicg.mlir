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
  llvm.func @kernel_bicg(%arg0: i32, %arg1: i32, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: !llvm.ptr, %arg10: !llvm.ptr, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: !llvm.ptr, %arg20: !llvm.ptr, %arg21: i64, %arg22: i64, %arg23: i64, %arg24: !llvm.ptr, %arg25: !llvm.ptr, %arg26: i64, %arg27: i64, %arg28: i64) {
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
  ^bb1(%54: i64):  // 2 preds: ^bb0, ^bb5
    %55 = llvm.icmp "slt" %54, %16 : i64
    llvm.cond_br %55, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    %56 = llvm.getelementptr inbounds|nuw %arg15[%54] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %14, %56 : f32, !llvm.ptr
    llvm.br ^bb3(%15 : i64)
  ^bb3(%57: i64):  // 2 preds: ^bb2, ^bb4
    %58 = llvm.icmp "slt" %57, %16 : i64
    llvm.cond_br %58, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %59 = llvm.getelementptr inbounds|nuw %arg10[%57] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %60 = llvm.load %59 : !llvm.ptr -> f32
    %61 = llvm.getelementptr inbounds|nuw %arg25[%54] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %62 = llvm.load %61 : !llvm.ptr -> f32
    %63 = llvm.mul %54, %16 overflow<nsw, nuw> : i64
    %64 = llvm.add %63, %57 overflow<nsw, nuw> : i64
    %65 = llvm.getelementptr inbounds|nuw %arg3[%64] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %66 = llvm.load %65 : !llvm.ptr -> f32
    %67 = llvm.fmul %62, %66 : f32
    %68 = llvm.fadd %60, %67 : f32
    %69 = llvm.getelementptr inbounds|nuw %arg10[%57] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %68, %69 : f32, !llvm.ptr
    %70 = llvm.getelementptr inbounds|nuw %arg15[%54] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %71 = llvm.load %70 : !llvm.ptr -> f32
    %72 = llvm.mul %54, %16 overflow<nsw, nuw> : i64
    %73 = llvm.add %72, %57 overflow<nsw, nuw> : i64
    %74 = llvm.getelementptr inbounds|nuw %arg3[%73] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %75 = llvm.load %74 : !llvm.ptr -> f32
    %76 = llvm.getelementptr inbounds|nuw %arg20[%57] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %77 = llvm.load %76 : !llvm.ptr -> f32
    %78 = llvm.fmul %75, %77 : f32
    %79 = llvm.fadd %71, %78 : f32
    %80 = llvm.getelementptr inbounds|nuw %arg15[%54] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %79, %80 : f32, !llvm.ptr
    %81 = llvm.add %57, %17 : i64
    llvm.br ^bb3(%81 : i64)
  ^bb5:  // pred: ^bb3
    %82 = llvm.add %54, %17 : i64
    llvm.br ^bb1(%82 : i64)
  ^bb6:  // pred: ^bb1
    %83 = llvm.trunc %20 : i64 to i32
    %84 = llvm.call @MPI_Barrier(%83) : (i32) -> i32
    llvm.return
  }
}

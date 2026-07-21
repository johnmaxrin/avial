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
  llvm.func @kernel_floyd_warshall(%arg0: i32, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64) {
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
    %15 = llvm.mlir.constant(128 : index) : i64
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
  ^bb1(%53: i64):  // 2 preds: ^bb0, ^bb12
    %54 = llvm.icmp "slt" %53, %15 : i64
    llvm.cond_br %54, ^bb2, ^bb13
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%14 : i64)
  ^bb3(%55: i64):  // 2 preds: ^bb2, ^bb11
    %56 = llvm.icmp "slt" %55, %15 : i64
    llvm.cond_br %56, ^bb4, ^bb12
  ^bb4:  // pred: ^bb3
    llvm.br ^bb5(%14 : i64)
  ^bb5(%57: i64):  // 2 preds: ^bb4, ^bb10
    %58 = llvm.icmp "slt" %57, %15 : i64
    llvm.cond_br %58, ^bb6, ^bb11
  ^bb6:  // pred: ^bb5
    %59 = llvm.mul %55, %15 overflow<nsw, nuw> : i64
    %60 = llvm.add %59, %57 overflow<nsw, nuw> : i64
    %61 = llvm.getelementptr inbounds|nuw %arg2[%60] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %62 = llvm.load %61 : !llvm.ptr -> f32
    %63 = llvm.mul %55, %15 overflow<nsw, nuw> : i64
    %64 = llvm.add %63, %53 overflow<nsw, nuw> : i64
    %65 = llvm.getelementptr inbounds|nuw %arg2[%64] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %66 = llvm.load %65 : !llvm.ptr -> f32
    %67 = llvm.mul %53, %15 overflow<nsw, nuw> : i64
    %68 = llvm.add %67, %57 overflow<nsw, nuw> : i64
    %69 = llvm.getelementptr inbounds|nuw %arg2[%68] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %70 = llvm.load %69 : !llvm.ptr -> f32
    %71 = llvm.fadd %66, %70 : f32
    %72 = llvm.fcmp "olt" %62, %71 : f32
    llvm.cond_br %72, ^bb7, ^bb8
  ^bb7:  // pred: ^bb6
    %73 = llvm.mul %55, %15 overflow<nsw, nuw> : i64
    %74 = llvm.add %73, %57 overflow<nsw, nuw> : i64
    %75 = llvm.getelementptr inbounds|nuw %arg2[%74] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %76 = llvm.load %75 : !llvm.ptr -> f32
    llvm.br ^bb9(%76 : f32)
  ^bb8:  // pred: ^bb6
    %77 = llvm.mul %55, %15 overflow<nsw, nuw> : i64
    %78 = llvm.add %77, %53 overflow<nsw, nuw> : i64
    %79 = llvm.getelementptr inbounds|nuw %arg2[%78] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %80 = llvm.load %79 : !llvm.ptr -> f32
    %81 = llvm.mul %53, %15 overflow<nsw, nuw> : i64
    %82 = llvm.add %81, %57 overflow<nsw, nuw> : i64
    %83 = llvm.getelementptr inbounds|nuw %arg2[%82] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %84 = llvm.load %83 : !llvm.ptr -> f32
    %85 = llvm.fadd %80, %84 : f32
    llvm.br ^bb9(%85 : f32)
  ^bb9(%86: f32):  // 2 preds: ^bb7, ^bb8
    llvm.br ^bb10
  ^bb10:  // pred: ^bb9
    %87 = llvm.mul %55, %15 overflow<nsw, nuw> : i64
    %88 = llvm.add %87, %57 overflow<nsw, nuw> : i64
    %89 = llvm.getelementptr inbounds|nuw %arg2[%88] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %86, %89 : f32, !llvm.ptr
    %90 = llvm.add %57, %16 : i64
    llvm.br ^bb5(%90 : i64)
  ^bb11:  // pred: ^bb5
    %91 = llvm.add %55, %16 : i64
    llvm.br ^bb3(%91 : i64)
  ^bb12:  // pred: ^bb3
    %92 = llvm.add %53, %16 : i64
    llvm.br ^bb1(%92 : i64)
  ^bb13:  // pred: ^bb1
    %93 = llvm.trunc %19 : i64 to i32
    %94 = llvm.call @MPI_Barrier(%93) : (i32) -> i32
    llvm.return
  }
}

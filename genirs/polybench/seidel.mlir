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
  llvm.func @kernel_seidel_2d(%arg0: i32, %arg1: i32, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64) {
    %0 = llvm.mlir.constant(128 : index) : i64
    %1 = llvm.mlir.zero : !llvm.ptr
    %2 = llvm.mlir.constant(4 : i64) : i64
    %3 = llvm.mlir.constant(0 : i32) : i32
    %4 = llvm.mlir.constant(1 : i64) : i64
    %5 = llvm.mlir.addressof @node_str_0 : !llvm.ptr
    %6 = llvm.mlir.addressof @arch_str_0 : !llvm.ptr
    %7 = llvm.mlir.constant(1.000000e+00 : f32) : f32
    %8 = llvm.mlir.addressof @node_str_1 : !llvm.ptr
    %9 = llvm.mlir.addressof @arch_str_1 : !llvm.ptr
    %10 = llvm.mlir.addressof @node_str_2 : !llvm.ptr
    %11 = llvm.mlir.addressof @arch_str_2 : !llvm.ptr
    %12 = llvm.mlir.addressof @node_str_3 : !llvm.ptr
    %13 = llvm.mlir.addressof @arch_str_3 : !llvm.ptr
    %14 = llvm.mlir.constant(4 : i32) : i32
    %15 = llvm.mlir.constant(9.000000e+00 : f64) : f64
    %16 = llvm.mlir.constant(0 : index) : i64
    %17 = llvm.mlir.constant(20 : index) : i64
    %18 = llvm.mlir.constant(1 : index) : i64
    %19 = llvm.mlir.constant(127 : index) : i64
    %20 = llvm.mlir.constant(-1 : index) : i64
    %21 = llvm.mlir.zero : !llvm.ptr
    %22 = llvm.call @MPI_Init(%21, %21) : (!llvm.ptr, !llvm.ptr) -> i32
    %23 = llvm.mlir.constant(1140850688 : i64) : i64
    %24 = llvm.alloca %2 x !llvm.struct<(ptr, ptr, i32, f32)> : (i64) -> !llvm.ptr
    %25 = llvm.getelementptr %24[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %26 = llvm.getelementptr %24[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %27 = llvm.getelementptr %24[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %28 = llvm.getelementptr %24[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %5, %25 : !llvm.ptr, !llvm.ptr
    llvm.store %6, %26 : !llvm.ptr, !llvm.ptr
    llvm.store %3, %27 : i32, !llvm.ptr
    llvm.store %7, %28 : f32, !llvm.ptr
    %29 = llvm.getelementptr %24[1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %30 = llvm.getelementptr %29[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %31 = llvm.getelementptr %29[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %32 = llvm.getelementptr %29[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %33 = llvm.getelementptr %29[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %8, %30 : !llvm.ptr, !llvm.ptr
    llvm.store %9, %31 : !llvm.ptr, !llvm.ptr
    llvm.store %3, %32 : i32, !llvm.ptr
    llvm.store %7, %33 : f32, !llvm.ptr
    %34 = llvm.getelementptr %24[2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %35 = llvm.getelementptr %34[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %36 = llvm.getelementptr %34[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %37 = llvm.getelementptr %34[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %38 = llvm.getelementptr %34[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %10, %35 : !llvm.ptr, !llvm.ptr
    llvm.store %11, %36 : !llvm.ptr, !llvm.ptr
    llvm.store %3, %37 : i32, !llvm.ptr
    llvm.store %7, %38 : f32, !llvm.ptr
    %39 = llvm.getelementptr %24[3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %40 = llvm.getelementptr %39[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %41 = llvm.getelementptr %39[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %42 = llvm.getelementptr %39[0, 2] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    %43 = llvm.getelementptr %39[0, 3] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(ptr, ptr, i32, f32)>
    llvm.store %12, %40 : !llvm.ptr, !llvm.ptr
    llvm.store %13, %41 : !llvm.ptr, !llvm.ptr
    llvm.store %3, %42 : i32, !llvm.ptr
    llvm.store %7, %43 : f32, !llvm.ptr
    %44 = llvm.alloca %4 x !llvm.struct<(i32, ptr)> : (i64) -> !llvm.ptr
    %45 = llvm.getelementptr %44[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(i32, ptr)>
    %46 = llvm.getelementptr %44[0, 1] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<(i32, ptr)>
    llvm.store %14, %45 : i32, !llvm.ptr
    llvm.store %24, %46 : !llvm.ptr, !llvm.ptr
    %47 = llvm.getelementptr %1[4] : (!llvm.ptr) -> !llvm.ptr, i32
    %48 = llvm.ptrtoint %47 : !llvm.ptr to i64
    %49 = llvm.call @malloc(%48) : (i64) -> !llvm.ptr
    %50 = llvm.getelementptr %1[4] : (!llvm.ptr) -> !llvm.ptr, i32
    %51 = llvm.ptrtoint %50 : !llvm.ptr to i64
    %52 = llvm.call @malloc(%51) : (i64) -> !llvm.ptr
    %53 = llvm.ptrtoint %49 : !llvm.ptr to i64
    %54 = llvm.ptrtoint %52 : !llvm.ptr to i64
    %55 = llvm.inttoptr %53 : i64 to !llvm.ptr
    %56 = llvm.inttoptr %54 : i64 to !llvm.ptr
    llvm.call @buildRankNodeMaps(%44, %55, %56) : (!llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.br ^bb1(%16 : i64)
  ^bb1(%57: i64):  // 2 preds: ^bb0, ^bb8
    %58 = llvm.icmp "slt" %57, %17 : i64
    llvm.cond_br %58, ^bb2, ^bb9
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%18 : i64)
  ^bb3(%59: i64):  // 2 preds: ^bb2, ^bb7
    %60 = llvm.icmp "slt" %59, %19 : i64
    llvm.cond_br %60, ^bb4, ^bb8
  ^bb4:  // pred: ^bb3
    llvm.br ^bb5(%18 : i64)
  ^bb5(%61: i64):  // 2 preds: ^bb4, ^bb6
    %62 = llvm.icmp "slt" %61, %19 : i64
    llvm.cond_br %62, ^bb6, ^bb7
  ^bb6:  // pred: ^bb5
    %63 = llvm.add %59, %20 : i64
    %64 = llvm.add %61, %20 : i64
    %65 = llvm.mul %63, %0 overflow<nsw, nuw> : i64
    %66 = llvm.add %65, %64 overflow<nsw, nuw> : i64
    %67 = llvm.getelementptr inbounds|nuw %arg3[%66] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %68 = llvm.load %67 : !llvm.ptr -> f32
    %69 = llvm.add %59, %20 : i64
    %70 = llvm.mul %69, %0 overflow<nsw, nuw> : i64
    %71 = llvm.add %70, %61 overflow<nsw, nuw> : i64
    %72 = llvm.getelementptr inbounds|nuw %arg3[%71] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %73 = llvm.load %72 : !llvm.ptr -> f32
    %74 = llvm.fadd %68, %73 : f32
    %75 = llvm.add %59, %20 : i64
    %76 = llvm.add %61, %18 : i64
    %77 = llvm.mul %75, %0 overflow<nsw, nuw> : i64
    %78 = llvm.add %77, %76 overflow<nsw, nuw> : i64
    %79 = llvm.getelementptr inbounds|nuw %arg3[%78] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %80 = llvm.load %79 : !llvm.ptr -> f32
    %81 = llvm.fadd %74, %80 : f32
    %82 = llvm.add %61, %20 : i64
    %83 = llvm.mul %59, %0 overflow<nsw, nuw> : i64
    %84 = llvm.add %83, %82 overflow<nsw, nuw> : i64
    %85 = llvm.getelementptr inbounds|nuw %arg3[%84] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %86 = llvm.load %85 : !llvm.ptr -> f32
    %87 = llvm.fadd %81, %86 : f32
    %88 = llvm.mul %59, %0 overflow<nsw, nuw> : i64
    %89 = llvm.add %88, %61 overflow<nsw, nuw> : i64
    %90 = llvm.getelementptr inbounds|nuw %arg3[%89] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %91 = llvm.load %90 : !llvm.ptr -> f32
    %92 = llvm.fadd %87, %91 : f32
    %93 = llvm.add %61, %18 : i64
    %94 = llvm.mul %59, %0 overflow<nsw, nuw> : i64
    %95 = llvm.add %94, %93 overflow<nsw, nuw> : i64
    %96 = llvm.getelementptr inbounds|nuw %arg3[%95] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %97 = llvm.load %96 : !llvm.ptr -> f32
    %98 = llvm.fadd %92, %97 : f32
    %99 = llvm.add %59, %18 : i64
    %100 = llvm.add %61, %20 : i64
    %101 = llvm.mul %99, %0 overflow<nsw, nuw> : i64
    %102 = llvm.add %101, %100 overflow<nsw, nuw> : i64
    %103 = llvm.getelementptr inbounds|nuw %arg3[%102] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %104 = llvm.load %103 : !llvm.ptr -> f32
    %105 = llvm.fadd %98, %104 : f32
    %106 = llvm.add %59, %18 : i64
    %107 = llvm.mul %106, %0 overflow<nsw, nuw> : i64
    %108 = llvm.add %107, %61 overflow<nsw, nuw> : i64
    %109 = llvm.getelementptr inbounds|nuw %arg3[%108] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %110 = llvm.load %109 : !llvm.ptr -> f32
    %111 = llvm.fadd %105, %110 : f32
    %112 = llvm.add %59, %18 : i64
    %113 = llvm.add %61, %18 : i64
    %114 = llvm.mul %112, %0 overflow<nsw, nuw> : i64
    %115 = llvm.add %114, %113 overflow<nsw, nuw> : i64
    %116 = llvm.getelementptr inbounds|nuw %arg3[%115] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %117 = llvm.load %116 : !llvm.ptr -> f32
    %118 = llvm.fadd %111, %117 : f32
    %119 = llvm.fpext %118 : f32 to f64
    %120 = llvm.fdiv %119, %15 : f64
    %121 = llvm.fptrunc %120 : f64 to f32
    %122 = llvm.mul %59, %0 overflow<nsw, nuw> : i64
    %123 = llvm.add %122, %61 overflow<nsw, nuw> : i64
    %124 = llvm.getelementptr inbounds|nuw %arg3[%123] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %121, %124 : f32, !llvm.ptr
    %125 = llvm.add %61, %18 : i64
    llvm.br ^bb5(%125 : i64)
  ^bb7:  // pred: ^bb5
    %126 = llvm.add %59, %18 : i64
    llvm.br ^bb3(%126 : i64)
  ^bb8:  // pred: ^bb3
    %127 = llvm.add %57, %18 : i64
    llvm.br ^bb1(%127 : i64)
  ^bb9:  // pred: ^bb1
    %128 = llvm.trunc %23 : i64 to i32
    %129 = llvm.call @MPI_Barrier(%128) : (i32) -> i32
    llvm.return
  }
}

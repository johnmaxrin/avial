module attributes {avial.target_devices = [#dlti.target_device_spec<"type" = "node", "arch" = "x86">, #dlti.target_device_spec<"type" = "node", "arch" = "x86">]} {
  llvm.func @MPI_Barrier(i32) -> i32
  llvm.func @MPI_Comm_size(i32, !llvm.ptr) -> i32
  llvm.func @MPI_Comm_rank(i32, !llvm.ptr) -> i32
  llvm.func @MPI_Init(!llvm.ptr, !llvm.ptr) -> i32
  llvm.func @testFunc(%arg0: i32, %arg1: i32, %arg2: i32, %arg3: i32, %arg4: f32, %arg5: f32, %arg6: !llvm.ptr, %arg7: !llvm.ptr, %arg8: i64, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: !llvm.ptr, %arg14: !llvm.ptr, %arg15: i64, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: !llvm.ptr, %arg21: !llvm.ptr, %arg22: i64, %arg23: i64, %arg24: i64, %arg25: i64, %arg26: i64, %arg27: !llvm.ptr, %arg28: !llvm.ptr, %arg29: i64, %arg30: i64, %arg31: i64, %arg32: i64, %arg33: i64, %arg34: !llvm.ptr, %arg35: !llvm.ptr, %arg36: i64, %arg37: i64, %arg38: i64, %arg39: i64, %arg40: i64) {
    %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.insertvalue %arg34, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.insertvalue %arg35, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.insertvalue %arg36, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.insertvalue %arg37, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.insertvalue %arg39, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %arg38, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg40, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.insertvalue %arg27, %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg28, %9[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg29, %10[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg30, %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg32, %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %arg31, %13[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.insertvalue %arg33, %14[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %17 = llvm.insertvalue %arg20, %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.insertvalue %arg21, %17[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %arg22, %18[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %arg23, %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %arg25, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %arg24, %21[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %arg26, %22[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %25 = llvm.insertvalue %arg13, %24[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %26 = llvm.insertvalue %arg14, %25[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %27 = llvm.insertvalue %arg15, %26[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %28 = llvm.insertvalue %arg16, %27[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %29 = llvm.insertvalue %arg18, %28[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %30 = llvm.insertvalue %arg17, %29[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %31 = llvm.insertvalue %arg19, %30[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %32 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %33 = llvm.insertvalue %arg6, %32[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %34 = llvm.insertvalue %arg7, %33[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %35 = llvm.insertvalue %arg8, %34[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %36 = llvm.insertvalue %arg9, %35[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %37 = llvm.insertvalue %arg11, %36[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %38 = llvm.insertvalue %arg10, %37[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %39 = llvm.insertvalue %arg12, %38[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %40 = llvm.mlir.zero : !llvm.ptr
    %41 = llvm.call @MPI_Init(%40, %40) : (!llvm.ptr, !llvm.ptr) -> i32
    %42 = llvm.mlir.constant(1140850688 : i64) : i64
    %43 = llvm.trunc %42 : i64 to i32
    %44 = llvm.mlir.constant(1 : i32) : i32
    %45 = llvm.alloca %44 x i32 : (i32) -> !llvm.ptr
    %46 = llvm.call @MPI_Comm_rank(%43, %45) : (i32, !llvm.ptr) -> i32
    %47 = llvm.load %45 : !llvm.ptr -> i32
    %48 = llvm.trunc %42 : i64 to i32
    %49 = llvm.mlir.constant(1 : i32) : i32
    %50 = llvm.alloca %49 x i32 : (i32) -> !llvm.ptr
    %51 = llvm.call @MPI_Comm_size(%48, %50) : (i32, !llvm.ptr) -> i32
    %52 = llvm.load %50 : !llvm.ptr -> i32
    %53 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %54 = llvm.mlir.constant(0 : i32) : i32
    %55 = llvm.srem %54, %52 : i32
    %56 = llvm.icmp "eq" %47, %55 : i32
    llvm.cond_br %56, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %57 = llvm.mlir.constant(500 : index) : i64
    %58 = llvm.mlir.constant(1000 : index) : i64
    %59 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg41) : i64 = (%57) to (%58) step (%59) {
          %80 = llvm.mlir.constant(0 : index) : i64
          %81 = llvm.mlir.constant(0 : index) : i64
          %82 = llvm.mlir.constant(1000 : index) : i64
          %83 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%81 : i64)
        ^bb1(%84: i64):  // 2 preds: ^bb0, ^bb5
          %85 = llvm.icmp "slt" %84, %82 : i64
          llvm.cond_br %85, ^bb2, ^bb6
        ^bb2:  // pred: ^bb1
          %86 = llvm.extractvalue %39[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %87 = llvm.mlir.constant(1000 : index) : i64
          %88 = llvm.mul %80, %87 overflow<nsw, nuw> : i64
          %89 = llvm.add %88, %84 overflow<nsw, nuw> : i64
          %90 = llvm.getelementptr  %86[%89] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %53, %90 : f32, !llvm.ptr
          %91 = llvm.mlir.constant(0 : index) : i64
          %92 = llvm.mlir.constant(1000 : index) : i64
          %93 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb3(%91 : i64)
        ^bb3(%94: i64):  // 2 preds: ^bb2, ^bb4
          %95 = llvm.icmp "slt" %94, %92 : i64
          llvm.cond_br %95, ^bb4, ^bb5
        ^bb4:  // pred: ^bb3
          %96 = llvm.extractvalue %31[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %97 = llvm.mlir.constant(1000 : index) : i64
          %98 = llvm.mul %80, %97 overflow<nsw, nuw> : i64
          %99 = llvm.add %98, %94 overflow<nsw, nuw> : i64
          %100 = llvm.getelementptr  %96[%99] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %101 = llvm.load %100 : !llvm.ptr -> f32
          %102 = llvm.fmul %arg4, %101 : f32
          %103 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %104 = llvm.mlir.constant(1000 : index) : i64
          %105 = llvm.mul %94, %104 overflow<nsw, nuw> : i64
          %106 = llvm.add %105, %84 overflow<nsw, nuw> : i64
          %107 = llvm.getelementptr  %103[%106] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %108 = llvm.load %107 : !llvm.ptr -> f32
          %109 = llvm.fmul %102, %108 : f32
          %110 = llvm.extractvalue %39[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %111 = llvm.mlir.constant(1000 : index) : i64
          %112 = llvm.mul %80, %111 overflow<nsw, nuw> : i64
          %113 = llvm.add %112, %84 overflow<nsw, nuw> : i64
          %114 = llvm.getelementptr  %110[%113] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %115 = llvm.load %114 : !llvm.ptr -> f32
          %116 = llvm.fadd %115, %109 : f32
          %117 = llvm.extractvalue %39[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %118 = llvm.mlir.constant(1000 : index) : i64
          %119 = llvm.mul %80, %118 overflow<nsw, nuw> : i64
          %120 = llvm.add %119, %84 overflow<nsw, nuw> : i64
          %121 = llvm.getelementptr  %117[%120] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %116, %121 : f32, !llvm.ptr
          %122 = llvm.add %94, %93 : i64
          llvm.br ^bb3(%122 : i64)
        ^bb5:  // pred: ^bb3
          %123 = llvm.add %84, %83 : i64
          llvm.br ^bb1(%123 : i64)
        ^bb6:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb2
  ^bb2:  // 2 preds: ^bb0, ^bb1
    %60 = llvm.mlir.constant(1 : i32) : i32
    %61 = llvm.srem %60, %52 : i32
    %62 = llvm.icmp "eq" %47, %61 : i32
    llvm.cond_br %62, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    %63 = llvm.mlir.constant(0 : index) : i64
    %64 = llvm.mlir.constant(500 : index) : i64
    %65 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg41) : i64 = (%63) to (%64) step (%65) {
          %80 = llvm.mlir.constant(0 : index) : i64
          %81 = llvm.mlir.constant(0 : index) : i64
          %82 = llvm.mlir.constant(1000 : index) : i64
          %83 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%81 : i64)
        ^bb1(%84: i64):  // 2 preds: ^bb0, ^bb5
          %85 = llvm.icmp "slt" %84, %82 : i64
          llvm.cond_br %85, ^bb2, ^bb6
        ^bb2:  // pred: ^bb1
          %86 = llvm.extractvalue %39[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %87 = llvm.mlir.constant(1000 : index) : i64
          %88 = llvm.mul %80, %87 overflow<nsw, nuw> : i64
          %89 = llvm.add %88, %84 overflow<nsw, nuw> : i64
          %90 = llvm.getelementptr  %86[%89] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %53, %90 : f32, !llvm.ptr
          %91 = llvm.mlir.constant(0 : index) : i64
          %92 = llvm.mlir.constant(1000 : index) : i64
          %93 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb3(%91 : i64)
        ^bb3(%94: i64):  // 2 preds: ^bb2, ^bb4
          %95 = llvm.icmp "slt" %94, %92 : i64
          llvm.cond_br %95, ^bb4, ^bb5
        ^bb4:  // pred: ^bb3
          %96 = llvm.extractvalue %31[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %97 = llvm.mlir.constant(1000 : index) : i64
          %98 = llvm.mul %80, %97 overflow<nsw, nuw> : i64
          %99 = llvm.add %98, %94 overflow<nsw, nuw> : i64
          %100 = llvm.getelementptr  %96[%99] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %101 = llvm.load %100 : !llvm.ptr -> f32
          %102 = llvm.fmul %arg4, %101 : f32
          %103 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %104 = llvm.mlir.constant(1000 : index) : i64
          %105 = llvm.mul %94, %104 overflow<nsw, nuw> : i64
          %106 = llvm.add %105, %84 overflow<nsw, nuw> : i64
          %107 = llvm.getelementptr  %103[%106] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %108 = llvm.load %107 : !llvm.ptr -> f32
          %109 = llvm.fmul %102, %108 : f32
          %110 = llvm.extractvalue %39[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %111 = llvm.mlir.constant(1000 : index) : i64
          %112 = llvm.mul %80, %111 overflow<nsw, nuw> : i64
          %113 = llvm.add %112, %84 overflow<nsw, nuw> : i64
          %114 = llvm.getelementptr  %110[%113] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %115 = llvm.load %114 : !llvm.ptr -> f32
          %116 = llvm.fadd %115, %109 : f32
          %117 = llvm.extractvalue %39[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %118 = llvm.mlir.constant(1000 : index) : i64
          %119 = llvm.mul %80, %118 overflow<nsw, nuw> : i64
          %120 = llvm.add %119, %84 overflow<nsw, nuw> : i64
          %121 = llvm.getelementptr  %117[%120] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %116, %121 : f32, !llvm.ptr
          %122 = llvm.add %94, %93 : i64
          llvm.br ^bb3(%122 : i64)
        ^bb5:  // pred: ^bb3
          %123 = llvm.add %84, %83 : i64
          llvm.br ^bb1(%123 : i64)
        ^bb6:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb4
  ^bb4:  // 2 preds: ^bb2, ^bb3
    %66 = llvm.mlir.constant(2 : i32) : i32
    %67 = llvm.srem %66, %52 : i32
    %68 = llvm.icmp "eq" %47, %67 : i32
    llvm.cond_br %68, ^bb5, ^bb6
  ^bb5:  // pred: ^bb4
    %69 = llvm.mlir.constant(500 : index) : i64
    %70 = llvm.mlir.constant(1000 : index) : i64
    %71 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg41) : i64 = (%69) to (%70) step (%71) {
          %80 = llvm.mlir.constant(0 : index) : i64
          %81 = llvm.mlir.constant(0 : index) : i64
          %82 = llvm.mlir.constant(1000 : index) : i64
          %83 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%81 : i64)
        ^bb1(%84: i64):  // 2 preds: ^bb0, ^bb5
          %85 = llvm.icmp "slt" %84, %82 : i64
          llvm.cond_br %85, ^bb2, ^bb6
        ^bb2:  // pred: ^bb1
          %86 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %87 = llvm.mlir.constant(1000 : index) : i64
          %88 = llvm.mul %80, %87 overflow<nsw, nuw> : i64
          %89 = llvm.add %88, %84 overflow<nsw, nuw> : i64
          %90 = llvm.getelementptr  %86[%89] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %91 = llvm.load %90 : !llvm.ptr -> f32
          %92 = llvm.fmul %91, %arg5 : f32
          %93 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %94 = llvm.mlir.constant(1000 : index) : i64
          %95 = llvm.mul %80, %94 overflow<nsw, nuw> : i64
          %96 = llvm.add %95, %84 overflow<nsw, nuw> : i64
          %97 = llvm.getelementptr  %93[%96] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %92, %97 : f32, !llvm.ptr
          %98 = llvm.mlir.constant(0 : index) : i64
          %99 = llvm.mlir.constant(1000 : index) : i64
          %100 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb3(%98 : i64)
        ^bb3(%101: i64):  // 2 preds: ^bb2, ^bb4
          %102 = llvm.icmp "slt" %101, %99 : i64
          llvm.cond_br %102, ^bb4, ^bb5
        ^bb4:  // pred: ^bb3
          %103 = llvm.extractvalue %39[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %104 = llvm.mlir.constant(1000 : index) : i64
          %105 = llvm.mul %80, %104 overflow<nsw, nuw> : i64
          %106 = llvm.add %105, %101 overflow<nsw, nuw> : i64
          %107 = llvm.getelementptr  %103[%106] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %108 = llvm.load %107 : !llvm.ptr -> f32
          %109 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %110 = llvm.mlir.constant(1000 : index) : i64
          %111 = llvm.mul %101, %110 overflow<nsw, nuw> : i64
          %112 = llvm.add %111, %84 overflow<nsw, nuw> : i64
          %113 = llvm.getelementptr  %109[%112] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %114 = llvm.load %113 : !llvm.ptr -> f32
          %115 = llvm.fmul %108, %114 : f32
          %116 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %117 = llvm.mlir.constant(1000 : index) : i64
          %118 = llvm.mul %80, %117 overflow<nsw, nuw> : i64
          %119 = llvm.add %118, %84 overflow<nsw, nuw> : i64
          %120 = llvm.getelementptr  %116[%119] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %121 = llvm.load %120 : !llvm.ptr -> f32
          %122 = llvm.fadd %121, %115 : f32
          %123 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %124 = llvm.mlir.constant(1000 : index) : i64
          %125 = llvm.mul %80, %124 overflow<nsw, nuw> : i64
          %126 = llvm.add %125, %84 overflow<nsw, nuw> : i64
          %127 = llvm.getelementptr  %123[%126] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %122, %127 : f32, !llvm.ptr
          %128 = llvm.add %101, %100 : i64
          llvm.br ^bb3(%128 : i64)
        ^bb5:  // pred: ^bb3
          %129 = llvm.add %84, %83 : i64
          llvm.br ^bb1(%129 : i64)
        ^bb6:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb6
  ^bb6:  // 2 preds: ^bb4, ^bb5
    %72 = llvm.mlir.constant(3 : i32) : i32
    %73 = llvm.srem %72, %52 : i32
    %74 = llvm.icmp "eq" %47, %73 : i32
    llvm.cond_br %74, ^bb7, ^bb8
  ^bb7:  // pred: ^bb6
    %75 = llvm.mlir.constant(0 : index) : i64
    %76 = llvm.mlir.constant(500 : index) : i64
    %77 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg41) : i64 = (%75) to (%76) step (%77) {
          %80 = llvm.mlir.constant(0 : index) : i64
          %81 = llvm.mlir.constant(0 : index) : i64
          %82 = llvm.mlir.constant(1000 : index) : i64
          %83 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%81 : i64)
        ^bb1(%84: i64):  // 2 preds: ^bb0, ^bb5
          %85 = llvm.icmp "slt" %84, %82 : i64
          llvm.cond_br %85, ^bb2, ^bb6
        ^bb2:  // pred: ^bb1
          %86 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %87 = llvm.mlir.constant(1000 : index) : i64
          %88 = llvm.mul %80, %87 overflow<nsw, nuw> : i64
          %89 = llvm.add %88, %84 overflow<nsw, nuw> : i64
          %90 = llvm.getelementptr  %86[%89] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %91 = llvm.load %90 : !llvm.ptr -> f32
          %92 = llvm.fmul %91, %arg5 : f32
          %93 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %94 = llvm.mlir.constant(1000 : index) : i64
          %95 = llvm.mul %80, %94 overflow<nsw, nuw> : i64
          %96 = llvm.add %95, %84 overflow<nsw, nuw> : i64
          %97 = llvm.getelementptr  %93[%96] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %92, %97 : f32, !llvm.ptr
          %98 = llvm.mlir.constant(0 : index) : i64
          %99 = llvm.mlir.constant(1000 : index) : i64
          %100 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb3(%98 : i64)
        ^bb3(%101: i64):  // 2 preds: ^bb2, ^bb4
          %102 = llvm.icmp "slt" %101, %99 : i64
          llvm.cond_br %102, ^bb4, ^bb5
        ^bb4:  // pred: ^bb3
          %103 = llvm.extractvalue %39[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %104 = llvm.mlir.constant(1000 : index) : i64
          %105 = llvm.mul %80, %104 overflow<nsw, nuw> : i64
          %106 = llvm.add %105, %101 overflow<nsw, nuw> : i64
          %107 = llvm.getelementptr  %103[%106] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %108 = llvm.load %107 : !llvm.ptr -> f32
          %109 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %110 = llvm.mlir.constant(1000 : index) : i64
          %111 = llvm.mul %101, %110 overflow<nsw, nuw> : i64
          %112 = llvm.add %111, %84 overflow<nsw, nuw> : i64
          %113 = llvm.getelementptr  %109[%112] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %114 = llvm.load %113 : !llvm.ptr -> f32
          %115 = llvm.fmul %108, %114 : f32
          %116 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %117 = llvm.mlir.constant(1000 : index) : i64
          %118 = llvm.mul %80, %117 overflow<nsw, nuw> : i64
          %119 = llvm.add %118, %84 overflow<nsw, nuw> : i64
          %120 = llvm.getelementptr  %116[%119] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %121 = llvm.load %120 : !llvm.ptr -> f32
          %122 = llvm.fadd %121, %115 : f32
          %123 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %124 = llvm.mlir.constant(1000 : index) : i64
          %125 = llvm.mul %80, %124 overflow<nsw, nuw> : i64
          %126 = llvm.add %125, %84 overflow<nsw, nuw> : i64
          %127 = llvm.getelementptr  %123[%126] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %122, %127 : f32, !llvm.ptr
          %128 = llvm.add %101, %100 : i64
          llvm.br ^bb3(%128 : i64)
        ^bb5:  // pred: ^bb3
          %129 = llvm.add %84, %83 : i64
          llvm.br ^bb1(%129 : i64)
        ^bb6:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb8
  ^bb8:  // 2 preds: ^bb6, ^bb7
    %78 = llvm.trunc %42 : i64 to i32
    %79 = llvm.call @MPI_Barrier(%78) : (i32) -> i32
    llvm.return
  }
}
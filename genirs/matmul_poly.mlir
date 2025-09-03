module attributes {avial.target_devices = [#dlti.target_device_spec<"type" = "node", "arch" = "x86">, #dlti.target_device_spec<"type" = "node", "arch" = "x86">]} {
  llvm.func @MPI_Barrier(i32) -> i32
  llvm.func @MPI_Comm_size(i32, !llvm.ptr) -> i32
  llvm.func @MPI_Comm_rank(i32, !llvm.ptr) -> i32
  llvm.func @MPI_Init(!llvm.ptr, !llvm.ptr) -> i32
  llvm.func @testFunc(%arg0: i32, %arg1: i32, %arg2: i32, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: i64, %arg10: !llvm.ptr, %arg11: !llvm.ptr, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: !llvm.ptr, %arg18: !llvm.ptr, %arg19: i64, %arg20: i64, %arg21: i64, %arg22: i64, %arg23: i64) {
    %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.insertvalue %arg17, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.insertvalue %arg18, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.insertvalue %arg19, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.insertvalue %arg20, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.insertvalue %arg22, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %arg21, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg23, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.insertvalue %arg10, %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg11, %9[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg12, %10[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg13, %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg15, %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %arg14, %13[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.insertvalue %arg16, %14[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %17 = llvm.insertvalue %arg3, %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.insertvalue %arg4, %17[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %arg5, %18[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %arg6, %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %arg8, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %arg7, %21[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %arg9, %22[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.mlir.zero : !llvm.ptr
    %25 = llvm.call @MPI_Init(%24, %24) : (!llvm.ptr, !llvm.ptr) -> i32
    %26 = llvm.mlir.constant(1140850688 : i64) : i64
    %27 = llvm.trunc %26 : i64 to i32
    %28 = llvm.mlir.constant(1 : i32) : i32
    %29 = llvm.alloca %28 x i32 : (i32) -> !llvm.ptr
    %30 = llvm.call @MPI_Comm_rank(%27, %29) : (i32, !llvm.ptr) -> i32
    %31 = llvm.load %29 : !llvm.ptr -> i32
    %32 = llvm.trunc %26 : i64 to i32
    %33 = llvm.mlir.constant(1 : i32) : i32
    %34 = llvm.alloca %33 x i32 : (i32) -> !llvm.ptr
    %35 = llvm.call @MPI_Comm_size(%32, %34) : (i32, !llvm.ptr) -> i32
    %36 = llvm.load %34 : !llvm.ptr -> i32
    %37 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %38 = llvm.sext %arg0 : i32 to i64
    %39 = llvm.sext %arg1 : i32 to i64
    %40 = llvm.sext %arg2 : i32 to i64
    %41 = llvm.mlir.constant(0 : i32) : i32
    %42 = llvm.srem %41, %36 : i32
    %43 = llvm.icmp "eq" %31, %42 : i32
    llvm.cond_br %43, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %44 = llvm.mlir.constant(500 : index) : i64
    %45 = llvm.mlir.constant(1000 : index) : i64
    %46 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg24) : i64 = (%44) to (%45) step (%46) {
          %55 = llvm.mlir.constant(0 : index) : i64
          %56 = llvm.mlir.constant(0 : index) : i64
          %57 = llvm.mlir.constant(1000 : index) : i64
          %58 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%56 : i64)
        ^bb1(%59: i64):  // 2 preds: ^bb0, ^bb5
          %60 = llvm.icmp "slt" %59, %57 : i64
          llvm.cond_br %60, ^bb2, ^bb6
        ^bb2:  // pred: ^bb1
          %61 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %62 = llvm.mlir.constant(128 : index) : i64
          %63 = llvm.mul %55, %62 overflow<nsw, nuw> : i64
          %64 = llvm.add %63, %59 overflow<nsw, nuw> : i64
          %65 = llvm.getelementptr  %61[%64] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %37, %65 : f32, !llvm.ptr
          %66 = llvm.mlir.constant(0 : index) : i64
          %67 = llvm.mlir.constant(1000 : index) : i64
          %68 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb3(%66 : i64)
        ^bb3(%69: i64):  // 2 preds: ^bb2, ^bb4
          %70 = llvm.icmp "slt" %69, %67 : i64
          llvm.cond_br %70, ^bb4, ^bb5
        ^bb4:  // pred: ^bb3
          %71 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %72 = llvm.mlir.constant(128 : index) : i64
          %73 = llvm.mul %55, %72 overflow<nsw, nuw> : i64
          %74 = llvm.add %73, %69 overflow<nsw, nuw> : i64
          %75 = llvm.getelementptr  %71[%74] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %76 = llvm.load %75 : !llvm.ptr -> f32
          %77 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %78 = llvm.mlir.constant(128 : index) : i64
          %79 = llvm.mul %69, %78 overflow<nsw, nuw> : i64
          %80 = llvm.add %79, %59 overflow<nsw, nuw> : i64
          %81 = llvm.getelementptr  %77[%80] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %82 = llvm.load %81 : !llvm.ptr -> f32
          %83 = llvm.fmul %76, %82 : f32
          %84 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %85 = llvm.mlir.constant(128 : index) : i64
          %86 = llvm.mul %55, %85 overflow<nsw, nuw> : i64
          %87 = llvm.add %86, %59 overflow<nsw, nuw> : i64
          %88 = llvm.getelementptr  %84[%87] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %89 = llvm.load %88 : !llvm.ptr -> f32
          %90 = llvm.fadd %89, %83 : f32
          %91 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %92 = llvm.mlir.constant(128 : index) : i64
          %93 = llvm.mul %55, %92 overflow<nsw, nuw> : i64
          %94 = llvm.add %93, %59 overflow<nsw, nuw> : i64
          %95 = llvm.getelementptr  %91[%94] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %90, %95 : f32, !llvm.ptr
          %96 = llvm.add %69, %68 : i64
          llvm.br ^bb3(%96 : i64)
        ^bb5:  // pred: ^bb3
          %97 = llvm.add %59, %58 : i64
          llvm.br ^bb1(%97 : i64)
        ^bb6:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb2
  ^bb2:  // 2 preds: ^bb0, ^bb1
    %47 = llvm.mlir.constant(1 : i32) : i32
    %48 = llvm.srem %47, %36 : i32
    %49 = llvm.icmp "eq" %31, %48 : i32
    llvm.cond_br %49, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    %50 = llvm.mlir.constant(0 : index) : i64
    %51 = llvm.mlir.constant(500 : index) : i64
    %52 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg24) : i64 = (%50) to (%51) step (%52) {
          %55 = llvm.mlir.constant(0 : index) : i64
          %56 = llvm.mlir.constant(0 : index) : i64
          %57 = llvm.mlir.constant(1000 : index) : i64
          %58 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%56 : i64)
        ^bb1(%59: i64):  // 2 preds: ^bb0, ^bb5
          %60 = llvm.icmp "slt" %59, %57 : i64
          llvm.cond_br %60, ^bb2, ^bb6
        ^bb2:  // pred: ^bb1
          %61 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %62 = llvm.mlir.constant(128 : index) : i64
          %63 = llvm.mul %55, %62 overflow<nsw, nuw> : i64
          %64 = llvm.add %63, %59 overflow<nsw, nuw> : i64
          %65 = llvm.getelementptr  %61[%64] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %37, %65 : f32, !llvm.ptr
          %66 = llvm.mlir.constant(0 : index) : i64
          %67 = llvm.mlir.constant(1000 : index) : i64
          %68 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb3(%66 : i64)
        ^bb3(%69: i64):  // 2 preds: ^bb2, ^bb4
          %70 = llvm.icmp "slt" %69, %67 : i64
          llvm.cond_br %70, ^bb4, ^bb5
        ^bb4:  // pred: ^bb3
          %71 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %72 = llvm.mlir.constant(128 : index) : i64
          %73 = llvm.mul %55, %72 overflow<nsw, nuw> : i64
          %74 = llvm.add %73, %69 overflow<nsw, nuw> : i64
          %75 = llvm.getelementptr  %71[%74] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %76 = llvm.load %75 : !llvm.ptr -> f32
          %77 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %78 = llvm.mlir.constant(128 : index) : i64
          %79 = llvm.mul %69, %78 overflow<nsw, nuw> : i64
          %80 = llvm.add %79, %59 overflow<nsw, nuw> : i64
          %81 = llvm.getelementptr  %77[%80] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %82 = llvm.load %81 : !llvm.ptr -> f32
          %83 = llvm.fmul %76, %82 : f32
          %84 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %85 = llvm.mlir.constant(128 : index) : i64
          %86 = llvm.mul %55, %85 overflow<nsw, nuw> : i64
          %87 = llvm.add %86, %59 overflow<nsw, nuw> : i64
          %88 = llvm.getelementptr  %84[%87] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %89 = llvm.load %88 : !llvm.ptr -> f32
          %90 = llvm.fadd %89, %83 : f32
          %91 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %92 = llvm.mlir.constant(128 : index) : i64
          %93 = llvm.mul %55, %92 overflow<nsw, nuw> : i64
          %94 = llvm.add %93, %59 overflow<nsw, nuw> : i64
          %95 = llvm.getelementptr  %91[%94] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %90, %95 : f32, !llvm.ptr
          %96 = llvm.add %69, %68 : i64
          llvm.br ^bb3(%96 : i64)
        ^bb5:  // pred: ^bb3
          %97 = llvm.add %59, %58 : i64
          llvm.br ^bb1(%97 : i64)
        ^bb6:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb4
  ^bb4:  // 2 preds: ^bb2, ^bb3
    %53 = llvm.trunc %26 : i64 to i32
    %54 = llvm.call @MPI_Barrier(%53) : (i32) -> i32
    llvm.return
  }
}
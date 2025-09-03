module attributes {avial.target_devices = [#dlti.target_device_spec<"type" = "node", "arch" = "x86">, #dlti.target_device_spec<"type" = "node", "arch" = "x86">]} {
  llvm.func @MPI_Barrier(i32) -> i32
  llvm.func @MPI_Comm_size(i32, !llvm.ptr) -> i32
  llvm.func @MPI_Comm_rank(i32, !llvm.ptr) -> i32
  llvm.func @MPI_Init(!llvm.ptr, !llvm.ptr) -> i32
  llvm.func @testFunc(%arg0: i32, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: !llvm.ptr, %arg7: !llvm.ptr, %arg8: i64, %arg9: i64, %arg10: i64, %arg11: !llvm.ptr, %arg12: !llvm.ptr, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: !llvm.ptr, %arg17: !llvm.ptr, %arg18: i64, %arg19: i64, %arg20: i64, %arg21: !llvm.ptr, %arg22: !llvm.ptr, %arg23: i64, %arg24: i64, %arg25: i64, %arg26: i64, %arg27: i64) {
    %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.insertvalue %arg21, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.insertvalue %arg22, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.insertvalue %arg23, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.insertvalue %arg24, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.insertvalue %arg26, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %arg25, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg27, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %9 = llvm.insertvalue %arg16, %8[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %10 = llvm.insertvalue %arg17, %9[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %11 = llvm.insertvalue %arg18, %10[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %12 = llvm.insertvalue %arg19, %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %13 = llvm.insertvalue %arg20, %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %15 = llvm.insertvalue %arg11, %14[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %16 = llvm.insertvalue %arg12, %15[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %17 = llvm.insertvalue %arg13, %16[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %18 = llvm.insertvalue %arg14, %17[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %19 = llvm.insertvalue %arg15, %18[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %20 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %21 = llvm.insertvalue %arg6, %20[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %22 = llvm.insertvalue %arg7, %21[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %23 = llvm.insertvalue %arg8, %22[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %24 = llvm.insertvalue %arg9, %23[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %25 = llvm.insertvalue %arg10, %24[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %26 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %27 = llvm.insertvalue %arg1, %26[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %28 = llvm.insertvalue %arg2, %27[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %29 = llvm.insertvalue %arg3, %28[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %30 = llvm.insertvalue %arg4, %29[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %31 = llvm.insertvalue %arg5, %30[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %32 = llvm.mlir.zero : !llvm.ptr
    %33 = llvm.call @MPI_Init(%32, %32) : (!llvm.ptr, !llvm.ptr) -> i32
    %34 = llvm.mlir.constant(1140850688 : i64) : i64
    %35 = llvm.trunc %34 : i64 to i32
    %36 = llvm.mlir.constant(1 : i32) : i32
    %37 = llvm.alloca %36 x i32 : (i32) -> !llvm.ptr
    %38 = llvm.call @MPI_Comm_rank(%35, %37) : (i32, !llvm.ptr) -> i32
    %39 = llvm.load %37 : !llvm.ptr -> i32
    %40 = llvm.trunc %34 : i64 to i32
    %41 = llvm.mlir.constant(1 : i32) : i32
    %42 = llvm.alloca %41 x i32 : (i32) -> !llvm.ptr
    %43 = llvm.call @MPI_Comm_size(%40, %42) : (i32, !llvm.ptr) -> i32
    %44 = llvm.load %42 : !llvm.ptr -> i32
    %45 = llvm.mlir.constant(0 : i32) : i32
    %46 = llvm.srem %45, %44 : i32
    %47 = llvm.icmp "eq" %39, %46 : i32
    llvm.cond_br %47, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %48 = llvm.mlir.constant(64 : index) : i64
    %49 = llvm.mlir.constant(128 : index) : i64
    %50 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg28) : i64 = (%48) to (%49) step (%50) {
          %71 = llvm.mlir.constant(0 : index) : i64
          %72 = llvm.mlir.constant(0 : index) : i64
          %73 = llvm.mlir.constant(128 : index) : i64
          %74 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%72 : i64)
        ^bb1(%75: i64):  // 2 preds: ^bb0, ^bb2
          %76 = llvm.icmp "slt" %75, %73 : i64
          llvm.cond_br %76, ^bb2, ^bb3
        ^bb2:  // pred: ^bb1
          %77 = llvm.extractvalue %31[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
          %78 = llvm.getelementptr  %77[%71] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %79 = llvm.load %78 : !llvm.ptr -> f32
          %80 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %81 = llvm.mlir.constant(128 : index) : i64
          %82 = llvm.mul %71, %81 overflow<nsw, nuw> : i64
          %83 = llvm.add %82, %75 overflow<nsw, nuw> : i64
          %84 = llvm.getelementptr  %80[%83] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %85 = llvm.load %84 : !llvm.ptr -> f32
          %86 = llvm.extractvalue %19[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
          %87 = llvm.getelementptr  %86[%75] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %88 = llvm.load %87 : !llvm.ptr -> f32
          %89 = llvm.fmul %85, %88 : f32
          %90 = llvm.fadd %79, %89 : f32
          %91 = llvm.extractvalue %31[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
          %92 = llvm.getelementptr  %91[%71] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %90, %92 : f32, !llvm.ptr
          %93 = llvm.add %75, %74 : i64
          llvm.br ^bb1(%93 : i64)
        ^bb3:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb2
  ^bb2:  // 2 preds: ^bb0, ^bb1
    %51 = llvm.mlir.constant(1 : i32) : i32
    %52 = llvm.srem %51, %44 : i32
    %53 = llvm.icmp "eq" %39, %52 : i32
    llvm.cond_br %53, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    %54 = llvm.mlir.constant(0 : index) : i64
    %55 = llvm.mlir.constant(64 : index) : i64
    %56 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg28) : i64 = (%54) to (%55) step (%56) {
          %71 = llvm.mlir.constant(0 : index) : i64
          %72 = llvm.mlir.constant(0 : index) : i64
          %73 = llvm.mlir.constant(128 : index) : i64
          %74 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%72 : i64)
        ^bb1(%75: i64):  // 2 preds: ^bb0, ^bb2
          %76 = llvm.icmp "slt" %75, %73 : i64
          llvm.cond_br %76, ^bb2, ^bb3
        ^bb2:  // pred: ^bb1
          %77 = llvm.extractvalue %31[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
          %78 = llvm.getelementptr  %77[%71] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %79 = llvm.load %78 : !llvm.ptr -> f32
          %80 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %81 = llvm.mlir.constant(128 : index) : i64
          %82 = llvm.mul %71, %81 overflow<nsw, nuw> : i64
          %83 = llvm.add %82, %75 overflow<nsw, nuw> : i64
          %84 = llvm.getelementptr  %80[%83] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %85 = llvm.load %84 : !llvm.ptr -> f32
          %86 = llvm.extractvalue %19[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
          %87 = llvm.getelementptr  %86[%75] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %88 = llvm.load %87 : !llvm.ptr -> f32
          %89 = llvm.fmul %85, %88 : f32
          %90 = llvm.fadd %79, %89 : f32
          %91 = llvm.extractvalue %31[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
          %92 = llvm.getelementptr  %91[%71] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %90, %92 : f32, !llvm.ptr
          %93 = llvm.add %75, %74 : i64
          llvm.br ^bb1(%93 : i64)
        ^bb3:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb4
  ^bb4:  // 2 preds: ^bb2, ^bb3
    %57 = llvm.mlir.constant(2 : i32) : i32
    %58 = llvm.srem %57, %44 : i32
    %59 = llvm.icmp "eq" %39, %58 : i32
    llvm.cond_br %59, ^bb5, ^bb6
  ^bb5:  // pred: ^bb4
    %60 = llvm.mlir.constant(64 : index) : i64
    %61 = llvm.mlir.constant(128 : index) : i64
    %62 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg28) : i64 = (%60) to (%61) step (%62) {
          %71 = llvm.mlir.constant(0 : index) : i64
          %72 = llvm.mlir.constant(0 : index) : i64
          %73 = llvm.mlir.constant(128 : index) : i64
          %74 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%72 : i64)
        ^bb1(%75: i64):  // 2 preds: ^bb0, ^bb2
          %76 = llvm.icmp "slt" %75, %73 : i64
          llvm.cond_br %76, ^bb2, ^bb3
        ^bb2:  // pred: ^bb1
          %77 = llvm.extractvalue %25[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
          %78 = llvm.getelementptr  %77[%71] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %79 = llvm.load %78 : !llvm.ptr -> f32
          %80 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %81 = llvm.mlir.constant(128 : index) : i64
          %82 = llvm.mul %75, %81 overflow<nsw, nuw> : i64
          %83 = llvm.add %82, %71 overflow<nsw, nuw> : i64
          %84 = llvm.getelementptr  %80[%83] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %85 = llvm.load %84 : !llvm.ptr -> f32
          %86 = llvm.extractvalue %13[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
          %87 = llvm.getelementptr  %86[%75] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %88 = llvm.load %87 : !llvm.ptr -> f32
          %89 = llvm.fmul %85, %88 : f32
          %90 = llvm.fadd %79, %89 : f32
          %91 = llvm.extractvalue %25[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
          %92 = llvm.getelementptr  %91[%71] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %90, %92 : f32, !llvm.ptr
          %93 = llvm.add %75, %74 : i64
          llvm.br ^bb1(%93 : i64)
        ^bb3:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb6
  ^bb6:  // 2 preds: ^bb4, ^bb5
    %63 = llvm.mlir.constant(3 : i32) : i32
    %64 = llvm.srem %63, %44 : i32
    %65 = llvm.icmp "eq" %39, %64 : i32
    llvm.cond_br %65, ^bb7, ^bb8
  ^bb7:  // pred: ^bb6
    %66 = llvm.mlir.constant(0 : index) : i64
    %67 = llvm.mlir.constant(64 : index) : i64
    %68 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg28) : i64 = (%66) to (%67) step (%68) {
          %71 = llvm.mlir.constant(0 : index) : i64
          %72 = llvm.mlir.constant(0 : index) : i64
          %73 = llvm.mlir.constant(128 : index) : i64
          %74 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%72 : i64)
        ^bb1(%75: i64):  // 2 preds: ^bb0, ^bb2
          %76 = llvm.icmp "slt" %75, %73 : i64
          llvm.cond_br %76, ^bb2, ^bb3
        ^bb2:  // pred: ^bb1
          %77 = llvm.extractvalue %25[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
          %78 = llvm.getelementptr  %77[%71] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %79 = llvm.load %78 : !llvm.ptr -> f32
          %80 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %81 = llvm.mlir.constant(128 : index) : i64
          %82 = llvm.mul %75, %81 overflow<nsw, nuw> : i64
          %83 = llvm.add %82, %71 overflow<nsw, nuw> : i64
          %84 = llvm.getelementptr  %80[%83] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %85 = llvm.load %84 : !llvm.ptr -> f32
          %86 = llvm.extractvalue %13[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
          %87 = llvm.getelementptr  %86[%75] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %88 = llvm.load %87 : !llvm.ptr -> f32
          %89 = llvm.fmul %85, %88 : f32
          %90 = llvm.fadd %79, %89 : f32
          %91 = llvm.extractvalue %25[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
          %92 = llvm.getelementptr  %91[%71] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %90, %92 : f32, !llvm.ptr
          %93 = llvm.add %75, %74 : i64
          llvm.br ^bb1(%93 : i64)
        ^bb3:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb8
  ^bb8:  // 2 preds: ^bb6, ^bb7
    %69 = llvm.trunc %34 : i64 to i32
    %70 = llvm.call @MPI_Barrier(%69) : (i32) -> i32
    llvm.return
  }
}
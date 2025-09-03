module attributes {avial.target_devices = [#dlti.target_device_spec<"type" = "node", "arch" = "x86">, #dlti.target_device_spec<"type" = "node", "arch" = "x86">]} {
  llvm.func @MPI_Barrier(i32) -> i32
  llvm.func @MPI_Comm_size(i32, !llvm.ptr) -> i32
  llvm.func @MPI_Comm_rank(i32, !llvm.ptr) -> i32
  llvm.func @MPI_Init(!llvm.ptr, !llvm.ptr) -> i32
  llvm.func @testFunc(%arg0: i32, %arg1: i32, %arg2: f32, %arg3: f32, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: i64, %arg10: i64, %arg11: !llvm.ptr, %arg12: !llvm.ptr, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: i64, %arg18: !llvm.ptr, %arg19: !llvm.ptr, %arg20: i64, %arg21: i64, %arg22: i64, %arg23: i64, %arg24: i64) {
    %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.insertvalue %arg18, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.insertvalue %arg19, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.insertvalue %arg20, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.insertvalue %arg21, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.insertvalue %arg23, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %arg22, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg24, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.insertvalue %arg11, %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg12, %9[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg13, %10[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg14, %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg16, %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %arg15, %13[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.insertvalue %arg17, %14[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %17 = llvm.insertvalue %arg4, %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.insertvalue %arg5, %17[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %arg6, %18[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %arg7, %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %arg9, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %arg8, %21[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %arg10, %22[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
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
    %37 = llvm.mlir.constant(0 : i32) : i32
    %38 = llvm.srem %37, %36 : i32
    %39 = llvm.icmp "eq" %31, %38 : i32
    llvm.cond_br %39, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %40 = llvm.mlir.constant(64 : index) : i64
    %41 = llvm.mlir.constant(128 : index) : i64
    %42 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg25) : i64 = (%40) to (%41) step (%42) {
          %63 = llvm.mlir.constant(0 : index) : i64
          %64 = llvm.mlir.constant(0 : index) : i64
          %65 = llvm.mlir.constant(128 : index) : i64
          %66 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%64 : i64)
        ^bb1(%67: i64):  // 2 preds: ^bb0, ^bb2
          %68 = llvm.icmp "slt" %67, %65 : i64
          llvm.cond_br %68, ^bb2, ^bb3
        ^bb2:  // pred: ^bb1
          %69 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %70 = llvm.mlir.constant(128 : index) : i64
          %71 = llvm.mul %63, %70 overflow<nsw, nuw> : i64
          %72 = llvm.add %71, %67 overflow<nsw, nuw> : i64
          %73 = llvm.getelementptr  %69[%72] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %74 = llvm.load %73 : !llvm.ptr -> f32
          %75 = llvm.fmul %74, %arg3 : f32
          %76 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %77 = llvm.mlir.constant(128 : index) : i64
          %78 = llvm.mul %63, %77 overflow<nsw, nuw> : i64
          %79 = llvm.add %78, %67 overflow<nsw, nuw> : i64
          %80 = llvm.getelementptr  %76[%79] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %75, %80 : f32, !llvm.ptr
          %81 = llvm.add %67, %66 : i64
          llvm.br ^bb1(%81 : i64)
        ^bb3:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb2
  ^bb2:  // 2 preds: ^bb0, ^bb1
    %43 = llvm.mlir.constant(1 : i32) : i32
    %44 = llvm.srem %43, %36 : i32
    %45 = llvm.icmp "eq" %31, %44 : i32
    llvm.cond_br %45, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    %46 = llvm.mlir.constant(0 : index) : i64
    %47 = llvm.mlir.constant(64 : index) : i64
    %48 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg25) : i64 = (%46) to (%47) step (%48) {
          %63 = llvm.mlir.constant(0 : index) : i64
          %64 = llvm.mlir.constant(0 : index) : i64
          %65 = llvm.mlir.constant(128 : index) : i64
          %66 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%64 : i64)
        ^bb1(%67: i64):  // 2 preds: ^bb0, ^bb2
          %68 = llvm.icmp "slt" %67, %65 : i64
          llvm.cond_br %68, ^bb2, ^bb3
        ^bb2:  // pred: ^bb1
          %69 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %70 = llvm.mlir.constant(128 : index) : i64
          %71 = llvm.mul %63, %70 overflow<nsw, nuw> : i64
          %72 = llvm.add %71, %67 overflow<nsw, nuw> : i64
          %73 = llvm.getelementptr  %69[%72] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %74 = llvm.load %73 : !llvm.ptr -> f32
          %75 = llvm.fmul %74, %arg3 : f32
          %76 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %77 = llvm.mlir.constant(128 : index) : i64
          %78 = llvm.mul %63, %77 overflow<nsw, nuw> : i64
          %79 = llvm.add %78, %67 overflow<nsw, nuw> : i64
          %80 = llvm.getelementptr  %76[%79] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %75, %80 : f32, !llvm.ptr
          %81 = llvm.add %67, %66 : i64
          llvm.br ^bb1(%81 : i64)
        ^bb3:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb4
  ^bb4:  // 2 preds: ^bb2, ^bb3
    %49 = llvm.mlir.constant(2 : i32) : i32
    %50 = llvm.srem %49, %36 : i32
    %51 = llvm.icmp "eq" %31, %50 : i32
    llvm.cond_br %51, ^bb5, ^bb6
  ^bb5:  // pred: ^bb4
    %52 = llvm.mlir.constant(64 : index) : i64
    %53 = llvm.mlir.constant(128 : index) : i64
    %54 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg25) : i64 = (%52) to (%53) step (%54) {
          %63 = llvm.mlir.constant(0 : index) : i64
          %64 = llvm.mlir.constant(0 : index) : i64
          %65 = llvm.mlir.constant(128 : index) : i64
          %66 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%64 : i64)
        ^bb1(%67: i64):  // 2 preds: ^bb0, ^bb5
          %68 = llvm.icmp "slt" %67, %65 : i64
          llvm.cond_br %68, ^bb2, ^bb6
        ^bb2:  // pred: ^bb1
          %69 = llvm.mlir.constant(0 : index) : i64
          %70 = llvm.mlir.constant(128 : index) : i64
          %71 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb3(%69 : i64)
        ^bb3(%72: i64):  // 2 preds: ^bb2, ^bb4
          %73 = llvm.icmp "slt" %72, %70 : i64
          llvm.cond_br %73, ^bb4, ^bb5
        ^bb4:  // pred: ^bb3
          %74 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %75 = llvm.mlir.constant(128 : index) : i64
          %76 = llvm.mul %63, %75 overflow<nsw, nuw> : i64
          %77 = llvm.add %76, %72 overflow<nsw, nuw> : i64
          %78 = llvm.getelementptr  %74[%77] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %79 = llvm.load %78 : !llvm.ptr -> f32
          %80 = llvm.fmul %arg2, %79 : f32
          %81 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %82 = llvm.mlir.constant(128 : index) : i64
          %83 = llvm.mul %67, %82 overflow<nsw, nuw> : i64
          %84 = llvm.add %83, %72 overflow<nsw, nuw> : i64
          %85 = llvm.getelementptr  %81[%84] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %86 = llvm.load %85 : !llvm.ptr -> f32
          %87 = llvm.fmul %80, %86 : f32
          %88 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %89 = llvm.mlir.constant(128 : index) : i64
          %90 = llvm.mul %63, %89 overflow<nsw, nuw> : i64
          %91 = llvm.add %90, %67 overflow<nsw, nuw> : i64
          %92 = llvm.getelementptr  %88[%91] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %93 = llvm.load %92 : !llvm.ptr -> f32
          %94 = llvm.fadd %93, %87 : f32
          %95 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %96 = llvm.mlir.constant(128 : index) : i64
          %97 = llvm.mul %63, %96 overflow<nsw, nuw> : i64
          %98 = llvm.add %97, %67 overflow<nsw, nuw> : i64
          %99 = llvm.getelementptr  %95[%98] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %94, %99 : f32, !llvm.ptr
          %100 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %101 = llvm.mlir.constant(128 : index) : i64
          %102 = llvm.mul %63, %101 overflow<nsw, nuw> : i64
          %103 = llvm.add %102, %72 overflow<nsw, nuw> : i64
          %104 = llvm.getelementptr  %100[%103] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %105 = llvm.load %104 : !llvm.ptr -> f32
          %106 = llvm.fmul %arg2, %105 : f32
          %107 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %108 = llvm.mlir.constant(128 : index) : i64
          %109 = llvm.mul %67, %108 overflow<nsw, nuw> : i64
          %110 = llvm.add %109, %72 overflow<nsw, nuw> : i64
          %111 = llvm.getelementptr  %107[%110] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %112 = llvm.load %111 : !llvm.ptr -> f32
          %113 = llvm.fmul %106, %112 : f32
          %114 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %115 = llvm.mlir.constant(128 : index) : i64
          %116 = llvm.mul %63, %115 overflow<nsw, nuw> : i64
          %117 = llvm.add %116, %67 overflow<nsw, nuw> : i64
          %118 = llvm.getelementptr  %114[%117] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %119 = llvm.load %118 : !llvm.ptr -> f32
          %120 = llvm.fadd %119, %113 : f32
          %121 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %122 = llvm.mlir.constant(128 : index) : i64
          %123 = llvm.mul %63, %122 overflow<nsw, nuw> : i64
          %124 = llvm.add %123, %67 overflow<nsw, nuw> : i64
          %125 = llvm.getelementptr  %121[%124] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %120, %125 : f32, !llvm.ptr
          %126 = llvm.add %72, %71 : i64
          llvm.br ^bb3(%126 : i64)
        ^bb5:  // pred: ^bb3
          %127 = llvm.add %67, %66 : i64
          llvm.br ^bb1(%127 : i64)
        ^bb6:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb6
  ^bb6:  // 2 preds: ^bb4, ^bb5
    %55 = llvm.mlir.constant(3 : i32) : i32
    %56 = llvm.srem %55, %36 : i32
    %57 = llvm.icmp "eq" %31, %56 : i32
    llvm.cond_br %57, ^bb7, ^bb8
  ^bb7:  // pred: ^bb6
    %58 = llvm.mlir.constant(0 : index) : i64
    %59 = llvm.mlir.constant(64 : index) : i64
    %60 = llvm.mlir.constant(1 : index) : i64
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg25) : i64 = (%58) to (%59) step (%60) {
          %63 = llvm.mlir.constant(0 : index) : i64
          %64 = llvm.mlir.constant(0 : index) : i64
          %65 = llvm.mlir.constant(128 : index) : i64
          %66 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb1(%64 : i64)
        ^bb1(%67: i64):  // 2 preds: ^bb0, ^bb5
          %68 = llvm.icmp "slt" %67, %65 : i64
          llvm.cond_br %68, ^bb2, ^bb6
        ^bb2:  // pred: ^bb1
          %69 = llvm.mlir.constant(0 : index) : i64
          %70 = llvm.mlir.constant(128 : index) : i64
          %71 = llvm.mlir.constant(1 : index) : i64
          llvm.br ^bb3(%69 : i64)
        ^bb3(%72: i64):  // 2 preds: ^bb2, ^bb4
          %73 = llvm.icmp "slt" %72, %70 : i64
          llvm.cond_br %73, ^bb4, ^bb5
        ^bb4:  // pred: ^bb3
          %74 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %75 = llvm.mlir.constant(128 : index) : i64
          %76 = llvm.mul %63, %75 overflow<nsw, nuw> : i64
          %77 = llvm.add %76, %72 overflow<nsw, nuw> : i64
          %78 = llvm.getelementptr  %74[%77] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %79 = llvm.load %78 : !llvm.ptr -> f32
          %80 = llvm.fmul %arg2, %79 : f32
          %81 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %82 = llvm.mlir.constant(128 : index) : i64
          %83 = llvm.mul %67, %82 overflow<nsw, nuw> : i64
          %84 = llvm.add %83, %72 overflow<nsw, nuw> : i64
          %85 = llvm.getelementptr  %81[%84] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %86 = llvm.load %85 : !llvm.ptr -> f32
          %87 = llvm.fmul %80, %86 : f32
          %88 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %89 = llvm.mlir.constant(128 : index) : i64
          %90 = llvm.mul %63, %89 overflow<nsw, nuw> : i64
          %91 = llvm.add %90, %67 overflow<nsw, nuw> : i64
          %92 = llvm.getelementptr  %88[%91] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %93 = llvm.load %92 : !llvm.ptr -> f32
          %94 = llvm.fadd %93, %87 : f32
          %95 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %96 = llvm.mlir.constant(128 : index) : i64
          %97 = llvm.mul %63, %96 overflow<nsw, nuw> : i64
          %98 = llvm.add %97, %67 overflow<nsw, nuw> : i64
          %99 = llvm.getelementptr  %95[%98] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %94, %99 : f32, !llvm.ptr
          %100 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %101 = llvm.mlir.constant(128 : index) : i64
          %102 = llvm.mul %63, %101 overflow<nsw, nuw> : i64
          %103 = llvm.add %102, %72 overflow<nsw, nuw> : i64
          %104 = llvm.getelementptr  %100[%103] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %105 = llvm.load %104 : !llvm.ptr -> f32
          %106 = llvm.fmul %arg2, %105 : f32
          %107 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %108 = llvm.mlir.constant(128 : index) : i64
          %109 = llvm.mul %67, %108 overflow<nsw, nuw> : i64
          %110 = llvm.add %109, %72 overflow<nsw, nuw> : i64
          %111 = llvm.getelementptr  %107[%110] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %112 = llvm.load %111 : !llvm.ptr -> f32
          %113 = llvm.fmul %106, %112 : f32
          %114 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %115 = llvm.mlir.constant(128 : index) : i64
          %116 = llvm.mul %63, %115 overflow<nsw, nuw> : i64
          %117 = llvm.add %116, %67 overflow<nsw, nuw> : i64
          %118 = llvm.getelementptr  %114[%117] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          %119 = llvm.load %118 : !llvm.ptr -> f32
          %120 = llvm.fadd %119, %113 : f32
          %121 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
          %122 = llvm.mlir.constant(128 : index) : i64
          %123 = llvm.mul %63, %122 overflow<nsw, nuw> : i64
          %124 = llvm.add %123, %67 overflow<nsw, nuw> : i64
          %125 = llvm.getelementptr  %121[%124] : (!llvm.ptr, i64) -> !llvm.ptr, f32
          llvm.store %120, %125 : f32, !llvm.ptr
          %126 = llvm.add %72, %71 : i64
          llvm.br ^bb3(%126 : i64)
        ^bb5:  // pred: ^bb3
          %127 = llvm.add %67, %66 : i64
          llvm.br ^bb1(%127 : i64)
        ^bb6:  // pred: ^bb1
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.br ^bb8
  ^bb8:  // 2 preds: ^bb6, ^bb7
    %61 = llvm.trunc %26 : i64 to i32
    %62 = llvm.call @MPI_Barrier(%61) : (i32) -> i32
    llvm.return
  }
}
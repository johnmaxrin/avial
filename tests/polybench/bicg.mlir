module {
  func.func @kernel_bicg(%arg0: i32, %arg1: i32, %arg2: memref<?x1000xf32>, %arg3: memref<?xf32>, %arg4: memref<?xf32>, %arg5: memref<?xf32>, %arg6: memref<?xf32>)  {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg7 = 0 to 1000 {
      affine.store %cst, %arg3[%arg7] : memref<?xf32>
    }
    affine.for %arg7 = 0 to 1000 {
      affine.store %cst, %arg4[%arg7] : memref<?xf32>
      affine.for %arg8 = 0 to 1000 {
        %0 = affine.load %arg3[%arg8] : memref<?xf32>
        %1 = affine.load %arg6[%arg7] : memref<?xf32>
        %2 = affine.load %arg2[%arg7, %arg8] : memref<?x1000xf32>
        %3 = arith.mulf %1, %2 : f32
        %4 = arith.addf %0, %3 : f32
        affine.store %4, %arg3[%arg8] : memref<?xf32>
        %5 = affine.load %arg4[%arg7] : memref<?xf32>
        %6 = affine.load %arg2[%arg7, %arg8] : memref<?x1000xf32>
        %7 = affine.load %arg5[%arg8] : memref<?xf32>
        %8 = arith.mulf %6, %7 : f32
        %9 = arith.addf %5, %8 : f32
        affine.store %9, %arg4[%arg7] : memref<?xf32>
      }
    }
    return
  }
}

module  {
  func.func @kernel_syr2k(%arg0: i32, %arg1: i32, %arg2: f32, %arg3: f32, %arg4: memref<?x1000xf32>, %arg5: memref<?x1000xf32>, %arg6: memref<?x1000xf32>)  {
    affine.for %arg7 = 0 to 1000 {
      affine.for %arg8 = 0 to 1000 {
        %0 = affine.load %arg4[%arg7, %arg8] : memref<?x1000xf32>
        %1 = arith.mulf %0, %arg3 : f32
        affine.store %1, %arg4[%arg7, %arg8] : memref<?x1000xf32>
      }
    }
    affine.for %arg7 = 0 to 1000 {
      affine.for %arg8 = 0 to 1000 {
        affine.for %arg9 = 0 to 1000 {
          %0 = affine.load %arg5[%arg7, %arg9] : memref<?x1000xf32>
          %1 = arith.mulf %arg2, %0 : f32
          %2 = affine.load %arg6[%arg8, %arg9] : memref<?x1000xf32>
          %3 = arith.mulf %1, %2 : f32
          %4 = affine.load %arg4[%arg7, %arg8] : memref<?x1000xf32>
          %5 = arith.addf %4, %3 : f32
          affine.store %5, %arg4[%arg7, %arg8] : memref<?x1000xf32>
          %6 = affine.load %arg6[%arg7, %arg9] : memref<?x1000xf32>
          %7 = arith.mulf %arg2, %6 : f32
          %8 = affine.load %arg5[%arg8, %arg9] : memref<?x1000xf32>
          %9 = arith.mulf %7, %8 : f32
          %10 = affine.load %arg4[%arg7, %arg8] : memref<?x1000xf32>
          %11 = arith.addf %10, %9 : f32
          affine.store %11, %arg4[%arg7, %arg8] : memref<?x1000xf32>
        }
      }
    }
    return
  }
}

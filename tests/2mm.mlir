module  {
  func.func @kernel_2mm(%arg0: i32, %arg1: i32, %arg2: i32, %arg3: i32, %arg4: f32, %arg5: f32, %arg6: memref<?x128xf32>, %arg7: memref<?x128xf32>, %arg8: memref<?x128xf32>, %arg9: memref<?x128xf32>, %arg10: memref<?x128xf32>)  {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg11 = 0 to 128 {
      affine.for %arg12 = 0 to 64 {
        affine.store %cst, %arg6[%arg11, %arg12] : memref<?x128xf32>
        affine.for %arg13 = 0 to 64 {
          %0 = affine.load %arg7[%arg11, %arg13] : memref<?x128xf32>
          %1 = arith.mulf %arg4, %0 : f32
          %2 = affine.load %arg8[%arg13, %arg12] : memref<?x128xf32>
          %3 = arith.mulf %1, %2 : f32
          %4 = affine.load %arg6[%arg11, %arg12] : memref<?x128xf32>
          %5 = arith.addf %4, %3 : f32
          affine.store %5, %arg6[%arg11, %arg12] : memref<?x128xf32>
        }
      }
    }
    affine.for %arg11 = 0 to 128 {
      affine.for %arg12 = 0 to 64 {
        %0 = affine.load %arg10[%arg11, %arg12] : memref<?x128xf32>
        %1 = arith.mulf %0, %arg5 : f32
        affine.store %1, %arg10[%arg11, %arg12] : memref<?x128xf32>
        affine.for %arg13 = 0 to 32 {
          %2 = affine.load %arg6[%arg11, %arg13] : memref<?x128xf32>
          %3 = affine.load %arg9[%arg13, %arg12] : memref<?x128xf32>
          %4 = arith.mulf %2, %3 : f32
          %5 = affine.load %arg10[%arg11, %arg12] : memref<?x128xf32>
          %6 = arith.addf %5, %4 : f32
          affine.store %6, %arg10[%arg11, %arg12] : memref<?x128xf32>
        }
      }
    }
    return
  }
}

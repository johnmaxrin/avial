module  {
  func.func @kernel_3mm(%arg0: i32, %arg1: i32, %arg2: i32, %arg3: i32, %arg4: i32, %arg5: memref<?x128xf32>, %arg6: memref<?x128xf32>, %arg7: memref<?x128xf32>, %arg8: memref<?x128xf32>, %arg9: memref<?x128xf32>, %arg10: memref<?x128xf32>, %arg11: memref<?x128xf32>)  {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg12 = 0 to 128 {
      affine.for %arg13 = 0 to 128 {
        affine.store %cst, %arg5[%arg12, %arg13] : memref<?x128xf32>
        affine.for %arg14 = 0 to 128 {
          %0 = affine.load %arg6[%arg12, %arg14] : memref<?x128xf32>
          %1 = affine.load %arg7[%arg14, %arg13] : memref<?x128xf32>
          %2 = arith.mulf %0, %1 : f32
          %3 = affine.load %arg5[%arg12, %arg13] : memref<?x128xf32>
          %4 = arith.addf %3, %2 : f32
          affine.store %4, %arg5[%arg12, %arg13] : memref<?x128xf32>
        }
      }
    }
    affine.for %arg12 = 0 to 128 {
      affine.for %arg13 = 0 to 128 {
        affine.store %cst, %arg8[%arg12, %arg13] : memref<?x128xf32>
        affine.for %arg14 = 0 to 128 {
          %0 = affine.load %arg9[%arg12, %arg14] : memref<?x128xf32>
          %1 = affine.load %arg10[%arg14, %arg13] : memref<?x128xf32>
          %2 = arith.mulf %0, %1 : f32
          %3 = affine.load %arg8[%arg12, %arg13] : memref<?x128xf32>
          %4 = arith.addf %3, %2 : f32
          affine.store %4, %arg8[%arg12, %arg13] : memref<?x128xf32>
        }
      }
    }
    affine.for %arg12 = 0 to 128 {
      affine.for %arg13 = 0 to 128 {
        affine.store %cst, %arg11[%arg12, %arg13] : memref<?x128xf32>
        affine.for %arg14 = 0 to 128 {
          %0 = affine.load %arg5[%arg12, %arg14] : memref<?x128xf32>
          %1 = affine.load %arg8[%arg14, %arg13] : memref<?x128xf32>
          %2 = arith.mulf %0, %1 : f32
          %3 = affine.load %arg11[%arg12, %arg13] : memref<?x128xf32>
          %4 = arith.addf %3, %2 : f32
          affine.store %4, %arg11[%arg12, %arg13] : memref<?x128xf32>
        }
      }
    }
    return
  }
}

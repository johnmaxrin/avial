module {
  func.func @kernel_jacobi_2d(
      %arg0: i32,
      %arg1: i32,
      %arg2: memref<?x128xf32>,
      %arg3: memref<?x128xf32>
  ) {
    %cst = arith.constant 2.000000e-01 : f64
    affine.for %arg4 = 0 to 300 {
      affine.for %arg5 = 1 to 19 {
        affine.for %arg6 = 1 to 19 {
          %0 = affine.load %arg2[%arg5, %arg6] : memref<?x128xf32>
          %1 = affine.load %arg2[%arg5, %arg6 - 1] : memref<?x128xf32>
          %2 = arith.addf %0, %1 : f32
          %3 = affine.load %arg2[%arg5, %arg6 + 1] : memref<?x128xf32>
          %4 = arith.addf %2, %3 : f32
          %5 = affine.load %arg2[%arg5 + 1, %arg6] : memref<?x128xf32>
          %6 = arith.addf %4, %5 : f32
          %7 = affine.load %arg2[%arg5 - 1, %arg6] : memref<?x128xf32>
          %8 = arith.addf %6, %7 : f32
          %9 = arith.extf %8 : f32 to f64
          %10 = arith.mulf %9, %cst : f64
          %11 = arith.truncf %10 : f64 to f32
          affine.store %11, %arg3[%arg5, %arg6] : memref<?x128xf32>
        }
      }
      affine.for %arg5 = 1 to 19 {
        affine.for %arg6 = 1 to 19 {
          %0 = affine.load %arg3[%arg5, %arg6] : memref<?x128xf32>
          affine.store %0, %arg2[%arg5, %arg6] : memref<?x128xf32>
        }
      }
    }
    return
  }
}

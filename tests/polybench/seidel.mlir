module {
  func.func @kernel_seidel_2d(
      %arg0: i32,
      %arg1: i32,
      %arg2: memref<?x128xf32>
  ) {
    %cst = arith.constant 9.000000e+00 : f64
    affine.for %arg3 = 0 to 20 {
      affine.for %arg4 = 1 to 127 {
        affine.for %arg5 = 1 to 127 {
          %0 = affine.load %arg2[%arg4 - 1, %arg5 - 1] : memref<?x128xf32>
          %1 = affine.load %arg2[%arg4 - 1, %arg5] : memref<?x128xf32>
          %2 = arith.addf %0, %1 : f32
          %3 = affine.load %arg2[%arg4 - 1, %arg5 + 1] : memref<?x128xf32>
          %4 = arith.addf %2, %3 : f32
          %5 = affine.load %arg2[%arg4, %arg5 - 1] : memref<?x128xf32>
          %6 = arith.addf %4, %5 : f32
          %7 = affine.load %arg2[%arg4, %arg5] : memref<?x128xf32>
          %8 = arith.addf %6, %7 : f32
          %9 = affine.load %arg2[%arg4, %arg5 + 1] : memref<?x128xf32>
          %10 = arith.addf %8, %9 : f32
          %11 = affine.load %arg2[%arg4 + 1, %arg5 - 1] : memref<?x128xf32>
          %12 = arith.addf %10, %11 : f32
          %13 = affine.load %arg2[%arg4 + 1, %arg5] : memref<?x128xf32>
          %14 = arith.addf %12, %13 : f32
          %15 = affine.load %arg2[%arg4 + 1, %arg5 + 1] : memref<?x128xf32>
          %16 = arith.addf %14, %15 : f32
          %17 = arith.extf %16 : f32 to f64
          %18 = arith.divf %17, %cst : f64
          %19 = arith.truncf %18 : f64 to f32
          affine.store %19, %arg2[%arg4, %arg5] : memref<?x128xf32>
        }
      }
    }
    return
  }
}

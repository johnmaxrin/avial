module {
  func.func @kernel_jacobi(
      %arg0: i32,
      %arg1: i32,
      %arg2: memref<?xf32>,
      %arg3: memref<?xf32>
  ) {
    %cst = arith.constant 3.333300e-01 : f64
    affine.for %arg4 = 0 to 10000 {
      affine.for %arg5 = 1 to 999 {
        %0 = affine.load %arg2[%arg5 - 1] : memref<?xf32>
        %1 = affine.load %arg2[%arg5] : memref<?xf32>
        %2 = arith.addf %0, %1 : f32
        %3 = affine.load %arg2[%arg5 + 1] : memref<?xf32>
        %4 = arith.addf %2, %3 : f32
        %5 = arith.extf %4 : f32 to f64
        %6 = arith.mulf %5, %cst : f64
        %7 = arith.truncf %6 : f64 to f32
        affine.store %7, %arg3[%arg5] : memref<?xf32>
      }
      affine.for %arg5 = 1 to 999 {
        %0 = affine.load %arg3[%arg5] : memref<?xf32>
        affine.store %0, %arg2[%arg5] : memref<?xf32>
      }
    }
    return
  }
}

#map = affine_map<(d0) -> (d0 - 1)>
module  {
  func.func @kernel_symm(%arg0: i32, %arg1: i32, %arg2: f32, %arg3: f32, %arg4: memref<?x1000xf32>, %arg5: memref<?x1000xf32>, %arg6: memref<?x1000xf32>)  {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg7 = 0 to 1000 {
      affine.for %arg8 = 0 to 1000 {
        %0 = affine.for %arg9 = 0 to #map(%arg8) iter_args(%arg10 = %cst) -> (f32) {
          %10 = affine.load %arg5[%arg9, %arg7] : memref<?x1000xf32>
          %11 = arith.mulf %arg2, %10 : f32
          %12 = affine.load %arg6[%arg7, %arg8] : memref<?x1000xf32>
          %13 = arith.mulf %11, %12 : f32
          %14 = affine.load %arg4[%arg9, %arg8] : memref<?x1000xf32>
          %15 = arith.addf %14, %13 : f32
          affine.store %15, %arg4[%arg9, %arg8] : memref<?x1000xf32>
          %16 = affine.load %arg6[%arg9, %arg8] : memref<?x1000xf32>
          %17 = affine.load %arg5[%arg9, %arg7] : memref<?x1000xf32>
          %18 = arith.mulf %16, %17 : f32
          %19 = arith.addf %arg10, %18 : f32
          affine.yield %19 : f32
        }
        %1 = affine.load %arg4[%arg7, %arg8] : memref<?x1000xf32>
        %2 = arith.mulf %arg3, %1 : f32
        %3 = affine.load %arg5[%arg7, %arg7] : memref<?x1000xf32>
        %4 = arith.mulf %arg2, %3 : f32
        %5 = affine.load %arg6[%arg7, %arg8] : memref<?x1000xf32>
        %6 = arith.mulf %4, %5 : f32
        %7 = arith.addf %2, %6 : f32
        %8 = arith.mulf %arg2, %0 : f32
        %9 = arith.addf %7, %8 : f32
        affine.store %9, %arg4[%arg7, %arg8] : memref<?x1000xf32>
      }
    }
    return
  }
}

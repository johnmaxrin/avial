module {
  func.func @kernel_gesummv(%arg0: i32, %arg1: f32, %arg2: f32, %arg3: memref<?x512xf32>, %arg4: memref<?x512xf32>, %arg5: memref<?xf32>, %arg6: memref<?xf32>, %arg7: memref<?xf32>) {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg8 = 0 to 512 {
      affine.store %cst, %arg5[%arg8] : memref<?xf32>
      affine.store %cst, %arg7[%arg8] : memref<?xf32>
      affine.for %arg9 = 0 to 512 {
        %5 = affine.load %arg3[%arg8, %arg9] : memref<?x512xf32>
        %6 = affine.load %arg6[%arg9] : memref<?xf32>
        %7 = arith.mulf %5, %6 : f32
        %8 = affine.load %arg5[%arg8] : memref<?xf32>
        %9 = arith.addf %7, %8 : f32
        affine.store %9, %arg5[%arg8] : memref<?xf32>
        %10 = affine.load %arg4[%arg8, %arg9] : memref<?x512xf32>
        %11 = affine.load %arg6[%arg9] : memref<?xf32>
        %12 = arith.mulf %10, %11 : f32
        %13 = affine.load %arg7[%arg8] : memref<?xf32>
        %14 = arith.addf %12, %13 : f32
        affine.store %14, %arg7[%arg8] : memref<?xf32>
      }
      %0 = affine.load %arg5[%arg8] : memref<?xf32>
      %1 = arith.mulf %arg1, %0 : f32
      %2 = affine.load %arg7[%arg8] : memref<?xf32>
      %3 = arith.mulf %arg2, %2 : f32
      %4 = arith.addf %1, %3 : f32
      affine.store %4, %arg7[%arg8] : memref<?xf32>
    }
    return
  }
}

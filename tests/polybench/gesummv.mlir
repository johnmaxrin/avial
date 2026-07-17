module {
  func.func @kernel_gesummv(
      %arg0: i32,
      %arg1: f32,
      %arg2: f32,
      %arg3: memref<?x200xf32>,
      %arg4: memref<?x200xf32>,
      %arg5: memref<?xf32>,
      %arg6: memref<?xf32>,
      %arg7: memref<?xf32>
  ) {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg8 = 0 to 200 {
      affine.store %cst, %arg5[%arg8] : memref<?xf32>
      affine.store %cst, %arg7[%arg8] : memref<?xf32>
      affine.for %arg9 = 0 to 200 {
        %0 = affine.load %arg3[%arg8, %arg9] : memref<?x200xf32>
        %1 = affine.load %arg6[%arg9] : memref<?xf32>
        %2 = arith.mulf %0, %1 : f32
        %3 = affine.load %arg5[%arg8] : memref<?xf32>
        %4 = arith.addf %2, %3 : f32
        affine.store %4, %arg5[%arg8] : memref<?xf32>
        %5 = affine.load %arg4[%arg8, %arg9] : memref<?x200xf32>
        %6 = affine.load %arg6[%arg9] : memref<?xf32>
        %7 = arith.mulf %5, %6 : f32
        %8 = affine.load %arg7[%arg8] : memref<?xf32>
        %9 = arith.addf %7, %8 : f32
        affine.store %9, %arg7[%arg8] : memref<?xf32>
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

module {
  func.func @kernel_gemver(
      %arg0: i32,
      %arg1: f32,
      %arg2: f32,
      %arg3: memref<200x200xf32>,
      %arg4: memref<200xf32>,
      %arg5: memref<200xf32>,
      %arg6: memref<200xf32>,
      %arg7: memref<200xf32>,
      %arg8: memref<200xf32>,
      %arg9: memref<200xf32>,
      %arg10: memref<200xf32>,
      %arg11: memref<200xf32>
  ) {
    affine.for %arg12 = 0 to 200 {
      affine.for %arg13 = 0 to 200 {
        %0 = affine.load %arg3[%arg12, %arg13] : memref<200x200xf32>
        %1 = affine.load %arg4[%arg12] : memref<200xf32>
        %2 = affine.load %arg5[%arg13] : memref<200xf32>
        %3 = arith.mulf %1, %2 : f32
        %4 = arith.addf %0, %3 : f32
        %5 = affine.load %arg6[%arg12] : memref<200xf32>
        %6 = affine.load %arg7[%arg13] : memref<200xf32>
        %7 = arith.mulf %5, %6 : f32
        %8 = arith.addf %4, %7 : f32
        affine.store %8, %arg3[%arg12, %arg13] : memref<200x200xf32>
      }
    }
    affine.for %arg12 = 0 to 200 {
      affine.for %arg13 = 0 to 200 {
        %0 = affine.load %arg9[%arg12] : memref<200xf32>
        %1 = affine.load %arg3[%arg13, %arg12] : memref<200x200xf32>
        %2 = arith.mulf %arg2, %1 : f32
        %3 = affine.load %arg10[%arg13] : memref<200xf32>
        %4 = arith.mulf %2, %3 : f32
        %5 = arith.addf %0, %4 : f32
        affine.store %5, %arg9[%arg12] : memref<200xf32>
      }
    }
    affine.for %arg12 = 0 to 200 {
      %0 = affine.load %arg9[%arg12] : memref<200xf32>
      %1 = affine.load %arg11[%arg12] : memref<200xf32>
      %2 = arith.addf %0, %1 : f32
      affine.store %2, %arg9[%arg12] : memref<200xf32>
    }
    affine.for %arg12 = 0 to 200 {
      affine.for %arg13 = 0 to 200 {
        %0 = affine.load %arg8[%arg12] : memref<200xf32>
        %1 = affine.load %arg3[%arg12, %arg13] : memref<200x200xf32>
        %2 = arith.mulf %arg1, %1 : f32
        %3 = affine.load %arg9[%arg13] : memref<200xf32>
        %4 = arith.mulf %2, %3 : f32
        %5 = arith.addf %0, %4 : f32
        affine.store %5, %arg8[%arg12] : memref<200xf32>
      }
    }
    return
  }
}

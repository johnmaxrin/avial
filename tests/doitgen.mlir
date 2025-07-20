module  {
  func.func @kernel_doitgen(%arg0: i32, %arg1: i32, %arg2: i32, %arg3: memref<?x128x128xf32>, %arg4: memref<?x128xf32>, %arg5: memref<?x128x128xf32>)  {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg6 = 0 to 128 {
      affine.for %arg7 = 0 to 64 {
        affine.for %arg8 = 0 to 32 {
          affine.store %cst, %arg5[%arg6, %arg7, %arg8] : memref<?x128x128xf32>
          affine.for %arg9 = 0 to 32 {
            %0 = affine.load %arg5[%arg6, %arg7, %arg8] : memref<?x128x128xf32>
            %1 = affine.load %arg3[%arg6, %arg7, %arg9] : memref<?x128x128xf32>
            %2 = affine.load %arg4[%arg9, %arg8] : memref<?x128xf32>
            %3 = arith.mulf %1, %2 : f32
            %4 = arith.addf %0, %3 : f32
            affine.store %4, %arg5[%arg6, %arg7, %arg8] : memref<?x128x128xf32>
          }
        }
        affine.for %arg8 = 0 to 128 {
          %0 = affine.load %arg5[%arg6, %arg7, %arg8] : memref<?x128x128xf32>
          affine.store %0, %arg3[%arg6, %arg7, %arg8] : memref<?x128x128xf32>
        }
      }
    }
    return
  }
}
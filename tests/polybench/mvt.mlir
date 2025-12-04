module  {
  func.func @kernel_mvt(%arg0: i32, %arg1: memref<?xf32>, %arg2: memref<?xf32>, %arg3: memref<?xf32>, %arg4: memref<?xf32>, %arg5: memref<?x128xf32>)  {
    affine.for %arg6 = 0 to 128 {
      affine.for %arg7 = 0 to 128 {
        %0 = affine.load %arg1[%arg6] : memref<?xf32>
        %1 = affine.load %arg5[%arg6, %arg7] : memref<?x128xf32>
        %2 = affine.load %arg3[%arg7] : memref<?xf32>
        %3 = arith.mulf %1, %2 : f32
        %4 = arith.addf %0, %3 : f32
        affine.store %4, %arg1[%arg6] : memref<?xf32>
      }
    }
    affine.for %arg6 = 0 to 128 {
      affine.for %arg7 = 0 to 128 {
        %0 = affine.load %arg2[%arg6] : memref<?xf32>
        %1 = affine.load %arg5[%arg7, %arg6] : memref<?x128xf32>
        %2 = affine.load %arg4[%arg7] : memref<?xf32>
        %3 = arith.mulf %1, %2 : f32
        %4 = arith.addf %0, %3 : f32
        affine.store %4, %arg2[%arg6] : memref<?xf32>
      }
    }
    return
  }
}
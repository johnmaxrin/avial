module  {
  func.func @kernel_atax(%arg0: i32, %arg1: i32, %arg2: memref<?x512xf32>, %arg3: memref<?xf32>, %arg4: memref<?xf32>, %arg5: memref<?xf32>)  {
    
    affine.for %arg6 = 0 to 512 {
      affine.for %arg7 = 0 to 512 {
        %0 = affine.load %arg5[%arg6] : memref<?xf32>
        %1 = affine.load %arg2[%arg6, %arg7] : memref<?x512xf32>
        %2 = affine.load %arg3[%arg7] : memref<?xf32>
        %3 = arith.mulf %1, %2 : f32
        %4 = arith.addf %0, %3 : f32
        affine.store %4, %arg5[%arg6] : memref<?xf32>
      }
      affine.for %arg7 = 0 to 512 {
        %0 = affine.load %arg4[%arg7] : memref<?xf32>
        %1 = affine.load %arg2[%arg6, %arg7] : memref<?x512xf32>
        %2 = affine.load %arg5[%arg6] : memref<?xf32>
        %3 = arith.mulf %1, %2 : f32
        %4 = arith.addf %0, %3 : f32
        affine.store %4, %arg4[%arg7] : memref<?xf32>
      }
    }
    return
  }
}

module  {
  func.func @matadd(%arg0: i32, %arg1: i32, %arg2: memref<?x1000xf32>, %arg3: memref<?x1000xf32>, %arg4: memref<?x1000xf32>) {
    %0 = arith.index_cast %arg0 : i32 to index
    %1 = arith.index_cast %arg1 : i32 to index
    
    affine.for %arg5 = 0 to 1000 {
      affine.for %arg6 = 0 to 1000 {
        %2 = affine.load %arg2[%arg5, %arg6] : memref<?x1000xf32>
        %3 = affine.load %arg3[%arg5, %arg6] : memref<?x1000xf32>
        %4 = arith.addf %2, %3 : f32
        affine.store %4, %arg4[%arg5, %arg6] : memref<?x1000xf32>
      }
    }
    return
  }
}
#map = affine_map<(d0) -> (d0)>
module  {
  func.func @kernel_trmm(%arg0: i32, %arg1: f32, %arg2: memref<?x1000xf32>, %arg3: memref<?x1000xf32>)  {
    affine.for %arg4 = 1 to 1000 {
      affine.for %arg5 = 0 to 1000 {
        affine.for %arg6 = 0 to #map(%arg4) {
          %0 = affine.load %arg2[%arg4, %arg6] : memref<?x1000xf32>
          %1 = arith.mulf %arg1, %0 : f32
          %2 = affine.load %arg3[%arg5, %arg6] : memref<?x1000xf32>
          %3 = arith.mulf %1, %2 : f32
          %4 = affine.load %arg3[%arg4, %arg5] : memref<?x1000xf32>
          %5 = arith.addf %4, %3 : f32
          affine.store %5, %arg3[%arg4, %arg5] : memref<?x1000xf32>
        }
      }
    }
    return
  }
}

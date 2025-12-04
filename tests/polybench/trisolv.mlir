#map = affine_map<(d0) -> (d0)>
module  {
  func.func @kernel_trisolv(%arg0: i32, %arg1: memref<?x128xf32>, %arg2: memref<?xf32>, %arg3: memref<?xf32>)  {
    affine.for %arg4 = 0 to 128 {
      %0 = affine.load %arg3[%arg4] : memref<?xf32>
      affine.store %0, %arg2[%arg4] : memref<?xf32>
      affine.for %arg5 = 0 to #map(%arg4) {
        %4 = affine.load %arg2[%arg4] : memref<?xf32>
        %5 = affine.load %arg1[%arg4, %arg5] : memref<?x128xf32>
        %6 = affine.load %arg2[%arg5] : memref<?xf32>
        %7 = arith.mulf %5, %6 : f32
        %8 = arith.subf %4, %7 : f32
        affine.store %8, %arg2[%arg4] : memref<?xf32>
      }
      %1 = affine.load %arg2[%arg4] : memref<?xf32>
      %2 = affine.load %arg1[%arg4, %arg4] : memref<?x128xf32>
      %3 = arith.divf %1, %2 : f32
      affine.store %3, %arg2[%arg4] : memref<?xf32>
    }
    return
  }
}

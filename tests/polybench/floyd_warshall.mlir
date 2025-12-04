module  {
  func.func @kernel_floyd_warshall(%arg0: i32, %arg1: memref<?x128xf32>)  {
    affine.for %arg2 = 0 to 128 {
      affine.for %arg3 = 0 to 128 {
        affine.for %arg4 = 0 to 128 {
          %0 = affine.load %arg1[%arg3, %arg4] : memref<?x128xf32>
          %1 = affine.load %arg1[%arg3, %arg2] : memref<?x128xf32>
          %2 = affine.load %arg1[%arg2, %arg4] : memref<?x128xf32>
          %3 = arith.addf %1, %2 : f32
          %4 = arith.cmpf olt, %0, %3 : f32
          %5 = scf.if %4 -> (f32) {
            %6 = affine.load %arg1[%arg3, %arg4] : memref<?x128xf32>
            scf.yield %6 : f32
          } else {
            %6 = affine.load %arg1[%arg3, %arg2] : memref<?x128xf32>
            %7 = affine.load %arg1[%arg2, %arg4] : memref<?x128xf32>
            %8 = arith.addf %6, %7 : f32
            scf.yield %8 : f32
          }
          affine.store %5, %arg1[%arg3, %arg4] : memref<?x128xf32>
        }
      }
    }
    return
  }
}

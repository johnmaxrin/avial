module {
  // Controlled memory-roof witness with a small distributed result. Each row
  // streams six full inputs but contributes only one gathered output element.
  // AI = 6*M*N / (4*(6*M*N+M)) = 0.25 flop/byte at this problem size.
  func.func @stream6(
      %arg0: i32, %arg1: i32,
      %arg2: memref<?x4096xf32>, %arg3: memref<?x4096xf32>,
      %arg4: memref<?x4096xf32>, %arg5: memref<?x4096xf32>,
      %arg6: memref<?x4096xf32>, %arg7: memref<?x4096xf32>,
      %arg8: memref<?xf32>) {
    %0 = arith.index_cast %arg0 : i32 to index
    %1 = arith.index_cast %arg1 : i32 to index

    affine.for %arg9 = 0 to 4096 {
      affine.for %arg10 = 0 to 4096 {
        %2 = affine.load %arg2[%arg9, %arg10] : memref<?x4096xf32>
        %3 = affine.load %arg3[%arg9, %arg10] : memref<?x4096xf32>
        %4 = affine.load %arg4[%arg9, %arg10] : memref<?x4096xf32>
        %5 = affine.load %arg5[%arg9, %arg10] : memref<?x4096xf32>
        %6 = affine.load %arg6[%arg9, %arg10] : memref<?x4096xf32>
        %7 = affine.load %arg7[%arg9, %arg10] : memref<?x4096xf32>
        %8 = arith.addf %2, %3 : f32
        %9 = arith.addf %8, %4 : f32
        %10 = arith.addf %9, %5 : f32
        %11 = arith.addf %10, %6 : f32
        %12 = arith.addf %11, %7 : f32
        %13 = affine.load %arg8[%arg9] : memref<?xf32>
        %14 = arith.addf %13, %12 : f32
        affine.store %14, %arg8[%arg9] : memref<?xf32>
      }
    }
    return
  }
}

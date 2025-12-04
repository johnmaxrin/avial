func.func @matmul(%A: memref<?x?xf32>, %B: memref<?x?xf32>, %C: memref<?x?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index

  %M = memref.dim %A, %c0 : memref<?x?xf32>
  %N = memref.dim %B, %c1 : memref<?x?xf32>
  %K = memref.dim %A, %c1 : memref<?x?xf32>

  // Sequential implementation
  affine.for %i = 0 to 5  step 1 {
    affine.for %j = 0 to %i {
      affine.for %k = 0 to 7 {
        %a = affine.load %A[%i, %k] : memref<?x?xf32>
        %b = affine.load %B[%k, %j] : memref<?x?xf32>
        %c = affine.load %C[%i, %j] : memref<?x?xf32>
        %prod = arith.mulf %a, %b : f32
        %sum = arith.addf %c, %prod : f32
        affine.store %sum, %C[%i, %j] : memref<?x?xf32>
      }
    }
  }
  return
}
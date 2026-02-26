module {
  func.func @kernel_jacobi(%arg0: i32, %arg1: i32, %arg2: memref<?xf32>, %arg3: memref<?xf32>) {
    %c-1_i32 = arith.constant -1 : i32
    %cst = arith.constant 3.333300e-01 : f64
    %c1_i32 = arith.constant 1 : i32
    affine.for %arg4 = 0 to 500 {
      affine.for %arg5 = 1 to 999 {
        %0 = arith.index_cast %arg5 : index to i32
        %1 = arith.addi %0, %c-1_i32 : i32
        %2 = arith.index_cast %1 : i32 to index
        %3 = affine.load %arg2[%arg5 - 1] : memref<?xf32>
        %4 = affine.load %arg2[%arg5] : memref<?xf32>
        %5 = arith.addf %3, %4 : f32
        %6 = arith.addi %0, %c1_i32 : i32
        %7 = arith.index_cast %6 : i32 to index
        %8 = affine.load %arg2[%arg5 + 1] : memref<?xf32>
        %9 = arith.addf %5, %8 : f32
        %10 = arith.extf %9 : f32 to f64
        %11 = arith.mulf %10, %cst : f64
        %12 = arith.truncf %11 : f64 to f32
        affine.store %12, %arg3[%arg5] : memref<?xf32>
      }
      affine.for %arg5 = 1 to 1000 {
        %0 = affine.load %arg3[%arg5] : memref<?xf32>
        affine.store %0, %arg2[%arg5] : memref<?xf32>
      }
    }
    return
  }
}

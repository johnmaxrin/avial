module {
  func.func @kernel_jacobi_2d(%arg0: i32, %arg1: i32, %arg2: memref<?x128xf32>, %arg3: memref<?x128xf32>)  {
    %c-1_i32 = arith.constant -1 : i32
    %cst = arith.constant 2.000000e-01 : f64
    %c1_i32 = arith.constant 1 : i32
    affine.for %arg4 = 0 to 300 {
      affine.for %arg5 = 1 to 19 {
        %0 = arith.index_cast %arg5 : index to i32
        %1 = arith.addi %0, %c1_i32 : i32
        %2 = arith.index_cast %1 : i32 to index
        %3 = arith.addi %0, %c-1_i32 : i32
        %4 = arith.index_cast %3 : i32 to index
        affine.for %arg6 = 1 to 19 {
          %5 = arith.index_cast %arg6 : index to i32
          %6 = affine.load %arg2[%arg5, %arg6] : memref<?x128xf32>
          %7 = arith.addi %5, %c-1_i32 : i32
          %8 = arith.index_cast %7 : i32 to index
          %9 = affine.load %arg2[%arg5, %arg6 - 1] : memref<?x128xf32>
          %10 = arith.addf %6, %9 : f32
          %11 = arith.addi %5, %c1_i32 : i32
          %12 = arith.index_cast %11 : i32 to index
          %13 = affine.load %arg2[%arg5, %arg6 + 1] : memref<?x128xf32>
          %14 = arith.addf %10, %13 : f32
          %15 = affine.load %arg2[%arg5 + 1, %arg6] : memref<?x128xf32>
          %16 = arith.addf %14, %15 : f32
          %17 = affine.load %arg2[%arg5 - 1, %arg6] : memref<?x128xf32>
          %18 = arith.addf %16, %17 : f32
          %19 = arith.extf %18 : f32 to f64
          %20 = arith.mulf %19, %cst : f64
          %21 = arith.truncf %20 : f64 to f32
          affine.store %21, %arg3[%arg5, %arg6] : memref<?x128xf32>
        }
      }
      affine.for %arg5 = 1 to 19 {
        affine.for %arg6 = 1 to 19 {
          %0 = affine.load %arg3[%arg5, %arg6] : memref<?x128xf32>
          affine.store %0, %arg2[%arg5, %arg6] : memref<?x128xf32>
        }
      }
    }
    return
  }
}

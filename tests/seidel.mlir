module  {
  func.func @kernel_seidel_2d(%arg0: i32, %arg1: i32, %arg2: memref<?x128xf32>)  {
    %c-1_i32 = arith.constant -1 : i32
    %cst = arith.constant 9.000000e+00 : f64
    %c1_i32 = arith.constant 1 : i32
    affine.for %arg3 = 0 to 20 {
      affine.for %arg4 = 1 to 127 {
        %0 = arith.index_cast %arg4 : index to i32
        %1 = arith.addi %0, %c-1_i32 : i32
        %2 = arith.index_cast %1 : i32 to index
        %3 = arith.addi %0, %c1_i32 : i32
        %4 = arith.index_cast %3 : i32 to index
        affine.for %arg5 = 1 to 127 {
          %5 = arith.index_cast %arg5 : index to i32
          %6 = arith.addi %5, %c-1_i32 : i32
          %7 = arith.index_cast %6 : i32 to index
          %8 = affine.load %arg2[%arg4 - 1, %arg5 - 1] : memref<?x128xf32>
          %9 = affine.load %arg2[%arg4 -1, %arg5] : memref<?x128xf32>
          %10 = arith.addf %8, %9 : f32
          %11 = arith.addi %5, %c1_i32 : i32
          %12 = arith.index_cast %11 : i32 to index
          %13 = affine.load %arg2[%arg4 - 1, %arg5 + 1] : memref<?x128xf32>
          %14 = arith.addf %10, %13 : f32
          %15 = affine.load %arg2[%arg4, %arg5 -1] : memref<?x128xf32>
          %16 = arith.addf %14, %15 : f32
          %17 = affine.load %arg2[%arg4, %arg5] : memref<?x128xf32>
          %18 = arith.addf %16, %17 : f32
          %19 = affine.load %arg2[%arg4, %arg5 + 1] : memref<?x128xf32>
          %20 = arith.addf %18, %19 : f32
          %21 = affine.load %arg2[%arg4 + 1, %arg5 - 1] : memref<?x128xf32>
          %22 = arith.addf %20, %21 : f32
          %23 = affine.load %arg2[%arg4 + 1, %arg5] : memref<?x128xf32>
          %24 = arith.addf %22, %23 : f32
          %25 = affine.load %arg2[%arg4 + 1, %arg5 + 1] : memref<?x128xf32>
          %26 = arith.addf %24, %25 : f32
          %27 = arith.extf %26 : f32 to f64
          %28 = arith.divf %27, %cst : f64
          %29 = arith.truncf %28 : f64 to f32
          affine.store %29, %arg2[%arg4, %arg5] : memref<?x128xf32>
        }
      }
    }
    return
  }
}

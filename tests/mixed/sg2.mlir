module  {
  func.func @matmul(
    
    %arg0: i32, 
    %arg1: i32, 
    %arg2: i32, 
    %arg3: memref<?x10000xf32>, 
    %arg4: memref<?x10000xf32>, 
    %arg5: memref<?x10000xf32>,
    

    %b_arg3: memref<?x10000xf32>, 
    %b_arg4: memref<?x10000xf32>, 
    %b_arg5: memref<?x10000xf32>,
    
 
    %c_arg3: memref<?x10000xf32>, 
    %c_arg4: memref<?x10000xf32>, 
    %c_arg5: memref<?x10000xf32>
    
    ) {
    %cst = arith.constant 0.000000e+00 : f32
    %0 = arith.index_cast %arg0 : i32 to index
    %1 = arith.index_cast %arg1 : i32 to index
    %2 = arith.index_cast %arg2 : i32 to index
    affine.for %arg6 = 0 to 10000 {
      affine.for %arg7 = 0 to 10000 {
        affine.store %cst, %arg5[%arg6, %arg7] : memref<?x10000xf32>
        affine.for %arg8 = 0 to 10000 {
          %3 = affine.load %arg3[%arg6, %arg8] : memref<?x10000xf32>
          %4 = affine.load %arg4[%arg8, %arg7] : memref<?x10000xf32>
          %5 = arith.mulf %3, %4 : f32
          %6 = affine.load %arg5[%arg6, %arg7] : memref<?x10000xf32>
          %7 = arith.addf %6, %5 : f32
          affine.store %7, %arg5[%arg6, %arg7] : memref<?x10000xf32>
        }
      }
    }

    affine.for %arg6 = 0 to 10000 {
      affine.for %arg7 = 0 to 10000 {
        affine.store %cst, %b_arg5[%arg6, %arg7] : memref<?x10000xf32>
        affine.for %arg8 = 0 to 10000 {
          %3 = affine.load %b_arg3[%arg6, %arg8] : memref<?x10000xf32>
          %4 = affine.load %b_arg4[%arg8, %arg7] : memref<?x10000xf32>
          %5 = arith.mulf %3, %4 : f32
          %6 = affine.load %b_arg5[%arg6, %arg7] : memref<?x10000xf32>
          %7 = arith.addf %6, %5 : f32
          affine.store %7, %b_arg5[%arg6, %arg7] : memref<?x10000xf32>
        }
      }
    }

    affine.for %arg6 = 0 to 10000 {
      affine.for %arg7 = 0 to 10000 {
        affine.store %cst, %c_arg5[%arg6, %arg7] : memref<?x10000xf32>
        affine.for %arg8 = 0 to 10000 {
          %3 = affine.load %c_arg3[%arg6, %arg8] : memref<?x10000xf32>
          %4 = affine.load %c_arg4[%arg8, %arg7] : memref<?x10000xf32>
          %5 = arith.mulf %3, %4 : f32
          %6 = affine.load %c_arg5[%arg6, %arg7] : memref<?x10000xf32>
          %7 = arith.addf %6, %5 : f32
          affine.store %7, %c_arg5[%arg6, %arg7] : memref<?x10000xf32>
        }
      }
    }

    return
  }
}
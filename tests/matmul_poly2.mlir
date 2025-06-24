module {
  func.func @_Z10cpu_matmulPolyPA400_fPA300_fS2_(%arg0: memref<?x400xf32>, %arg1: memref<?x300xf32>, %arg2: memref<?x300xf32>){
    %c200 = arith.constant 200 : index
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c300 = arith.constant 300 : index
    %c400 = arith.constant 400 : index
    scf.for   %arg3 = %c0 to %c200 step %c1  {
      scf.for %arg4 = %c0 to %c300 step %c1 {
        scf.for %arg5 = %c0 to %c400 step %c1 {
          %0 = memref.load %arg0[%arg3, %arg5] : memref<?x400xf32>
          %1 = memref.load %arg1[%arg5, %arg4] : memref<?x300xf32>
          %2 = arith.mulf %0, %1 : f32
          %3 = memref.load %arg2[%arg3, %arg4] : memref<?x300xf32>
          %4 = arith.addf %3, %2 : f32
          memref.store %4, %arg2[%arg3, %arg4] : memref<?x300xf32>
        }
      }
    } {task="true"}


    scf.for   %arg3 = %c0 to %c200 step %c1  {
      scf.for %arg4 = %c0 to %c300 step %c1 {
        scf.for %arg5 = %c0 to %c400 step %c1 {
          %0 = memref.load %arg0[%arg3, %arg5] : memref<?x400xf32>
          %1 = memref.load %arg1[%arg5, %arg4] : memref<?x300xf32>
          %2 = arith.mulf %0, %1 : f32
          %3 = memref.load %arg2[%arg3, %arg4] : memref<?x300xf32>
          %4 = arith.addf %3, %2 : f32
          memref.store %4, %arg2[%arg3, %arg4] : memref<?x300xf32>
        }
      }
    } {task="true"}

    
    return
  }
}


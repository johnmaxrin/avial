module attributes {avial.target_devices = [#dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 1.000000e+00 : f32, "node_id" = "node0", "gpu_count" = 0 : i32, "gpu_arch" = [], "gpu_id" = []>, #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 5.000000e-01 : f32, "node_id" = "node1", "gpu_count" = 1 : i32, "gpu_arch" = ["sm_61"], "gpu_id" = [0 : i32]>, #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 5.000000e-01 : f32, "node_id" = "node2", "gpu_count" = 1 : i32, "gpu_arch" = ["sm_61"], "gpu_id" = [0 : i32]>]} {
  "avial.schedule"() <{inputs = [{name = "arg0", type = i32}, {name = "arg1", type = i32}, {name = "arg2", type = f32}, {name = "arg3", type = f32}, {name = "arg4", type = memref<?x1000xf32>}, {name = "arg5", type = memref<?x1000xf32>}, {name = "arg6", type = memref<?x1000xf32>}], scheduleName = "kernel_syr2k"}> ({
  ^bb0(%arg0: i32, %arg1: i32, %arg2: f32, %arg3: f32, %arg4: memref<?x1000xf32>, %arg5: memref<?x1000xf32>, %arg6: memref<?x1000xf32>):
    "avial.replicate"(%arg4) <{operandSegmentSizes = array<i32: 0, 1>}> ({
      %c0 = arith.constant 0 : index
      %c1000 = arith.constant 1000 : index
      %c1 = arith.constant 1 : index
      scf.for %arg7 = %c0 to %c1000 step %c1 {
        %c0_0 = arith.constant 0 : index
        %c1000_1 = arith.constant 1000 : index
        %c1_2 = arith.constant 1 : index
        scf.for %arg8 = %c0_0 to %c1000_1 step %c1_2 {
          %0 = memref.load %arg4[%arg7, %arg8] : memref<?x1000xf32>
          %1 = arith.mulf %0, %arg3 : f32
          memref.store %1, %arg4[%arg7, %arg8] : memref<?x1000xf32>
        }
      }
      "avial.yield"() : () -> ()
    }) {replicateID = 1 : i64} : (memref<?x1000xf32>) -> ()
    "avial.replicate"(%arg6, %arg5, %arg4) <{operandSegmentSizes = array<i32: 2, 1>}> ({
      %c0 = arith.constant 0 : index
      %c1000 = arith.constant 1000 : index
      %c1 = arith.constant 1 : index
      scf.for %arg7 = %c0 to %c1000 step %c1 {
        %c0_0 = arith.constant 0 : index
        %c1000_1 = arith.constant 1000 : index
        %c1_2 = arith.constant 1 : index
        scf.for %arg8 = %c0_0 to %c1000_1 step %c1_2 {
          %c0_3 = arith.constant 0 : index
          %c1000_4 = arith.constant 1000 : index
          %c1_5 = arith.constant 1 : index
          scf.for %arg9 = %c0_3 to %c1000_4 step %c1_5 {
            %0 = memref.load %arg5[%arg7, %arg9] : memref<?x1000xf32>
            %1 = arith.mulf %arg2, %0 : f32
            %2 = memref.load %arg6[%arg8, %arg9] : memref<?x1000xf32>
            %3 = arith.mulf %1, %2 : f32
            %4 = memref.load %arg4[%arg7, %arg8] : memref<?x1000xf32>
            %5 = arith.addf %4, %3 : f32
            memref.store %5, %arg4[%arg7, %arg8] : memref<?x1000xf32>
            %6 = memref.load %arg6[%arg7, %arg9] : memref<?x1000xf32>
            %7 = arith.mulf %arg2, %6 : f32
            %8 = memref.load %arg5[%arg8, %arg9] : memref<?x1000xf32>
            %9 = arith.mulf %7, %8 : f32
            %10 = memref.load %arg4[%arg7, %arg8] : memref<?x1000xf32>
            %11 = arith.addf %10, %9 : f32
            memref.store %11, %arg4[%arg7, %arg8] : memref<?x1000xf32>
          }
        }
      }
      "avial.yield"() : () -> ()
    }) {replicateID = 2 : i64} : (memref<?x1000xf32>, memref<?x1000xf32>, memref<?x1000xf32>) -> ()
    "avial.yield"() : () -> ()
  }) : () -> ()
}

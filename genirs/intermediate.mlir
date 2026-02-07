module attributes {avial.target_devices = [#dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 1.000000e+00 : f32, "node_id" = "node0", "gpu_count" = 0 : i32, "gpu_arch" = [], "gpu_id" = []>, #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 5.000000e-01 : f32, "node_id" = "node1", "gpu_count" = 1 : i32, "gpu_arch" = ["sm_61"], "gpu_id" = [0 : i32]>, #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 5.000000e-01 : f32, "node_id" = "node2", "gpu_count" = 1 : i32, "gpu_arch" = ["sm_61"], "gpu_id" = [0 : i32]>]} {
  "avial.schedule"() <{inputs = [{name = "arg0", type = i32}, {name = "arg1", type = i32}, {name = "arg2", type = f32}, {name = "arg3", type = f32}, {name = "arg4", type = memref<?x1000xf32>}, {name = "arg5", type = memref<?x1000xf32>}, {name = "arg6", type = memref<?x1000xf32>}], scheduleName = "kernel_syr2k"}> ({
  ^bb0(%arg0: i32, %arg1: i32, %arg2: f32, %arg3: f32, %arg4: memref<?x1000xf32>, %arg5: memref<?x1000xf32>, %arg6: memref<?x1000xf32>):
    %subview = memref.subview %arg4[0, 0] [334, 1000] [1, 1] : memref<?x1000xf32> to memref<334x1000xf32, strided<[1000, 1]>>
    %0 = "avial.task"(%subview, %arg4) <{inpRanges = array<i64: 0, 0>, operandSegmentSizes = array<i32: 0, 1, 1>, outRanges = array<i64: 0, 334>, target = #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 1.000000e+00 : f32, "node_id" = "node0", "gpu_count" = 0 : i32, "gpu_arch" = [], "gpu_id" = []>}> ({
    ^bb0(%arg7: memref<334x1000xf32, strided<[1000, 1]>>):
      %c0 = arith.constant 0 : index
      %c334 = arith.constant 334 : index
      %c1 = arith.constant 1 : index
      scf.parallel (%arg8) = (%c0) to (%c334) step (%c1) {
        %c0_5 = arith.constant 0 : index
        %c1000 = arith.constant 1000 : index
        %c1_6 = arith.constant 1 : index
        scf.for %arg9 = %c0_5 to %c1000 step %c1_6 {
          %6 = memref.load %subview[%arg8, %arg9] : memref<334x1000xf32, strided<[1000, 1]>>
          %7 = arith.mulf %6, %arg3 : f32
          memref.store %7, %subview[%arg8, %arg9] : memref<334x1000xf32, strided<[1000, 1]>>
        }
        scf.reduce 
      }
      "avial.yield"() : () -> ()
    }) {name = "0", needBroadcast = false, repId = 1 : i64} : (memref<334x1000xf32, strided<[1000, 1]>>, memref<?x1000xf32>) -> !avial.taskref
    %subview_0 = memref.subview %arg4[334, 0] [333, 1000] [1, 1] : memref<?x1000xf32> to memref<333x1000xf32, strided<[1000, 1], offset: 334000>>
    %1 = "avial.task"(%subview_0, %arg4) <{inpRanges = array<i64: 0, 0>, operandSegmentSizes = array<i32: 0, 1, 1>, outRanges = array<i64: 334, 667>, target = #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 5.000000e-01 : f32, "node_id" = "node1", "gpu_count" = 1 : i32, "gpu_arch" = ["sm_61"], "gpu_id" = [0 : i32]>}> ({
    ^bb0(%arg7: memref<333x1000xf32, strided<[1000, 1], offset: 334000>>):
      %c0 = arith.constant 0 : index
      %c333 = arith.constant 333 : index
      %c1 = arith.constant 1 : index
      scf.parallel (%arg8) = (%c0) to (%c333) step (%c1) {
        %c0_5 = arith.constant 0 : index
        %c1000 = arith.constant 1000 : index
        %c1_6 = arith.constant 1 : index
        scf.for %arg9 = %c0_5 to %c1000 step %c1_6 {
          %6 = memref.load %subview_0[%arg8, %arg9] : memref<333x1000xf32, strided<[1000, 1], offset: 334000>>
          %7 = arith.mulf %6, %arg3 : f32
          memref.store %7, %subview_0[%arg8, %arg9] : memref<333x1000xf32, strided<[1000, 1], offset: 334000>>
        }
        scf.reduce 
      }
      "avial.yield"() : () -> ()
    }) {name = "1", needBroadcast = false, repId = 1 : i64} : (memref<333x1000xf32, strided<[1000, 1], offset: 334000>>, memref<?x1000xf32>) -> !avial.taskref
    %subview_1 = memref.subview %arg4[667, 0] [333, 1000] [1, 1] : memref<?x1000xf32> to memref<333x1000xf32, strided<[1000, 1], offset: 667000>>
    %2 = "avial.task"(%subview_1, %arg4) <{inpRanges = array<i64: 0, 0>, operandSegmentSizes = array<i32: 0, 1, 1>, outRanges = array<i64: 667, 1000>, target = #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 5.000000e-01 : f32, "node_id" = "node2", "gpu_count" = 1 : i32, "gpu_arch" = ["sm_61"], "gpu_id" = [0 : i32]>}> ({
    ^bb0(%arg7: memref<333x1000xf32, strided<[1000, 1], offset: 667000>>):
      %c0 = arith.constant 0 : index
      %c333 = arith.constant 333 : index
      %c1 = arith.constant 1 : index
      scf.parallel (%arg8) = (%c0) to (%c333) step (%c1) {
        %c0_5 = arith.constant 0 : index
        %c1000 = arith.constant 1000 : index
        %c1_6 = arith.constant 1 : index
        scf.for %arg9 = %c0_5 to %c1000 step %c1_6 {
          %6 = memref.load %subview_1[%arg8, %arg9] : memref<333x1000xf32, strided<[1000, 1], offset: 667000>>
          %7 = arith.mulf %6, %arg3 : f32
          memref.store %7, %subview_1[%arg8, %arg9] : memref<333x1000xf32, strided<[1000, 1], offset: 667000>>
        }
        scf.reduce 
      }
      "avial.yield"() : () -> ()
    }) {name = "2", needBroadcast = false, repId = 1 : i64} : (memref<333x1000xf32, strided<[1000, 1], offset: 667000>>, memref<?x1000xf32>) -> !avial.taskref
    %subview_2 = memref.subview %arg4[0, 0] [334, 1000] [1, 1] : memref<?x1000xf32> to memref<334x1000xf32, strided<[1000, 1]>>
    %3 = "avial.task"(%arg6, %arg5, %subview_2, %arg4) <{inpRanges = array<i64: 0, 0>, operandSegmentSizes = array<i32: 2, 1, 1>, outRanges = array<i64: 0, 334>, target = #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 1.000000e+00 : f32, "node_id" = "node0", "gpu_count" = 0 : i32, "gpu_arch" = [], "gpu_id" = []>}> ({
    ^bb0(%arg7: memref<?x1000xf32>, %arg8: memref<?x1000xf32>, %arg9: memref<334x1000xf32, strided<[1000, 1]>>):
      %c0 = arith.constant 0 : index
      %c334 = arith.constant 334 : index
      %c1 = arith.constant 1 : index
      scf.parallel (%arg10) = (%c0) to (%c334) step (%c1) {
        %c0_5 = arith.constant 0 : index
        %c1000 = arith.constant 1000 : index
        %c1_6 = arith.constant 1 : index
        scf.for %arg11 = %c0_5 to %c1000 step %c1_6 {
          %c0_7 = arith.constant 0 : index
          %c1000_8 = arith.constant 1000 : index
          %c1_9 = arith.constant 1 : index
          scf.for %arg12 = %c0_7 to %c1000_8 step %c1_9 {
            %6 = memref.load %arg5[%arg10, %arg12] : memref<?x1000xf32>
            %7 = arith.mulf %arg2, %6 : f32
            %8 = memref.load %arg6[%arg11, %arg12] : memref<?x1000xf32>
            %9 = arith.mulf %7, %8 : f32
            %10 = memref.load %subview_2[%arg10, %arg11] : memref<334x1000xf32, strided<[1000, 1]>>
            %11 = arith.addf %10, %9 : f32
            memref.store %11, %subview_2[%arg10, %arg11] : memref<334x1000xf32, strided<[1000, 1]>>
            %12 = memref.load %arg6[%arg10, %arg12] : memref<?x1000xf32>
            %13 = arith.mulf %arg2, %12 : f32
            %14 = memref.load %arg5[%arg11, %arg12] : memref<?x1000xf32>
            %15 = arith.mulf %13, %14 : f32
            %16 = memref.load %subview_2[%arg10, %arg11] : memref<334x1000xf32, strided<[1000, 1]>>
            %17 = arith.addf %16, %15 : f32
            memref.store %17, %subview_2[%arg10, %arg11] : memref<334x1000xf32, strided<[1000, 1]>>
          }
        }
        scf.reduce 
      }
      "avial.yield"() : () -> ()
    }) {name = "0", needBroadcast = false, repId = 2 : i64} : (memref<?x1000xf32>, memref<?x1000xf32>, memref<334x1000xf32, strided<[1000, 1]>>, memref<?x1000xf32>) -> !avial.taskref
    %subview_3 = memref.subview %arg4[334, 0] [333, 1000] [1, 1] : memref<?x1000xf32> to memref<333x1000xf32, strided<[1000, 1], offset: 334000>>
    %4 = "avial.task"(%arg6, %arg5, %subview_3, %arg4) <{inpRanges = array<i64: 0, 0>, operandSegmentSizes = array<i32: 2, 1, 1>, outRanges = array<i64: 334, 667>, target = #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 5.000000e-01 : f32, "node_id" = "node1", "gpu_count" = 1 : i32, "gpu_arch" = ["sm_61"], "gpu_id" = [0 : i32]>}> ({
    ^bb0(%arg7: memref<?x1000xf32>, %arg8: memref<?x1000xf32>, %arg9: memref<333x1000xf32, strided<[1000, 1], offset: 334000>>):
      %c0 = arith.constant 0 : index
      %c333 = arith.constant 333 : index
      %c1 = arith.constant 1 : index
      scf.parallel (%arg10) = (%c0) to (%c333) step (%c1) {
        %c0_5 = arith.constant 0 : index
        %c1000 = arith.constant 1000 : index
        %c1_6 = arith.constant 1 : index
        scf.for %arg11 = %c0_5 to %c1000 step %c1_6 {
          %c0_7 = arith.constant 0 : index
          %c1000_8 = arith.constant 1000 : index
          %c1_9 = arith.constant 1 : index
          scf.for %arg12 = %c0_7 to %c1000_8 step %c1_9 {
            %6 = memref.load %arg5[%arg10, %arg12] : memref<?x1000xf32>
            %7 = arith.mulf %arg2, %6 : f32
            %8 = memref.load %arg6[%arg11, %arg12] : memref<?x1000xf32>
            %9 = arith.mulf %7, %8 : f32
            %10 = memref.load %subview_3[%arg10, %arg11] : memref<333x1000xf32, strided<[1000, 1], offset: 334000>>
            %11 = arith.addf %10, %9 : f32
            memref.store %11, %subview_3[%arg10, %arg11] : memref<333x1000xf32, strided<[1000, 1], offset: 334000>>
            %12 = memref.load %arg6[%arg10, %arg12] : memref<?x1000xf32>
            %13 = arith.mulf %arg2, %12 : f32
            %14 = memref.load %arg5[%arg11, %arg12] : memref<?x1000xf32>
            %15 = arith.mulf %13, %14 : f32
            %16 = memref.load %subview_3[%arg10, %arg11] : memref<333x1000xf32, strided<[1000, 1], offset: 334000>>
            %17 = arith.addf %16, %15 : f32
            memref.store %17, %subview_3[%arg10, %arg11] : memref<333x1000xf32, strided<[1000, 1], offset: 334000>>
          }
        }
        scf.reduce 
      }
      "avial.yield"() : () -> ()
    }) {name = "1", needBroadcast = false, repId = 2 : i64} : (memref<?x1000xf32>, memref<?x1000xf32>, memref<333x1000xf32, strided<[1000, 1], offset: 334000>>, memref<?x1000xf32>) -> !avial.taskref
    %subview_4 = memref.subview %arg4[667, 0] [333, 1000] [1, 1] : memref<?x1000xf32> to memref<333x1000xf32, strided<[1000, 1], offset: 667000>>
    %5 = "avial.task"(%arg6, %arg5, %subview_4, %arg4) <{inpRanges = array<i64: 0, 0>, operandSegmentSizes = array<i32: 2, 1, 1>, outRanges = array<i64: 667, 1000>, target = #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 5.000000e-01 : f32, "node_id" = "node2", "gpu_count" = 1 : i32, "gpu_arch" = ["sm_61"], "gpu_id" = [0 : i32]>}> ({
    ^bb0(%arg7: memref<?x1000xf32>, %arg8: memref<?x1000xf32>, %arg9: memref<333x1000xf32, strided<[1000, 1], offset: 667000>>):
      %c0 = arith.constant 0 : index
      %c333 = arith.constant 333 : index
      %c1 = arith.constant 1 : index
      scf.parallel (%arg10) = (%c0) to (%c333) step (%c1) {
        %c0_5 = arith.constant 0 : index
        %c1000 = arith.constant 1000 : index
        %c1_6 = arith.constant 1 : index
        scf.for %arg11 = %c0_5 to %c1000 step %c1_6 {
          %c0_7 = arith.constant 0 : index
          %c1000_8 = arith.constant 1000 : index
          %c1_9 = arith.constant 1 : index
          scf.for %arg12 = %c0_7 to %c1000_8 step %c1_9 {
            %6 = memref.load %arg5[%arg10, %arg12] : memref<?x1000xf32>
            %7 = arith.mulf %arg2, %6 : f32
            %8 = memref.load %arg6[%arg11, %arg12] : memref<?x1000xf32>
            %9 = arith.mulf %7, %8 : f32
            %10 = memref.load %subview_4[%arg10, %arg11] : memref<333x1000xf32, strided<[1000, 1], offset: 667000>>
            %11 = arith.addf %10, %9 : f32
            memref.store %11, %subview_4[%arg10, %arg11] : memref<333x1000xf32, strided<[1000, 1], offset: 667000>>
            %12 = memref.load %arg6[%arg10, %arg12] : memref<?x1000xf32>
            %13 = arith.mulf %arg2, %12 : f32
            %14 = memref.load %arg5[%arg11, %arg12] : memref<?x1000xf32>
            %15 = arith.mulf %13, %14 : f32
            %16 = memref.load %subview_4[%arg10, %arg11] : memref<333x1000xf32, strided<[1000, 1], offset: 667000>>
            %17 = arith.addf %16, %15 : f32
            memref.store %17, %subview_4[%arg10, %arg11] : memref<333x1000xf32, strided<[1000, 1], offset: 667000>>
          }
        }
        scf.reduce 
      }
      "avial.yield"() : () -> ()
    }) {name = "2", needBroadcast = false, repId = 2 : i64} : (memref<?x1000xf32>, memref<?x1000xf32>, memref<333x1000xf32, strided<[1000, 1], offset: 667000>>, memref<?x1000xf32>) -> !avial.taskref
    "avial.yield"() : () -> ()
  }) : () -> ()
}

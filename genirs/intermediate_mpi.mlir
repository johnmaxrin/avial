#map = affine_map<(d0)[s0, s1] -> ((d0 - s0) ceildiv s1)>
module attributes {avial.target_devices = [#dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 1.000000e+00 : f32, "node_id" = "node0", "gpu_count" = 0 : i32, "gpu_arch" = [], "gpu_id" = []>, #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 5.000000e-01 : f32, "node_id" = "node1", "gpu_count" = 1 : i32, "gpu_arch" = ["sm_61"], "gpu_id" = [0 : i32]>, #dlti.target_device_spec<"type" = "node", "arch" = "x86_64", "cost" = 5.000000e-01 : f32, "node_id" = "node2", "gpu_count" = 1 : i32, "gpu_arch" = ["sm_61"], "gpu_id" = [0 : i32]>], gpu.container_module} {
  func.func @kernel_syr2k(%arg0: i32, %arg1: i32, %arg2: f32, %arg3: f32, %arg4: memref<?x1000xf32>, %arg5: memref<?x1000xf32>, %arg6: memref<?x1000xf32>) {
    %0 = mpi.init : !mpi.retval
    %1 = mpi.comm_world : !mpi.comm
    %rank = mpi.comm_rank(%1) : i32
    %retval, %size = mpi.comm_size(%1) : !mpi.retval, i32
    %subview = memref.subview %arg4[0, 0] [334, 1000] [1, 1] : memref<?x1000xf32> to memref<334x1000xf32, strided<[1000, 1]>>
    %subview_0 = memref.subview %arg4[334, 0] [333, 1000] [1, 1] : memref<?x1000xf32> to memref<333x1000xf32, strided<[1000, 1], offset: 334000>>
    %subview_1 = memref.subview %arg4[667, 0] [333, 1000] [1, 1] : memref<?x1000xf32> to memref<333x1000xf32, strided<[1000, 1], offset: 667000>>
    %subview_2 = memref.subview %arg4[0, 0] [334, 1000] [1, 1] : memref<?x1000xf32> to memref<334x1000xf32, strided<[1000, 1]>>
    %subview_3 = memref.subview %arg4[334, 0] [333, 1000] [1, 1] : memref<?x1000xf32> to memref<333x1000xf32, strided<[1000, 1], offset: 334000>>
    %subview_4 = memref.subview %arg4[667, 0] [333, 1000] [1, 1] : memref<?x1000xf32> to memref<333x1000xf32, strided<[1000, 1], offset: 667000>>
    %c0_i32 = arith.constant 0 : i32
    %2 = arith.remsi %c0_i32, %size : i32
    %3 = arith.cmpi eq, %rank, %2 : i32
    scf.if %3 {
      %c0 = arith.constant 0 : index
      %c334 = arith.constant 334 : index
      %c1 = arith.constant 1 : index
      %23 = llvm.mlir.constant(1 : i64) : i64
      omp.parallel {
        omp.wsloop {
          omp.loop_nest (%arg7) : index = (%c0) to (%c334) step (%c1) {
            memref.alloca_scope  {
              %c0_20 = arith.constant 0 : index
              %c1000 = arith.constant 1000 : index
              %c1_21 = arith.constant 1 : index
              scf.for %arg8 = %c0_20 to %c1000 step %c1_21 {
                %24 = memref.load %subview[%arg7, %arg8] : memref<334x1000xf32, strided<[1000, 1]>>
                %25 = arith.mulf %24, %arg3 : f32
                memref.store %25, %subview[%arg7, %arg8] : memref<334x1000xf32, strided<[1000, 1]>>
              }
            }
            omp.yield
          }
        }
        omp.terminator
      }
    }
    %c1_i32 = arith.constant 1 : i32
    %4 = arith.remsi %c1_i32, %size : i32
    %5 = arith.cmpi eq, %rank, %4 : i32
    scf.if %5 {
      %alloc = memref.alloc() : memref<333x1000xf32>
      memref.copy %subview_0, %alloc : memref<333x1000xf32, strided<[1000, 1], offset: 334000>> to memref<333x1000xf32>
      %memref = gpu.alloc  () : memref<333x1000xf32>
      gpu.memcpy  %memref, %alloc : memref<333x1000xf32>, memref<333x1000xf32>
      %c0 = arith.constant 0 : index
      %c333 = arith.constant 333 : index
      %c1 = arith.constant 1 : index
      %c1_20 = arith.constant 1 : index
      %23 = affine.apply #map(%c333)[%c0, %c1]
      gpu.launch_func  @kernel_syr2k_kernel::@kernel_syr2k_kernel blocks in (%23, %c1_20, %c1_20) threads in (%c1_20, %c1_20, %c1_20)  args(%c1 : index, %c0 : index, %memref : memref<333x1000xf32>, %arg3 : f32)
      gpu.memcpy  %alloc, %memref : memref<333x1000xf32>, memref<333x1000xf32>
      memref.copy %alloc, %subview_0 : memref<333x1000xf32> to memref<333x1000xf32, strided<[1000, 1], offset: 334000>>
    }
    %c2_i32 = arith.constant 2 : i32
    %6 = arith.remsi %c2_i32, %size : i32
    %7 = arith.cmpi eq, %rank, %6 : i32
    scf.if %7 {
      %alloc = memref.alloc() : memref<333x1000xf32>
      memref.copy %subview_1, %alloc : memref<333x1000xf32, strided<[1000, 1], offset: 667000>> to memref<333x1000xf32>
      %memref = gpu.alloc  () : memref<333x1000xf32>
      gpu.memcpy  %memref, %alloc : memref<333x1000xf32>, memref<333x1000xf32>
      %c0 = arith.constant 0 : index
      %c333 = arith.constant 333 : index
      %c1 = arith.constant 1 : index
      %c1_20 = arith.constant 1 : index
      %23 = affine.apply #map(%c333)[%c0, %c1]
      gpu.launch_func  @kernel_syr2k_kernel_0::@kernel_syr2k_kernel blocks in (%23, %c1_20, %c1_20) threads in (%c1_20, %c1_20, %c1_20)  args(%c1 : index, %c0 : index, %memref : memref<333x1000xf32>, %arg3 : f32)
      gpu.memcpy  %alloc, %memref : memref<333x1000xf32>, memref<333x1000xf32>
      memref.copy %alloc, %subview_1 : memref<333x1000xf32> to memref<333x1000xf32, strided<[1000, 1], offset: 667000>>
    }
    %8 = mpi.barrier(%1) -> !mpi.retval
    %c1_i32_5 = arith.constant 1 : i32
    %c0_i32_6 = arith.constant 0 : i32
    %c0_i32_7 = arith.constant 0 : i32
    %subview_8 = memref.subview %arg4[0, 0] [334000, 1000] [1, 1] : memref<?x1000xf32> to memref<334000x1000xf32, strided<[1000, 1]>>
    %9 = arith.cmpi eq, %rank, %c0_i32_6 : i32
    scf.if %9 {
      %c0_i32_20 = arith.constant 0 : i32
      %23 = arith.remsi %c0_i32_20, %size : i32
      %24 = arith.cmpi ne, %23, %c0_i32_6 : i32
      scf.if %24 {
        %25 = mpi.recv(%subview_8, %c0_i32_7, %23, %1) : memref<334000x1000xf32, strided<[1000, 1]>>, i32, i32 -> !mpi.retval
      }
    } else {
      %c0_i32_20 = arith.constant 0 : i32
      %23 = arith.remsi %c0_i32_20, %size : i32
      %24 = arith.cmpi eq, %rank, %23 : i32
      scf.if %24 {
        %25 = mpi.send(%subview_8, %c0_i32_7, %c0_i32_6, %1) : memref<334000x1000xf32, strided<[1000, 1]>>, i32, i32 -> !mpi.retval
      }
    }
    %subview_9 = memref.subview %arg4[334, 0] [333000, 1000] [1, 1] : memref<?x1000xf32> to memref<333000x1000xf32, strided<[1000, 1], offset: 334000>>
    %10 = arith.cmpi eq, %rank, %c0_i32_6 : i32
    scf.if %10 {
      %c1_i32_20 = arith.constant 1 : i32
      %23 = arith.remsi %c1_i32_20, %size : i32
      %24 = arith.cmpi ne, %23, %c0_i32_6 : i32
      scf.if %24 {
        %25 = mpi.recv(%subview_9, %c0_i32_7, %23, %1) : memref<333000x1000xf32, strided<[1000, 1], offset: 334000>>, i32, i32 -> !mpi.retval
      }
    } else {
      %c1_i32_20 = arith.constant 1 : i32
      %23 = arith.remsi %c1_i32_20, %size : i32
      %24 = arith.cmpi eq, %rank, %23 : i32
      scf.if %24 {
        %25 = mpi.send(%subview_9, %c0_i32_7, %c0_i32_6, %1) : memref<333000x1000xf32, strided<[1000, 1], offset: 334000>>, i32, i32 -> !mpi.retval
      }
    }
    %subview_10 = memref.subview %arg4[667, 0] [333000, 1000] [1, 1] : memref<?x1000xf32> to memref<333000x1000xf32, strided<[1000, 1], offset: 667000>>
    %11 = arith.cmpi eq, %rank, %c0_i32_6 : i32
    scf.if %11 {
      %c2_i32_20 = arith.constant 2 : i32
      %23 = arith.remsi %c2_i32_20, %size : i32
      %24 = arith.cmpi ne, %23, %c0_i32_6 : i32
      scf.if %24 {
        %25 = mpi.recv(%subview_10, %c0_i32_7, %23, %1) : memref<333000x1000xf32, strided<[1000, 1], offset: 667000>>, i32, i32 -> !mpi.retval
      }
    } else {
      %c2_i32_20 = arith.constant 2 : i32
      %23 = arith.remsi %c2_i32_20, %size : i32
      %24 = arith.cmpi eq, %rank, %23 : i32
      scf.if %24 {
        %25 = mpi.send(%subview_10, %c0_i32_7, %c0_i32_6, %1) : memref<333000x1000xf32, strided<[1000, 1], offset: 667000>>, i32, i32 -> !mpi.retval
      }
    }
    %c0_i32_11 = arith.constant 0 : i32
    %12 = arith.remsi %c0_i32_11, %size : i32
    %13 = arith.cmpi eq, %rank, %12 : i32
    scf.if %13 {
      %c0 = arith.constant 0 : index
      %c334 = arith.constant 334 : index
      %c1 = arith.constant 1 : index
      %23 = llvm.mlir.constant(1 : i64) : i64
      omp.parallel {
        omp.wsloop {
          omp.loop_nest (%arg7) : index = (%c0) to (%c334) step (%c1) {
            memref.alloca_scope  {
              %c0_20 = arith.constant 0 : index
              %c1000 = arith.constant 1000 : index
              %c1_21 = arith.constant 1 : index
              scf.for %arg8 = %c0_20 to %c1000 step %c1_21 {
                %c0_22 = arith.constant 0 : index
                %c1000_23 = arith.constant 1000 : index
                %c1_24 = arith.constant 1 : index
                scf.for %arg9 = %c0_22 to %c1000_23 step %c1_24 {
                  %24 = memref.load %arg5[%arg7, %arg9] : memref<?x1000xf32>
                  %25 = arith.mulf %arg2, %24 : f32
                  %26 = memref.load %arg6[%arg8, %arg9] : memref<?x1000xf32>
                  %27 = arith.mulf %25, %26 : f32
                  %28 = memref.load %subview_2[%arg7, %arg8] : memref<334x1000xf32, strided<[1000, 1]>>
                  %29 = arith.addf %28, %27 : f32
                  memref.store %29, %subview_2[%arg7, %arg8] : memref<334x1000xf32, strided<[1000, 1]>>
                  %30 = memref.load %arg6[%arg7, %arg9] : memref<?x1000xf32>
                  %31 = arith.mulf %arg2, %30 : f32
                  %32 = memref.load %arg5[%arg8, %arg9] : memref<?x1000xf32>
                  %33 = arith.mulf %31, %32 : f32
                  %34 = memref.load %subview_2[%arg7, %arg8] : memref<334x1000xf32, strided<[1000, 1]>>
                  %35 = arith.addf %34, %33 : f32
                  memref.store %35, %subview_2[%arg7, %arg8] : memref<334x1000xf32, strided<[1000, 1]>>
                }
              }
            }
            omp.yield
          }
        }
        omp.terminator
      }
    }
    %c1_i32_12 = arith.constant 1 : i32
    %14 = arith.remsi %c1_i32_12, %size : i32
    %15 = arith.cmpi eq, %rank, %14 : i32
    scf.if %15 {
      %alloc = memref.alloc() : memref<333x1000xf32>
      memref.copy %subview_3, %alloc : memref<333x1000xf32, strided<[1000, 1], offset: 334000>> to memref<333x1000xf32>
      %memref = gpu.alloc  () : memref<333x1000xf32>
      gpu.memcpy  %memref, %alloc : memref<333x1000xf32>, memref<333x1000xf32>
      %c0 = arith.constant 0 : index
      %dim = memref.dim %arg6, %c0 : memref<?x1000xf32>
      %alloc_20 = memref.alloc(%dim) : memref<?x1000xf32>
      memref.copy %arg6, %alloc_20 : memref<?x1000xf32> to memref<?x1000xf32>
      %memref_21 = gpu.alloc  (%dim) : memref<?x1000xf32>
      gpu.memcpy  %memref_21, %alloc_20 : memref<?x1000xf32>, memref<?x1000xf32>
      %c0_22 = arith.constant 0 : index
      %dim_23 = memref.dim %arg5, %c0_22 : memref<?x1000xf32>
      %alloc_24 = memref.alloc(%dim_23) : memref<?x1000xf32>
      memref.copy %arg5, %alloc_24 : memref<?x1000xf32> to memref<?x1000xf32>
      %memref_25 = gpu.alloc  (%dim_23) : memref<?x1000xf32>
      gpu.memcpy  %memref_25, %alloc_24 : memref<?x1000xf32>, memref<?x1000xf32>
      %c0_26 = arith.constant 0 : index
      %c333 = arith.constant 333 : index
      %c1 = arith.constant 1 : index
      %c1_27 = arith.constant 1 : index
      %23 = affine.apply #map(%c333)[%c0_26, %c1]
      gpu.launch_func  @kernel_syr2k_kernel_1::@kernel_syr2k_kernel blocks in (%23, %c1_27, %c1_27) threads in (%c1_27, %c1_27, %c1_27)  args(%c1 : index, %c0_26 : index, %memref_25 : memref<?x1000xf32>, %arg2 : f32, %memref_21 : memref<?x1000xf32>, %memref : memref<333x1000xf32>)
      gpu.memcpy  %alloc, %memref : memref<333x1000xf32>, memref<333x1000xf32>
      memref.copy %alloc, %subview_3 : memref<333x1000xf32> to memref<333x1000xf32, strided<[1000, 1], offset: 334000>>
    }
    %c2_i32_13 = arith.constant 2 : i32
    %16 = arith.remsi %c2_i32_13, %size : i32
    %17 = arith.cmpi eq, %rank, %16 : i32
    scf.if %17 {
      %alloc = memref.alloc() : memref<333x1000xf32>
      memref.copy %subview_4, %alloc : memref<333x1000xf32, strided<[1000, 1], offset: 667000>> to memref<333x1000xf32>
      %memref = gpu.alloc  () : memref<333x1000xf32>
      gpu.memcpy  %memref, %alloc : memref<333x1000xf32>, memref<333x1000xf32>
      %c0 = arith.constant 0 : index
      %dim = memref.dim %arg6, %c0 : memref<?x1000xf32>
      %alloc_20 = memref.alloc(%dim) : memref<?x1000xf32>
      memref.copy %arg6, %alloc_20 : memref<?x1000xf32> to memref<?x1000xf32>
      %memref_21 = gpu.alloc  (%dim) : memref<?x1000xf32>
      gpu.memcpy  %memref_21, %alloc_20 : memref<?x1000xf32>, memref<?x1000xf32>
      %c0_22 = arith.constant 0 : index
      %dim_23 = memref.dim %arg5, %c0_22 : memref<?x1000xf32>
      %alloc_24 = memref.alloc(%dim_23) : memref<?x1000xf32>
      memref.copy %arg5, %alloc_24 : memref<?x1000xf32> to memref<?x1000xf32>
      %memref_25 = gpu.alloc  (%dim_23) : memref<?x1000xf32>
      gpu.memcpy  %memref_25, %alloc_24 : memref<?x1000xf32>, memref<?x1000xf32>
      %c0_26 = arith.constant 0 : index
      %c333 = arith.constant 333 : index
      %c1 = arith.constant 1 : index
      %c1_27 = arith.constant 1 : index
      %23 = affine.apply #map(%c333)[%c0_26, %c1]
      gpu.launch_func  @kernel_syr2k_kernel_2::@kernel_syr2k_kernel blocks in (%23, %c1_27, %c1_27) threads in (%c1_27, %c1_27, %c1_27)  args(%c1 : index, %c0_26 : index, %memref_25 : memref<?x1000xf32>, %arg2 : f32, %memref_21 : memref<?x1000xf32>, %memref : memref<333x1000xf32>)
      gpu.memcpy  %alloc, %memref : memref<333x1000xf32>, memref<333x1000xf32>
      memref.copy %alloc, %subview_4 : memref<333x1000xf32> to memref<333x1000xf32, strided<[1000, 1], offset: 667000>>
    }
    %18 = mpi.barrier(%1) -> !mpi.retval
    %c1_i32_14 = arith.constant 1 : i32
    %c0_i32_15 = arith.constant 0 : i32
    %c0_i32_16 = arith.constant 0 : i32
    %subview_17 = memref.subview %arg4[0, 0] [334000, 1000] [1, 1] : memref<?x1000xf32> to memref<334000x1000xf32, strided<[1000, 1]>>
    %19 = arith.cmpi eq, %rank, %c0_i32_15 : i32
    scf.if %19 {
      %c0_i32_20 = arith.constant 0 : i32
      %23 = arith.remsi %c0_i32_20, %size : i32
      %24 = arith.cmpi ne, %23, %c0_i32_15 : i32
      scf.if %24 {
        %25 = mpi.recv(%subview_17, %c0_i32_16, %23, %1) : memref<334000x1000xf32, strided<[1000, 1]>>, i32, i32 -> !mpi.retval
      }
    } else {
      %c0_i32_20 = arith.constant 0 : i32
      %23 = arith.remsi %c0_i32_20, %size : i32
      %24 = arith.cmpi eq, %rank, %23 : i32
      scf.if %24 {
        %25 = mpi.send(%subview_17, %c0_i32_16, %c0_i32_15, %1) : memref<334000x1000xf32, strided<[1000, 1]>>, i32, i32 -> !mpi.retval
      }
    }
    %subview_18 = memref.subview %arg4[334, 0] [333000, 1000] [1, 1] : memref<?x1000xf32> to memref<333000x1000xf32, strided<[1000, 1], offset: 334000>>
    %20 = arith.cmpi eq, %rank, %c0_i32_15 : i32
    scf.if %20 {
      %c1_i32_20 = arith.constant 1 : i32
      %23 = arith.remsi %c1_i32_20, %size : i32
      %24 = arith.cmpi ne, %23, %c0_i32_15 : i32
      scf.if %24 {
        %25 = mpi.recv(%subview_18, %c0_i32_16, %23, %1) : memref<333000x1000xf32, strided<[1000, 1], offset: 334000>>, i32, i32 -> !mpi.retval
      }
    } else {
      %c1_i32_20 = arith.constant 1 : i32
      %23 = arith.remsi %c1_i32_20, %size : i32
      %24 = arith.cmpi eq, %rank, %23 : i32
      scf.if %24 {
        %25 = mpi.send(%subview_18, %c0_i32_16, %c0_i32_15, %1) : memref<333000x1000xf32, strided<[1000, 1], offset: 334000>>, i32, i32 -> !mpi.retval
      }
    }
    %subview_19 = memref.subview %arg4[667, 0] [333000, 1000] [1, 1] : memref<?x1000xf32> to memref<333000x1000xf32, strided<[1000, 1], offset: 667000>>
    %21 = arith.cmpi eq, %rank, %c0_i32_15 : i32
    scf.if %21 {
      %c2_i32_20 = arith.constant 2 : i32
      %23 = arith.remsi %c2_i32_20, %size : i32
      %24 = arith.cmpi ne, %23, %c0_i32_15 : i32
      scf.if %24 {
        %25 = mpi.recv(%subview_19, %c0_i32_16, %23, %1) : memref<333000x1000xf32, strided<[1000, 1], offset: 667000>>, i32, i32 -> !mpi.retval
      }
    } else {
      %c2_i32_20 = arith.constant 2 : i32
      %23 = arith.remsi %c2_i32_20, %size : i32
      %24 = arith.cmpi eq, %rank, %23 : i32
      scf.if %24 {
        %25 = mpi.send(%subview_19, %c0_i32_16, %c0_i32_15, %1) : memref<333000x1000xf32, strided<[1000, 1], offset: 667000>>, i32, i32 -> !mpi.retval
      }
    }
    %22 = mpi.barrier(%1) -> !mpi.retval
    return
  }
  gpu.module @kernel_syr2k_kernel [#nvvm.target<chip = "sm_61">] {
    llvm.func @kernel_syr2k_kernel(%arg0: i64, %arg1: i64, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: f32) attributes {gpu.kernel, gpu.known_block_size = array<i32: 1, 1, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 1, 1, 1>} {
      %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %1 = llvm.insertvalue %arg2, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %2 = llvm.insertvalue %arg3, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %3 = llvm.insertvalue %arg4, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %4 = llvm.insertvalue %arg5, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %5 = llvm.insertvalue %arg7, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %6 = llvm.insertvalue %arg6, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %7 = llvm.insertvalue %arg8, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %8 = llvm.mlir.constant(1 : index) : i64
      %9 = llvm.mlir.constant(1000 : index) : i64
      %10 = llvm.mlir.constant(0 : index) : i64
      %11 = nvvm.read.ptx.sreg.ctaid.x : i32
      %12 = llvm.sext %11 : i32 to i64
      %13 = llvm.mul %12, %arg0 overflow<nsw> : i64
      %14 = llvm.add %13, %arg1 : i64
      llvm.br ^bb1(%10 : i64)
    ^bb1(%15: i64):  // 2 preds: ^bb0, ^bb2
      %16 = llvm.icmp "slt" %15, %9 : i64
      llvm.cond_br %16, ^bb2, ^bb3
    ^bb2:  // pred: ^bb1
      %17 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %18 = llvm.mlir.constant(1000 : index) : i64
      %19 = llvm.mul %14, %18 overflow<nsw, nuw> : i64
      %20 = llvm.add %19, %15 overflow<nsw, nuw> : i64
      %21 = llvm.getelementptr inbounds|nuw %17[%20] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %22 = llvm.load %21 : !llvm.ptr -> f32
      %23 = llvm.fmul %22, %arg9 : f32
      %24 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %25 = llvm.mlir.constant(1000 : index) : i64
      %26 = llvm.mul %14, %25 overflow<nsw, nuw> : i64
      %27 = llvm.add %26, %15 overflow<nsw, nuw> : i64
      %28 = llvm.getelementptr inbounds|nuw %24[%27] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %23, %28 : f32, !llvm.ptr
      %29 = llvm.add %15, %8 : i64
      llvm.br ^bb1(%29 : i64)
    ^bb3:  // pred: ^bb1
      llvm.return
    }
  }
  gpu.module @kernel_syr2k_kernel_0 [#nvvm.target<chip = "sm_61">] {
    llvm.func @kernel_syr2k_kernel(%arg0: i64, %arg1: i64, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: f32) attributes {gpu.kernel, gpu.known_block_size = array<i32: 1, 1, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 1, 1, 1>} {
      %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %1 = llvm.insertvalue %arg2, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %2 = llvm.insertvalue %arg3, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %3 = llvm.insertvalue %arg4, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %4 = llvm.insertvalue %arg5, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %5 = llvm.insertvalue %arg7, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %6 = llvm.insertvalue %arg6, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %7 = llvm.insertvalue %arg8, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %8 = llvm.mlir.constant(1 : index) : i64
      %9 = llvm.mlir.constant(1000 : index) : i64
      %10 = llvm.mlir.constant(0 : index) : i64
      %11 = nvvm.read.ptx.sreg.ctaid.x : i32
      %12 = llvm.sext %11 : i32 to i64
      %13 = llvm.mul %12, %arg0 overflow<nsw> : i64
      %14 = llvm.add %13, %arg1 : i64
      llvm.br ^bb1(%10 : i64)
    ^bb1(%15: i64):  // 2 preds: ^bb0, ^bb2
      %16 = llvm.icmp "slt" %15, %9 : i64
      llvm.cond_br %16, ^bb2, ^bb3
    ^bb2:  // pred: ^bb1
      %17 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %18 = llvm.mlir.constant(1000 : index) : i64
      %19 = llvm.mul %14, %18 overflow<nsw, nuw> : i64
      %20 = llvm.add %19, %15 overflow<nsw, nuw> : i64
      %21 = llvm.getelementptr inbounds|nuw %17[%20] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %22 = llvm.load %21 : !llvm.ptr -> f32
      %23 = llvm.fmul %22, %arg9 : f32
      %24 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %25 = llvm.mlir.constant(1000 : index) : i64
      %26 = llvm.mul %14, %25 overflow<nsw, nuw> : i64
      %27 = llvm.add %26, %15 overflow<nsw, nuw> : i64
      %28 = llvm.getelementptr inbounds|nuw %24[%27] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %23, %28 : f32, !llvm.ptr
      %29 = llvm.add %15, %8 : i64
      llvm.br ^bb1(%29 : i64)
    ^bb3:  // pred: ^bb1
      llvm.return
    }
  }
  gpu.module @kernel_syr2k_kernel_1 [#nvvm.target<chip = "sm_61">] {
    llvm.func @kernel_syr2k_kernel(%arg0: i64, %arg1: i64, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: f32, %arg10: !llvm.ptr, %arg11: !llvm.ptr, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: !llvm.ptr, %arg18: !llvm.ptr, %arg19: i64, %arg20: i64, %arg21: i64, %arg22: i64, %arg23: i64) attributes {gpu.kernel, gpu.known_block_size = array<i32: 1, 1, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 1, 1, 1>} {
      %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %1 = llvm.insertvalue %arg17, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %2 = llvm.insertvalue %arg18, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %3 = llvm.insertvalue %arg19, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %4 = llvm.insertvalue %arg20, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %5 = llvm.insertvalue %arg22, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %6 = llvm.insertvalue %arg21, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %7 = llvm.insertvalue %arg23, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %9 = llvm.insertvalue %arg10, %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %10 = llvm.insertvalue %arg11, %9[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %11 = llvm.insertvalue %arg12, %10[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %12 = llvm.insertvalue %arg13, %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %13 = llvm.insertvalue %arg15, %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %14 = llvm.insertvalue %arg14, %13[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %15 = llvm.insertvalue %arg16, %14[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %16 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %17 = llvm.insertvalue %arg2, %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %18 = llvm.insertvalue %arg3, %17[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %19 = llvm.insertvalue %arg4, %18[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %20 = llvm.insertvalue %arg5, %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %21 = llvm.insertvalue %arg7, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %22 = llvm.insertvalue %arg6, %21[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %23 = llvm.insertvalue %arg8, %22[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %24 = llvm.mlir.constant(1 : index) : i64
      %25 = llvm.mlir.constant(1000 : index) : i64
      %26 = llvm.mlir.constant(0 : index) : i64
      %27 = nvvm.read.ptx.sreg.ctaid.x : i32
      %28 = llvm.sext %27 : i32 to i64
      %29 = llvm.mul %28, %arg0 overflow<nsw> : i64
      %30 = llvm.add %29, %arg1 : i64
      llvm.br ^bb1(%26 : i64)
    ^bb1(%31: i64):  // 2 preds: ^bb0, ^bb5
      %32 = llvm.icmp "slt" %31, %25 : i64
      llvm.cond_br %32, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      llvm.br ^bb3(%26 : i64)
    ^bb3(%33: i64):  // 2 preds: ^bb2, ^bb4
      %34 = llvm.icmp "slt" %33, %25 : i64
      llvm.cond_br %34, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      %35 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %36 = llvm.mlir.constant(1000 : index) : i64
      %37 = llvm.mul %30, %36 overflow<nsw, nuw> : i64
      %38 = llvm.add %37, %33 overflow<nsw, nuw> : i64
      %39 = llvm.getelementptr inbounds|nuw %35[%38] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %40 = llvm.load %39 : !llvm.ptr -> f32
      %41 = llvm.fmul %arg9, %40 : f32
      %42 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %43 = llvm.mlir.constant(1000 : index) : i64
      %44 = llvm.mul %31, %43 overflow<nsw, nuw> : i64
      %45 = llvm.add %44, %33 overflow<nsw, nuw> : i64
      %46 = llvm.getelementptr inbounds|nuw %42[%45] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %47 = llvm.load %46 : !llvm.ptr -> f32
      %48 = llvm.fmul %41, %47 : f32
      %49 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %50 = llvm.mlir.constant(1000 : index) : i64
      %51 = llvm.mul %30, %50 overflow<nsw, nuw> : i64
      %52 = llvm.add %51, %31 overflow<nsw, nuw> : i64
      %53 = llvm.getelementptr inbounds|nuw %49[%52] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %54 = llvm.load %53 : !llvm.ptr -> f32
      %55 = llvm.fadd %54, %48 : f32
      %56 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %57 = llvm.mlir.constant(1000 : index) : i64
      %58 = llvm.mul %30, %57 overflow<nsw, nuw> : i64
      %59 = llvm.add %58, %31 overflow<nsw, nuw> : i64
      %60 = llvm.getelementptr inbounds|nuw %56[%59] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %55, %60 : f32, !llvm.ptr
      %61 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %62 = llvm.mlir.constant(1000 : index) : i64
      %63 = llvm.mul %30, %62 overflow<nsw, nuw> : i64
      %64 = llvm.add %63, %33 overflow<nsw, nuw> : i64
      %65 = llvm.getelementptr inbounds|nuw %61[%64] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %66 = llvm.load %65 : !llvm.ptr -> f32
      %67 = llvm.fmul %arg9, %66 : f32
      %68 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %69 = llvm.mlir.constant(1000 : index) : i64
      %70 = llvm.mul %31, %69 overflow<nsw, nuw> : i64
      %71 = llvm.add %70, %33 overflow<nsw, nuw> : i64
      %72 = llvm.getelementptr inbounds|nuw %68[%71] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %73 = llvm.load %72 : !llvm.ptr -> f32
      %74 = llvm.fmul %67, %73 : f32
      %75 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %76 = llvm.mlir.constant(1000 : index) : i64
      %77 = llvm.mul %30, %76 overflow<nsw, nuw> : i64
      %78 = llvm.add %77, %31 overflow<nsw, nuw> : i64
      %79 = llvm.getelementptr inbounds|nuw %75[%78] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %80 = llvm.load %79 : !llvm.ptr -> f32
      %81 = llvm.fadd %80, %74 : f32
      %82 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %83 = llvm.mlir.constant(1000 : index) : i64
      %84 = llvm.mul %30, %83 overflow<nsw, nuw> : i64
      %85 = llvm.add %84, %31 overflow<nsw, nuw> : i64
      %86 = llvm.getelementptr inbounds|nuw %82[%85] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %81, %86 : f32, !llvm.ptr
      %87 = llvm.add %33, %24 : i64
      llvm.br ^bb3(%87 : i64)
    ^bb5:  // pred: ^bb3
      %88 = llvm.add %31, %24 : i64
      llvm.br ^bb1(%88 : i64)
    ^bb6:  // pred: ^bb1
      llvm.return
    }
  }
  gpu.module @kernel_syr2k_kernel_2 [#nvvm.target<chip = "sm_61">] {
    llvm.func @kernel_syr2k_kernel(%arg0: i64, %arg1: i64, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: f32, %arg10: !llvm.ptr, %arg11: !llvm.ptr, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: !llvm.ptr, %arg18: !llvm.ptr, %arg19: i64, %arg20: i64, %arg21: i64, %arg22: i64, %arg23: i64) attributes {gpu.kernel, gpu.known_block_size = array<i32: 1, 1, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 1, 1, 1>} {
      %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %1 = llvm.insertvalue %arg17, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %2 = llvm.insertvalue %arg18, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %3 = llvm.insertvalue %arg19, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %4 = llvm.insertvalue %arg20, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %5 = llvm.insertvalue %arg22, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %6 = llvm.insertvalue %arg21, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %7 = llvm.insertvalue %arg23, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %9 = llvm.insertvalue %arg10, %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %10 = llvm.insertvalue %arg11, %9[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %11 = llvm.insertvalue %arg12, %10[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %12 = llvm.insertvalue %arg13, %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %13 = llvm.insertvalue %arg15, %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %14 = llvm.insertvalue %arg14, %13[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %15 = llvm.insertvalue %arg16, %14[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %16 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %17 = llvm.insertvalue %arg2, %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %18 = llvm.insertvalue %arg3, %17[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %19 = llvm.insertvalue %arg4, %18[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %20 = llvm.insertvalue %arg5, %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %21 = llvm.insertvalue %arg7, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %22 = llvm.insertvalue %arg6, %21[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %23 = llvm.insertvalue %arg8, %22[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %24 = llvm.mlir.constant(1 : index) : i64
      %25 = llvm.mlir.constant(1000 : index) : i64
      %26 = llvm.mlir.constant(0 : index) : i64
      %27 = nvvm.read.ptx.sreg.ctaid.x : i32
      %28 = llvm.sext %27 : i32 to i64
      %29 = llvm.mul %28, %arg0 overflow<nsw> : i64
      %30 = llvm.add %29, %arg1 : i64
      llvm.br ^bb1(%26 : i64)
    ^bb1(%31: i64):  // 2 preds: ^bb0, ^bb5
      %32 = llvm.icmp "slt" %31, %25 : i64
      llvm.cond_br %32, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      llvm.br ^bb3(%26 : i64)
    ^bb3(%33: i64):  // 2 preds: ^bb2, ^bb4
      %34 = llvm.icmp "slt" %33, %25 : i64
      llvm.cond_br %34, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      %35 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %36 = llvm.mlir.constant(1000 : index) : i64
      %37 = llvm.mul %30, %36 overflow<nsw, nuw> : i64
      %38 = llvm.add %37, %33 overflow<nsw, nuw> : i64
      %39 = llvm.getelementptr inbounds|nuw %35[%38] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %40 = llvm.load %39 : !llvm.ptr -> f32
      %41 = llvm.fmul %arg9, %40 : f32
      %42 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %43 = llvm.mlir.constant(1000 : index) : i64
      %44 = llvm.mul %31, %43 overflow<nsw, nuw> : i64
      %45 = llvm.add %44, %33 overflow<nsw, nuw> : i64
      %46 = llvm.getelementptr inbounds|nuw %42[%45] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %47 = llvm.load %46 : !llvm.ptr -> f32
      %48 = llvm.fmul %41, %47 : f32
      %49 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %50 = llvm.mlir.constant(1000 : index) : i64
      %51 = llvm.mul %30, %50 overflow<nsw, nuw> : i64
      %52 = llvm.add %51, %31 overflow<nsw, nuw> : i64
      %53 = llvm.getelementptr inbounds|nuw %49[%52] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %54 = llvm.load %53 : !llvm.ptr -> f32
      %55 = llvm.fadd %54, %48 : f32
      %56 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %57 = llvm.mlir.constant(1000 : index) : i64
      %58 = llvm.mul %30, %57 overflow<nsw, nuw> : i64
      %59 = llvm.add %58, %31 overflow<nsw, nuw> : i64
      %60 = llvm.getelementptr inbounds|nuw %56[%59] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %55, %60 : f32, !llvm.ptr
      %61 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %62 = llvm.mlir.constant(1000 : index) : i64
      %63 = llvm.mul %30, %62 overflow<nsw, nuw> : i64
      %64 = llvm.add %63, %33 overflow<nsw, nuw> : i64
      %65 = llvm.getelementptr inbounds|nuw %61[%64] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %66 = llvm.load %65 : !llvm.ptr -> f32
      %67 = llvm.fmul %arg9, %66 : f32
      %68 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %69 = llvm.mlir.constant(1000 : index) : i64
      %70 = llvm.mul %31, %69 overflow<nsw, nuw> : i64
      %71 = llvm.add %70, %33 overflow<nsw, nuw> : i64
      %72 = llvm.getelementptr inbounds|nuw %68[%71] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %73 = llvm.load %72 : !llvm.ptr -> f32
      %74 = llvm.fmul %67, %73 : f32
      %75 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %76 = llvm.mlir.constant(1000 : index) : i64
      %77 = llvm.mul %30, %76 overflow<nsw, nuw> : i64
      %78 = llvm.add %77, %31 overflow<nsw, nuw> : i64
      %79 = llvm.getelementptr inbounds|nuw %75[%78] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %80 = llvm.load %79 : !llvm.ptr -> f32
      %81 = llvm.fadd %80, %74 : f32
      %82 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %83 = llvm.mlir.constant(1000 : index) : i64
      %84 = llvm.mul %30, %83 overflow<nsw, nuw> : i64
      %85 = llvm.add %84, %31 overflow<nsw, nuw> : i64
      %86 = llvm.getelementptr inbounds|nuw %82[%85] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %81, %86 : f32, !llvm.ptr
      %87 = llvm.add %33, %24 : i64
      llvm.br ^bb3(%87 : i64)
    ^bb5:  // pred: ^bb3
      %88 = llvm.add %31, %24 : i64
      llvm.br ^bb1(%88 : i64)
    ^bb6:  // pred: ^bb1
      llvm.return
    }
  }
}

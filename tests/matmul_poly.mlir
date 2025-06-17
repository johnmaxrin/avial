module attributes {dlti.dl_spec = #dlti.dl_spec<#dlti.dl_entry<i16, dense<16> : vector<2xi32>>, #dlti.dl_entry<i32, dense<32> : vector<2xi32>>, #dlti.dl_entry<i1, dense<8> : vector<2xi32>>, #dlti.dl_entry<i8, dense<8> : vector<2xi32>>, #dlti.dl_entry<f64, dense<64> : vector<2xi32>>, #dlti.dl_entry<f128, dense<128> : vector<2xi32>>, #dlti.dl_entry<f16, dense<16> : vector<2xi32>>, #dlti.dl_entry<i64, dense<64> : vector<2xi32>>, #dlti.dl_entry<i128, dense<128> : vector<2xi32>>, #dlti.dl_entry<!llvm.ptr, dense<64> : vector<4xi32>>, #dlti.dl_entry<"dlti.endianness", "little">, #dlti.dl_entry<"dlti.stack_alignment", 128 : i32>>, llvm.data_layout = "e-m:o-i64:64-i128:128-n32:64-S128", llvm.target_triple = "arm64-apple-macosx15.0.0", "polygeist.target-cpu" = "apple-m1", "polygeist.target-features" = "+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz"} {
  func.func @_Z10cpu_matmulPolyPA400_fPA300_fS2_(%arg0: memref<?x400xf32>, %arg1: memref<?x300xf32>, %arg2: memref<?x300xf32>) attributes {llvm.linkage = #llvm.linkage<external>} {
    %c200 = arith.constant 200 : index
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c300 = arith.constant 300 : index
    %c400 = arith.constant 400 : index
    scf.for %arg3 = %c0 to %c200 step %c1 {
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
    }
    return
  }
}

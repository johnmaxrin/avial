module attributes {dlti.dl_spec = #dlti.dl_spec<#dlti.dl_entry<!llvm.ptr, dense<64> : vector<4xi32>>, #dlti.dl_entry<i64, dense<64> : vector<2xi32>>, #dlti.dl_entry<i128, dense<128> : vector<2xi32>>, #dlti.dl_entry<f16, dense<16> : vector<2xi32>>, #dlti.dl_entry<f64, dense<64> : vector<2xi32>>, #dlti.dl_entry<f128, dense<128> : vector<2xi32>>, #dlti.dl_entry<i8, dense<8> : vector<2xi32>>, #dlti.dl_entry<i1, dense<8> : vector<2xi32>>, #dlti.dl_entry<i32, dense<32> : vector<2xi32>>, #dlti.dl_entry<i16, dense<16> : vector<2xi32>>, #dlti.dl_entry<"dlti.stack_alignment", 128 : i32>, #dlti.dl_entry<"dlti.endianness", "little">>, llvm.data_layout = "e-m:o-i64:64-i128:128-n32:64-S128", llvm.target_triple = "arm64-apple-macosx16.0.0", "polygeist.target-cpu" = "apple-m1", "polygeist.target-features" = "+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz"} {
  func.func @kernel_gesummv(%arg0: i32, %arg1: f32, %arg2: f32, %arg3: memref<?x200xf32>, %arg4: memref<?x200xf32>, %arg5: memref<?xf32>, %arg6: memref<?xf32>, %arg7: memref<?xf32>) attributes {llvm.linkage = #llvm.linkage<external>} {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg8 = 0 to 200 {
      affine.store %cst, %arg5[%arg8] : memref<?xf32>
      affine.store %cst, %arg7[%arg8] : memref<?xf32>
      affine.for %arg9 = 0 to 200 {
        %5 = affine.load %arg3[%arg8, %arg9] : memref<?x200xf32>
        %6 = affine.load %arg6[%arg9] : memref<?xf32>
        %7 = arith.mulf %5, %6 : f32
        %8 = affine.load %arg5[%arg8] : memref<?xf32>
        %9 = arith.addf %7, %8 : f32
        affine.store %9, %arg5[%arg8] : memref<?xf32>
        %10 = affine.load %arg4[%arg8, %arg9] : memref<?x200xf32>
        %11 = affine.load %arg6[%arg9] : memref<?xf32>
        %12 = arith.mulf %10, %11 : f32
        %13 = affine.load %arg7[%arg8] : memref<?xf32>
        %14 = arith.addf %12, %13 : f32
        affine.store %14, %arg7[%arg8] : memref<?xf32>
      }
      %0 = affine.load %arg5[%arg8] : memref<?xf32>
      %1 = arith.mulf %arg1, %0 : f32
      %2 = affine.load %arg7[%arg8] : memref<?xf32>
      %3 = arith.mulf %arg2, %2 : f32
      %4 = arith.addf %1, %3 : f32
      affine.store %4, %arg7[%arg8] : memref<?xf32>
    }
    return
  }
}

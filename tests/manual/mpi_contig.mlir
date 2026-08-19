// a row slice of a row-major array is contiguous
// (strides [8,1] over dims [2,8]), so --lower-to-llvm must
// accept it and emit the full 2*8 = 16 element count.
module attributes {dlti.dl_spec = #dlti.dl_spec<"MPI:Implementation" = "OpenMPI">} {
  func.func @contig(%buf: memref<8x8xf32>) {
    %tag = arith.constant 0 : i32
    %dst = arith.constant 1 : i32
    %comm = mpi.comm_world : !mpi.comm
    %sv = memref.subview %buf[0, 0] [2, 8] [1, 1]
        : memref<8x8xf32> to memref<2x8xf32, strided<[8, 1]>>
    %r = mpi.send(%sv, %tag, %dst, %comm)
        : memref<2x8xf32, strided<[8, 1]>>, i32, i32 -> !mpi.retval
    return
  }
}

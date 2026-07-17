#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_syrk(int32_t N, int32_t M, double alpha, double beta,
                        double *C_alloc, double *C_aligned, int64_t C_offset,
                        int64_t C_size0, int64_t C_size1, int64_t C_stride0,
                        int64_t C_stride1, double *A_alloc, double *A_aligned,
                        int64_t A_offset, int64_t A_size0, int64_t A_size1,
                        int64_t A_stride0, int64_t A_stride1);
#ifdef __cplusplus
}
#endif

extern "C" {

// Custom trace function to print the call stack
void print_trace() {
  void *array[10];
  int size = backtrace(array, 10);
  backtrace_symbols_fd(array, size, fileno(stdout));
}

} // extern "C"

int main(int argc, char **argv) {
  int rank = 0, size = 0;

  // NOTE: reduced from the original file's EXTRALARGE PolyBench dims
  // (N=2600, M=2000) to LARGE (N=1000, M=1200) for faster iteration.
  // If you rebuild the .mlir with the original 2600/2000 bounds, update
  // these to match -- the driver's N/M must equal the hardcoded affine
  // bounds in the .mlir, since arg0/arg1 aren't used to size the loops.
  int N = 1000, M = 1200;
  double alpha = 1.5, beta = 1.2;

  // C: N x N (only lower triangle is read/written by the kernel)
  // A: N x M
  double *C = (double *)aligned_alloc(64, (size_t)N * N * sizeof(double));
  double *A = (double *)aligned_alloc(64, (size_t)N * M * sizeof(double));

  for (size_t i = 0; i < (size_t)N * N; i++)
    C[i] = 1.0;
  for (size_t i = 0; i < (size_t)N * M; i++)
    A[i] = 1.0;

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_syrk(N, M, alpha, beta, C, C, 0, N, N, N, 1, A, A, 0, N, M, M, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("syrk kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<N*N; ++i)
    //     {
    //             printf("%f\n", C[i]);
    //     }
  }

  free(C);
  free(A);
  MPI_Finalize();
  return 0;
}

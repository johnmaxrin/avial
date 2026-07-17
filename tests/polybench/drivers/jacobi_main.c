#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_jacobi(int32_t TSTEPS, int32_t N, float *A_alloc,
                          float *A_aligned, int64_t A_offset, int64_t A_size0,
                          int64_t A_stride0, float *B_alloc, float *B_aligned,
                          int64_t B_offset, int64_t B_size0, int64_t B_stride0);
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

  // A, B: size N (must be >= 1000; kernel's inner loop hardcodes bound 999)
  int N = 1000;
  int TSTEPS =
      10000; // unused by kernel body (loop bound hardcoded), kept for signature

  float *A = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *B = (float *)aligned_alloc(64, (size_t)N * sizeof(float));

  // Standard PolyBench jacobi-1d init pattern
  for (int i = 0; i < N; i++) {
    A[i] = ((float)(i + 2)) / N;
    B[i] = ((float)(i + 3)) / N;
  }

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_jacobi(TSTEPS, N, A, A, 0, N, 1, B, B, 0, N, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("jacobi kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<N; ++i)
    //     {
    //             printf("%f\n", A[i]);
    //     }
  }

  free(A);
  free(B);
  MPI_Finalize();
  return 0;
}

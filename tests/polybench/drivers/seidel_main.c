#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_seidel_2d(int32_t TSTEPS, int32_t N, float *A_alloc,
                             float *A_aligned, int64_t A_offset,
                             int64_t A_size0, int64_t A_size1,
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

  // A: N x N, updated in-place (Gauss-Seidel: no separate output buffer)
  int N = 128;
  int TSTEPS =
      20; // unused by kernel body (loop bound hardcoded), kept for signature

  float *A = (float *)aligned_alloc(64, (size_t)N * N * sizeof(float));

  // Standard PolyBench seidel-2d init pattern
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      A[i * N + j] = ((float)(i * (j + 2) + 2)) / N;
    }
  }

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_seidel_2d(TSTEPS, N, A, A, 0, N, N, N, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("seidel_2d kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<N*N; ++i)
    //     {
    //             printf("%f\n", A[i]);
    //     }
  }

  free(A);
  MPI_Finalize();
  return 0;
}

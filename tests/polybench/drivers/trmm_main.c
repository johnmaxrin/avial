#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_trmm(int32_t N, float alpha, float *A_alloc,
                        float *A_aligned, int64_t A_offset, int64_t A_size0,
                        int64_t A_size1, int64_t A_stride0, int64_t A_stride1,
                        float *B_alloc, float *B_aligned, int64_t B_offset,
                        int64_t B_size0, int64_t B_size1, int64_t B_stride0,
                        int64_t B_stride1);
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

  // A: N x N, treated as lower-triangular (only entries A[i][k], k<i, are ever
  // read) B: N x N, updated in-place; row 0 of B is never touched by the kernel
  // (see notes)
  int N = 1000;
  float alpha = 1.5f;

  float *A = (float *)aligned_alloc(64, (size_t)N * N * sizeof(float));
  float *B = (float *)aligned_alloc(64, (size_t)N * N * sizeof(float));

  // Only the strictly-lower triangle of A (k < i) is ever read by the kernel;
  // diagonal and upper entries are never accessed, but filled in for
  // completeness/cleanliness.
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      A[i * N + j] = (j < i) ? 0.5f : ((j == i) ? 1.0f : 0.0f);
    }
  }
  for (size_t i = 0; i < (size_t)N * N; i++)
    B[i] = 1.0f;

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_trmm(N, alpha, A, A, 0, N, N, N, 1, B, B, 0, N, N, N, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("trmm kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<N*N; ++i)
    //     {
    //             printf("%f\n", B[i]);
    //     }
  }

  free(A);
  free(B);
  MPI_Finalize();
  return 0;
}

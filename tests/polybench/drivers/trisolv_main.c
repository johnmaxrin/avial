#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_trisolv(int32_t N, float *L_alloc, float *L_aligned,
                           int64_t L_offset, int64_t L_size0, int64_t L_size1,
                           int64_t L_stride0, int64_t L_stride1, float *x_alloc,
                           float *x_aligned, int64_t x_offset, int64_t x_size0,
                           int64_t x_stride0, float *b_alloc, float *b_aligned,
                           int64_t b_offset, int64_t b_size0,
                           int64_t b_stride0);
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

  // L: N x N lower-triangular (diagonal MUST be non-zero, see below), x, b: N
  int N = 1000;

  float *L = (float *)aligned_alloc(64, (size_t)N * N * sizeof(float));
  float *x = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *b = (float *)aligned_alloc(64, (size_t)N * sizeof(float));

  // L must be lower-triangular with a nonzero diagonal, since the kernel
  // divides by L[i][i] for every i -- a zero (or near-zero) diagonal entry
  // produces inf/nan that then poisons every x[j] for j > i.
  for (int i = 0; i < N; i++) {
    for (int j = 0; j <= i; j++) {
      L[i * N + j] = (i == j) ? 2.0f : 0.5f;
    }
    // strictly-upper entries are never read by the kernel (loop only
    // ever accesses L[i][j] for j <= i), but zero them for cleanliness
    for (int j = i + 1; j < N; j++) {
      L[i * N + j] = 0.0f;
    }
  }
  for (size_t i = 0; i < (size_t)N; i++)
    b[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    x[i] = 0.0f; // x is fully overwritten before use each iter, init for
                 // cleanliness

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_trisolv(N, L, L, 0, N, N, N, 1, x, x, 0, N, 1, b, b, 0, N, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("trisolv kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<N; ++i)
    //     {
    //             printf("%f\n", x[i]);
    //     }
  }

  free(L);
  free(x);
  free(b);
  MPI_Finalize();
  return 0;
}

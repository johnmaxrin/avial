#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_mvt(int32_t N, float *x1_alloc, float *x1_aligned,
                       int64_t x1_offset, int64_t x1_size0, int64_t x1_stride0,
                       float *x2_alloc, float *x2_aligned, int64_t x2_offset,
                       int64_t x2_size0, int64_t x2_stride0, float *y1_alloc,
                       float *y1_aligned, int64_t y1_offset, int64_t y1_size0,
                       int64_t y1_stride0, float *y2_alloc, float *y2_aligned,
                       int64_t y2_offset, int64_t y2_size0, int64_t y2_stride0,
                       float *A_alloc, float *A_aligned, int64_t A_offset,
                       int64_t A_size0, int64_t A_size1, int64_t A_stride0,
                       int64_t A_stride1);
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

  // x1, x2, y1, y2: N; A: N x N
  int N = 128;

  float *x1 = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *x2 = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *y1 = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *y2 = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *A = (float *)aligned_alloc(64, (size_t)N * N * sizeof(float));

  // x1/x2 are accumulated onto their initial values (real mvt semantics,
  // not a missing-zero bug) -- seed with a defined value, not necessarily zero.
  for (size_t i = 0; i < (size_t)N; i++)
    x1[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    x2[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    y1[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    y2[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N * N; i++)
    A[i] = 1.0f;

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_mvt(N, x1, x1, 0, N, 1, x2, x2, 0, N, 1, y1, y1, 0, N, 1, y2, y2, 0, N,
             1, A, A, 0, N, N, N, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("mvt kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<N; ++i)
    //     {
    //             printf("%f\n", x1[i]);
    //     }
  }

  free(x1);
  free(x2);
  free(y1);
  free(y2);
  free(A);
  MPI_Finalize();
  return 0;
}

#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_atax(int32_t N, int32_t M, float *A_alloc, float *A_aligned,
                        int64_t A_offset, int64_t A_size0, int64_t A_size1,
                        int64_t A_stride0, int64_t A_stride1, float *x_alloc,
                        float *x_aligned, int64_t x_offset, int64_t x_size0,
                        int64_t x_stride0, float *y_alloc, float *y_aligned,
                        int64_t y_offset, int64_t y_size0, int64_t y_stride0,
                        float *tmp_alloc, float *tmp_aligned,
                        int64_t tmp_offset, int64_t tmp_size0,
                        int64_t tmp_stride0);
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

  // A: N x M, x: M, y: M, tmp: N
  int N = 128, M = 128;

  float *A = (float *)aligned_alloc(64, (size_t)N * M * sizeof(float));
  float *x = (float *)aligned_alloc(64, (size_t)M * sizeof(float));
  float *y = (float *)aligned_alloc(64, (size_t)M * sizeof(float));
  float *tmp = (float *)aligned_alloc(64, (size_t)N * sizeof(float));

  for (size_t i = 0; i < (size_t)N * M; i++)
    A[i] = 1.0f;
  for (size_t i = 0; i < (size_t)M; i++)
    x[i] = 1.0f;
  for (size_t i = 0; i < (size_t)M; i++)
    y[i] = 0.0f; // must be zeroed: kernel accumulates into y
  for (size_t i = 0; i < (size_t)N; i++)
    tmp[i] = 0.0f; // must be zeroed: kernel accumulates into tmp

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_atax(N, M, A, A, 0, N, M, M, 1, x, x, 0, M, 1, y, y, 0, M, 1, tmp, tmp,
              0, N, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("atax kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<M; ++i)
    //     {
    //             printf("%f\n", y[i]);
    //     }
  }

  free(A);
  free(x);
  free(y);
  free(tmp);
  MPI_Finalize();
  return 0;
}

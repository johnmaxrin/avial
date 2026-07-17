#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_gesummv(
    int32_t N, float alpha, float beta, float *A_alloc, float *A_aligned,
    int64_t A_offset, int64_t A_size0, int64_t A_size1, int64_t A_stride0,
    int64_t A_stride1, float *B_alloc, float *B_aligned, int64_t B_offset,
    int64_t B_size0, int64_t B_size1, int64_t B_stride0, int64_t B_stride1,
    float *tmp_alloc, float *tmp_aligned, int64_t tmp_offset, int64_t tmp_size0,
    int64_t tmp_stride0, float *x_alloc, float *x_aligned, int64_t x_offset,
    int64_t x_size0, int64_t x_stride0, float *y_alloc, float *y_aligned,
    int64_t y_offset, int64_t y_size0, int64_t y_stride0);
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

  // A, B: N x N, tmp, x, y: N
  int N = 200;
  float alpha = 1.5f, beta = 1.2f;

  float *A = (float *)aligned_alloc(64, (size_t)N * N * sizeof(float));
  float *B = (float *)aligned_alloc(64, (size_t)N * N * sizeof(float));
  float *tmp = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *x = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *y = (float *)aligned_alloc(64, (size_t)N * sizeof(float));

  for (size_t i = 0; i < (size_t)N * N; i++)
    A[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N * N; i++)
    B[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    tmp[i] = 0.0f; // kernel zeroes this itself, init for cleanliness
  for (size_t i = 0; i < (size_t)N; i++)
    x[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    y[i] = 0.0f; // kernel zeroes this itself, init for cleanliness

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_gesummv(N, alpha, beta, A, A, 0, N, N, N, 1, B, B, 0, N, N, N, 1, tmp,
                 tmp, 0, N, 1, x, x, 0, N, 1, y, y, 0, N, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("gesummv kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<N; ++i)
    //     {
    //             printf("%f\n", y[i]);
    //     }
  }

  free(A);
  free(B);
  free(tmp);
  free(x);
  free(y);
  MPI_Finalize();
  return 0;
}

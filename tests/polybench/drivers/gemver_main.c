#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_gemver(
    int32_t N, float alpha, float beta, float *A_alloc, float *A_aligned,
    int64_t A_offset, int64_t A_size0, int64_t A_size1, int64_t A_stride0,
    int64_t A_stride1, float *u1_alloc, float *u1_aligned, int64_t u1_offset,
    int64_t u1_size0, int64_t u1_stride0, float *v1_alloc, float *v1_aligned,
    int64_t v1_offset, int64_t v1_size0, int64_t v1_stride0, float *u2_alloc,
    float *u2_aligned, int64_t u2_offset, int64_t u2_size0, int64_t u2_stride0,
    float *v2_alloc, float *v2_aligned, int64_t v2_offset, int64_t v2_size0,
    int64_t v2_stride0, float *w_alloc, float *w_aligned, int64_t w_offset,
    int64_t w_size0, int64_t w_stride0, float *x_alloc, float *x_aligned,
    int64_t x_offset, int64_t x_size0, int64_t x_stride0, float *y_alloc,
    float *y_aligned, int64_t y_offset, int64_t y_size0, int64_t y_stride0,
    float *z_alloc, float *z_aligned, int64_t z_offset, int64_t z_size0,
    int64_t z_stride0);
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

  // A: N x N, u1/v1/u2/v2/w/x/y/z: N
  int N = 200;
  float alpha = 1.5f, beta = 1.2f;

  float *A = (float *)aligned_alloc(64, (size_t)N * N * sizeof(float));
  float *u1 = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *v1 = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *u2 = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *v2 = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *w = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *x = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *y = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *z = (float *)aligned_alloc(64, (size_t)N * sizeof(float));

  for (size_t i = 0; i < (size_t)N * N; i++)
    A[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    u1[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    v1[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    u2[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    v2[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    w[i] = 0.0f; // must be zeroed: kernel accumulates into w, never resets it
  for (size_t i = 0; i < (size_t)N; i++)
    x[i] = 0.0f; // must be zeroed: kernel accumulates into x, never resets it
  for (size_t i = 0; i < (size_t)N; i++)
    y[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    z[i] = 1.0f;

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_gemver(N, alpha, beta, A, A, 0, N, N, N, 1, u1, u1, 0, N, 1, v1, v1, 0,
                N, 1, u2, u2, 0, N, 1, v2, v2, 0, N, 1, w, w, 0, N, 1, x, x, 0,
                N, 1, y, y, 0, N, 1, z, z, 0, N, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("gemver kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<N; ++i)
    //     {
    //             printf("%f\n", w[i]);
    //     }
  }

  free(A);
  free(u1);
  free(v1);
  free(u2);
  free(v2);
  free(w);
  free(x);
  free(y);
  free(z);
  MPI_Finalize();
  return 0;
}

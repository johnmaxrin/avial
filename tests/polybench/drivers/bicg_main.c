#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_bicg(int32_t M, int32_t N, float *A_alloc, float *A_aligned,
                        int64_t A_offset, int64_t A_size0, int64_t A_size1,
                        int64_t A_stride0, int64_t A_stride1, float *s_alloc,
                        float *s_aligned, int64_t s_offset, int64_t s_size0,
                        int64_t s_stride0, float *q_alloc, float *q_aligned,
                        int64_t q_offset, int64_t q_size0, int64_t q_stride0,
                        float *p_alloc, float *p_aligned, int64_t p_offset,
                        int64_t p_size0, int64_t p_stride0, float *r_alloc,
                        float *r_aligned, int64_t r_offset, int64_t r_size0,
                        int64_t r_stride0);
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

  // A: N x M, s: M, q: N, p: M, r: N
  int N = 1000, M = 1000;

  float *A = (float *)aligned_alloc(64, (size_t)N * M * sizeof(float));
  float *s = (float *)aligned_alloc(64, (size_t)M * sizeof(float));
  float *q = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
  float *p = (float *)aligned_alloc(64, (size_t)M * sizeof(float));
  float *r = (float *)aligned_alloc(64, (size_t)N * sizeof(float));

  for (size_t i = 0; i < (size_t)N * M; i++)
    A[i] = 1.0f;
  for (size_t i = 0; i < (size_t)M; i++)
    s[i] = 0.0f; // must be zeroed: kernel accumulates into s, never resets it
  for (size_t i = 0; i < (size_t)N; i++)
    q[i] = 0.0f; // kernel zeroes this itself, but init for cleanliness
  for (size_t i = 0; i < (size_t)M; i++)
    p[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N; i++)
    r[i] = 1.0f;

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_bicg(M, N, A, A, 0, N, M, M, 1, s, s, 0, M, 1, q, q, 0, N, 1, p, p, 0,
              M, 1, r, r, 0, N, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("bicg kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<M; ++i)
    //     {
    //             printf("%f\n", s[i]);
    //     }
  }

  free(A);
  free(s);
  free(q);
  free(p);
  free(r);
  MPI_Finalize();
  return 0;
}

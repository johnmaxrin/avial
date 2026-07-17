#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_symm(int32_t M, int32_t N, float alpha, float beta,
                        float *C_alloc, float *C_aligned, int64_t C_offset,
                        int64_t C_size0, int64_t C_size1, int64_t C_stride0,
                        int64_t C_stride1, float *A_alloc, float *A_aligned,
                        int64_t A_offset, int64_t A_size0, int64_t A_size1,
                        int64_t A_stride0, int64_t A_stride1, float *B_alloc,
                        float *B_aligned, int64_t B_offset, int64_t B_size0,
                        int64_t B_size1, int64_t B_stride0, int64_t B_stride1);
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

  // C: N x N (accumulated onto existing values -- real symm semantics, not a
  // bug) A: N x N, should be symmetric per algorithm's assumption (kernel
  // doesn't enforce this itself) B: N x N
  int N = 1000;
  float alpha = 1.5f, beta = 1.2f;

  float *C = (float *)aligned_alloc(64, (size_t)N * N * sizeof(float));
  float *A = (float *)aligned_alloc(64, (size_t)N * N * sizeof(float));
  float *B = (float *)aligned_alloc(64, (size_t)N * N * sizeof(float));

  for (size_t i = 0; i < (size_t)N * N; i++)
    C[i] = 1.0f;
  for (size_t i = 0; i < (size_t)N * N; i++)
    B[i] = 1.0f;

  // A must be symmetric for the algorithm's math to mean anything sensible
  // (the kernel reads both A[i][k] and A[k][i] positions and treats them
  // as equivalent -- it doesn't check symmetry itself, so a non-symmetric
  // A will still "run" but the result won't match a real symm computation).
  for (int i = 0; i < N; i++) {
    for (int j = 0; j <= i; j++) {
      float v = 1.0f;
      A[i * N + j] = v;
      A[j * N + i] = v;
    }
  }

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_symm(N, N, alpha, beta, C, C, 0, N, N, N, 1, A, A, 0, N, N, N, 1, B, B,
              0, N, N, N, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("symm kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<N*N; ++i)
    //     {
    //             printf("%f\n", C[i]);
    //     }
  }

  free(C);
  free(A);
  free(B);
  MPI_Finalize();
  return 0;
}

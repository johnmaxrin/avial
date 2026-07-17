#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void matadd(int32_t M, int32_t N, float *A_alloc, float *A_aligned,
                   int64_t A_offset, int64_t A_size0, int64_t A_size1,
                   int64_t A_stride0, int64_t A_stride1, float *B_alloc,
                   float *B_aligned, int64_t B_offset, int64_t B_size0,
                   int64_t B_size1, int64_t B_stride0, int64_t B_stride1,
                   float *C_alloc, float *C_aligned, int64_t C_offset,
                   int64_t C_size0, int64_t C_size1, int64_t C_stride0,
                   int64_t C_stride1);
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
  int M = 1000, N = 1000;
  float *A = (float *)aligned_alloc(64, M * N * sizeof(float));
  float *B = (float *)aligned_alloc(64, M * N * sizeof(float));
  float *C = (float *)aligned_alloc(64, M * N * sizeof(float));

  for (int i = 0; i < M * N; i++)
    A[i] = 1.0f;
  for (int i = 0; i < M * N; i++)
    B[i] = 2.0f;
  for (int i = 0; i < M * N; i++)
    C[i] = 0.0f;
  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  matadd(M, N, A, A, 0, M, N, N, 1, B, B, 0, M, N, N, 1, C, C, 0, M, N, N, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("Matrix addition time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<M*N; ++i)
    //     {
    //             printf("%f\n", C[i]);
    //     }
  }

  free(A);
  free(B);
  free(C);
  MPI_Finalize();
  return 0;
}

#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_2mm(
    int32_t NI, int32_t NJ, int32_t NK, int32_t NL, float alpha, float beta,
    float *tmp_alloc, float *tmp_aligned, int64_t tmp_offset, int64_t tmp_size0,
    int64_t tmp_size1, int64_t tmp_stride0, int64_t tmp_stride1, float *A_alloc,
    float *A_aligned, int64_t A_offset, int64_t A_size0, int64_t A_size1,
    int64_t A_stride0, int64_t A_stride1, float *B_alloc, float *B_aligned,
    int64_t B_offset, int64_t B_size0, int64_t B_size1, int64_t B_stride0,
    int64_t B_stride1, float *C_alloc, float *C_aligned, int64_t C_offset,
    int64_t C_size0, int64_t C_size1, int64_t C_stride0, int64_t C_stride1,
    float *D_alloc, float *D_aligned, int64_t D_offset, int64_t D_size0,
    int64_t D_size1, int64_t D_stride0, int64_t D_stride1);
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

  // Dimensions: tmp is NI x NJ, A is NI x NK, B is NK x NJ, C is NJ x NL, D is
  // NI x NL
  int NI = 1000, NJ = 1000, NK = 1000, NL = 1000;
  float alpha = 1.5f, beta = 1.2f;

  float *tmp = (float *)aligned_alloc(64, (size_t)NI * NJ * sizeof(float));
  float *A = (float *)aligned_alloc(64, (size_t)NI * NK * sizeof(float));
  float *B = (float *)aligned_alloc(64, (size_t)NK * NJ * sizeof(float));
  float *C = (float *)aligned_alloc(64, (size_t)NJ * NL * sizeof(float));
  float *D = (float *)aligned_alloc(64, (size_t)NI * NL * sizeof(float));

  for (size_t i = 0; i < (size_t)NI * NJ; i++)
    tmp[i] = 0.0f;
  for (size_t i = 0; i < (size_t)NI * NK; i++)
    A[i] = 1.0f;
  for (size_t i = 0; i < (size_t)NK * NJ; i++)
    B[i] = 1.0f;
  for (size_t i = 0; i < (size_t)NJ * NL; i++)
    C[i] = 1.0f;
  for (size_t i = 0; i < (size_t)NI * NL; i++)
    D[i] = 1.0f;

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_2mm(NI, NJ, NK, NL, alpha, beta, tmp, tmp, 0, NI, NJ, NJ, 1, A, A, 0,
             NI, NK, NK, 1, B, B, 0, NK, NJ, NJ, 1, C, C, 0, NJ, NL, NL, 1, D,
             D, 0, NI, NL, NL, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("2mm kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<NI*NL; ++i)
    //     {
    //             printf("%f\n", D[i]);
    //     }
  }

  free(tmp);
  free(A);
  free(B);
  free(C);
  free(D);
  MPI_Finalize();
  return 0;
}

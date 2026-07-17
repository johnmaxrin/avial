#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void
kernel_doitgen(int32_t NR, int32_t NQ, int32_t NP, float *A_alloc,
               float *A_aligned, int64_t A_offset, int64_t A_size0,
               int64_t A_size1, int64_t A_size2, int64_t A_stride0,
               int64_t A_stride1, int64_t A_stride2, float *C4_alloc,
               float *C4_aligned, int64_t C4_offset, int64_t C4_size0,
               int64_t C4_size1, int64_t C4_stride0, int64_t C4_stride1,
               float *sum_alloc, float *sum_aligned, int64_t sum_offset,
               int64_t sum_size0, int64_t sum_size1, int64_t sum_size2,
               int64_t sum_stride0, int64_t sum_stride1, int64_t sum_stride2);
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

  // A: NR x NQ x NP, C4: NP x NP, sum: NR x NQ x NP (same shape as A)
  int NR = 128, NQ = 128, NP = 128;

  float *A = (float *)aligned_alloc(64, (size_t)NR * NQ * NP * sizeof(float));
  float *C4 = (float *)aligned_alloc(64, (size_t)NP * NP * sizeof(float));
  float *sum = (float *)aligned_alloc(64, (size_t)NR * NQ * NP * sizeof(float));

  for (size_t i = 0; i < (size_t)NR * NQ * NP; i++)
    A[i] = 1.0f;
  for (size_t i = 0; i < (size_t)NP * NP; i++)
    C4[i] = 1.0f;
  for (size_t i = 0; i < (size_t)NR * NQ * NP; i++)
    sum[i] = 0.0f; // zeroed: kernel only writes sum for q<64, p<32 — rest read
                   // back into A as-is

  MPI_Init(&argc, &argv);

  // Row-major strides
  int64_t A_stride2 = 1, A_stride1 = NP, A_stride0 = (int64_t)NQ * NP;
  int64_t C4_stride1 = 1, C4_stride0 = NP;
  int64_t sum_stride2 = 1, sum_stride1 = NP, sum_stride0 = (int64_t)NQ * NP;

  double start_time = MPI_Wtime();
  kernel_doitgen(NR, NQ, NP, A, A, 0, NR, NQ, NP, A_stride0, A_stride1,
                 A_stride2, C4, C4, 0, NP, NP, C4_stride0, C4_stride1, sum, sum,
                 0, NR, NQ, NP, sum_stride0, sum_stride1, sum_stride2);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("doitgen kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<NR*NQ*NP; ++i)
    //     {
    //             printf("%f\n", A[i]);
    //     }
  }

  free(A);
  free(C4);
  free(sum);
  MPI_Finalize();
  return 0;
}

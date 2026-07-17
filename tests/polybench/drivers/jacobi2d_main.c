#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_jacobi_2d(int32_t TSTEPS, int32_t N, float *A_alloc,
                             float *A_aligned, int64_t A_offset,
                             int64_t A_size0, int64_t A_size1,
                             int64_t A_stride0, int64_t A_stride1,
                             float *B_alloc, float *B_aligned, int64_t B_offset,
                             int64_t B_size0, int64_t B_size1,
                             int64_t B_stride0, int64_t B_stride1);
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

  // A, B: matching the memref<?x128xf32> type (128 columns)
  // NOTE: kernel body only ever touches rows/cols 1..18 (loop bound "1 to 19"),
  // so this allocation is sized to honestly match the declared type (128 rows x
  // 128 cols), even though most of it goes untouched across all TSTEPS
  // iterations.
  int N_ROWS = 128, N_COLS = 128;
  int TSTEPS =
      300; // unused by kernel body (loop bound hardcoded), kept for signature
  int N = 20; // also unused by kernel body directly, kept for signature

  float *A =
      (float *)aligned_alloc(64, (size_t)N_ROWS * N_COLS * sizeof(float));
  float *B =
      (float *)aligned_alloc(64, (size_t)N_ROWS * N_COLS * sizeof(float));

  // Standard PolyBench jacobi-2d init pattern, scaled by the region size
  // actually touched
  for (int i = 0; i < N_ROWS; i++) {
    for (int j = 0; j < N_COLS; j++) {
      A[i * N_COLS + j] = ((float)i * (j + 2) + 2) / N_COLS;
      B[i * N_COLS + j] = ((float)i * (j + 3) + 3) / N_COLS;
    }
  }

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_jacobi_2d(TSTEPS, N, A, A, 0, N_ROWS, N_COLS, N_COLS, 1, B, B, 0,
                   N_ROWS, N_COLS, N_COLS, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("jacobi_2d kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<N_ROWS*N_COLS; ++i)
    //     {
    //             printf("%f\n", A[i]);
    //     }
  }

  free(A);
  free(B);
  MPI_Finalize();
  return 0;
}

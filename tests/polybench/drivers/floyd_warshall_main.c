#include <execinfo.h>
#include <mpi.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void kernel_floyd_warshall(int32_t N, float *path_alloc,
                                  float *path_aligned, int64_t path_offset,
                                  int64_t path_size0, int64_t path_size1,
                                  int64_t path_stride0, int64_t path_stride1);
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

  // path: N x N adjacency/distance matrix, updated in-place
  int N = 128;

  float *path = (float *)aligned_alloc(64, (size_t)N * N * sizeof(float));

  // Seed with a pattern resembling the PolyBench reference init:
  // finite "edge weight" for most pairs, occasional large sentinel
  // value standing in for "no direct edge" (not IEEE INF, to avoid
  // inf+inf/inf-inf edge cases propagating through the comparisons).
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      float w = (float)((i * j) % 7 + 1);
      if ((i + j) % 13 == 0 || (i + j) % 7 == 0 || (i + j) % 11 == 0) {
        w = 999.0f;
      }
      path[i * N + j] = w;
    }
  }

  MPI_Init(&argc, &argv);

  double start_time = MPI_Wtime();
  kernel_floyd_warshall(N, path, path, 0, N, N, N, 1);
  double end_time = MPI_Wtime();
  double elapsed = end_time - start_time;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Barrier(MPI_COMM_WORLD);
  double max_elapsed;
  MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
  if (rank == 0) {
    printf("floyd_warshall kernel time: %.6f seconds\n", max_elapsed);
    //     for(int i=0; i<N*N; ++i)
    //     {
    //             printf("%f\n", path[i]);
    //     }
  }

  free(path);
  MPI_Finalize();
  return 0;
}

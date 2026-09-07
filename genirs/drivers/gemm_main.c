#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <execinfo.h>


#ifdef __cplusplus
extern "C" {
#endif
extern void matmul(int32_t M, int32_t N, int32_t K,
    float *A_alloc, float *A_aligned,
    int64_t A_offset, int64_t A_size0, int64_t A_size1,
    int64_t A_stride0, int64_t A_stride1,
    float *B_alloc, float *B_aligned,
    int64_t B_offset, int64_t B_size0, int64_t B_size1,
    int64_t B_stride0, int64_t B_stride1,
    float *C_alloc, float *C_aligned,
    int64_t C_offset, int64_t C_size0, int64_t C_size1,
    int64_t C_stride0, int64_t C_stride1);
#ifdef __cplusplus
}
#endif

extern "C" {

// Custom trace function to print the call stack
void print_trace() {
    void* array[10];
    int size = backtrace(array, 10);
    // backtrace_symbols_fd prints directly to stdout
    backtrace_symbols_fd(array, size, fileno(stdout));
}

// Intercepting MPI_Send
// int MPI_Send(const void *buf, int count, MPI_Datatype datatype, int dest, 
//              int tag, MPI_Comm comm) {
    
//     int rank;
//     PMPI_Comm_rank(comm, &rank);

//     // Added %p to display the buffer memory address
//     printf("\n[Rank %d] ---> MPI_Send to dest %d | Tag: %d | Buf: %p <---\n", 
//             rank, dest, tag, buf);
    
//     printf("----------------------------------------------------------\n");

//     return PMPI_Send(buf, count, datatype, dest, tag, comm);
// }

// // Intercepting MPI_Recv
// int MPI_Recv(void *buf, int count, MPI_Datatype datatype, int source, 
//              int tag, MPI_Comm comm, MPI_Status *statusr ) {
    
//     int rank;
//     PMPI_Comm_rank(comm, &rank);

//     // Added %p to display the buffer memory address
//     printf("\n[Rank %d] <--- MPI_Recv from src %d | Tag: %d | Buf: %p ---> Sz: %d\n", 
//             rank, source, tag, buf, count);

//     printf("----------------------------------------------------------\n");

//     return PMPI_Recv(buf, count, datatype, source, tag, comm, status);
// }

} // extern "C"



int main(int argc, char **argv) {
    // MPI_Init(&argc, &argv);
    
    int rank=0, size=0;
    
    
    int M = 1000, K = 1000, N = 1000;
    float *A = (float*) aligned_alloc(64, M*K*sizeof(float));
    float *B = (float*) aligned_alloc(64, K*N*sizeof(float));
    float *C = (float*) aligned_alloc(64, M*N*sizeof(float));
    

    for (int i=0; i<M*K; i++) A[i] = 1.0f;
    for (int i=0; i<K*N; i++) B[i] = 1.0f;
    for (int i=0; i<M*N; i++) C[i] = 0.0f;
    
    MPI_Init(&argc, &argv);

    double start_time = MPI_Wtime(); 
    matmul(M, N, K,
        A, A, 0, M, K, K, 1,        
        B, B, 0, K, N, N, 1,        
        C, C, 0, M, N, N, 1);
    
    double end_time = MPI_Wtime();
    double elapsed = end_time - start_time;

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Barrier(MPI_COMM_WORLD);
    
    
    double max_elapsed;
    MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
    int failed = 0;
    if(rank == 0)
    {
        printf("Matrix multiplication time: %.6f seconds\n", max_elapsed);

        // Correctness gate (novel_4_reality.md 7.1 / 7.8). A and B are all
        // ones and the kernel zero-inits C, so every element must be exactly
        // K -- no fp tolerance needed. Checking *all* of C on rank 0 also
        // covers 7.8: rank 0 only holds the whole result if every per-level
        // gather moved its full slice, so a short transfer count or a task
        // whose loop bounds disagree with its outRanges shows up here as
        // untouched entries.
        const float expected = (float) K;
        long bad = 0;
        float first_bad = 0.0f;
        long first_bad_idx = -1;
        for (long i = 0; i < (long) M * N; ++i) {
            if (C[i] != expected) {
                if (bad == 0) { first_bad = C[i]; first_bad_idx = i; }
                ++bad;
            }
        }

        if (bad == 0) {
            printf("PASS: all %ld elements of C == %.1f\n", (long) M * N, expected);
        } else {
            printf("FAIL: %ld of %ld elements wrong; first at C[%ld][%ld] = %f, expected %f\n",
                   bad, (long) M * N, first_bad_idx / N, first_bad_idx % N,
                   first_bad, expected);
            failed = 1;
        }
    }

    MPI_Bcast(&failed, 1, MPI_INT, 0, MPI_COMM_WORLD);

    free(A);
    free(B);
    free(C);
    MPI_Finalize();
    return failed;
}



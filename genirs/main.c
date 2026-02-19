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
//              int tag, MPI_Comm comm, MPI_Status *status) {
    
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
    
    
    int M = 10000, K = 10000, N = 10000;
    float *A = (float*) aligned_alloc(64, M*K*sizeof(float));
    float *B = (float*) aligned_alloc(64, K*N*sizeof(float));
    float *C = (float*) aligned_alloc(64, M*N*sizeof(float));
    

    for (int i=0; i<M*K; i++) A[i] = 1.0f;
    for (int i=0; i<K*N; i++) B[i] = 1.0f;
    for (int i=0; i<M*N; i++) C[i] = 0.0f;
    
    
    
    matmul(M, N, K,
        A, A, 0, M, K, K, 1,        
        B, B, 0, K, N, N, 1,        
        C, C, 0, M, N, N, 1);
    
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Barrier(MPI_COMM_WORLD);
    
    // printf("[%d] Buffer: %p\n",rank, C);

    // printf("Rank %d: After matmul, C[0]=%f, C[334000]=%f, C[667000]=%f\n", 
    //        rank, C[0], C[334000], C[667000]);
    
    // // Count non-zero elements
    // int nonzero_count = 0;
    // for (int i = 0; i < M*N; i++) {
    //     if (C[i] != 0.0f) nonzero_count++;
    // }
    // printf("Rank %d: Total non-zero elements = %d\n", rank, nonzero_count);
    
    // // Show first non-zero and last non-zero
    // int first_nonzero = -1, last_nonzero = -1;
    // for (int i = 0; i < M*N; i++) {
    //     if (C[i] != 0.0f) {
    //         if (first_nonzero == -1) first_nonzero = i;
    //         last_nonzero = i;
    //     }
    // }
    // printf("Rank %d: First non-zero at %d, Last non-zero at %d\n", 
    //        rank, first_nonzero, last_nonzero);

    if(rank == 0)
    {
        for(int i=0; i<M*N; ++i)
        {
            if(C[i] != 1000.00f)
                printf("%f", C[i]);
        }
    }


    free(A);
    free(B);
    free(C);
    MPI_Finalize();
    return 0;
}



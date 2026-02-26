#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <mpi.h>
#include <execinfo.h>


#ifdef __cplusplus
extern "C"
{
#endif

    extern void kernel_jacobi(
        int32_t arg0,  // tsteps
        int32_t arg1,  // n
        void *arg2,    // memref arg2 - allocated ptr
        void *arg3,    // memref arg2 - aligned ptr
        int64_t arg4,  // memref arg2 - offset
        int64_t arg5,  // memref arg2 - size
        int64_t arg6,  // memref arg2 - stride
        void *arg7,    // memref arg3 - allocated ptr
        void *arg8,    // memref arg3 - aligned ptr
        int64_t arg9,  // memref arg3 - offset
        int64_t arg10, // memref arg3 - size
        int64_t arg11  // memref arg3 - stride
    );

#ifdef __cplusplus
}
#endif


extern "C" {
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


int main(int argc, char **argv)
{
    // Problem parameters
    int32_t tsteps = 500; // Number of time steps
    int32_t n = 1000;      // Array size

    // Parse command line arguments if provided
    if (argc > 1)
    {
        tsteps = atoi(argv[1]);
    }
    if (argc > 2)
    {
        n = atoi(argv[2]);
    }

    // printf("Jacobi 1D Stencil\n");
    // printf("=================\n");
    // printf("Array size (n): %d\n", n);
    // printf("Time steps: %d\n", tsteps);
    // printf("\n");

    // Allocate arrays
    // Note: Arrays are allocated as dynamic size (malloc)
    float *A = (float *)malloc(n * sizeof(float));
    float *B = (float *)malloc(n * sizeof(float));

    if (!A || !B)
    {
        fprintf(stderr, "Memory allocation failed!\n");
        return 1;
    }

    // Initialize array A
    for (int i = 0; i < n; i++)
    {
        A[i] = (float)i;
    }

    // Initialize array B to zero
    memset(B, 0, n * sizeof(float));

    // Set boundary conditions
    A[0] = 0.0f;
    A[n - 1] = 0.0f;

    // printf("Initial values (center region):\n");
    // for (int i = n / 2 - 2; i <= n / 2 + 2; i++)
    // {
    //     printf("  A[%d] = %.2f\n", i, A[i]);
    // }
    // printf("\n");

    // Call the LLVM-compiled function
    // MLIR memref descriptors have the following structure:
    // - allocated ptr: pointer to the allocated memory
    // - aligned ptr: pointer to the aligned data (usually same as allocated)
    // - offset: offset in elements (usually 0)
    // - size: size of dimension
    // - stride: stride of dimension (usually 1 for contiguous)

    // printf("Running Jacobi iteration...\n");

    kernel_jacobi(
        tsteps,     // arg0: tsteps (i32)
        n,          // arg1: n (i32)
        (void *)A,  // arg2: memref A - allocated ptr
        (void *)A,  // arg3: memref A - aligned ptr
        0,          // arg4: memref A - offset
        (int64_t)n, // arg5: memref A - size
        1,          // arg6: memref A - stride
        (void *)B,  // arg7: memref B - allocated ptr
        (void *)B,  // arg8: memref B - aligned ptr
        0,          // arg9: memref B - offset
        (int64_t)n, // arg10: memref B - size
        1           // arg11: memref B - stride
    );
    int rank;

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (rank == 0)
    {
        // printf("Computation complete!\n\n");

        // Print results
        // printf("Final values (center region):\n");
        for (int i = 0; i < n; ++i)
        {
            printf("%.6f\n",A[i]);
        }
        // printf("\n");

        // printf("Final values (Initial region):\n");
        // for (int i = 1; i <= 4; i++)
        // {
        //     printf("  A[%d] = %.6f\n", i, A[i]);
        // }
        // printf("\n");





        // Verify boundary conditions
        // printf("Boundary check:\n");
        // printf("  A[0] = %.6f (should be 0.0)\n", A[0]);
        // printf("  A[%d] = %.6f (should be 0.0)\n", n - 1, A[n - 1]);
    }

    // Clean up
    free(A);
    free(B);

    MPI_Finalize();
    return 0;
}
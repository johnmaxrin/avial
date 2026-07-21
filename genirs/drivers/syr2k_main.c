#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <mpi.h>
#include <math.h>

// External kernel declaration - your distributed heterogeneous kernel
// kernel_syr2k signature from LLVM IR:
// define void @kernel_syr2k(i32 %N, i32 %M, float %alpha, float %beta, 
//                           ptr %C, ptr %C_base, i64 offset, i64 N, i64 N, i64 stride1, i64 stride2,
//                           ptr %A, ptr %A_base, i64 offset, i64 N, i64 M, i64 stride1, i64 stride2,
//                           ptr %B, ptr %B_base, i64 offset, i64 N, i64 M, i64 stride1, i64 stride2)

#ifdef __cplusplus
extern "C" {
#endif

void kernel_syr2k(
    int32_t, int32_t,        // N, M
    float, float,            // alpha, beta
    void*, void*, int64_t, int64_t, int64_t, int64_t, int64_t,  // C matrix (NxN, output)
    void*, void*, int64_t, int64_t, int64_t, int64_t, int64_t,  // A matrix (NxM, input)
    void*, void*, int64_t, int64_t, int64_t, int64_t, int64_t   // B matrix (NxM, input)
);

#ifdef __cplusplus
}
#endif

// Initialize matrix with specific value
void init_matrix(float* mat, int size, float value) {
    for (int i = 0; i < size; i++) {
        mat[i] = value;
    }
}

// Initialize symmetric matrix
void init_symmetric_matrix(float* mat, int N, float value) {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            mat[i * N + j] = value;
        }
    }
}

// Print sample of matrix
void print_matrix_sample(const char* name, float* mat, int rows, int cols, int rank) {
    printf("Rank %d: %s (%dx%d) sample:\n", rank, name, rows, cols);
    int max_r = (rows < 5) ? rows : 5;
    int max_c = (cols < 5) ? cols : 5;
    
    for (int i = 0; i < max_r; i++) {
        printf("  ");
        for (int j = 0; j < max_c; j++) {
            printf("%10.2f ", mat[i * cols + j]);
        }
        if (cols > 5) printf("...");
        printf("\n");
    }
    if (rows > 5) printf("  ...\n");
}

int main(int argc, char** argv) {
    int rank, size;
    double start_time, end_time;
    
    // Initialize MPI
        // Matrix dimensions (syr2k: C is NxN, A and B are NxM)
    int N = 1000;  // C: N x N,  A: N x M,  B: N x M
    int M = 1000;  // A: N x M,  B: N x M
    
    // Scalars
    float alpha = 1.5f;
    float beta = 1.2f;
    float C_init = 1.0f;  // Initial value for C
    float A_value = 1.0f; // Value for A
    float B_value = 1.0f; // Value for B
   
    
    // Allocate matrices
    // All ranks allocate full-size matrices (distributed kernel handles the distribution)
    float* C = (float*)malloc(N * N * sizeof(float));
    float* A = (float*)malloc(N * M * sizeof(float));
    float* B = (float*)malloc(N * M * sizeof(float));
    
   
   
    
    // Initialize input matrices
    init_symmetric_matrix(C, N, C_init);  // C is symmetric
    init_matrix(A, N * M, A_value);
    init_matrix(B, N * M, B_value);
    
 
    // Synchronize all ranks before starting computation
    start_time = 0;
    
    // Call your distributed heterogeneous kernel
    // The kernel should handle MPI communication internally
    // Signature: kernel_syr2k(N, M, alpha, beta, C, A, B)
    kernel_syr2k(
        N, M,                    // Dimensions
        alpha, beta,             // Scalars
        C, C, 0, N, N, N, 1,    // C (output/input, N x N, symmetric)
        A, A, 0, N, M, M, 1,    // A (input, N x M)
        B, B, 0, N, M, M, 1     // B (input, N x M)
    );
    
    
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    

    // Synchronize after computation
    MPI_Barrier(MPI_COMM_WORLD);
    end_time = MPI_Wtime();
    
    if (rank == 0) {
        printf("Computation completed in %.4f seconds\n\n", end_time - start_time);
    }
    
    // Verify results at rank 0
    if (rank == 0) {
        printf("========================================\n");
        printf("VERIFICATION at Rank 0\n");
        printf("========================================\n\n");
        
        printf("Expected computation:\n");
        printf("  C := alpha*A*B^T + alpha*B*A^T + beta*C\n");
        printf("  where alpha=%.2f, beta=%.2f\n", alpha, beta);
        printf("  Input: C[i][j]=%.2f, A[i][j]=%.2f, B[i][j]=%.2f\n\n", C_init, A_value, B_value);
        
        // For simple case where all A and B values are 1.0:
        // Each element: alpha * sum(A[i][k]*B[j][k]) + alpha * sum(B[i][k]*A[j][k]) + beta*C[i][j]
        //             = alpha * M * 1.0 * 1.0 + alpha * M * 1.0 * 1.0 + beta * C_init
        //             = 2 * alpha * M + beta * C_init
        float expected_value = 2.0f * alpha * M + beta * C_init;
        printf("For all-ones input, expected C[i][j] = 2*alpha*M + beta*C_init\n");
        printf("                                      = 2*%.2f*%d + %.2f*%.2f\n", alpha, M, beta, C_init);
        printf("                                      = %.2f\n\n", expected_value);
        
        // Verify C matrix values
        printf("Checking C matrix values...\n");
        float tolerance = 1e-2f;  // Tolerance for floating point comparison
        int errors_C = 0;
        int max_errors_to_print = 10;
        
        for (int i = 0; i < N * N; i++) {
            float diff = fabsf(C[i] - expected_value);
            if (diff > tolerance) {
                if (errors_C < max_errors_to_print) {
                    printf("Rank %d: ERROR in C[%d][%d]: expected %.6f, got %.6f (diff=%.6f)\n",
                           rank, i / N, i % N, expected_value, C[i], diff);
                }
                errors_C++;
            }
        }
        
        if (errors_C > max_errors_to_print) {
            printf("Rank %d: ... and %d more errors in C\n", rank, errors_C - max_errors_to_print);
        }
        
        if (errors_C == 0) {
            printf("✓ C matrix is CORRECT (within tolerance %.6f)\n\n", tolerance);
        } else {
            printf("✗ C matrix has %d ERRORS (tolerance %.6f)\n\n", errors_C, tolerance);
        }
        
        // Check if C is symmetric (as it should be for syr2k)
        printf("Checking if C is symmetric...\n");
        int symmetry_errors = 0;
        int max_sym_errors = 10;
        for (int i = 0; i < N; i++) {
            for (int j = i + 1; j < N; j++) {
                float diff = fabsf(C[i * N + j] - C[j * N + i]);
                if (diff > tolerance) {
                    if (symmetry_errors < max_sym_errors) {
                        printf("  Symmetry error at C[%d][%d]=%.6f vs C[%d][%d]=%.6f (diff=%.6f)\n",
                               i, j, C[i * N + j], j, i, C[j * N + i], diff);
                    }
                    symmetry_errors++;
                }
            }
        }
        
        if (symmetry_errors == 0) {
            printf("✓ C matrix is SYMMETRIC\n\n");
        } else {
            printf("✗ C matrix has %d symmetry violations\n\n", symmetry_errors);
        }
        
        // Print samples
        printf("========================================\n");
        printf("SAMPLE OUTPUT\n");
        printf("========================================\n\n");
        print_matrix_sample("C (result)", C, N, N, rank);
        printf("\n");
        
        // Overall result
        printf("========================================\n");
        if (errors_C == 0 && symmetry_errors == 0) {
            printf("RESULT: ✓ ALL TESTS PASSED\n");
            printf("  C matrix is correct and symmetric\n");
        } else {
            printf("RESULT: ✗ TESTS FAILED\n");
            printf("  Errors in C: %d\n", errors_C);
            printf("  Symmetry violations: %d\n", symmetry_errors);
        }
        printf("========================================\n");
    }
    
    // Cleanup
    free(C);
    free(A);
    free(B);
    
    // Finalize MPI
    MPI_Finalize();
    
    return 0;
}
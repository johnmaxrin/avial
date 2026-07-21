#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <mpi.h>

// External kernel declaration - your distributed heterogeneous kernel
#ifdef __cplusplus
extern "C" {
#endif

void kernel_3mm(
    int32_t, int32_t, int32_t, int32_t, int32_t,
    void*, void*, int64_t, int64_t, int64_t, int64_t, int64_t,
    void*, void*, int64_t, int64_t, int64_t, int64_t, int64_t,
    void*, void*, int64_t, int64_t, int64_t, int64_t, int64_t,
    void*, void*, int64_t, int64_t, int64_t, int64_t, int64_t,
    void*, void*, int64_t, int64_t, int64_t, int64_t, int64_t,
    void*, void*, int64_t, int64_t, int64_t, int64_t, int64_t,
    void*, void*, int64_t, int64_t, int64_t, int64_t, int64_t
);

#ifdef __cplusplus
}
#endif

// Initialize matrix with value 1.0
void init_matrix(float* mat, int size) {
    for (int i = 0; i < size; i++) {
        mat[i] = 1.0f;
    }
}

// Check if results are correct (expected value for matrix multiplication with all 1s)
// For C = A * B where A is MxK, B is KxN, and all values are 1.0:
// C[i][j] = sum(A[i][k] * B[k][j]) = sum(1.0 * 1.0) for k=0..K-1 = K
int verify_result(const char* name, float* mat, int rows, int cols, float expected_value, int rank) {
    int errors = 0;
    int max_errors_to_print = 10;
    
    for (int i = 0; i < rows * cols; i++) {
        if (mat[i] != expected_value) {
            if (errors < max_errors_to_print) {
                printf("Rank %d: ERROR in %s[%d][%d]: expected %.1f, got %.6f\n",
                       rank, name, i / cols, i % cols, expected_value, mat[i]);
            }
            errors++;
        }
    }
    
    if (errors > max_errors_to_print) {
        printf("Rank %d: ... and %d more errors in %s\n", rank, errors - max_errors_to_print, name);
    }
    
    return errors;
}

// Print sample of matrix
void print_matrix_sample(const char* name, float* mat, int rows, int cols, int rank) {
    printf("Rank %d: %s (%dx%d) sample:\n", rank, name, rows, cols);
    int max_r = (rows < 5) ? rows : 5;
    int max_c = (cols < 5) ? cols : 5;
    
    for (int i = 0; i < max_r; i++) {
        printf("  ");
        for (int j = 0; j < max_c; j++) {
            printf("%8.1f ", mat[i * cols + j]);
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
    
   
    
    // Matrix dimensions (all 1000x1000 as specified)
    int NI = 1000;  // A: NI x NK,  E: NI x NJ,  G: NI x NM
    int NJ = 1000;  // B: NK x NJ,  C: NJ x NL,  E: NI x NJ,  F: NJ x NM
    int NK = 1000;  // A: NI x NK,  B: NK x NJ
    int NL = 1000;  // C: NJ x NL,  D: NL x NM
    int NM = 1000;  // D: NL x NM,  F: NJ x NM,  G: NI x NM
    
    if (rank == 0) {
        printf("========================================\n");
        printf("MPI 3MM Distributed Heterogeneous Kernel Test\n");
        printf("========================================\n");
        printf("Number of MPI processes: %d\n", size);
        printf("Matrix sizes: all 1000x1000\n");
        printf("Input values: all 1.0\n");
        printf("Computing: E = A*B, F = C*D, G = E*F\n\n");
    }
    
    // Allocate all matrices
    // All ranks allocate full-size matrices (your distributed kernel handles the distribution)
    float* A = (float*)malloc(NI * NK * sizeof(float));
    float* B = (float*)malloc(NK * NJ * sizeof(float));
    float* C = (float*)malloc(NJ * NL * sizeof(float));
    float* D = (float*)malloc(NL * NM * sizeof(float));
    float* E = (float*)calloc(NI * NJ, sizeof(float));
    float* F = (float*)calloc(NJ * NM, sizeof(float));
    float* G = (float*)calloc(NI * NM, sizeof(float));
    
    
   
    
    // Initialize input matrices (all values = 1.0)
    init_matrix(A, NI * NK);
    init_matrix(B, NK * NJ);
    init_matrix(C, NJ * NL);
    init_matrix(D, NL * NM);
    
    // Synchronize all ranks before starting computation
    
    
    // Call your distributed heterogeneous kernel
    // The kernel should handle MPI communication internally
    kernel_3mm(
        NI, NJ, NK, NL, NM,
        E, E, 0, NI, NJ, NJ, 1,  // E (output, NI x NJ)
        A, A, 0, NI, NK, NK, 1,  // A (input, NI x NK)
        B, B, 0, NK, NJ, NJ, 1,  // B (input, NK x NJ)
        F, F, 0, NJ, NM, NM, 1,  // F (intermediate/output, NJ x NM)
        C, C, 0, NJ, NL, NL, 1,  // C (input, NJ x NL)
        D, D, 0, NL, NM, NM, 1,  // D (input, NL x NM)
        G, G, 0, NI, NM, NM, 1   // G (final output, NI x NM)
    );
    
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    if (rank == 0) {
        printf("Rank 0: Initializing input matrices...\n");
    }
    // Synchronize after computation
    MPI_Barrier(MPI_COMM_WORLD);
    
    if (rank == 0) {
        end_time = MPI_Wtime();
        printf("Computation completed in %.4f seconds\n\n", end_time - start_time);
    }
    
    // Verify results at rank 0
    if (rank == 0) {
        printf("========================================\n");
        printf("VERIFICATION at Rank 0\n");
        printf("========================================\n\n");
        
        // Expected values when all inputs are 1.0:
        // E[i][j] = sum(A[i][k] * B[k][j]) = sum(1.0 * 1.0) for k=0..NK-1 = NK = 1000
        // F[i][j] = sum(C[i][k] * D[k][j]) = sum(1.0 * 1.0) for k=0..NL-1 = NL = 1000
        // G[i][j] = sum(E[i][k] * F[k][j]) = sum(1000 * 1000) for k=0..NJ-1 = 1000 * 1000 = 1,000,000
        
        float expected_E = (float)NK;        // 1000.0
        float expected_F = (float)NL;        // 1000.0
        float expected_G = (float)(NK * NL * NJ); // 1,000,000.0
        
        printf("Expected values:\n");
        printf("  E (A*B): all elements should be %.1f\n", expected_E);
        printf("  F (C*D): all elements should be %.1f\n", expected_F);
        printf("  G (E*F): all elements should be %.1f\n\n", expected_G);
        
        // Verify E = A * B
        printf("Checking E = A * B...\n");
        int errors_E = verify_result("E", E, NI, NJ, expected_E, rank);
        if (errors_E == 0) {
            printf("✓ E matrix is CORRECT (all values = %.1f)\n\n", expected_E);
        } else {
            printf("✗ E matrix has %d ERRORS\n\n", errors_E);
        }
        
        // Verify F = C * D
        printf("Checking F = C * D...\n");
        int errors_F = verify_result("F", F, NJ, NM, expected_F, rank);
        if (errors_F == 0) {
            printf("✓ F matrix is CORRECT (all values = %.1f)\n\n", expected_F);
        } else {
            printf("✗ F matrix has %d ERRORS\n\n", errors_F);
        }
        
        // Verify G = E * F
        printf("Checking G = E * F...\n");
        int errors_G = verify_result("G", G, NI, NM, expected_G, rank);
        if (errors_G == 0) {
            printf("✓ G matrix is CORRECT (all values = %.1f)\n\n", expected_G);
        } else {
            printf("✗ G matrix has %d ERRORS\n\n", errors_G);
        }
        
        // Print samples
        printf("========================================\n");
        printf("SAMPLE OUTPUT\n");
        printf("========================================\n\n");
        print_matrix_sample("E (A*B)", E, NI, NJ, rank);
        printf("\n");
        print_matrix_sample("F (C*D)", F, NJ, NM, rank);
        printf("\n");
        print_matrix_sample("G (E*F)", G, NI, NM, rank);
        printf("\n");
        
        // Overall result
        printf("========================================\n");
        if (errors_E == 0 && errors_F == 0 && errors_G == 0) {
            printf("RESULT: ✓ ALL TESTS PASSED\n");
        } else {
            printf("RESULT: ✗ TESTS FAILED\n");
            printf("  Errors in E: %d\n", errors_E);
            printf("  Errors in F: %d\n", errors_F);
            printf("  Errors in G: %d\n", errors_G);
        }
        printf("========================================\n");
    }
    
    // Cleanup
    free(A);
    free(B);
    free(C);
    free(D);
    free(E);
    free(F);
    free(G);
    
    // Finalize MPI
    MPI_Finalize();
    
    return 0;
}
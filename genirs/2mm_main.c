#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#ifdef __cplusplus
extern "C" {
#endif
void testFunc(int32_t M, int32_t N, int32_t K, int32_t extra,
              float alpha, float beta,
              /* A */
              float *A_alloc, float *A_aligned,
              long long A_off, long long A_s0, long long A_s1,
              long long A_t0, long long A_t1,
              /* B */
              float *B_alloc, float *B_aligned,
              long long B_off, long long B_s0, long long B_s1,
              long long B_t0, long long B_t1,
              /* C */
              float *C_alloc, float *C_aligned,
              long long C_off, long long C_s0, long long C_s1,
              long long C_t0, long long C_t1,
              /* D (scratch) */
              float *D_alloc, float *D_aligned,
              long long D_off, long long D_s0, long long D_s1,
              long long D_t0, long long D_t1,
              /* E (scratch) */
              float *E_alloc, float *E_aligned,
              long long E_off, long long E_s0, long long E_s1,
              long long E_t0, long long E_t1);
#ifdef __cplusplus
}
#endif

int main(int argc, char **argv) {
    MPI_Init(NULL, NULL);

    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    int32_t M = 1000, K = 1000, N = 1000;
    int32_t extra = 0;
    float alpha = 1.0f, beta = 0.0f;

    float *A = (float*) malloc((size_t)M * K * sizeof(float));
    float *B = (float*) malloc((size_t)K * N * sizeof(float));
    float *C = (float*) malloc((size_t)M * N * sizeof(float));

    float *D = (float*) malloc(1 * sizeof(float));
    float *E = (float*) malloc(1 * sizeof(float));
    *D = 0.0f; *E = 0.0f;

    for (size_t i=0; i<(size_t)M*K; i++) A[i] = 1.0f;
    for (size_t i=0; i<(size_t)K*N; i++) B[i] = 1.0f;
    for (size_t i=0; i<(size_t)M*N; i++) C[i] = 0.0f;

    MPI_Barrier(MPI_COMM_WORLD);
    // double start = MPI_Wtime();
    // printf("Hello\n");
    testFunc(
        M, N, K, extra,
        alpha, beta,
        /* A */
        A, A, 0, M, K, K, 1,
        /* B */
        B, B, 0, K, N, N, 1,
        /* C */
        C, C, 0, M, N, N, 1,
        /* D: 1x1 scratch */
        D, D, 0, 1, 1, 1, 1,
        /* E: 1x1 scratch */
        E, E, 0, 1, 1, 1, 1
    );

    MPI_Barrier(MPI_COMM_WORLD);
    // double end = MPI_Wtime();

    // if (rank == 0) {
    //     printf("C[0] = %f\n", C[0]);
    //     printf("Elapsed time: %f seconds\n", end - start);
    // }

    // free(A); free(B); free(C);
    // free(D); free(E);

    MPI_Finalize();
    return 0;
}
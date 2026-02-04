#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#ifdef __cplusplus
extern "C"
{
#endif

    // Forward declaration of the kernel function
    extern void kernel_2mm(int ni, int nj, int nk, int nl,
                           float alpha, float beta,
                           float *tmp, float *tmp_base, long tmp_offset, long tmp_size0, long tmp_size1, long tmp_stride0, long tmp_stride1,
                           float *A, float *A_base, long A_offset, long A_size0, long A_size1, long A_stride0, long A_stride1,
                           float *B, float *B_base, long B_offset, long B_size0, long B_size1, long B_stride0, long B_stride1,
                           float *C, float *C_base, long C_offset, long C_size0, long C_size1, long C_stride0, long C_stride1,
                           float *D, float *D_base, long D_offset, long D_size0, long D_size1, long D_stride0, long D_stride1);

#ifdef __cplusplus
}
#endif

int main()
{
    // Matrix dimensions
    int ni = 1000; // rows of A and tmp
    int nj = 1000; // cols of A, rows of B
    int nk = 1000; // cols of B and tmp
    int nl = 1000; // cols of C and D

    float alpha = 1.5f;
    float beta = 1.2f;

    // Allocate matrices
    float *tmp = (float *)malloc(ni * nk * sizeof(float));
    float *A = (float *)malloc(ni * nj * sizeof(float));
    float *B = (float *)malloc(nj * nk * sizeof(float));
    float *C = (float *)malloc(nk * nl * sizeof(float));
    float *D = (float *)malloc(ni * nl * sizeof(float));

    // Initialize arrays (all except result D with 1, D with 0)
    for (int i = 0; i < ni * nk; i++)
        tmp[i] = 1.0f;
    for (int i = 0; i < ni * nj; i++)
        A[i] = 1.0f;
    for (int i = 0; i < nj * nk; i++)
        B[i] = 1.0f;
    for (int i = 0; i < nk * nl; i++)
        C[i] = 1.0f;
    for (int i = 0; i < ni * nl; i++)
        D[i] = 0.0f; // Result array

    // Call kernel_2mm
    // Each array needs: ptr, base_ptr, offset, size0, size1, stride0, stride1
    kernel_2mm(ni, nj, nk, nl, alpha, beta,
               tmp, tmp, 0, ni, nk, nk, 1,
               A, A, 0, ni, nj, nj, 1,
               B, B, 0, nj, nk, nk, 1,
               C, C, 0, nk, nl, nl, 1,
               D, D, 0, ni, nl, nl, 1);

    // Print a sample of results
    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    if (rank == 0)
    {
        printf("Sample results from D:\n");
        for (int i = 0; i < 4 && i < ni; i++)
        {
            for (int j = 0; j < 4 && j < nl; j++)
            {
                printf("%.2f ", D[i * nl + j]);
            }
            printf("\n");
        }

        printf("\n\n");
        for (int i = 500; i < 504 && i < ni; i++)
        {
            for (int j = 0; j < 4 && j < nl; j++)
            {
                printf("%.2f ", D[i * nl + j]);
            }
            printf("\n");
        }

        printf("\n\n");
        for (int i = 950; i < 954 && i < ni; i++)
        {
            for (int j = 0; j < 4 && j < nl; j++)
            {
                printf("%.2f ", D[i * nl + j]);
            }
            printf("\n");
        }
    }

    // Free allocated memory
    free(tmp);
    free(A);
    free(B);
    free(C);
    free(D);

    return 0;
}
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

extern void testFunc(int32_t M, int32_t N, int32_t K,
                   float *A_alloc, float *A_aligned,
                   int64_t A_offset, int64_t A_size0, int64_t A_size1,
                   int64_t A_stride0, int64_t A_stride1,
                   float *B_alloc, float *B_aligned,
                   int64_t B_offset, int64_t B_size0, int64_t B_size1,
                   int64_t B_stride0, int64_t B_stride1,
                   float *C_alloc, float *C_aligned,
                   int64_t C_offset, int64_t C_size0, int64_t C_size1,
                   int64_t C_stride0, int64_t C_stride1);

int main() {
    int M = 1000, K = 1000, N = 1000;

    float *A = (float*) aligned_alloc(64, M*K*sizeof(float));
    float *B = (float*) aligned_alloc(64, K*N*sizeof(float));
    float *C = (float*) aligned_alloc(64, M*N*sizeof(float));

    for (int i=0; i<M*K; i++) A[i] = 1.0f;
    for (int i=0; i<K*N; i++) B[i] = 1.0f;
    for (int i=0; i<K*N; i++) C[i] = 0.0f;

    testFunc(M, N, K,
           A, A, 0, M, K, K, 1,        
           B, B, 0, K, N, N, 1,        
           C, C, 0, M, N, N, 1);       

    printf("C[0] = %f\n", C[0]);

    free(A);
    free(B);
    free(C);
    
    MPI_Finalize();
    return 0;
}

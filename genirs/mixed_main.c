#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <execinfo.h>

#ifdef __cplusplus
extern "C" {
#endif
extern void matmul(
    // Basic parameters
    int32_t arg0, int32_t arg1, int32_t arg2,
    
    // First memref: syr2k_A (from earlier schedule)
    float* arg3_alloc, float* arg3_aligned,
    int64_t arg3_offset, int64_t arg3_size0, int64_t arg3_size1,
    int64_t arg3_stride0, int64_t arg3_stride1,
    
    // Second memref: syr2k_B (from earlier schedule)
    float* arg4_alloc, float* arg4_aligned,
    int64_t arg4_offset, int64_t arg4_size0, int64_t arg4_size1,
    int64_t arg4_stride0, int64_t arg4_stride1,
    
    // Third memref: syr2k_C (from earlier schedule)
    float* arg5_alloc, float* arg5_aligned,
    int64_t arg5_offset, int64_t arg5_size0, int64_t arg5_size1,
    int64_t arg5_stride0, int64_t arg5_stride1,
    
    // Fourth memref: gemm_A
    float* arg6_alloc, float* arg6_aligned,
    int64_t arg6_offset, int64_t arg6_size0, int64_t arg6_size1,
    int64_t arg6_stride0, int64_t arg6_stride1,
    
    // Fifth memref: gemm_B
    float* arg7_alloc, float* arg7_aligned,
    int64_t arg7_offset, int64_t arg7_size0, int64_t arg7_size1,
    int64_t arg7_stride0, int64_t arg7_stride1,
    
    // Sixth memref: gemm_C
    float* arg8_alloc, float* arg8_aligned,
    int64_t arg8_offset, int64_t arg8_size0, int64_t arg8_size1,
    int64_t arg8_stride0, int64_t arg8_stride1,
    
    // Seventh memref: 2mm_tmp
    float* arg24_alloc, float* arg24_aligned,
    int64_t arg24_offset, int64_t arg24_size0, int64_t arg24_size1,
    int64_t arg24_stride0, int64_t arg24_stride1,
    
    // Eighth memref: 2mm_A
    float* arg25_alloc, float* arg25_aligned,
    int64_t arg25_offset, int64_t arg25_size0, int64_t arg25_size1,
    int64_t arg25_stride0, int64_t arg25_stride1,
    
    // Ninth memref: 2mm_B
    float* arg26_alloc, float* arg26_aligned,
    int64_t arg26_offset, int64_t arg26_size0, int64_t arg26_size1,
    int64_t arg26_stride0, int64_t arg26_stride1,
    
    // Tenth memref: 2mm_C
    float* arg27_alloc, float* arg27_aligned,
    int64_t arg27_offset, int64_t arg27_size0, int64_t arg27_size1,
    int64_t arg27_stride0, int64_t arg27_stride1,
    
    // Eleventh memref: 2mm_D
    float* arg33_alloc, float* arg33_aligned,
    int64_t arg33_offset, int64_t arg33_size0, int64_t arg33_size1,
    int64_t arg33_stride0, int64_t arg33_stride1,
    
    // Twelfth memref: matadd_A (1000x1000)
    float* arg34_alloc, float* arg34_aligned,
    int64_t arg34_offset, int64_t arg34_size0, int64_t arg34_size1,
    int64_t arg34_stride0, int64_t arg34_stride1,
    
    // Thirteenth memref: matadd_B (1000x1000)
    float* arg40_alloc, float* arg40_aligned,
    int64_t arg40_offset, int64_t arg40_size0, int64_t arg40_size1,
    int64_t arg40_stride0, int64_t arg40_stride1,
    
    // Fourteenth memref: matadd_C (1000x1000)
    float* arg41_alloc, float* arg41_aligned,
    int64_t arg41_offset, int64_t arg41_size0, int64_t arg41_size1,
    int64_t arg41_stride0, int64_t arg41_stride1,
    
    // Fifteenth memref: (unknown - possibly syr2k alpha/beta or gemm params)
    float* arg47_alloc, float* arg47_aligned,
    int64_t arg47_offset, int64_t arg47_size0, int64_t arg47_size1,
    int64_t arg47_stride0, int64_t arg47_stride1,
    
    // Sixteenth memref: (unknown)
    float* arg48_alloc, float* arg48_aligned,
    int64_t arg48_offset, int64_t arg48_size0, int64_t arg48_size1,
    int64_t arg48_stride0, int64_t arg48_stride1,
    
    // Seventeenth memref: (unknown - possibly scalar parameters)
    float* arg54_alloc, float* arg54_aligned,
    int64_t arg54_offset, int64_t arg54_size0, int64_t arg54_size1,
    int64_t arg54_stride0, int64_t arg54_stride1,
    
    // Eighteenth memref: (unknown)
    float* arg55_alloc, float* arg55_aligned,
    int64_t arg55_offset, int64_t arg55_size0, int64_t arg55_size1,
    int64_t arg55_stride0, int64_t arg55_stride1,
    
    // Nineteenth memref: (unknown)
    float* arg61_alloc, float* arg61_aligned,
    int64_t arg61_offset, int64_t arg61_size0, int64_t arg61_size1,
    int64_t arg61_stride0, int64_t arg61_stride1,
    
    // Twentieth memref: (unknown)
    float* arg62_alloc, float* arg62_aligned,
    int64_t arg62_offset, int64_t arg62_size0, int64_t arg62_size1,
    int64_t arg62_stride0, int64_t arg62_stride1,
    
    // Twenty-first memref: (unknown)
    float* arg68_alloc, float* arg68_aligned,
    int64_t arg68_offset, int64_t arg68_size0, int64_t arg68_size1,
    int64_t arg68_stride0, int64_t arg68_stride1,
    
    // Twenty-second memref: (unknown)
    float* arg69_alloc, float* arg69_aligned,
    int64_t arg69_offset, int64_t arg69_size0, int64_t arg69_size1,
    int64_t arg69_stride0, int64_t arg69_stride1,
    
    // Twenty-third memref: (unknown)
    float* arg75_alloc, float* arg75_aligned,
    int64_t arg75_offset, int64_t arg75_size0, int64_t arg75_size1,
    int64_t arg75_stride0, int64_t arg75_stride1,
    
    // Twenty-fourth memref: (unknown)
    float* arg76_alloc, float* arg76_aligned,
    int64_t arg76_offset, int64_t arg76_size0, int64_t arg76_size1,
    int64_t arg76_stride0, int64_t arg76_stride1,
    
    // Twenty-fifth memref: (unknown)
    float* arg82_alloc, float* arg82_aligned,
    int64_t arg82_offset, int64_t arg82_size0, int64_t arg82_size1,
    int64_t arg82_stride0, int64_t arg82_stride1,
    
    // Twenty-sixth memref: (unknown)
    float* arg83_alloc, float* arg83_aligned,
    int64_t arg83_offset, int64_t arg83_size0, int64_t arg83_size1,
    int64_t arg83_stride0, int64_t arg83_stride1,
    
    // Twenty-seventh memref: (unknown)
    float* arg89_alloc, float* arg89_aligned,
    int64_t arg89_offset, int64_t arg89_size0, int64_t arg89_size1,
    int64_t arg89_stride0, int64_t arg89_stride1,
    
    // Twenty-eighth memref: (unknown)
    float* arg90_alloc, float* arg90_aligned,
    int64_t arg90_offset, int64_t arg90_size0, int64_t arg90_size1,
    int64_t arg90_stride0, int64_t arg90_stride1
);
#ifdef __cplusplus
}
#endif

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);
    
    int rank=0, size=0;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    // Matrix dimensions based on your combined schedule
    int M = 10000, K = 10000, N = 10000;  // For 10000x10000 matrices
    int M_small = 1000, N_small = 1000;   // For 1000x1000 matrices (matadd)
    
    // Allocate all the matrices needed for gemm, 2mm, and matadd
    printf("Allocating matrices...\n");
    
    // syr2k matrices (10000x10000) - though from your schedule these might not be used
    float *syr2k_A = (float*) aligned_alloc(64, M*K*sizeof(float));
    float *syr2k_B = (float*) aligned_alloc(64, M*K*sizeof(float));
    float *syr2k_C = (float*) aligned_alloc(64, M*N*sizeof(float));
    
    // gemm matrices (10000x10000)
    float *gemm_A = (float*) aligned_alloc(64, M*K*sizeof(float));
    float *gemm_B = (float*) aligned_alloc(64, K*N*sizeof(float));
    float *gemm_C = (float*) aligned_alloc(64, M*N*sizeof(float));
    
    // 2mm matrices (10000x10000)
    float *mm2_tmp = (float*) aligned_alloc(64, M*N*sizeof(float));
    float *mm2_A = (float*) aligned_alloc(64, M*K*sizeof(float));
    float *mm2_B = (float*) aligned_alloc(64, K*N*sizeof(float));
    float *mm2_C = (float*) aligned_alloc(64, M*N*sizeof(float));
    float *mm2_D = (float*) aligned_alloc(64, M*N*sizeof(float));
    
    // matadd matrices (1000x1000)
    float *matadd_A = (float*) aligned_alloc(64, M_small*N_small*sizeof(float));
    float *matadd_B = (float*) aligned_alloc(64, M_small*N_small*sizeof(float));
    float *matadd_C = (float*) aligned_alloc(64, M_small*N_small*sizeof(float));
    
    // Additional matrices for unknown parameters - allocate small buffers
    float *unknown1 = (float*) aligned_alloc(64, sizeof(float));
    float *unknown2 = (float*) aligned_alloc(64, sizeof(float));
    float *unknown3 = (float*) aligned_alloc(64, sizeof(float));
    float *unknown4 = (float*) aligned_alloc(64, sizeof(float));
    float *unknown5 = (float*) aligned_alloc(64, sizeof(float));
    float *unknown6 = (float*) aligned_alloc(64, sizeof(float));
    float *unknown7 = (float*) aligned_alloc(64, sizeof(float));
    float *unknown8 = (float*) aligned_alloc(64, sizeof(float));
    float *unknown9 = (float*) aligned_alloc(64, sizeof(float));
    float *unknown10 = (float*) aligned_alloc(64, sizeof(float));
    float *unknown11 = (float*) aligned_alloc(64, sizeof(float));
    float *unknown12 = (float*) aligned_alloc(64, sizeof(float));
    float *unknown13 = (float*) aligned_alloc(64, sizeof(float));
    
    // Initialize all matrices
    printf("Initializing matrices...\n");
    
    // Initialize large matrices (10000x10000)
    for (int i = 0; i < M*K; i++) {
        syr2k_A[i] = 1.0f;
        syr2k_B[i] = 2.0f;
        gemm_A[i] = 1.0f;
        mm2_A[i] = 1.0f;
    }
    
    for (int i = 0; i < K*N; i++) {
        gemm_B[i] = 1.0f;
        mm2_B[i] = 1.0f;
    }
    
    for (int i = 0; i < M*N; i++) {
        syr2k_C[i] = 0.5f;
        gemm_C[i] = 0.0f;
        mm2_tmp[i] = 0.0f;
        mm2_C[i] = 1.0f;
        mm2_D[i] = 0.0f;
    }
    
    // Initialize small matrices (1000x1000)
    for (int i = 0; i < M_small*N_small; i++) {
        matadd_A[i] = 1.0f;
        matadd_B[i] = 2.0f;
        matadd_C[i] = 0.0f;
    }
    
    // Initialize unknown parameters (scalars likely)
    unknown1[0] = 1.0f;  // Possibly syr2k_alpha
    unknown2[0] = 1.0f;  // Possibly syr2k_beta
    unknown3[0] = 1.0f;  // Possibly gemm_alpha
    unknown4[0] = 1.0f;  // Possibly gemm_beta
    unknown5[0] = 1.0f;  // Possibly 2mm_alpha
    unknown6[0] = 1.0f;  // Possibly 2mm_beta
    unknown7[0] = 0.0f;
    unknown8[0] = 0.0f;
    unknown9[0] = 0.0f;
    unknown10[0] = 0.0f;
    unknown11[0] = 0.0f;
    unknown12[0] = 0.0f;
    unknown13[0] = 0.0f;
    
    printf("Calling combined kernel (gemm + 2mm + matadd)...\n");
    
    // Call the combined function
    matmul(
        // Basic parameters - likely M, N, K for different operations
        M, N, K,  // arg0, arg1, arg2
        
        // syr2k matrices
        syr2k_A, syr2k_A, 0, M, K, K, 1,  // arg3
        syr2k_B, syr2k_B, 0, M, K, K, 1,  // arg4
        syr2k_C, syr2k_C, 0, M, N, N, 1,  // arg5
        
        // gemm matrices
        gemm_A, gemm_A, 0, M, K, K, 1,    // arg6
        gemm_B, gemm_B, 0, K, N, N, 1,    // arg7
        gemm_C, gemm_C, 0, M, N, N, 1,    // arg8
        
        // 2mm matrices
        mm2_tmp, mm2_tmp, 0, M, N, N, 1,  // arg24
        mm2_A, mm2_A, 0, M, K, K, 1,      // arg25
        mm2_B, mm2_B, 0, K, N, N, 1,      // arg26
        mm2_C, mm2_C, 0, M, N, N, 1,      // arg27
        mm2_D, mm2_D, 0, M, N, N, 1,      // arg33
        
        // matadd matrices
        matadd_A, matadd_A, 0, M_small, N_small, N_small, 1,  // arg34
        matadd_B, matadd_B, 0, M_small, N_small, N_small, 1,  // arg40
        matadd_C, matadd_C, 0, M_small, N_small, N_small, 1,  // arg41
        
        // Unknown parameters (scalars for alpha/beta values)
        unknown1, unknown1, 0, 1, 1, 1, 1,  // arg47
        unknown2, unknown2, 0, 1, 1, 1, 1,  // arg48
        unknown3, unknown3, 0, 1, 1, 1, 1,  // arg54
        unknown4, unknown4, 0, 1, 1, 1, 1,  // arg55
        unknown5, unknown5, 0, 1, 1, 1, 1,  // arg61
        unknown6, unknown6, 0, 1, 1, 1, 1,  // arg62
        unknown7, unknown7, 0, 1, 1, 1, 1,  // arg68
        unknown8, unknown8, 0, 1, 1, 1, 1,  // arg69
        unknown9, unknown9, 0, 1, 1, 1, 1,  // arg75
        unknown10, unknown10, 0, 1, 1, 1, 1, // arg76
        unknown11, unknown11, 0, 1, 1, 1, 1, // arg82
        unknown12, unknown12, 0, 1, 1, 1, 1, // arg83
        unknown13, unknown13, 0, 1, 1, 1, 1, // arg89
        unknown13, unknown13, 0, 1, 1, 1, 1  // arg90 (duplicate)
    );
    
    MPI_Barrier(MPI_COMM_WORLD);
    
    if(rank == 0) {
        printf("Checking results...\n");
        
        // Check gemm results (should be 10000.0f)
        printf("Checking gemm result (C[0] should be ~10000.0): %f\n", gemm_C[0]);
        
        // Check 2mm results (D[0] should be 10000.0f * 10000.0f = 100000000.0f)
        printf("Checking 2mm result (D[0]): %f\n", mm2_D[0]);
        
        // Check matadd results (should be 3.0f = 1.0f + 2.0f)
        printf("Checking matadd result (C[0] should be 3.0): %f\n", matadd_C[0]);
        
        printf("First few elements:\n");
        printf("  gemm_C[0]: %f\n", gemm_C[0]);
        printf("  mm2_D[0]: %f\n", mm2_D[0]);
        printf("  matadd_C[0]: %f\n", matadd_C[0]);
    }
    
    // Free all allocated memory
    free(syr2k_A);
    free(syr2k_B);
    free(syr2k_C);
    free(gemm_A);
    free(gemm_B);
    free(gemm_C);
    free(mm2_tmp);
    free(mm2_A);
    free(mm2_B);
    free(mm2_C);
    free(mm2_D);
    free(matadd_A);
    free(matadd_B);
    free(matadd_C);
    free(unknown1);
    free(unknown2);
    free(unknown3);
    free(unknown4);
    free(unknown5);
    free(unknown6);
    free(unknown7);
    free(unknown8);
    free(unknown9);
    free(unknown10);
    free(unknown11);
    free(unknown12);
    free(unknown13);
    
    MPI_Finalize();
    return 0;
}
// gemm: C = A*B   (C is zero-initialised inside the kernel)
#define DHIR_BENCH_NAME "gemm"
#include "dhir_bench.h"

extern "C" void matmul(int32_t, int32_t, int32_t,
                       float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                       float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                       float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t);

static float *A, *B, *C, *C_ref;

static void bench_alloc(void) {
    A = dhir_alloc((long)DHIR_M * DHIR_K);
    B = dhir_alloc((long)DHIR_K * DHIR_N);
    C = dhir_alloc((long)DHIR_M * DHIR_N);
    C_ref = dhir_alloc((long)DHIR_M * DHIR_N);
    dhir_fill(A, (long)DHIR_M * DHIR_K, 1);
    dhir_fill(B, (long)DHIR_K * DHIR_N, 7);
    dhir_zero(C, (long)DHIR_M * DHIR_N);
}

static void bench_call(void) {
    matmul(DHIR_M, DHIR_N, DHIR_K,
           MR2(A, DHIR_M, DHIR_K),
           MR2(B, DHIR_K, DHIR_N),
           MR2(C, DHIR_M, DHIR_N));
}

static void bench_reference(void) {
    for (int i = 0; i < DHIR_M; ++i)
        for (int j = 0; j < DHIR_N; ++j) {
            float acc = 0.0f;
            for (int k = 0; k < DHIR_K; ++k)
                acc += A[(long)i * DHIR_K + k] * B[(long)k * DHIR_N + j];
            C_ref[(long)i * DHIR_N + j] = acc;
        }
}

static int bench_check(void) {
    return dhir_compare("C", C, C_ref, (long)DHIR_M * DHIR_N, DHIR_EPS);
}

static void bench_free(void) { free(A); free(B); free(C); free(C_ref); }

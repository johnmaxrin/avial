// add2d: C = A + B
#define DHIR_BENCH_NAME "add2d"
#include "dhir_bench.h"

extern "C" void matadd(int32_t, int32_t,
                       float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                       float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                       float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t);

static float *A, *B, *C, *C_ref;

static void bench_alloc(void) {
    long n = (long)DHIR_M * DHIR_N;
    A = dhir_alloc(n); B = dhir_alloc(n); C = dhir_alloc(n); C_ref = dhir_alloc(n);
    dhir_fill(A, n, 1);
    dhir_fill(B, n, 7);
    dhir_zero(C, n);
}

static void bench_call(void) {
    matadd(DHIR_M, DHIR_N,
           MR2(A, DHIR_M, DHIR_N),
           MR2(B, DHIR_M, DHIR_N),
           MR2(C, DHIR_M, DHIR_N));
}

static void bench_reference(void) {
    long n = (long)DHIR_M * DHIR_N;
    for (long i = 0; i < n; ++i) C_ref[i] = A[i] + B[i];
}

static int bench_check(void) {
    return dhir_compare("C", C, C_ref, (long)DHIR_M * DHIR_N, DHIR_EPS);
}

static void bench_free(void) { free(A); free(B); free(C); free(C_ref); }

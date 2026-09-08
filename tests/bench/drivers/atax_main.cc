// atax: tmp = A*x ; y = A^T*tmp
//
// The kernel accumulates into tmp and y without zeroing them, and fuses the
// two passes under one i loop. tmp[i] is complete before it is used, so this
// is algebraically the standard atax. Only the second inner loop is parallel;
// the first runs redundantly on every rank, which is correct only because tmp
// starts identical everywhere.
#define DHIR_BENCH_NAME "atax"
#include "dhir_bench.h"

extern "C" void kernel_atax(int32_t, int32_t,
                            float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                            float *, float *, int64_t, int64_t, int64_t,
                            float *, float *, int64_t, int64_t, int64_t,
                            float *, float *, int64_t, int64_t, int64_t);

static float *A, *x, *y, *tmp, *y_ref, *tmp_ref;

static void bench_alloc(void) {
    A = dhir_alloc((long)DHIR_M * DHIR_N);
    x = dhir_alloc(DHIR_N);
    y = dhir_alloc(DHIR_N);
    tmp = dhir_alloc(DHIR_M);
    y_ref = dhir_alloc(DHIR_N);
    tmp_ref = dhir_alloc(DHIR_M);

    dhir_fill(A, (long)DHIR_M * DHIR_N, 1);
    dhir_fill(x, DHIR_N, 7);
    dhir_zero(y, DHIR_N);
    dhir_zero(tmp, DHIR_M);
}

static void bench_call(void) {
    kernel_atax(DHIR_M, DHIR_N,
                MR2(A, DHIR_M, DHIR_N),
                MR1(x, DHIR_N),
                MR1(y, DHIR_N),
                MR1(tmp, DHIR_M));
}

static void bench_reference(void) {
    dhir_zero(y_ref, DHIR_N);
    dhir_zero(tmp_ref, DHIR_M);
    for (int i = 0; i < DHIR_M; ++i) {
        for (int j = 0; j < DHIR_N; ++j)
            tmp_ref[i] += A[(long)i * DHIR_N + j] * x[j];
        for (int j = 0; j < DHIR_N; ++j)
            y_ref[j] += A[(long)i * DHIR_N + j] * tmp_ref[i];
    }
}

static int bench_check(void) {
    return dhir_compare("y", y, y_ref, DHIR_N, DHIR_EPS);
}

static void bench_free(void) {
    free(A); free(x); free(y); free(tmp); free(y_ref); free(tmp_ref);
}

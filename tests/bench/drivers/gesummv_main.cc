// gesummv: tmp = A*x ; y = B*x ; y = alpha*tmp + beta*y
#define DHIR_BENCH_NAME "gesummv"
#include "dhir_bench.h"

extern "C" void kernel_gesummv(int32_t, float, float,
                               float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                               float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                               float *, float *, int64_t, int64_t, int64_t,
                               float *, float *, int64_t, int64_t, int64_t,
                               float *, float *, int64_t, int64_t, int64_t);

static const float ALPHA = 1.5f, BETA = 1.2f;
static float *A, *B, *tmp, *x, *y, *y_ref, *tmp_ref;

static void bench_alloc(void) {
    A = dhir_alloc((long)DHIR_N * DHIR_N);
    B = dhir_alloc((long)DHIR_N * DHIR_N);
    tmp = dhir_alloc(DHIR_N);
    x = dhir_alloc(DHIR_N);
    y = dhir_alloc(DHIR_N);
    y_ref = dhir_alloc(DHIR_N);
    tmp_ref = dhir_alloc(DHIR_N);

    dhir_fill(A, (long)DHIR_N * DHIR_N, 1);
    dhir_fill(B, (long)DHIR_N * DHIR_N, 7);
    dhir_fill(x, DHIR_N, 13);
    // Nonzero sentinel initialization: ensures that if the kernel omits
    // its required zero-initialization of tmp and y, the check will fail.
    dhir_fill(tmp, DHIR_N, 17);
    dhir_fill(y, DHIR_N, 23);
}

static void bench_call(void) {
    kernel_gesummv(DHIR_N, ALPHA, BETA,
                   MR2(A, DHIR_N, DHIR_N),
                   MR2(B, DHIR_N, DHIR_N),
                   MR1(tmp, DHIR_N),
                   MR1(x, DHIR_N),
                   MR1(y, DHIR_N));
}

static void bench_reference(void) {
    for (int i = 0; i < DHIR_N; ++i) {
        tmp_ref[i] = 0.0f;
        y_ref[i] = 0.0f;
        for (int j = 0; j < DHIR_N; ++j) {
            tmp_ref[i] += A[(long)i * DHIR_N + j] * x[j];
            y_ref[i] += B[(long)i * DHIR_N + j] * x[j];
        }
        y_ref[i] = ALPHA * tmp_ref[i] + BETA * y_ref[i];
    }
}

static int bench_check(void) {
    int e = dhir_compare("y", y, y_ref, DHIR_N, DHIR_EPS);
    e += dhir_compare("tmp", tmp, tmp_ref, DHIR_N, DHIR_EPS);
    return e;
}

static void bench_free(void) {
    free(A); free(B); free(tmp); free(x); free(y); free(y_ref); free(tmp_ref);
}

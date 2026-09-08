// gemver: A = A + u1*v1^T + u2*v2^T ; x = x + beta*A^T*y + z ; w = w + alpha*A*x
#define DHIR_BENCH_NAME "gemver"
#include "dhir_bench.h"

extern "C" void kernel_gemver(int32_t, float, float,
                              float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                              float *, float *, int64_t, int64_t, int64_t,
                              float *, float *, int64_t, int64_t, int64_t,
                              float *, float *, int64_t, int64_t, int64_t,
                              float *, float *, int64_t, int64_t, int64_t,
                              float *, float *, int64_t, int64_t, int64_t,
                              float *, float *, int64_t, int64_t, int64_t,
                              float *, float *, int64_t, int64_t, int64_t,
                              float *, float *, int64_t, int64_t, int64_t);

static const float ALPHA = 1.5f, BETA = 1.2f;
static float *A, *u1, *v1, *u2, *v2, *w, *x, *y, *z;
static float *A_init, *w_init, *x_init, *A_ref, *w_ref, *x_ref;

static void bench_alloc(void) {
    A = dhir_alloc((long)DHIR_N * DHIR_N);
    u1 = dhir_alloc(DHIR_N);
    v1 = dhir_alloc(DHIR_N);
    u2 = dhir_alloc(DHIR_N);
    v2 = dhir_alloc(DHIR_N);
    w = dhir_alloc(DHIR_N);
    x = dhir_alloc(DHIR_N);
    y = dhir_alloc(DHIR_N);
    z = dhir_alloc(DHIR_N);

    A_init = dhir_alloc((long)DHIR_N * DHIR_N);
    w_init = dhir_alloc(DHIR_N);
    x_init = dhir_alloc(DHIR_N);
    A_ref = dhir_alloc((long)DHIR_N * DHIR_N);
    w_ref = dhir_alloc(DHIR_N);
    x_ref = dhir_alloc(DHIR_N);

    dhir_fill(A, (long)DHIR_N * DHIR_N, 1);
    dhir_fill(u1, DHIR_N, 3);
    dhir_fill(v1, DHIR_N, 5);
    dhir_fill(u2, DHIR_N, 7);
    dhir_fill(v2, DHIR_N, 9);
    dhir_fill(w, DHIR_N, 11);
    dhir_fill(x, DHIR_N, 13);
    dhir_fill(y, DHIR_N, 17);
    dhir_fill(z, DHIR_N, 19);

    for (long i = 0; i < (long)DHIR_N * DHIR_N; ++i) A_init[i] = A[i];
    for (int i = 0; i < DHIR_N; ++i) {
        w_init[i] = w[i];
        x_init[i] = x[i];
    }
}

static void bench_call(void) {
    kernel_gemver(DHIR_N, ALPHA, BETA,
                  MR2(A, DHIR_N, DHIR_N),
                  MR1(u1, DHIR_N),
                  MR1(v1, DHIR_N),
                  MR1(u2, DHIR_N),
                  MR1(v2, DHIR_N),
                  MR1(w, DHIR_N),
                  MR1(x, DHIR_N),
                  MR1(y, DHIR_N),
                  MR1(z, DHIR_N));
}

static void bench_reference(void) {
    // 1. A = A + u1*v1^T + u2*v2^T
    for (int i = 0; i < DHIR_N; ++i)
        for (int j = 0; j < DHIR_N; ++j)
            A_ref[(long)i * DHIR_N + j] = A_init[(long)i * DHIR_N + j] +
                                          u1[i] * v1[j] + u2[i] * v2[j];

    // 2. x = x + beta*A^T*y
    for (int i = 0; i < DHIR_N; ++i) {
        x_ref[i] = x_init[i];
        for (int j = 0; j < DHIR_N; ++j)
            x_ref[i] += BETA * A_ref[(long)j * DHIR_N + i] * y[j];
    }

    // 3. x = x + z
    for (int i = 0; i < DHIR_N; ++i)
        x_ref[i] += z[i];

    // 4. w = w + alpha*A*x
    for (int i = 0; i < DHIR_N; ++i) {
        w_ref[i] = w_init[i];
        for (int j = 0; j < DHIR_N; ++j)
            w_ref[i] += ALPHA * A_ref[(long)i * DHIR_N + j] * x_ref[j];
    }
}

static int bench_check(void) {
    int e = dhir_compare("w", w, w_ref, DHIR_N, DHIR_EPS);
    e += dhir_compare("x", x, x_ref, DHIR_N, DHIR_EPS);
    e += dhir_compare("A", A, A_ref, (long)DHIR_N * DHIR_N, DHIR_EPS);
    return e;
}

static void bench_free(void) {
    free(A); free(u1); free(v1); free(u2); free(v2);
    free(w); free(x); free(y); free(z);
    free(A_init); free(w_init); free(x_init);
    free(A_ref); free(w_ref); free(x_ref);
}

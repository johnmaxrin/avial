// mvt: vx1 += A*vy1 ; vx2 += A^T*vy2
#define DHIR_BENCH_NAME "mvt"
#include "dhir_bench.h"

extern "C" void kernel_mvt(int32_t,
                           float *, float *, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t);

static float *vx1, *vx2, *vy1, *vy2, *A, *x1_init, *x2_init, *x1_ref, *x2_ref;

static void bench_alloc(void) {
    vx1 = dhir_alloc(DHIR_N); vx2 = dhir_alloc(DHIR_N);
    vy1 = dhir_alloc(DHIR_N); vy2 = dhir_alloc(DHIR_N);
    A = dhir_alloc((long)DHIR_N * DHIR_N);
    x1_init = dhir_alloc(DHIR_N); x2_init = dhir_alloc(DHIR_N);
    x1_ref = dhir_alloc(DHIR_N); x2_ref = dhir_alloc(DHIR_N);

    dhir_fill(vx1, DHIR_N, 1);
    dhir_fill(vx2, DHIR_N, 7);
    dhir_fill(vy1, DHIR_N, 13);
    dhir_fill(vy2, DHIR_N, 23);
    dhir_fill(A, (long)DHIR_N * DHIR_N, 31);
    for (int i = 0; i < DHIR_N; ++i) { x1_init[i] = vx1[i]; x2_init[i] = vx2[i]; }
}

static void bench_call(void) {
    kernel_mvt(DHIR_N,
               MR1(vx1, DHIR_N), MR1(vx2, DHIR_N),
               MR1(vy1, DHIR_N), MR1(vy2, DHIR_N),
               MR2(A, DHIR_N, DHIR_N));
}

static void bench_reference(void) {
    for (int i = 0; i < DHIR_N; ++i) {
        float acc = x1_init[i];
        for (int j = 0; j < DHIR_N; ++j) acc += A[(long)i * DHIR_N + j] * vy1[j];
        x1_ref[i] = acc;
    }
    for (int i = 0; i < DHIR_N; ++i) {
        float acc = x2_init[i];
        for (int j = 0; j < DHIR_N; ++j) acc += A[(long)j * DHIR_N + i] * vy2[j];
        x2_ref[i] = acc;
    }
}

static int bench_check(void) {
    int e = dhir_compare("vx1", vx1, x1_ref, DHIR_N, DHIR_EPS);
    e += dhir_compare("vx2", vx2, x2_ref, DHIR_N, DHIR_EPS);
    return e;
}

static void bench_free(void) {
    free(vx1); free(vx2); free(vy1); free(vy2); free(A);
    free(x1_init); free(x2_init); free(x1_ref); free(x2_ref);
}

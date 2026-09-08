// 3mm: E = A*B ; F = C*D ; G = E*F   (all three outputs zeroed in the kernel)
#define DHIR_BENCH_NAME "3mm"
#include "dhir_bench.h"

extern "C" void kernel_3mm(int32_t, int32_t, int32_t, int32_t, int32_t,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t);

static float *E, *A, *B, *F, *C, *D, *G, *E_ref, *F_ref, *G_ref;

static void bench_alloc(void) {
    E = dhir_alloc((long)DHIR_NI * DHIR_NJ);
    A = dhir_alloc((long)DHIR_NI * DHIR_NK);
    B = dhir_alloc((long)DHIR_NK * DHIR_NJ);
    F = dhir_alloc((long)DHIR_NJ * DHIR_NL);
    C = dhir_alloc((long)DHIR_NJ * DHIR_NM);
    D = dhir_alloc((long)DHIR_NM * DHIR_NL);
    G = dhir_alloc((long)DHIR_NI * DHIR_NL);
    E_ref = dhir_alloc((long)DHIR_NI * DHIR_NJ);
    F_ref = dhir_alloc((long)DHIR_NJ * DHIR_NL);
    G_ref = dhir_alloc((long)DHIR_NI * DHIR_NL);

    dhir_fill(A, (long)DHIR_NI * DHIR_NK, 1);
    dhir_fill(B, (long)DHIR_NK * DHIR_NJ, 7);
    dhir_fill(C, (long)DHIR_NJ * DHIR_NM, 13);
    dhir_fill(D, (long)DHIR_NM * DHIR_NL, 23);
    dhir_zero(E, (long)DHIR_NI * DHIR_NJ);
    dhir_zero(F, (long)DHIR_NJ * DHIR_NL);
    dhir_zero(G, (long)DHIR_NI * DHIR_NL);
}

static void bench_call(void) {
    kernel_3mm(DHIR_NI, DHIR_NJ, DHIR_NK, DHIR_NL, DHIR_NM,
               MR2(E, DHIR_NI, DHIR_NJ),
               MR2(A, DHIR_NI, DHIR_NK),
               MR2(B, DHIR_NK, DHIR_NJ),
               MR2(F, DHIR_NJ, DHIR_NL),
               MR2(C, DHIR_NJ, DHIR_NM),
               MR2(D, DHIR_NM, DHIR_NL),
               MR2(G, DHIR_NI, DHIR_NL));
}

static void mm(float *out, const float *l, const float *r, int m, int n, int k) {
    for (int i = 0; i < m; ++i)
        for (int j = 0; j < n; ++j) {
            float acc = 0.0f;
            for (int p = 0; p < k; ++p) acc += l[(long)i * k + p] * r[(long)p * n + j];
            out[(long)i * n + j] = acc;
        }
}

static void bench_reference(void) {
    mm(E_ref, A, B, DHIR_NI, DHIR_NJ, DHIR_NK);
    mm(F_ref, C, D, DHIR_NJ, DHIR_NL, DHIR_NM);
    mm(G_ref, E_ref, F_ref, DHIR_NI, DHIR_NL, DHIR_NJ);
}

static int bench_check(void) {
    int e = dhir_compare("E", E, E_ref, (long)DHIR_NI * DHIR_NJ, DHIR_EPS);
    e += dhir_compare("F", F, F_ref, (long)DHIR_NJ * DHIR_NL, DHIR_EPS);
    e += dhir_compare("G", G, G_ref, (long)DHIR_NI * DHIR_NL, DHIR_EPS);
    return e;
}

static void bench_free(void) {
    free(E); free(A); free(B); free(F); free(C); free(D); free(G);
    free(E_ref); free(F_ref); free(G_ref);
}

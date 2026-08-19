// 2mm: D = alpha*A*B ; E = beta*E + D*C
//
// E is read-modify-written by the kernel, so the reference needs E's initial
// contents, so we keep a pristine copy before the call.
#define DHIR_BENCH_NAME "2mm"
#include "dhir_bench.h"

extern "C" void kernel_2mm(int32_t, int32_t, int32_t, int32_t, float, float,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                           float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t);

static const float ALPHA = 1.5f, BETA = 0.75f;
static float *D, *A, *B, *C, *E, *E_init, *E_ref, *D_ref;

static void bench_alloc(void) {
    D = dhir_alloc((long)DHIR_NI * DHIR_NJ);
    A = dhir_alloc((long)DHIR_NI * DHIR_NK);
    B = dhir_alloc((long)DHIR_NK * DHIR_NJ);
    C = dhir_alloc((long)DHIR_NJ * DHIR_NL);
    E = dhir_alloc((long)DHIR_NI * DHIR_NL);
    E_init = dhir_alloc((long)DHIR_NI * DHIR_NL);
    E_ref = dhir_alloc((long)DHIR_NI * DHIR_NL);
    D_ref = dhir_alloc((long)DHIR_NI * DHIR_NJ);

    dhir_fill(A, (long)DHIR_NI * DHIR_NK, 1);
    dhir_fill(B, (long)DHIR_NK * DHIR_NJ, 7);
    dhir_fill(C, (long)DHIR_NJ * DHIR_NL, 13);
    dhir_fill(E, (long)DHIR_NI * DHIR_NL, 23);
    dhir_zero(D, (long)DHIR_NI * DHIR_NJ);
    for (long i = 0; i < (long)DHIR_NI * DHIR_NL; ++i) E_init[i] = E[i];
}

static void bench_call(void) {
    kernel_2mm(DHIR_NI, DHIR_NJ, DHIR_NK, DHIR_NL, ALPHA, BETA,
               MR2(D, DHIR_NI, DHIR_NJ),
               MR2(A, DHIR_NI, DHIR_NK),
               MR2(B, DHIR_NK, DHIR_NJ),
               MR2(C, DHIR_NJ, DHIR_NL),
               MR2(E, DHIR_NI, DHIR_NL));
}

static void bench_reference(void) {
    for (int i = 0; i < DHIR_NI; ++i)
        for (int j = 0; j < DHIR_NJ; ++j) {
            float acc = 0.0f;
            for (int k = 0; k < DHIR_NK; ++k)
                acc += ALPHA * A[(long)i * DHIR_NK + k] * B[(long)k * DHIR_NJ + j];
            D_ref[(long)i * DHIR_NJ + j] = acc;
        }

    for (int i = 0; i < DHIR_NI; ++i)
        for (int j = 0; j < DHIR_NL; ++j) {
            float acc = E_init[(long)i * DHIR_NL + j] * BETA;
            for (int k = 0; k < DHIR_NJ; ++k)
                acc += D_ref[(long)i * DHIR_NJ + k] * C[(long)k * DHIR_NL + j];
            E_ref[(long)i * DHIR_NL + j] = acc;
        }
}

static int bench_check(void) {
    int e = dhir_compare("D", D, D_ref, (long)DHIR_NI * DHIR_NJ, DHIR_EPS);
    e += dhir_compare("E", E, E_ref, (long)DHIR_NI * DHIR_NL, DHIR_EPS);
    return e;
}

static void bench_free(void) {
    free(D); free(A); free(B); free(C); free(E);
    free(E_init); free(E_ref); free(D_ref);
}

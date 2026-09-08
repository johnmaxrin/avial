// doitgen: sum[r][q][p] = sum_s A[r][q][s]*C4[s][p] ; then A = sum
//
// A is overwritten in place, so we keep a pristine copy before the call.
#define DHIR_BENCH_NAME "doitgen"
#include "dhir_bench.h"

extern "C" void kernel_doitgen(int32_t, int32_t, int32_t,
                               float *, float *, int64_t, int64_t, int64_t, int64_t,
                               int64_t, int64_t, int64_t,
                               float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                               float *, float *, int64_t, int64_t, int64_t, int64_t,
                               int64_t, int64_t, int64_t);

static float *A, *C4, *sum, *A_init, *A_ref;

static long a_elems(void) { return (long)DHIR_NR * DHIR_NQ * DHIR_NP; }

static void bench_alloc(void) {
    A = dhir_alloc(a_elems());
    C4 = dhir_alloc((long)DHIR_NP * DHIR_NP);
    sum = dhir_alloc(a_elems());
    A_init = dhir_alloc(a_elems());
    A_ref = dhir_alloc(a_elems());

    dhir_fill(A, a_elems(), 1);
    dhir_fill(C4, (long)DHIR_NP * DHIR_NP, 7);
    dhir_zero(sum, a_elems());
    for (long i = 0; i < a_elems(); ++i) A_init[i] = A[i];
}

static void bench_call(void) {
    kernel_doitgen(DHIR_NR, DHIR_NQ, DHIR_NP,
                   MR3(A, DHIR_NR, DHIR_NQ, DHIR_NP),
                   MR2(C4, DHIR_NP, DHIR_NP),
                   MR3(sum, DHIR_NR, DHIR_NQ, DHIR_NP));
}

static void bench_reference(void) {
    for (int r = 0; r < DHIR_NR; ++r)
        for (int q = 0; q < DHIR_NQ; ++q) {
            long base = ((long)r * DHIR_NQ + q) * DHIR_NP;
            for (int p = 0; p < DHIR_NP; ++p) {
                float acc = 0.0f;
                for (int s = 0; s < DHIR_NP; ++s)
                    acc += A_init[base + s] * C4[(long)s * DHIR_NP + p];
                A_ref[base + p] = acc;
            }
        }
}

static int bench_check(void) {
    return dhir_compare("A", A, A_ref, a_elems(), DHIR_EPS);
}

static void bench_free(void) {
    free(A); free(C4); free(sum); free(A_init); free(A_ref);
}

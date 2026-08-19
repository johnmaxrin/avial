// jacobi: T sweeps of a 1-D 3-point stencil over [1, N-1)
//
// The kernel widens the 3-point sum to f64, scales, then narrows back to f32.
// We mirror that exactly; doing the scale in f32 would drift and
// compound into false failures over T sweeps.
#define DHIR_BENCH_NAME "jacobi"
#include "dhir_bench.h"

extern "C" void kernel_jacobi(int32_t, int32_t,
                              float *, float *, int64_t, int64_t, int64_t,
                              float *, float *, int64_t, int64_t, int64_t);

static const double COEF = 3.333300e-01;

static float *A, *B, *A_init, *A_ref, *B_ref;

static void bench_alloc(void) {
    A = dhir_alloc(DHIR_N); B = dhir_alloc(DHIR_N);
    A_init = dhir_alloc(DHIR_N);
    A_ref = dhir_alloc(DHIR_N); B_ref = dhir_alloc(DHIR_N);

    dhir_fill(A, DHIR_N, 1);
    dhir_zero(B, DHIR_N);
    for (int i = 0; i < DHIR_N; ++i) A_init[i] = A[i];
}

static void bench_call(void) {
    kernel_jacobi(DHIR_T, DHIR_N, MR1(A, DHIR_N), MR1(B, DHIR_N));
}

static void bench_reference(void) {
    for (int i = 0; i < DHIR_N; ++i) { A_ref[i] = A_init[i]; B_ref[i] = 0.0f; }
    for (int t = 0; t < DHIR_T; ++t) {
        for (int i = 1; i < DHIR_N - 1; ++i) {
            float s = A_ref[i - 1] + A_ref[i];
            s = s + A_ref[i + 1];
            B_ref[i] = (float)((double)s * COEF);
        }
        for (int i = 1; i < DHIR_N - 1; ++i) A_ref[i] = B_ref[i];
    }
}

static int bench_check(void) {
    return dhir_compare("A", A, A_ref, DHIR_N, DHIR_EPS);
}

static void bench_free(void) { free(A); free(B); free(A_init); free(A_ref); free(B_ref); }

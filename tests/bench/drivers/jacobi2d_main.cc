// jacobi2d: T sweeps of a 2-D 5-point stencil over [1, N-1)^2
//
// Summation order matters in f32, so we add the five points in the same order
// the kernel emits: centre, west, east, south, north, then widen to f64 for the
// scale and narrow back, exactly as the kernel does.
#define DHIR_BENCH_NAME "jacobi2d"
#include "dhir_bench.h"

extern "C" void kernel_jacobi_2d(int32_t, int32_t,
                                 float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                                 float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t);

static const double COEF = 2.000000e-01;

static float *A, *B, *A_init, *A_ref, *B_ref;

static long n2(void) { return (long)DHIR_N * DHIR_N; }
#define AT(p, i, j) (p)[(long)(i) * DHIR_N + (j)]

static void bench_alloc(void) {
    A = dhir_alloc(n2()); B = dhir_alloc(n2());
    A_init = dhir_alloc(n2());
    A_ref = dhir_alloc(n2()); B_ref = dhir_alloc(n2());

    dhir_fill(A, n2(), 1);
    dhir_zero(B, n2());
    for (long i = 0; i < n2(); ++i) A_init[i] = A[i];
}

static void bench_call(void) {
    kernel_jacobi_2d(DHIR_T, DHIR_N,
                     MR2(A, DHIR_N, DHIR_N),
                     MR2(B, DHIR_N, DHIR_N));
}

static void bench_reference(void) {
    for (long i = 0; i < n2(); ++i) { A_ref[i] = A_init[i]; B_ref[i] = 0.0f; }
    for (int t = 0; t < DHIR_T; ++t) {
        for (int i = 1; i < DHIR_N - 1; ++i)
            for (int j = 1; j < DHIR_N - 1; ++j) {
                float s = AT(A_ref, i, j) + AT(A_ref, i, j - 1);
                s = s + AT(A_ref, i, j + 1);
                s = s + AT(A_ref, i + 1, j);
                s = s + AT(A_ref, i - 1, j);
                AT(B_ref, i, j) = (float)((double)s * COEF);
            }
        for (int i = 1; i < DHIR_N - 1; ++i)
            for (int j = 1; j < DHIR_N - 1; ++j)
                AT(A_ref, i, j) = AT(B_ref, i, j);
    }
}

static int bench_check(void) {
    return dhir_compare("A", A, A_ref, n2(), DHIR_EPS);
}

static void bench_free(void) { free(A); free(B); free(A_init); free(A_ref); free(B_ref); }

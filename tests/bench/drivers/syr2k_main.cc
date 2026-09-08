// syr2k: C = beta*C + alpha*(A*B^T + B*A^T)
//
// C is read-modify-written, so the reference needs its initial contents.
#define DHIR_BENCH_NAME "syr2k"
#include "dhir_bench.h"

extern "C" void kernel_syr2k(int32_t, int32_t, float, float,
                             float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                             float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t,
                             float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t);

static const float ALPHA = 1.5f, BETA = 0.75f;
static float *C, *A, *B, *C_init, *C_ref;

static void bench_alloc(void) {
    C = dhir_alloc((long)DHIR_N * DHIR_N);
    A = dhir_alloc((long)DHIR_N * DHIR_M);
    B = dhir_alloc((long)DHIR_N * DHIR_M);
    C_init = dhir_alloc((long)DHIR_N * DHIR_N);
    C_ref = dhir_alloc((long)DHIR_N * DHIR_N);

    dhir_fill(C, (long)DHIR_N * DHIR_N, 1);
    dhir_fill(A, (long)DHIR_N * DHIR_M, 7);
    dhir_fill(B, (long)DHIR_N * DHIR_M, 13);
    for (long i = 0; i < (long)DHIR_N * DHIR_N; ++i) C_init[i] = C[i];
}

static void bench_call(void) {
    kernel_syr2k(DHIR_N, DHIR_M, ALPHA, BETA,
                 MR2(C, DHIR_N, DHIR_N),
                 MR2(A, DHIR_N, DHIR_M),
                 MR2(B, DHIR_N, DHIR_M));
}

static void bench_reference(void) {
    for (int i = 0; i < DHIR_N; ++i)
        for (int j = 0; j < DHIR_N; ++j)
            C_ref[(long)i * DHIR_N + j] = C_init[(long)i * DHIR_N + j] * BETA;

    for (int i = 0; i < DHIR_N; ++i)
        for (int j = 0; j < DHIR_N; ++j) {
            float acc = C_ref[(long)i * DHIR_N + j];
            for (int k = 0; k < DHIR_M; ++k) {
                acc += ALPHA * A[(long)i * DHIR_M + k] * B[(long)j * DHIR_M + k];
                acc += ALPHA * B[(long)i * DHIR_M + k] * A[(long)j * DHIR_M + k];
            }
            C_ref[(long)i * DHIR_N + j] = acc;
        }
}

static int bench_check(void) {
    return dhir_compare("C", C, C_ref, (long)DHIR_N * DHIR_N, DHIR_EPS);
}

static void bench_free(void) { free(C); free(A); free(B); free(C_init); free(C_ref); }

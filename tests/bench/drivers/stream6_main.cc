// stream6: Out[i] = sum_j(A+B+C+D+E+F)[i,j]
#define DHIR_BENCH_NAME "stream6"
#include "dhir_bench.h"

#define MR2_ABI float *, float *, int64_t, int64_t, int64_t, int64_t, int64_t
#define MR1_ABI float *, float *, int64_t, int64_t, int64_t
extern "C" void stream6(int32_t, int32_t,
                         MR2_ABI, MR2_ABI, MR2_ABI, MR2_ABI,
                         MR2_ABI, MR2_ABI, MR1_ABI);
#undef MR1_ABI
#undef MR2_ABI

static float *A, *B, *C, *D, *E, *F, *Out, *Out_ref;

static void bench_alloc(void) {
    long n = (long)DHIR_M * DHIR_N;
    A = dhir_alloc(n); B = dhir_alloc(n); C = dhir_alloc(n);
    D = dhir_alloc(n); E = dhir_alloc(n); F = dhir_alloc(n);
    Out = dhir_alloc(DHIR_M); Out_ref = dhir_alloc(DHIR_M);
    dhir_fill(A, n, 1);  dhir_fill(B, n, 7);  dhir_fill(C, n, 13);
    dhir_fill(D, n, 23); dhir_fill(E, n, 31); dhir_fill(F, n, 43);
    dhir_zero(Out, DHIR_M);
}

static void bench_call(void) {
    stream6(DHIR_M, DHIR_N,
            MR2(A, DHIR_M, DHIR_N), MR2(B, DHIR_M, DHIR_N),
            MR2(C, DHIR_M, DHIR_N), MR2(D, DHIR_M, DHIR_N),
            MR2(E, DHIR_M, DHIR_N), MR2(F, DHIR_M, DHIR_N),
            MR1(Out, DHIR_M));
}

static void bench_reference(void) {
    dhir_zero(Out_ref, DHIR_M);
    for (int i = 0; i < DHIR_M; ++i) {
        for (int j = 0; j < DHIR_N; ++j) {
            long index = (long)i * DHIR_N + j;
            float value = A[index] + B[index];
            value += C[index];
            value += D[index];
            value += E[index];
            value += F[index];
            Out_ref[i] += value;
        }
    }
}

static int bench_check(void) {
    return dhir_compare("Out", Out, Out_ref, DHIR_M, DHIR_EPS);
}

static void bench_free(void) {
    free(A); free(B); free(C); free(D); free(E); free(F);
    free(Out); free(Out_ref);
}

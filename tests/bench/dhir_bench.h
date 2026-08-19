// Unified C++ driver framework: manages MLIR MemRef struct 
// descriptors, MPI_Wtime lifecycle, and tolerance checking.
//
// Each driver supplies five hooks and gets main(), MPI lifecycle, timing, the
// correctness gate, and a machine-readable result line for free:
//
//   bench_alloc()      allocate and deterministically initialise inputs
//   bench_call()       call the compiled kernel
//   bench_reference()  compute the sequential reference on rank 0
//   bench_check()      compare kernel output against reference, return #errors
//   bench_free()       release
//
// The driver owns the MPI lifecycle: run_bench.sh strips MPI_Init/MPI_Finalize
// out of the lowered IR so that timing can start before the kernel is entered.
//
// Problem sizes are never hardcoded here, they come from
// generated bench_sizes.h, which is derived from
// kernel's own .mlir, See tests/bench/kernels.py.
#pragma once

#include <mpi.h>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>

#include "bench_sizes.h"

#ifndef DHIR_BENCH_NAME
#error "define DHIR_BENCH_NAME before including dhir_bench.h"
#endif

// Default tolerance. Kernels that accumulate over long reductions raise it.
#ifndef DHIR_EPS
#define DHIR_EPS 1e-3f
#endif

// ---------------------------------------------------------------------------
// memref descriptor ABI
//
// MLIR lowers a memref argument to (allocated, aligned, offset, sizes,
// strides). Getting these wrong will result in silent corruption, so we
// build them here rather than by hand at each call site, old drivers passed
// zeros for sizes and strides.
// ---------------------------------------------------------------------------
#define MR1(p, d0) \
    (p), (p), (int64_t)0, (int64_t)(d0), (int64_t)1
#define MR2(p, d0, d1) \
    (p), (p), (int64_t)0, (int64_t)(d0), (int64_t)(d1), (int64_t)(d1), (int64_t)1
#define MR3(p, d0, d1, d2)                                                  \
    (p), (p), (int64_t)0, (int64_t)(d0), (int64_t)(d1), (int64_t)(d2),      \
        (int64_t)((d1) * (d2)), (int64_t)(d2), (int64_t)1

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

// Deterministic and identical on every rank, so all ranks start from the same
// data and a divergence is the kernel's doing rather than the input's.
static inline float dhir_val(long i) {
    return (float)((i * 1103515245L + 12345L) % 1000) / 1000.0f;
}

static inline float *dhir_alloc(long n) {
    float *p = (float *)aligned_alloc(64, ((size_t)n * sizeof(float) + 63) / 64 * 64);
    if (!p) {
        fprintf(stderr, "%s: allocation of %ld floats failed\n", DHIR_BENCH_NAME, n);
        exit(2);
    }
    return p;
}

static inline void dhir_fill(float *p, long n, long seed) {
    for (long i = 0; i < n; ++i) p[i] = dhir_val(i + seed);
}

static inline void dhir_zero(float *p, long n) {
    for (long i = 0; i < n; ++i) p[i] = 0.0f;
}

// Relative comparison: these kernels accumulate over up to N terms, so a fixed
// absolute epsilon would either reject correct results or accept wrong ones
// depending on the magnitude.
static inline int dhir_compare(const char *what, const float *got,
                               const float *want, long n, float eps) {
    int errors = 0;
    for (long i = 0; i < n; ++i) {
        float w = want[i], g = got[i];
        float tol = eps * (std::fabs(w) > 1.0f ? std::fabs(w) : 1.0f);
        if (!(std::fabs(g - w) <= tol)) {
            if (errors < 5)
                printf("  mismatch %s[%ld]: got %.6f want %.6f\n", what, i, g, w);
            ++errors;
        }
    }
    if (errors > 5) printf("  ... and %d more in %s\n", errors - 5, what);
    return errors;
}

// ---------------------------------------------------------------------------
// MPI lifecycle
//
// The lowered kernel opens with MPI_Init and closes with MPI_Finalize, but the
// driver has to own the lifecycle: timing starts before the kernel is entered,
// and the correctness check runs after it returns. run_bench.sh so
// redirects those two calls in the generated .ll to the stubs below.
//
// Redirecting rather than deleting the calls keeps the SSA structure intact,
// dropping the lines outright would leave dangling uses of their results.
// ---------------------------------------------------------------------------
extern "C" int dhir_noop_mpi_init(void *, void *) { return 0; }
extern "C" int dhir_noop_mpi_finalize(void) { return 0; }

// ---------------------------------------------------------------------------
// hooks supplied by the driver
// ---------------------------------------------------------------------------
static void bench_alloc(void);
static void bench_call(void);
static void bench_reference(void);
static int bench_check(void);
static void bench_free(void);

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);

    int rank = 0, nranks = 1;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nranks);

    bench_alloc();

    MPI_Barrier(MPI_COMM_WORLD);
    double t0 = MPI_Wtime();
    bench_call();
    double elapsed = MPI_Wtime() - t0;

    double max_elapsed = elapsed;
    MPI_Reduce(&elapsed, &max_elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);

    // Only rank 0 is checked, and deliberately so: there is no end-of-schedule
    // gather, so rank 0 holds the complete result only if every per-level
    // gather moved its full slice.
    int failed = 0;
    if (rank == 0) {
        bench_reference();
        int errors = bench_check();
        failed = errors ? 1 : 0;
        printf("RESULT kernel=%s ranks=%d seconds=%.6f status=%s errors=%d\n",
               DHIR_BENCH_NAME, nranks, max_elapsed, failed ? "FAIL" : "PASS",
               errors);
    }

    MPI_Bcast(&failed, 1, MPI_INT, 0, MPI_COMM_WORLD);
    bench_free();
    MPI_Finalize();
    return failed;
}

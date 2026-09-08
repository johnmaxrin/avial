// Quantifies OpenMP parallel region dispatch and synchronization latency for the roofline h coefficient.
//
// Modeling recurring parallel region entry latency is essential for iterative computations (such as
// stencils like jacobi, which enter parallel sections 200 times across 100 timesteps), in contrast
// to single-entry kernels like gemm. Omitting this overhead caused systematic ~4x under-estimations
// on iterative workloads. This microbenchmark supplies direct empirical measurements of h, replacing
// statistical regression fits with explicit hardware profiling.
//
// Experimental protocol: measures differential elapsed time for launching and terminating an
// omp parallel for loop around a minimal payload under target thread affinities. Subtracting the
// runtime of an identical unparallelized sequential loop extracts net synchronization and team
// entry overhead while filtering out arithmetic compute cost.
//
//   Compilation: c++ -O2 -fopenmp -o omp_entry omp_entry_main.cc
//   Execution:   OMP_NUM_THREADS=16 ./omp_entry [iters]
//
// Emits CSV formatted records: CALIBRATION,omp_entry,<threads>,<iters>,<seconds_per_entry>
// compatible with ingestion pipelines in pingpong_main.cc.
#include <cstdio>
#include <cstdlib>
#include <vector>

#ifdef _OPENMP
#include <omp.h>
#endif

#include <chrono>

using clk = std::chrono::steady_clock;
static double seconds_since(clk::time_point t) {
    return std::chrono::duration<double>(clk::now() - t).count();
}

int main(int argc, char **argv) {
    const long iters = argc > 1 ? atol(argv[1]) : 20000;

    // Array dimensions are chosen to ensure compute latency remains negligible compared to
    // region invocation overhead, while remaining non-trivial to prevent dead-code elimination.
    const int n = 64;
    std::vector<double> a(n, 1.0), b(n, 2.0);

#ifdef _OPENMP
    const int threads = omp_get_max_threads();
#else
    const int threads = 1;
#endif

    // Initial warmup iterations: amortizes thread pool creation latency (a one-time
    // launch expense, isolated from recurrent per-invocation synchronization overhead h).
    for (int w = 0; w < 100; ++w) {
#pragma omp parallel for
        for (int i = 0; i < n; ++i) a[i] += b[i];
    }

    auto t0 = clk::now();
    for (long it = 0; it < iters; ++it) {
#pragma omp parallel for
        for (int i = 0; i < n; ++i) a[i] += b[i];
    }
    const double with_region = seconds_since(t0);

    // Executes an identical iteration count sequentially to isolate and subtract
    // raw computational latency from the parallel dispatch overhead.
    auto t1 = clk::now();
    for (long it = 0; it < iters; ++it)
        for (int i = 0; i < n; ++i) a[i] += b[i];
    const double body_only = seconds_since(t1);

    const double per_entry = (with_region - body_only) / double(iters);

    printf("CALIBRATION,omp_entry,%d,%ld,%.9g\n", threads, iters, per_entry);
    printf("# threads=%d  with_region=%.6f s  body_only=%.6f s  "
           "per_entry=%.3f us  (checksum %.1f)\n",
           threads, with_region, body_only, per_entry * 1e6, a[0]);
    return 0;
}

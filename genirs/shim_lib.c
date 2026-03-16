// profile_shim.c
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <time.h>
#include <mpi.h>
#include <stdint.h>

// --- Timing helpers ---
static double get_time_ms()
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1e3 + ts.tv_nsec * 1e-6;
}

// --- Accumulated stats ---
static double mpi_send_ms = 0.0;
static double mpi_recv_ms = 0.0;
static double mpi_barrier_ms = 0.0;
static double gpu_memcpy_h2d_ms = 0.0;
static double gpu_memcpy_d2h_ms = 0.0;
static double gpu_sync_ms = 0.0;
static double gpu_memcpy_ms = 0.0;

static long mpi_send_calls = 0;
static long mpi_recv_calls = 0;
static long mpi_barrier_calls = 0;
static long gpu_memcpy_calls = 0;
static long gpu_sync_calls = 0;

// ---- MPI wrappers ----
static int my_rank = -1;

int MPI_Send(const void *buf, int count, MPI_Datatype dtype,
             int dest, int tag, MPI_Comm comm)
{
    static int (*real_fn)() = NULL;
    if (!real_fn)
        real_fn = dlsym(RTLD_NEXT, "MPI_Send");
    double t0 = get_time_ms();
    int r = real_fn(buf, count, dtype, dest, tag, comm);
    mpi_send_ms += get_time_ms() - t0;
    mpi_send_calls++;
    return r;
}

int MPI_Recv(void *buf, int count, MPI_Datatype dtype,
             int src, int tag, MPI_Comm comm, MPI_Status *status)
{
    static int (*real_fn)() = NULL;
    if (!real_fn)
        real_fn = dlsym(RTLD_NEXT, "MPI_Recv");
    double t0 = get_time_ms();
    int r = real_fn(buf, count, dtype, src, tag, comm, status);
    mpi_recv_ms += get_time_ms() - t0;
    mpi_recv_calls++;
    return r;
}

int MPI_Barrier(MPI_Comm comm)
{
    static int (*real_fn)() = NULL;
    MPI_Comm_rank(comm, &my_rank);
    if (!real_fn)
        real_fn = dlsym(RTLD_NEXT, "MPI_Barrier");
    double t0 = get_time_ms();
    int r = real_fn(comm);
    mpi_barrier_ms += get_time_ms() - t0;
    mpi_barrier_calls++;
    return r;
}

// ---- GPU wrappers ----
// mgpuMemcpy signature from your IR:
// void mgpuMemcpy(ptr dst, ptr src, i64 size, ptr stream)
// We can't distinguish H2D vs D2H from pointers alone without CUDA API,
// so we track total and use heuristics or CUDA pointer queries.

void mgpuMemcpy(void *dst, void *src, uint64_t size, void *stream)
{
    static void (*real_fn)() = NULL;
    if (!real_fn)
        real_fn = dlsym(RTLD_NEXT, "mgpuMemcpy");
    double t0 = get_time_ms();
    real_fn(dst, src, size, stream);
    // Note: this measures launch time, not completion.
    // Use mgpuStreamSynchronize timing for wall time.
    gpu_memcpy_ms += get_time_ms() - t0;
    gpu_memcpy_calls++;
}

void mgpuStreamSynchronize(void *stream)
{
    static void (*real_fn)() = NULL;
    if (!real_fn)
     if (!real_fn) {
        fprintf(stderr, "FAILED to find mgpuStreamSynchronize: %s\n", dlerror());
        return;
    }
    double t0 = get_time_ms();
    real_fn(stream);
    gpu_sync_ms += get_time_ms() - t0; // THIS is the real H<->D transfer time
    gpu_sync_calls++;
}

// ---- Print report at exit ----
static void __attribute__((destructor)) print_profile()
{

    fprintf(stderr,
            "\n[PROFILE rank=%d]\n"
            "  MPI_Send     : %6.2f ms  (%ld calls)\n"
            "  MPI_Recv     : %6.2f ms  (%ld calls)\n"
            "  MPI_Barrier  : %6.2f ms  (%ld calls)\n"
            "  MPI total    : %6.2f ms\n"
            "  GPU memcpy   : %6.2f ms  (%ld calls, launch overhead)\n"
            "  GPU sync     : %6.2f ms  (%ld calls, actual H<->D wait)\n",
            my_rank,
            mpi_send_ms, mpi_send_calls,
            mpi_recv_ms, mpi_recv_calls,
            mpi_barrier_ms, mpi_barrier_calls,
            mpi_send_ms + mpi_recv_ms + mpi_barrier_ms,
            gpu_memcpy_ms, gpu_memcpy_calls,
            gpu_sync_ms, gpu_sync_calls);
}
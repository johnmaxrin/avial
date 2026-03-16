#include <iostream>
#include <cmath>
#include <cstdlib>
#include <mpi.h>

extern "C" void kernel_bicg(
    int, int,
    float *, float *, long, long, long,
    float *, float *, long, long, long,
    float *, float *, long, long, long,
    float *, float *, long, long, long,
    float *, float *, long, long, long);

void bicg_reference(
    int N, int M,
    float *A,
    float *s,
    float *q,
    float *p,
    float *r)
{
    for (int j = 0; j < M; j++)
        s[j] = 0.0f;

    for (int i = 0; i < N; i++)
        q[i] = 0.0f;

    for (int i = 0; i < N; i++)
        for (int j = 0; j < M; j++)
        {
            s[j] += r[i] * A[i * M + j];
            q[i] += A[i * M + j] * p[j];
        }
}

bool verify(int N, int M, float *s, float *q, float *s_ref, float *q_ref)
{
    const float eps = 1e-3;

    for (int i = 0; i < M; i++)
        if (std::fabs(s[i] - s_ref[i]) > eps)
        {
            std::cout << "Mismatch in s at " << i << " "
                      << s[i] << " vs " << s_ref[i] << "\n";
            return false;
        }

    for (int i = 0; i < N; i++)
        if (std::fabs(q[i] - q_ref[i]) > eps)
        {
            std::cout << "Mismatch in q at " << i << " "
                      << q[i] << " vs " << q_ref[i] << "\n";
            return false;
        }

    return true;
}

int main()
{
    const int N = 1000;
    const int M = 1000;

    float *A = (float *)malloc(sizeof(float) * N * M);
    float *s = (float *)malloc(sizeof(float) * M);
    float *q = (float *)malloc(sizeof(float) * N);
    float *p = (float *)malloc(sizeof(float) * M);
    float *r = (float *)malloc(sizeof(float) * N);

    float *s_ref = (float *)malloc(sizeof(float) * M);
    float *q_ref = (float *)malloc(sizeof(float) * N);

    for (int i = 0; i < N * M; i++)
        A[i] = (float)(i % 100) / 100.0f;
    for (int i = 0; i < M; i++)
        p[i] = (float)(i % 50) / 50.0f;
    for (int i = 0; i < N; i++)
        r[i] = (float)(i % 70) / 70.0f;

    bicg_reference(N, M, A, s_ref, q_ref, p, r);

    printf("Calling Bicg Kernel\n");

    kernel_bicg(
        N, M,
        A, A, 0, N, M,
        s, s, 0, M, 1,
        q, q, 0, N, 1,
        p, p, 0, M, 1,
        r, r, 0, N, 1);

    int rank = 0;

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (rank == 0)
    {
        bool ok = verify(N, M, s, q, s_ref, q_ref);

        if (ok)
            std::cout << "Verification PASSED\n";
        else
            std::cout << "Verification FAILED\n";
    }

    free(A);
    free(s);
    free(q);
    free(p);
    free(r);
    free(s_ref);
    free(q_ref);

    return 0;
}
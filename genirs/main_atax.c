#include <iostream>
#include <cmath>
#include <mpi.h>
#include <cstdlib>

constexpr int M = 1280;
constexpr int N = 1280;
constexpr float EPS = 1e-4f;

extern "C" void kernel_atax(
    int, int,
    float*, float*,
    long,long,long,long,long,
    float*, float*,
    long,long,long,
    float*, float*,
    long,long,long,
    float*, float*,
    long,long,long);

/* reference ATAX */
void atax_reference(float *A, float *x, float *y)
{
    float tmp[M];

    for (int i = 0; i < M; i++)
    {
        tmp[i] = 0.0f;
        for (int j = 0; j < N; j++)
            tmp[i] += A[i*N + j] * x[j];
    }

    for (int j = 0; j < N; j++)
    {
        y[j] = 0.0f;
        for (int i = 0; i < M; i++)
            y[j] += A[i*N + j] * tmp[i];
    }
}

int main(int argc, char **argv)
{

    // MPI_Init(nullptr, nullptr);

    float *A = (float*)malloc(sizeof(float) * M * N);
    float *x = (float*)malloc(sizeof(float) * N);
    float *y_kernel = (float*)malloc(sizeof(float) * N);
    float *y_ref = (float*)malloc(sizeof(float) * N);
    float *tmp = (float*)malloc(sizeof(float) * N);

    /* initialize */
    for (int i = 0; i < M; i++)
        for (int j = 0; j < N; j++)
            A[i*N + j] = (float)((i * j) % 100) / 100.0f;

    for (int i = 0; i < N; i++)
        x[i] = (float)(i % 50) / 50.0f;

    for (int i = 0; i < N; i++)
        y_kernel[i] = 0.0f;

    printf("Calling Atax Kernel\n");

    kernel_atax(
        M, N,
        A, x,
        0,0,0,0,0,
        y_kernel, tmp,
        0,0,0,
        nullptr,nullptr,
        0,0,0,
        nullptr,nullptr,
        0,0,0
    );

    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if(rank == 0)
    {
        atax_reference(A, x, y_ref);

        int errors = 0;

        for(int i = 0; i < N; i++)
        {
            if(std::fabs(y_kernel[i] - y_ref[i]) > EPS)
            {
                std::cout << "Mismatch at " << i
                          << " kernel=" << y_kernel[i]
                          << " ref=" << y_ref[i] << std::endl;
                errors++;
            }
        }

        if(errors == 0)
            std::cout << "PASS\n";
        else
            std::cout << "FAIL: " << errors << " mismatches\n";
    }

    free(A);
    free(x);
    free(y_kernel);
    free(y_ref);
    free(tmp);

    MPI_Finalize();
    return 0;
}
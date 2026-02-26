// Minimal Jacobi 1D stencil - matches the MLIR polybench version
// This is the exact algorithm that your MLIR compiler transforms

#include <iostream>
#include <cstdlib>
#include <cstring>

#define N 1000       // Array size
#define TSTEPS 500  // Number of iterations

const float inv3 = 1.0f / 3.0f;

void jacobi_1d(int tsteps, int n, double* A, double* B) {

    for (int t = 0; t < tsteps; t++) {
        
        // Compute: B[j] = (A[j-1] + A[j] + A[j+1]) / 3.0
        // This is the parallel computation phase
        for (int j = 1; j < n - 1; j++) {
            B[j] = (A[j-1] + A[j] + A[j+1]) / 3;
        }
        
        // Copy B back to A
        // This is the synchronization phase
        for (int j = 1; j < n - 1; j++) {
            A[j] = B[j];
        }
    }
}

int main() {
    // Allocate arrays
    double *A = new double[N];
    double *B = new double[N];
    
    // Initialize A with some values
    for (int i = 0; i < N; i++) {
        A[i] = (double)i;
        B[i] = 0.0;
    }
    
    // Set boundary conditions
    A[0] = 0.0;
    A[N-1] = 0.0;
    
    // std::cout << "Running Jacobi 1D stencil..." << std::endl;
    // std::cout << "Array size: " << N << std::endl;
    // std::cout << "Iterations: " << TSTEPS << std::endl;
    
    // Run Jacobi
    jacobi_1d(TSTEPS, N, A, B);
    
    // // Print some results
    // std::cout << "\nResults (center values):" << std::endl;
    // for (int i = N/2 - 2; i <= N/2 + 2; i++) {
    //     std::cout << "A[" << i << "] = " << A[i] << std::endl;
    // }

    // std::cout << "\nResults (Inital Values):" << std::endl;
    // for (int i = 0; i <= 4; i++) {
    //     std::cout << "A[" << i << "] = " << A[i] << std::endl;
    // }
   
    for (int i = 0; i < 1000; i++) {
        std::cout << A[i] << std::endl;
    }

    // Cleanup
    delete[] A;
    delete[] B;
    
    return 0;
}

/* 
Compilation and execution:
  g++ -O3 jacobi_minimal.cpp -o jacobi
  ./jacobi

Expected behavior:
  - Two phases per iteration:
    1. Compute phase: All B[j] can be computed in parallel
    2. Copy phase: All A[j] = B[j] can be done in parallel
  - These two phases must be synchronized (barrier between them)
  
This matches your MLIR structure:
  scf.for (iterations)
    - ReplicateOp (repId=1): Parallel computation
    - ReplicateOp (repId=2): Parallel copy-back
    - Dependency: repId=1 must complete before repId=2
*/
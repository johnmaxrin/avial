# Auto-Parallel Benchmark Evaluation (`eval_auto_parallel.py`)

This document explains the architecture, arguments, and cluster execution model for `tests/eval_auto_parallel.py`, specifically focusing on multi-node execution under batch schedulers like PBS/Slurm.

---

## 1. Overview

`eval_auto_parallel.py` is the automated evaluation driver for the DHIR compiler pipeline. It sweeps through PolyBench benchmark kernels across different cluster scales, compiles each kernel to native machine code, executes the parallel binary, and verifies correctness against a sequential reference.

For every `(kernel, rank_count)` pair, the pipeline:
1. **Extracts sizes**: Generates problem dimensions from `.mlir` sources.
2. **Compiles kernel**: `dhir-opt` (optimization & MPI/LLVM dialect conversion) $\to$ `mlir-translate` $\to$ `llc` $\to$ `kernel.o`.
3. **Links driver**: Links driver + `kernel.o` + `libdhir_runtime.a` + OpenMP + MPI into a standalone `bench` binary.
4. **Executes**: Launches `mpirun -np <ranks> ./bench`.
5. **Verifies**: Rank 0 computes a sequential reference result and compares against the parallel output within tolerance (`dhir_compare`).
6. **Reports**: Appends performance and status rows to `results.csv`.

---

## 2. Ranks (`--ranks`)

`--ranks` specifies the number of compute nodes to compile and run the kernel for (e.g., `--ranks 1 2`).

---

## 3. Shared Working Directory (`--workdir`)

`--workdir` must point to a shared filesystem (e.g., NFS `$PBS_O_WORKDIR/build/wd`) so remote compute nodes can access the compiled benchmark binaries.

---

## 4. Configuring MPI via `DHIR_MPIRUN_FLAGS`

`tests/run_bench.sh` passes flags through to `mpirun`. For PBS Pro with `select=N:ncpus=4:mpiprocs=1:ompthreads=4`:

```bash
export DHIR_MPIRUN_FLAGS="--map-by ppr:1:node:pe=4 --bind-to core -x PATH -x LD_LIBRARY_PATH -x DHIR_OMP_LIBDIR"
```

- `--map-by ppr:1:node:pe=4`: Places 1 process per node with 4 processing elements (cores) per rank.
- `--bind-to core`: Binds OpenMP worker threads cleanly across the 4 allocated cores.
- `-x`: Forwards environment variables to remote compute nodes.

---

## 5. PBS Script Template

```bash
#!/usr/bin/env bash
#PBS -N dhir_eval
#PBS -l select=2:ncpus=4:mpiprocs=1:ompthreads=4
#PBS -l place=scatter:excl
#PBS -l walltime=02:00:00
#PBS -j oe
#PBS -o eval.log

cd "$PBS_O_WORKDIR"

# Toolchain modules & paths
module load openmpi501 gcc13.3.0

export PATH="$LLVM_ROOT/bin:$OMPI_ROOT/bin:$GCC13_ROOT/bin:$PATH"
export DHIR_OMP_LIBDIR="$HOME/.local/libomp"
export LD_LIBRARY_PATH="$GCC13_ROOT/lib64:$GCC13_ROOT/lib:$OMPI_ROOT/lib:$DHIR_OMP_LIBDIR:${LD_LIBRARY_PATH:-}"

# MPI execution flags
export DHIR_MPIRUN_FLAGS="--map-by ppr:1:node:pe=4 --bind-to core -x PATH -x LD_LIBRARY_PATH -x DHIR_OMP_LIBDIR"

# Shared storage workdir (NFS)
SHARED_WORKDIR="$PBS_O_WORKDIR/build/wd"
mkdir -p "$SHARED_WORKDIR"

# Run evaluation
python3 -u tests/eval_auto_parallel.py \
    --ranks 1 2 \
    --workdir "$SHARED_WORKDIR" \
    --csv tests/bench/results.csv
```

---

## 6. Running a Single Benchmark Directly (`run_bench.sh`)

You can test individual kernels directly without the Python harness:

```bash
# Usage: ./tests/run_bench.sh <kernel> <ranks> [--workdir DIR]
./tests/run_bench.sh gemm 2 --workdir "$PBS_O_WORKDIR/build/wd"
```

---

## 7. Sample Benchmark Results (Aqua Cluster, 4 Cores per Node)

Evaluated across compute nodes using **4 total CPU cores per node** (`ncpus=4`, `ompthreads=4`, `pe=4`):

```
kernel       P  status      seconds  detail
----------------------------------------------------------------
gemm         1  PASS       1.026150
gemm         2  PASS       0.525757
2mm          1  PASS       2.033072
2mm          2  PASS       1.030094
3mm          1  PASS       3.038828
3mm          2  PASS       1.540261
syr2k        1  PASS       1.412101
syr2k        2  PASS       0.720315
mvt          1  PASS       0.022098
mvt          2  PASS       0.022211
atax         1  PASS       0.019404
atax         2  PASS       0.020192
jacobi       1  PASS       0.019999
jacobi       2  PASS       0.060271
jacobi2d     1  PASS       0.021109
jacobi2d     2  PASS       0.138584
add2d        1  PASS       0.025346
add2d        2  PASS       0.036491
doitgen      1  PASS       0.037496
doitgen      2  PASS       0.030444
gesummv      1  PASS       0.020386
gesummv      2  PASS       0.020795
gemver       1  PASS       0.020659
gemver       2  PASS       0.022888
----------------------------------------------------------------
24/24 verified correct   ->  tests/bench/results.csv
```

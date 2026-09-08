# Compute Calibration

Profiles CPU compute throughputs across cache/memory tiers, memory bandwidth, and OpenMP runtime overheads for the DHIR cost model.

## What It Measures
- **Compute Rates ($R$)**: FLOP/s across memory regimes (`l1`, `llc`, `dram`, and `contiguous`).
- **Single-Thread Rates**: Serial execution throughputs for single-threaded loops.
- **Memory Bandwidth ($B$)**: Effective bytes/second streaming bandwidth.
- **Runtime Overheads**: Execution startup floor ($c$) and OpenMP parallel invocation latency ($h$).
- **Cache Capacities**: Detected or overridden L1, LLC, and DRAM sizes.

---

## 1. Single-Node Calibration (`calibrate.py`)

Profiles the local host and optionally injects calibrated rates into a system configuration.

### Usage
```bash
python3 calibration/compute/calibrate.py \
  --config system_config.json \
  --update-config system_config.calibrated.json
```

### Key Options
- `--config <file>`: Input system configuration.
- `--update-config <file>`: Target configuration file updated with calibrated hardware parameters.
- `--num-threads <int>`: OpenMP thread count to benchmark (defaults to all available cores).
- `--profile <file>`: Detailed JSON diagnostic fit report (default: `calibration/compute/profiles/machine_profile.json`).
- `--raw-csv <file>`: CSV timing records output (default: `calibration/compute/profiles/calibration_raw.csv`).
- `--auto-size`: Dynamically size anchor kernels to target runtime and cache tiers (default: enabled).
- `--only-calibrate`: Profile hardware and write outputs without running validation checks.
- `--validate`: Run validation gates against polybench anchor kernels after fitting.

---

## 2. Cluster Calibration (`run_parallel_calibrate.py`)

Coordinates concurrent per-node calibration across an MPI cluster and aggregates results into a single configuration.

### How It Works
- Runs `calibrate.py` concurrently on each cluster node via `mpirun`.
- Nodes synchronize rank status and intermediate outputs using a shared filesystem directory (`--workdir`).
- Each node measures its local hardware independently.
- Rank 0 aggregates all per-node fits and updates the respective `nodes.<node_id>` blocks.

### Cluster Usage
```bash
python3 calibration/compute/run_parallel_calibrate.py \
  --config system_config.json \
  --output-config system_config.calibrated.json \
  --workdir /mnt/shared_nfs/calib_work \
  --mpi-flags "--hostfile hostfile --bind-to none"
```

### Key Options
- `--config <file>`: Input cluster configuration containing `cluster.node_ids` (default: `system_config.json`).
- `--output-config <file>`: Output configuration file (default: `<config>.calibrated.json`).
- `--in-place`: Overwrite `--config` directly instead of writing to a new file.
- `--workdir <dir>`: Shared directory (e.g. NFS mount) visible to all nodes.
- `--mpi-flags <str>`: Flags forwarded to `mpirun` (e.g. `--hostfile`, `--bind-to none`, environment exports).
- `--nodes <list>`: Specific subset of node IDs to calibrate (default: all nodes).

---

## Outputs
- **`<config>.calibrated.json`**: System configuration populated with per-node calibration values:
  - `compute_rate_dram`, `compute_rate_llc`, `compute_rate_l1`, `compute_rate_contiguous` (FLOP/s)
  - `r_l1_ratio`, `r_llc_ratio`, `r_contiguous_ratio`
  - `memory_bandwidth` (bytes/s)
  - `overhead` ($c$ startup floor in seconds)
  - `omp_entry_latency` ($h$ parallel invocation latency in seconds)
- **`calibration/compute/profiles/machine_profile.json`**: Complete diagnostic profile with solver regression fits.
- **`calibration/compute/profiles/calibration_raw.csv`**: Raw benchmark run timings and sample statistics.

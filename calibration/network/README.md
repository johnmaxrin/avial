# Network Calibration

Profiles inter-node network latency, bandwidth, and collective synchronization costs for the DHIR distributed cost model.

## What It Measures
- **Point-to-Point Latency ($\alpha$) & Bandwidth ($\beta$)**: Per-link latency (seconds) and inverse transfer rate (seconds/byte) between root (rank 0) and worker nodes via asymmetric ping-pong sweeps.
- **Barrier Latency**: Global synchronization overhead measured using `MPI_Barrier`.
- **Collective Patterns**: Measures serialized hub-gather and hub-broadcast patterns and validates against the star network model:
  $$\text{Time} = \sum_{i \in \text{workers}} (\alpha_i + \beta_i \times \text{bytes})$$

---

## How to Run (`cluster_calibrate.py`)

Compiles the C++ benchmark driver (`drivers/cluster_calibration_main.cc`) with `mpicxx` and executes an MPI benchmark sweep across all nodes.

### Usage
```bash
python3 calibration/network/cluster_calibrate.py \
  --config system_config.json \
  --write-config system_config.calibrated.json \
  --workdir build/clustercal \
  --mpirun-flags "--hostfile hostfile --map-by ppr:1:node --bind-to none"
```

### Key Options
- `--config <file>`: Input system configuration defining `cluster.world_size` and `cluster.node_ids`.
- `--write-config <file>`: Output path for the calibrated configuration (default: `<config>.calibrated.json`).
- `--workdir <dir>`: Shared build and scratch directory accessible by all ranks.
- `--mpirun-flags <str>`: Flags passed directly to `mpirun` (hostfile, 1 process per node mapping, library paths).
- `--sizes <bytes...>`: Payload sizes to sweep (default: 8 B to 16 MiB).
- `--repeats <int>`: Number of measurement sweeps (default: 2).
- `--net-iters <int>`: Iterations per payload size (default: 60).
- `--net-warmups <int>`: Warmup iterations discarded before timing (default: 10).

---

## Outputs
- **`<config>.calibrated.json`**: Injects network parameters into the system configuration:
  - `network`: Cluster-wide aggregate metrics (`alpha_seconds`, `beta_seconds_per_byte`, `bandwidth_byte_per_second`, `barrier_seconds`).
  - `nodes.<node_id>.network`: Per-node point-to-point link parameters relative to the root node.
- **`calibration/network/profiles/cluster_profile.json`**: Linear regression fits ($\alpha, \beta$), $R^2$ scores, and star-model collective prediction errors.
- **`calibration/network/profiles/cluster_calibration_raw.csv`**: Raw benchmark records for all ping-pong, barrier, and collective iterations.

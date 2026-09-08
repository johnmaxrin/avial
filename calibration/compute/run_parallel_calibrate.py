#!/usr/bin/env python3
"""Distributed cluster calibration.

Runs ``calibrate.py`` on each node via MPI placement and generates
``<config>.calibrated.json`` with per-node calibration parameters.
"""

import argparse
import json
import os
import socket
import subprocess
import sys
import time
from pathlib import Path

from mpi4py import MPI

ROOT = Path(__file__).resolve().parent.parent.parent
CALIBRATE = ROOT / "calibration" / "compute" / "calibrate.py"

NODE_RATE_KEY = {"dram": "compute_rate_strided",
                 "llc": "compute_rate_llc",
                 "l1": "compute_rate_l1",
                 "contiguous": "compute_rate_contiguous"}
LEGACY_RATE_KEY = {"dram": "R_flop_per_second",
                   "llc": "R_llc_flop_per_second",
                   "l1": "R_l1_flop_per_second",
                   "contiguous": "R_contiguous_flop_per_second"}


def ensure_dir(path):
    """Create directory safely ignoring NFS creation races."""
    try:
        path.mkdir(parents=True, exist_ok=True)
    except FileExistsError:
        pass
    return path
def build_calibrate_cmd(node_id, wd, args, extra_args):
    cmd = [sys.executable, "-u", str(CALIBRATE),
           "--repeats", str(args.repeats),
           "--workdir", str(wd),
           "--profile", str(wd / "machine_profile.json"),
           "--raw-csv", str(wd / "raw.csv")]
    if args.kernels:
        cmd += ["--kernels", *args.kernels]
    if args.auto_size:
        cmd.append("--auto-size")
    else:
        cmd.append("--no-auto-size")
    if args.serial_rates:
        cmd.append("--serial-rates")
    else:
        cmd.append("--no-serial-rates")
    if args.secant_bandwidth:
        cmd.append("--secant-bandwidth")
    else:
        cmd.append("--no-secant-bandwidth")
    if args.dims:
        cmd += ["--dims", args.dims]
    if args.size is not None:
        cmd += ["--size", str(args.size)]
    if args.c_floor is not None:
        cmd += ["--c-floor", str(args.c_floor)]
    if args.h_entry is not None:
        cmd += ["--h-entry", str(args.h_entry)]
    if args.num_threads is not None:
        cmd += ["--num-threads", str(args.num_threads)]
    if args.l1_bytes is not None:
        cmd += ["--l1-bytes", str(args.l1_bytes)]
    if args.llc_bytes is not None:
        cmd += ["--llc-bytes", str(args.llc_bytes)]
    if args.memory_bytes is not None:
        cmd += ["--memory-bytes", str(args.memory_bytes)]
    if args.anchor_seconds is not None:
        cmd += ["--anchor-seconds", str(args.anchor_seconds)]
    if args.timeout is not None:
        cmd += ["--timeout", str(args.timeout)]
    if args.discovery_floor_binary:
        cmd += ["--discovery-floor-binary", args.discovery_floor_binary]
    if args.discovery_reps is not None:
        cmd += ["--discovery-reps", str(args.discovery_reps)]
    if args.omp_entry_binary:
        cmd += ["--omp-entry-binary", args.omp_entry_binary]
    if args.omp_entry_iters is not None:
        cmd += ["--omp-entry-iters", str(args.omp_entry_iters)]
    if args.only_calibrate:
        cmd.append("--only-calibrate")
    if args.validate:
        cmd.append("--validate")
    if args.only_validate:
        cmd.append("--only-validate")
    if args.val_size is not None:
        cmd += ["--val-size", str(args.val_size)]
    if args.val_kernels:
        cmd += ["--val-kernels", *args.val_kernels]
    if args.val_dims:
        cmd += ["--val-dims", args.val_dims]
    if extra_args:
        cmd += list(extra_args)
    return cmd


def build_env(args):
    """Constructs the environment for the per-node calibrate.py subprocess."""
    env = dict(os.environ)
    for var in ("DHIR_MPIRUN_FLAGS", "DHIR_CAL_MPIRUN_FLAGS"):
        env.pop(var, None)
    parts = [str(ROOT / "build" / "lib"), "/usr/local/lib",
             env.get("LD_LIBRARY_PATH", "")]
    env["LD_LIBRARY_PATH"] = ":".join(p for p in parts if p)
    if args.num_threads is not None:
        env["OMP_NUM_THREADS"] = str(args.num_threads)
    return env


def run_calibrate_node(node_id, run_dir, args, extra_args, env):
    """Run calibrate.py locally for node_id; returns (returncode, 'DONE'|'FAIL')."""
    wd = run_dir / node_id
    wd.mkdir(parents=True, exist_ok=True)
    cmd = build_calibrate_cmd(node_id, wd, args, extra_args)
    log_path = wd / "calibrate.log"
    t0 = time.time()
    rc = 0
    with open(log_path, "w") as lf:
        lf.write(" ".join(cmd) + "\n")
        lf.flush()
        try:
            proc = subprocess.run(cmd, cwd=ROOT, env=env,
                                  stdout=lf, stderr=subprocess.STDOUT,
                                  timeout=(args.timeout or 0) or None)
            rc = proc.returncode
        except subprocess.TimeoutExpired:
            rc = 124
            lf.write("\n[launcher] calibrate.py timed out\n")
        except Exception as exc:
            rc = 2
            lf.write(f"\n[launcher] {exc}\n")
    suffix = "DONE" if rc == 0 else "FAIL"
    return rc, suffix


def load_fit(profile_path):
    """Read representative_machine block from a node's JSON profile."""
    data = json.loads(profile_path.read_text())
    fit = data.get("representative_machine")
    if not fit:
        raise ValueError(f"{profile_path}: no 'representative_machine'")
    return fit


def calibration_node_block(fit):
    """Extract node calibration parameters in system config format."""
    rates = {}
    block = {}
    for cls, key in NODE_RATE_KEY.items():
        v = fit.get(f"R_{cls}") or 0.0
        if not v:
            v = fit.get(LEGACY_RATE_KEY[cls]) or 0.0
        rates[cls] = float(v)
        block[key] = round(float(v), 2)

    base = rates["dram"] or 1.0
    b_mem = float(fit.get("B_byte_per_second") or 0.0)
    block["r_l1_ratio"] = round(rates["l1"] / base, 4)
    block["r_llc_ratio"] = round(rates["llc"] / base, 4)
    block["r_contiguous_ratio"] = round(rates["contiguous"] / base, 4)
    block["memory_bandwidth"] = round(b_mem, 2)
    block["bandwidth"] = round(b_mem, 2)
    block["overhead"] = round(float(fit.get("c_seconds") or 0.0), 6)
    block["omp_entry_latency"] = fit.get("h_parallel_entry_seconds") or 0.0
    block["omp_first_entry_latency"] = fit.get("h_first_parallel_entry_seconds") or 0.0
    for cls in ("dram", "llc", "l1", "contiguous"):
        s = fit.get(f"R_{cls}_serial_flop_per_second")
        if s:
            block[f"compute_rate_{cls}_serial"] = round(float(s), 2)
    for k in ("l1_bytes", "llc_bytes", "memory_bytes", "threads"):
        if fit.get(k):
            block[k] = int(fit[k])
    if fit.get("strided_flop_threshold") is not None:
        block["strided_flop_threshold"] = fit["strided_flop_threshold"]
    return block


def aggregate_config(config_data, node_status, run_dir):
    """Merge calibrated node parameters into a copy of the input config."""
    updated = json.loads(json.dumps(config_data))
    nodes = updated.setdefault("nodes", {})
    errors = []
    for node_id, status in node_status.items():
        if status != "DONE":
            errors.append(f"{node_id}: {status}")
            continue
        profile = run_dir / node_id / "machine_profile.json"
        if not profile.exists():
            errors.append(f"{node_id}: DONE but {profile} missing")
            continue
        try:
            fit = load_fit(profile)
        except Exception as exc:
            errors.append(f"{node_id}: profile unreadable ({exc})")
            continue
        node = nodes.setdefault(node_id, {})
        node.update(calibration_node_block(fit))
        node["calibrated"] = True
    updated["calibrated"] = not errors
    return updated, errors


def build_parser():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--config",
                    default=str(ROOT / "system_config.json"),
                    help="input system_config.json (default: system_config.json)")
    ap.add_argument("--output-config", default=None,
                    help="output config path (default: <config>.calibrated.json)")
    ap.add_argument("--in-place", action="store_true",
                    help="write the calibrated config back over --config")
    ap.add_argument("--workdir",
                    default="/tmp/wd/",
                    help="shared working directory, visible to all nodes "
                         "(default: /tmp/wd/)")
    ap.add_argument("--task-id", default="parallel_cal",
                    help="subdirectory of --workdir holding this run's outputs")
    ap.add_argument("--nodes", nargs="*", default=None,
                    help="subset of node_ids to calibrate (default: all nodes "
                         "from the config)")
    ap.add_argument("--mpirun", default=os.environ.get("MPIRUN", "mpirun"))
    ap.add_argument("--mpi-flags",
                    default=os.environ.get("DHIR_MPIRUN_FLAGS")
                             or os.environ.get("DHIR_CAL_MPIRUN_FLAGS")
                             or "--bind-to none",
                    help="mpirun flags passed verbatim to the launcher. ALL "
                         "host placement and env exports are carried here -- "
                         "e.g. DHIR_MPIRUN_FLAGS='--hostfile=<h> --bind-to "
                         "none -x LD_LIBRARY_PATH=... -x PATH=...' -- so every "
                         "node imports the shared toolchain exactly as exported. "
                         "There is no separate host flag and nothing is "
                         "hardcoded.")
    ap.add_argument("--no-rexec", action="store_true",
                    help="do not self-re-launch under mpirun; run as rank 0 only")
    ap.add_argument("--coord-timeout", type=int, default=None,
                    help="coordinator wait timeout(s); default: --timeout")
    ap.add_argument("--repeats", type=int, default=5)
    ap.add_argument("--kernels", nargs="+", default=None)
    ap.add_argument("--auto-size", action=argparse.BooleanOptionalAction, default=True)
    ap.add_argument("--serial-rates", action=argparse.BooleanOptionalAction, default=True)
    ap.add_argument("--secant-bandwidth", action=argparse.BooleanOptionalAction, default=True)
    ap.add_argument("--dims", default=None)
    ap.add_argument("--size", type=int, default=None)
    ap.add_argument("--c-floor", type=float, default=None)
    ap.add_argument("--h-entry", type=float, default=None)
    ap.add_argument("--num-threads", type=int, default=None)
    ap.add_argument("--l1-bytes", type=int, default=None)
    ap.add_argument("--llc-bytes", type=int, default=None)
    ap.add_argument("--memory-bytes", type=int, default=None)
    ap.add_argument("--anchor-seconds", type=float, default=None)
    ap.add_argument("--timeout", type=int, default=900)
    ap.add_argument("--discovery-floor-binary", default=None)
    ap.add_argument("--discovery-reps", type=int, default=None)
    ap.add_argument("--omp-entry-binary", default=None)
    ap.add_argument("--omp-entry-iters", type=int, default=None)
    ap.add_argument("--only-calibrate", action="store_true")
    ap.add_argument("--validate", action="store_true")
    ap.add_argument("--only-validate", action="store_true")
    ap.add_argument("--val-size", type=int, default=None)
    ap.add_argument("--val-kernels", nargs="+", default=None)
    ap.add_argument("--val-dims", default=None)
    return ap


def print_node_summary(updated_config, target_nodes):
    print("\nCalibrated node parameters written to config:")
    for node_id in target_nodes:
        n = updated_config.get("nodes", {}).get(node_id, {})
        rs = n.get("compute_rate_strided", 0) or 0
        rc = n.get("compute_rate_contiguous", 0) or 0
        bw = n.get("memory_bandwidth", 0) or 0
        c = n.get("overhead", 0) or 0
        h = n.get("omp_entry_latency", 0) or 0
        print(f"  {node_id:<10}: R_strided={rs/1e9:.2f} G/s "
              f"R_contig={rc/1e9:.2f} G/s BW={bw/1e9:.2f} GB/s "
              f"c={c*1e3:.3f} ms h={h*1e6:.2f} us")


def output_paths(args, config_path):
    if args.in_place:
        return config_path
    if args.output_config:
        return Path(args.output_config).resolve()
    return config_path.parent / f"{config_path.stem}.calibrated.json"


def write_calibrated_config(updated, out_path):
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(updated, indent=2) + "\n")


def rexec_under_mpirun(args, target_nodes):
    """Re-launch this script across target nodes under mpirun."""
    flags = (args.mpi_flags or "").split()
    cmd = [args.mpirun, *flags,
           "-np", str(len(target_nodes)), sys.executable, "-u",
           str(Path(__file__).resolve()), *sys.argv[1:]]
    print("Relaunching under mpirun:", " ".join(cmd), flush=True)
    return subprocess.run(cmd, cwd=ROOT).returncode


def main():
    ap = build_parser()
    args, extra_args = ap.parse_known_args()

    config_path = Path(args.config)
    if not config_path.exists():
        raise FileNotFoundError(f"Config file not found: {config_path}")
    config_data = json.loads(config_path.read_text())
    cluster_node_ids = config_data.get("cluster", {}).get(
        "node_ids", list(config_data.get("nodes", {}).keys()))
    if not cluster_node_ids:
        ap.error("config has no node_ids")

    target_nodes = args.nodes or list(cluster_node_ids)
    if not target_nodes:
        ap.error("no target nodes resolved from config")

    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()

    if size == 1 and len(target_nodes) > 1 and not args.no_rexec:
        return rexec_under_mpirun(args, target_nodes)

    run_dir = ensure_dir(Path(args.workdir) / args.task_id)
    env = build_env(args)

    if size == 1:
        node_id = target_nodes[0]
        actual_host = socket.gethostname()
        print(f"Single-node calibration (rank 0 on {node_id} ({actual_host})).",
              flush=True)
        rc, suffix = run_calibrate_node(node_id, run_dir, args, extra_args, env)
        status = {node_id: suffix}
        updated, errs = aggregate_config(config_data, status, run_dir)
        out_path = output_paths(args, config_path)
        write_calibrated_config(updated, out_path)
        print(f"Wrote calibrated config: {out_path}")
        print_node_summary(updated, [node_id])
        return 1 if (suffix != "DONE" or errs) else 0

    if rank >= len(target_nodes):
        print(f"rank {rank} has no node_id; exiting", flush=True)
        return 0

    node_id = target_nodes[rank]
    actual_host = socket.gethostname()

    print(f"Rank {rank} calibrating {node_id} on {actual_host}", flush=True)
    rc, suffix = run_calibrate_node(node_id, run_dir, args, extra_args, env)

    gathered = comm.gather((node_id, rc, suffix), root=0)

    if rank != 0:
        return 0

    all_status = {}
    for res in gathered or []:
        all_status[res[0]] = res[2]
    for nid in target_nodes:
        all_status.setdefault(nid, "MISSING")

    updated, errs = aggregate_config(config_data, all_status, run_dir)
    failures = [n for n, s in all_status.items() if s != "DONE"]
    successes = [n for n, s in all_status.items() if s == "DONE"]
    if successes:
        out_path = output_paths(args, config_path)
        write_calibrated_config(updated, out_path)
        print(f"\nWrote calibrated config: {out_path}"
              f" (partial)" if errs else f"\nWrote calibrated config: {out_path}",
              flush=True)
        print_node_summary(updated, [n for n in target_nodes if n in
                                     updated.get("nodes", {})])
    else:
        print("\nNo node calibrated successfully; not writing a config.",
              file=sys.stderr, flush=True)
    print("\nNode completion:", {n: s for n, s in all_status.items()}, flush=True)
    if errs:
        print("Errors:", "; ".join(errs), file=sys.stderr)
    return 1 if (failures or errs) else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(130)
    except (RuntimeError, ValueError, subprocess.TimeoutExpired) as exc:
        print(f"parallel calibration error: {exc}", file=sys.stderr)
        sys.exit(2)

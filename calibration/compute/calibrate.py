#!/usr/bin/env python3
"""Quantifies the single-node BSP/roofline performance profile for a target system.

Rather than running a joint multi-parameter fit, each parameter is isolated
via a dedicated witness benchmark, ensuring cross-parameter error absorption cannot occur:

    c        fixed invocation base  -- a strictly serial kernel with trivial dimensions,
                                      profiled inside the full harness to capture
                                      ambient overheads (MPI initialization, runtime
                                      hwloc topology queries, descriptor allocation)
    h_first  initial OpenMP team spawn -- identical probe with an active parallel region
    h        region re-dispatch     -- identical stencil measured across two distinct iteration counts
    R_l1     |
    R_llc    |  processing throughput per cache tier -- a single gemm geometry whose
    R_dram   |  working footprint is tuned to reside in L1, inside LLC, or in main DRAM,
    R_contig |  such that strided memory placement is the sole differentiator
    R_*_serial  identical anchor kernels evaluated with a single thread, reflecting
                that serial loops run on a single core where speedup deviates heavily from thread count
    B        streaming memory bandwidth -- net elapsed execution time of a stream read kernel

Work volumes and data traffic originate from analysis/costModel.h at the DHIR dialect interface:
Floating-point operation counts conform to standard roofline rules (FMA counts as 2, adds and
multiplications count as 1). Memory traffic represents the theoretical lower bound across memref
access spaces, where modified buffers incur a factor-of-two penalty for cache fetch and writeback.
These values represent static analytical bounds rather than performance-counter reads. The extracted
rates characterize this benchmark suite on the evaluated host, reflecting effective sustainable
throughput rather than hardware theoretical peaks.
"""

import argparse
import csv
import importlib.util
import json
import math
import os
import re
import statistics
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
RUN_BENCH = ROOT / "tests" / "run_bench.sh"
KERNELS_PY = ROOT / "tests" / "bench" / "kernels.py"
DEFAULT_KERNELS = ["gemm", "2mm", "3mm", "syr2k", "mvt", "atax", "jacobi", "jacobi2d", "add2d", "doitgen", "gesummv", "gemver", "stream6"]
RESULT_RE = re.compile(r"^RESULT kernel=(\S+) ranks=(\d+)(?: threads=\d+)? seconds=([\d.eE+-]+) status=(\S+) errors=(\d+)")
ADAPTIVE_SIZING_PY = ROOT / "calibration" / "compute" / "adaptive_sizing.py"


def load_adaptive_sizing():
    if not ADAPTIVE_SIZING_PY.exists():
        return None
    spec = importlib.util.spec_from_file_location("adaptive_sizing", ADAPTIVE_SIZING_PY)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def load_kernels():
    spec = importlib.util.spec_from_file_location("dhir_kernels", KERNELS_PY)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module




def omp_ir_report(kernel, config=None, num_threads=None, llc_bytes=None, l1_bytes=None, extra_flags=(), mlir_path=None):
    """Invokes dhir-opt using --dhir-omp-cost-model-report to collect OpenMP cost metrics from IR."""
    if num_threads is None:
        num_threads = os.cpu_count()
    mlir = Path(mlir_path) if mlir_path else (ROOT/"tests"/"polybench"/f"{kernel}.mlir")
    cfg = config or (ROOT/"tests"/"configs"/"system_config_4_cpu.json")
    dhir_opt = ROOT/"build"/"bin"/"dhir-opt"
    flags = list(extra_flags)
    if num_threads:
        flags.append(f"--dhir-omp-threads={num_threads}")
    if llc_bytes:
        flags.append(f"--dhir-omp-llc-bytes={llc_bytes}")
    if l1_bytes:
        flags.append(f"--dhir-omp-l1-bytes={l1_bytes}")
    proc = subprocess.run([str(dhir_opt), "--dhir-omp-cost-model-report",
                           *flags, str(mlir), str(cfg)],
                          cwd=ROOT, text=True, capture_output=True, timeout=300)
    summary, nests = None, []
    for line in (proc.stdout + "\n" + proc.stderr).splitlines():
        if line.startswith("OMPCOSTMODEL_NEST "):
            nests.append(dict(re.findall(r'(\w+)=("[^"]*"|\S+)',
                                         line[len("OMPCOSTMODEL_NEST "):])))
        elif line.startswith("OMPCOSTMODEL kernel="):
            summary = dict(re.findall(r'(\w+)=("[^"]*"|\S+)',
                                      line[len("OMPCOSTMODEL "):]))
    if summary is None:
        raise RuntimeError(f"{kernel}: no OMPCOSTMODEL line from dhir-opt: "
                           f"{proc.stderr[:400]}")
    if summary.get("status") != "OK":
        raise RuntimeError(f"{kernel}: OMP cost model invalid: {summary.get('reason')}")
    # Loop nests execute sequentially, with each nest constrained by its own
    # compute or memory ceiling. Using a single aggregate roofline across the entire
    # kernel would improperly mask memory-stalled regions behind compute-heavy nests.
    summary["nest_metrics"] = nests
    return summary


# Ranked from lowest to highest throughput: strided accesses spilling past LLC
# incur DRAM penalties, LLC-resident accesses pay cache lookup costs, L1-resident
# accesses dispatch at core pipeline throughput, and contiguous accesses leverage vector units.
COMPUTE_CLASSES = ("dram", "llc", "l1", "contiguous")

CLASS_FIELD = {
    "dram": "dram_strided_flop_fraction",
    "llc": "llc_strided_flop_fraction",
    "l1": "in_cache_strided_flop_fraction",
    "contiguous": "contiguous_flop_fraction",
}


def sample_stat(values, stat="min"):
    """Aggregates multiple execution timings for a given setup into a representative scalar.

    Defaults to `min`. Observed runtimes comprise deterministic baseline execution
    skewed by non-negative external noise (OS context switches, page faults from competing
    ranks, or dentry cache misses during hwloc initialization). Consequently, sample distributions
    exhibit a rigid lower bound accompanied by an extended upper tail; an isolated 0.53 s spike
    amid 17 ms measurements skews the median while preserving the minimum. Applying an identical
    reduction strategy across both calibration anchors and validation targets maintains internal
    consistency.
    """
    values = [v for v in values if v is not None]
    if not values:
        raise ValueError("no successful measurements")
    return min(values) if stat == "min" else statistics.median(values)


def class_fractions(row):
    """Computes normalized FLOP ratios across compute classes along with their unparallelized shares.

    The compiler emits both the overall FLOP proportion per cache level and the unvectorized/serial
    fraction retained by the parallelizer (such as `dhir.task`, purely sequential `dhir.converge`
    stages, or unpartitioned `affine.for` loops). Sequential computations execute on a single core
    and must therefore be evaluated using single-core class throughput instead of the gang rate.
    """
    total = {}
    serial = {}
    for name in COMPUTE_CLASSES:
        total[name] = max(0.0, float(row.get(CLASS_FIELD[name], 0.0)))
        serial[name] = max(0.0, float(row.get("serial_" + CLASS_FIELD[name], 0.0)))
        serial[name] = min(serial[name], total[name])
    if "contiguous_flop_fraction" not in row:
        strided = sum(total[c] for c in ("dram", "llc", "l1"))
        total["contiguous"] = max(0.0, 1.0 - strided)
        if float(row.get("serial_flop_fraction", 0.0)) >= 0.999:
            serial["contiguous"] = total["contiguous"]
    scale = sum(total.values())
    if scale > 0 and abs(scale - 1.0) > 1e-6:
        total = {k: v / scale for k, v in total.items()}
        serial = {k: v / scale for k, v in serial.items()}
    # Legacy reports without `serial_*` keys supplied thread_flops; use this fallback
    # to guarantee that completely sequential kernels in older profiles evaluate against single-thread rates.
    if not any(serial.values()) and row.get("is_serial"):
        serial = dict(total)
    return total, serial


NEST_CLASS_FIELD = {"dram": "strided", "llc": "llc_strided",
                    "l1": "in_cache_strided", "contiguous": "contiguous"}


def nest_rows(row):
    """Extracts per-nest workload, memory volume, and cache class distribution directly from compiler reports."""
    out = []
    for nest in row.get("nest_metrics") or []:
        try:
            flops = float(nest["flops"])
            classes = {cls: float(nest.get(NEST_CLASS_FIELD[cls], 0.0))
                       for cls in COMPUTE_CLASSES}
            entry = {
                "kind": nest.get("kind", "replicate"),
                "operations": flops,
                "bytes": float(nest["total_bytes"]),
                "is_parallel": nest.get("parallel", "1") == "1",
                "classes": classes,
            }
        except (KeyError, ValueError):
            return []
        accounted = sum(classes.values())
        if flops > 0 and accounted < flops:
            entry["classes"]["contiguous"] += flops - accounted
        out.append(entry)
    return out


def parallel_entry_count(row):
    """Returns (initial_entry_count, subsequent_entry_count) for an evaluated kernel profile.

    Kernels lacking `dhir.replicate` constructs never initialize an OpenMP thread team,
    incurring neither initial team allocation overhead nor subsequent dispatch delays.
    """
    entries = int(row.get("parallel_entries", 1) or 0)
    has_parallel = int(row.get("parallel_nests", 1) or 0) > 0
    if not has_parallel:
        return 0, 0
    return 1, max(0, entries - 1)


def overhead_seconds(row, c, h_first, h):
    first, rest = parallel_entry_count(row)
    return c + h_first * first + h * rest


def net_time(row, c, h, h_first=0.0):
    """Net compute duration remaining once baseline invocation latency and dispatch overheads are subtracted."""
    return max(1e-6, row["seconds"] - overhead_seconds(row, c, h_first, h))


def pure_class_witness(rows, cls, preferred=None, purity=0.99):
    """Identifies the measurement record whose arithmetic operations map predominantly to a single cache class.

    A throughput parameter cleanly characterizes a memory regime only when derived
    from an unblended workload; computing R_dram from a loop that is 80% DRAM-strided and
    20% contiguous inadvertently pollutes the DRAM estimate with vector engine performance.
    """
    candidates = []
    for row in rows:
        if float(row.get("operations", 0.0)) <= 0:
            continue
        total, _ = class_fractions(row)
        if total.get(cls, 0.0) >= purity:
            candidates.append(row)
    if isinstance(preferred, str):
        for row in candidates:
            if row.get("kernel") == preferred:
                return row
    elif preferred is not None:
        for row in candidates:
            if row is preferred:
                return row
    return candidates[0] if candidates else None


# Default reference anchors employed whenever the caller omits explicit anchor tags.
LEGACY_WITNESS = {"dram": "gemm", "contiguous": "syr2k", "l1": "doitgen",
                  "llc": "3mm"}


def derive_direct_rates(rows, h_empirical=3.06e-6, c_empirical=None, c_floor=None,
                        num_threads=None, secant_data=None, l1_bytes=None,
                        llc_bytes=None, anchors=None, parallel_speedup=None,
                        bandwidth_row=None, h_first=0.0, serial_rates=None,
                        bandwidth_method="direct"):
    """Extracts throughput for each compute tier independently via its corresponding witness benchmark.

    Each processing rate is computed as `W_IR(anchor) / t_net(anchor)` with memory bandwidth
    determined via a two-point secant or net duration. Because parameters are evaluated in isolation,
    error cross-contamination—the central flaw of multi-dimensional grid regressions—is eliminated.
    """
    if num_threads is None:
        num_threads = os.cpu_count()
    by_k = {r["kernel"]: r for r in rows}

    c = c_floor if c_floor is not None else (c_empirical if c_empirical is not None else 0.0)
    # The base invocation overhead cannot surpass the shortest execution interval recorded through the harness.
    observed = [r["seconds"] for r in rows if r.get("seconds")]
    if secant_data:
        observed += [d["seconds"] for d in secant_data.values() if d.get("seconds")]
    if observed and c >= min(observed):
        c = max(1e-6, min(observed) * 0.95)

    anchors = dict(anchors or {})
    for cls in COMPUTE_CLASSES:
        if anchors.get(cls) is None:
            anchors[cls] = pure_class_witness(rows, cls,
                                              LEGACY_WITNESS.get(cls))

    rates = {}
    for cls in COMPUTE_CLASSES:
        row = anchors.get(cls)
        if row is not None and float(row.get("operations", 0.0)) > 0:
            rates[cls] = row["operations"] / net_time(row, c, h_empirical, h_first)

    # Populate missing cache class throughputs from adjacent levels rather than
    # disparate tiers; cache hierarchies are strictly ordered, making adjacent tiers
    # the closest physical approximation.
    for i, cls in enumerate(COMPUTE_CLASSES):
        if rates.get(cls, 0.0) > 0:
            continue
        for j in list(range(i - 1, -1, -1)) + list(range(i + 1, len(COMPUTE_CLASSES))):
            other = COMPUTE_CLASSES[j]
            if rates.get(other, 0.0) > 0:
                rates[cls] = rates[other]
                break
    if not any(rates.get(c_, 0.0) > 0 for c_ in COMPUTE_CLASSES):
        raise ValueError("no compute-class anchor produced a positive rate")

    band = bandwidth_row if bandwidth_row is not None else by_k.get("add2d")
    if band is None:
        raise ValueError("direct derivation requires a bandwidth anchor row")
    secant = ((secant_data or {}).get("bandwidth_secant")
              or (secant_data or {}).get("add2d_secant"))
    if secant and secant.get("bytes", 0) > band["bytes"]:
        # Base the direct throughput reading on the highest-traffic configuration,
        # where baseline overhead uncertainty c represents the minimal fractional error.
        band, secant = dict(secant), {"bytes": band["bytes"],
                                      "seconds": band["seconds"]}
    b_secant = None
    if secant and secant.get("bytes", 0) < band["bytes"]:
        # Static invocation costs cancel out in the differential calculation,
        # neutralizing base overhead error in B. However, differencing two noisy
        # measurements compounds variance over a reduced denominator. When c is
        # independently isolated via a dedicated probe, secant cancellation yields diminishing
        # returns: a 10% timing jitter can inflate an 8% bandwidth error up to 30%.
        # Retained primarily for cross-validation.
        delta_bytes = band["bytes"] - secant["bytes"]
        delta_t = max(1e-9, band["seconds"] - secant["seconds"])
        b_secant = delta_bytes / delta_t
    b_eff = band["bytes"] / net_time(band, c, h_empirical, h_first)
    b_method = "direct_net_time"
    if b_secant is not None and bandwidth_method == "secant":
        b_eff = b_secant
        b_method = "two_point_secant"

    speedup = parallel_speedup if parallel_speedup and parallel_speedup > 1.0 else 1.0

    res = {
        "R_flop_per_second": rates["dram"],
        "R_contiguous_flop_per_second": rates["contiguous"],
        "R_l1_flop_per_second": rates["l1"],
        "R_scalar_flop_per_second": rates["l1"],
        "R_llc_flop_per_second": rates["llc"],
        "B_byte_per_second": b_eff,
        "c_seconds": c,
        "h_parallel_entry_seconds": h_empirical,
        "h_first_parallel_entry_seconds": h_first,
        "parallel_speedup": speedup,
        "strided_flop_threshold": STRIDED_FLOP_THRESHOLD,
        "fit_log_mse": 0.0,
        "method": b_method,
    }
    if b_secant is not None:
        res["B_byte_per_second_secant"] = b_secant
    serial_rates = serial_rates or {}
    for cls in COMPUTE_CLASSES:
        res[f"R_{cls}"] = rates[cls]
        # Sequential loops execute on a single core. Estimating single-core performance by dividing
        # multi-threaded gang rates by thread count presumes ideal scaling—a condition rarely met in practice.
        # Direct single-thread evaluation of the anchor provides an accurate ground truth.
        single = serial_rates.get(cls, 0.0)
        res[f"R_{cls}_serial_flop_per_second"] = single if single > 0 else rates[cls] / speedup
        if single > 0:
            res[f"parallel_speedup_{cls}"] = rates[cls] / single
    res["R_strided"] = rates["dram"]
    res["R_l1_ratio"] = rates["l1"] / rates["dram"] if rates["dram"] > 0 else 1.0
    res["R_llc_ratio"] = rates["llc"] / rates["dram"] if rates["dram"] > 0 else 1.0
    res["R_contiguous_ratio"] = (rates["contiguous"] / rates["dram"]
                                 if rates["dram"] > 0 else 1.0)
    res["anchors"] = {cls: (anchors[cls]["kernel"] if anchors.get(cls) else None)
                      for cls in COMPUTE_CLASSES}
    res["anchor_dimensions"] = {cls: (anchors[cls].get("dimensions")
                                      if anchors.get(cls) else None)
                                for cls in COMPUTE_CLASSES}
    if l1_bytes is not None: res["l1_bytes"] = l1_bytes
    if llc_bytes is not None: res["llc_bytes"] = llc_bytes
    if num_threads is not None: res["threads"] = num_threads
    return res


# Configuration attributes parsed by `includes/system_config.h`, allowing calibrated
# metrics to be written directly into system JSON descriptors for IR cost estimation.
CONFIG_MACHINE_RATE_KEY = {"dram": "R_strided", "llc": "R_llc", "l1": "R_l1",
                           "contiguous": "R_contiguous"}
CONFIG_NODE_RATE_KEY = {"dram": "compute_rate_strided",
                        "llc": "compute_rate_llc",
                        "l1": "compute_rate_l1",
                        "contiguous": "compute_rate_contiguous"}


def config_machine_block(fit):
    """Formats the calibrated system profile using the property keys expected by the configuration schema."""
    block = {
        "memory_bandwidth": fit["B_byte_per_second"],
        "overhead": fit["c_seconds"],
        "h_parallel_entry_seconds": fit.get("h_parallel_entry_seconds", 0.0),
        "h_first_parallel_entry_seconds": fit.get("h_first_parallel_entry_seconds", 0.0),
        "strided_flop_threshold": fit.get("strided_flop_threshold", 0.5),
        "calibrated": True,
    }
    for cls, key in CONFIG_MACHINE_RATE_KEY.items():
        block[key] = fit.get(f"R_{cls}", 0.0)
        serial = fit.get(f"R_{cls}_serial_flop_per_second", 0.0)
        if serial:
            block[f"{key}_serial"] = serial
    for key in ("l1_bytes", "llc_bytes", "memory_bytes", "threads"):
        if fit.get(key):
            block[key] = int(fit[key])
    return block


def config_node_block(fit):
    block = {
        "memory_bandwidth": fit["B_byte_per_second"],
        "overhead": fit["c_seconds"],
        "omp_entry_latency": fit.get("h_parallel_entry_seconds", 0.0),
        "omp_first_entry_latency": fit.get("h_first_parallel_entry_seconds", 0.0),
    }
    for cls, key in CONFIG_NODE_RATE_KEY.items():
        block[key] = fit.get(f"R_{cls}", 0.0)
        serial = fit.get(f"R_{cls}_serial_flop_per_second", 0.0)
        if serial:
            block[f"{key}_serial"] = serial
    for key in ("l1_bytes", "llc_bytes", "memory_bytes", "threads"):
        if fit.get(key):
            block[key] = int(fit[key])
    return block


def update_system_config(path, fit):
    """Updates a system configuration file in place with newly calibrated hardware parameters.

    Exposes the calibration data to downstream compilation passes: `dhir-opt` maps
    the `machine` entry into the `dhir.machine` DLTI dictionary, enabling `analysis/costModel.h`
    to evaluate IR cost directly so transformation passes can evaluate candidates autonomously.
    """
    path = Path(path)
    config = json.loads(path.read_text())
    machine = config.setdefault("machine", {})
    machine.update(config_machine_block(fit))
    node_block = config_node_block(fit)
    for node in config.get("nodes", {}).values():
        node.update(node_block)
    config["calibrated"] = True
    path.write_text(json.dumps(config, indent=2) + "\n")
    return path


def run(cmd, timeout):
    return subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True, timeout=timeout)


STRIDED_FLOP_THRESHOLD = 0.5

# Historic attribute names defined in profile schemas for class throughput values.
LEGACY_RATE_FIELD = {
    "dram": "R_flop_per_second",
    "llc": "R_llc_flop_per_second",
    "l1": "R_l1_flop_per_second",
    "contiguous": "R_contiguous_flop_per_second",
}


def predict(row, fit, num_threads=None):
    """Computes runtime: T = c + h_first*[parallel] + h*entries + max(sum(FLOPs_class / R_class), Bytes / B).

    Work in each memory regime is evaluated at that regime's specific throughput, while unparallelized
    sections are evaluated against single-threaded throughput. Previous heuristic thresholding
    of overall strided fractions incorrectly forced 2mm's 80/20 mixed loop into fully strided DRAM access,
    ignoring compiler-verified cache residency bounds.
    """
    total = max(0.0, float(row.get("operations", 0.0)))
    frac, serial_frac = class_fractions(row)

    speedup = float(fit.get("parallel_speedup", 1.0)) or 1.0
    if speedup < 1.0:
        speedup = 1.0
    rate = {}
    for cls in COMPUTE_CLASSES:
        value = float(fit.get(f"R_{cls}", 0.0) or 0.0)
        if value <= 0.0:
            value = float(fit.get(LEGACY_RATE_FIELD[cls], 0.0) or 0.0)
        rate[cls] = value
    fallback = max(rate.values()) if any(v > 0 for v in rate.values()) else 1.0
    for cls in COMPUTE_CLASSES:
        if rate[cls] <= 0.0:
            rate[cls] = fallback

    serial_rate = {}
    for cls in COMPUTE_CLASSES:
        value = float(fit.get(f"R_{cls}_serial_flop_per_second", 0.0) or 0.0)
        serial_rate[cls] = value if value > 0.0 else rate[cls] / speedup

    bandwidth = float(fit.get("B_byte_per_second", 0.0) or 0.0)

    def compute_seconds(flops_by_class, serial):
        seconds = 0.0
        for cls, flops in flops_by_class.items():
            seconds += flops / (serial_rate[cls] if serial else rate[cls])
        return seconds

    nests = nest_rows(row)
    if nests:
        execution = 0.0
        for nest in nests:
            compute = compute_seconds(nest["classes"], not nest["is_parallel"])
            memory = nest["bytes"] / bandwidth if bandwidth > 0 else 0.0
            execution += max(compute, memory)
    else:
        compute = compute_seconds(
            {cls: total * max(0.0, frac[cls] - serial_frac[cls])
             for cls in COMPUTE_CLASSES}, False)
        compute += compute_seconds(
            {cls: total * serial_frac[cls] for cls in COMPUTE_CLASSES}, True)
        memory = row.get("bytes", 0.0) / bandwidth if bandwidth > 0 else 0.0
        execution = max(compute, memory)

    overhead = overhead_seconds(row, fit["c_seconds"],
                                fit.get("h_first_parallel_entry_seconds", 0.0),
                                fit.get("h_parallel_entry_seconds", 0.0))
    return overhead + execution


def rankdata(values):
    order=sorted(range(len(values)), key=values.__getitem__); ranks=[0.0]*len(values)
    i=0
    while i<len(order):
        j=i+1
        while j<len(order) and values[order[j]]==values[order[i]]: j+=1
        rank=(i+j-1)/2.0
        for k in range(i,j): ranks[order[k]]=rank
        i=j
    return ranks


def spearman(a,b):
    ra=rankdata(a); rb=rankdata(b); am=statistics.mean(ra); bm=statistics.mean(rb)
    num=sum((x-am)*(y-bm) for x,y in zip(ra,rb)); da=sum((x-am)**2 for x in ra); db=sum((y-bm)**2 for y in rb)
    return num/math.sqrt(da*db) if da and db else 0.0


_SESSION_WORKDIR = None


def session_workdir():
    """Allocates a unified temporary directory for the execution run to enable compilation artifact caching."""
    global _SESSION_WORKDIR
    if _SESSION_WORKDIR is None:
        _SESSION_WORKDIR = tempfile.mkdtemp(prefix="dhir_calibrate_")
    return _SESSION_WORKDIR


def dims_str(dims):
    return ",".join(f"{k}={v}" for k, v in sorted(dims.items()))


def kernel_natural_dims(km, kernels):
    natural = {}
    for kernel in kernels:
        try:
            _, dims = km.resolve(kernel)
        except Exception:
            continue
        natural[kernel] = dims
    return natural


def ir_row(kernel, dims, args, km, label=None, threads=None):
    """Extracts operational workload, data traffic, and cache regime splits from IR for a specific configuration."""
    label = label or kernel
    mlir = None
    if dims:
        mlir = Path(args.workdir or "/tmp") / f"{label}_specialized.mlir"
        km.specialize_mlir(kernel, dims, out_path=mlir)
    rep = omp_ir_report(kernel, config=args.config,
                        num_threads=threads or args.num_threads,
                        llc_bytes=args.llc_bytes, l1_bytes=args.l1_bytes,
                        mlir_path=mlir)
    _, resolved = km.resolve(kernel, in_path=mlir, overrides=dims or None)
    ops = float(rep["flops"])
    row = {
        "kernel": label,
        "benchmark": kernel,
        "dimensions": resolved,
        "operations": ops,
        "bytes": float(rep["total_bytes"]),
        "thread_flops": float(rep["thread_flops"]),
        "parallel_entries": int(rep["entries"]),
        "parallel_regions": int(rep.get("nests", 1)),
        "parallel_nests": int(rep.get("parallel_nests", 1)),
        "in_model": True,
        "nest_metrics": rep.get("nest_metrics") or [],
        "operations_formula": "IR: OpenMP-aware DHIR flops",
        "bytes_formula": "IR: OpenMP-aware DHIR total_bytes",
    }
    for field in ("strided_flop_fraction", "in_cache_strided_flop_fraction",
                  "llc_strided_flop_fraction", "dram_strided_flop_fraction",
                  "serial_flop_fraction",
                  "serial_in_cache_strided_flop_fraction",
                  "serial_llc_strided_flop_fraction",
                  "serial_dram_strided_flop_fraction",
                  "serial_contiguous_flop_fraction"):
        row[field] = float(rep.get(field, 0.0))
    row["contiguous_flop_fraction"] = max(0.0, 1.0 - row["strided_flop_fraction"])
    if "serial_contiguous_flop_fraction" not in rep and row["serial_flop_fraction"] >= 0.999:
        row["serial_contiguous_flop_fraction"] = row["contiguous_flop_fraction"]
    row["is_serial"] = row["parallel_nests"] == 0
    total, serial = class_fractions(row)
    for cls in COMPUTE_CLASSES:
        row[f"{cls}_flops"] = ops * total[cls]
        row[f"serial_{cls}_flops"] = ops * serial[cls]
    return row


def measure(kernel, dims, args, repeats=None, threads=None, label=None,
            required=True):
    """Builds and executes a target configuration, returning all validated runtimes.

    The initial execution of each kernel is treated as warmup and excluded. On systems
    featuring dynamic CPU frequency boosting, benchmarks executed immediately following idle
    phases (such as single-threaded compilation) run at transient clock speeds that degrade under sustained load,
    producing unrepresentative 20-40% speed boosts. Retaining that initial run skewed anchor baselines
    away from steady-state conditions, causing gemm kernel projections to diverge by ~20%.
    """
    repeats = args.repeats if repeats is None else repeats
    warmup = max(0, args.warmup)
    threads = args.num_threads if threads is None else threads
    label = label or kernel
    base = ["bash", str(RUN_BENCH), kernel, "1"]
    if dims:
        base += ["--dims", dims_str(dims)]
    if args.config:
        base += ["--config", args.config]
    # Successive repetitions of a setup share the compiled binary, avoiding redundant
    # compilation between runs. For small problem sizes, the compiler pass accounts for
    # roughly triple the duration of actual benchmark execution.
    work = Path(args.workdir or session_workdir()) / f"build_{label}"
    work.mkdir(parents=True, exist_ok=True)
    base += ["--workdir", str(work), "--reuse-build"]
    env = dict(os.environ)
    env["OMP_NUM_THREADS"] = str(threads)
    times = []
    for repeat in range(warmup + repeats):
        cmd = list(base)
        proc = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True,
                              timeout=args.timeout, env=env)
        match = None
        for line in proc.stdout.splitlines():
            found = RESULT_RE.match(line)
            if found and found.group(4) == "PASS":
                match = found
        if match is None:
            detail = (proc.stderr.strip().splitlines() or ["missing PASS RESULT"])[-1]
            if required:
                raise RuntimeError(f"{label} repeat {repeat + 1} was not "
                                   f"correctness-verified: {detail}")
            return times[warmup:]
        times.append(float(match.group(3)))
    return times[warmup:]


def scale_to_target(spec, net, target_seconds, threads=1, allow_shrink=False):
    """Determines a power-of-two scaling multiplier for an anchor's outermost loop bound.

    Rescaling only the outermost dimension preserves innermost strides, cache footprints,
    and memory access patterns targeted by calibration. Restricting adjustments to powers of two
    also maintains memory alignment boundaries. Calculating the factor from seed trials eliminates
    the need to hardcode synthetic hardware throughput estimates into sizing heuristics.
    """
    key = spec.get("scale_key")
    dims = dict(spec["dims"])
    if not key or target_seconds <= 0 or net <= 0:
        return dims, 1.0
    exponent = max(1, int(spec.get("scale_exponent", 1)))
    # Truncate scale steps downward: scale up exclusively via power-of-two multiples
    # bounded by target time, and step down minimally when contracting. Rounding upward
    # could inflate an already sufficient anchor—doubling an L1 test geometry, for example,
    # would needlessly double a 200 MB memory footprint and reference check time.
    steps = int(math.log2(max(target_seconds / net, 1e-12)) / exponent)
    if not allow_shrink:
        steps = max(0, steps)
    factor = 2.0 ** steps
    # Seed executions buried within measurement jitter would suggest unbounded scaling;
    # the sizing configuration therefore imposes an upper bound constrained by available RAM.
    max_scale = float(spec.get("max_scale", 0) or 0)
    if max_scale >= 1.0:
        factor = min(factor, max_scale)
    scaled = max(1, int(dims[key] * factor))
    if key in ("M", "NR"):
        scaled = max(scaled, threads)
    dims[key] = scaled
    return dims, factor


def serial_anchor_spec(spec, parallel_row, threads):
    """Contracts anchor geometry so that single-threaded execution matches target wall-clock duration.

    Working footprints and memory layouts remain governed by invariant leading dimensions;
    scaling only the outermost loop bound ensures the single-thread trial mirrors the parallel
    setup with a reduced iteration count.
    """
    dims = dict(parallel_row.get("dimensions") or spec["dims"])
    key = spec.get("scale_key")
    if key and key in dims:
        exponent = max(1, int(spec.get("scale_exponent", 1)))
        shrink = max(1, 1 << max(0, int(round(threads ** (1.0 / exponent))).bit_length() - 1))
        dims[key] = max(1, dims[key] // shrink)
    return {**spec, "dims": dims}


def anchor_measurement(name, spec, args, km, c_estimate, h_first, h,
                       target_seconds, threads=None, allow_shrink=False,
                       label=None, purity_class=None):
    """Executes a pilot trial on the anchor configuration and iteratively rescales bounds to hit target duration."""
    label = label or name
    kernel = spec["kernel"]
    threads = threads or args.num_threads
    seed_dims = dict(spec["dims"])
    row = ir_row(kernel, seed_dims, args, km, label=label, threads=threads)
    seed_repeats = max(1, min(args.repeats, 2))
    times = measure(kernel, seed_dims, args, repeats=seed_repeats,
                    threads=threads, label=label)
    seconds = sample_stat(times, args.stat)
    parallel = 1 if row["parallel_nests"] > 0 else 0
    net = max(1e-9, seconds - c_estimate - h_first * parallel
              - h * max(0, row["parallel_entries"] - parallel))
    dims = dict(seed_dims)
    budget = float(spec.get("max_scale", 0) or 0)
    for _ in range(3):
        remaining = budget if budget >= 1.0 else 0
        scaled, factor = scale_to_target({**spec, "dims": dims,
                                          "max_scale": remaining}, net,
                                         target_seconds, threads=threads,
                                         allow_shrink=allow_shrink)
        if scaled == dims:
            break
        dims = scaled
        row = ir_row(kernel, dims, args, km, label=label, threads=threads)
        times = measure(kernel, dims, args, repeats=seed_repeats,
                        threads=threads, label=label)
        seconds = sample_stat(times, args.stat)
        parallel = 1 if row["parallel_nests"] > 0 else 0
        net = max(1e-9, seconds - c_estimate - h_first * parallel
                  - h * max(0, row["parallel_entries"] - parallel))
        if budget >= 1.0 and factor > 0:
            budget = max(1.0, budget / factor)  # limit bounds total cumulative expansion
        allow_shrink = False  # dimension reduction permitted solely during the opening iteration
    if len(times) < args.repeats:
        times += measure(kernel, dims, args, repeats=args.repeats - len(times),
                         threads=threads, label=label)
    row["seconds"] = sample_stat(times, args.stat)
    row["samples"] = times
    row["threads"] = threads
    row["anchor"] = name
    if purity_class is not None:
        total, _ = class_fractions(row)
        row["anchor_purity"] = total.get(purity_class, 0.0)
    return row


def print_anchor(name, row):
    purity = row.get("anchor_purity")
    tail = f" purity={purity:.3f}" if purity is not None else ""
    print(f"  {name:<16} {row['benchmark']:<8} {dims_str(row['dimensions']):<26}"
          f" t={row['seconds']:.5f}s ops={row['operations']:.4g}"
          f" bytes={row['bytes']:.4g} entries={row['parallel_entries']}{tail}",
          flush=True)


def anchor_work_seconds(row, fit):
    """Estimates intrinsic arithmetic and memory transfer duration for the anchor, omitting all overhead components."""
    if not fit:
        return 0.0
    stripped = dict(fit)
    stripped["c_seconds"] = 0.0
    stripped["h_parallel_entry_seconds"] = 0.0
    stripped["h_first_parallel_entry_seconds"] = 0.0
    return predict(row, stripped)


def derive_overheads(anchor_rows, fit=None, h_default=3.06e-6):
    """Determines c, h_first, and h via isolated measurements executed within the benchmark harness.

    `c` quantifies invariant per-invocation initialization costs incurred prior to kernel execution:
    MPI runtime setup, hwloc system topology inspection, and memref metadata allocation.
    A trivial sequential kernel provides an isolated measurement of these startup overheads.

    `h_first` represents the additional latency introduced by the initial `omp.parallel` directive:
    instantiating the OpenMP thread team. This is a one-time penalty rather than a recurring cost.
    Because its magnitude rivals topology inspection, conflating it with recurring entry latency
    would artificially exaggerate multi-iteration stencil costs by (entries - 1) * h_first.

    `h` measures recurring dispatch latency when re-entering parallel regions with an existing thread team.
    Sweeping iteration counts on a stencil isolates this quantity: the two runs differ strictly in
    parallel activations, allowing differencing to cancel static baseline overheads.
    """
    parallel_floor = anchor_rows.get("floor_parallel")
    serial_floor = anchor_rows.get("floor_serial")
    lo, hi = anchor_rows.get("entry_lo"), anchor_rows.get("entry_hi")

    h = h_default
    if lo and hi:
        delta_entries = hi["parallel_entries"] - lo["parallel_entries"]
        delta_work = anchor_work_seconds(hi, fit) - anchor_work_seconds(lo, fit)
        delta_t = hi["seconds"] - lo["seconds"] - delta_work
        if delta_entries > 0 and delta_t > 0:
            h = delta_t / delta_entries

    if serial_floor is not None:
        c = serial_floor["seconds"] - anchor_work_seconds(serial_floor, fit)
        h_first = 0.0
        if parallel_floor is not None:
            entries = max(0, parallel_floor["parallel_entries"] - 1)
            h_first = (parallel_floor["seconds"]
                       - anchor_work_seconds(parallel_floor, fit)
                       - c - h * entries)
    elif parallel_floor is not None:
        entries = max(0, parallel_floor["parallel_entries"] - 1)
        c = (parallel_floor["seconds"] - anchor_work_seconds(parallel_floor, fit)
             - h * entries)
        h_first = 0.0
    else:
        raise ValueError("calibration requires a floor anchor")
    return max(1e-9, c), max(0.0, h_first), max(0.0, h)


def run_validation(fit, val_kernels, val_sizing_plan, args, km, profile=None):
    """Profiles benchmark kernels across target dimensions and verifies analytical model accuracy."""
    val_rows = []
    print("\n=========================================================================")
    print(f"  Validation Phase ({len(val_kernels)} kernels)")
    print("=========================================================================")

    for kernel in val_kernels:
        overrides = val_sizing_plan.get(kernel, {})
        try:
            row = ir_row(kernel, overrides, args, km, label=f"{kernel}_val")
        except (RuntimeError, ValueError) as exc:
            print(f"  [{kernel}] SKIP ({exc})")
            continue
        print(f"  [{kernel}] measuring size={dims_str(row['dimensions'])}... ",
              end="", flush=True)
        times = measure(kernel, overrides, args, label=f"{kernel}_val",
                        required=False)
        if not times:
            print("FAIL (no correctness-verified run)")
            continue
        seconds = sample_stat(times, args.stat)
        row["seconds"] = seconds
        row["samples"] = times
        predicted = predict(row, fit, num_threads=args.num_threads)
        error = abs(predicted - seconds) / seconds
        # Predictions cannot be expected to achieve tighter error margins than the empirical
        # variance of the measurement itself; reporting delta to the observed min/max interval
        # confirms whether the prediction fell within the empirical spread (delta = 0).
        low, high = min(times), max(times)
        band_error = max(0.0, low - predicted, predicted - high) / seconds
        spread = (high - low) / low if low > 0 else 0.0
        print(f"measured={seconds:.5f}s  predicted={predicted:.5f}s  "
              f"error={error:.1%}  band={band_error:.1%}  spread={spread:.1%}")
        row.update({
            "predicted_seconds": predicted,
            "absolute_relative_error": error,
            "band_relative_error": band_error,
            "sample_relative_spread": spread,
            "observed_effective_flop_per_second": row["operations"] / seconds,
            "observed_effective_byte_per_second": row["bytes"] / seconds,
        })
        val_rows.append(row)

    if not val_rows:
        print("No validation kernels succeeded.")
        return 1

    errors = [x["absolute_relative_error"] for x in val_rows]
    median_error = statistics.median(errors)
    worst = max(errors)
    rho = spearman([x["seconds"] for x in val_rows],
                   [x["predicted_seconds"] for x in val_rows])
    over = [x["kernel"] for x in val_rows
            if x["band_relative_error"] > args.max_kernel_error]
    noisy = [x["kernel"] for x in val_rows
             if x["sample_relative_spread"] > args.max_kernel_error]
    passed = (median_error <= args.max_median_error and rho >= args.min_spearman
              and not over)

    print("\n-------------------------------------------------------------------------")
    print("  Summary: Kernel Predictions & Error")
    print("-------------------------------------------------------------------------")
    for x in sorted(val_rows, key=lambda r: -r["absolute_relative_error"]):
        print(f"  {x['kernel']:<12}: measured={x['seconds']:>9.5f}s  "
              f"predicted={x['predicted_seconds']:>9.5f}s  "
              f"error={x['absolute_relative_error']:>6.1%}  "
              f"band={x['band_relative_error']:>6.1%}  "
              f"spread={x['sample_relative_spread']:>6.1%}")
    print("-" * 78)
    print(f"median error={median_error:.1%}  worst={worst:.1%}  Spearman={rho:.3f}"
          f"  gate={'PASS' if passed else 'FAIL'}")
    if over:
        print(f"  outside the measured interval by more than "
              f"{args.max_kernel_error:.0%}: {', '.join(over)}")
    if noisy:
        print(f"  own sample spread already exceeds {args.max_kernel_error:.0%} "
              f"(measurement-limited, not model-limited): {', '.join(noisy)}")
    print()

    if profile is not None:
        profile["validation"] = {
            "method": "per-kernel prediction at declared sizes",
            "statistic": args.stat,
            "repeats": args.repeats,
            "predictions": val_rows,
            "median_absolute_relative_error": median_error,
            "worst_absolute_relative_error": worst,
            "worst_band_relative_error": max(x["band_relative_error"] for x in val_rows),
            "measurement_limited_kernels": noisy,
            "spearman_rank_correlation": rho,
            "kernels_over_bound": over,
            "thresholds": {
                "median_absolute_relative_error": args.max_median_error,
                "max_kernel_absolute_relative_error": args.max_kernel_error,
                "spearman_rank_correlation": args.min_spearman,
            },
            "passed": passed,
        }
        for entry in val_rows:
            entry.pop("nest_metrics", None)
        names = {x["kernel"] for x in val_rows}
        merged = [k for k in profile.get("kernels", []) if k["kernel"] not in names]
        merged.extend(val_rows)
        profile["kernels"] = merged
        Path(args.profile).write_text(json.dumps(profile, indent=2, default=str) + "\n")
        print(f"Updated profile with validation results: {args.profile}")

    return 0 if passed else 1


ANCHOR_KERNELS = ("gemm", "syr2k", "add2d", "stream6", "jacobi", "atax")
OVERHEAD_ANCHORS = ("floor_serial", "floor_parallel")


def probe_binary(args, name, attr):
    path = getattr(args, attr, None)
    if path:
        return path if Path(path).exists() else None
    for cand in (ROOT / "build" / "bin" / name,
                 ROOT / "build" / "calibration" / name):
        if cand.exists():
            return str(cand)
    return None


def probe_entry_latency(args):
    """Direct standalone libomp fork/join timing harness, providing a validation reference for h."""
    binary = probe_binary(args, "omp_entry", "omp_entry_binary")
    if not binary:
        return None, None
    env = dict(os.environ)
    env["OMP_NUM_THREADS"] = str(args.num_threads)
    best, threads = None, None
    for _ in range(max(1, args.probe_trials)):
        proc = subprocess.run([binary, str(args.omp_entry_iters)], cwd=ROOT,
                              text=True, capture_output=True,
                              timeout=args.timeout, env=env)
        for line in proc.stdout.splitlines():
            parts = line.strip().split(",")
            if len(parts) == 5 and parts[1] == "omp_entry":
                value = float(parts[4])
                if value > 0 and (best is None or value < best):
                    best, threads = value, int(parts[2])
    return best, threads


def probe_discovery_floor(args):
    """Standalone hwloc hardware discovery benchmark, acting as an empirical check for baseline c."""
    binary = probe_binary(args, "discovery_floor", "discovery_floor_binary")
    if not binary:
        return None
    best = None
    for _ in range(max(1, args.probe_trials)):
        proc = subprocess.run([binary, str(args.discovery_reps)], cwd=ROOT,
                              text=True, capture_output=True, timeout=args.timeout)
        for line in proc.stdout.splitlines():
            parts = line.strip().split(",")
            if len(parts) == 4 and parts[1] == "c_floor":
                value = float(parts[3])
                if value > 0 and (best is None or value < best):
                    best = value
    return best


def measure_overhead_anchors(plan, args, km):
    """Executes the three baseline overhead witnesses: sequential floor, parallel floor, and entry pair."""
    rows = {}
    for name in OVERHEAD_ANCHORS:
        spec = plan.get(name)
        if not spec:
            continue
        try:
            row = ir_row(spec["kernel"], spec["dims"], args, km, label=name)
            times = measure(spec["kernel"], spec["dims"], args, label=name)
        except (RuntimeError, ValueError) as exc:
            print(f"  {name:<16} unavailable ({exc})", flush=True)
            continue
        row["seconds"] = sample_stat(times, args.stat)
        row["samples"] = times
        row["anchor"] = name
        rows[name] = row
        print_anchor(name, row)
    spec = plan.get("entry")
    if spec:
        key, factor = spec.get("entry_key", "T"), int(spec.get("entry_factor", 4))
        for label, dims in (("entry_lo", dict(spec["dims"])),
                            ("entry_hi", {**spec["dims"],
                                          key: spec["dims"][key] * factor})):
            row = ir_row(spec["kernel"], dims, args, km, label=label)
            row["seconds"] = sample_stat(
                measure(spec["kernel"], dims, args, label=label), args.stat)
            row["anchor"] = label
            rows[label] = row
            print_anchor(label, row)
    if "floor_serial" in rows and rows["floor_serial"]["parallel_nests"] > 0:
        print("  note: floor_serial anchor was parallelized; treating the "
              "parallel floor as c and h_first as 0", flush=True)
        rows.pop("floor_serial")
    return rows


def build_argument_parser():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--kernels", nargs="+", default=DEFAULT_KERNELS)
    ap.add_argument("--repeats", type=int, default=5,
                    help="timed measurements per configuration (default: 5)")
    ap.add_argument("--warmup", type=int, default=1,
                    help="runs discarded before timing each configuration, so "
                         "no measurement is taken at an unsustainable boost "
                         "clock (default: 1)")
    ap.add_argument("--stat", choices=("min", "median"), default="min",
                    help="statistic reducing repeats; see sample_stat (default: min)")
    ap.add_argument("--config")
    ap.add_argument("--timeout", type=int, default=900)
    ap.add_argument("--raw-csv", default=str(ROOT/"calibration"/"compute"/"profiles"/"calibration_raw.csv"))
    ap.add_argument("--profile", default=str(ROOT/"calibration"/"compute"/"profiles"/"machine_profile.json"))
    ap.add_argument("--workdir", help="shared working directory for distributed runs")
    ap.add_argument("--max-median-error", type=float, default=0.30)
    ap.add_argument("--max-kernel-error", type=float, default=0.30,
                    help="per-kernel bound for the gate, applied to the distance "
                         "from the prediction to the measured interval (default: 0.30)")
    ap.add_argument("--min-spearman", type=float, default=0.70)
    default_threads = os.cpu_count()
    ap.add_argument("--num-threads", type=int, default=default_threads,
                    help=f"OpenMP thread count per node (default: {default_threads})")
    ap.add_argument("--llc-bytes", type=int, default=None,
                    help="override detected LLC size in bytes")
    ap.add_argument("--l1-bytes", type=int, default=None,
                    help="override detected L1 data cache size in bytes")
    ap.add_argument("--memory-bytes", type=int, default=None,
                    help="override detected available RAM in bytes")
    ap.add_argument("--anchor-seconds", type=float, default=0.25,
                    help="runtime each compute anchor is scaled to, so the "
                         "residual error in c stays a small share of it")
    ap.add_argument("--serial-rates", action=argparse.BooleanOptionalAction, default=True,
                    help="measure each anchor at one thread for the single-thread "
                         "rates serial nests are priced against (default: True)")
    ap.add_argument("--secant-bandwidth", action=argparse.BooleanOptionalAction, default=True,
                    help="measure a second, smaller streaming point so the "
                         "differential bandwidth can be reported (default: True)")
    ap.add_argument("--bandwidth-method", choices=("direct", "secant"), default="direct",
                    help="which bandwidth to calibrate against: the net time of "
                         "the largest streaming point, or the two-point secant "
                         "(default: direct; see derive_direct_rates)")
    ap.add_argument("--auto-size", action=argparse.BooleanOptionalAction, default=True,
                    help="scale anchors to --anchor-seconds; without it the "
                         "declared anchor shapes are used as-is (default: True)")
    ap.add_argument("--probe-trials", type=int, default=3,
                    help="repeats of the standalone cross-check probes")
    ap.add_argument("--omp-entry-binary",
                    help="omp_entry binary; an independent reference for h")
    ap.add_argument("--omp-entry-iters", type=int, default=20000)
    ap.add_argument("--discovery-floor-binary",
                    help="discovery_floor binary; an independent reference for c")
    ap.add_argument("--discovery-reps", type=int, default=5)
    ap.add_argument("--c-floor", type=float, default=None,
                    help="override the measured startup floor c in seconds")
    ap.add_argument("--h-entry", type=float, default=None,
                    help="override the measured parallel-entry latency h in seconds")
    ap.add_argument("--update-config", metavar="FILE",
                    help="write the calibrated machine vector into this system "
                         "config so dhir-opt prices IR with it")
    ap.add_argument("--dims", help="dimension overrides, e.g. gemm:M=2048;add2d:N=8192")
    ap.add_argument("--size", type=int, help="symmetric dimension override")
    ap.add_argument("--only-calibrate", action="store_true",
                    help="write the profile and exit without validating")
    ap.add_argument("--only-validate", action="store_true",
                    help="read the fit from the profile JSON and validate")
    ap.add_argument("--validate", action="store_true",
                    help="validate after calibrating")
    ap.add_argument("--val-kernels", nargs="+", default=None)
    ap.add_argument("--val-size", type=int, default=None)
    ap.add_argument("--val-dims", type=str, default=None)
    return ap


def validation_plan(km, kernels, size, dims):
    plan = {}
    for spec in (str(size) if size else None, dims):
        if not spec:
            continue
        for kernel in kernels:
            parsed = km.parse_dims_str(kernel, spec)
            if parsed:
                plan.setdefault(kernel, {}).update(parsed)
    return plan


def print_fit(fit, args):
    print("\n--- Calibrated Machine Parameters ---")
    print("  Model Mode     : OpenMP-Aware")
    print(f"  Method         : {fit.get('method', 'direct_derivation')}")
    print(f"  Statistic      : {args.stat} of {args.repeats} repeats")
    for cls, label in (("dram", "R_strided(DRAM)"), ("llc", "R_LLC"),
                       ("l1", "R_L1"), ("contiguous", "R_contiguous")):
        rate = fit.get(f"R_{cls}", 0.0)
        serial = fit.get(f"R_{cls}_serial_flop_per_second", 0.0)
        speedup = fit.get(f"parallel_speedup_{cls}")
        tail = f"  1-thread={serial/1e9:.3f} G" + (f" ({speedup:.1f}x)" if speedup else " (derived)")
        print(f"  {label:<15}: {rate/1e9:8.3f} GFLOP/s{tail}")
    print(f"  B_effective    : {fit['B_byte_per_second']/1e9:8.3f} GB/s")
    print(f"  Startup (c)    : {fit.get('c_seconds', 0.0)*1e3:8.3f} ms")
    print(f"  Team start (h0): {fit.get('h_first_parallel_entry_seconds', 0.0)*1e3:8.3f} ms")
    print(f"  Entry lat (h)  : {fit.get('h_parallel_entry_seconds', 0.0)*1e6:8.3f} us")
    print(f"  L1 / LLC       : {fit.get('l1_bytes', 0)/1024:.0f} KB / "
          f"{fit.get('llc_bytes', 0)/(1024*1024):.1f} MB")
    print(f"  Threads        : {fit.get('threads', args.num_threads)}")
    print("-" * 60, flush=True)


def main():
    ap = build_argument_parser()
    args = ap.parse_args()
    if args.repeats < 1:
        ap.error("--repeats must be positive")

    sizing = load_adaptive_sizing()
    if sizing is None:
        ap.error("calibration/compute/adaptive_sizing.py is required")
    if args.llc_bytes is None:
        args.llc_bytes = sizing.detect_last_level_cache()
    if args.l1_bytes is None:
        args.l1_bytes = sizing.detect_l1_data_cache()
    if args.memory_bytes is None:
        args.memory_bytes = sizing.detect_available_ram()

    if args.workdir:
        work = Path(args.workdir)
        work.mkdir(parents=True, exist_ok=True)
        if ap.get_default("profile") == args.profile:
            args.profile = str(work / "machine_profile.json")
        if ap.get_default("raw_csv") == args.raw_csv:
            args.raw_csv = str(work / "calibration_raw.csv")

    km = load_kernels()
    val_kernels = args.val_kernels or args.kernels
    val_plan = validation_plan(km, val_kernels, args.val_size or args.size,
                               args.val_dims or args.dims)

    if args.only_validate:
        path = Path(args.profile)
        if not path.exists():
            raise RuntimeError(f"Profile {args.profile} does not exist. Calibrate first.")
        profile = json.loads(path.read_text())
        fit = profile.get("representative_machine")
        if not fit:
            raise RuntimeError(f"Profile {args.profile} has no 'representative_machine'.")
        print(f"Loaded calibrated parameters from {args.profile}")
        print_fit(fit, args)
        return run_validation(fit, val_kernels, val_plan, args, km, profile=profile)

    natural = kernel_natural_dims(km, ANCHOR_KERNELS)
    plan = sizing.get_auto_sizing_plan(llc_bytes=args.llc_bytes,
                                       l1_bytes=args.l1_bytes,
                                       cpus=args.num_threads,
                                       mem_avail_bytes=args.memory_bytes,
                                       natural=natural)
    hardware = plan["hardware"]
    print("Anchor sizing from detected hardware:", flush=True)
    print(f"  L1 {hardware['l1_bytes']/1024:.0f} KB, "
          f"LLC {hardware['llc_bytes']/(1024*1024):.1f} MB, "
          f"RAM {hardware['mem_avail_bytes']/(1024**3):.2f} GB, "
          f"{hardware['cpus']} threads", flush=True)

    anchor_rows = measure_overhead_anchors(plan, args, km)
    c, h_first, h = derive_overheads(anchor_rows)
    if args.c_floor is not None:
        c = args.c_floor
    if args.h_entry is not None:
        h = args.h_entry
    target = args.anchor_seconds if args.auto_size else 0.0

    anchors, serial_rates = {}, {}
    # Single-threaded anchors run prior to parallel tests so multi-threaded baselines
    # sit temporally adjacent to the validation stage; hardware thermal/frequency drift over
    # several minutes can perturb matrix-multiplication timings beyond target model error bounds.
    if args.serial_rates:
        for cls in COMPUTE_CLASSES:
            spec = plan.get(cls)
            if not spec:
                continue
            serial_spec = serial_anchor_spec(spec, {"dimensions": spec["dims"]},
                                             args.num_threads)
            row = anchor_measurement(cls, serial_spec, args, km, c, 0.0, h, target,
                                     threads=1, allow_shrink=True,
                                     label=f"{cls}_serial", purity_class=cls)
            print_anchor(f"{cls}@1thread", row)
            if row["operations"] > 0:
                serial_rates[cls] = row["operations"] / net_time(row, c, h, 0.0)
            anchor_rows[f"{cls}_serial"] = row

    for cls in COMPUTE_CLASSES:
        spec = plan.get(cls)
        if not spec:
            continue
        row = anchor_measurement(cls, spec, args, km, c, h_first, h, target,
                                 purity_class=cls)
        print_anchor(cls, row)
        if row.get("anchor_purity", 1.0) < 0.99:
            print(f"    warning: {cls} anchor is only "
                  f"{row['anchor_purity']:.1%} {cls}-classified; its rate is a "
                  f"blend of regimes", flush=True)
        anchors[cls] = row
        anchor_rows[cls] = row

    band_spec = plan["bandwidth"]
    secant_data = {}
    small = None
    if args.secant_bandwidth and band_spec.get("secant_dims"):
        small = anchor_measurement("bandwidth_small", band_spec, args, km, c,
                                   h_first, h, 0.0, label="bandwidth_small")
        print_anchor("bandwidth_small", small)
        anchor_rows["bandwidth_small"] = small
    # Direct bandwidth is derived from the largest streaming footprint, minimizing the relative
    # contribution of residual invocation error c to net duration.
    band = anchor_measurement("bandwidth",
                              {**band_spec,
                               "dims": band_spec.get("secant_dims", band_spec["dims"])},
                              args, km, c, h_first, h, 0.0, label="bandwidth")
    print_anchor("bandwidth", band)
    anchor_rows["bandwidth"] = band
    if small is not None:
        secant_data["bandwidth_secant"] = {"bytes": small["bytes"],
                                           "seconds": small["seconds"],
                                           "parallel_entries": small["parallel_entries"],
                                           "parallel_nests": small["parallel_nests"]}

    fit = None
    for _ in range(2):
        c_new, h_first_new, h_new = derive_overheads(anchor_rows, fit)
        c = args.c_floor if args.c_floor is not None else c_new
        h = args.h_entry if args.h_entry is not None else h_new
        h_first = h_first_new
        fit = derive_direct_rates(list(anchor_rows.values()), h_empirical=h,
                                  c_floor=c, h_first=h_first,
                                  num_threads=args.num_threads,
                                  secant_data=secant_data if secant_data else None,
                                  l1_bytes=args.l1_bytes, llc_bytes=args.llc_bytes,
                                  anchors=anchors, bandwidth_row=band,
                                  serial_rates=serial_rates,
                                  bandwidth_method=args.bandwidth_method)
    fit["memory_bytes"] = args.memory_bytes
    fit["statistic"] = args.stat
    fit["repeats"] = args.repeats
    print_fit(fit, args)
    return finish_calibration(fit, anchor_rows, val_kernels, val_plan, args, km)


def finish_calibration(fit, anchor_rows, val_kernels, val_plan, args, km):
    """Serializes raw timing records and machine profiles to disk, then runs validation if requested."""
    raw = []
    for name, row in anchor_rows.items():
        for index, seconds in enumerate(row.get("samples", [row.get("seconds", 0.0)])):
            raw.append({"record_type": "anchor", "kernel": name,
                        "repeat": index + 1, "bytes": row["bytes"],
                        "operations": row["operations"], "iterations": "",
                        "seconds": seconds, "status": "PASS"})
    Path(args.raw_csv).parent.mkdir(parents=True, exist_ok=True)
    fields = ["record_type", "kernel", "repeat", "bytes", "operations",
              "iterations", "seconds", "status"]
    with open(args.raw_csv, "w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(raw)

    anchor_summary = []
    for name, row in anchor_rows.items():
        entry = {k: row[k] for k in ("kernel", "benchmark", "dimensions",
                                     "operations", "bytes", "seconds",
                                     "parallel_entries", "parallel_nests")
                 if k in row}
        entry["anchor"] = name
        entry["threads"] = row.get("threads", args.num_threads)
        entry["purity"] = row.get("anchor_purity")
        # Single-core anchors fall outside the scope of team-level predictive equations;
        # evaluating them against multi-threaded models would misstate prediction error.
        if entry["threads"] == args.num_threads:
            entry["predicted_seconds"] = predict(row, fit, num_threads=args.num_threads)
            entry["absolute_relative_error"] = (
                abs(entry["predicted_seconds"] - row["seconds"]) / row["seconds"]
                if row.get("seconds") else 0.0)
        samples = row.get("samples") or []
        if len(samples) > 1:
            entry["sample_relative_spread"] = (max(samples) - min(samples)) / min(samples)
        anchor_summary.append(entry)

    checks = {}
    probe_h, probe_threads = probe_entry_latency(args)
    if probe_h is not None:
        checks["h_parallel_entry_seconds"] = {
            "calibrated": fit["h_parallel_entry_seconds"],
            "probe": probe_h, "probe_threads": probe_threads,
            "ratio_calibrated_over_probe": fit["h_parallel_entry_seconds"] / probe_h,
            "source": "calibration/compute/drivers/omp_entry_main.cc",
            "note": "the probe times a bare omp parallel for; the calibrated "
                    "value is the re-entry cost of the compiled kernel's own "
                    "regions, so the probe is a lower bound"}
    probe_c = probe_discovery_floor(args)
    if probe_c is not None:
        checks["c_seconds"] = {
            "calibrated": fit["c_seconds"], "probe": probe_c,
            "ratio_calibrated_over_probe": fit["c_seconds"] / probe_c,
            "source": "calibration/compute/drivers/discovery_floor_main.cc",
            "note": "the probe times only the hwloc topology scan in a fresh "
                    "process; c also covers MPI startup and descriptor setup, "
                    "and is measured through the benchmark harness that pays it"}

    profile = {
        "schema_version": 3,
        "scope": "one representative machine; kernel effective rates are "
                 "observations, not node peak rates",
        "model": "T = c + h_first*[has parallel region] + h*(entries-1) + "
                 "max(sum(class_flops/R_class), bytes/B)",
        "estimate_semantics": "FLOPs and compulsory bytes from "
                              "analysis/costModel.h (IR access maps); not "
                              "hardware counters",
        "representative_machine": fit,
        "anchors": anchor_summary,
        "kernels": [],
        "out_of_model_kernels": [],
        "parameter_checks": checks,
        "validation": None,
        "raw_csv": str(Path(args.raw_csv).resolve()),
    }
    Path(args.profile).parent.mkdir(parents=True, exist_ok=True)
    Path(args.profile).write_text(json.dumps(profile, indent=2, default=str) + "\n")
    print(f"Calibrated machine profile saved to: {args.profile} (raw={args.raw_csv})")
    if args.update_config:
        written = update_system_config(args.update_config, fit)
        print(f"Machine vector written into system config: {written}\n"
              f"  dhir-opt --dhir-omp-cost-model-report <kernel.mlir> {written}"
              f"  now prints predicted_seconds")

    if args.only_calibrate or not args.validate:
        print("Calibration complete.")
        return 0
    return run_validation(fit, val_kernels, val_plan, args, km, profile=profile)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, ValueError, subprocess.TimeoutExpired) as exc:
        print(f"calibration error: {exc}", file=sys.stderr)
        sys.exit(2)

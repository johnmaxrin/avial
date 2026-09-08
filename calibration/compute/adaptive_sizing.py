#!/usr/bin/env python3
"""Dynamic problem dimension synthesis for OpenMP-aware platform calibration.

Each calibration benchmark anchor simultaneously adheres to three governing principles:

1. **Regime Isolation.** The throughput classes modeled in `analysis/costModel.h`
   are differentiated primarily by where the strided memory operand resides (L1,
   LLC, or off-chip DRAM). Consequently, each anchor's strided operand must fit
   definitively within its designated hierarchy level. Dimensions are computed
   dynamically from probed L1 and LLC capacities rather than hardcoded sizes.

2. **Structural Cache Alignment.** Cache set conflict dynamics depend directly on
   the leading matrix dimension rather than aggregate memory volume: when row strides
   align with cache set associativity boundaries, rows map to identical sets.
   Because power-of-two strides exhibit distinct conflict characteristics from odd
   strides, anchors retain the kernel's canonical leading dimensions and scale
   strictly by powers of two. Arbitrary dimensions risk shifting the workload
   into unrepresentative cache conflict regimes.

3. **Overhead Amortization.** Constant launch and discovery latency c is incurred
   once per invocation. Anchors must execute long enough to ensure c's measurement
   uncertainty does not distort throughput metrics. Target runtimes are achieved by
   expanding the outermost loop bound, preserving both the working set regime and
   inner loop spatial layout.

Dimensions defined here serve as baseline seeds: `calibrate.py` benchmarks the seed
and scales the outermost loop by powers of two to reach target durations, avoiding
hardcoded hardware performance assumptions.
"""

import math
import os
import re
from pathlib import Path

DEFAULT_L1_BYTES = 32 * 1024
DEFAULT_LLC_BYTES = 32 * 1024 * 1024
DEFAULT_RAM_BYTES = 2 * 1024 * 1024 * 1024


def round_to_multiple(val, multiple=64):
    """Aligns an integer upward to the nearest multiple of the specified boundary."""
    val = int(val)
    rem = val % multiple
    return val if rem == 0 else val + (multiple - rem)


def next_pow2(val):
    val = max(1, int(val))
    return 1 << (val - 1).bit_length()


def prev_pow2(val):
    val = max(1, int(val))
    return 1 << (val.bit_length() - 1)


def _parse_cache_size(text):
    m = re.match(r"^(\d+)\s*([KkMmGg]?)$", text.strip())
    if not m:
        return None
    num = int(m.group(1))
    unit = m.group(2).upper()
    return num * {"": 1, "K": 1024, "M": 1024 ** 2, "G": 1024 ** 3}[unit]


def _iter_cache_indices():
    base = Path("/sys/devices/system/cpu/cpu0/cache")
    for idx in range(32):
        d = base / f"index{idx}"
        if not (d / "size").exists():
            continue
        try:
            size = _parse_cache_size((d / "size").read_text())
            level = (d / "level").read_text().strip() if (d / "level").exists() else ""
            ctype = (d / "type").read_text().strip() if (d / "type").exists() else ""
        except OSError:
            continue
        if size:
            yield level, ctype, size


def detect_last_level_cache():
    """Identifies the maximum capacity among host data or unified caches (LLC) in bytes."""
    best = max((s for _, t, s in _iter_cache_indices()
                if t in ("Data", "Unified")), default=0)
    return best or DEFAULT_LLC_BYTES


def detect_l1_data_cache():
    """Retrieves host L1 Data Cache capacity in bytes."""
    for level, ctype, size in _iter_cache_indices():
        if level == "1" and ctype == "Data":
            return size
    return DEFAULT_L1_BYTES


def detect_available_ram():
    """Parses unallocated system RAM in bytes from /proc/meminfo."""
    try:
        for line in Path("/proc/meminfo").read_text().splitlines():
            if line.startswith("MemAvailable:"):
                return int(line.split()[1]) * 1024
    except OSError:
        pass
    return DEFAULT_RAM_BYTES


def detect_online_cpus():
    return os.cpu_count() or 2


def regime_inner_extents(l1_bytes=None, llc_bytes=None, element_bytes=4):
    """Derives square matrix extents ensuring an extent x extent block targets each cache level.

    The three strided anchors maintain an identical GEMM structure, adjusting solely the
    reduction operand `B[K][N]`. Because this is the strided array, its residency governs
    the transition across R_l1, R_llc, and R_strided regimes. Maintaining power-of-two
    extents preserves cache conflict characteristics typical of benchmark matrices,
    preventing unrepresentative set spreading caused by odd strides.
    """
    l1 = l1_bytes or detect_l1_data_cache()
    llc = llc_bytes or detect_last_level_cache()

    def largest_fitting(limit):
        extent = 1
        while (2 * extent) ** 2 * element_bytes <= limit:
            extent *= 2
        return extent

    # Allocating at half cache capacity reserves space for streaming inputs and output buffers,
    # preventing premature eviction under non-ideal LRU replacement policies.
    l1_extent = largest_fitting(max(element_bytes * 16, l1 // 2))
    llc_extent = largest_fitting(max(element_bytes * 16, llc // 2))
    return {"l1": l1_extent, "llc": max(llc_extent, 2 * l1_extent),
            "l1_bytes": l1, "llc_bytes": llc}


def strided_anchor_dims(regime, natural, l1_bytes=None, llc_bytes=None,
                        element_bytes=4, threads=1, mem_avail_bytes=None):
    """Generates GEMM matrix dimensions situating strided operand B[K][N] within a target cache tier.

    Adheres to two key sizing constraints:

    *Expansion is confined to reduction dimension K.* B's temporal reuse window spans K*N
    elements. Increasing K scales memory volume linearly with cache capacity. In contrast,
    scaling square matrices quadratically causes excessive memory allocation (e.g. multi-gigabyte
    buffers on 100+ MB LLC systems leading to paging and prohibitive reference pass times).
    Preserving natural N keeps row strides and cache indexing identical to predicted kernels.

    *M scales modestly with worker thread count.* Seed profiling guides subsequent scaling
    in calibrate.py, so the initial run must execute quickly across heterogeneous hardware
    rather than evaluating the entire workload upfront.

    For L1 and LLC tiers, N is scaled symmetrically: retaining a full 1024 leading dimension
    for L1 would yield an artificially brief reduction loop dominated by loop setup overhead.
    """
    extents = regime_inner_extents(l1_bytes, llc_bytes, element_bytes)
    llc = extents["llc_bytes"]
    n_nat = natural.get("N", 1024)
    k_nat = natural.get("K", n_nat)
    # Provides sufficient outer iterations to saturate threads without incurring high seed run latency.
    m = max(8, 2 * threads)

    if regime == "dram":
        n = n_nat
        # Mirrors the cost model qualification in analysis/costModel.h: total active footprint
        # encompasses operand B alongside active streaming vectors and accumulator rows.
        k = k_nat
        while k * n * element_bytes + 2 * n * element_bytes <= llc:
            k *= 2
    else:
        n = k = extents[regime]

    # Constrains total memory footprint (A, B, C plus verification buffers) within available RAM;
    # reducing K rather than N preserves the underlying spatial stride class.
    budget = (mem_avail_bytes or detect_available_ram()) // 4
    while k > 1 and (m * k + k * n + 2 * m * n) * element_bytes > budget:
        k //= 2
    dims = {"M": int(m), "N": int(n), "K": int(k)}
    return dims, gemm_max_scale(dims, budget, element_bytes)


def gemm_max_scale(dims, budget, element_bytes=4):
    """Computes the maximum power-of-two multiplier for dimension M within the memory `budget`.

    Guards calibrate.py against unbounded expansion when initial seed durations approach timer
    granularity limits. Accounts for matrix operands A, B, C and reference validation buffers.
    """
    m, n, k = dims["M"], dims["N"], dims["K"]
    fixed = k * n * element_bytes
    per_row = (m * k + 2 * m * n) * element_bytes
    if per_row <= 0:
        return 1
    room = max(0, budget - fixed) / per_row
    scale = 1
    while scale * 2 <= room:
        scale *= 2
    return max(1, scale)


def square_max_scale(extent, arrays, budget, element_bytes=4):
    """Calculates the maximum power-of-two growth factor for square kernels permissible under `budget`."""
    scale = 1
    while arrays * (extent * scale * 2) ** 2 * element_bytes <= budget:
        scale *= 2
    return max(1, scale)


BANDWIDTH_SECANT_RATIO = 4


def bandwidth_anchor(natural, llc_bytes=None, mem_avail_bytes=None,
                     element_bytes=4, streams=6):
    """Defines two streaming configurations with memory traffic separated by a power-of-two ratio.

    Varying solely row counts preserves row strides, DRAM page interleaving, and hardware
    prefetch dynamics. Differential measurement cancels out fixed process launch latency
    and OpenMP dispatch overhead. The primary anchor matches the benchmark's natural shape
    when memory permits. A 4x ratio is chosen over 2x so timing variances between sampling
    points represent a smaller fraction of the secant denominator while remaining in DRAM.
    """
    llc = llc_bytes or detect_last_level_cache()
    mem = mem_avail_bytes or detect_available_ram()
    n = natural.get("N", 4096)
    m_nat = natural.get("M", n)

    per_row = element_bytes * n * streams
    # Caps the peak allocation to 25% of available RAM to accommodate concurrent compilation workloads.
    max_rows = prev_pow2(max(2, (mem // 4) // per_row))
    rows = min(prev_pow2(m_nat), max_rows)
    # Ensures the base point exceeds LLC capacity to prevent cache hits from corrupting DRAM bandwidth estimates.
    ratio = BANDWIDTH_SECANT_RATIO
    while rows // ratio >= 2 and (rows // ratio) * per_row < 4 * llc:
        rows *= 2
        if rows > max_rows:
            rows = max_rows
            break
    base_rows = max(2, rows // ratio)
    return {"base": {"M": int(base_rows), "N": int(n)},
            "secant": {"M": int(rows), "N": int(n)}}


def get_auto_sizing_plan(llc_bytes=None, l1_bytes=None, cpus=None,
                         mem_avail_bytes=None, natural=None):
    """Assembles calibration anchor configurations corresponding to each target roofline parameter."""
    llc = llc_bytes or detect_last_level_cache()
    l1 = l1_bytes or detect_l1_data_cache()
    mem = mem_avail_bytes or detect_available_ram()
    threads = cpus or detect_online_cpus()
    natural = natural or {}
    gemm_nat = natural.get("gemm", {"M": 1024, "N": 1024, "K": 1024})
    syr2k_nat = natural.get("syr2k", {"N": 1024, "M": 1024})
    add2d_nat = natural.get("add2d", {"M": 4096, "N": 4096})
    stream_nat = natural.get("stream6", {"M": 4096, "N": 4096})
    jacobi_nat = natural.get("jacobi", {"T": 100, "N": 768})
    atax_nat = natural.get("atax", {"M": 512, "N": 512})

    band = bandwidth_anchor(stream_nat, llc_bytes=llc, mem_avail_bytes=mem)
    # Sizing the parallel floor anchor to the shared cache ensures memory page mapping and cold TLB
    # initialization match real kernel invocations, while keeping arithmetic compute negligible.
    floor_extent = 1
    while (2 * floor_extent) ** 2 * 4 * 4 <= llc:
        floor_extent *= 2
    floor_extent = max(64, floor_extent)
    plan = {
        # Baseline overhead captures pre-execution setup: MPI bootstrap, topology enumeration,
        # and descriptor allocation. Evaluating an unparallelized kernel captures this baseline
        # while isolating it from multi-threaded team allocation latency.
        "floor_serial": {"kernel": "atax",
                         "dims": {k: 64 for k in atax_nat}},
        "floor_parallel": {"kernel": "add2d",
                           "dims": {k: floor_extent for k in add2d_nat}},
        # Differential runs across two stencil iteration counts cancel startup and team creation,
        # isolating recurring per-entry re-dispatch latency.
        "entry": {"kernel": "jacobi", "dims": dict(jacobi_nat),
                  "entry_key": "T", "entry_factor": 4},
        "contiguous": {"kernel": "syr2k", "dims": dict(syr2k_nat),
                       "scale_key": "N", "scale_exponent": 3,
                       "max_scale": square_max_scale(syr2k_nat.get("N", 1024), 4,
                                                     mem // 4)},
        "bandwidth": {"kernel": "stream6", "dims": band["base"],
                      "secant_dims": band["secant"], "scale_key": None},
    }
    for regime in ("l1", "llc", "dram"):
        dims, max_scale = strided_anchor_dims(regime, gemm_nat, l1_bytes=l1,
                                              llc_bytes=llc, threads=threads,
                                              mem_avail_bytes=mem)
        if regime == "l1":
            max_scale = min(max_scale, max(1, 655360 // dims["M"]))
        plan[regime] = {
            "kernel": "gemm",
            "dims": dims,
            "scale_key": "M",
            "scale_exponent": 1,
            "max_scale": max_scale,
        }
    plan["hardware"] = {
        "l1_bytes": l1,
        "llc_bytes": llc,
        "mem_avail_bytes": mem,
        "cpus": threads,
        "inner_extents": regime_inner_extents(l1, llc),
    }
    return plan


if __name__ == "__main__":
    plan = get_auto_sizing_plan()
    hw = plan["hardware"]
    print("Detected hardware:")
    print(f"  CPUs      : {hw['cpus']}")
    print(f"  L1 data   : {hw['l1_bytes'] / 1024:.0f} KB")
    print(f"  LLC       : {hw['llc_bytes'] / (1024 * 1024):.1f} MB")
    print(f"  Avail RAM : {hw['mem_avail_bytes'] / (1024 ** 3):.2f} GB")
    print("\nAnchor seeds:")
    for name in ("floor_serial", "floor_parallel", "entry", "l1", "llc", "dram",
                 "contiguous", "bandwidth"):
        entry = plan[name]
        extra = ""
        if "secant_dims" in entry:
            extra = f"  secant={entry['secant_dims']}"
        if "entry_key" in entry:
            extra = (f"  x{entry['entry_factor']} on {entry['entry_key']}")
        print(f"  {name:<15}: {entry['kernel']:<8} {entry['dims']}{extra}")

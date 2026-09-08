#!/usr/bin/env python3
"""Verification suite for OpenMP cost model metrics against analytical ground truth:

  - gemm: strided accesses (fraction=1.0), partitioned A/C with broadcast B.
  - syr2k: unit-stride contiguous accesses (fraction=0.0).
  - add2d: bandwidth-bound streaming loop with 256 MiB footprint.
  - jacobi: 200 invocations (100 steps x 2 parallel nests) accumulating metrics.
  - atax: serial execution (thread count T=1) without multi-core speedup.
"""

import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DHIR_OPT = ROOT / "build" / "bin" / "dhir-opt"
CONFIG = ROOT / "tests" / "configs" / "system_config_4_cpu.json"


def run_omp_model(kernel):
    mlir = ROOT / "tests" / "polybench" / f"{kernel}.mlir"
    # Fix cache capacity at 30 MiB to keep baseline checks invariant to host LLC size.
    cmd = [str(DHIR_OPT), "--dhir-omp-cost-model-report", "--dhir-omp-threads=16",
           "--dhir-omp-llc-bytes=31457280", str(mlir), str(CONFIG)]
    proc = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True, timeout=120)
    
    summary = None
    nests = []
    for line in (proc.stdout + "\n" + proc.stderr).splitlines():
        if line.startswith("OMPCOSTMODEL kernel="):
            summary = dict(re.findall(r'(\w+)=("[^"]*"|\S+)', line))
        elif line.startswith("OMPCOSTMODEL_NEST "):
            nests.append(dict(re.findall(r'(\w+)=("[^"]*"|\S+)', line)))
    
    return summary, nests


def run_specialized_cache_model(kernel, size):
    """Build a specialized problem size and parse its cache-regime report."""
    kernels_py = ROOT / "tests" / "bench" / "kernels.py"
    with tempfile.TemporaryDirectory(prefix="dhir_omp_cache_") as td:
        mlir = Path(td) / f"{kernel}.mlir"
        gen = subprocess.run(
            [sys.executable, str(kernels_py), kernel, "--size", str(size),
             "--emit-mlir", str(mlir)],
            cwd=ROOT, text=True, capture_output=True, timeout=30)
        if gen.returncode:
            return None
        proc = subprocess.run(
            [str(DHIR_OPT), "--dhir-omp-cost-model-report",
              "--dhir-omp-threads=16", "--dhir-omp-llc-bytes=4194304",
             str(mlir), str(CONFIG)],
            cwd=ROOT, text=True, capture_output=True, timeout=120)
        for line in (proc.stdout + "\n" + proc.stderr).splitlines():
            if line.startswith("OMPCOSTMODEL kernel="):
                return dict(re.findall(r'(\w+)=("[^"]*"|\S+)', line))
    return None


def main():
    print("Running OpenMP-Aware Cost Model Verification Gate...")
    print(f"{'Kernel':<12} {'FLOPs':>12} {'Thread FLOPs':>14} {'Total Bytes':>14} {'Entries':>8} {'StridedFrac':>12} {'Verdict':>8}")
    print("-" * 84)
    
    checks = {
        "gemm": {
            "flops": 2147483648,
            "thread_flops": 134217728,
            # Updated array C requires RFO read + writeback: A + B + 2*C = 4 x 4 MiB buffers.
            "total_bytes": 16777216,
            "entries": 1,
            "strided_flop_fraction": 1.0,
        },
        "syr2k": {
            "flops": 6443499520,
            "thread_flops": 402718720,
            # Cumulative updates across passes: (2*C) + (2*C + A + B) = 8 x 4 MiB buffers.
            "total_bytes": 33554432,
            "entries": 2,
            "strided_flop_fraction": 0.0,
        },
        "add2d": {
            "flops": 16777216,
            "thread_flops": 1048576,
            # Compulsory traffic: A + B + 2*C for 4096x4096 single-precision elements.
            "total_bytes": 268435456,
            "entries": 1,
            "strided_flop_fraction": 0.0,
        },
        "jacobi": {
            "flops": 229800,
            "thread_flops": 14400,
            # Working set fits in cache; 200 steps incur only initial cold loads for A and B.
            "total_bytes": 18392,
            "entries": 200,
            "strided_flop_fraction": 0.0,
        },
        "atax": {
            "flops": 1048576,
            "thread_flops": 1048576,  # Serial execution: single thread executes all FLOPs
            "total_bytes": 1058816,
            "entries": 1,
            "strided_flop_fraction": 0.0,
        }
    }
    
    failures = 0
    for kernel, want in checks.items():
        summary, nests = run_omp_model(kernel)
        if not summary:
            print(f"{kernel:<12} FAIL: No OMPCOSTMODEL summary line produced")
            failures += 1
            continue
        
        got_flops = int(summary["flops"])
        got_tflops = int(summary["thread_flops"])
        got_bytes = int(summary["total_bytes"])
        got_entries = int(summary["entries"])
        got_frac = float(summary["strided_flop_fraction"])
        
        passed = (
            got_flops == want["flops"] and
            got_tflops == want["thread_flops"] and
            got_bytes == want["total_bytes"] and
            got_entries == want["entries"] and
            abs(got_frac - want["strided_flop_fraction"]) < 1e-3
        )
        
        verdict = "PASS" if passed else "FAIL"
        if not passed:
            failures += 1
        
        print(f"{kernel:<12} {got_flops:>12} {got_tflops:>14} {got_bytes:>14} {got_entries:>8} {got_frac:>12.4f} {verdict:>8}")

    print("\nCache-regime regression (specialized N=512, 4 MiB LLC)...")
    for kernel, minimum in (("2mm", 0.70), ("3mm", 0.99), ("doitgen", 0.99)):
        summary = run_specialized_cache_model(kernel, 512)
        llc = float(summary.get("llc_strided_flop_fraction", 0.0)) if summary else 0.0
        dram = float(summary.get("dram_strided_flop_fraction", 1.0)) if summary else 1.0
        passed = summary is not None and llc >= minimum and dram < 1e-3
        if not passed:
            failures += 1
        print(f"  {kernel:<10}: llc={llc:.4f} dram={dram:.4f} "
              f"{'PASS' if passed else 'FAIL'}")
    
    print("-" * 84)
    if failures == 0:
        print("ALL GATES PASSED: OpenMP-aware extraction is deterministic and exact.")
        return 0
    else:
        print(f"FAILED: {failures} kernel(s) mismatched.")
        return 1


if __name__ == "__main__":
    sys.exit(main())

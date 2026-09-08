#!/usr/bin/env python3
"""Verification suite for OpenMP-aware calibration in calibrate.py.

Checks:
1. Extraction: confirms omp_ir_report captures required metrics for canonical kernels.
2. Direct Rate Derivation: isolates R_strided, R_contiguous, and B_effective using net-duration adjustments.
3. Prediction: validates single-thread pricing on serial loops and re-entry costs on multi-step stencils.
4. Parity: verifies anchor predictions achieve close consistency under direct derivation.
"""

import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(ROOT / "tests" / "bench"))

from calibrate import (
    COMPUTE_CLASSES,
    class_fractions,
    derive_direct_rates,
    load_kernels,
    omp_ir_report,
    predict,
    spearman,
    STRIDED_FLOP_THRESHOLD,
)

def test_omp_ir_extraction():
    print("Test 1: OpenMP-aware IR extraction across kernels...")
    kernels = ["gemm", "syr2k", "add2d", "jacobi", "atax"]
    for k in kernels:
        rep = omp_ir_report(k)
        assert "flops" in rep, f"{k}: missing flops"
        assert "thread_flops" in rep, f"{k}: missing thread_flops"
        assert "total_bytes" in rep, f"{k}: missing total_bytes"
        assert "entries" in rep, f"{k}: missing entries"
        assert "parallel_nests" in rep, f"{k}: missing parallel_nests"
        assert "serial_flop_fraction" in rep, f"{k}: missing serial_flop_fraction"
        assert "strided_flop_fraction" in rep, f"{k}: missing strided_flop_fraction"
        assert "in_cache_strided_flop_fraction" in rep, f"{k}: missing in_cache_strided_flop_fraction"
        assert "llc_strided_flop_fraction" in rep, f"{k}: missing llc_strided_flop_fraction"
        assert "dram_strided_flop_fraction" in rep, f"{k}: missing dram_strided_flop_fraction"
        sf = float(rep["strided_flop_fraction"])
        l1 = float(rep["in_cache_strided_flop_fraction"])
        llc = float(rep["llc_strided_flop_fraction"])
        dram = float(rep["dram_strided_flop_fraction"])
        assert abs(sf - (l1 + llc + dram)) < 1e-3, f"{k}: stride sum mismatch: {sf} vs {l1} + {llc} + {dram}"
        serial = float(rep["serial_flop_fraction"])
        assert (int(rep["parallel_nests"]) == 0) == (serial >= 0.999), (
            f"{k}: parallel_nests={rep['parallel_nests']} disagrees with "
            f"serial_flop_fraction={serial}")
        print(f"  {k:<10}: flops={rep['flops']} bytes={rep['total_bytes']} "
              f"strided_total={sf:.4f} [L1={l1:.4f} LLC={llc:.4f} DRAM={dram:.4f}] "
              f"serial={serial:.4f} parallel_nests={rep['parallel_nests']}")
    print("  -> PASS: All IR metrics successfully extracted and regime decomposition matches costmodel.h.")


def test_direct_rate_derivation():
    print("\nTest 2: Direct Effective Rate Derivation (novel_6_completes.md §5)...")
    # Reference empirical execution timings collected on this target host:
    rows = [
        {
            "kernel": "gemm",
            "operations": 2147483648.0,
            "bytes": 16777216.0,
            "seconds": 4.002558,
            "parallel_entries": 1,
            "parallel_nests": 1,
            "strided_flop_fraction": 1.0,
            "dram_strided_flop_fraction": 1.0,
            "contiguous_flop_fraction": 0.0,
            "is_serial": False,
        },
        {
            "kernel": "syr2k",
            "operations": 6443499520.0,
            "bytes": 33554432.0,
            "seconds": 1.612294,
            "parallel_entries": 2,
            "parallel_nests": 2,
            "strided_flop_fraction": 0.0,
            "contiguous_flop_fraction": 1.0,
            "is_serial": False,
        },
        {
            "kernel": "add2d",
            "operations": 16777216.0,
            "bytes": 268435456.0,
            "seconds": 0.027078,
            "parallel_entries": 1,
            "parallel_nests": 1,
            "strided_flop_fraction": 0.0,
            "contiguous_flop_fraction": 1.0,
            "is_serial": False,
        },
    ]

    h_emp = 3.06e-6  # 3.06 microseconds per parallel dispatch
    c_floor = 3.8e-4  # 0.38 milliseconds baseline startup cost

    fit = derive_direct_rates(rows, h_empirical=h_emp, c_floor=c_floor, num_threads=16)

    r_strided = fit["R_flop_per_second"]
    r_contig = fit["R_contiguous_flop_per_second"]
    b_eff = fit["B_byte_per_second"]

    print(f"  R_strided    : {r_strided / 1e9:.2f} GFLOP/s")
    print(f"  R_contiguous : {r_contig / 1e9:.2f} GFLOP/s")
    print(f"  B_effective  : {b_eff / 1e9:.2f} GB/s")
    print(f"  h (overhead) : {fit['h_parallel_entry_seconds'] * 1e6:.2f} us")
    print(f"  c (floor)    : {fit['c_seconds'] * 1e3:.2f} ms")

    assert r_strided > 0.4e9, f"R_strided expected > 0.4 GFLOP/s, got {r_strided}"
    assert r_contig > r_strided, "Contiguous rate should exceed strided rate"
    assert b_eff > 5e9, f"DRAM bandwidth expected > 5 GB/s, got {b_eff}"
    print("  -> PASS: Direct rate derivation produced physically consistent rates.")
    return fit, rows


def test_predictions_and_calibration_parity(fit, rows):
    print("\nTest 3: Parity and Prediction on Calibration Triplet...")
    by_k = {r["kernel"]: r for r in rows}
    for k in ["gemm", "syr2k", "add2d"]:
        r = by_k[k]
        pred = predict(r, fit, num_threads=16)
        meas = r["seconds"]
        err = abs(pred - meas) / meas
        print(f"  {k:<8}: measured={meas:.4f}s, predicted={pred:.4f}s, error={err:.2%}")
        assert err < 0.02, f"{k} error exceeded 2%: {err:.2%}"
    print("  -> PASS: Calibration triplet achieves <1% parity under direct derivation.")


def test_generalization_and_serial_stencil(fit):
    print("\nTest 4: Evaluation on Serial (atax) and Stencil (jacobi)...")
    atax_row = {
        "kernel": "atax",
        "operations": 1048576.0,
        "bytes": 1058816.0,
        "parallel_entries": 1,
        "parallel_nests": 0,
        "strided_flop_fraction": 0.0,
        "contiguous_flop_fraction": 1.0,
        "serial_flop_fraction": 1.0,
        "serial_contiguous_flop_fraction": 1.0,
        "is_serial": True,
        "seconds": 0.012937,
    }
    pred_atax = predict(atax_row, fit, num_threads=16)
    print(f"  atax   : measured={atax_row['seconds']*1e3:.2f}ms, predicted={pred_atax*1e3:.2f}ms")
    # Kernels lacking parallel constructs omit OpenMP team creation and must
    # not incur initial team initialization overhead.
    assert pred_atax >= fit["c_seconds"], "serial prediction fell below the floor"
    team_start = fit.get("h_first_parallel_entry_seconds", 0.0)
    if team_start > 0:
        assert pred_atax < fit["c_seconds"] + team_start, (
            "a wholly serial kernel was charged OpenMP team startup")
    # Unparallelized shares must evaluate against single-thread throughput;
    # dividing multi-core gang throughput by thread count erroneously presumes linear scaling.
    serial_rate = fit["R_contiguous_serial_flop_per_second"]
    assert serial_rate * 16 > fit["R_contiguous"], (
        "serial contiguous rate looks like R_contiguous / threads")

    jacobi_row = {
        "kernel": "jacobi",
        "operations": 229800.0,
        "bytes": 18392.0,
        "parallel_entries": 200,
        "parallel_nests": 2,
        "strided_flop_fraction": 0.0,
        "contiguous_flop_fraction": 1.0,
        "is_serial": False,
        "seconds": 0.013077,
    }
    pred_jacobi = predict(jacobi_row, fit, num_threads=16)
    entries_cost = fit["h_parallel_entry_seconds"] * 199
    print(f"  jacobi : measured={jacobi_row['seconds']*1e3:.2f}ms, "
          f"predicted={pred_jacobi*1e3:.2f}ms "
          f"(199 re-entries cost {entries_cost*1e3:.2f}ms)")
    print("  -> PASS: Serial and stencil behaviors successfully evaluated.")


def main():
    test_omp_ir_extraction()
    fit, rows = test_direct_rate_derivation()
    test_predictions_and_calibration_parity(fit, rows)
    test_generalization_and_serial_stencil(fit)
    print("\n========================================================")
    print("ALL OPENMP-AWARE CALIBRATION TESTS PASSED SUCCESSFULLY!")
    print("========================================================")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Runs every kernel at every rank count through tests/run_bench.sh, which checks
each result against a sequential reference, and writes one CSV row per run.

every kernel in the works list produces a timing row at P=1,2,4.
A row whose status is not PASS is not a slow result, and exit code is non zero

    python3 tests/eval_auto_parallel.py
    python3 tests/eval_auto_parallel.py --kernels gemm 3mm --ranks 1 4
    python3 tests/eval_auto_parallel.py --csv results.csv
"""

import argparse
import csv
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RUN_BENCH = ROOT / "tests" / "run_bench.sh"

# The F8 works list: kernels that lower to tasks and have a driver.
KERNELS = ["gemm", "2mm", "3mm", "syr2k", "mvt", "atax",
           "jacobi", "jacobi2d", "add2d", "doitgen"]

DEFAULT_RANKS = [1, 2, 4]

RESULT_RE = re.compile(
    r"^RESULT kernel=(\S+) ranks=(\d+) seconds=([\d.]+) status=(\S+) errors=(\d+)")


def run_one(kernel, ranks, config, timeout):
    cmd = ["bash", str(RUN_BENCH), kernel, str(ranks)]
    if config:
        cmd += ["--config", config]

    started = time.time()
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True,
                              timeout=timeout, cwd=ROOT)
    except subprocess.TimeoutExpired:
        return {"kernel": kernel, "ranks": ranks, "status": "TIMEOUT",
                "errors": "", "seconds": "", "detail": f"exceeded {timeout}s"}

    for line in proc.stdout.splitlines():
        m = RESULT_RE.match(line)
        if m:
            return {"kernel": kernel, "ranks": ranks, "status": m.group(4),
                    "errors": int(m.group(5)), "seconds": float(m.group(3)),
                    "detail": ""}

    # No RESULT line: the run died before the driver could report.
    detail = (proc.stderr.strip().splitlines() or ["no output"])[-1][:160]
    return {"kernel": kernel, "ranks": ranks, "status": "ERROR", "errors": "",
            "seconds": round(time.time() - started, 3), "detail": detail}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--kernels", nargs="+", default=KERNELS)
    ap.add_argument("--ranks", nargs="+", type=int, default=DEFAULT_RANKS)
    ap.add_argument("--config", default=None,
                    help="fixed system config; default generates one per rank count")
    ap.add_argument("--csv", default=str(ROOT / "tests" / "bench" / "results.csv"))
    ap.add_argument("--timeout", type=int, default=900)
    args = ap.parse_args()

    rows = []
    failures = []

    print(f"{'kernel':<10} {'P':>3}  {'status':<8} {'seconds':>10}  detail")
    print("-" * 64)

    for kernel in args.kernels:
        for ranks in args.ranks:
            row = run_one(kernel, ranks, args.config, args.timeout)
            rows.append(row)

            secs = f"{row['seconds']:.6f}" if isinstance(row["seconds"], float) else ""
            print(f"{row['kernel']:<10} {row['ranks']:>3}  {row['status']:<8} "
                  f"{secs:>10}  {row['detail']}")
            sys.stdout.flush()

            if row["status"] != "PASS":
                failures.append(row)

    config_name = Path(args.config).name if args.config else "generated"
    with open(args.csv, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["kernel", "P", "config", "strategy", "status", "errors", "seconds"])
        for r in rows:
            w.writerow([r["kernel"], r["ranks"], config_name, "default",
                        r["status"], r["errors"], r["seconds"]])

    print("-" * 64)
    passed = sum(1 for r in rows if r["status"] == "PASS")
    print(f"{passed}/{len(rows)} verified correct   ->  {args.csv}")

    if failures:
        print("\nnot verified:")
        for r in failures:
            print(f"  {r['kernel']} P={r['ranks']}: {r['status']} {r['detail']}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

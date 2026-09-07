#!/usr/bin/env python3
"""Source of truth for kernel dimensions.
Automatically parses loop bounds directly from .mlir
and generates bench_sizes.h to prevent heap overflows.

Usage:
    python3 kernels.py <kernel> --header <out.h>   # emit sizes for one kernel
    python3 kernels.py --check-all                 # drift-check every kernel
"""

import argparse
import re
import sys
from pathlib import Path

POLYBENCH = Path(__file__).resolve().parent.parent / "polybench"


class Spec:
    """Structure of one kernel, sizes are derived from the .mlir.

    bounds:  dimension name for each affine.for bound, in source order. Repeats
             are fine and are checked for agreement; None ignores that bound.
    memrefs: (name, [dims...]) per memref argument in signature order. A leading
             '?' dim is dynamic (the driver picks it, so it must be named) and
             every later dim is static in the type and is cross-checked.
    """

    def __init__(self, func, bounds, memrefs, scalars=()):
        self.func = func
        self.bounds = bounds
        self.memrefs = memrefs
        self.scalars = scalars


SPECS = {
    # C = A*B                     loops: i, j, k
    "gemm": Spec("matmul", ["M", "N", "K"],
                 [("A", ["M", "K"]), ("B", ["K", "N"]), ("C", ["M", "N"])]),

    # D = alpha*A*B ; E = beta*E + D*C      loops: i,j,k then i,j,k
    "2mm": Spec("kernel_2mm", ["NI", "NJ", "NK", "NI", "NL", "NJ"],
                [("D", ["NI", "NJ"]), ("A", ["NI", "NK"]), ("B", ["NK", "NJ"]),
                 ("C", ["NJ", "NL"]), ("E", ["NI", "NL"])]),

    # E = A*B ; F = C*D ; G = E*F
    "3mm": Spec("kernel_3mm",
                ["NI", "NJ", "NK", "NJ", "NL", "NM", "NI", "NL", "NJ"],
                [("E", ["NI", "NJ"]), ("A", ["NI", "NK"]), ("B", ["NK", "NJ"]),
                 ("F", ["NJ", "NL"]), ("C", ["NJ", "NM"]), ("D", ["NM", "NL"]),
                 ("G", ["NI", "NL"])]),

    # C *= beta ; C += alpha*(A*B^T + B*A^T)
    "syr2k": Spec("kernel_syr2k", ["N", "N", "N", "N", "M"],
                  [("C", ["N", "N"]), ("A", ["N", "M"]), ("B", ["N", "M"])]),

    # x1 += A*y1 ; x2 += A^T*y2
    "mvt": Spec("kernel_mvt", ["N", "N", "N", "N"],
                [("x1", ["N"]), ("x2", ["N"]), ("y1", ["N"]), ("y2", ["N"]),
                 ("A", ["N", "N"])]),

    # tmp = A*x ; y = A^T*tmp
    "atax": Spec("kernel_atax", ["M", "N", "M"],
                 [("A", ["M", "N"]), ("x", ["N"]), ("y", ["N"]), ("tmp", ["M"])]),

    # T sweeps of a 1-D 3-point stencil over [1, N-1). Both arrays are fully
    # dynamic, so N can only come from the loop bound.
    "jacobi": Spec("kernel_jacobi", ["T", "N", "N"],
                   [("A", ["N"]), ("B", ["N"])], scalars=("T", "N")),

    # T sweeps of a 2-D 5-point stencil over [1, N-1)^2
    "jacobi2d": Spec("kernel_jacobi_2d", ["T", "N", "N", "N", "N"],
                     [("A", ["N", "N"]), ("B", ["N", "N"])], scalars=("T", "N")),

    # C = A + B
    "add2d": Spec("matadd", ["M", "N"],
                  [("A", ["M", "N"]), ("B", ["M", "N"]), ("C", ["M", "N"])]),

    # sum[r][q][p] = sum_s A[r][q][s]*C4[s][p] ; A = sum
    "doitgen": Spec("kernel_doitgen", ["NR", "NQ", "NP", "NP", "NP"],
                    [("A", ["NR", "NQ", "NP"]), ("C4", ["NP", "NP"]),
                     ("sum", ["NR", "NQ", "NP"])]),

    # tmp = A*x ; y = B*x ; y = alpha*tmp + beta*y
    "gesummv": Spec("kernel_gesummv", ["N", "N"],
                    [("A", ["N", "N"]), ("B", ["N", "N"]), ("tmp", ["N"]),
                     ("x", ["N"]), ("y", ["N"])]),

    # A = A + u1*v1^T + u2*v2^T ; x = x + beta*A^T*y + z ; w = w + alpha*A*x
    "gemver": Spec("kernel_gemver", ["N", "N", "N", "N", "N", "N", "N"],
                   [("A", ["N", "N"]), ("u1", ["N"]), ("v1", ["N"]),
                    ("u2", ["N"]), ("v2", ["N"]), ("w", ["N"]),
                    ("x", ["N"]), ("y", ["N"]), ("z", ["N"])]),
}

# Stencils write [1, N-1), so the array is one wider than the loop's upper
# bound. Everything else has loop bound == dimension.
STENCIL_UB_IS_N_MINUS_1 = {"jacobi", "jacobi2d"}


class Drift(Exception):
    pass


def parse_mlir(path):
    """Return (bounds, memref_shapes) as they literally appear in the file."""
    text = path.read_text()

    bounds = [(int(lo), int(hi)) for lo, hi in
              re.findall(r"affine\.for\s+%\w+\s*=\s*(\d+)\s+to\s+(\d+)", text)]

    sig = re.search(r"func\.func\s+@(\w+)\s*\((.*?)\)\s*(?:->|\{)", text, re.S)
    if not sig:
        raise Drift(f"{path.name}: no func.func signature found")
    func, arglist = sig.group(1), sig.group(2)

    shapes = []
    for m in re.finditer(r"memref<([^>]*)>", arglist):
        dims = m.group(1).split("x")[:-1]  # drop the element type
        shapes.append([None if d == "?" else int(d) for d in dims])

    return func, bounds, shapes


def resolve(kernel):
    """Resolve a kernel's symbolic dims to concrete values, checking for drift."""
    if kernel not in SPECS:
        raise Drift(f"unknown kernel {kernel!r}")
    spec = SPECS[kernel]
    path = POLYBENCH / f"{kernel}.mlir"
    if not path.exists():
        raise Drift(f"missing {path}")

    func, bounds, shapes = parse_mlir(path)

    if func != spec.func:
        raise Drift(f"{kernel}: spec says @{spec.func}, .mlir has @{func}")
    if len(bounds) != len(spec.bounds):
        raise Drift(f"{kernel}: spec declares {len(spec.bounds)} loop bounds, "
                    f".mlir has {len(bounds)}")
    if len(shapes) != len(spec.memrefs):
        raise Drift(f"{kernel}: spec declares {len(spec.memrefs)} memref args, "
                    f".mlir has {len(shapes)}")

    dims = {}

    def bind(name, value, why):
        prev = dims.setdefault(name, value)
        if prev != value:
            raise Drift(f"{kernel}: {name} is {prev} elsewhere but {value} {why}"
                        f" -- the .mlir was resized only partly")

    # Loop bounds give the dimensions.
    for i, (name, (lo, hi)) in enumerate(zip(spec.bounds, bounds)):
        if name is None:
            continue
        value = hi + 1 if kernel in STENCIL_UB_IS_N_MINUS_1 and lo == 1 else hi
        bind(name, value, f"at loop {i} (bound {lo}..{hi})")

    # Static memref dims must agree with them.
    for (name, decl), shape in zip(spec.memrefs, shapes):
        if len(decl) != len(shape):
            raise Drift(f"{kernel}: {name} declared rank {len(decl)}, "
                        f".mlir has rank {len(shape)}")
        for axis, (dim_name, static) in enumerate(zip(decl, shape)):
            if static is None:
                continue  # dynamic: the driver supplies it
            bind(dim_name, static, f"in {name} axis {axis}")

    missing = [d for m in spec.memrefs for d in m[1] if d not in dims]
    if missing:
        raise Drift(f"{kernel}: could not resolve {sorted(set(missing))} "
                    f"from the .mlir")

    return spec, dims


def emit_header(kernel, out):
    spec, dims = resolve(kernel)
    lines = [
        "// GENERATED by tests/bench/kernels.py -- do not edit.",
        f"// Sizes parsed from tests/polybench/{kernel}.mlir; edit that file to resize.",
        "#pragma once",
        "",
        f"#define DHIR_KERNEL_{kernel.upper().replace('2', 'TWO').replace('3', 'THREE')} 1",
        "",
    ]
    for name in sorted(dims):
        lines.append(f"#define DHIR_{name} {dims[name]}")
    lines.append("")
    Path(out).write_text("\n".join(lines))
    return dims


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("kernel", nargs="?")
    ap.add_argument("--header")
    ap.add_argument("--check-all", action="store_true")
    ap.add_argument("--print", action="store_true")
    args = ap.parse_args()

    if args.check_all:
        bad = 0
        for k in SPECS:
            try:
                _, dims = resolve(k)
                print(f"  {k:10s} " + "  ".join(f"{n}={v}" for n, v in sorted(dims.items())))
            except Drift as e:
                print(f"  {k:10s} DRIFT: {e}", file=sys.stderr)
                bad += 1
        return 1 if bad else 0

    if not args.kernel:
        ap.error("give a kernel name or --check-all")

    try:
        if args.header:
            dims = emit_header(args.kernel, args.header)
        else:
            _, dims = resolve(args.kernel)
        if args.print or not args.header:
            print(" ".join(f"{n}={v}" for n, v in sorted(dims.items())))
    except Drift as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

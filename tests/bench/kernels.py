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

    # Out[i] = sum_j (A+B+C+D+E+F)[i, j]
    "stream6": Spec("stream6", ["M", "N"],
                    [("A", ["M", "N"]), ("B", ["M", "N"]), ("C", ["M", "N"]),
                     ("D", ["M", "N"]), ("E", ["M", "N"]), ("F", ["M", "N"]),
                     ("Out", ["M"])]),
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


def parse_dims_str(kernel, s):
    """Parses a dimension string like 'M=2048,N=2048' or '2048' or 'gemm:M=2048;add2d:N=4096'."""
    if not s:
        return {}
    s = s.strip()
    if ";" in s or (":" in s and not re.match(r"^\w+=\d+", s)):
        entries = s.split(";")
        for entry in entries:
            entry = entry.strip()
            if not entry:
                continue
            if ":" in entry:
                k_name, rest = entry.split(":", 1)
                if k_name.strip() == kernel:
                    return parse_dims_str(kernel, rest)
        return {}

    if s.isdigit():
        val = int(s)
        spec = SPECS.get(kernel)
        if not spec:
            return {}
        res = {}
        for b in spec.bounds:
            if b and b not in spec.scalars:
                res[b] = val
        return res

    out = {}
    for part in s.split(","):
        part = part.strip()
        if not part:
            continue
        if "=" in part:
            k, v = part.split("=", 1)
            out[k.strip()] = int(v.strip())
    return out


def specialize_mlir(kernel, overrides, in_path=None, out_path=None):
    """Specializes an MLIR source text with new dimension overrides without modifying disk files."""
    if kernel not in SPECS:
        raise Drift(f"unknown kernel {kernel!r}")
    spec = SPECS[kernel]
    src_path = Path(in_path) if in_path else (POLYBENCH / f"{kernel}.mlir")
    text = src_path.read_text()

    if not overrides:
        if out_path:
            Path(out_path).write_text(text)
        return text

    _, orig_dims = resolve(kernel, in_path=src_path)
    active_dims = dict(orig_dims)
    active_dims.update(overrides)

    def replace_bound(match):
        idx = getattr(replace_bound, "idx", 0)
        replace_bound.idx = idx + 1
        if idx >= len(spec.bounds):
            return match.group(0)
        dim_name = spec.bounds[idx]
        if not dim_name or dim_name not in active_dims:
            return match.group(0)

        var_name = match.group(1)
        lo_str = match.group(2)
        lo = int(lo_str)
        val = active_dims[dim_name]
        new_hi = val - 1 if (kernel in STENCIL_UB_IS_N_MINUS_1 and lo == 1) else val
        return f"affine.for {var_name} = {lo_str} to {new_hi}"

    replace_bound.idx = 0
    text = re.sub(r"affine\.for\s+(%\w+)\s*=\s*(\d+)\s+to\s+\d+", replace_bound, text)

    sig = re.search(r"func\.func\s+@(\w+)\s*\((.*?)\)\s*(?:->|\{)", text, re.S)
    if sig:
        arglist = sig.group(2)
        memref_args = re.findall(r"(%arg\d+)\s*:\s*(memref<[^>]+>)", arglist)
        for (arg_var, old_type), (m_name, decl) in zip(memref_args, spec.memrefs):
            elem_type = old_type.split("x")[-1].rstrip(">")
            new_shape = ["?" if ax == 0 else str(active_dims[d]) for ax, d in enumerate(decl)]
            new_type = f"memref<{'x'.join(new_shape)}x{elem_type}>"
            if new_type != old_type:
                # Replace in signature: %argX: memref<...>
                # and in loads/stores: %argX[...] : memref<...>
                pattern = rf"({re.escape(arg_var)}(?:\[[^\]]*\])?\s*:\s*){re.escape(old_type)}"
                text = re.sub(pattern, rf"\g<1>{new_type}", text)

    if out_path:
        out_p = Path(out_path)
        out_p.parent.mkdir(parents=True, exist_ok=True)
        out_p.write_text(text)
    return text


def resolve(kernel, in_path=None, overrides=None):
    """Resolve a kernel's symbolic dims to concrete values, checking for drift."""
    if kernel not in SPECS:
        raise Drift(f"unknown kernel {kernel!r}")
    spec = SPECS[kernel]
    path = Path(in_path) if in_path else (POLYBENCH / f"{kernel}.mlir")
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

    if overrides:
        for k, v in overrides.items():
            if k in dims:
                dims[k] = v

    return spec, dims


def emit_header(kernel, out, overrides=None, in_path=None):
    spec, dims = resolve(kernel, in_path=in_path, overrides=overrides)
    lines = [
        "// GENERATED by tests/bench/kernels.py -- do not edit.",
        f"// Sizes parsed from {in_path or f'tests/polybench/{kernel}.mlir'}",
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
    ap.add_argument("--dims", help="comma-separated dimension overrides e.g. M=2048,N=2048 or single integer")
    ap.add_argument("--size", type=int, help="symmetric dimension override across all dimensions")
    ap.add_argument("--emit-mlir", help="path to emit specialized MLIR copy with new dimensions")
    ap.add_argument("--in-mlir", help="input MLIR path instead of default tests/polybench/<kernel>.mlir")
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

    overrides = {}
    if args.size:
        overrides = parse_dims_str(args.kernel, str(args.size))
    elif args.dims:
        overrides = parse_dims_str(args.kernel, args.dims)

    try:
        if args.emit_mlir:
            specialize_mlir(args.kernel, overrides, in_path=args.in_mlir, out_path=args.emit_mlir)

        if args.header:
            dims = emit_header(args.kernel, args.header, overrides=overrides, in_path=args.emit_mlir or args.in_mlir)
        else:
            _, dims = resolve(args.kernel, in_path=args.emit_mlir or args.in_mlir, overrides=overrides)
        if args.print or not args.header:
            print(" ".join(f"{n}={v}" for n, v in sorted(dims.items())))
    except Drift as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())


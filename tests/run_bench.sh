#!/usr/bin/env bash
#
# Build and run given DHIR kernel at given rank
#
#   tests/run_bench.sh <kernel> <ranks> [options]
#
# Pipeline:
#   kernels.py  -> bench_sizes.h   (sizes parsed from the kernel's own .mlir)
#   dhir-opt    -> LLVM dialect
#   mlir-translate -> .ll
#   llc         -> .o
#   mpicxx      -> link driver + libdhir_runtime.a + MPI
#   mpirun -np <ranks>
#
# Prints the driver's RESULT and exits nonzero error or kernel verificatin fails
set -eo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BENCH="$ROOT/tests/bench"
DHIR_OPT="$ROOT/build/bin/dhir-opt"
RUNTIME="$ROOT/build/libdhir_runtime.a"
OMP_LIBDIR="${DHIR_OMP_LIBDIR:-/usr/local/lib/x86_64-unknown-linux-gnu}"

usage() {
    cat >&2 <<EOF
usage: $(basename "$0") <kernel> <ranks> [--config FILE] [--workdir DIR] [--keep] [--verbose]

  --config FILE   system config JSON; default: generated with <ranks> uniform nodes
  --workdir DIR   where to put intermediates; default: a temp dir
  --keep          keep intermediates and print their location
  --verbose       echo each pipeline stage
  --reuse-build   with --workdir, skip the compile pipeline when that directory
                  already holds a binary built for this kernel and these sizes
                  (repeated timings of one configuration then compile once)
EOF
    exit 2
}

[[ $# -ge 2 ]] || usage
KERNEL="$1"; RANKS="$2"; shift 2

CONFIG=""; WORKDIR=""; KEEP=0; VERBOSE=0; DIMS=""; SIZE=""; REUSE=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --config)  CONFIG="$2"; shift 2 ;;
        --workdir) WORKDIR="$2"; shift 2 ;;
        --keep)    KEEP=1; shift ;;
        --verbose) VERBOSE=1; shift ;;
        --dims)    DIMS="$2"; shift 2 ;;
        --size)    SIZE="$2"; shift 2 ;;
        --reuse-build) REUSE=1; shift ;;
        *) echo "unknown option: $1" >&2; usage ;;
    esac
done

SRC="$ROOT/tests/polybench/$KERNEL.mlir"
DRIVER="$BENCH/drivers/${KERNEL}_main.cc"
[[ -f "$SRC"    ]] || { echo "no kernel source: $SRC" >&2; exit 2; }
[[ -f "$DRIVER" ]] || { echo "no driver: $DRIVER" >&2; exit 2; }
[[ -x "$DHIR_OPT" ]] || { echo "no dhir-opt: $DHIR_OPT (build first)" >&2; exit 2; }
[[ -f "$RUNTIME"  ]] || { echo "no runtime: $RUNTIME (build first)" >&2; exit 2; }

if [[ -z "$WORKDIR" ]]; then
    WORKDIR="$(mktemp -d)"
    [[ $KEEP -eq 1 ]] || trap 'rm -rf "$WORKDIR"' EXIT
fi
mkdir -p "$WORKDIR"

say() { [[ $VERBOSE -eq 1 ]] && echo "  [$KERNEL/np=$RANKS] $*" >&2 || true; }

# --- config -----------------------------------------------------------------
# The rank->node map is built from the config, so the node count must match the
# rank count. Generate one rather than requiring a checked-in file per P.
if [[ -z "$CONFIG" ]]; then
    CONFIG="$WORKDIR/config_${RANKS}.json"
    {
        echo '{'
        echo '  "cluster": {'
        echo "    \"world_size\": $RANKS,"
        printf '    "node_ids": ['
        for ((i = 0; i < RANKS; ++i)); do
            printf '"node%d"' "$i"
            [[ $i -lt $((RANKS - 1)) ]] && printf ', '
        done
        echo ']'
        echo '  },'
        echo '  "nodes": {'
        for ((i = 0; i < RANKS; ++i)); do
            printf '    "node%d": {"cpu_arch": "x86_64", "gpus": []}' "$i"
            [[ $i -lt $((RANKS - 1)) ]] && printf ','
            echo
        done
        echo '  }'
        echo '}'
    } > "$CONFIG"
    say "generated config with $RANKS nodes"
fi

# Repeated measurements of one configuration differ only in the timing, so the
# pipeline (kernels.py, dhir-opt, mlir-translate, llc, mpicxx) is worth running
# once.  The stamp records what the cached binary was built for; anything else
# rebuilds.
STAMP="$WORKDIR/build.stamp"
WANT="$KERNEL|$RANKS|${DIMS}|${SIZE}|$CONFIG"
if [[ $REUSE -eq 1 && -x "$WORKDIR/bench" && -f "$STAMP" ]] \
   && [[ "$(cat "$STAMP")" == "$WANT" ]] \
   && [[ "$WORKDIR/bench" -nt "$DHIR_OPT" && "$WORKDIR/bench" -nt "$SRC" ]]; then
    say "reusing build in $WORKDIR"
    SKIP_BUILD=1
else
    SKIP_BUILD=0
fi

if [[ $SKIP_BUILD -eq 0 ]]; then
# --- sizes & specialization ---
# Parsed from the .mlir, or specialized dynamically if --dims/--size is passed.
say "extracting sizes"
DIMS_ARGS=()
if [[ -n "$SIZE" ]]; then
    DIMS_ARGS+=(--size "$SIZE")
elif [[ -n "$DIMS" ]]; then
    DIMS_ARGS+=(--dims "$DIMS")
fi

python3 "$BENCH/kernels.py" "$KERNEL" "${DIMS_ARGS[@]}" \
        --emit-mlir "$WORKDIR/raw_in.mlir" \
        --header "$WORKDIR/bench_sizes.h" --print >&2

# --- compile ---
# MPIImplTraits reads the implementation from the module's DLTI spec; attach it
# to the source, then strip it again before mlir-translate, which rejects it.
MPI_SPEC='dlti.dl_spec = #dlti.dl_spec<"MPI:Implementation" = "OpenMPI">'
sed -E "0,/^module[[:space:]]*\{/s//module attributes {$MPI_SPEC} {/" \
    "$WORKDIR/raw_in.mlir" > "$WORKDIR/in.mlir"

say "dhir-opt"
"$DHIR_OPT" --affine-to-dhir --std-to-dhir --lower-replicate --lower-converge \
            --dhir-to-mpi --lower-to-llvm \
            "$WORKDIR/in.mlir" "$CONFIG" > "$WORKDIR/llvm.mlir" 2> "$WORKDIR/opt.log" || {
    echo "FAIL $KERNEL np=$RANKS: dhir-opt failed" >&2
    tail -20 "$WORKDIR/opt.log" >&2
    exit 1
}

sed -i "s/, $MPI_SPEC//g; s/$MPI_SPEC//g" "$WORKDIR/llvm.mlir"

say "mlir-translate"
mlir-translate --mlir-to-llvmir "$WORKDIR/llvm.mlir" > "$WORKDIR/kernel.ll" 2> "$WORKDIR/translate.log" || {
    echo "FAIL $KERNEL np=$RANKS: mlir-translate failed" >&2
    tail -20 "$WORKDIR/translate.log" >&2
    exit 1
}

# Use driver
sed -i 's/@MPI_Init\b/@dhir_noop_mpi_init/g; s/@MPI_Finalize\b/@dhir_noop_mpi_finalize/g' \
    "$WORKDIR/kernel.ll"

say "llc"
llc -O3 -relocation-model=pic -filetype=obj "$WORKDIR/kernel.ll" -o "$WORKDIR/kernel.o" \
    2> "$WORKDIR/llc.log" || {
    echo "FAIL $KERNEL np=$RANKS: llc failed" >&2
    tail -20 "$WORKDIR/llc.log" >&2
    exit 1
}

say "link"
mpicxx -O2 -fopenmp -I"$WORKDIR" -I"$BENCH" \
       "$DRIVER" "$WORKDIR/kernel.o" "$RUNTIME" \
       -lm -lhwloc -L"$OMP_LIBDIR" -lomp -o "$WORKDIR/bench" \
       2> "$WORKDIR/link.log" || {
    echo "FAIL $KERNEL np=$RANKS: link failed" >&2
    tail -20 "$WORKDIR/link.log" >&2
    exit 1
}

printf '%s' "$WANT" > "$STAMP"
fi   # SKIP_BUILD

# --- run ---
# Default binding: none.  With np<=2 Open MPI binds each rank to a single core,
# which shrinks the process CPU affinity mask to one core (two SMT threads on
# this host).  The OpenMP runtime then sizes its team from that mask, so the
# kernel's omp.parallel regions run on 2 threads while the cost model prices
# them against the node's full thread budget -- the measured rates are then not
# the rates being modelled.  Binding to none hands the rank the whole node,
# which is also the cluster layout the model assumes (one rank per node).
say "mpirun -np $RANKS"
MPI_FLAGS=(${DHIR_MPIRUN_FLAGS:---oversubscribe --bind-to none})
# No thread affinity is set: the kernels are meant to run with whatever the
# OpenMP runtime picks by default, so the calibration measures that.  Only
# variables the caller exported are forwarded.
for var in OMP_NUM_THREADS OMP_PROC_BIND OMP_PLACES; do
    [[ -n "${!var:-}" ]] && MPI_FLAGS+=(-x "$var")
done
set +e
LD_LIBRARY_PATH="$OMP_LIBDIR:${LD_LIBRARY_PATH:-}" \
    mpirun "${MPI_FLAGS[@]}" -np "$RANKS" "$WORKDIR/bench" \
    > "$WORKDIR/run.out" 2> "$WORKDIR/run.err"
RC=$?
set -e

grep '^RESULT' "$WORKDIR/run.out" || true

if [[ $RC -ne 0 ]]; then
    echo "FAIL $KERNEL np=$RANKS: exit $RC" >&2
    grep -v '^RESULT' "$WORKDIR/run.out" | head -20 >&2
    tail -20 "$WORKDIR/run.err" >&2
fi

[[ $KEEP -eq 1 ]] && echo "  intermediates: $WORKDIR" >&2
exit $RC

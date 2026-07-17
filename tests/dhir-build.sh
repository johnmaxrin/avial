#!/usr/bin/env bash
#
# build_dhir.sh — run the full dhir-opt -> mlir-translate -> mpic++ pipeline
#
# Usage (positional):
#   ./build_dhir.sh <input.mlir> <config.json> <driver.c> [output_name]
#
# Usage (flags):
#   ./build_dhir.sh --mlir <input.mlir> --config <config.json> --driver <driver.c> [--out <output_name>]
#
# Flags and positionals can be mixed; flags take priority if both are given
# for the same slot. Only the first three positionals (mlir, config, driver)
# and an optional 4th (output name) are recognized.
#
# What it does:
#   1. Runs dhir-opt on the input .mlir with the given config, through the
#      full std-to-dhir / affine-to-dhir / lower-converge / lower-replicate /
#      dhir-to-mpi / lower-to-llvm pipeline.
#   2. Strips any line containing "MPI_Init" from the resulting .mlir
#      (dhir-opt's output apparently emits an MPI_Init call that must be
#      removed before further lowering/linking, per the established manual
#      workflow).
#   3. Runs mlir-translate --mlir-to-llvmir to produce a .ll file.
#   4. Compiles the .ll together with the user-supplied driver .c file via
#      mpic++, linking against dhir_runtime and hwloc, producing a final
#      executable.
#
# Assumes it is run from the directory containing dhir-opt (./bin/dhir-opt)
# and the runtime libraries (-L. picks up the current directory), matching
# the manual workflow this script replaces. Override with --dhir-opt /
# --lib-dir if your layout differs.

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
DHIR_OPT_BIN="./bin/dhir-opt"
LIB_DIR="."
WORK_DIR="./dhir_build"

INPUT_MLIR=""
CONFIG_JSON=""
DRIVER_C=""
OUT_NAME=""

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
Usage:
  $(basename "$0") <input.mlir> <config.json> <driver.c> [output_name]
  $(basename "$0") --mlir <input.mlir> --config <config.json> --driver <driver.c> [--out <output_name>]

Options:
  -m, --mlir <path>       Path to the input .mlir file (required)
  -c, --config <path>     Path to the system config .json file (required)
  -d, --driver <path>     Path to the driver .c file with main() (required)
  -o, --out <name>        Base name for output artifacts (default: derived
                          from the input .mlir filename)
      --dhir-opt <path>   Path to the dhir-opt binary (default: ./bin/dhir-opt)
      --lib-dir <path>    Directory passed to mpic++ -L (default: .)
      --work-dir <path>   Directory for intermediate build artifacts
                          (default: ./dhir_build)
  -h, --help              Show this help and exit

Positional and flag forms can be mixed; the first three unflagged
positional arguments are taken as <input.mlir> <config.json> <driver.c>,
and a fourth positional is taken as the output name.
EOF
}

# ---------------------------------------------------------------------------
# Argument parsing (supports --flag, -f, and positionals)
# ---------------------------------------------------------------------------
positional_args=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--mlir)
            INPUT_MLIR="$2"; shift 2 ;;
        -c|--config)
            CONFIG_JSON="$2"; shift 2 ;;
        -d|--driver)
            DRIVER_C="$2"; shift 2 ;;
        -o|--out)
            OUT_NAME="$2"; shift 2 ;;
        --dhir-opt)
            DHIR_OPT_BIN="$2"; shift 2 ;;
        --lib-dir)
            LIB_DIR="$2"; shift 2 ;;
        --work-dir)
            WORK_DIR="$2"; shift 2 ;;
        -h|--help)
            usage; exit 0 ;;
        --)
            shift
            while [[ $# -gt 0 ]]; do positional_args+=("$1"); shift; done
            ;;
        -*)
            echo "Error: unknown option '$1'" >&2
            usage
            exit 1
            ;;
        *)
            positional_args+=("$1"); shift ;;
    esac
done

# Fill in from positionals for anything not already set via flags
if [[ -z "$INPUT_MLIR" && ${#positional_args[@]} -ge 1 ]]; then
    INPUT_MLIR="${positional_args[0]}"
fi
if [[ -z "$CONFIG_JSON" && ${#positional_args[@]} -ge 2 ]]; then
    CONFIG_JSON="${positional_args[1]}"
fi
if [[ -z "$DRIVER_C" && ${#positional_args[@]} -ge 3 ]]; then
    DRIVER_C="${positional_args[2]}"
fi
if [[ -z "$OUT_NAME" && ${#positional_args[@]} -ge 4 ]]; then
    OUT_NAME="${positional_args[3]}"
fi

# ---------------------------------------------------------------------------
# Validate inputs
# ---------------------------------------------------------------------------
if [[ -z "$INPUT_MLIR" || -z "$CONFIG_JSON" || -z "$DRIVER_C" ]]; then
    echo "Error: input .mlir, config .json, and driver .c are all required." >&2
    echo >&2
    usage
    exit 1
fi

for f in "$INPUT_MLIR" "$CONFIG_JSON" "$DRIVER_C"; do
    if [[ ! -f "$f" ]]; then
        echo "Error: file not found: $f" >&2
        exit 1
    fi
done

if [[ ! -x "$DHIR_OPT_BIN" ]]; then
    echo "Error: dhir-opt binary not found or not executable at: $DHIR_OPT_BIN" >&2
    echo "       (override with --dhir-opt <path> if it lives elsewhere)" >&2
    exit 1
fi

# Derive a base name for artifacts if not explicitly given
if [[ -z "$OUT_NAME" ]]; then
    OUT_NAME="$(basename "$INPUT_MLIR")"
    OUT_NAME="${OUT_NAME%.mlir}"
fi

mkdir -p "$WORK_DIR"

LOWERED_MLIR="$WORK_DIR/${OUT_NAME}.lowered.mlir"
CLEANED_MLIR="$WORK_DIR/${OUT_NAME}.mlir"
LLVM_IR="$WORK_DIR/${OUT_NAME}.ll"
EXECUTABLE="./${OUT_NAME}_test"

echo "=== dhir build pipeline: ${OUT_NAME} ==="
echo "  input mlir : $INPUT_MLIR"
echo "  config     : $CONFIG_JSON"
echo "  driver     : $DRIVER_C"
echo "  work dir   : $WORK_DIR"
echo "  output     : $EXECUTABLE"
echo

# ---------------------------------------------------------------------------
# Step 1: dhir-opt full lowering pipeline
# ---------------------------------------------------------------------------
echo "--- [1/4] Running dhir-opt ---"
"$DHIR_OPT_BIN" \
    "$INPUT_MLIR" \
    "$CONFIG_JSON" \
    --std-to-dhir \
    --affine-to-dhir --lower-converge --lower-replicate --dhir-to-mpi --lower-to-llvm \
    > "$LOWERED_MLIR"
echo "    -> $LOWERED_MLIR"
echo

# ---------------------------------------------------------------------------
# Step 2: strip MPI_Init lines
# ---------------------------------------------------------------------------
echo "--- [2/4] Removing MPI_Init lines ---"
grep -v "MPI_Init" "$LOWERED_MLIR" > "$CLEANED_MLIR"
echo "    -> $CLEANED_MLIR"
echo

# ---------------------------------------------------------------------------
# Step 3: mlir-translate to LLVM IR
# ---------------------------------------------------------------------------
echo "--- [3/4] Running mlir-translate --mlir-to-llvmir ---"
mlir-translate --mlir-to-llvmir "$CLEANED_MLIR" > "$LLVM_IR"
echo "    -> $LLVM_IR"
echo

# ---------------------------------------------------------------------------
# Step 4: compile with mpic++
# ---------------------------------------------------------------------------
echo "--- [4/4] Compiling with mpic++ ---"
mpic++ -g "$DRIVER_C" "$LLVM_IR" -L"$LIB_DIR" -fopenmp -ldhir_runtime -lhwloc -o "$EXECUTABLE"
echo "    -> $EXECUTABLE"
echo

echo "=== Build complete: $EXECUTABLE ==="

#!/bin/bash

# Per-pass test runner - stops at each pass for inspection
# Usage: ./test_per_pass.sh <test_file> [--stop-at=PASS] [--continue-on-error]

# Don't exit on error by default in this script
set +e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"  && pwd)"
BUILD_DIR="${SCRIPT_DIR}/../build"
DHIR_OPT="${BUILD_DIR}/bin/dhir-opt"

# Parse arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <test_file.mlir> [--stop-at=PASS] [--continue-on-error]"
    echo ""
    echo "Options:"
    echo "  --stop-at=PASS         Stop after executing specified pass"
    echo "  --continue-on-error    Continue testing even if a pass fails"
    echo ""
    echo "Passes:"
    echo "  affine-to-dhir"
    echo "  std-to-dhir"
    echo "  lower-replicate"
    echo "  lower-converge"
    echo "  dhir-to-mpi"
    echo "  lower-to-llvm"
    exit 1
fi

TEST_FILE="$1"
STOP_AT=""
CONTINUE_ON_ERROR=0

shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --stop-at=*)
            STOP_AT="${1#--stop-at=}"
            shift
            ;;
        --continue-on-error)
            CONTINUE_ON_ERROR=1
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [ ! -f "${TEST_FILE}" ]; then
    echo -e "${RED}Error: Test file not found: ${TEST_FILE}${NC}"
    exit 1
fi

if [ ! -f "${DHIR_OPT}" ]; then
    echo -e "${RED}Error: dhir-opt not found at ${DHIR_OPT}${NC}"
    exit 1
fi

TEST_NAME=$(basename "${TEST_FILE}" .mlir)
OUTPUT_DIR="${BUILD_DIR}/test_output/${TEST_NAME}"
mkdir -p "${OUTPUT_DIR}"

echo -e "${BLUE}Testing: ${TEST_NAME}${NC}"
echo "Output directory: ${OUTPUT_DIR}"
echo ""

# Pipeline definition
declare -A PASSES=(
    [1]="affine-to-dhir"
    [2]="std-to-dhir"
    [3]="lower-replicate"
    [4]="lower-converge"
    [5]="dhir-to-mpi"
    [6]="lower-to-llvm"
)

declare -A DESCRIPTIONS=(
    [1]="Convert Affine dialect to DHIR"
    [2]="Convert Standard dialect to DHIR"
    [3]="Lower Replicate operations"
    [4]="Lower Converge operations"
    [5]="Convert DHIR to MPI"
    [6]="Lower to LLVM"
)

# Run passes incrementally
CURRENT_FILE="${TEST_FILE}"
STOP_INDEX=6

# Find stop index if specified
if [ -n "${STOP_AT}" ]; then
    for i in "${!PASSES[@]}"; do
        if [ "${PASSES[$i]}" = "${STOP_AT}" ]; then
            STOP_INDEX=$i
            break
        fi
    done
fi

for i in {1..6}; do
    PASS="${PASSES[$i]}"
    DESC="${DESCRIPTIONS[$i]}"
    OUTPUT_FILE="${OUTPUT_DIR}/${i}_${PASS}.mlir"
    ERROR_FILE="${OUTPUT_DIR}/${i}_${PASS}.error"
    
    echo -e "${YELLOW}[$i/6] ${DESC}${NC}"
    echo "Pass: --${PASS}"
    
    # Run pass
    if "${DHIR_OPT}" "--${PASS}" "${CURRENT_FILE}" > "${OUTPUT_FILE}" 2> "${ERROR_FILE}"; then
        echo -e "${GREEN}✓ Success${NC}"
        
        # Show stats
        LINES=$(wc -l < "${OUTPUT_FILE}")
        echo "  Output: ${OUTPUT_FILE} (${LINES} lines)"
        
        # Check for errors/warnings in stderr
        if [ -s "${ERROR_FILE}" ]; then
            echo -e "  ${YELLOW}Warnings/Debug output:${NC}"
            head -5 "${ERROR_FILE}"
            if [ $(wc -l < "${ERROR_FILE}") -gt 5 ]; then
                echo "  ... (see ${ERROR_FILE} for full output)"
            fi
        else
            rm -f "${ERROR_FILE}"
        fi
        
        CURRENT_FILE="${OUTPUT_FILE}"
    else
        echo -e "${RED}✗ Failed${NC}"
        echo "Error log: ${ERROR_FILE}"
        echo ""
        echo "Error output:"
        cat "${ERROR_FILE}"
        
        # Check if we should continue or stop
        if [ ${CONTINUE_ON_ERROR} -eq 0 ]; then
            echo ""
            echo -e "${RED}Stopping due to error. Use --continue-on-error to continue anyway.${NC}"
            exit 1
        else
            echo ""
            echo -e "${YELLOW}Continuing to next pass despite error...${NC}"
            # Use the failed output as input for next pass (it may be partially valid)
            CURRENT_FILE="${OUTPUT_FILE}"
        fi
    fi
    
    echo ""
    
    # Stop if requested
    if [ $i -eq ${STOP_INDEX} ]; then
        echo -e "${BLUE}Stopped at: ${PASS}${NC}"
        echo "Output file: ${OUTPUT_FILE}"
        break
    fi
done

echo -e "${GREEN}All passes completed successfully!${NC}"
echo "Final output: ${CURRENT_FILE}"
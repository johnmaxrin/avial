#!/bin/bash

# Test runner for DHIR compiler
# Usage: ./run_tests.sh [test_name|all] [--verbose] [--keep-output]

# Don't exit on error - we want to continue testing
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/../build"
TEST_DIR="${SCRIPT_DIR}/../tests"
POLYBENCH_DIR="${TEST_DIR}/polybench"
OUTPUT_DIR="${BUILD_DIR}/test_output"

# Tools
DHIR_OPT="${BUILD_DIR}/bin/dhir-opt"

# Parse arguments
TEST_FILTER=""
VERBOSE=0
KEEP_OUTPUT=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=1
            shift
            ;;
        --keep-output|-k)
            KEEP_OUTPUT=1
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [test_name|all] [--verbose] [--keep-output]"
            echo ""
            echo "Options:"
            echo "  test_name       Run specific test (e.g., jacobi)"
            echo "  all             Run all tests (default)"
            echo "  --verbose, -v   Show detailed output"
            echo "  --keep-output, -k  Keep output files after test"
            exit 0
            ;;
        *)
            TEST_FILTER="$1"
            shift
            ;;
    esac
done

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Test statistics
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if dhir-opt exists
if [ ! -f "${DHIR_OPT}" ]; then
    log_error "dhir-opt not found at ${DHIR_OPT}"
    log_info "Please build the project first: cd build && make"
    exit 1
fi

# Pipeline stages
PIPELINE=(
    "--affine-to-dhir"
    "--std-to-dhir"
    "--lower-replicate"
    "--lower-converge"
    "--dhir-to-mpi"
    "--lower-to-llvm"
)

# Run a single test
run_test() {
    local test_file="$1"
    local test_name=$(basename "${test_file}" .mlir)
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    log_info "Running test: ${test_name}"
    
    # Output file
    local output_file="${OUTPUT_DIR}/${test_name}_output.mlir"
    local error_file="${OUTPUT_DIR}/${test_name}_error.log"
    
    # Run the full pipeline
    local cmd="${DHIR_OPT}"
    for pass in "${PIPELINE[@]}"; do
        cmd="${cmd} ${pass}"
    done
    cmd="${cmd} ${test_file}"
    
    if [ $VERBOSE -eq 1 ]; then
        log_info "Command: ${cmd}"
    fi
    
    # Execute and capture output
    if eval "${cmd} > ${output_file} 2> ${error_file}"; then
        log_success "${test_name}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        
        # Clean up if not keeping output
        if [ $KEEP_OUTPUT -eq 0 ]; then
            rm -f "${output_file}" "${error_file}"
        fi
        
        return 0
    else
        log_error "${test_name}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_TEST_NAMES+=("${test_name}")
        
        if [ $VERBOSE -eq 1 ]; then
            echo "Error output:"
            cat "${error_file}"
        else
            log_info "Run with --verbose to see error details"
            log_info "Error log saved to: ${error_file}"
        fi
        
        return 1
    fi
}

# Run tests for all files in polybench
run_polybench_tests() {
    log_info "Running Polybench tests from ${POLYBENCH_DIR}"
    
    if [ ! -d "${POLYBENCH_DIR}" ]; then
        log_error "Polybench directory not found: ${POLYBENCH_DIR}"
        exit 1
    fi
    
    # Find all .mlir files
    local test_files=()
    while IFS= read -r -d '' file; do
        test_files+=("$file")
    done < <(find "${POLYBENCH_DIR}" -name "*.mlir" -print0 | sort -z)
    
    if [ ${#test_files[@]} -eq 0 ]; then
        log_warning "No test files found in ${POLYBENCH_DIR}"
        exit 0
    fi
    
    log_info "Found ${#test_files[@]} test files"
    echo ""
    
    # Run each test
    for test_file in "${test_files[@]}"; do
        local test_name=$(basename "${test_file}" .mlir)
        
        # Apply filter if specified
        if [ -n "${TEST_FILTER}" ] && [ "${TEST_FILTER}" != "all" ]; then
            if [[ ! "${test_name}" =~ ${TEST_FILTER} ]]; then
                continue
            fi
        fi
        
        run_test "${test_file}"
        echo ""
    done
}

# Main execution
log_info "DHIR Compiler Test Suite"
log_info "========================="
echo ""

# Track failed test names
FAILED_TEST_NAMES=()

run_polybench_tests

# Print summary
echo ""
log_info "Test Summary"
log_info "============"
echo "Total tests:  ${TOTAL_TESTS}"
echo -e "Passed:       ${GREEN}${PASSED_TESTS}${NC}"
echo -e "Failed:       ${RED}${FAILED_TESTS}${NC}"

# List failed tests if any
if [ ${FAILED_TESTS} -gt 0 ]; then
    echo ""
    log_error "Failed tests:"
    for test_name in "${FAILED_TEST_NAMES[@]}"; do
        echo "  - ${test_name}"
    done
fi

if [ $KEEP_OUTPUT -eq 1 ]; then
    log_info "Output files saved to: ${OUTPUT_DIR}"
fi

# Exit with appropriate code
if [ ${FAILED_TESTS} -eq 0 ]; then
    exit 0
else
    exit 1
fi
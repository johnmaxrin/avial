# Makefile for DHIR Testing

.PHONY: all test test-verbose test-single clean help

SHELL := /bin/bash
BUILD_DIR := ../build
TEST_SCRIPT := ./run_tests.sh
PER_PASS_SCRIPT := ./test_per_pass.sh

# Default target
all: test

# Run all tests
test:
	@echo "Running all tests..."
	@chmod +x $(TEST_SCRIPT)
	@$(TEST_SCRIPT) all

# Run tests with verbose output
test-verbose:
	@echo "Running all tests (verbose)..."
	@chmod +x $(TEST_SCRIPT)
	@$(TEST_SCRIPT) all --verbose

# Run tests and keep output
test-keep:
	@echo "Running all tests (keeping output)..."
	@chmod +x $(TEST_SCRIPT)
	@$(TEST_SCRIPT) all --keep-output

# Run a single test by name
# Usage: make test-single TEST=jacobi
test-single:
ifndef TEST
	$(error TEST is not set. Usage: make test-single TEST=jacobi)
endif
	@echo "Running test: $(TEST)"
	@chmod +x $(TEST_SCRIPT)
	@$(TEST_SCRIPT) $(TEST) --verbose --keep-output

# Run per-pass test
# Usage: make test-pass FILE=../tests/polybench/jacobi.mlir
test-pass:
ifndef FILE
	$(error FILE is not set. Usage: make test-pass FILE=../tests/polybench/jacobi.mlir)
endif
	@chmod +x $(PER_PASS_SCRIPT)
	@$(PER_PASS_SCRIPT) $(FILE)

# Run per-pass test and stop at specific pass
# Usage: make test-pass-stop FILE=../tests/polybench/jacobi.mlir STOP=lower-converge
test-pass-stop:
ifndef FILE
	$(error FILE is not set)
endif
ifndef STOP
	$(error STOP is not set)
endif
	@chmod +x $(PER_PASS_SCRIPT)
	@$(PER_PASS_SCRIPT) $(FILE) --stop-at=$(STOP)

# Clean test outputs
clean:
	@echo "Cleaning test outputs..."
	@rm -rf $(BUILD_DIR)/test_output
	@echo "Done."

# Show help
help:
	@echo "DHIR Test Infrastructure"
	@echo "========================"
	@echo ""
	@echo "Available targets:"
	@echo "  make test              - Run all tests"
	@echo "  make test-verbose      - Run all tests with verbose output"
	@echo "  make test-keep         - Run all tests and keep output files"
	@echo "  make test-single TEST=<name> - Run a specific test"
	@echo "  make test-pass FILE=<path>   - Run per-pass test on a file"
	@echo "  make test-pass-stop FILE=<path> STOP=<pass> - Stop at specific pass"
	@echo "  make clean             - Clean test output directory"
	@echo "  make help              - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make test-single TEST=jacobi"
	@echo "  make test-pass FILE=../tests/polybench/jacobi.mlir"
	@echo "  make test-pass-stop FILE=../tests/polybench/jacobi.mlir STOP=lower-converge"
	@echo ""
	@echo "Available passes for STOP:"
	@echo "  affine-to-dhir, std-to-dhir, lower-replicate, lower-converge"
	@echo "  dhir-to-mpi, lower-to-llvm"
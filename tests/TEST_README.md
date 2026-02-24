# DHIR Compiler Test Infrastructure

A comprehensive testing framework for the DHIR compiler pipeline.

## Quick Start

```bash
# From the project root
cd test

# Run all tests
make test

# Run a specific test
make test-single TEST=jacobi

# Run with verbose output
make test-verbose
```

## Components

### 1. Main Test Runner (`run_tests.sh`)

Runs all tests in the polybench directory through the full compilation pipeline.

**Usage:**
```bash
./run_tests.sh [test_name|all] [--verbose] [--keep-output]
```

**Examples:**
```bash
# Run all tests
./run_tests.sh all

# Run specific test
./run_tests.sh jacobi

# Run with verbose output
./run_tests.sh all --verbose

# Keep output files for inspection
./run_tests.sh all --keep-output
```

**Features:**
- ✅ Runs full pipeline: affine-to-dhir → std-to-dhir → lower-replicate → lower-converge → dhir-to-mpi → lower-to-llvm
- ✅ Colored output for easy reading
- ✅ Test statistics (passed/failed counts)
- ✅ Error logging for failed tests
- ✅ Optional verbose mode for debugging

### 2. Per-Pass Test Runner (`test_per_pass.sh`)

Runs a single test file through each pass incrementally, saving intermediate results.

**Usage:**
```bash
./test_per_pass.sh <test_file.mlir> [--stop-at=PASS]
```

**Examples:**
```bash
# Run all passes
./test_per_pass.sh ../tests/polybench/jacobi.mlir

# Stop after lower-converge
./test_per_pass.sh ../tests/polybench/jacobi.mlir --stop-at=lower-converge
```

**Output:**
Creates `build/test_output/<test_name>/` with files:
- `1_affine-to-dhir.mlir`
- `2_std-to-dhir.mlir`
- `3_lower-replicate.mlir`
- `4_lower-converge.mlir`
- `5_dhir-to-mpi.mlir`
- `6_lower-to-llvm.mlir`

### 3. Makefile Targets

Convenient shortcuts for common testing tasks.

**Available targets:**

| Target | Description |
|--------|-------------|
| `make test` | Run all tests |
| `make test-verbose` | Run all tests with verbose output |
| `make test-keep` | Run all tests and keep output files |
| `make test-single TEST=<name>` | Run a specific test |
| `make test-pass FILE=<path>` | Run per-pass test on a file |
| `make test-pass-stop FILE=<path> STOP=<pass>` | Stop at specific pass |
| `make clean` | Clean test output directory |
| `make help` | Show help message |

**Examples:**
```bash
# Quick test
make test

# Debug specific test
make test-single TEST=jacobi

# Inspect intermediate outputs
make test-pass FILE=../tests/polybench/jacobi.mlir

# Stop at specific pass for debugging
make test-pass-stop FILE=../tests/polybench/jacobi.mlir STOP=lower-converge

# Clean up
make clean
```

### 4. Test Analyzer (`analyze_tests.py`)

Python script that analyzes test outputs and generates reports.

**Usage:**
```bash
./analyze_tests.py <output_dir> [--report FILE] [--json FILE]
```

**Examples:**
```bash
# Generate report to stdout
./analyze_tests.py ../build/test_output

# Save report to file
./analyze_tests.py ../build/test_output --report report.txt

# Export JSON data
./analyze_tests.py ../build/test_output --json data.json
```

**Features:**
- Line counts for each pass
- Operation counts and frequency
- Dialect usage statistics
- Per-test and aggregate summaries

## Directory Structure

```
test/
├── run_tests.sh          # Main test runner
├── test_per_pass.sh      # Per-pass test runner
├── analyze_tests.py      # Analysis tool
├── Makefile              # Convenience targets
└── README.md             # This file

build/
└── test_output/          # Generated test outputs
    ├── jacobi/           # Per-test directory
    │   ├── 1_affine-to-dhir.mlir
    │   ├── 2_std-to-dhir.mlir
    │   └── ...
    └── ...

tests/
└── polybench/            # Test input files
    ├── jacobi.mlir
    ├── seidel.mlir
    └── ...
```

## Compilation Pipeline

The full pipeline consists of these passes:

1. **`--affine-to-dhir`**: Convert Affine dialect to DHIR
   - Wraps loops in FixedPointOp or ReplicateOp
   - Analyzes loop dependencies

2. **`--std-to-dhir`**: Convert Standard dialect to DHIR
   - Converts standard operations

3. **`--lower-replicate`**: Lower Replicate operations
   - Converts ReplicateOp to TaskOp

4. **`--lower-converge`**: Lower Converge operations
   - Sets needBroadcast flags
   - Inlines ConvergeOp body

5. **`--dhir-to-mpi`**: Convert DHIR to MPI
   - Generates MPI communication code
   - Creates rank-based task distribution
   - Handles GPU operations

6. **`--lower-to-llvm`**: Lower to LLVM
   - Final lowering to LLVM dialect

## Common Workflows

### Developing a New Pass

```bash
# 1. Run per-pass test to see current state
make test-pass FILE=../tests/polybench/jacobi.mlir

# 2. Work on your pass implementation

# 3. Test incrementally, stopping at your pass
make test-pass-stop FILE=../tests/polybench/jacobi.mlir STOP=your-pass

# 4. Once working, test full pipeline
make test-single TEST=jacobi

# 5. Run all tests to ensure no regressions
make test
```

### Debugging a Failing Test

```bash
# 1. Run with verbose output
make test-single TEST=failing_test

# 2. Run per-pass to find where it fails
make test-pass FILE=../tests/polybench/failing_test.mlir

# 3. Inspect intermediate output
cat ../build/test_output/failing_test/3_lower-replicate.mlir

# 4. Fix the issue

# 5. Verify fix
make test-single TEST=failing_test
```

### Analyzing Performance

```bash
# 1. Run tests and keep outputs
make test-keep

# 2. Generate analysis report
./analyze_tests.py ../build/test_output --report analysis.txt

# 3. Review operation counts and dialect usage
cat analysis.txt

# 4. Export for further processing
./analyze_tests.py ../build/test_output --json data.json
```

## Adding New Tests

1. Add your `.mlir` file to `tests/polybench/`
2. Run the test:
   ```bash
   make test-single TEST=your_test_name
   ```
3. If it passes, it will automatically be included in `make test`

## Continuous Integration

For CI systems, use:

```bash
cd test
make test
```

This will:
- Run all tests
- Return exit code 0 on success, 1 on failure
- Print summary with pass/fail counts

## Troubleshooting

**Problem:** `dhir-opt not found`
```bash
# Solution: Build the project first
cd build && make
```

**Problem:** Tests fail with "permission denied"
```bash
# Solution: Make scripts executable
chmod +x run_tests.sh test_per_pass.sh analyze_tests.py
```

**Problem:** Want to see detailed error messages
```bash
# Solution: Use verbose mode
make test-verbose
# or
./run_tests.sh all --verbose
```

**Problem:** Want to inspect intermediate MLIR
```bash
# Solution: Use per-pass runner
make test-pass FILE=../tests/polybench/your_test.mlir
# Look in build/test_output/your_test/
```

## Output Files

Test outputs are saved to `build/test_output/`:
- Each test gets its own directory
- Each pass creates a numbered `.mlir` file
- Error logs saved as `.error` files
- Use `make clean` to remove all outputs

## Tips

- Use `make test-keep` during development to inspect outputs
- Use `make test-pass-stop` to debug specific passes
- Check error logs in `build/test_output/` for detailed errors
- Use the analyzer to track operation counts across passes
- Run `make test` before committing to catch regressions

## Advanced Usage

### Custom Pass Sequences

Edit the `PIPELINE` array in `run_tests.sh` to test custom pass sequences:

```bash
PIPELINE=(
    "--your-custom-pass"
    "--affine-to-dhir"
    # ... more passes
)
```

### Parallel Testing

For large test suites, use GNU parallel:

```bash
find ../tests/polybench -name "*.mlir" | \
    parallel --jobs 4 "./test_per_pass.sh {}"
```

### Test Result Tracking

Track test results over time:

```bash
# Run tests and save report
make test > test_results_$(date +%Y%m%d).log
```

## Contributing

When adding new tests:
1. Ensure they follow the same structure as existing tests
2. Add documentation if the test covers a specific feature
3. Run the full test suite before submitting
4. Include any necessary input files in `tests/`
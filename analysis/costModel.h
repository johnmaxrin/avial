// Evaluates OpenMP-aware computational workload, memory traffic, and multi-thread
// scaling directly at the DHIR dialect stage (following ConvertAffineToDhirPass).
//
// Analyzes parallel loops (dhir.replicate), sequential regions (dhir.task),
// and iterative temporal loops (dhir.converge) to assess:
//   1. Total FLOP throughput versus per-thread workload across OpenMP teams,
//      distinguishing parallelized compute from unparallelized serial execution.
//   2. Cache residency across memory hierarchies (L1/LLC) versus off-chip DRAM volume.
//   3. Inter-core broadcast penalties incurred by shared read-only operands.
//   4. Spatial memory access patterns (differentiating unit-stride and strided accesses).
//   5. Mandatory memory bus transfers: modified buffers incur two passes (read for
//      ownership and eventual writeback), whereas cache-resident loops avoid redundant
//      reloads over successive iterations of a time loop.
//
// Scope: Affine and DHIR loop structures featuring compile-time constant trip counts.
// Any non-analyzable constructs trigger an invalid state accompanied by a diagnostic reason.
#pragma once

#include "mlir/Dialect/Affine/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/Affine/Analysis/Utils.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Math/IR/Math.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/MapVector.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/raw_ostream.h"

// Operations from the DHIR dialect (ReplicateOp, ConvergeOp, TaskOp) are utilized
// solely by this OpenMP cost model; the corresponding header is local to this repository.
#include "includes/dhirOps.h"

#include <algorithm>
#include <cerrno>
#include <cstdlib>
#include <limits>
#include <fstream>
#include <functional>
#include <optional>

namespace mlir {
namespace dhir {

inline bool checkedAddNonNegative(int64_t lhs, int64_t rhs, int64_t &out) {
    if (lhs < 0 || rhs < 0 || lhs > std::numeric_limits<int64_t>::max() - rhs)
        return false;
    out = lhs + rhs;
    return true;
}

inline bool checkedMulNonNegative(int64_t lhs, int64_t rhs, int64_t &out) {
    if (lhs < 0 || rhs < 0)
        return false;
    __int128 value = static_cast<__int128>(lhs) * rhs;
    if (value > std::numeric_limits<int64_t>::max())
        return false;
    out = static_cast<int64_t>(value);
    return true;
}

/// Evaluates the floating-point FLOP contribution of an operation. Integer operations
/// are omitted because index calculations and loop control do not count toward roofline compute.
inline std::optional<int64_t> flopWeightChecked(Operation *op) {
    int64_t base = 0;
    // Under standard roofline modeling (aligned with calibrate.py), a fused
    // multiply-add operation is credited as 2 FLOPs (matching 2*M*N*K in gemm kernels).
    if (isa<math::FmaOp>(op)) base = 2;
    else if (isa<arith::AddFOp, arith::SubFOp, arith::MulFOp, arith::DivFOp,
            arith::NegFOp, arith::RemFOp, arith::MaximumFOp, arith::MinimumFOp,
            arith::MaxNumFOp, arith::MinNumFOp>(op))
        base = 1;
    // Transcendental and non-linear math functions are assigned a baseline of 1 FLOP.
    // While physical execution latency on hardware is considerably greater, existing
    // benchmark suites do not feature these heavily, so maintaining a uniform baseline
    // avoids introducing ad-hoc, uncalibrated cycle heuristics.
    else if (isa<math::SqrtOp, math::ExpOp, math::LogOp, math::PowFOp,
            math::SinOp, math::CosOp, math::TanhOp, math::AbsFOp>(op))
        base = 1;
    else if (auto contract = dyn_cast<vector::ContractionOp>(op)) {
        auto lhs = contract.getLhsType();
        auto rhs = contract.getRhsType();
        if (lhs.isScalable() || rhs.isScalable() ||
            !isa<FloatType>(lhs.getElementType()))
            return int64_t(0);
        SmallVector<int64_t> bounds;
        contract.getIterationBounds(bounds);
        int64_t iterations = 1;
        for (int64_t bound : bounds)
            if (!checkedMulNonNegative(iterations, bound, iterations))
                return std::nullopt;
        if (!checkedMulNonNegative(iterations, 2, base)) return std::nullopt;
    } else if (auto reduction = dyn_cast<vector::ReductionOp>(op)) {
        auto source = reduction.getSourceVectorType();
        if (source.isScalable() || !isa<FloatType>(source.getElementType()))
            return int64_t(0);
        int64_t count = source.getNumElements();
        // Reducing a vector of N elements entails N - 1 binary reductions, plus
        // an additional operation if an initial accumulator operand is supplied.
        if (count <= 0) return std::nullopt;
        bool hasAccumulator = op->getNumOperands() > 1;
        int64_t combines = count - 1;
        if (hasAccumulator &&
            !checkedAddNonNegative(combines, 1, combines))
            return std::nullopt;
        base = combines;
    } else if (auto reduction = dyn_cast<vector::MultiDimReductionOp>(op)) {
        auto source = reduction.getSourceVectorType();
        if (source.isScalable() || !isa<FloatType>(source.getElementType()))
            return int64_t(0);
        int64_t reduced = 1;
        for (int64_t dim : reduction.getReductionDims()) {
            if (dim < 0 || dim >= source.getRank() ||
                !checkedMulNonNegative(reduced, source.getDimSize(dim), reduced))
                return std::nullopt;
        }
        base = std::max<int64_t>(0, reduced - 1);
    } else
        return int64_t(0);

    // Operations with zero iterations or null shapes yield zero computational cost;
    // early-exit here to avoid division-by-zero during subsequent lane scaling.
    if (base == 0) return int64_t(0);

    Type resultType;
    if (op->getNumResults() != 0)
        resultType = op->getResult(0).getType();
    else if (op->getNumOperands() != 0)
        resultType = op->getOperand(0).getType();
    if (auto vector = dyn_cast<VectorType>(resultType)) {
        // Scalable vector lengths cannot be evaluated statically at compile time.
        // Assuming unit scalar length would underestimate execution cost, so this
        // triggers an evaluation failure.
        if (vector.isScalable()) return std::nullopt;
        int64_t lanes = vector.getNumElements();
        if (lanes <= 0 || lanes > std::numeric_limits<int64_t>::max() / base)
            return std::nullopt;
        base *= lanes;
    } else if (auto shaped = dyn_cast<ShapedType>(resultType)) {
        // Pointwise operations over statically shaped tensors scale with total element count.
        // Tensors with dynamic dimensions or unranked shapes cannot be statically quantified.
        if (!shaped.hasStaticShape()) return std::nullopt;
        int64_t elements = shaped.getNumElements();
        if (elements <= 0 || elements > std::numeric_limits<int64_t>::max() / base)
            return std::nullopt;
        base *= elements;
    }
    return base;
}

inline int64_t flopWeight(Operation *op) {
    return flopWeightChecked(op).value_or(0);
}

/// Computes the element storage size in bytes for a memref, supporting fixed-width vectors.
/// Index types and dynamically scalable vectors are rejected because their concrete byte
/// footprint depends on machine-specific runtime properties.
inline std::optional<int64_t> elementByteWidth(Type elem) {
    if (elem.isIntOrFloat()) {
        unsigned bits = elem.getIntOrFloatBitWidth();
        if (bits == 0) return std::nullopt;
        return int64_t((bits + 7) / 8);
    }
    if (auto complex = dyn_cast<ComplexType>(elem)) {
        auto scalar = elementByteWidth(complex.getElementType());
        if (!scalar) return std::nullopt;
        int64_t width = 0;
        if (!checkedMulNonNegative(*scalar, 2, width)) return std::nullopt;
        return width;
    }
    if (auto vector = dyn_cast<VectorType>(elem)) {
        if (vector.isScalable()) return std::nullopt;
        auto scalar = elementByteWidth(vector.getElementType());
        if (!scalar) return std::nullopt;
        int64_t width = 0;
        if (!checkedMulNonNegative(*scalar, vector.getNumElements(), width))
            return std::nullopt;
        return width;
    }
    return std::nullopt;
}

/// Obtains the individual element size in bytes for the specified memref Value.
inline int64_t elementBytes(Value memref) {
    auto type = dyn_cast<MemRefType>(memref.getType());
    if (!type) return 0;
    return elementByteWidth(type.getElementType()).value_or(0);
}

/// Extracts the underlying memref Value targeted by an affine load or store, or returns nullptr.
inline Value accessedMemref(Operation *op) {
    if (auto load = dyn_cast<affine::AffineLoadOp>(op)) return load.getMemRef();
    if (auto store = dyn_cast<affine::AffineStoreOp>(op)) return store.getMemRef();
    if (auto load = dyn_cast<affine::AffineVectorLoadOp>(op)) return load.getMemRef();
    if (auto store = dyn_cast<affine::AffineVectorStoreOp>(op)) return store.getMemRef();
    return nullptr;
}

inline bool isAffineMemoryOp(Operation *op) {
    return isa<affine::AffineLoadOp, affine::AffineStoreOp,
                affine::AffineVectorLoadOp, affine::AffineVectorStoreOp>(op);
}

/// Derives the static multidimensional slice dimensions for affine vector read/write operations.
/// Because vector transfers span minor dimensions, this shape scales the scalar bounding box
/// when estimating memory footprint.
inline std::optional<SmallVector<int64_t>> affineVectorAccessShape(Operation *op) {
    VectorType type;
    if (auto load = dyn_cast<affine::AffineVectorLoadOp>(op))
        type = load.getVectorType();
    else if (auto store = dyn_cast<affine::AffineVectorStoreOp>(op))
        type = store.getVectorType();
    else
        return std::nullopt;
    if (type.isScalable()) return std::nullopt;
    SmallVector<int64_t> shape;
    for (int64_t extent : type.getShape()) {
        if (extent <= 0) return std::nullopt;
        shape.push_back(extent);
    }
    return shape;
}

/// Classifies the spatial memory traversal pattern with respect to a loop induction variable.
/// Memory regularity directly dictates vector efficiency and accounts for significant
/// throughput disparities across kernels: in syr2k, inner loop iterations access B[i][k],
/// C[j][k], C[i][k], and B[j][k] with consecutive unit stride (attaining ~7.15 GFLOP/s),
/// whereas gemm touches B[k][j] across columns with stride N (yielding ~1.51 GFLOP/s).
/// Since the same platform exhibits up to a 4.7x speed gap at identical loop depths,
/// a unified compute throughput R is inadequate, requiring this structural classification.
enum class StrideClass {
    Invariant,  ///< Reference unaffected by the loop index (loop-invariant)
    UnitStride, ///< Sequential, cache-line-friendly traversal on successive iterations
    Strided     ///< Non-consecutive progression or indexing across a leading dimension
};

/// Extracts the linear coefficient of dimension index `pos` inside `expr` (returning 0 if absent).
/// For non-linear, non-affine, or compile-time indeterminate terms (e.g. products of variables,
/// modulo, floor/ceil divisions), a sentinel is returned so downstream analyses safely fall
/// back to classifying the access as non-unit strided.
inline int64_t affineExprCoefficient(AffineExpr expr, unsigned pos,
                                     bool symbol) {
    constexpr int64_t unknown = 1 << 20;
    if (isa<AffineConstantExpr>(expr)) return 0;
    if (auto dim = dyn_cast<AffineDimExpr>(expr))
        return !symbol && dim.getPosition() == pos ? 1 : 0;
    if (auto sym = dyn_cast<AffineSymbolExpr>(expr))
        return symbol && sym.getPosition() == pos ? 1 : 0;
    auto bin = dyn_cast<AffineBinaryOpExpr>(expr);
    if (!bin) return unknown;
    int64_t lhs = affineExprCoefficient(bin.getLHS(), pos, symbol);
    int64_t rhs = affineExprCoefficient(bin.getRHS(), pos, symbol);
    switch (bin.getKind()) {
    case AffineExprKind::Add: {
        if (lhs == unknown || rhs == unknown) return unknown;
        __int128 value = static_cast<__int128>(lhs) + rhs;
        return value > std::numeric_limits<int64_t>::max() ||
                       value < std::numeric_limits<int64_t>::min()
                   ? unknown
                   : static_cast<int64_t>(value);
    }
    case AffineExprKind::Mul: {
        if (auto c = dyn_cast<AffineConstantExpr>(bin.getRHS()))
            return lhs == unknown ? unknown :
                   (static_cast<__int128>(lhs) * c.getValue() >
                            std::numeric_limits<int64_t>::max() ||
                        static_cast<__int128>(lhs) * c.getValue() <
                            std::numeric_limits<int64_t>::min()
                    ? unknown
                    : lhs * c.getValue());
        if (auto c = dyn_cast<AffineConstantExpr>(bin.getLHS()))
            return rhs == unknown ? unknown :
                   (static_cast<__int128>(rhs) * c.getValue() >
                            std::numeric_limits<int64_t>::max() ||
                        static_cast<__int128>(rhs) * c.getValue() <
                            std::numeric_limits<int64_t>::min()
                    ? unknown
                    : rhs * c.getValue());
        return (lhs || rhs) ? unknown : 0;
    }
    default: // Non-linear affine operations including mod, floordiv, and ceildiv
        return (lhs || rhs) ? unknown : 0;
    }
}

inline int64_t dimCoefficient(AffineExpr expr, unsigned pos) {
    return affineExprCoefficient(expr, pos, false);
}

/// Analyzes an affine memory operation to determine whether its address progression under `iv` is invariant, unit-stride, or strided.
inline StrideClass classifyAccess(Operation *op, Value iv) {
    if (!isAffineMemoryOp(op))
        return StrideClass::Invariant;

    affine::MemRefAccess access(op);
    affine::AffineValueMap map;
    access.getAccessMap(&map);
    if (map.getNumResults() == 0) return StrideClass::Invariant;
    map.composeSimplifyAndCanonicalize();

    auto memref = accessedMemref(op);
    auto memrefType = memref ? dyn_cast<MemRefType>(memref.getType()) : MemRefType();
    if (!memrefType) return StrideClass::Strided;

    bool depends = false;
    for (unsigned r = 0; r < map.getNumResults(); ++r)
        depends |= map.isFunctionOf(r, iv);
    if (!depends) return StrideClass::Invariant;

    // Querying physical element strides directly from MemRefType handles identity,
    // explicitly strided, and affine layouts, avoiding the naive assumption that the
    // highest logical dimension corresponds to unit physical memory spacing.
    SmallVector<int64_t> strides;
    int64_t offset = 0;
    if (failed(memrefType.getStridesAndOffset(strides, offset)) ||
        strides.size() != map.getNumResults()) {
        return StrideClass::Strided;
    }
    if (memrefType.getLayout().isIdentity()) {
        // In certain MLIR releases, dynamic-dimension identity memrefs report dynamic
        // strides even on the fastest dimension. The innermost physical stride is guaranteed
        // to be unit (1), allowing outer strides to be derived so long as subsequent extents remain constant.
        int64_t trailing = 1;
        for (int r = int(strides.size()) - 1; r >= 0; --r) {
            if (strides[r] == ShapedType::kDynamic) {
                if (r == int(strides.size()) - 1)
                    strides[r] = 1;
                else if (trailing != ShapedType::kDynamic)
                    strides[r] = trailing;
            }
            int64_t dim = memrefType.getDimSize(unsigned(r));
            if (strides[r] == ShapedType::kDynamic ||
                dim == ShapedType::kDynamic ||
                !checkedMulNonNegative(strides[r], dim, trailing))
                trailing = ShapedType::kDynamic;
        }
    }

    unsigned ivPos = 0;
    bool found = false;
    for (; ivPos < map.getNumOperands(); ++ivPos) {
        if (map.getOperand(ivPos) == iv) {
            found = true;
            break;
        }
    }
    // After affine simplification or rebasing, an IV may influence an expression transitively
    // without appearing as an explicit top-level operand. Since the exact linear multiplier
    // cannot be extracted directly, classify conservatively as strided.
    if (!found) {
        return StrideClass::Strided;
    }
    bool ivIsSymbol = ivPos >= map.getNumDims();
    unsigned coeffPos = ivIsSymbol ? ivPos - map.getNumDims() : ivPos;

    __int128 physicalCoeff = 0;
    bool sawDependentDimension = false;
    for (unsigned r = 0; r < map.getNumResults(); ++r) {
        if (!map.isFunctionOf(r, iv)) continue;
        sawDependentDimension = true;
        int64_t coeff = affineExprCoefficient(map.getResult(r), coeffPos,
                                               ivIsSymbol);
        if (coeff == (1 << 20) || strides[r] == ShapedType::kDynamic) {
            return StrideClass::Strided;
        }
        physicalCoeff += static_cast<__int128>(coeff) * strides[r];
        if (physicalCoeff > std::numeric_limits<int64_t>::max() ||
            physicalCoeff < std::numeric_limits<int64_t>::min())
            return StrideClass::Strided;
    }
    if (!sawDependentDimension) return StrideClass::Invariant;
    // A net physical step of zero indicates repeated access to the same address (such as
    // an invariant broadcast slice within the loop), which does not constitute unit stride.
    return physicalCoeff == 1 ? StrideClass::UnitStride : StrideClass::Strided;
}

/// Finds the innermost affine.for loop surrounding `op`, returning nullptr if none exists.
inline affine::AffineForOp innermostLoop(Operation *op) {
    for (Operation *p = op->getParentOp(); p; p = p->getParentOp())
        if (auto forOp = dyn_cast<affine::AffineForOp>(p)) return forOp;
    return nullptr;
}

/// Inspects DHIR dialect IR (after ConvertAffineToDhirPass) to formulate OpenMP-informed
/// compute load and memory bandwidth estimations. This resolves the primary limitations
/// identified in early cost model revisions:
///
/// 1. Uniform Parallelism Assumption — distinguishes multithreaded teams in dhir.replicate
///    (T threads) from sequential execution in dhir.task (1 thread) and dhir.converge loops.
/// 2. Single-Core Cache Model — accounts for shared read data replicated across core caches,
///    scaling off-chip DRAM requests by α(T, LLC) when aggregate footprints outgrow LLC capacity.
/// 3. Static Invocation Count — models activation frequencies as the product of enclosing
///    temporal iteration bounds.
///
/// Calibration methodology:
///   R_strided = W_IR(gemm) / t_gemm       (isolated directly without multi-parameter fitting)
///   R_contiguous = W_IR(syr2k) / t_syr2k
///   B = Bytes_total(add2d) / t_add2d
struct OMPCostModelResult {
    bool valid = true;
    std::string reason;

    /// Represents an isolated execution scope (either parallel replicate or sequential task/converge).
    struct Nest {
        std::string kind; // "replicate" | "replicate (in converge)" | "task" | "serial"
        int64_t totalFlops = 0;
        int64_t threadFlops = 0;    ///< Per-thread computational volume (total / T for parallel nests)
        int64_t partitionedBytes = 0; ///< Volume of thread-private partitioned memory traffic
        int64_t broadcastBytes = 0;   ///< Invariant shared operand traffic prior to core replication scaling
        int64_t broadcastMultiplier = 1; ///< Amplification factor α(T, LLC): 1 if cache-resident, T otherwise
        int64_t totalBytes = 0;       ///< Combined traffic (partitionedBytes + broadcastMultiplier * broadcastBytes)
        int64_t entries = 1;          ///< Invocation count per kernel launch (derived from outer convergence iterations)
        int64_t stridedFlops = 0;
        int64_t inCacheStridedFlops = 0;
        int64_t llcStridedFlops = 0;  ///< Strided operations where loop working set fits within the LLC
        int64_t contiguousFlops = 0;
        int64_t stridedFootprintBytes = 0;
        int64_t workingSetBytes = 0;  ///< Peak memory footprint across active innermost loops
        bool isCacheResidentStrided = false;
        bool isLLCResidentStrided = false;
        bool inCache = false;         ///< Indicates whether the working set remains within LLC bounds
        bool isParallel = false;      ///< True if dispatched across an OpenMP thread team (replicate)
        bool exact = true;            ///< Set to false if any static metric could not be conclusively proven
    };

    SmallVector<Nest> nests;

    int64_t totalFlops() const {
        int64_t s = 0;
        for (auto &n : nests) {
            if (!checkedAddNonNegative(s, n.totalFlops, s))
                return std::numeric_limits<int64_t>::max();
        }
        return s;
    }
    int64_t totalThreadFlops() const {
        int64_t s = 0;
        for (auto &n : nests) {
            if (!checkedAddNonNegative(s, n.threadFlops, s))
                return std::numeric_limits<int64_t>::max();
        }
        return s;
    }
    int64_t totalBytes() const {
        int64_t s = 0;
        for (auto &n : nests) {
            if (!checkedAddNonNegative(s, n.totalBytes, s))
                return std::numeric_limits<int64_t>::max();
        }
        return s;
    }
    int64_t totalEntries() const {
        int64_t s = 0;
        for (auto &n : nests) {
            if (!checkedAddNonNegative(s, n.entries, s))
                return std::numeric_limits<int64_t>::max();
        }
        return s;
    }
    /// Computes operation counts grouped by access class. When `onlySerial` is enabled,
    /// aggregation is limited to single-threaded regions (dhir.task, dhir.converge, or unparallelized
    /// affine loops), allowing their cost to be evaluated using single-core performance rates.
    struct ClassFlops {
        long double dram = 0, l1 = 0, llc = 0, contiguous = 0;
        long double total() const { return dram + l1 + llc + contiguous; }
    };
    ClassFlops classFlops(bool onlySerial = false) const {
        ClassFlops c;
        for (auto &n : nests) {
            if (onlySerial && n.isParallel) continue;
            c.dram += n.stridedFlops;
            c.l1 += n.inCacheStridedFlops;
            c.llc += n.llcStridedFlops;
            c.contiguous += n.contiguousFlops;
        }
        return c;
    }

    /// Cumulative proportion of operations executed with non-unit strides, covering L1, LLC, and DRAM.
    /// Use `dramStridedFlopFraction()` to inspect solely the memory-bottlenecked DRAM regime.
    double stridedFlopFraction() const {
        ClassFlops c = classFlops();
        return c.total() > 0 ? double((c.dram + c.l1 + c.llc) / c.total()) : 0.0;
    }
    double inCacheStridedFlopFraction() const {
        ClassFlops c = classFlops();
        return c.total() > 0 ? double(c.l1 / c.total()) : 0.0;
    }
    double dramStridedFlopFraction() const {
        ClassFlops c = classFlops();
        return c.total() > 0 ? double(c.dram / c.total()) : 0.0;
    }
    double llcStridedFlopFraction() const {
        ClassFlops c = classFlops();
        return c.total() > 0 ? double(c.llc / c.total()) : 0.0;
    }
    double serialFlopFraction() const {
        ClassFlops all = classFlops(), ser = classFlops(true);
        return all.total() > 0 ? double(ser.total() / all.total()) : 0.0;
    }
    /// Counts loop nests dispatched across an OpenMP thread team. Kernels lacking
    /// any parallel regions omit thread team initialization, avoiding one-time setup latency.
    size_t parallelNests() const {
        return size_t(llvm::count_if(nests, [](const Nest &n) {
            return n.isParallel;
        }));
    }

    void print(raw_ostream &os, StringRef label,
               const struct MachineModel *machine = nullptr) const;
};

/// Enumeration of performance regimes, arranged in ascending order of throughput.
enum ComputeClass { CC_Dram = 0, CC_Llc, CC_L1, CC_Contiguous, CC_Count };

inline StringRef computeClassName(unsigned cls) {
    static const char *names[] = {"dram", "llc", "l1", "contiguous"};
    return cls < CC_Count ? names[cls] : "unknown";
}

/// Hardware profile encapsulation: defines throughput rates across regimes (both team and
/// single-core), sustained memory bandwidth, runtime dispatch latencies, and cache capacities.
///
/// Decoupled entirely from MLIR IR structures, this profile allows optimization passes to evaluate
/// candidate placement choices rapidly against cached nest summaries:
/// evaluating P candidates entails P calls to `machineSeconds` rather than repeated AST traversals.
///
/// Values are populated from system configurations generated by `calibrate.py --update-config`
/// and mapped into the `dhir.machine` DLTI attribute space via `libs/utils.cc`.
struct MachineModel {
    double rate[CC_Count] = {0.0, 0.0, 0.0, 0.0};
    double serialRate[CC_Count] = {0.0, 0.0, 0.0, 0.0};
    double bandwidth = 0.0;      ///< Memory bus streaming bandwidth (B, in bytes/sec)
    double startup = 0.0;        ///< Kernel launch base latency (c)
    double firstEntry = 0.0;     ///< Initial OpenMP thread team allocation penalty (h_first)
    double entry = 0.0;          ///< Subsequent parallel region synchronization and entry overhead (h)
    int64_t l1Bytes = 0;
    int64_t llcBytes = 0;
    int64_t memoryBytes = 0;
    int threads = 0;

    /// Uncalibrated architectures reflect zero throughput; this guard prevents
    /// division-by-zero errors and keeps profiling in metrics-only mode.
    bool calibrated() const {
        for (unsigned cls = 0; cls < CC_Count; ++cls)
            if (rate[cls] <= 0.0) return false;
        return bandwidth > 0.0;
    }
    /// Defaults to the team execution rate if single-threaded measurements are unavailable,
    /// providing a lower bound on serial latency without assuming artificial scaling models.
    double singleThreadRate(unsigned cls) const {
        return serialRate[cls] > 0.0 ? serialRate[cls] : rate[cls];
    }
};

/// Estimates the execution time of an individual nest via its dominant compute or memory roofline.
/// Since nests execute sequentially, evaluating rooflines per nest prevents compute-intensive
/// loops from masking the true latency of memory-bound neighbors.
inline double machineNestSeconds(const OMPCostModelResult::Nest &nest,
                                 const MachineModel &machine) {
    const int64_t flops[CC_Count] = {nest.stridedFlops, nest.llcStridedFlops,
                                     nest.inCacheStridedFlops,
                                     nest.contiguousFlops};
    int64_t accounted = 0;
    for (unsigned cls = 0; cls < CC_Count; ++cls) accounted += flops[cls];
    double compute = 0.0;
    for (unsigned cls = 0; cls < CC_Count; ++cls) {
        double r = nest.isParallel ? machine.rate[cls]
                                   : machine.singleThreadRate(cls);
        if (r > 0.0) compute += double(flops[cls]) / r;
    }
    // Operations residing outside innermost loops lack access stride context;
    // they are charged at the contiguous rate to remain consistent with reporting metrics.
    if (accounted < nest.totalFlops) {
        double r = nest.isParallel ? machine.rate[CC_Contiguous]
                                   : machine.singleThreadRate(CC_Contiguous);
        if (r > 0.0) compute += double(nest.totalFlops - accounted) / r;
    }
    double memory = machine.bandwidth > 0.0
                        ? double(nest.totalBytes) / machine.bandwidth
                        : 0.0;
    return std::max(compute, memory);
}

/// Computes estimated total execution duration in seconds for an entire kernel:
///
///   T = c + h_first * [contains parallel region] + h * (entries - 1)
///       + sum_{n in nests}( max(compute_time_n, memory_time_n) )
///
/// Kernels devoid of `dhir.replicate` construct no OpenMP teams and thus bypass
/// team startup and region re-entry penalties.
inline std::optional<double> machineSeconds(const OMPCostModelResult &result,
                                            const MachineModel &machine) {
    if (!result.valid || !machine.calibrated()) return std::nullopt;
    int64_t entries = 0;
    bool anyParallel = false;
    double execution = 0.0;
    for (auto &nest : result.nests) {
        entries += nest.entries;
        anyParallel |= nest.isParallel;
        execution += machineNestSeconds(nest, machine);
    }
    double overhead = machine.startup;
    if (anyParallel)
        overhead += machine.firstEntry +
                    machine.entry * double(std::max<int64_t>(0, entries - 1));
    return overhead + execution;
}

/// Probes Linux sysfs to determine the host's L1 Data Cache capacity, defaulting safely if unavailable.
inline int64_t detectHostL1DataCacheBytes() {
    for (unsigned index = 0; index < 32; ++index) {
        std::string prefix = "/sys/devices/system/cpu/cpu0/cache/index" +
                             std::to_string(index) + "/";
        std::ifstream typeFile(prefix + "type");
        std::ifstream levelFile(prefix + "level");
        std::ifstream sizeFile(prefix + "size");
        std::string type, level, size;
        if (!typeFile || !levelFile || !sizeFile ||
            !(typeFile >> type) || !(levelFile >> level) || !(sizeFile >> size))
            continue;
        if (type != "Data" || level != "1") continue;

        errno = 0;
        char *end = nullptr;
        long long value = std::strtoll(size.c_str(), &end, 10);
        if (errno != 0 || end == size.c_str() || value < 0) continue;
        long long multiplier = 1;
        if (*end == 'K' || *end == 'k') multiplier = 1024LL;
        else if (*end == 'M' || *end == 'm') multiplier = 1024LL * 1024;
        else if (*end == 'G' || *end == 'g') multiplier = 1024LL * 1024 * 1024;
        else if (*end != '\0') continue;
        if (value > std::numeric_limits<int64_t>::max() / multiplier) continue;
        return int64_t(value * multiplier);
    }
    return 32768; // Default 32 KiB fallback for containerized or non-standard environments
}

/// Identifies the largest unified or data cache (LLC) exposed in host sysfs.
/// Accurate LLC capacity is vital for evaluating the OpenMP broadcast multiplier,
/// preventing skewed predictions caused by static cache size assumptions.
inline int64_t detectHostLastLevelCacheBytes() {
    int64_t largest = 0;
    for (unsigned index = 0; index < 32; ++index) {
        std::string prefix = "/sys/devices/system/cpu/cpu0/cache/index" +
                             std::to_string(index) + "/";
        std::ifstream typeFile(prefix + "type");
        std::ifstream levelFile(prefix + "level");
        std::ifstream sizeFile(prefix + "size");
        std::string type, level, size;
        if (!typeFile || !levelFile || !sizeFile ||
            !(typeFile >> type) || !(levelFile >> level) || !(sizeFile >> size))
            continue;
        if (type != "Data" && type != "Unified") continue;
        errno = 0;
        char *end = nullptr;
        long long value = std::strtoll(size.c_str(), &end, 10);
        if (errno != 0 || end == size.c_str() || value <= 0) continue;
        long long multiplier = 1;
        if (*end == 'K' || *end == 'k') multiplier = 1024LL;
        else if (*end == 'M' || *end == 'm') multiplier = 1024LL * 1024;
        else if (*end == 'G' || *end == 'g') multiplier = 1024LL * 1024 * 1024;
        else if (*end != '\0') continue;
        if (value > std::numeric_limits<int64_t>::max() / multiplier) continue;
        largest = std::max(largest, int64_t(value * multiplier));
    }
    return largest > 0 ? largest : 30LL * 1024 * 1024;
}

/// Calculates the combined bounding box footprint in bytes for a set of memory accesses
/// referencing the same memref at the specified loop depth.
inline std::optional<int64_t>
ompRegionBytes(ArrayRef<Operation *> accesses, unsigned loopDepth) {
    if (accesses.empty()) return int64_t(0);
    Value memref;
    std::optional<affine::MemRefRegion> merged;
    SmallVector<int64_t> vectorExtent;
    for (Operation *access : accesses) {
        if (!isAffineMemoryOp(access)) continue;
        Value current = accessedMemref(access);
        if (!current) continue;
        if (!memref) memref = current;
        if (memref != current) return std::nullopt;
        if (auto shape = affineVectorAccessShape(access)) {
            auto type = dyn_cast<MemRefType>(current.getType());
            if (!type || shape->size() > type.getRank()) return std::nullopt;
            if (vectorExtent.empty()) vectorExtent.assign(type.getRank(), 1);
            unsigned first = type.getRank() - shape->size();
            for (unsigned i = 0; i < shape->size(); ++i)
                vectorExtent[first + i] =
                    std::max(vectorExtent[first + i], (*shape)[i]);
        }
        affine::MemRefRegion region(access->getLoc());
        if (failed(region.compute(access, loopDepth))) return std::nullopt;
        if (!merged) { merged.emplace(std::move(region)); continue; }
        if (failed(merged->unionBoundingBox(region))) return std::nullopt;
    }
    if (!merged || !memref) return int64_t(0);
    auto type = dyn_cast<MemRefType>(memref.getType());
    if (!type) return std::nullopt;
    auto width = elementByteWidth(type.getElementType());
    if (!width) return std::nullopt;
    SmallVector<int64_t> shape;
    auto elements = merged->getConstantBoundingSizeAndShape(&shape);
    if (!elements || shape.size() != type.getRank()) return std::nullopt;
    if (!vectorExtent.empty()) {
        for (unsigned i = 0; i < shape.size(); ++i) {
            int64_t extra = vectorExtent[i] - 1;
            if (extra < 0 || shape[i] > std::numeric_limits<int64_t>::max() - extra)
                return std::nullopt;
            shape[i] += extra;
        }
        *elements = 1;
        for (int64_t extent : shape)
            if (!checkedMulNonNegative(*elements, extent, *elements))
                return std::nullopt;
    }
    int64_t bytes = 0;
    if (!checkedMulNonNegative(*elements, *width, bytes)) return std::nullopt;
    return bytes;
}

/// Evaluates the cumulative loop trip count product across all affine.for ancestors
/// enclosing `op`, up to (and excluding) the `stop` boundary.
inline int64_t ompEnclosingTrips(Operation *op, Operation *stop, bool &ok) {
    int64_t product = 1;
    for (Operation *parent = op->getParentOp(); parent && parent != stop;
         parent = parent->getParentOp()) {
        auto forOp = dyn_cast<affine::AffineForOp>(parent);
        if (!forOp) continue;
        std::optional<uint64_t> trip = affine::getConstantTripCount(forOp);
        if (!trip) { ok = false; return product; }
        int64_t next = 0;
        if (*trip > uint64_t(std::numeric_limits<int64_t>::max()) ||
            !checkedMulNonNegative(product, int64_t(*trip), next)) {
            ok = false;
            return std::numeric_limits<int64_t>::max();
        }
        product = next;
    }
    return product;
}

inline unsigned enclosingAffineForDepth(Operation *op) {
    unsigned depth = 0;
    for (Operation *parent = op->getParentOp(); parent;
         parent = parent->getParentOp())
        if (isa<affine::AffineForOp>(parent)) ++depth;
    return depth;
}

/// Determines the absolute loop nesting level for calculating an operand's cache reuse window.
///
/// Because `affine::MemRefRegion::compute(op, depth)` treats outer induction variables up to
/// `depth` as symbolic and aggregates across deeper levels, depth is measured globally relative
/// to the function's root affine loop rather than local DHIR constructs.
///
/// Non-unit-stride accesses typically exhibit temporal reuse only when outer loop dimensions
/// advance (e.g., column-strided `B[k][j]` in gemm traversed along k reuses lines across steps of j).
/// Therefore, sustained cache residency demands capturing the footprint across both the innermost loop
/// and its enclosing parent (`depth(loop) - 1`).
inline unsigned reuseWindowDepth(affine::AffineForOp loop) {
    unsigned depth = enclosingAffineForDepth(loop.getOperation());
    return depth > 0 ? depth - 1 : 0;
}

inline int64_t ompActiveWorkers(affine::AffineForOp loop, int numThreads) {
    if (numThreads <= 0) return 0;
    auto trip = affine::getConstantTripCount(loop);
    if (!trip || *trip == 0) return 1;
    if (*trip > uint64_t(std::numeric_limits<int64_t>::max()))
        return numThreads;
    return std::min<int64_t>(int64_t(numThreads), int64_t(*trip));
}

/// Profiles an individual affine.for loop (executed either inside a parallel dhir.replicate
/// or as a sequential nest), returning its detailed operation counts, traffic, and access categories.
inline OMPCostModelResult::Nest ompAnalyzeLoop(affine::AffineForOp forOp,
                                                Value parallelIV,
                                                int64_t cacheBytes,
                                                int numThreads,
                                                bool isParallel,
                                                int64_t l1CacheBytes = 0) {
    using namespace mlir;
    OMPCostModelResult::Nest nest;
    if (!forOp) return nest;

    // Statistics gathered here represent a single invocation of `forOp`.
    // Repetitions from outer convergence loops scale the `entries` count rather
    // than inflating single-pass workload, preventing double-counting of time steps.
    Operation *regionStop = forOp->getParentOp();

    // Associate innermost loops with their respective memory accesses and arithmetic operations
    llvm::MapVector<Operation *, SmallVector<Operation *>> accessesByLoop;
    llvm::MapVector<Operation *, SmallVector<std::pair<Operation *, int64_t>>>
        flopOpsByLoop;

    bool ok = true;
    forOp->walk<WalkOrder::PreOrder>([&](Operation *bodyOp) -> WalkResult {
        if (bodyOp != forOp.getOperation() &&
            isa<dhir::ReplicateOp, dhir::ConvergeOp, dhir::TaskOp,
                dhir::ScheduleOp>(bodyOp))
            return WalkResult::skip();
        affine::AffineForOp loop = innermostLoop(bodyOp);
        if (accessedMemref(bodyOp)) {
            if (loop) accessesByLoop[loop.getOperation()].push_back(bodyOp);
        }
        auto fw = flopWeightChecked(bodyOp);
        if (!fw) {
            ok = false;
            return WalkResult::advance();
        }
        if (*fw) {
            int64_t trips = ompEnclosingTrips(bodyOp, regionStop, ok);
            int64_t weighted = 0;
            if (!checkedMulNonNegative(*fw, trips, weighted)) {
                ok = false;
                return WalkResult::advance();
            }
            int64_t total = 0;
            if (!checkedAddNonNegative(nest.totalFlops, weighted, total)) {
                ok = false;
                return WalkResult::advance();
            }
            nest.totalFlops = total;
            if (loop) {
                flopOpsByLoop[loop.getOperation()].push_back({bodyOp, weighted});
            }
        }
        return WalkResult::advance();
    });
    nest.exact = ok;

    // Classify innermost loop FLOPs across regimes: strided-DRAM, cache-resident strided,
    // or contiguous. Cache thresholds are passed as parameters to decouple analysis from the host
    // build environment and support cross-target architectural modeling.
    int64_t effectiveL1CacheBytes = l1CacheBytes;
    for (auto &entry : accessesByLoop) {
        auto loop = cast<affine::AffineForOp>(entry.first);
        bool anyStrided = false;
        SmallVector<Operation *> stridedOps;
        int64_t nestStridedFootprint = 0;
        int64_t loopWorkingSet = 0;

        // Cache retention depends on the cumulative working set of the entire loop nest,
        // rather than individual operands in isolation. For instance, a strided column buffer
        // stays cache-resident only if co-allocated arrays do not displace it. Footprints are
        // merged per memref to unify multiple accesses targeting identical buffers.
        int64_t stridedAccesses = 0;
        int64_t stridedElementBytes = 0;
        llvm::MapVector<Value, SmallVector<Operation *>> allByMemref;
        for (Operation *access : entry.second) {
            if (Value mref = accessedMemref(access))
                allByMemref[mref].push_back(access);
            if (classifyAccess(access, loop.getInductionVar()) == StrideClass::Strided) {
                anyStrided = true;
                stridedOps.push_back(access);
                // Tracks cumulative access frequency, determining whether an operand undergoes
                // repetitive reuse or is streamed only once from memory.
                int64_t trips = ompEnclosingTrips(access, regionStop, ok);
                if (!checkedAddNonNegative(stridedAccesses, trips, stridedAccesses))
                    nest.exact = false;
                if (!stridedElementBytes)
                    stridedElementBytes = elementBytes(accessedMemref(access));
            }
        }
        for (auto &mEntry : allByMemref) {
            auto bytes = ompRegionBytes(mEntry.second, reuseWindowDepth(loop));
            if (!bytes || !checkedAddNonNegative(loopWorkingSet, *bytes,
                                                 loopWorkingSet)) {
                nest.exact = false;
                continue;
            }
        }
        // Regime boundaries are governed strictly by loops executing strided operations;
        // reported working sets reflect only these decisive scopes. Incorporating unrelated
        // loops (e.g. initialization passes over matrix C in gemm) would artificially inflate
        // the working set beyond what the active computational kernel actually contends with.
        if (anyStrided)
            nest.workingSetBytes = std::max(nest.workingSetBytes, loopWorkingSet);

        if (anyStrided) {
            llvm::MapVector<Value, SmallVector<Operation *>> stridedByMemref;
            for (Operation *op : stridedOps) {
                Value mref = accessedMemref(op);
                if (mref) stridedByMemref[mref].push_back(op);
            }
            for (auto &mEntry : stridedByMemref) {
                auto bytes = ompRegionBytes(mEntry.second, reuseWindowDepth(loop));
                if (!bytes || !checkedAddNonNegative(nestStridedFootprint, *bytes,
                                                     nestStridedFootprint)) {
                    nest.exact = false;
                    continue;
                }
            }
            if (!checkedAddNonNegative(nest.stridedFootprintBytes,
                                       nestStridedFootprint,
                                       nest.stridedFootprintBytes))
                nest.exact = false;
            nest.isCacheResidentStrided = nest.isCacheResidentStrided ||
                (nestStridedFootprint > 0 &&
                 nestStridedFootprint <= effectiveL1CacheBytes);
        }

        // Trace SSA definitions for each arithmetic op to avoid penalizing entire mixed loops.
        // A FLOP is labeled strided only if an upstream dependency stems from a strided memory load;
        // unaffected computations retain their contiguous throughput classification.
        auto classifyFlop = [&](Operation *flop, Value iv) {
            SmallPtrSet<Operation *, 16> visiting;
            bool sawUnit = false;
            bool sawStrided = false;
            std::function<void(Value)> trace = [&](Value value) {
                Operation *def = value.getDefiningOp();
                if (!def || !visiting.insert(def).second) return;
                if (isAffineMemoryOp(def)) {
                    switch (classifyAccess(def, iv)) {
                    case StrideClass::Strided: sawStrided = true; break;
                    case StrideClass::UnitStride: sawUnit = true; break;
                    case StrideClass::Invariant: break;
                    }
                    visiting.erase(def);
                    return;
                }
                for (Value operand : def->getOperands()) trace(operand);
                visiting.erase(def);
            };
            for (Value operand : flop->getOperands()) trace(operand);
            if (sawStrided) return StrideClass::Strided;
            if (sawUnit) return StrideClass::UnitStride;
            return StrideClass::Invariant;
        };

        // Cache residency benefits manifest only when data is revisited across iterations.
        // A strided buffer accessed exactly once incurs compulsory DRAM cold-miss latency regardless
        // of whether its raw size fits within cache limits (e.g., transposed matrix traversal in mvt
        // visits each element once, streaming cold lines from memory even if total capacity fits).
        // Verifying actual re-traversal prevents misclassifying cold streaming traffic as cache hits.
        int64_t stridedElements = stridedElementBytes > 0
                                      ? nestStridedFootprint / stridedElementBytes
                                      : 0;
        bool reswept = stridedElements > 0 &&
                       stridedAccesses >= 2 * stridedElements;
        bool l1Resident = anyStrided && nestStridedFootprint > 0 &&
                          nestStridedFootprint <= effectiveL1CacheBytes;
        bool llcResident = anyStrided && reswept && !l1Resident && cacheBytes > 0 &&
                           loopWorkingSet > 0 && loopWorkingSet <= cacheBytes;
        nest.isLLCResidentStrided = nest.isLLCResidentStrided || llcResident;
        for (auto &flop : flopOpsByLoop.lookup(entry.first)) {
            StrideClass cls = classifyFlop(flop.first, loop.getInductionVar());
            if (cls == StrideClass::Strided) {
                int64_t updated = 0;
                if (l1Resident) {
                    if (!checkedAddNonNegative(nest.inCacheStridedFlops,
                                               flop.second, updated)) {
                        nest.exact = false;
                        continue;
                    }
                    nest.inCacheStridedFlops = updated;
                } else if (llcResident) {
                    if (!checkedAddNonNegative(nest.llcStridedFlops,
                                               flop.second, updated)) {
                        nest.exact = false;
                        continue;
                    }
                    nest.llcStridedFlops = updated;
                } else {
                    if (!checkedAddNonNegative(nest.stridedFlops, flop.second,
                                               updated)) {
                        nest.exact = false;
                        continue;
                    }
                    nest.stridedFlops = updated;
                }
            } else {
                int64_t updated = 0;
                if (!checkedAddNonNegative(nest.contiguousFlops, flop.second,
                                           updated)) {
                    nest.exact = false;
                    continue;
                }
                nest.contiguousFlops = updated;
            }
        }
    }

    // Floating-point operations located outside innermost loops fall back to contiguous categorization
    int64_t accountedFlops = 0;
    bool accounted = checkedAddNonNegative(accountedFlops, nest.stridedFlops,
                                           accountedFlops);
    accounted = accounted &&
                checkedAddNonNegative(accountedFlops,
                                      nest.inCacheStridedFlops,
                                      accountedFlops);
    accounted = accounted &&
                checkedAddNonNegative(accountedFlops, nest.llcStridedFlops,
                                      accountedFlops);
    accounted = accounted &&
                checkedAddNonNegative(accountedFlops, nest.contiguousFlops,
                                      accountedFlops);
    if (!accounted) {
        nest.exact = false;
    } else if (accountedFlops < nest.totalFlops) {
        int64_t missing = nest.totalFlops - accountedFlops;
        int64_t updated = 0;
        if (!checkedAddNonNegative(nest.contiguousFlops, missing, updated))
            nest.exact = false;
        else
            nest.contiguousFlops = updated;
    }

    // Partitioned: memory operations indexed by parallelIV (thread-local partitions)
    // Broadcast:   memory accesses invariant to parallelIV (shared across worker threads)
    llvm::MapVector<Value, SmallVector<Operation *>> partitioned, broadcast;

    // Segregate memory accesses based on dependency on the parallel induction variable
    forOp->walk<WalkOrder::PreOrder>([&](Operation *bodyOp) -> WalkResult {
        if (bodyOp != forOp.getOperation() &&
            isa<dhir::ReplicateOp, dhir::ConvergeOp, dhir::TaskOp,
                dhir::ScheduleOp>(bodyOp))
            return WalkResult::skip();
        Value memref = accessedMemref(bodyOp);
        if (!memref || !isAffineMemoryOp(bodyOp)) return WalkResult::advance();
        affine::MemRefAccess access(bodyOp);
        affine::AffineValueMap map;
        access.getAccessMap(&map);
        map.composeSimplifyAndCanonicalize();
        bool isFunctionOfIV = !parallelIV ? false :
            llvm::any_of(llvm::seq(0u, map.getNumResults()),
                         [&](unsigned i) { return map.isFunctionOf(i, parallelIV); });
        if (isFunctionOfIV) partitioned[memref].push_back(bodyOp);
        else broadcast[memref].push_back(bodyOp);
        return WalkResult::advance();
    });

    // Stores to unallocated cache lines incur two bus transactions: a read-for-ownership
    // fetch upon cache miss followed by writeback upon eviction. Treating writes as single
    // transfers underestimates write-heavy kernels (e.g. add2d) relative to read-dominated
    // benchmarks (like stream6), biasing bandwidth projections across disparate workloads.
    // Cache capacity checks consider net buffer size, while bus volume tracks bidirectional transfers.
    auto groupBytes = [](ArrayRef<Operation *> accesses, int64_t &footprint,
                         int64_t &traffic) {
        auto bytes = ompRegionBytes(accesses, /*loopDepth=*/0);
        if (!bytes) return false;
        footprint = *bytes;
        bool written = llvm::any_of(accesses, [](Operation *op) {
            return isa<affine::AffineStoreOp, affine::AffineVectorStoreOp>(op);
        });
        traffic = *bytes;
        return !written || checkedMulNonNegative(*bytes, 2, traffic);
    };

    int64_t footprintBytes = 0;
    for (auto &entry : partitioned) {
        int64_t footprint = 0, traffic = 0;
        if (!groupBytes(entry.second, footprint, traffic) ||
            !checkedAddNonNegative(nest.partitionedBytes, traffic,
                                   nest.partitionedBytes) ||
            !checkedAddNonNegative(footprintBytes, footprint, footprintBytes))
            nest.exact = false;
    }
    int64_t bcBytes = 0;
    for (auto &entry : broadcast) {
        int64_t footprint = 0, traffic = 0;
        if (!groupBytes(entry.second, footprint, traffic) ||
            !checkedAddNonNegative(bcBytes, traffic, bcBytes) ||
            !checkedAddNonNegative(nest.broadcastBytes, traffic,
                                   nest.broadcastBytes) ||
            !checkedAddNonNegative(footprintBytes, footprint, footprintBytes))
            nest.exact = false;
    }

    nest.inCache = (cacheBytes > 0 && footprintBytes <= cacheBytes);
    int64_t activeWorkers = ompActiveWorkers(forOp, numThreads);
    // The shared LLC holds both thread-private partitions and invariant broadcast buffers.
    // When aggregate footprints exceed cache capacity, thread contention forces redundant,
    // independent DRAM fetches across active cores.
    nest.broadcastMultiplier = (!isParallel || bcBytes == 0 || nest.inCache)
                                   ? 1 : activeWorkers;
    int64_t scaledBroadcast = 0;
    if (!checkedMulNonNegative(nest.broadcastMultiplier, bcBytes,
                              scaledBroadcast) ||
        !checkedAddNonNegative(nest.partitionedBytes, scaledBroadcast,
                               nest.totalBytes))
        nest.exact = false;
    int64_t workers = isParallel ? std::max<int64_t>(1, activeWorkers) : 1;
    nest.threadFlops = nest.totalFlops / workers;
    if (isParallel && nest.totalFlops % workers != 0)
        ++nest.threadFlops;
    nest.isParallel = isParallel;
    return nest;
}

/// Derives cumulative invocation multipliers from surrounding static dhir.converge loops.
/// This corresponds to the `entries` metric, representing how frequently a parallel region
/// is entered during execution.
inline int64_t dhirEntriesChecked(Operation *op, bool &ok) {
    int64_t prod = 1;
    for (Operation *p = op->getParentOp(); p; p = p->getParentOp()) {
        if (auto converge = dyn_cast<dhir::ConvergeOp>(p)) {
            // All intermediate affine loops between the stage and this converge point multiply
            // the activation count. Inspecting the full ancestor chain correctly captures nested
            // temporal tiles without erroneously multiplying disjoint sibling stages.
            bool foundLoop = false;
            for (Operation *q = op->getParentOp(); q && q != converge.getOperation();
                 q = q->getParentOp()) {
                if (auto forOp = dyn_cast<affine::AffineForOp>(q)) {
                    foundLoop = true;
                    auto trip = affine::getConstantTripCount(forOp);
                    if (!trip || *trip > uint64_t(std::numeric_limits<int64_t>::max()) ||
                        !checkedMulNonNegative(prod, int64_t(*trip), prod)) {
                        ok = false;
                        return std::numeric_limits<int64_t>::max();
                    }
                }
            }
            if (!foundLoop) {
                affine::AffineForOp controllingLoop;
                for (Operation &inner : converge.getBody().front())
                    if (auto forOp = dyn_cast<affine::AffineForOp>(&inner)) {
                        if (controllingLoop) {
                            ok = false; // Cannot determine unambiguous converge loop structure
                            return prod;
                        }
                        controllingLoop = forOp;
                    }
                if (!controllingLoop) {
                    ok = false;
                    return prod;
                }
                auto trip = affine::getConstantTripCount(controllingLoop);
                if (!trip || *trip > uint64_t(std::numeric_limits<int64_t>::max()) ||
                    !checkedMulNonNegative(prod, int64_t(*trip), prod)) {
                    ok = false;
                    return std::numeric_limits<int64_t>::max();
                }
            }
        }
    }
    return prod;
}

inline int64_t dhirEntries(Operation *op) {
    bool ok = true;
    return dhirEntriesChecked(op, ok);
}

/// Multiplies per-activation execution metrics by total invocation count (`entries`).
///
/// Computational operations scale linearly across all invocations.
/// Conversely, memory traffic scales conditionally: datasets that fit within the LLC
/// incur compulsory cold misses on the initial step and remain cache-resident thereafter,
/// avoiding redundant bus traffic on subsequent iterations (e.g. iterative stencils like
/// jacobi stay resident in cache). Only working sets exceeding LLC capacity reload from DRAM
/// across successive entries.
inline bool scaleOMPNestMetrics(OMPCostModelResult::Nest &nest,
                                int64_t entries) {
    if (entries < 0) return false;
    auto scale = [entries](int64_t &value) {
        int64_t scaled = 0;
        if (!checkedMulNonNegative(value, entries, scaled)) return false;
        value = scaled;
        return true;
    };
    if (!scale(nest.totalFlops) || !scale(nest.threadFlops) ||
        !scale(nest.stridedFlops) || !scale(nest.inCacheStridedFlops) ||
        !scale(nest.llcStridedFlops) || !scale(nest.contiguousFlops))
        return false;
    if (!nest.inCache &&
        (!scale(nest.partitionedBytes) || !scale(nest.broadcastBytes) ||
         !scale(nest.totalBytes)))
        return false;
    return true;
}

/// Evaluates the OpenMP-oriented performance model over DHIR-transformed IR.
/// Expects `func` following ConvertAffineToDhirPass execution.
/// Analyzes structural patterns within schedule bodies:
///   dhir.replicate { affine.for ... }          — Parallel region (omp.parallel team)
///   dhir.converge { affine.for T { ... } }     — Sequential temporal loop, scaling
///     enclosed replicates by T entries
inline OMPCostModelResult computeOMPCostModel(func::FuncOp func,
                                              int64_t lastLevelCacheBytes,
                                              int numThreads,
                                              int64_t l1CacheBytes) {
    OMPCostModelResult result;

    if (l1CacheBytes <= 0 || lastLevelCacheBytes <= 0) {
        result.valid = false;
        result.reason = "cache capacities must be supplied by the target "
                        "configuration, not probed from the compiling host";
        return result;
    }
    if (!func) {
        result.valid = false;
        result.reason = "null function passed to OpenMP cost model";
        return result;
    }
    if (numThreads <= 0) {
        result.valid = false;
        result.reason = "OpenMP thread count must be positive";
        return result;
    }

    auto invalidate = [&](StringRef why) {
        if (result.valid) result.reason = why.str();
        result.valid = false;
    };

    auto appendNest = [&](OMPCostModelResult::Nest n, Operation *container,
                          StringRef kind, bool isParallel) {
        bool entriesOk = true;
        n.entries = dhirEntriesChecked(container, entriesOk);
        n.kind = kind.str();
        if (!entriesOk || !n.exact) {
            invalidate(!entriesOk ? "unsupported or overflowing converge entry count"
                                  : "unable to compute an exact OpenMP byte/work region");
            return;
        }
        if (!scaleOMPNestMetrics(n, n.entries)) {
            invalidate("OpenMP FLOP count overflow");
            return;
        }
        result.nests.push_back(std::move(n));
    };

    std::function<void(Block &)> analyzeBlock;
    std::function<void(Operation &)> analyzeOp;
    analyzeBlock = [&](Block &block) {
        for (Operation &op : block) analyzeOp(op);
    };
    analyzeOp = [&](Operation &op) {
        if (isa<dhir::YieldOp, func::ReturnOp>(&op)) return;

        if (auto schedule = dyn_cast<dhir::ScheduleOp>(&op)) {
            for (Block &nested : schedule.getBody()) analyzeBlock(nested);
            return;
        }

        if (auto replicate = dyn_cast<dhir::ReplicateOp>(&op)) {
            bool foundLoop = false;
            for (Operation &inner : replicate.getBody().front()) {
                if (auto forOp = dyn_cast<affine::AffineForOp>(&inner)) {
                    foundLoop = true;
                    auto n = ompAnalyzeLoop(forOp, forOp.getInductionVar(),
                                            lastLevelCacheBytes, numThreads, true,
                                            l1CacheBytes);
                    appendNest(std::move(n), replicate.getOperation(),
                               "replicate", true);
                } else if (isa<dhir::ReplicateOp, dhir::ConvergeOp,
                               dhir::TaskOp, dhir::ScheduleOp>(&inner)) {
                    foundLoop = true;
                    analyzeOp(inner);
                } else if (!isa<dhir::YieldOp>(&inner)) {
                    invalidate("unsupported non-loop operation in dhir.replicate");
                }
            }
            if (!foundLoop) invalidate("dhir.replicate has no direct affine loop");
            return;
        }

        if (auto converge = dyn_cast<dhir::ConvergeOp>(&op)) {
            bool foundLoop = false;
            for (Operation &inner : converge.getBody().front()) {
                auto convergeFor = dyn_cast<affine::AffineForOp>(&inner);
                if (!convergeFor) {
                    if (isa<dhir::ReplicateOp, dhir::ConvergeOp,
                            dhir::TaskOp, dhir::ScheduleOp>(&inner)) {
                        analyzeOp(inner);
                    } else if (!isa<dhir::YieldOp>(&inner)) {
                        invalidate("unsupported non-loop operation in dhir.converge");
                    }
                    continue;
                }
                foundLoop = true;
                bool foundStage = false;
                bool unsupportedScalar = false;
                std::function<void(Operation &)> findStages;
                findStages = [&](Operation &candidate) {
                    if (isa<dhir::YieldOp>(&candidate)) return;
                    if (isa<dhir::ReplicateOp, dhir::ConvergeOp,
                            dhir::TaskOp, dhir::ScheduleOp>(&candidate)) {
                        foundStage = true;
                        analyzeOp(candidate);
                        return;
                    }
                    if (isa<affine::AffineForOp>(&candidate)) {
                        for (Operation &nested : candidate.getRegion(0).front())
                            findStages(nested);
                        return;
                    }
                    // Reject silent omission of scalar operations situated directly inside
                    // a converge block alongside parallel child stages.
                    if (flopWeightChecked(&candidate).value_or(0) != 0 ||
                        accessedMemref(&candidate))
                        unsupportedScalar = true;
                };
                for (Operation &nested : convergeFor.getBody()->getOperations())
                    findStages(nested);

                if (unsupportedScalar && foundStage) {
                    invalidate("mixed serial and nested parallel work in dhir.converge");
                } else if (!foundStage) {
                    // Converge loops lacking nested parallel constructs constitute purely sequential
                    // execution; their trip count directly scales the workload rather than entry frequency.
                    auto n = ompAnalyzeLoop(convergeFor, Value(),
                                            lastLevelCacheBytes, 1, false,
                                            l1CacheBytes);
                    n.kind = "converge";
                    n.entries = 1;
                    if (!n.exact || !scaleOMPNestMetrics(n, 1))
                        invalidate("unable to compute an exact converge region");
                    else
                        result.nests.push_back(std::move(n));
                }
            }
            if (!foundLoop) invalidate("dhir.converge has no controlling affine loop");
            return;
        }

        if (auto task = dyn_cast<dhir::TaskOp>(&op)) {
            bool foundLoop = false;
            for (Operation &inner : task.getRegion().front()) {
                if (auto forOp = dyn_cast<affine::AffineForOp>(&inner)) {
                    foundLoop = true;
                    auto n = ompAnalyzeLoop(forOp, Value(),
                                            lastLevelCacheBytes, 1, false,
                                            l1CacheBytes);
                    appendNest(std::move(n), task.getOperation(), "task", false);
                } else if (isa<dhir::ReplicateOp, dhir::ConvergeOp,
                               dhir::TaskOp, dhir::ScheduleOp>(&inner)) {
                    foundLoop = true;
                    analyzeOp(inner);
                } else if (!isa<dhir::YieldOp>(&inner)) {
                    invalidate("unsupported non-loop operation in dhir.task");
                }
            }
            if (!foundLoop) invalidate("dhir.task has no direct affine loop");
            return;
        }

        if (auto forOp = dyn_cast<affine::AffineForOp>(&op)) {
            auto n = ompAnalyzeLoop(forOp, Value(), lastLevelCacheBytes, 1, false,
                                    l1CacheBytes);
            n.kind = "serial";
            n.entries = 1;
            if (!n.exact || !scaleOMPNestMetrics(n, 1))
                invalidate("unable to compute an exact serial region");
            else
                result.nests.push_back(std::move(n));
        }
    };

    for (Block &block : func.getBody()) analyzeBlock(block);

    if (result.nests.empty()) {
        invalidate("no analyzable loops found in DHIR schedule body");
    }
    return result;
}

inline void OMPCostModelResult::print(raw_ostream &os, StringRef label,
                                      const MachineModel *machine) const {
    if (!valid) {
        os << "OMPCOSTMODEL kernel=" << label << " status=INVALID reason=\""
           << reason << "\"\n";
        return;
    }
    int64_t totalFlops = this->totalFlops();
    int64_t totalBytes = this->totalBytes();
    int64_t totalEntries = this->totalEntries();
    for (auto &n : nests) {
        os << "OMPCOSTMODEL_NEST kernel=" << label
           << " kind=" << n.kind
           << " flops=" << n.totalFlops
           << " thread_flops=" << n.threadFlops
           << " part_bytes=" << n.partitionedBytes
           << " bcast_bytes=" << n.broadcastBytes
           << " mult=" << n.broadcastMultiplier
           << " total_bytes=" << n.totalBytes
           << " entries=" << n.entries
           << " in_cache=" << (n.inCache ? 1 : 0)
           << " parallel=" << (n.isParallel ? 1 : 0)
           << " strided=" << n.stridedFlops
           << " in_cache_strided=" << n.inCacheStridedFlops
           << " llc_strided=" << n.llcStridedFlops
           << " strided_footprint_bytes=" << n.stridedFootprintBytes
           << " working_set_bytes=" << n.workingSetBytes
           << " contiguous=" << n.contiguousFlops;
        if (machine && machine->calibrated())
            os << " seconds=" << llvm::format("%.9g",
                                              machineNestSeconds(n, *machine));
        os << "\n";
    }
    ClassFlops all = classFlops(), ser = classFlops(/*onlySerial=*/true);
    long double denom = all.total();
    auto frac = [&](long double value) {
        return denom > 0 ? double(value / denom) : 0.0;
    };
    int64_t threadFlops = this->totalThreadFlops();
    os << "OMPCOSTMODEL kernel=" << label << " status=OK"
       << " flops=" << totalFlops
       << " thread_flops=" << threadFlops
       << " total_bytes=" << totalBytes
       << " entries=" << totalEntries
       << " strided_flop_fraction="
       << llvm::format("%.6f", frac(all.dram + all.l1 + all.llc))
       << " in_cache_strided_flop_fraction=" << llvm::format("%.6f", frac(all.l1))
       << " llc_strided_flop_fraction=" << llvm::format("%.6f", frac(all.llc))
       << " dram_strided_flop_fraction=" << llvm::format("%.6f", frac(all.dram))
       // Computations remaining unparallelized execute on a single core; the model
       // evaluates them against single-thread regime throughput rather than multi-threaded team rates.
       << " serial_flop_fraction=" << llvm::format("%.6f", frac(ser.total()))
       << " serial_in_cache_strided_flop_fraction="
       << llvm::format("%.6f", frac(ser.l1))
       << " serial_llc_strided_flop_fraction=" << llvm::format("%.6f", frac(ser.llc))
       << " serial_dram_strided_flop_fraction="
       << llvm::format("%.6f", frac(ser.dram))
       << " serial_contiguous_flop_fraction="
       << llvm::format("%.6f", frac(ser.contiguous))
       << " nests=" << nests.size()
       << " parallel_nests=" << parallelNests();
    // Against calibrated target profiles, the output provides concrete time predictions
    // mirroring calibrate.py validation formulas, enabling in-compiler candidate ranking.
    if (machine) {
        if (auto seconds = machineSeconds(*this, *machine))
            os << " predicted_seconds=" << llvm::format("%.9g", *seconds);
        else
            os << " predicted_seconds=uncalibrated";
    }
    os << "\n";
}

} // namespace dhir
} // namespace mlir


#ifndef DHIR_LOCAL_WORKSHARE_H
#define DHIR_LOCAL_WORKSHARE_H

#include "includes/dhirOps.h"
#include "includes/utils.h"
#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/ADT/MapVector.h"
#include <cstdint>
#include <optional>

namespace mlir::dhir {
namespace local_workshare {

// Transforms local thread scheduling following the resolution of MPI ownership
// and index rebasing. For 3-D rectangular pointwise loop nests, this pass
// distributes outer row iterations across threads while preserving contiguous
// inner column loops for SIMD vectorization, replacing linearized coordinate
// decomposition and eliminating integer division/modulo overhead. Buffer
// independence is not inferred solely from distinct SSA values; dynamic
// disambiguation guards are synthesized to verify storage disjointness at runtime
// prior to executing the optimized schedule.

inline std::optional<int64_t> constant(Value v) {
  auto op = v.getDefiningOp<arith::ConstantOp>();
  if (!op) return std::nullopt;
  auto a = dyn_cast<IntegerAttr>(op.getValue());
  if (!a || a.getValue().getBitWidth() > 64) return std::nullopt;
  return a.getValue().getSExtValue();
}

inline bool outside(Value v, Operation *root) {
  if (Operation *def = v.getDefiningOp()) return !root->isAncestor(def);
  return !root->isAncestor(cast<BlockArgument>(v).getOwner()->getParentOp());
}

// Affine lowering often introduces side-effect-free definitions between loop
// headers. Hoist only speculatable operations whose transitive operands are
// invariant with respect to all induction variables within the enclosing loop nest.
inline bool canHoist(Value v, Operation *root) {
  if (outside(v, root)) return true;
  Operation *def = v.getDefiningOp();
  if (!def || def->getNumRegions() || !isPure(def)) return false;
  return llvm::all_of(def->getOperands(), [&](Value x) {
    return canHoist(x, root);
  });
}

inline Value hoist(Value v, Operation *root, IRRewriter &b, IRMapping &map) {
  if (outside(v, root)) return v;
  if (map.contains(v)) return map.lookup(v);
  Operation *def = v.getDefiningOp();
  for (Value x : def->getOperands()) {
    Value h = hoist(x, root, b, map);
    if (h != x) map.map(x, h);
  }
  b.clone(*def, map);
  return map.lookup(v);
}

// Matches loop bodies containing only side-effect-free header computations
// followed by exactly one nested loop.
inline scf::ForOp innerLoop(Block *body) {
  scf::ForOp result;
  for (Operation &op : body->without_terminator()) {
    if (auto loop = dyn_cast<scf::ForOp>(op)) {
      if (result || loop.getNumResults()) return {};
      result = loop;
    } else if (result || op.getNumRegions() || !isPure(&op)) {
      return {};
    }
  }
  return result;
}

struct Nest {
  scf::ParallelOp outer;
  scf::ForOp row, column;
  SmallVector<Value> reads, writes;
};

inline std::optional<Nest> analyze(scf::ParallelOp outer) {
  auto task = outer->getParentOfType<dhir::TaskOp>();
  if (outer.getNumLoops() != 1 || outer.getNumResults() ||
      constant(outer.getStep()[0]) != 1 || !task) return std::nullopt;
  auto target = dyn_cast<TargetDeviceSpecAttr>(task.getTarget());
  auto gpus = target ? dyn_cast_or_null<IntegerAttr>(getDeviceAttribute(target, "gpu_count")) : IntegerAttr();
  if (!gpus || gpus.getInt() != 0) return std::nullopt;
  auto row = innerLoop(outer.getBody());
  auto col = row ? innerLoop(row.getBody()) : scf::ForOp();
  if (!col || constant(row.getStep()) != 1 || constant(col.getStep()) != 1)
    return std::nullopt;
  for (Value v : {row.getLowerBound(), row.getUpperBound(), row.getStep(),
                  col.getLowerBound(), col.getUpperBound(), col.getStep()})
    if (!canHoist(v, outer)) return std::nullopt;

  llvm::SetVector<Value> reads, writes;
  SmallVector<memref::StoreOp> stores;
  bool legal = true;
  outer.getBody()->walk([&](Operation *op) {
    if (auto st = dyn_cast<memref::StoreOp>(op)) {
      writes.insert(st.getMemRef()); stores.push_back(st);
    } else if (auto ld = dyn_cast<memref::LoadOp>(op)) {
      reads.insert(ld.getMemRef());
    } else if (op->getNumRegions()) {
      if (!isa<scf::ForOp, scf::IfOp>(op)) legal = false;
      // Arbitrary nested loops and reductions violate the canonical 3-D nest structure.
      if (auto f = dyn_cast<scf::ForOp>(op))
        if (f != row && f != col) legal = false;
    } else if (!isMemoryEffectFree(op)) legal = false;
  });
  if (!legal || stores.empty()) return std::nullopt;
  SmallVector<Value> ivs{outer.getInductionVars()[0], row.getInductionVar(),
                         col.getInductionVar()};
  for (auto st : stores) {
    if (st.getIndices().size() != 3 || st.getIndices()[2] != ivs[2])
      return std::nullopt;
    for (Value iv : ivs)
      if (llvm::count(st.getIndices(), iv) != 1) return std::nullopt;
    // Individual store injectivity is insufficient to ensure race-free execution:
    // multiple stores targeting the same memory reference must share identical
    // affine indexing maps. Inter-buffer aliasing across distinct memrefs is
    // subsequently validated via dynamic runtime guards.
    for (auto other : stores)
      if (st.getMemRef() == other.getMemRef() &&
          !llvm::equal(st.getIndices(), other.getIndices())) return std::nullopt;
  }
  for (Value w : writes) if (reads.contains(w)) return std::nullopt;
  for (Value v : llvm::concat<const Value>(reads.getArrayRef(), writes.getArrayRef())) {
    auto t = dyn_cast<MemRefType>(v.getType());
    if (!t || t.getRank() != 3 ||
        !t.getElementType().isIntOrFloat() ||
        !outside(v, outer))
      return std::nullopt;
    // Ensure element bitwidth aligns precisely with ABI allocation size to avoid
    // misinterpreting padded or non-standard scalar types (e.g., i24 or f80).
    unsigned bits = t.getElementType().getIntOrFloatBitWidth();
    if (bits != 8 && bits != 16 && bits != 32 && bits != 64) return std::nullopt;
    if (Attribute space = t.getMemorySpace()) {
      auto integer = dyn_cast<IntegerAttr>(space);
      if (!integer || integer.getInt() != 0) return std::nullopt;
    }
    SmallVector<int64_t> strides;
    int64_t offset;
    if (failed(t.getStridesAndOffset(strides, offset))) return std::nullopt;
  }
  return Nest{outer, row, col, reads.takeVector(), writes.takeVector()};
}

// Synthesizes half-open byte interval bounds accounting for base offsets and
// strides to detect partial overlaps arising from subviews, type casts, or
// aliased function arguments. Non-canonical layouts or arithmetic overflow
// during address and extent computation conservatively trigger fallback to
// the original schedule.
struct Guards {
  IRRewriter &b;
  Location loc;
  Value valid, zero, one;
  Guards(IRRewriter &b, Location loc) : b(b), loc(loc) {
    valid = b.create<arith::ConstantIntOp>(loc, 1, 1);
    zero = b.create<arith::ConstantIntOp>(loc, 0, 64);
    one = b.create<arith::ConstantIntOp>(loc, 1, 64);
  }
  Value i64(Value v) { return b.create<arith::IndexCastUIOp>(loc, b.getI64Type(), v); }
  Value cmp(arith::CmpIPredicate p, Value a, Value c) {
    return b.create<arith::CmpIOp>(loc, p, a, c);
  }
  void require(Value v) { valid = b.create<arith::AndIOp>(loc, valid, v); }
  Value mul(Value a, Value c) {
    auto x = b.create<arith::MulUIExtendedOp>(loc, a, c);
    require(cmp(arith::CmpIPredicate::eq, x.getHigh(), zero));
    return x.getLow();
  }
  Value add(Value a, Value c) {
    auto x = b.create<arith::AddUIExtendedOp>(loc, a, c);
    Value noOverflow = b.create<arith::XOrIOp>(loc, x.getOverflow(),
        b.create<arith::ConstantIntOp>(loc, 1, 1));
    require(noOverflow);
    return x.getSum();
  }
  std::pair<Value, Value> span(Value v) {
    auto md = b.create<memref::ExtractStridedMetadataOp>(loc, v);
    Value offset = i64(md.getOffset());
    require(cmp(arith::CmpIPredicate::sge, offset, zero));
    Value extent = one;
    for (int d = 2; d >= 0; --d) {
      Value size = i64(md.getSizes()[d]);
      Value stride = i64(md.getStrides()[d]);
      require(cmp(arith::CmpIPredicate::sgt, size, zero));
      require(cmp(arith::CmpIPredicate::sge, stride, extent));
      Value last = b.create<arith::SubIOp>(loc, size, one);
      extent = add(mul(last, stride), extent);
    }
    auto t = cast<MemRefType>(v.getType());
    Value bytes = b.create<arith::ConstantIntOp>(loc,
        t.getElementType().getIntOrFloatBitWidth() / 8, 64);
    Value ptr = i64(b.create<memref::ExtractAlignedPointerAsIndexOp>(loc, v));
    Value lo = add(ptr, mul(offset, bytes));
    Value hi = add(lo, mul(extent, bytes));
    return {lo, hi};
  }
};

// Matches an affine offset expression relative to an atomic base value.
// Reassociation of addition operations across narrowing casts is prohibited,
// as modular arithmetic composed with sign extension violates affine linear
// equivalence. Specifically, an index_cast over an integer addition is treated
// as an atomic base expression to preserve wrapping semantics.
struct Expr { Value base; int64_t offset; };
inline Expr expression(Value v) {
  if (auto c = constant(v)) return {{}, *c};
  if (auto c = v.getDefiningOp<arith::IndexCastOp>()) return {c.getIn(), 0};
  auto base = [](Value v) {
    if (auto c = v.getDefiningOp<arith::IndexCastOp>()) return c.getIn();
    return v;
  };
  if (auto a = v.getDefiningOp<arith::AddIOp>()) {
    if (auto c = constant(a.getRhs())) return {base(a.getLhs()), *c};
    if (auto c = constant(a.getLhs())) return {base(a.getRhs()), *c};
  }
  return {v, 0};
}

inline bool narrowColumnRange(scf::ForOp col) {
  if (constant(col.getLowerBound()) != 0 || constant(col.getStep()) != 1)
    return false;
  if (auto ub = constant(col.getUpperBound())) return *ub >= 0 && *ub <= INT32_MAX;
  Value bound = col.getUpperBound();
  if (auto add = bound.getDefiningOp<arith::AddIOp>()) {
    auto c = constant(add.getRhs());
    if (!c || *c < -1 || *c > 0) return false;
    bound = add.getLhs();
  }
  auto cast = bound.getDefiningOp<arith::IndexCastOp>();
  auto t = cast ? dyn_cast<IntegerType>(cast.getIn().getType()) : IntegerType();
  return t && t.getWidth() <= 32;
}

inline bool columnCastsAreWideEnough(Value v) {
  // The induction variable range proof is established for signed 32-bit indices.
  // Reject narrower intermediate integer types (e.g., index -> i8 -> index)
  // where modular truncation could alter boundary conditions.
  if (auto t = dyn_cast<IntegerType>(v.getType()))
    if (t.getWidth() < 32) return false;
  if (auto cast = v.getDefiningOp<arith::IndexCastOp>())
    return columnCastsAreWideEnough(cast.getIn());
  if (auto add = v.getDefiningOp<arith::AddIOp>())
    return columnCastsAreWideEnough(add.getLhs()) &&
           columnCastsAreWideEnough(add.getRhs());
  return true;
}

inline std::optional<int64_t> columnOffset(Value v, Value iv) {
  if (auto cast = v.getDefiningOp<arith::IndexCastOp>()) v = cast.getIn();
  auto add = v.getDefiningOp<arith::AddIOp>();
  if (!add) return std::nullopt;
  Value base = add.getLhs();
  auto delta = constant(add.getRhs());
  if (!delta) { delta = constant(add.getLhs()); base = add.getRhs(); }
  if (!delta || (*delta != -1 && *delta != 1)) return std::nullopt;
  if (auto cast = base.getDefiningOp<arith::IndexCastOp>()) base = cast.getIn();
  if (base != iv || !columnCastsAreWideEnough(v)) return std::nullopt;
  return delta;
}

inline bool boundaryCondition(Value cond, scf::ForOp col, int64_t delta) {
  auto cmp = cond.getDefiningOp<arith::CmpIOp>();
  if (!cmp || !columnCastsAreWideEnough(cmp.getLhs())) return false;
  Expr lhs = expression(cmp.getLhs()), rhs = expression(cmp.getRhs());
  if (lhs.base != col.getInductionVar() || lhs.offset != 0) return false;
  if (delta == -1)
    return cmp.getPredicate() == arith::CmpIPredicate::sgt &&
           !rhs.base && rhs.offset == 0;
  Expr ub = expression(col.getUpperBound());
  return delta == 1 && cmp.getPredicate() == arith::CmpIPredicate::slt &&
         rhs.base == ub.base && rhs.offset == ub.offset - 1;
}

inline void normalizeColumns(scf::ForOp col, IRRewriter &b) {
  Location loc = col.getLoc();
  bool narrowSafe = narrowColumnRange(col), split = false;
  SmallVector<scf::IfOp> candidates;
  for (Operation &op : col.getBody()->without_terminator())
    if (auto branch = dyn_cast<scf::IfOp>(op)) candidates.push_back(branch);
  for (auto branch : candidates) {
    if (branch.getNumResults() != 1 || !branch.elseBlock()) continue;
    auto ty = dyn_cast<scf::YieldOp>(branch.thenBlock()->getTerminator());
    auto ey = dyn_cast<scf::YieldOp>(branch.elseBlock()->getTerminator());
    auto ld = ty.getOperand(0).getDefiningOp<memref::LoadOp>();
    auto center = ey.getOperand(0).getDefiningOp<memref::LoadOp>();
    if (!ld || !center || center->getBlock() != col.getBody() ||
        ld->getBlock() != branch.thenBlock() ||
        ld.getMemRef() != center.getMemRef() ||
        ld.getIndices().size() != center.getIndices().size() ||
        !branch.elseBlock()->without_terminator().empty()) continue;
    bool pure = true;
    for (Operation &op : branch.thenBlock()->without_terminator())
      if (&op != ld.getOperation() && (op.getNumRegions() || !isPure(&op))) pure = false;
    if (!pure) continue;
    int changed = -1;
    for (unsigned d = 0; d < ld.getIndices().size(); ++d)
      if (ld.getIndices()[d] != center.getIndices()[d]) {
        if (changed != -1) { changed = -2; break; }
        changed = d;
      }
    if (changed < 0) continue;
    b.setInsertionPoint(branch);
    IRMapping map;
    for (Operation &op : branch.thenBlock()->without_terminator())
      if (&op != ld.getOperation()) b.clone(op, map);
    SmallVector<Value> indices(center.getIndices());
    Value neighbor = map.lookupOrDefault(ld.getIndices()[changed]);
    auto delta = columnOffset(ld.getIndices()[changed], col.getInductionVar());
    bool columnNeighbor = narrowSafe && center.getIndices()[changed] == col.getInductionVar() &&
        delta && boundaryCondition(branch.getCondition(), col, *delta);
    if (columnNeighbor) {
      Value offset = b.create<arith::ConstantIndexOp>(loc, *delta);
      neighbor = b.create<arith::AddIOp>(loc, col.getInductionVar(), offset);
    }
    auto select = b.create<arith::SelectOp>(loc, branch.getCondition(), neighbor,
                                           indices[changed]);
    if (columnNeighbor) {
      select->setAttr("dhir.column_neighbor", b.getUnitAttr()); split = true;
    }
    indices[changed] = select;
    Value result = b.create<memref::LoadOp>(loc, ld.getMemRef(), indices);
    b.replaceOp(branch, result);
  }
  // Hoist loop-invariant index and predicate computations—strictly excluding
  // memory access operations—above the inner column loop.
  for (Operation &op : llvm::make_early_inc_range(col.getBody()->without_terminator()))
    if (!op.getNumRegions() && isPure(&op) &&
        llvm::all_of(op.getOperands(), [&](Value v) { return outside(v, col); }))
      op.moveBefore(col);
  if (!split) return;
  b.setInsertionPoint(col);
  Value one = b.create<arith::ConstantIndexOp>(loc, 1);
  Value leftEnd = b.create<arith::MinSIOp>(loc, col.getUpperBound(), one);
  Value last = b.create<arith::SubIOp>(loc, col.getUpperBound(), one);
  Value rightStart = b.create<arith::MaxSIOp>(loc, leftEnd, last);
  SmallVector<Value> lbs{col.getLowerBound(), leftEnd, rightStart};
  SmallVector<Value> ubs{leftEnd, rightStart, col.getUpperBound()};
  for (unsigned part = 0; part < 3; ++part) {
    b.setInsertionPoint(col);
    auto loop = b.create<scf::ForOp>(loc, lbs[part], ubs[part], one);
    IRMapping map; map.map(col.getInductionVar(), loop.getInductionVar());
    b.setInsertionPointToStart(loop.getBody());
    for (Operation &op : col.getBody()->without_terminator()) {
      if (op.hasAttr("dhir.column_neighbor") && part == 1) {
        auto select = cast<arith::SelectOp>(op);
        map.map(select.getResult(), map.lookupOrDefault(select.getTrueValue()));
      } else {
        Operation *cloned = b.clone(op, map);
        cloned->removeAttr("dhir.column_neighbor");
      }
    }
  }
  b.eraseOp(col);
}

inline void transform(Nest n, IRRewriter &b) {
  auto outer = n.outer;
  Location loc = outer.getLoc();
  b.setInsertionPoint(outer);
  IRMapping hm;
  Value rowLB = hoist(n.row.getLowerBound(), outer, b, hm);
  Value rowUB = hoist(n.row.getUpperBound(), outer, b, hm);
  Value colLB = hoist(n.column.getLowerBound(), outer, b, hm);
  Value colUB = hoist(n.column.getUpperBound(), outer, b, hm);
  Value step = b.create<arith::ConstantIndexOp>(loc, 1);
  Guards g(b, loc);
  llvm::MapVector<Value, std::pair<Value, Value>> spans;
  for (Value v : llvm::concat<Value>(n.reads, n.writes))
    if (!spans.count(v)) spans[v] = g.span(v);
  auto disjoint = [&](Value a, Value c) {
    auto x = spans[a], y = spans[c];
    g.require(b.create<arith::OrIOp>(loc,
        g.cmp(arith::CmpIPredicate::ule, x.second, y.first),
        g.cmp(arith::CmpIPredicate::ule, y.second, x.first)));
  };
  for (Value w : n.writes) for (Value r : n.reads) disjoint(w, r);
  for (unsigned i = 0; i < n.writes.size(); ++i)
    for (unsigned j = i + 1; j < n.writes.size(); ++j) disjoint(n.writes[i], n.writes[j]);
  Value safe = g.valid;
  Value points = g.one;
  for (auto bounds : {std::make_pair(outer.getLowerBound()[0], outer.getUpperBound()[0]),
                      std::make_pair(rowLB, rowUB), std::make_pair(colLB, colUB)}) {
    Value extent = b.create<arith::SubIOp>(loc, bounds.second, bounds.first);
    Value count = g.i64(b.create<arith::MaxSIOp>(loc, extent,
        b.create<arith::ConstantIndexOp>(loc, 0)));
    points = g.mul(points, count);
  }
  Value large = g.cmp(arith::CmpIPredicate::uge, points,
      b.create<arith::ConstantIntOp>(loc, 4096, 64));
  // Dynamic extent overflow triggers fallback to the original schedule,
  // guaranteeing semantic preservation without perturbing the iteration domain.
  safe = b.create<arith::AndIOp>(loc, safe, g.valid);
  // For tall, narrow iteration spaces where the outer dimension already provides
  // higher concurrency than the row domain, preserve the existing schedule to
  // prevent concurrency degradation.
  Value rowExtent = b.create<arith::SubIOp>(loc, rowUB, rowLB);
  Value outerExtent = b.create<arith::SubIOp>(loc, outer.getUpperBound()[0],
                                             outer.getLowerBound()[0]);
  safe = b.create<arith::AndIOp>(loc, safe,
      b.create<arith::CmpIOp>(loc, arith::CmpIPredicate::sgt, rowExtent, outerExtent));
  auto guard = b.create<scf::IfOp>(loc, safe, true);
  guard->setAttr("dhir.local_workshare_guard", b.getUnitAttr());
  b.setInsertionPointToStart(guard.elseBlock());
  b.clone(*outer);
  b.setInsertionPointToStart(guard.thenBlock());
  auto sizeGuard = b.create<scf::IfOp>(loc, large, true);
  b.setInsertionPointToStart(sizeGuard.elseBlock());
  auto serial = b.create<scf::ForOp>(loc, outer.getLowerBound()[0],
                                    outer.getUpperBound()[0], step);
  b.setInsertionPointToStart(serial.getBody());
  IRMapping serialMap; serialMap.map(outer.getInductionVars()[0], serial.getInductionVar());
  for (Operation &op : outer.getBody()->without_terminator()) b.clone(op, serialMap);

  b.setInsertionPointToStart(sizeGuard.thenBlock());
  auto rows = b.create<scf::ParallelOp>(loc, ValueRange{rowLB}, ValueRange{rowUB},
                                      ValueRange{step});
  rows->setAttr("dhir.local_rows", b.getUnitAttr());
  b.setInsertionPointToStart(rows.getBody());
  auto layers = b.create<scf::ForOp>(loc, outer.getLowerBound()[0],
                                    outer.getUpperBound()[0], step);
  b.setInsertionPointToStart(layers.getBody());
  IRMapping map;
  map.map(outer.getInductionVars()[0], layers.getInductionVar());
  map.map(n.row.getInductionVar(), rows.getInductionVars()[0]);
  for (Operation &op : outer.getBody()->without_terminator()) {
    if (&op == n.row.getOperation()) break;
    b.clone(op, map);
  }
  scf::ForOp newColumn;
  for (Operation &op : n.row.getBody()->without_terminator()) {
    auto *clone = b.clone(op, map);
    if (&op == n.column.getOperation()) newColumn = cast<scf::ForOp>(clone);
  }
  normalizeColumns(newColumn, b);
  b.eraseOp(outer);
}
} // namespace local_workshare

#define GEN_PASS_DEF_LOCALWORKSHAREPASS
#include "dialect/Passes.h.inc"
struct LocalWorksharePass : impl::LocalWorksharePassBase<LocalWorksharePass> {
  void runOnOperation() override {
    SmallVector<scf::ParallelOp> candidates;
    getOperation()->walk([&](scf::ParallelOp op) { candidates.push_back(op); });
    IRRewriter b(&getContext());
    for (auto op : candidates)
      if (auto nest = local_workshare::analyze(op)) {
        local_workshare::transform(*nest, b);
        getOperation()->setAttr("dhir.local_workshare_optimized", b.getUnitAttr());
      }
  }
};
} // namespace mlir::dhir
#endif

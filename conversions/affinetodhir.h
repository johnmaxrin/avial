#include "mlir/Pass/PassManager.h"
#include "mlir/IR/PatternMatch.h"

#include "includes/dhirDialect.h"
#include "includes/dhirTypes.h"

#include "mlir/Transforms/DialectConversion.h"

#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/Passes.h"

#include "llvm/Support/Casting.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"

#include "includes/dhirDialect.h"
#include "includes/dhirOps.h"
#include "includes/dhirTypes.h"
#include "includes/utils.h"

#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/IR/Builders.h"

#include "mlir/Conversion/Passes.h"

#include "analysis/polyhedralAnalysis.h"
#include "analysis/arrayPartitionAnalysis.h"

#include <string>
#include <functional>

using namespace mlir;
using namespace dhir;

namespace mlir
{
    namespace dhir
    {

#define GEN_PASS_DEF_CONVERTAFFINETODHIRPASS

#include "dialect/Passes.h.inc"

        struct ConvertAffineToDhirPass : public mlir::dhir::impl::ConvertAffineToDhirPassBase<ConvertAffineToDhirPass>
        {
            using ConvertAffineToDhirPassBase::ConvertAffineToDhirPassBase;

            bool isUnitStep(mlir::scf::ForOp loop)
            {
                auto step = loop.getStep().getDefiningOp<mlir::arith::ConstantIndexOp>();
                return step && step.value() == 1;
            }

            bool sameIndices(ValueRange lhs, ValueRange rhs)
            {
                return lhs.size() == rhs.size() &&
                       std::equal(lhs.begin(), lhs.end(), rhs.begin());
            }

            // Checks whether `value` reads the accumulator modified by `store`.
            bool dependsOnAccumulator(Value value, mlir::memref::StoreOp store,
                                      llvm::SmallPtrSetImpl<Operation *> &seen)
            {
                Operation *def = value.getDefiningOp();
                if (!def || !seen.insert(def).second)
                    return false;
                if (auto load = dyn_cast<mlir::memref::LoadOp>(def))
                    if (load.getMemRef() == store.getMemRef() &&
                        sameIndices(load.getIndices(), store.getIndices()))
                        return true;
                for (Value operand : def->getOperands())
                    if (dependsOnAccumulator(operand, store, seen))
                        return true;
                return false;
            }

            bool isAdditiveReadModifyWrite(mlir::memref::StoreOp store)
            {
                Operation *def = store.getValue().getDefiningOp();
                if (!def || !isa<mlir::arith::AddFOp, mlir::arith::AddIOp>(def))
                    return false;
                if (def->getNumOperands() != 2)
                    return false;

                for (unsigned side = 0; side < 2; ++side)
                {
                    auto load = def->getOperand(side)
                                    .getDefiningOp<mlir::memref::LoadOp>();
                    if (!load || load.getMemRef() != store.getMemRef() ||
                        !sameIndices(load.getIndices(), store.getIndices()))
                        continue;

                    // The other operand represents this iteration's contribution. A valid
                    // sum reduction requires it to be independent of the running accumulator.
                    // An update like `a += a * (i+1)` matches the addition shape but forms
                    // an ordered recurrence: initializing remote shards with identity (0)
                    // discards the incoming state they rely on, so the sum of partials
                    // diverges from sequential execution (120 sequentially vs 6 on 2 ranks).
                    llvm::SmallPtrSet<Operation *, 8> seen;
                    if (dependsOnAccumulator(def->getOperand(1 - side), store, seen))
                    {
                        llvm::errs() << "Reduction contribution depends on the "
                                        "accumulator (ordered recurrence); not "
                                        "treating it as a sum\n";
                        continue;
                    }
                    return true;
                }
                return false;
            }

            // A loop whose IV is unused repeats one computation every
            // iteration (e.g. an `iters` convergence loop).  Its iterations
            // address no disjoint data, so partitioning it would make every
            // shard recompute the whole output and the combine would sum the
            // duplicates.  Never select it; let an inner loop carry the
            // parallelism.
            bool isIVInvariantBody(mlir::scf::ForOp loop)
            {
                return loop.getInductionVar().use_empty();
            }

            // SCF lacks the affine dependence test below.  Accept only the
            // common kernel shape: overwrites advance with the IV; other
            // writes must be additive read-modify-write reductions.
            bool isScfLoopIndependent(mlir::scf::ForOp loop)
            {
                if (!loop.getInitArgs().empty() || !isUnitStep(loop))
                    return false;

                if (isIVInvariantBody(loop))
                {
                    llvm::errs() << "SCF loop body is invariant in its IV "
                                    "(repeat loop); not partitioning it\n";
                    return false;
                }

                Value iv = loop.getInductionVar();
                mlir::dhir::ArrayPartitioningAnalysis analysis(loop, iv);
                llvm::SmallVector<mlir::memref::LoadOp> loads;
                llvm::SmallVector<mlir::memref::StoreOp> stores;
                loop.walk([&](mlir::memref::LoadOp load) { loads.push_back(load); });
                loop.walk([&](mlir::memref::StoreOp store) { stores.push_back(store); });

                if (stores.empty())
                    return false;

                for (mlir::memref::StoreOp store : stores)
                {
                    auto storeAccess = analysis.getUnitStrideDimensionAndOffset(store, iv);
                    if (!storeAccess)
                    {
                        if (!isAdditiveReadModifyWrite(store))
                            return false;
                        continue;
                    }
                    if (storeAccess->second != 0)
                        return false;

                    // An in-place load from another iteration's slice is a real
                    // loop-carried dependence, not a stencil input halo.
                    for (mlir::memref::LoadOp load : loads)
                    {
                        if (load.getMemRef() == store.getMemRef())
                        {
                            auto loadAccess =
                                analysis.getUnitStrideDimensionAndOffset(load, iv);
                            if (!loadAccess ||
                                loadAccess->first != storeAccess->first ||
                                loadAccess->second != storeAccess->second)
                                return false;
                            continue;
                        }
                        // Distinct SSA values can still alias the same underlying memory.
                        // A subview or cast does not yield independent storage: with
                        // `V = memref.cast A`, `V[i] = A[i-1] + 1` is a true loop-carried
                        // dependence that naive SSA inequality checks miss entirely.
                        // Because accesses are expressed in differing coordinate frames,
                        // direct index comparison is invalid — refuse partitioning.
                        if (mlir::dhir::viewRoot(load.getMemRef()) ==
                            mlir::dhir::viewRoot(store.getMemRef()))
                        {
                            llvm::errs() << "SCF loop load and store alias the "
                                            "same allocation through a view; not "
                                            "partitioning it\n";
                            return false;
                        }
                    }
                }

                llvm::errs() << "SCF loop is conservatively independent\n";
                return true;
            }

            // A rank-1 (flat) output stored as `IV*coeff + base`, coeff != 1,
            // is a scaled slab: shard [s,e) writes [s*coeff+base, e*coeff+base),
            // but the gather slices the raw [s,e) — wrong bytes.  Not fixable
            // with SUM partialReduce (disjoint overwrites, not adds), so leave
            // such loops unpartitioned (serially correct, like spmv/histo).
            bool hasScaledFlatSlabStore(mlir::affine::AffineForOp loop)
            {
                Value iv = loop.getInductionVar();
                bool scaled = false;
                loop.walk([&](mlir::affine::AffineStoreOp store) {
                    auto memrefTy = dyn_cast<MemRefType>(store.getMemRef().getType());
                    if (!memrefTy || memrefTy.getRank() != 1)
                        return;
                    auto operands = store.getMapOperands();
                    int ivPos = -1;
                    for (int k = 0; k < (int)operands.size(); ++k)
                        if (operands[k] == iv) { ivPos = k; break; }
                    if (ivPos < 0)
                        return;
                    AffineMap map = store.getAffineMap();
                    if (map.getNumResults() != 1)
                        return;
                    AffineExpr expr = map.getResult(0);
                    unsigned numDims = map.getNumDims();
                    AffineExpr ivExpr =
                        (ivPos < (int)numDims)
                            ? getAffineDimExpr(ivPos, loop.getContext())
                            : getAffineSymbolExpr(ivPos - numDims, loop.getContext());
                    std::function<int64_t(AffineExpr, int64_t)> coeff =
                        [&](AffineExpr node, int64_t mult) -> int64_t {
                        if (node == ivExpr)
                            return mult;
                        if (auto bin = dyn_cast<AffineBinaryOpExpr>(node)) {
                            if (bin.getKind() == AffineExprKind::Add)
                                return coeff(bin.getLHS(), mult) +
                                       coeff(bin.getRHS(), mult);
                            if (bin.getKind() == AffineExprKind::Mul) {
                                if (auto rc = dyn_cast<AffineConstantExpr>(bin.getRHS());
                                    rc && bin.getLHS() == ivExpr)
                                    return mult * rc.getValue();
                                if (auto lc = dyn_cast<AffineConstantExpr>(bin.getLHS());
                                    lc && bin.getRHS() == ivExpr)
                                    return mult * lc.getValue();
                            }
                        }
                        return 0;
                    };
                    if (coeff(expr, 1) != 1)
                        scaled = true;
                });
                return scaled;
            }

            bool isStencilLoop(Operation *loop, Value iv,
                               const llvm::SmallVector<llvm::SmallVector<Value>> &insouts)
            {
                mlir::dhir::ArrayPartitioningAnalysis analysis(loop, iv);
                for (Value in : insouts[0])
                {
                    auto info = analysis.analyzeArray(in);
                    if (info.haloLeft > 0 || info.haloRight > 0)
                        return true;
                }
                for (Value out : insouts[1])
                {
                    auto info = analysis.analyzeArray(out);
                    if (info.haloLeft > 0 || info.haloRight > 0)
                        return true;
                }
                return false;
            }

            void wrapScfLoop(mlir::scf::ForOp loop, mlir::OpBuilder &builder,
                             int &repId)
            {
                auto insouts = InsOutsAnalysis::getInsandOut(loop);
                bool isStencil =
                    isStencilLoop(loop, loop.getInductionVar(), insouts);

                // A shard nested in serial control flow may feed the next
                // iteration; force a broadcast so its writes stay ordered.
                bool forceBroadcast =
                    loop->getParentOfType<mlir::scf::ForOp>() ||
                    loop->getParentOfType<mlir::scf::WhileOp>();

                builder.setInsertionPoint(loop);
                auto replicateOp = builder.create<mlir::dhir::ReplicateOp>(
                    loop.getLoc(), insouts[0], insouts[1]);
                replicateOp->setAttr("replicateID",
                                     builder.getI64IntegerAttr(repId));
                replicateOp->setAttr(
                    "pattern",
                    builder.getStringAttr(isStencil ? "stencil" : "default"));
                if (forceBroadcast)
                    replicateOp->setAttr("forceBroadcast", builder.getUnitAttr());

                mlir::Block *newBlock =
                    builder.createBlock(&replicateOp.getBodyRegion());
                loop->moveBefore(newBlock, newBlock->end());
                builder.setInsertionPointToEnd(newBlock);
                builder.create<mlir::dhir::YieldOp>(builder.getUnknownLoc());
                llvm::errs() << "Wrapped SCF loop with ReplicateOp (replicateID="
                             << repId << ")\n";
                ++repId;
            }

            // Helper function to check if a loop is independent (considering only its own iterations)
            // This checks the loop in isolation, not in the context of parent loops
            bool isLoopIndependent(mlir::affine::AffineForOp loop)
            {
                llvm::SmallVector<mlir::Operation *, 4> memOpVector;
                bool hasInvariantStore = false;
                Value iv = loop.getInductionVar();
                mlir::dhir::ArrayPartitioningAnalysis analysis(loop.getOperation(), loop.getInductionVar());

                // Collect only memory operations directly within this loop
                // Do NOT walk into nested loops - we only care about this loop's own dependencies
                loop.getBody()->walk([&](mlir::Operation *op)
                                     {
                    if (mlir::isa<mlir::affine::AffineStoreOp>(op)) {
                        memOpVector.push_back(op);
                        // A memory operation is owned by the loop body block,
                        // not directly by the AffineForOp.  Compare the
                        // nearest enclosing loop so invariant stores in this
                        // loop are actually rejected while nested-loop stores
                        // remain part of the nested loop's analysis.
                        if (op->getParentOfType<mlir::affine::AffineForOp>() == loop) {
                            if (analysis.getDimensionForIV(op, iv) == -1) {
                                hasInvariantStore = true;
                            }
                        }
                    }
                    else if (mlir::isa<mlir::affine::AffineLoadOp>(op)) {
                        memOpVector.push_back(op);
                    } });

                if (hasInvariantStore) {
                    llvm::errs() << "Loop contains invariant store (reduction) - cannot parallelize\n";
                    return false;
                }

                // Check for loop-carried dependencies at this loop's level only
                llvm::SmallVector<mlir::Operation *, 4> forLoopOpVector;
                forLoopOpVector.push_back(loop.getOperation());

                affine::FlatAffineValueConstraints constraints;
                affine::getIndexSet(forLoopOpVector, &constraints);

                llvm::errs() << "---- Checking Inner Loop Independence (Isolated) ----\n";

                for (int i = 0; i < memOpVector.size(); ++i)
                {
                    for (int j = 0; j < memOpVector.size(); ++j)
                    {
                        if (i == j)
                            continue;

                        mlir::affine::MemRefAccess src(memOpVector[i]);
                        mlir::affine::MemRefAccess dst(memOpVector[j]);
                        SmallVector<mlir::affine::DependenceComponent, 2> comps;

                        mlir::affine::DependenceResult res =
                            mlir::affine::checkMemrefAccessDependence(src, dst, 1, &constraints, &comps);

                        if (res.value == mlir::affine::DependenceResult::HasDependence)
                        {
                            if (comps.size() > 0)
                            {
                                auto &comp = comps[0];
                                if (!(comp.lb == 0 && comp.ub == 0))
                                {
                                    llvm::errs() << "Loop carries dependence (isolated check)\n";
                                    llvm::errs() << "---- End Checking Inner Loop Independence ----\n";
                                    return false; // Has loop-carried dependence
                                }
                            }
                        }
                        else if (res.value == mlir::affine::DependenceResult::Failure)
                        {
                            llvm::errs() << "Dependence check failed - assuming dependent\n";
                            llvm::errs() << "---- End Checking Inner Loop Independence ----\n";
                            return false; // Conservative: assume dependent
                        }
                    }
                }

                llvm::errs() << "No loop-carried dependence found - loop is independent!\n";
                llvm::errs() << "---- End Checking Inner Loop Independence ----\n";
                return true; // No loop-carried dependence
            }

            // Helper function to wrap independent loops with ReplicateOp
            void wrapIndependentLoopsInConverge(mlir::affine::AffineForOp outerLoop,
                                                mlir::OpBuilder &builder,
                                                int &repId)
            {
                llvm::SmallVector<mlir::affine::AffineForOp> allInnerLoops;

                // Collect all direct child loops of the outer loop
                // We need to check them at the same nesting level
                for (auto &op : outerLoop.getBody()->getOperations())
                {
                    if (auto innerLoop = mlir::dyn_cast<mlir::affine::AffineForOp>(op))
                    {
                        allInnerLoops.push_back(innerLoop);
                    }
                }

                // Now check each inner loop for independence (in isolation)
                llvm::SmallVector<mlir::affine::AffineForOp> independentLoops;
                for (auto innerLoop : allInnerLoops)
                {
                    // iter_args are invisible to the memory-access dependence
                    // check but are a real loop-carried value dependence: each
                    // iteration feeds the next.  Partitioning such a loop would
                    // need the previous shard's state, so leave it alone.
                    if (innerLoop.getNumRegionIterArgs() != 0)
                    {
                        llvm::errs() << "Inner loop carries iter_args; not wrapping in ReplicateOp\n";
                        continue;
                    }
                    if (isLoopIndependent(innerLoop))
                    {
                        independentLoops.push_back(innerLoop);
                    }
                }

                llvm::errs() << "Found " << independentLoops.size()
                             << " independent inner loops to wrap\n";

                // Wrap each independent loop with ReplicateOp
                for (auto forOp : independentLoops)
                {
                    auto insouts = InsOutsAnalysis::getInsandOut(forOp);

                    bool isStencil = false;

                    mlir::dhir::ArrayPartitioningAnalysis analysis(forOp.getOperation(), forOp.getInductionVar());
                    for (Value in : insouts[0])
                    {
                        auto info = analysis.analyzeArray(in);
                        if (info.haloLeft > 0 || info.haloRight > 0)
                            isStencil = true;
                    }

                    for (Value out : insouts[1])
                    {
                        auto info = analysis.analyzeArray(out);
                        if (info.haloLeft > 0 || info.haloRight > 0)
                            isStencil = true;
                    }

                    builder.setInsertionPoint(forOp);
                    auto replicateOp = builder.create<mlir::dhir::ReplicateOp>(forOp.getLoc(), insouts[0], insouts[1]);
                    replicateOp->setAttr("replicateID", builder.getI64IntegerAttr(repId));

                    if (isStencil)
                        replicateOp->setAttr("pattern", builder.getStringAttr("stencil"));
                    else
                        replicateOp->setAttr("pattern", builder.getStringAttr("default"));

                    mlir::Region &replicateRegion = replicateOp.getBodyRegion();
                    mlir::Block *newBlock = builder.createBlock(&replicateRegion);

                    forOp->moveBefore(newBlock, newBlock->end());
                    builder.setInsertionPointToEnd(newBlock);
                    builder.create<mlir::dhir::YieldOp>(builder.getUnknownLoc());

                    llvm::errs() << "Wrapped loop with ReplicateOp (replicateID=" << repId << ")\n";
                    ++repId;
                }
            }

            // Returns true if `loop` contains no nested affine.for operations.
            bool isInnermostAffineFor(mlir::affine::AffineForOp loop)
            {
                bool hasNested = false;
                loop.getBody()->walk([&](mlir::affine::AffineForOp nested) {
                    if (nested != loop)
                        hasNested = true;
                });
                return !hasNested;
            }

            // Interchanges a perfect 2-deep affine loop nest when an outer reduction loop
            // encloses a parallel per-output loop, exposing the parallel loop at the outermost
            // level for ReplicateOp partitioning. Returns true if interchange was performed.
            bool tryHoistParallelReductionNest(mlir::affine::AffineForOp outer)
            {
                // Verify that the nest is a perfect 2-deep affine nest.
                mlir::affine::AffineForOp inner;
                int bodyOps = 0;
                for (mlir::Operation &op : outer.getBody()->without_terminator())
                {
                    ++bodyOps;
                    inner = mlir::dyn_cast<mlir::affine::AffineForOp>(&op);
                }
                if (bodyOps != 1 || !inner || !isInnermostAffineFor(inner))
                    return false;

                // Require unit steps and ensure neither loop carries region iter_args.
                if (outer.getStepAsInt() != 1 || inner.getStepAsInt() != 1)
                    return false;
                if (outer.getNumRegionIterArgs() != 0 ||
                    inner.getNumRegionIterArgs() != 0)
                    return false;

                // Require rectangular loop bounds independent of the outer induction variable.
                for (mlir::Value v : inner.getLowerBoundOperands())
                    if (!outer.isDefinedOutsideOfLoop(v))
                        return false;
                for (mlir::Value v : inner.getUpperBoundOperands())
                    if (!outer.isDefinedOutsideOfLoop(v))
                        return false;

                // Verify that inner operations access memory strictly through affine loads/stores
                // without side effects.
                llvm::SmallVector<mlir::Value, 8> accessed;
                llvm::SmallVector<mlir::Value, 4> stored;
                for (mlir::Operation &op : inner.getBody()->without_terminator())
                {
                    if (auto load = mlir::dyn_cast<mlir::affine::AffineLoadOp>(&op))
                    {
                        accessed.push_back(load.getMemRef());
                        continue;
                    }
                    if (auto store = mlir::dyn_cast<mlir::affine::AffineStoreOp>(&op))
                    {
                        accessed.push_back(store.getMemRef());
                        stored.push_back(store.getMemRef());
                        continue;
                    }
                    if (op.getNumRegions() != 0 || !mlir::isMemoryEffectFree(&op))
                        return false;
                }

                // Verify that all accesses to stored buffers share the same underlying view root
                // to prevent undetected aliasing across subviews.
                for (mlir::Value s : stored)
                    for (mlir::Value a : accessed)
                        if (a != s && mlir::dhir::viewRoot(a) == mlir::dhir::viewRoot(s))
                            return false;

                // Verify loop-carried dependences: depth 1 (outer) must carry a reduction dependence,
                // while depth 2 (inner) must be dependence-free.
                if (checkLoopDependence(outer, 1) != 1)
                    return false;
                if (checkLoopDependence(outer, 2) != 0)
                    return false;

                // Ensure the loop interchange preserves all dependences.
                llvm::SmallVector<mlir::affine::AffineForOp, 2> nest = {outer,
                                                                        inner};
                llvm::SmallVector<unsigned, 2> perm = {1, 0};
                if (!mlir::affine::isValidLoopInterchangePermutation(nest, perm))
                {
                    llvm::errs() << "Reduction-over-parallel nest found but "
                                    "interchange is dependence-illegal; leaving "
                                    "it unchanged\n";
                    return false;
                }

                mlir::affine::interchangeLoops(outer, inner);
                llvm::errs() << "Interchanged reduction/parallel loop nest: "
                                "hoisted the parallel per-output loop above the "
                                "reduction loop for partitioning\n";
                return true;
            }

            // Interchanges qualifying reduction-over-parallel nests across the module
            // before loops are classified into Replicate, Converge, or Task operations.
            void hoistParallelReductionNests(mlir::Operation *module)
            {
                llvm::SmallVector<mlir::affine::AffineForOp> topLevel;
                module->walk<mlir::WalkOrder::PreOrder>([&](func::FuncOp funcOp) {
                    for (auto &op : funcOp.getBody().front().getOperations())
                        if (auto forOp = mlir::dyn_cast<mlir::affine::AffineForOp>(&op))
                            topLevel.push_back(forOp);
                });
                for (auto forOp : topLevel)
                    tryHoistParallelReductionNest(forOp);
            }
            // ================= kmeans loop fission =====================
            //
            // kmeans' per-iteration point loop mixes two kinds of work:
            //   (A) ASSIGNMENT   membership[i] = argmin_c dist(point i, center c)
            //                    delta += (membership[i] changed)
            //       each point's result depends only on that point, so which
            //       rank computes it is irrelevant -- bit-exact at any P.
            //   (B) ACCUMULATION new_centers[membership[i]][:] += feature[i][:]
            //                    new_centers_len[membership[i]] += 1
            //       a data-dependent f32 scatter-add.  Distributing it makes it
            //       a cross-rank partialReduce, which REASSOCIATES the f32 sum;
            //       the reassociated centroids feed the convergence argmin, so
            //       the trajectory diverges (this is why the whole-loop
            //       distribution was reverted).
            //
            // Fission the loop into (A) and (B).  (A) is wrapped in a
            // ReplicateOp and distributed over point slices; (B) is left a bare
            // serial scf.for that runs REPLICATED on every rank over the full
            // point range, reading the membership that (A) produced (gathered
            // to all ranks by (A)'s forceBroadcast).  Because every rank runs
            // the identical full accumulation in point order, (B) reproduces
            // the reference's f32 order bit-for-bit at any P.
            //
            // The whole thing is driven by IR structure, no kernel name:
            //   * the loop carries only sum-reduction iter_args (the delta);
            //   * it has an IV-slab store of a value V into an integer array M
            //     (membership[i] = V);
            //   * it has data-dependent additive-RMW scatter store(s) whose
            //     address depends on the outer IV ONLY through V -- so (B) can
            //     recover the address by loading M[i] instead of recomputing V.

            // Does `root` transitively read `target`?  Used to reject an ordered
            // recurrence (`a += a*k`) masquerading as a sum.
            
            bool valueReadsValue(mlir::Value root, mlir::Value target,
                                 llvm::SmallPtrSetImpl<mlir::Operation *> &seen)
            {
                if (root == target)
                    return true;
                mlir::Operation *def = root.getDefiningOp();
                if (!def || !seen.insert(def).second)
                    return false;
                if (def->getNumRegions() != 0)
                    return true; // a captured read we do not trace; assume yes
                for (mlir::Value o : def->getOperands())
                    if (valueReadsValue(o, target, seen))
                        return true;
                return false;
            }
            // Is `v` `carried` plus a contribution independent of `carried`?
            // Accepts `carried`, a bare add, and a single-result scf.if each of
            // whose arms is `carried` or such an add (conditional increment).
            bool isSumReductionOfCarried(mlir::Value v, mlir::Value carried)
            {
                if (v == carried)
                    return true;
                mlir::Operation *def = v.getDefiningOp();
                if (!def)
                    return false;
                if (auto ifOp = mlir::dyn_cast<mlir::scf::IfOp>(def))
                {
                    if (ifOp->getNumResults() != 1 ||
                        ifOp.getThenRegion().empty() ||
                        ifOp.getElseRegion().empty())
                        return false;
                    for (mlir::Region *r :
                         {&ifOp.getThenRegion(), &ifOp.getElseRegion()})
                    {
                        auto y = mlir::dyn_cast<mlir::scf::YieldOp>(
                            r->front().getTerminator());
                        if (!y || y.getNumOperands() != 1 ||
                            !isSumReductionOfCarried(y.getOperand(0), carried))
                            return false;
                    }
                    return true;
                }
                if (mlir::isa<mlir::arith::AddFOp, mlir::arith::AddIOp>(def) &&
                    def->getNumOperands() == 2)
                {
                    for (unsigned s = 0; s < 2; ++s)
                    {
                        if (def->getOperand(s) != carried)
                            continue;
                        llvm::SmallPtrSet<mlir::Operation *, 16> seen;
                        if (valueReadsValue(def->getOperand(1 - s), carried, seen))
                            continue; // ordered recurrence, not a sum
                        return true;
                    }
                }
                return false;
            }

            // For a sum-reduction carry, is the contribution added to `carried`
            // available OUTSIDE the reduction op (so a `select` built before the
            // loop yield can reference it)?  Rejects a contribution defined
            // inside a conditional arm.  Validation only, no mutation.
            bool carryContributionIsHoistable(mlir::Value yielded,
                                               mlir::Value carried)
            {
                if (yielded == carried)
                    return true;
                mlir::Operation *def = yielded.getDefiningOp();
                if (!def)
                    return false;
                auto addContribHoistable = [&](mlir::Value av,
                                               mlir::Operation *scope) -> bool {
                    if (av == carried)
                        return true; // pass-through, contributes 0
                    auto ad = av.getDefiningOp();
                    if (!ad ||
                        !mlir::isa<mlir::arith::AddFOp, mlir::arith::AddIOp>(ad) ||
                        ad->getNumOperands() != 2)
                        return false;
                    for (unsigned s = 0; s < 2; ++s)
                        if (ad->getOperand(s) == carried)
                        {
                            mlir::Value c = ad->getOperand(1 - s);
                            mlir::Operation *cd = c.getDefiningOp();
                            return !cd || !scope || !scope->isAncestor(cd);
                        }
                    return false;
                };
                if (auto ifOp = mlir::dyn_cast<mlir::scf::IfOp>(def))
                {
                    for (mlir::Region *r :
                         {&ifOp.getThenRegion(), &ifOp.getElseRegion()})
                    {
                        auto y = mlir::dyn_cast<mlir::scf::YieldOp>(
                            r->front().getTerminator());
                        if (!y || !addContribHoistable(y.getOperand(0), ifOp))
                            return false;
                    }
                    return true;
                }
                return addContribHoistable(yielded, nullptr);
            }

            // Build the SSA value V such that `yielded == carried + V`, inserting
            // any needed ops at `b`'s insertion point.  Mirror of the check above;
            // only called after it succeeded.
            mlir::Value buildCarryContribution(mlir::OpBuilder &b,
                                               mlir::Location loc,
                                               mlir::Value yielded,
                                               mlir::Value carried)
            {
                mlir::Type ty = carried.getType();
                auto zero = [&]() -> mlir::Value {
                    if (mlir::isa<mlir::FloatType>(ty))
                        return b.create<mlir::arith::ConstantOp>(
                            loc, b.getFloatAttr(ty, 0.0));
                    return b.create<mlir::arith::ConstantOp>(
                        loc, b.getIntegerAttr(ty, 0));
                };
                auto addContrib = [&](mlir::Value av) -> mlir::Value {
                    if (av == carried)
                        return zero();
                    auto ad = av.getDefiningOp();
                    for (unsigned s = 0; s < 2; ++s)
                        if (ad->getOperand(s) == carried)
                            return ad->getOperand(1 - s);
                    return zero();
                };
                if (yielded == carried)
                    return zero();
                if (auto ifOp =
                        mlir::dyn_cast<mlir::scf::IfOp>(yielded.getDefiningOp()))
                {
                    auto yt = mlir::cast<mlir::scf::YieldOp>(
                        ifOp.getThenRegion().front().getTerminator());
                    auto ye = mlir::cast<mlir::scf::YieldOp>(
                        ifOp.getElseRegion().front().getTerminator());
                    mlir::Value tv = addContrib(yt.getOperand(0));
                    mlir::Value ev = addContrib(ye.getOperand(0));
                    return b.create<mlir::arith::SelectOp>(loc, ifOp.getCondition(),
                                                           tv, ev);
                }
                return addContrib(yielded);
            }

            // Rewrite every iter_arg of `loop` (all already verified to be
            // hoistable sum reductions) into a 1-element memref so the loop has
            // no SSA carry and the accumulator store becomes an IV-invariant
            // additive read-modify-write -- which the existing partitioner treats
            // as a partialReduce.  For an exact integer count (the delta) the
            // cross-rank sum is exact, so this is safe to distribute.
            void demoteReductionCarriers(mlir::scf::ForOp loop)
            {
                auto yieldOp =
                    mlir::cast<mlir::scf::YieldOp>(loop.getBody()->getTerminator());
                mlir::Location loc = loop.getLoc();
                auto funcOp = loop->getParentOfType<mlir::func::FuncOp>();
                mlir::OpBuilder entry(&funcOp.getBody().front(),
                                      funcOp.getBody().front().begin());
                mlir::Value zeroIdx =
                    entry.create<mlir::arith::ConstantIndexOp>(loc, 0);

                unsigned n = loop.getNumRegionIterArgs();
                llvm::SmallVector<mlir::Value> accs;
                for (unsigned i = 0; i < n; ++i)
                {
                    auto ty = mlir::MemRefType::get(
                        {1}, loop.getRegionIterArg(i).getType());
                    accs.push_back(
                        entry.create<mlir::memref::AllocOp>(loc, ty));
                }
                // Re-seed before the loop (inside any enclosing while iteration).
                mlir::OpBuilder before(loop);
                for (unsigned i = 0; i < n; ++i)
                    before.create<mlir::memref::StoreOp>(
                        loc, loop.getInitArgs()[i], accs[i],
                        mlir::ValueRange{zeroIdx});

                // Normalise each carry to a direct additive RMW on its buffer.
                mlir::OpBuilder atYield(yieldOp);
                llvm::SmallVector<mlir::Value> newTotals;
                for (unsigned i = 0; i < n; ++i)
                {
                    mlir::Value contrib = buildCarryContribution(
                        atYield, loc, yieldOp.getOperand(i),
                        loop.getRegionIterArg(i));
                    mlir::Value cur = atYield.create<mlir::memref::LoadOp>(
                        loc, accs[i], mlir::ValueRange{zeroIdx});
                    mlir::Value tot =
                        mlir::isa<mlir::FloatType>(cur.getType())
                            ? atYield
                                  .create<mlir::arith::AddFOp>(loc, cur, contrib)
                                  .getResult()
                            : atYield
                                  .create<mlir::arith::AddIOp>(loc, cur, contrib)
                                  .getResult();
                    newTotals.push_back(tot);
                }
                // Load the running total at the top for in-body readers.
                mlir::OpBuilder body(loop.getBody(), loop.getBody()->begin());
                for (unsigned i = 0; i < n; ++i)
                {
                    mlir::Value ld = body.create<mlir::memref::LoadOp>(
                        loc, accs[i], mlir::ValueRange{zeroIdx});
                    loop.getRegionIterArg(i).replaceAllUsesWith(ld);
                }
                for (unsigned i = 0; i < n; ++i)
                    atYield.create<mlir::memref::StoreOp>(
                        loc, newTotals[i], accs[i], mlir::ValueRange{zeroIdx});

                // Rebuild the loop with no iter_args and move the body across.
                mlir::OpBuilder at(loop);
                auto newLoop = at.create<mlir::scf::ForOp>(
                    loc, loop.getLowerBound(), loop.getUpperBound(),
                    loop.getStep());
                newLoop.getBody()->getTerminator()->erase();
                newLoop.getBody()->getOperations().splice(
                    newLoop.getBody()->end(), loop.getBody()->getOperations());
                loop.getInductionVar().replaceAllUsesWith(
                    newLoop.getInductionVar());
                auto movedYield = mlir::cast<mlir::scf::YieldOp>(
                    newLoop.getBody()->getTerminator());
                mlir::OpBuilder(movedYield).create<mlir::scf::YieldOp>(loc);
                movedYield->erase();

                at.setInsertionPointAfter(newLoop);
                for (unsigned i = 0; i < n; ++i)
                {
                    mlir::Value ld = at.create<mlir::memref::LoadOp>(
                        loc, accs[i], mlir::ValueRange{zeroIdx});
                    loop.getResult(i).replaceAllUsesWith(ld);
                }
                loop.erase();
                funcOp.walk([&](mlir::func::ReturnOp ret) {
                    mlir::OpBuilder atRet(ret);
                    for (mlir::Value acc : accs)
                        atRet.create<mlir::memref::DeallocOp>(loc, acc);
                });
            }

            // Is `target` used (transitively) to compute `v`?
            bool valueDependsOn(mlir::Value v, mlir::Value target,
                                llvm::SmallPtrSetImpl<mlir::Operation *> &seen)
            {
                if (v == target)
                    return true;
                mlir::Operation *def = v.getDefiningOp();
                if (!def || !seen.insert(def).second)
                    return false;
                for (mlir::Value o : def->getOperands())
                    if (valueDependsOn(o, target, seen))
                        return true;
                return false;
            }
            
            // Does `v` reach `iv` WITHOUT passing through `stop`?  `stop` is
            // treated as a leaf (cut point).  Used to prove a scatter address
            // depends on the outer IV only through the assigned value V.
            bool reachesIVExcept(mlir::Value v, mlir::Value iv, mlir::Value stop,
                                 llvm::SmallPtrSetImpl<mlir::Operation *> &seen)
            {
                if (v == stop)
                    return false;
                if (v == iv)
                    return true;
                mlir::Operation *def = v.getDefiningOp();
                if (!def || !seen.insert(def).second)
                    return false;
                for (mlir::Value o : def->getOperands())
                    if (reachesIVExcept(o, iv, stop, seen))
                        return true;
                return false;
            }

            // Try to fission `loop` into a distributable assignment nest and a
            // serial-replicated scatter-accumulation nest.  Returns true iff it
            // transformed the IR.  Performs NO mutation unless every guard holds.
            bool tryFissionScatterAccumulation(mlir::scf::ForOp loop)
            {
                if (!isUnitStep(loop) || loop.getNumRegionIterArgs() == 0)
                    return false;
                if (loop.getInductionVar().use_empty())
                    return false;
                for (mlir::Operation *p = loop->getParentOp(); p;
                     p = p->getParentOp())
                    if (auto c = mlir::dyn_cast<mlir::scf::ForOp>(p);
                        c && !c.getInitArgs().empty())
                        return false;

                mlir::Value iv = loop.getInductionVar();
                auto yieldOp = mlir::cast<mlir::scf::YieldOp>(
                    loop.getBody()->getTerminator());

                // (1) every carry is a hoistable sum reduction (the delta), and
                //     it escapes only into its own reduction chain + the yield.
                for (unsigned i = 0; i < loop.getNumRegionIterArgs(); ++i)
                {
                    mlir::Value carried = loop.getRegionIterArg(i);
                    if (!isSumReductionOfCarried(yieldOp.getOperand(i), carried) ||
                        !carryContributionIsHoistable(yieldOp.getOperand(i),
                                                      carried))
                        return false;
                    for (mlir::Operation *u : carried.getUsers())
                        if (mlir::isa<mlir::memref::StoreOp>(u))
                            return false; // prefix-sum shape: not partitionable
                }

                // (2) classify every store as an IV-slab overwrite or a
                //     data-dependent additive-RMW scatter.  Anything else -> bail.
                mlir::dhir::ArrayPartitioningAnalysis analysis(loop, iv);
                llvm::SmallVector<mlir::memref::StoreOp> slabStores, scatterStores;
                bool bad = false;
                loop.walk([&](mlir::memref::StoreOp s) {
                    auto acc = analysis.getUnitStrideDimensionAndOffset(s, iv);
                    if (acc)
                    {
                        if (acc->second != 0)
                            bad = true;
                        else
                            slabStores.push_back(s);
                    }
                    else if (isAdditiveReadModifyWrite(s))
                        scatterStores.push_back(s);
                    else
                        bad = true;
                });
                if (bad || slabStores.empty() || scatterStores.empty())
                    return false;

                // (3) find the assignment store V -> M[iv] (M integer) such that
                //     every scatter address depends on V and reaches the outer IV
                //     only through V.
                mlir::memref::StoreOp membershipStore;
                mlir::Value Varg;
                for (mlir::memref::StoreOp s : slabStores)
                {
                    auto memTy = mlir::cast<mlir::MemRefType>(s.getMemRef().getType());
                    if (!memTy.getElementType().isIntOrIndex())
                        continue;
                    mlir::Value cand = s.getValue();
                    bool ok = true;
                    for (mlir::memref::StoreOp sc : scatterStores)
                    {
                        bool usesV = false, escapes = false;
                        for (mlir::Value idx : sc.getIndices())
                        {
                            llvm::SmallPtrSet<mlir::Operation *, 32> s1, s2;
                            if (valueDependsOn(idx, cand, s1))
                                usesV = true;
                            if (reachesIVExcept(idx, iv, cand, s2))
                                escapes = true;
                        }
                        if (!usesV || escapes)
                        {
                            ok = false;
                            break;
                        }
                    }
                    if (ok)
                    {
                        membershipStore = s;
                        Varg = cand;
                        break;
                    }
                }
                if (!membershipStore)
                    return false;

                // __FISSION_TRANSFORM__
                mlir::Block *bodyBlk = loop.getBody();
                auto liftTop = [&](mlir::Operation *op) -> mlir::Operation * {
                    while (op->getBlock() != bodyBlk)
                        op = op->getParentOp();
                    return op;
                };

                // Move-set: top-level body ops that feed ONLY the scatter path.
                // Seed with the top-level op containing each scatter store; grow
                // to any op all of whose result users are in/under the move-set.
                // The assignment value V's defining op (the argmin nest) is never
                // moved -- the scatter nest recovers V by loading M[i] instead.
                llvm::SmallPtrSet<mlir::Operation *, 16> moveSet;
                for (mlir::memref::StoreOp sc : scatterStores)
                    moveSet.insert(liftTop(sc));
                mlir::Operation *vargDef = Varg.getDefiningOp();
                bool grew = true;
                while (grew)
                {
                    grew = false;
                    for (mlir::Operation &o : bodyBlk->without_terminator())
                    {
                        if (moveSet.count(&o) || &o == vargDef ||
                            o.getNumResults() == 0 ||
                            mlir::isa<mlir::memref::StoreOp>(o))
                            continue;
                        bool anyUse = false, allInMove = true;
                        for (mlir::Value r : o.getResults())
                            for (mlir::Operation *u : r.getUsers())
                            {
                                anyUse = true;
                                if (!moveSet.count(liftTop(u)))
                                    allInMove = false;
                            }
                        if (anyUse && allInMove)
                        {
                            moveSet.insert(&o);
                            grew = true;
                        }
                    }
                }

                // Build Nest B after the loop: a bare serial scf.for over the
                // full range that loads membership and replays the scatter path.
                mlir::OpBuilder b(loop);
                b.setInsertionPointAfter(loop);
                auto nestB = b.create<mlir::scf::ForOp>(
                    loop.getLoc(), loop.getLowerBound(), loop.getUpperBound(),
                    loop.getStep());
                b.setInsertionPointToStart(nestB.getBody());
                mlir::Value memLoad = b.create<mlir::memref::LoadOp>(
                    loop.getLoc(), membershipStore.getMemRef(),
                    mlir::ValueRange{nestB.getInductionVar()});
                mlir::IRMapping map;
                map.map(iv, nestB.getInductionVar());
                map.map(Varg, memLoad);
                for (mlir::Operation &o : bodyBlk->without_terminator())
                    if (moveSet.count(&o))
                        b.clone(o, map);
                nestB->setAttr("dhir.serialReplicated", b.getUnitAttr());

                // Prune the moved ops out of Nest A (reverse program order).
                llvm::SmallVector<mlir::Operation *> toErase;
                for (mlir::Operation &o : bodyBlk->without_terminator())
                    if (moveSet.count(&o))
                        toErase.push_back(&o);
                for (auto it = toErase.rbegin(); it != toErase.rend(); ++it)
                    (*it)->erase();

                // Nest A now carries only the assignment + delta; demote the
                // delta carry so the loop partitions and distributes.
                llvm::errs() << "Fissioned scatter-accumulation loop: assignment "
                                "nest distributes, accumulation nest kept "
                                "serial-replicated\n";
                demoteReductionCarriers(loop);
                return true;
            }

            void fissionScatterAccumulationLoops(mlir::Operation *module)
            {
                for (unsigned round = 0; round < 8; ++round)
                {
                    llvm::SmallVector<mlir::scf::ForOp> loops;
                    module->walk<mlir::WalkOrder::PreOrder>(
                        [&](mlir::scf::ForOp l) {
                            if (!l.getInitArgs().empty())
                                loops.push_back(l);
                        });
                    bool changed = false;
                    for (mlir::scf::ForOp l : loops)
                        if (tryFissionScatterAccumulation(l))
                        {
                            changed = true;
                            break; // handles are stale; re-collect
                        }
                    if (!changed)
                        return;
                }
            }

            void runOnOperation() override
            {
                mlir::MLIRContext *context = &getContext();
                auto *module = getOperation();
                mlir::OpBuilder builder(context);

                // Expose outer parallelism (loop interchange) before the nests
                // are classified into Replicate/Converge/Task.
                hoistParallelReductionNests(module);

                // Split a loop that mixes distributable assignment with a
                // reassociation-sensitive scatter-accumulation (kmeans): the
                // assignment nest is distributed, the accumulation nest is kept
                // serial-replicated so its f32 sum keeps the reference order.
                fissionScatterAccumulationLoops(module);

                llvm::SmallVector<mlir::Operation *, 4> toReplicateVector;
                llvm::SmallVector<mlir::Operation *, 4> toConvergeVector;
                llvm::SmallVector<mlir::Operation *, 4> toTaskVector;

                module->walk<mlir::WalkOrder::PreOrder>([&](mlir::Operation *op)
                                                        {
                    if (mlir::isa<func::FuncOp>(op))
                    {
                        auto funcOp = mlir::dyn_cast<func::FuncOp>(op);
                        Block &blck = funcOp.getBody().front();

                        for (auto &op : blck.getOperations())
                        {
                            if (mlir::isa<affine::AffineForOp>(op))
                            {
                                mlir::affine::AffineForOp forOp = mlir::dyn_cast<mlir::affine::AffineForOp>(op);
                                
                                // Check dependence at depth 1 (outer loop)
                                int outerDep = checkLoopDependence(forOp, 1);
                                
                                // A loop whose IV never reaches its body repeats
                                // one computation (an `iters` loop).  Its
                                // iterations address no disjoint data, so the
                                // dependence test reports no conflict even though
                                // partitioning it is unsound: every shard would
                                // recompute the whole output and the reduction
                                // combine would sum those duplicates (spmv/histo
                                // came out scaled by the shard count).
                                //
                                // Distributing an *inner* loop instead was tried
                                // (route the nest to the ConvergeOp path).  With
                                // the shard-local scatter loop now kept serial it
                                // no longer races, but the MPI partialReduce
                                // combine is still wrong for these two:
                                //  - spmv writes arg8[arg7[i]] as a pure OVERWRITE.
                                //    The combine seeds shard 0 with the old arg8
                                //    and SUMS, so every output position that a
                                //    non-root shard owns comes out as
                                //    arg8_old + value (≈3/4 of outputs → 854 errs).
                                //    A disjoint overwrite must zero-seed ALL
                                //    shards, not sum onto shard 0's copy.
                                //  - histo is an i8 saturating scatter-ADD and
                                //    under-counts (24935) — its in-kernel zeroing
                                //    loop is partitioned alongside the count loop.
                                // Both need the combine reworked per scatter kind;
                                // until then keep the whole nest unpartitioned so
                                // every rank redundantly computes the correct
                                // result (correct, no speedup — like cutcp/lbm).
                                bool ivRepeatLoop = forOp.getInductionVar().use_empty();

                                if (outerDep == 1) // Outer loop has dependence
                                {
                                    // Collect all inner loops
                                    llvm::SmallVector<mlir::affine::AffineForOp> innerLoops;
                                    forOp.walk<mlir::WalkOrder::PreOrder>([&](mlir::affine::AffineForOp innerOp)
                                    {
                                        if (innerOp != forOp) // Skip the outer loop itself
                                        {
                                            innerLoops.push_back(innerOp);
                                        }
                                    });

                                    // Check if any inner loop is parallelizable
                                    bool hasParallelizableInner = false;
                                    for (auto innerLoop : innerLoops)
                                    {
                                        if (isLoopIndependent(innerLoop))
                                        {
                                            hasParallelizableInner = true;
                                            break;
                                        }
                                    }
                                    
                                    // Wrap with ConvergeOp if there are parallelizable inner loops
                                    if(hasParallelizableInner)
                                        toConvergeVector.push_back(forOp);
                                    else
                                    {
                                        // If it contains dependence at both level, 
                                        // Wrap the whole loop nest with taskOp.
                                        toTaskVector.push_back(forOp); 
                                        llvm::errs() << "---- Wrapping with TaskOp ----\n";
                                    }
                                        
                                }
                                else if (outerDep == 0) // No dependence in outer loop
                                {
                                    // Fully parallelizable - wrap with ReplicateOp.
                                    // iter_args are not visible to the memory-access
                                    // dependence check, yet they carry a value from
                                    // one iteration to the next, so a loop that has
                                    // them is not parallelizable: it is left
                                    // unpartitioned and then runs, unchanged, on
                                    // every rank.
                                    if (forOp.getNumRegionIterArgs() != 0)
                                    {
                                        llvm::errs() << "Loop carries iter_args; leaving it unpartitioned\n";
                                    }
                                    else if (ivRepeatLoop)
                                    {
                                        llvm::errs() << "Loop body is invariant in its IV "
                                                        "(repeat loop); leaving it unpartitioned\n";
                                    }
                                    else if (hasScaledFlatSlabStore(forOp))
                                    {
                                        llvm::errs() << "Loop writes a scaled/offset flat slab "
                                                        "(gather cannot represent it); leaving it "
                                                        "unpartitioned\n";
                                    }
                                    else
                                        toReplicateVector.push_back(forOp);
                                }
                                else // outerDep == 2, dependence check inconclusive
                                {
                                    // The affine test could not prove independence
                                    // (e.g. lbm's ping-pong stream/collide carries a
                                    // cross-iteration dependence it can't resolve).
                                    // Previously this called exit(0), which killed
                                    // the process before the module was ever
                                    // emitted — the kernel object came out empty and
                                    // every downstream link failed with "undefined
                                    // reference".  Fall back to the same safe
                                    // behavior as the unpartitionable cases above:
                                    // leave the loop unwrapped so it runs unchanged
                                    // on every rank (correct, no speedup).
                                    llvm::errs() << "Dependence analysis inconclusive; "
                                                    "leaving it unpartitioned\n";
                                }
                            }
                        }
                    } });



                // Generate Individual Tasks
                for(auto task: toTaskVector)
                {
                    
                }
                
                // Create ReplicateOp for fully parallelizable loops
                int repId = 1;
                for (auto op : toReplicateVector)
                {
                    affine::AffineForOp forOp = mlir::dyn_cast<affine::AffineForOp>(op);
                    auto insouts = InsOutsAnalysis::getInsandOut(forOp);

                    bool isStencil = false;
                    mlir::dhir::ArrayPartitioningAnalysis analysis(
                        forOp.getOperation(), forOp.getInductionVar());
                    for (Value in : insouts[0])
                    {
                        auto info = analysis.analyzeArray(in);
                        isStencil |= info.haloLeft > 0 || info.haloRight > 0;
                    }
                    for (Value out : insouts[1])
                    {
                        auto info = analysis.analyzeArray(out);
                        isStencil |= info.haloLeft > 0 || info.haloRight > 0;
                    }

                    builder.setInsertionPoint(forOp);
                    auto replicateOp = builder.create<mlir::dhir::ReplicateOp>(forOp.getLoc(), insouts[0], insouts[1]);
                    replicateOp->setAttr("replicateID", builder.getI64IntegerAttr(repId));
                    replicateOp->setAttr(
                        "pattern",
                        builder.getStringAttr(isStencil ? "stencil" : "default"));

                    mlir::Region &replicateRegion = replicateOp.getBodyRegion();
                    mlir::Block *newBlock = builder.createBlock(&replicateRegion);

                    forOp->moveBefore(newBlock, newBlock->end());
                    builder.setInsertionPointToEnd(newBlock);
                    builder.create<mlir::dhir::YieldOp>(builder.getUnknownLoc());
                    ++repId;
                }

                // Extracted Rodinia kernels predominantly use scf.for.  Select
                // the outermost conservatively independent loops, including
                // loops nested in serial SCF control flow.  Do not create a
                // nested replicate when an already-selected affine/SCF loop
                // owns the same computation.  A task nested under a
                // loop-carried scf.for is deliberately left serial: the
                // carried values define iteration state (including ping-pong
                // buffers), and DHIR has no contract for cloning or swapping
                // that state across shards.
                llvm::SmallVector<mlir::scf::ForOp> scfCandidates;
                module->walk<mlir::WalkOrder::PreOrder>([&](mlir::scf::ForOp loop) {
                    // A fissioned scatter-accumulation nest (and anything nested
                    // in it) must stay serial-replicated -- never partition it,
                    // or its f32 scatter-add would reassociate across ranks.
                    for (Operation *p = loop; p; p = p->getParentOp())
                        if (p->hasAttr("dhir.serialReplicated"))
                            return;
                    for (Operation *parent = loop->getParentOp(); parent;
                         parent = parent->getParentOp())
                    {
                        if (auto carried = dyn_cast<mlir::scf::ForOp>(parent);
                            carried && !carried.getInitArgs().empty())
                        {
                            llvm::errs()
                                << "Leaving SCF loop under loop-carried ancestor "
                                << "unpartitioned\n";
                            return;
                        }
                        if (llvm::is_contained(toReplicateVector, parent) ||
                            llvm::is_contained(toConvergeVector, parent))
                            return;
                    }

                    for (mlir::scf::ForOp selected : scfCandidates)
                        if (selected->isProperAncestor(loop))
                            return;

                    if (isScfLoopIndependent(loop))
                        scfCandidates.push_back(loop);
                });

                for (mlir::scf::ForOp loop : scfCandidates)
                    wrapScfLoop(loop, builder, repId);

                // Create ConvergeOp for loops with dependencies
                int taskId = 1;
                for (auto op : toConvergeVector)
                {
                    affine::AffineForOp forOp = mlir::dyn_cast<affine::AffineForOp>(op);

                    // FIRST: Wrap independent inner loops with ReplicateOp
                    // This must be done BEFORE creating ConvergeOp
                    wrapIndependentLoopsInConverge(forOp, builder, repId);

                    // NOW: Create the ConvergeOp and move the outer loop into it
                    auto insouts = InsOutsAnalysis::getInsandOut(forOp);

                    builder.setInsertionPoint(forOp);
                    auto convergeOp = builder.create<mlir::dhir::ConvergeOp>(forOp.getLoc(), insouts[0], insouts[1]);
                    convergeOp->setAttr("ConvergeID", builder.getI64IntegerAttr(taskId));

                    mlir::Region &ConvergeRegion = convergeOp.getBodyRegion();
                    mlir::Block *newBlock = builder.createBlock(&ConvergeRegion);

                    forOp->moveBefore(newBlock, newBlock->end());
                    builder.setInsertionPointToEnd(newBlock);
                    builder.create<mlir::dhir::YieldOp>(builder.getUnknownLoc());

                    ++taskId;
                }

            }
        };
    }
}

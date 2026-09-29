#ifndef UPLIFT_WHILE_TO_FOR_H
#define UPLIFT_WHILE_TO_FOR_H

// ============================================================================
// Canonicalization: scf.while -> scf.for uplift for counted timestep loops.
//
// RATIONALE FOR A DEDICATED PRE-PASS
// ----------------------------------
// The DHIR distribution pipeline operates primarily on scf::ForOp constructs.
// In conversions/dhirtompi.h, deferred communication frames (DeferFrame) for
// inter-iteration stencil residency are instantiated exclusively within the
// scf::ForOp lowering path (via deferFrames.emplace_back()). Loops represented
// as scf::WhileOp do not trigger deferred synchronization, preventing stencil
// residency optimizations. Frontends often emit while-loops for counted timestep
// loops when the induction variable remains live past loop termination; this
// pass canonicalizes such loops into scf::ForOp form.
//
// Executing this transformation as an independent pass prior to --affine-to-dhir
// ensures that subsequent DHIR lowering passes encounter canonical scf::ForOp
// loops directly, while maintaining pass modularity and auditability.
//
// RATIONALE FOR CUSTOM REWRITE IMPLEMENTATION
// ------------------------------------------
// 1. Exit Induction Variable Computation:
//    The standard mlir::scf::upliftWhileToForLoop implementation in LLVM 22.1.8
//    computes the final induction value as:
//        lastIV = lb + (ceildiv(ub - lb, step) - 1) * step
//    This yields the induction value of the final executed iteration rather than
//    the value carried out upon loop termination (which increments before condition
//    evaluation). Furthermore, it lacks zero-trip clamping. The correct exit value
//    is:
//        exitIV = lb + max(0, ceildiv(ub - lb, step)) * step
//    For loops with step sizes greater than one, using the last-executed index
//    produces an off-by-step discrepancy for post-loop consumers relying on the
//    exit value. This implementation explicitly generates the clamped exit formula.
//
// 2. Handling Derived Operations in Before Region:
//    The upstream pattern requires the `before` block to begin immediately with
//    an arith::CmpIOp, disallowing preceding side-effect-free operations.
//    Counted timestep loops frequently compute auxiliary derived values
//    (e.g., `iv - 1`) forwarded by scf.condition for post-loop consumption.
//    This pass permits side-effect-free, speculatable derived operations in the
//    `before` block and rematerializes them within the new loop body and at the
//    loop exit.
//
// SCOPE CONSTRAINTS AND TARGET CRITERIA
// ------------------------------------
// The transformation applies strictly to counted, bounded timestep loops with
// array-accessing nested loop bodies. Worklist algorithms, binary searches,
// convergence tests, and retry loops are excluded to avoid altering the semantics
// or execution structure of irregular kernels. All eligibility conditions are
// evaluated purely via structural IR properties.
// ============================================================================

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/Support/raw_ostream.h"

#include "includes/dhirDialect.h"

namespace mlir
{
    namespace dhir
    {
        // Diagnostics control flag set by --print-uplift. Reports transformation
        // decisions and eligibility rationale for inspected scf.while operations.
        // Disabled by default to keep standard compilation output clean.
        inline bool &printUpliftDecisions()
        {
            static bool enabled = false;
            return enabled;
        }

        namespace uplift_detail
        {
            // Returns true if `v` is defined outside `loop` (i.e., is loop-invariant).
            inline bool definedOutside(mlir::Value v, mlir::Operation *loop)
            {
                if (!v)
                    return false;
                if (mlir::Operation *def = v.getDefiningOp())
                    return !loop->isAncestor(def);
                auto barg = mlir::cast<mlir::BlockArgument>(v);
                mlir::Operation *owner = barg.getOwner()->getParentOp();
                return owner && owner != loop && !loop->isAncestor(owner);
            }

            // Computes maximum nesting depth of scf.for and affine.for loops within `region`.
            inline unsigned deepestForNest(mlir::Region &region)
            {
                unsigned best = 0;
                region.walk([&](mlir::Operation *op) {
                    if (!mlir::isa<mlir::scf::ForOp, mlir::affine::AffineForOp>(op))
                        return;
                    unsigned depth = 1;
                    for (mlir::Operation *p = op->getParentOp();
                         p && p != region.getParentOp(); p = p->getParentOp())
                        if (mlir::isa<mlir::scf::ForOp,
                                      mlir::affine::AffineForOp>(p))
                            ++depth;
                    best = std::max(best, depth);
                });
                return best;
            }

            // Determines whether `region` contains a loop nest performing stores to a memref,
            // characteristic of computational kernels operating across multi-dimensional arrays.
            inline bool sweepsAnArray(mlir::Region &region)
            {
                bool found = false;
                region.walk([&](mlir::Operation *op) {
                    if (found)
                        return;
                    if (!mlir::isa<mlir::memref::StoreOp,
                                   mlir::affine::AffineStoreOp>(op))
                        return;
                    for (mlir::Operation *p = op->getParentOp();
                         p && p != region.getParentOp(); p = p->getParentOp())
                        if (mlir::isa<mlir::scf::ForOp,
                                      mlir::affine::AffineForOp>(p))
                        {
                            found = true;
                            return;
                        }
                });
                return found;
            }

            // Validates whether comparison predicate `p` is strict-less-than (slt/ult),
            // which maps directly to the exclusive upper bound of scf.for. Returns
            // signedness via `isSigned`. Non-strict predicates (sle/ule) are rejected.
            inline bool isUpliftablePredicate(mlir::arith::CmpIPredicate p,
                                              bool &isSigned)
            {
                switch (p)
                {
                case mlir::arith::CmpIPredicate::slt:
                    isSigned = true;
                    return true;
                case mlir::arith::CmpIPredicate::ult:
                    isSigned = false;
                    return true;
                default:
                    return false;
                }
            }

            inline void report(llvm::StringRef verdict, const std::string &why)
            {
                if (printUpliftDecisions())
                    llvm::errs() << "[uplift-while-to-for] " << verdict << ": "
                                 << why << "\n";
            }
        } // namespace uplift_detail

        // ------------------------------------------------------------------
        // Core transformation function.
        //
        // Implemented as an explicit rewrite on RewriterBase rather than a greedy
        // pattern driver to prevent unintended canonicalization or dead-code
        // elimination on unrelated operations, isolating modifications strictly
        // to eligible loop candidates.
        // ------------------------------------------------------------------
        inline mlir::LogicalResult
        upliftCountedWhile(mlir::scf::WhileOp loop, mlir::RewriterBase &rewriter)
        {
            {
                using namespace uplift_detail;

                // =========================================================
                // Constraint 1: Exactly one iter_arg representing the induction variable.
                //
                // Additional carried values indicate complex loop-carried state
                // (e.g., worklist pointers, dynamic flags), which are excluded
                // from this transformation to preserve downstream distribution semantics.
                // =========================================================
                if (loop.getInits().size() != 1)
                {
                    report("refuse", "not a single iter_arg (" +
                                         std::to_string(loop.getInits().size()) +
                                         " carried values) -- loop-carried "
                                         "state, not a bare trip count");
                    return mlir::failure();
                }

                if (!loop.getBefore().hasOneBlock() ||
                    !loop.getAfter().hasOneBlock())
                {
                    report("refuse", "before/after is not a single block");
                    return mlir::failure();
                }

                mlir::Block &before = *loop.getBeforeBody();
                mlir::Block &after = *loop.getAfterBody();
                mlir::BlockArgument ivBefore = before.getArgument(0);

                auto cond = mlir::dyn_cast<mlir::scf::ConditionOp>(
                    before.getTerminator());
                if (!cond)
                {
                    report("refuse", "before region has no scf.condition");
                    return mlir::failure();
                }

                // =========================================================
                // Constraint 2: The `before` block contains only pure derived operations,
                // an arith.cmpi, and the scf.condition terminator.
                //
                // Derived operations will be rematerialized, requiring them to be
                // side-effect-free, speculatable, single-result, and region-free.
                // Non-trivial computations or operations with side effects are rejected.
                // =========================================================
                mlir::arith::CmpIOp cmp;
                llvm::SmallVector<mlir::Operation *> derived;
                for (mlir::Operation &op : before.without_terminator())
                {
                    if (auto c = mlir::dyn_cast<mlir::arith::CmpIOp>(&op))
                    {
                        if (cmp)
                        {
                            report("refuse", "before region has more than one "
                                             "arith.cmpi");
                            return mlir::failure();
                        }
                        cmp = c;
                        continue;
                    }
                    if (op.getNumRegions() != 0 || op.getNumResults() != 1)
                    {
                        report("refuse",
                               std::string("before region op '") +
                                   op.getName().getStringRef().str() +
                                   "' has regions or is not single-result");
                        return mlir::failure();
                    }
                    if (!mlir::isMemoryEffectFree(&op) ||
                        !mlir::isSpeculatable(&op))
                    {
                        report("refuse",
                               std::string("before region op '") +
                                   op.getName().getStringRef().str() +
                                   "' is not pure/speculatable, so it cannot be "
                                   "rematerialized");
                        return mlir::failure();
                    }
                    derived.push_back(&op);
                }
                if (!cmp)
                {
                    report("refuse", "before region has no arith.cmpi (cmpf or "
                                     "a carried i1 flag -- a convergence test, "
                                     "not a trip count)");
                    return mlir::failure();
                }
                if (cond.getCondition() != cmp.getResult() ||
                    !cmp.getResult().hasOneUse())
                {
                    report("refuse", "the cmpi does not feed the scf.condition "
                                     "exclusively");
                    return mlir::failure();
                }

                // Verify that every derived operation depends solely on the induction
                // variable, loop-invariant values, or previously verified derived operations.
                auto isDerived = [&](mlir::Operation *op) {
                    return op && llvm::is_contained(derived, op);
                };
                for (mlir::Operation *d : derived)
                    for (mlir::Value operand : d->getOperands())
                    {
                        if (operand == ivBefore ||
                            definedOutside(operand, loop.getOperation()) ||
                            isDerived(operand.getDefiningOp()))
                            continue;
                        report("refuse", "a before-region op reads something "
                                         "that is neither the IV, "
                                         "loop-invariant, nor another pure "
                                         "derived value");
                        return mlir::failure();
                    }

                // =========================================================
                // Constraint 3: Termination test must be of the form `iv < invariantBound`.
                //
                // Loop bounds that vary per iteration (e.g., search bounds or worklist limits)
                // do not represent statically determinable trip counts and are rejected.
                // =========================================================
                bool isSigned = false;
                if (!isUpliftablePredicate(cmp.getPredicate(), isSigned))
                {
                    report("refuse", "cmpi predicate is not slt/ult");
                    return mlir::failure();
                }
                if (cmp.getLhs() != ivBefore)
                {
                    report("refuse", "cmpi lhs is not the carried induction "
                                     "variable");
                    return mlir::failure();
                }
                mlir::Value ub = cmp.getRhs();
                if (!definedOutside(ub, loop.getOperation()))
                {
                    report("refuse", "comparison bound is not loop-invariant");
                    return mlir::failure();
                }
                if (!ivBefore.getType().isIntOrIndex())
                {
                    report("refuse", "induction variable is not integer/index");
                    return mlir::failure();
                }

                // =========================================================
                // Constraint 4: scf.condition forwards only the induction variable and pure
                // derived values, with no circular dependencies feeding the `before` block.
                //
                // Ensures loop control is strictly bound to the induction variable rather than
                // a feedback or convergence condition.
                // =========================================================
                llvm::SmallVector<unsigned> ivPositions;
                for (auto [k, arg] : llvm::enumerate(cond.getArgs()))
                {
                    if (arg == ivBefore)
                    {
                        ivPositions.push_back(unsigned(k));
                        continue;
                    }
                    if (isDerived(arg.getDefiningOp()))
                        continue;
                    report("refuse", "scf.condition forwards a value that is "
                                     "neither the IV nor a pure derived value");
                    return mlir::failure();
                }
                if (ivPositions.empty())
                {
                    report("refuse", "scf.condition does not forward the IV");
                    return mlir::failure();
                }
                for (mlir::Operation &op : before.without_terminator())
                    for (mlir::Value operand : op.getOperands())
                        if (operand.getDefiningOp() == loop.getOperation())
                        {
                            report("refuse", "before region reads a loop result "
                                             "(loop-carried condition)");
                            return mlir::failure();
                        }

                // =========================================================
                // Constraint 5: The `after` block terminates with an scf.yield of arith.addi(iv, step),
                // where the addition resides at top-level with a positive constant step.
                //
                // Conditional increments nested within control flow represent data-dependent
                // iteration caps rather than unconditional induction progressions, and are rejected.
                // =========================================================
                auto yield =
                    mlir::dyn_cast<mlir::scf::YieldOp>(after.getTerminator());
                if (!yield || yield.getNumOperands() != 1)
                {
                    report("refuse", "after region does not yield exactly one "
                                     "value");
                    return mlir::failure();
                }
                auto add =
                    yield.getOperand(0).getDefiningOp<mlir::arith::AddIOp>();
                if (!add)
                {
                    report("refuse", "yielded value is not an arith.addi (a "
                                     "select, divsi or scf.for result -- not a "
                                     "fixed-step increment)");
                    return mlir::failure();
                }
                if (add->getBlock() != &after)
                {
                    report("refuse", "the IV increment is nested in control "
                                     "flow (retry cap, not a trip count)");
                    return mlir::failure();
                }

                // The incremented operand must correspond to an after-block argument bound
                // to the induction variable by scf.condition (which may occupy an index other than 0).
                mlir::BlockArgument ivAfter;
                mlir::Value step;
                for (unsigned p : ivPositions)
                {
                    mlir::BlockArgument cand = after.getArgument(p);
                    if (add.getLhs() == cand)
                    {
                        ivAfter = cand;
                        step = add.getRhs();
                        break;
                    }
                    if (add.getRhs() == cand)
                    {
                        ivAfter = cand;
                        step = add.getLhs();
                        break;
                    }
                }
                if (!ivAfter)
                {
                    report("refuse", "arith.addi does not increment the "
                                     "induction variable");
                    return mlir::failure();
                }
                if (!definedOutside(step, loop.getOperation()))
                {
                    report("refuse", "step is not loop-invariant");
                    return mlir::failure();
                }
                std::optional<int64_t> stepConst =
                    mlir::getConstantIntValue(step);
                if (!stepConst || *stepConst <= 0)
                {
                    report("refuse", "step is not a positive constant");
                    return mlir::failure();
                }

                // =========================================================
                // GUARD 6: the IV is not otherwise written in `after`.  Its
                // only non-read use may be the increment above; yielding it
                // unchanged would be an infinite loop the scf.for would not
                // reproduce.
                // =========================================================
                for (mlir::OpOperand &use : ivAfter.getUses())
                {
                    mlir::Operation *user = use.getOwner();
                    if (user == add.getOperation())
                        continue;
                    if (user == yield.getOperation())
                    {
                        report("refuse", "after region yields the IV unchanged");
                        return mlir::failure();
                    }
                    // All other references are read uses that map directly to the scf.for induction variable.
                }

                // =========================================================
                // Constraint 7: The loop body must contain an array-accessing nested loop.
                //
                // Restricts transformation targeting specifically to outer timestep loops
                // that enclose computational loop nests suitable for distributed stencil
                // optimizations, excluding scalar or control-only loops.
                // =========================================================
                unsigned depth = deepestForNest(loop.getAfter());
                if (depth < 1 || !sweepsAnArray(loop.getAfter()))
                {
                    report("refuse", "no array-sweeping for-nest in the body "
                                     "(deepest nest " + std::to_string(depth) +
                                     ") -- not a timestep loop");
                    return mlir::failure();
                }

                // =========================================================
                // Construction of equivalent scf.for loop.
                // =========================================================
                mlir::Location loc = loop.getLoc();
                mlir::Value lb = loop.getInits()[0];

                // Rematerialize derived values from the `before` region in topological order.
                auto neededFor = [&](mlir::ValueRange roots) {
                    llvm::SetVector<mlir::Operation *> want;
                    llvm::SmallVector<mlir::Value> work(roots.begin(),
                                                        roots.end());
                    while (!work.empty())
                    {
                        mlir::Value v = work.pop_back_val();
                        if (v == ivBefore)
                            continue;
                        mlir::Operation *d = v.getDefiningOp();
                        if (!isDerived(d) || !want.insert(d))
                            continue;
                        for (mlir::Value o : d->getOperands())
                            work.push_back(o);
                    }
                    llvm::SmallVector<mlir::Operation *> ordered;
                    for (mlir::Operation *d : derived)
                        if (want.contains(d))
                            ordered.push_back(d);
                    return ordered;
                };
                // Recomputes `roots` using `ivRepl` as the base induction variable,
                // appending newly generated operations to `made`.
                auto rematerialize =
                    [&](mlir::Value ivRepl, mlir::ValueRange roots,
                        llvm::SmallVectorImpl<mlir::Value> &out,
                        llvm::SmallVectorImpl<mlir::Operation *> &made) {
                        mlir::IRMapping map;
                        map.map(ivBefore, ivRepl);
                        for (mlir::Operation *d : neededFor(roots))
                            made.push_back(rewriter.clone(*d, map));
                        for (mlir::Value r : roots)
                            out.push_back(r == ivBefore
                                              ? ivRepl
                                              : map.lookupOrDefault(r));
                    };

                // Provide a null body builder so that scf::ForOp::build automatically
                // instantiates the default scf.yield terminator.
                auto forOp = rewriter.create<mlir::scf::ForOp>(
                    loc, lb, ub, step, mlir::ValueRange{},
                    /*bodyBuilder=*/nullptr,
                    /*unsignedCmp=*/!isSigned);

                // Construct body block arguments: each after-block argument maps either to
                // the scf.for induction variable or a recomputed derived value.
                llvm::SmallVector<mlir::Operation *> bodyMade;
                llvm::SmallVector<mlir::Value> bodyArgs;
                mlir::Block *body = forOp.getBody();
                mlir::Operation *bodyTerm = body->getTerminator();
                rewriter.setInsertionPoint(bodyTerm);
                rematerialize(forOp.getInductionVar(), cond.getArgs(), bodyArgs,
                              bodyMade);

                rewriter.eraseOp(yield);
                rewriter.inlineBlockBefore(&after, bodyTerm, bodyArgs);
                // The explicit increment is now redundant, as induction is managed by scf.for.
                if (add->use_empty())
                    rewriter.eraseOp(add);

                // Compute the exit induction variable:
                //     tripCount = ceildiv(ub - lb, step)
                //     exitIV    = lb + max(0, tripCount) * step
                //
                // Trip count is formulated as: (ub - lb + step - 1) / step for positive steps.
                // The zero-trip clamp max(0, tripCount) ensures that when lb >= ub, the exit value
                // evaluates exactly to lb. Signed versus unsigned operations mirror the comparison predicate.
                rewriter.setInsertionPointAfter(forOp);
                llvm::SmallVector<mlir::Operation *> tailMade;
                mlir::Type ivType = lb.getType();
                auto mk = [&](auto op) {
                    tailMade.push_back(op.getOperation());
                    return op.getResult();
                };
                mlir::Value one = mk(rewriter.create<mlir::arith::ConstantOp>(
                    loc, rewriter.getIntegerAttr(ivType, 1)));
                mlir::Value zero = mk(rewriter.create<mlir::arith::ConstantOp>(
                    loc, rewriter.getIntegerAttr(ivType, 0)));
                mlir::Value span =
                    mk(rewriter.create<mlir::arith::SubIOp>(loc, ub, lb));
                mlir::Value biased =
                    mk(rewriter.create<mlir::arith::AddIOp>(loc, span, step));
                mlir::Value numer =
                    mk(rewriter.create<mlir::arith::SubIOp>(loc, biased, one));
                mlir::Value trips =
                    isSigned ? mk(rewriter.create<mlir::arith::DivSIOp>(
                                   loc, numer, step))
                             : mk(rewriter.create<mlir::arith::DivUIOp>(
                                   loc, numer, step));
                mlir::Value clamped =
                    isSigned ? mk(rewriter.create<mlir::arith::MaxSIOp>(
                                   loc, trips, zero))
                             : mk(rewriter.create<mlir::arith::MaxUIOp>(
                                   loc, trips, zero));
                mlir::Value advance =
                    mk(rewriter.create<mlir::arith::MulIOp>(loc, clamped, step));
                mlir::Value exitIV =
                    mk(rewriter.create<mlir::arith::AddIOp>(loc, lb, advance));

                // Replace scf.while results with corresponding values evaluated at the exit
                // iteration: either the exit induction value or derived values recomputed from it.
                llvm::SmallVector<mlir::Value> replacements;
                rematerialize(exitIV, cond.getArgs(), replacements, tailMade);

                report("accept",
                       "uplifted a counted timestep while: step " +
                           std::to_string(*stepConst) + ", " +
                           (isSigned ? "signed" : "unsigned") + ", IV at "
                           "condition index " +
                           std::to_string(ivPositions.front()) + ", " +
                           std::to_string(derived.size()) +
                           " derived value(s) rematerialized, for-nest depth " +
                           std::to_string(depth));

                rewriter.replaceOp(loop, replacements);

                // Clean up any rematerialized operations that have no remaining uses.
                for (auto list : {&bodyMade, &tailMade})
                    for (mlir::Operation *op : llvm::reverse(*list))
                        if (op->use_empty())
                            rewriter.eraseOp(op);

                return mlir::success();
            }
        }

        #define GEN_PASS_DEF_UPLIFTWHILETOFORPASS
        #include "dialect/Passes.h.inc"

        struct UpliftWhileToForPass
            : public mlir::dhir::impl::UpliftWhileToForPassBase<
                  UpliftWhileToForPass>
        {
            using UpliftWhileToForPassBase::UpliftWhileToForPassBase;

            void runOnOperation() override
            {
                // Collect candidate loops prior to transformation to avoid mutating
                // the IR during traversal.
                llvm::SmallVector<mlir::scf::WhileOp> candidates;
                getOperation()->walk(
                    [&](mlir::scf::WhileOp op) { candidates.push_back(op); });

                mlir::IRRewriter rewriter(&getContext());
                for (mlir::scf::WhileOp op : candidates)
                {
                    rewriter.setInsertionPoint(op);
                    (void)upliftCountedWhile(op, rewriter);
                }
            }
        };
    } // namespace dhir
} // namespace mlir

#endif // UPLIFT_WHILE_TO_FOR_H

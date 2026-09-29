#ifndef DHIR_OWNERSHIP_ANALYSIS_H
#define DHIR_OWNERSHIP_ANALYSIS_H

// ===========================================================================
// Per-output, per-version distributed OWNERSHIP decision.
//
// Following a partitioned level execution, each rank retains only its local shard.
// Whether this shard must be transferred prior to the next consumer depends on
// the access pattern of subsequent readers for this specific buffer version:
//
//   * only same-owner shard readers            -> retain shard locally
//   * neighbour / halo readers                 -> exchange ghosts (stencil)
//   * externally observable terminal outputs   -> assemble on root node
//   * whole-buffer / cross-owner / unpartitioned readers -> materialize across all ranks
//
// This file computes ownership decisions purely from IR structural properties
// with full alias awareness: every buffer is traced to its base allocation via
// getMemRefAccess (depGraph.h) to ensure consumers using subviews or casts are
// properly tracked. Unproven access patterns conservatively default to
// MaterializeOnAllRanks.
//
// RetainOwnedShard elides per-iteration transfers for intermediate values that
// remain local to each rank. If an elided buffer is externally observable outside
// the loop, the final iteration's value is gathered once after loop termination
// (see isObservableOutput and DeferFrame::endpointGathers in conversions/dhirtompi.h).
//
// OutputOwnership provides a unified representation reconciling same-owner
// shard retention (e.g. CFD) and ghost cell exchange (e.g. Jacobi2d).
// ===========================================================================

#include "analysis/depGraph.h"      // TaskOpInfo, DependencyGraph, getMemRefAccess
#include "analysis/syncHoisting.h"  // nearestEnclosingSerialLoop
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Interfaces/CallInterfaces.h"
#include "llvm/ADT/SmallVector.h"
#include <algorithm>
#include <limits>
#include <string>

namespace mlir
{
    namespace dhir
    {
        // Controlled by dhir-opt's --print-ownership flag. Emits diagnostics
        // for per-output distributed ownership decisions when enabled.
        inline bool &printOwnershipDecisions()
        {
            static bool enabled = false;
            return enabled;
        }
        
        // The four strategies for handling a produced output version at level
        // synchronization, ordered from least to most communication overhead.
        enum class OwnershipKind
        {
            RetainOwnedShard,      // zero communication: each rank retains its written slab
            RefreshGhosts,         // halo exchange between neighbours (stencil kernels)
            MaterializeOnRoot,     // gather and assemble buffer onto root rank 0
            MaterializeOnAllRanks  // assemble on root, then broadcast to all participating ranks
        };

        inline llvm::StringRef ownershipKindName(OwnershipKind k)
        {
            switch (k)
            {
            case OwnershipKind::RetainOwnedShard:      return "RetainOwnedShard";
            case OwnershipKind::RefreshGhosts:         return "RefreshGhosts";
            case OwnershipKind::MaterializeOnRoot:     return "MaterializeOnRoot";
            case OwnershipKind::MaterializeOnAllRanks: return "MaterializeOnAllRanks";
            }
            return "MaterializeOnAllRanks";
        }

        // Ownership decision for a single (task, output-index) buffer version.
        struct OutputOwnership
        {
            OwnershipKind kind = OwnershipKind::MaterializeOnAllRanks;
            int64_t partitionDim = -1;   // axis sharded by the producer

            // Explicit emission directives so consumers do not need to infer intent.
            bool needsRootGather = true;        // send owner shards to root (assemble)
            bool needsAllRanksBroadcast = true; // broadcast assembled buffer from root to workers
            std::string reason;
        };

        // ------------------------------------------------------------------
        // Structural helpers (alias-aware, dynamic-shape safe).
        // ------------------------------------------------------------------

        // Identifies the single dimension sliced by `v`'s outermost subview, returning:
        //   -1  : `v` is not a subview, or the subview spans the full extent on all dimensions
        //   -2  : the subview slices multiple dimensions, or shapes cannot be resolved
        // A dimension is considered "full" if offset is constant 0 and size equals the
        // source extent. Dynamic offsets or sizes indicate a sliced dimension, allowing
        // detection of runtime-partitioned slabs without requiring compile-time static bounds.
        inline int64_t slicedSubviewDim(mlir::Value v)
        {
            auto sv = mlir::dyn_cast_or_null<mlir::memref::SubViewOp>(
                v.getDefiningOp());
            if (!sv)
                return -1;
            auto srcType = mlir::dyn_cast<mlir::MemRefType>(
                sv.getSource().getType());
            if (!srcType)
                return -2;
            llvm::SmallVector<mlir::OpFoldResult> offsets = sv.getMixedOffsets();
            llvm::SmallVector<mlir::OpFoldResult> sizes = sv.getMixedSizes();
            if ((int64_t)offsets.size() != srcType.getRank() ||
                (int64_t)sizes.size() != srcType.getRank())
                return -2;

            auto staticZero = [](mlir::OpFoldResult ofr) -> bool {
                if (auto attr = mlir::dyn_cast<mlir::Attribute>(ofr))
                    if (auto i = mlir::dyn_cast<mlir::IntegerAttr>(attr))
                        return i.getInt() == 0;
                return false;
            };
            auto staticEq = [](mlir::OpFoldResult ofr, int64_t v) -> bool {
                if (v == mlir::ShapedType::kDynamic)
                    return false;
                if (auto attr = mlir::dyn_cast<mlir::Attribute>(ofr))
                    if (auto i = mlir::dyn_cast<mlir::IntegerAttr>(attr))
                        return i.getInt() == v;
                return false;
            };

            int64_t sliced = -1;
            for (int64_t d = 0; d < srcType.getRank(); ++d)
            {
                bool fullDim = staticZero(offsets[d]) &&
                               staticEq(sizes[d], srcType.getDimSize(d));
                if (fullDim)
                    continue;
                if (sliced != -1)
                    return -2; // more than one sliced dim
                sliced = d;
            }
            return sliced;
        }

        // Returns the (offset, size) slice of a subview along `dim`, or nullopt
        // if `v` is not a SubViewOp or `dim` is out of bounds.
        inline std::optional<std::pair<mlir::OpFoldResult, mlir::OpFoldResult>>
        subviewRangeOnDim(mlir::Value v, int64_t dim)
        {
            auto sv = mlir::dyn_cast_or_null<mlir::memref::SubViewOp>(
                v.getDefiningOp());
            if (!sv || dim < 0)
                return std::nullopt;
            llvm::SmallVector<mlir::OpFoldResult> offsets = sv.getMixedOffsets();
            llvm::SmallVector<mlir::OpFoldResult> sizes = sv.getMixedSizes();
            if (dim >= (int64_t)offsets.size() || dim >= (int64_t)sizes.size())
                return std::nullopt;
            return std::make_pair(offsets[dim], sizes[dim]);
        }

        // Checks whether two index expressions represent structurally identical computations.
        // Accepts equal attributes, identical SSA values, or matching pure operations
        // applied to structurally equal operands. Supports dynamic partitioned bounds
        // computed by identical arithmetic chains across tasks. Recursion is depth-bounded.
        inline bool sameIndexExpr(mlir::OpFoldResult a, mlir::OpFoldResult b,
                                  unsigned depth = 0)
        {
            if (depth > 12)
                return false;
            auto attrA = mlir::dyn_cast<mlir::Attribute>(a);
            auto attrB = mlir::dyn_cast<mlir::Attribute>(b);
            if (attrA || attrB)
                return attrA && attrB && attrA == attrB;

            auto valA = mlir::cast<mlir::Value>(a);
            auto valB = mlir::cast<mlir::Value>(b);
            if (valA == valB)
                return true;

            mlir::Operation *defA = valA.getDefiningOp();
            mlir::Operation *defB = valB.getDefiningOp();
            if (!defA || !defB || defA->getName() != defB->getName() ||
                !mlir::isPure(defA) || !mlir::isPure(defB) ||
                defA->getNumOperands() != defB->getNumOperands() ||
                defA->getAttrDictionary() != defB->getAttrDictionary())
                return false;
            // Differentiate results of a multi-result operation.
            if (mlir::cast<mlir::OpResult>(valA).getResultNumber() !=
                mlir::cast<mlir::OpResult>(valB).getResultNumber())
                return false;
            for (auto [opndA, opndB] :
                 llvm::zip(defA->getOperands(), defB->getOperands()))
                if (!sameIndexExpr(mlir::OpFoldResult(opndA),
                                   mlir::OpFoldResult(opndB), depth + 1))
                    return false;
            return true;
        }

        // Checks whether two subviews cover structurally equivalent ranges along `dim`.
        inline bool sameShardRangeOnDim(mlir::Value a, mlir::Value b,
                                       int64_t dim)
        {
            auto rangeA = subviewRangeOnDim(a, dim);
            auto rangeB = subviewRangeOnDim(b, dim);
            if (!rangeA || !rangeB)
                return false;
            return sameIndexExpr(rangeA->first, rangeB->first) &&
                   sameIndexExpr(rangeA->second, rangeB->second);
        }

        inline mlir::Attribute taskPlacement(mlir::Operation *op)
        {
            if (auto taskOp = mlir::dyn_cast_or_null<mlir::dhir::TaskOp>(op))
                return taskOp.getTarget();
            return mlir::Attribute();
        }

        // Checks if `op` reads the underlying contents of `v` rather than merely
        // constructing an alias view or querying shape metadata. Mirrors broadcastAnalysis
        // so that unpartitioned consumer detection remains consistent across the compiler.
        inline bool opReadsMemref(mlir::Operation *op, mlir::Value v)
        {
            if (auto load = mlir::dyn_cast<mlir::memref::LoadOp>(op))
                return load.getMemRef() == v;
            if (auto load = mlir::dyn_cast<mlir::affine::AffineLoadOp>(op))
                return load.getMemRef() == v;
            if (auto copy = mlir::dyn_cast<mlir::memref::CopyOp>(op))
                return copy.getSource() == v || copy.getTarget() == v;
            if (mlir::isa<mlir::memref::StoreOp, mlir::affine::AffineStoreOp>(op))
                return false;
            if (mlir::isa<mlir::memref::SubViewOp, mlir::memref::CastOp,
                          mlir::memref::ReinterpretCastOp, mlir::memref::ViewOp,
                          mlir::memref::ExpandShapeOp,
                          mlir::memref::CollapseShapeOp,
                          mlir::memref::TransposeOp, mlir::memref::DimOp,
                          mlir::memref::AllocOp, mlir::memref::AllocaOp,
                          mlir::memref::DeallocOp>(op))
                return false;
            for (mlir::Value operand : op->getOperands())
                if (operand == v)
                    return true;
            return false;
        }

        inline bool isInsideTask(mlir::Operation *op)
        {
            for (mlir::Operation *p = op->getParentOp(); p; p = p->getParentOp())
                if (mlir::isa<mlir::dhir::TaskOp>(p))
                    return true;
            return false;
        }

        // Locates the enclosing operation scope that encapsulates all potential readers:
        // the parent ScheduleOp if available, or the outermost ancestor below ModuleOp.
        inline mlir::Operation *ownershipScope(mlir::Operation *op)
        {
            mlir::Operation *best = op->getParentOp();
            for (mlir::Operation *p = best; p; p = p->getParentOp())
            {
                if (mlir::isa<mlir::dhir::ScheduleOp>(p))
                    return p;
                if (!mlir::isa<mlir::ModuleOp>(p))
                    best = p;
            }
            return best;
        }

        // Checks whether `base` (or any of its aliasing views) is accessed by code
        // executing OUTSIDE of any TaskOp. Such operations run redundantly on all ranks
        // and require full buffer contents. Unresolved operations conservatively return true.
        inline bool hasUndistributedReaderIn(mlir::Operation *scope,
                                             mlir::Value base)
        {
            if (!scope)
                return true;
            bool found = false;
            scope->walk([&](mlir::Operation *op) {
                if (found)
                    return mlir::WalkResult::interrupt();
                if (mlir::isa<mlir::dhir::TaskOp>(op) || isInsideTask(op))
                    return mlir::WalkResult::advance();
                for (mlir::Value operand : op->getOperands())
                {
                    if (!mlir::isa<mlir::MemRefType>(operand.getType()))
                        continue;
                    if (getMemRefAccess(operand).baseMemRef != base)
                        continue;
                    if (opReadsMemref(op, operand))
                    {
                        found = true;
                        return mlir::WalkResult::interrupt();
                    }
                }
                return mlir::WalkResult::advance();
            });
            return found;
        }

        // Checks whether any undistributed reader exists within the entire ownership scope.
        inline bool hasUndistributedReader(mlir::Operation *producerOp,
                                           mlir::Value base)
        {
            return hasUndistributedReaderIn(ownershipScope(producerOp), base);
        }

        // Returns the enclosing ScheduleOp or FuncOp defining the compiled scope.
        // Values escaping this boundary belong to the caller.
        inline mlir::Operation *enclosingCompiledUnit(mlir::Operation *op)
        {
            for (mlir::Operation *p = op; p; p = p->getParentOp())
                if (mlir::isa<mlir::dhir::ScheduleOp, mlir::func::FuncOp>(p))
                    return p;
            return nullptr;
        }

        // Determines if the final version of `base` produced in a loop is externally observable.
        // If observable, the final iteration's output must be gathered after the loop even
        // when per-iteration intermediate transfers are elided. Conservatively returns true
        // for unproven cases (e.g., block arguments, escaping returns, or external calls).
        inline bool isObservableOutput(mlir::Operation *producerOp,
                                       mlir::Value base)
        {
            if (!base || !producerOp)
                return true;
            // Function/schedule arguments or loop-carried values are assumed observable.
            if (mlir::isa<mlir::BlockArgument>(base))
                return true;
            mlir::Operation *unit = enclosingCompiledUnit(producerOp);
            mlir::Operation *def = base.getDefiningOp();
            if (!unit || !def)
                return true;
            // Memory defined outside the compiled unit belongs to the caller.
            if (!unit->isAncestor(def))
                return true;
            // Internal allocations escape if returned or passed to a function call.
            for (mlir::Operation *user : base.getUsers())
                if (user->hasTrait<mlir::OpTrait::ReturnLike>() ||
                    mlir::isa<mlir::CallOpInterface>(user))
                    return true;
            return false;
        }

        // Checks whether `base` (or an alias) is referenced after `loop` finishes execution.
        // Post-loop deferred synchronizations can omit broadcasts if no surviving readers
        // exist following loop completion. Conservatively returns true if the loop is nested
        // in a recurring region or if any subsequent operation references the base allocation.
        inline bool hasReaderAfterLoop(mlir::Operation *loop, mlir::Value base)
        {
            if (!loop || !base)
                return true;
            mlir::Operation *unit = enclosingCompiledUnit(loop);
            if (!unit || loop->getParentOp() != unit)
                return true;

            bool found = false;
            for (mlir::Operation *next = loop->getNextNode();
                 next && !found; next = next->getNextNode())
            {
                // Traverse subsequent operations and all nested regions to detect references.
                next->walk([&](mlir::Operation *op) {
                    for (mlir::Value operand : op->getOperands())
                    {
                        if (!mlir::isa<mlir::MemRefType>(operand.getType()))
                            continue;
                        if (getMemRefAccess(operand).baseMemRef != base)
                            continue;
                        found = true;
                        return mlir::WalkResult::interrupt();
                    }
                    return mlir::WalkResult::advance();
                });
            }
            return found;
        }

        // Computes the synchronization requirement for output `writeIndex` of `producer`.
        // `graph` provides all other tasks for consumer classification;
        // `producer.actualBuffer[writeIndex]` represents the logical output buffer and
        // `partitionDim` denotes its partitioned dimension.
        //
        // RetainOwnedShard is selected only when all consumers access matching same-owner
        // shards along the identical partition dimension, no undistributed host readers exist,
        // and the producer is enclosed in a serial loop. Intermediate versions remain local,
        // while observable final outputs are assembled once post-loop via endpoint gathers.
        // All unproven access patterns fall back to assemble/broadcast.
        inline OutputOwnership decideOutputOwnership(
            const DependencyGraph &graph, const TaskOpInfo &producer,
            size_t writeIndex, int64_t partitionDim)
        {
            OutputOwnership decision;
            decision.partitionDim = partitionDim;

            mlir::Operation *producerOp = producer.op;

            // Stencil operations carry halo contracts; ghost exchanges are handled
            // by dedicated stencil lowering logic (e.g. Jacobi2d).
            if (producerOp && producerOp->hasAttr("stencil"))
            {
                decision.kind = OwnershipKind::RefreshGhosts;
                decision.needsRootGather = false;
                decision.needsAllRanksBroadcast = false;
                decision.reason = "stencil producer: neighbour halo exchange";
                return decision;
            }

            // No usable partition axis -> cannot reason about slabs; be safe.
            if (writeIndex >= producer.actualBuffer.size() || partitionDim < 0)
            {
                decision.kind = OwnershipKind::MaterializeOnAllRanks;
                decision.reason = "no proven partition axis; materialize on all";
                return decision;
            }

            mlir::Value logical = producer.actualBuffer[writeIndex];
            mlir::Value base = getMemRefAccess(logical).baseMemRef;
            if (!base)
            {
                decision.kind = OwnershipKind::MaterializeOnAllRanks;
                decision.reason = "output base allocation unknown; materialize on all";
                return decision;
            }

            // The producer's shard range along the partition axis for comparison against consumers.
            mlir::Value producerView =
                writeIndex < producer.writes.size() ? producer.writes[writeIndex]
                                                    : logical;
            mlir::Attribute producerPlacement = taskPlacement(producerOp);

            // Classify every reader of this buffer across all OTHER replicates.
            bool anyReader = false;
            bool anySameOwner = false;
            bool anyCrossOwner = false;
            for (const TaskOpInfo &consumer : graph.tasks)
            {
                if (&consumer == &producer)
                    continue;
                // Sibling shards belonging to the same replicate are concurrent peers,
                // not consumer tasks.
                if (consumer.repId == producer.repId)
                    continue;

                // Inspect accesses via read operands or read-modify-write reduction targets.
                auto classify = [&](mlir::Value r) {
                    if (!mlir::isa<mlir::MemRefType>(r.getType()))
                        return;
                    MemRefAccess acc = getMemRefAccess(r);
                    if (acc.baseMemRef != base)
                        return;
                    anyReader = true;
                    // An un-sliced access touches the full buffer across shards
                    // (e.g., cross-owner halo/neighbor reads).
                    if (!acc.isSubview)
                    {
                        anyCrossOwner = true;
                        return;
                    }
                    // Both task groups must partition the buffer identically: each consumer
                    // shard must match the producer shard assigned to the consumer's target device
                    // so that no data crosses rank boundaries.
                    if (slicedSubviewDim(r) != partitionDim)
                    {
                        anyCrossOwner = true;
                        return;
                    }
                    mlir::Attribute consumerPlacement =
                        taskPlacement(consumer.op);
                    if (!producerPlacement || !consumerPlacement)
                    {
                        anyCrossOwner = true;
                        return;
                    }
                    // Identify the producer shard located on the consumer's target device.
                    mlir::Value ownerView;
                    if (consumerPlacement == producerPlacement)
                        ownerView = producerView;
                    else
                    {
                        for (const TaskOpInfo &sibling : graph.tasks)
                        {
                            if (sibling.repId != producer.repId ||
                                taskPlacement(sibling.op) != consumerPlacement ||
                                writeIndex >= sibling.writes.size())
                                continue;
                            mlir::Value candidate = sibling.writes[writeIndex];
                            if (getMemRefAccess(candidate).baseMemRef != base)
                                continue;
                            ownerView = candidate;
                            break;
                        }
                    }
                    // If no corresponding producer shard exists on this device or ranges differ,
                    // communication across ranks is required.
                    if (!ownerView ||
                        !sameShardRangeOnDim(r, ownerView, partitionDim))
                    {
                        anyCrossOwner = true;
                        return;
                    }
                    anySameOwner = true;
                };
                for (mlir::Value r : consumer.reads)
                    classify(r);
                for (mlir::Value r : consumer.reduceTargets)
                    classify(r);
            }

            // A reader that runs outside every task sees the whole buffer.
            bool undistributed = hasUndistributedReader(producerOp, base);

            const bool inSerialLoop =
                nearestEnclosingSerialLoop(producerOp) != nullptr;

            if (anyCrossOwner || undistributed)
            {
                decision.kind = OwnershipKind::MaterializeOnAllRanks;
                decision.needsRootGather = true;
                decision.needsAllRanksBroadcast = true;
                decision.reason = undistributed
                    ? "read by undistributed code; materialize on all ranks"
                    : "read whole / cross-owner by a later task; materialize on all ranks";
                return decision;
            }

            if (anySameOwner && inSerialLoop)
            {
                // Every consumer reads exclusively this rank's local slab along the same
                // dimension, and the producer sits inside a serial loop that updates the
                // buffer on subsequent timesteps. Shards can safely remain local.
                decision.kind = OwnershipKind::RetainOwnedShard;
                decision.needsRootGather = false;
                decision.needsAllRanksBroadcast = false;
                decision.reason = "loop-carried intermediate read only as a same-"
                                  "owner shard; retain owned slab";
                return decision;
            }

            // Same-owner slab read outside an iterative loop, or terminal output without
            // subsequent consumers: assemble on root to ensure external visibility.
            // (Broadcast follows only if needBroadcast is set, matching existing behavior.)
            decision.kind = OwnershipKind::MaterializeOnRoot;
            decision.needsRootGather = true;
            decision.needsAllRanksBroadcast = false;
            decision.reason = anyReader
                ? "same-owner shard read outside a serial loop; assemble on root"
                : "no later reader (terminal/observable output); assemble on root";
            return decision;
        }

        // ===================================================================
        // PROFITABILITY FALLBACK: Decline distribution for communication-dominated
        // regions where collective transfer overhead cannot be amortized.
        //
        // While sharding analysis determines communication mechanics for partitioned
        // buffers, partition selection determines whether a region should be
        // sharded initially. Post-hoc communication elision risks leaving partial
        // buffers ungathered, causing subsequent readers to observe incomplete data.
        // Declining distribution before partitioning avoids this risk entirely by
        // preserving the original replicated loop structure: each rank redundantly
        // computes the complete output, satisfying all local readers without
        // introducing sharding, ownership, or aliasing hazards. A conservative
        // decline decision affects execution speed rather than program correctness.
        //
        // Two structural, IR-driven rules are evaluated under a common precondition,
        // without kernel-specific heuristics or weakened dependence constraints
        // (the ReplicateOp loop-independence proof is reused to drive thread-level
        // rather than rank-level parallelism):
        //
        //   PRECONDITION (All rules): All output buffers produced by the region
        //     are consumed by replicated code. Distributing the region would
        //     therefore require a global assemble-and-broadcast across all ranks
        //     to materialize the full buffer. This mirrors the MaterializeOnAllRanks
        //     condition identified in decideOutputOwnership, evaluated here prior
        //     to lowering.
        //
        //   RULE 1 ("Dead Payload"): The region writes to strictly fewer axes
        //     than the gather operation moves. When gather operations transfer
        //     full rank-R volumes while the kernel only writes across D < R axes,
        //     communication volume scales asymptotically as O(N^(R-D)) relative
        //     to computed work. For large problem sizes, communication overhead
        //     dominates computational throughput. (Example: Gaussian elimination
        //     updating a 1D column slice within a 2D matrix).
        //
        //   RULE 2 ("Constant Fill"): The region computes no dynamic values and
        //     only stores loop-invariant constants. Sharding distributes no
        //     arithmetic while still paying the full collective materialization
        //     cost. Local redundant initialization is strictly faster than
        //     network transfer. (Example: zero-initializing accumulators in K-means).
        //
        // The policy uses dimensional and structural analysis rather than static
        // cost modeling, ensuring robustness when dynamic buffer shapes and runtime
        // loop counts prevent static FLOP and byte quantification.
        //
        // CONSERVATIVE SAFEGUARDS:
        //   * Non-uniform iteration cost: If an unwritten dimension has a small
        //     static bound or iterations have high computational intensity,
        //     Rule 1 may decline distribution even if partitioning would be
        //     profitable; the region executes redundantly and correctly.
        //   * Interprocedural calls: Function calls inside the region inhibit
        //     declining, as work volume cannot be analyzed locally.
        //   * Syntactic store indexing: Unrecognized store patterns (e.g. copies,
        //     aliased views, or unresolvable indexing) inhibit declining and
        //     retain default distribution.
        //   * Reductions and scatters: Partial-reduction and scatter outputs are
        //     excluded; their transfers perform accumulation rather than redundant
        //     buffer gathering.
        //   Any ambiguous condition defaults to distribution, preserving baseline
        //   lowering behavior.
        //
        // SOUNDNESS OF REDUNDANT EXECUTION:
        // Redundant recomputation is deterministic (free of call operations and
        // side effects) and all input operands originate from replicated state
        // already consistent across ranks. In addition, computing the entire
        // output space on each rank guarantees that all buffer elements are
        // fully defined, preventing uninitialized memory reads.
        // ===================================================================

        // Controls whether partition profitability fallback is active
        // (configured via --profitability-fallback; disabled by default to
        // preserve baseline lowering behavior).
        inline bool &profitabilityFallbackEnabled()
        {
            static bool enabled = false;
            return enabled;
        }

        // Controls diagnostic logging for partition distribution decisions
        // (configured via --print-distribution-decisions; disabled by default).
        inline bool &printDistributionDecisions()
        {
            static bool enabled = false;
            return enabled;
        }

        struct DistributionDecision
        {
            bool distribute = true;
            llvm::StringRef rule = "none";   // Specific profitability rule applied.
            std::string reason;
            // Dimensional metrics recorded for diagnostic auditing.
            int64_t writtenDims = -1;
            int64_t outputRank = -1;
        };

        // Determines whether `op` is nested within a distributed region (either an
        // already-lowered dhir.task or a pending dhir.replicate). During lowering,
        // both operations coexist; recognizing both prevents unlowered sibling
        // replicates from being incorrectly classified as replicated code.
        inline bool isInsideDistributedRegion(mlir::Operation *op)
        {
            for (mlir::Operation *p = op->getParentOp(); p; p = p->getParentOp())
                if (mlir::isa<mlir::dhir::TaskOp, mlir::dhir::ReplicateOp>(p))
                    return true;
            return false;
        }

        // Pre-lowering counterpart to hasUndistributedReaderIn: determines whether
        // `base` (or an alias resolving to the same underlying allocation) is read
        // by code executing on all ranks. Uses alias analysis via getMemRefAccess.
        // Returns false if readers cannot be conclusively established, ensuring
        // conservative retention of distribution.
        inline bool hasReplicatedReaderPreLowering(mlir::Operation *scope,
                                                   mlir::Value base)
        {
            if (!scope || !base)
                return false; // Precondition unverified; retain distribution.
            bool found = false;
            scope->walk([&](mlir::Operation *op) {
                if (found)
                    return mlir::WalkResult::interrupt();
                if (mlir::isa<mlir::dhir::TaskOp, mlir::dhir::ReplicateOp>(op) ||
                    isInsideDistributedRegion(op))
                    return mlir::WalkResult::advance();
                for (mlir::Value operand : op->getOperands())
                {
                    if (!mlir::isa<mlir::MemRefType>(operand.getType()))
                        continue;
                    if (getMemRefAccess(operand).baseMemRef != base)
                        continue;
                    if (opReadsMemref(op, operand))
                    {
                        found = true;
                        return mlir::WalkResult::interrupt();
                    }
                }
                return mlir::WalkResult::advance();
            });
            return found;
        }

        // Determines whether `value` varies across loop iterations internal to
        // `region`. Returns true for loop induction variables and dependent
        // intermediate values defined inside `region`. Values defined outside
        // (such as kernel arguments, outer loop variables, or constants) are
        // invariant across this region's execution.
        inline bool varsWithinRegion(mlir::Operation *region, mlir::Value value,
                                     unsigned depth = 0)
        {
            if (depth > 24)
                return true; // Recursion limit reached; assume varying.
            if (!region || !value)
                return true;
            if (auto arg = mlir::dyn_cast<mlir::BlockArgument>(value))
            {
                mlir::Operation *owner = arg.getOwner()->getParentOp();
                // Block arguments belonging to nested blocks represent induction
                // variables or region-carried loop state.
                return owner && region->isAncestor(owner);
            }
            mlir::Operation *def = value.getDefiningOp();
            if (!def || !region->isAncestor(def))
                return false; // Defined externally; invariant across region execution.
            for (mlir::Value operand : def->getOperands())
                if (varsWithinRegion(region, operand, depth + 1))
                    return true;
            return false;
        }

        // Counts the number of distinct dimensions of `out` modified by stores
        // within `region` whose index expressions vary across inner iterations.
        // The count is unioned across all stores to conservatively overestimate
        // written axes (favoring distribution).
        //
        // Returns -1 if store indices cannot be statically verified (such as
        // indirect stores through views, copies, or unhandled access patterns),
        // which prevents distribution from being declined.
        inline int64_t countVaryingStoreDims(mlir::Operation *region,
                                             mlir::Value out)
        {
            auto type = out ? mlir::dyn_cast<mlir::MemRefType>(out.getType())
                            : mlir::MemRefType();
            if (!region || !out || !type)
                return -1;
            mlir::Value base = getMemRefAccess(out).baseMemRef;
            llvm::SmallVector<bool> varying(type.getRank(), false);
            bool sawStore = false;
            bool unclear = false;

            region->walk([&](mlir::Operation *op) {
                mlir::Value target;
                llvm::SmallVector<mlir::Value> indices;
                if (auto st = mlir::dyn_cast<mlir::memref::StoreOp>(op))
                {
                    target = st.getMemRef();
                    indices.assign(st.getIndices().begin(), st.getIndices().end());
                }
                else if (auto st = mlir::dyn_cast<mlir::affine::AffineStoreOp>(op))
                {
                    target = st.getMemRef();
                    indices.assign(st.getMapOperands().begin(),
                                   st.getMapOperands().end());
                }
                else if (auto cp = mlir::dyn_cast<mlir::memref::CopyOp>(op))
                {
                    // Full-buffer copy operations are not represented by the
                    // element-wise store proxy.
                    if (getMemRefAccess(cp.getTarget()).baseMemRef == base)
                        unclear = true;
                    return;
                }
                else
                    return;

                if (getMemRefAccess(target).baseMemRef != base)
                    return;
                if (target != out)
                {
                    // Target accesses the base allocation via an alias or view.
                    unclear = true;
                    return;
                }
                sawStore = true;

                if (auto affineStore =
                        mlir::dyn_cast<mlir::affine::AffineStoreOp>(op))
                {
                    // In affine stores, dimension d corresponds to the d-th affine
                    // map result. Mark dimension d varying if any dependent operand
                    // varies within the region.
                    mlir::AffineMap map = affineStore.getAffineMap();
                    if ((int64_t)map.getNumResults() != type.getRank())
                    {
                        unclear = true;
                        return;
                    }
                    for (int64_t d = 0; d < type.getRank(); ++d)
                    {
                        mlir::AffineExpr expr = map.getResult(d);
                        for (unsigned pos = 0; pos < indices.size(); ++pos)
                        {
                            bool used = pos < map.getNumDims()
                                            ? expr.isFunctionOfDim(pos)
                                            : expr.isFunctionOfSymbol(
                                                  pos - map.getNumDims());
                            if (used && varsWithinRegion(region, indices[pos]))
                            {
                                varying[d] = true;
                                break;
                            }
                        }
                    }
                    return;
                }

                if ((int64_t)indices.size() != type.getRank())
                {
                    unclear = true;
                    return;
                }
                for (int64_t d = 0; d < type.getRank(); ++d)
                    if (varsWithinRegion(region, indices[d]))
                        varying[d] = true;
            });

            if (unclear || !sawStore)
                return -1;
            int64_t count = 0;
            for (bool v : varying)
                if (v)
                    ++count;
            return count;
        }

        // Identifies whether `region` performs constant initialization (fill),
        // storing only loop-invariant values into memory. Such regions involve
        // no distributed arithmetic to offset buffer gather/scatter overhead.
        //
        // Verification is structural: control-flow and terminators are ignored,
        // stores must write region-invariant values, and all other operations
        // must be side-effect free (excluding loads, copies, calls, and allocations).
        inline bool isConstantFillRegion(mlir::Operation *region)
        {
            if (!region)
                return false;
            bool fill = true;
            bool sawStore = false;
            region->walk([&](mlir::Operation *op) {
                if (!fill)
                    return mlir::WalkResult::interrupt();
                if (op == region)
                    return mlir::WalkResult::advance();
                if (mlir::isa<mlir::scf::ForOp, mlir::affine::AffineForOp,
                              mlir::scf::ParallelOp>(op))
                {
                    // Loop carrying values represents iterative computation rather
                    // than pure initialization.
                    if (op->getNumResults() != 0)
                    {
                        fill = false;
                        return mlir::WalkResult::interrupt();
                    }
                    return mlir::WalkResult::advance();
                }
                if (op->hasTrait<mlir::OpTrait::IsTerminator>())
                    return mlir::WalkResult::advance();

                mlir::Value stored;
                if (auto st = mlir::dyn_cast<mlir::memref::StoreOp>(op))
                    stored = st.getValue();
                else if (auto st = mlir::dyn_cast<mlir::affine::AffineStoreOp>(op))
                    stored = st.getValue();
                if (stored)
                {
                    sawStore = true;
                    if (varsWithinRegion(region, stored))
                    {
                        fill = false;
                        return mlir::WalkResult::interrupt();
                    }
                    return mlir::WalkResult::advance();
                }

                // Remaining operations must be purely computational (e.g. constant
                // definitions or index calculations) without side effects.
                if (!mlir::isMemoryEffectFree(op))
                {
                    fill = false;
                    return mlir::WalkResult::interrupt();
                }
                return mlir::WalkResult::advance();
            });
            return fill && sawStore;
        }

        // Evaluates whether `op` should be distributed or executed locally.
        // `outs` specifies declared output buffers and `partialReduceOut` indicates
        // per-output scatter/reduction status.
        inline DistributionDecision decideDistribution(
            mlir::dhir::ReplicateOp op, llvm::ArrayRef<mlir::Value> outs,
            llvm::ArrayRef<bool> partialReduceOut, bool isStencil)
        {
            DistributionDecision keep;
            mlir::Operation *region = op.getOperation();

            if (!profitabilityFallbackEnabled())
            {
                keep.reason = "policy off (--profitability-fallback not given)";
                return keep;
            }
            if (isStencil)
            {
                keep.reason = "stencil: halo contract owns this region";
                return keep;
            }
            if (outs.empty())
            {
                keep.reason = "no declared outputs";
                return keep;
            }
            for (bool pr : partialReduceOut)
                if (pr)
                {
                    keep.reason = "scatter/reduction output: the transfer is a "
                                  "sum, which IS the distribution";
                    return keep;
                }
            // Functions containing calls cannot be statically audited for work volume.
            bool sawCall = false;
            region->walk([&](mlir::Operation *inner) {
                if (mlir::isa<mlir::CallOpInterface>(inner))
                    sawCall = true;
            });
            if (sawCall)
            {
                keep.reason = "region contains a call: work not analysable";
                return keep;
            }

            // PRECONDITION: All outputs must have replicated readers, requiring
            // complete buffer gathering and broadcasting if distributed.
            mlir::Operation *scope = ownershipScope(region);
            for (mlir::Value out : outs)
            {
                mlir::Value base = getMemRefAccess(out).baseMemRef;
                if (!base || !hasReplicatedReaderPreLowering(scope, base))
                {
                    keep.reason = "an output has no proven replicated reader; "
                                  "its shard may not need materializing";
                    return keep;
                }
            }

            // RULE 2: Constant fill regions contain no arithmetic to distribute.
            if (isConstantFillRegion(region))
            {
                DistributionDecision decline;
                decline.distribute = false;
                decline.rule = "constant-fill";
                decline.reason = "region only stores region-invariant values, so "
                                 "sharding distributes no arithmetic while still "
                                 "materializing every output on every rank";
                return decline;
            }

            // RULE 1: Lower-dimensional writes relative to gathered buffer volume.
            // Requiring this condition across all outputs ensures that partially-written
            // buffers do not trigger false declines.
            int64_t minWritten = std::numeric_limits<int64_t>::max();
            int64_t maxRank = 0;
            for (mlir::Value out : outs)
            {
                auto type = mlir::dyn_cast<mlir::MemRefType>(out.getType());
                if (!type)
                {
                    keep.reason = "output is not a ranked memref";
                    return keep;
                }
                int64_t written = countVaryingStoreDims(region, out);
                if (written < 0)
                {
                    keep.reason = "output's written axes could not be established";
                    return keep;
                }
                if (written >= type.getRank())
                {
                    keep.writtenDims = written;
                    keep.outputRank = type.getRank();
                    keep.reason = "output is written on every axis the transfer "
                                  "moves: payload matches the work produced";
                    return keep;
                }
                minWritten = std::min(minWritten, written);
                maxRank = std::max(maxRank, type.getRank());
            }

            DistributionDecision decline;
            decline.distribute = false;
            decline.rule = "dead-payload";
            decline.writtenDims = minWritten;
            decline.outputRank = maxRank;
            decline.reason = "region writes a lower-dimensional slice than the "
                             "gather moves, so the payload grows faster than the "
                             "work being distributed";
            return decline;
        }

        // Emits diagnostic logging for partition decisions under --print-distribution-decisions.
        inline void logDistributionDecision(mlir::dhir::ReplicateOp op,
                                            const DistributionDecision &d,
                                            int64_t numDevices)
        {
            if (!printDistributionDecisions())
                return;
            llvm::StringRef schedule = "<unknown>";
            if (auto sch = op->getParentOfType<mlir::dhir::ScheduleOp>())
                schedule = sch.getScheduleName();
            int64_t repId = -1;
            if (auto attr = op->getAttrOfType<mlir::IntegerAttr>("replicateID"))
                repId = attr.getInt();
            llvm::errs() << "[distribute] schedule=" << schedule
                         << " repId=" << repId << " P=" << numDevices << " -> "
                         << (d.distribute ? "DISTRIBUTE" : "DECLINE")
                         << " rule=" << d.rule;
            if (d.writtenDims >= 0)
                llvm::errs() << " writtenDims=" << d.writtenDims
                             << " outputRank=" << d.outputRank;
            llvm::errs() << " (" << d.reason << ")\n";
        }

    } // namespace dhir
} // namespace mlir

#endif // DHIR_OWNERSHIP_ANALYSIS_H

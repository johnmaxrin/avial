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
// This decision is derived purely from IR structural properties (without
// kernel-specific heuristics) and is explicitly ALIAS-AWARE: each buffer is
// traced back to its root allocation via getMemRefAccess (depGraph.h), ensuring
// consumers accessing data through subviews or casts are accurately tracked.
// Any unproven access patterns conservatively default to MaterializeOnAllRanks,
// guaranteeing that transfers are only elided when provably redundant.
//
// OutputOwnership provides a unified representation reconciling same-owner
// shard retention (e.g. CFD) and ghost cell exchange (e.g. Jacobi2d).
// ===========================================================================

#include "analysis/depGraph.h"      // TaskOpInfo, DependencyGraph, getMemRefAccess
#include "analysis/syncHoisting.h"  // nearestEnclosingSerialLoop
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "llvm/ADT/SmallVector.h"
#include <string>

namespace mlir
{
    namespace dhir
    {
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
        inline bool hasUndistributedReader(mlir::Operation *producerOp,
                                           mlir::Value base)
        {
            mlir::Operation *scope = ownershipScope(producerOp);
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

        // Computes the synchronization requirement for output `writeIndex` of `producer`.
        // `graph` provides all other tasks for consumer classification;
        // `producer.actualBuffer[writeIndex]` represents the logical output buffer and
        // `partitionDim` denotes its partitioned dimension.
        //
        // Conservative by construction: RetainOwnedShard is selected ONLY when all
        // readers access strictly the same rank's slab along the same dimension, no
        // unpartitioned host readers exist, and the producer resides within an enclosing
        // serial loop (guaranteeing that the buffer is an intermediate version overwritten
        // on subsequent iterations). All other scenarios trigger assembly/broadcast.
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
                    // Slicing on the exact same axis indicates access to this rank's own slab;
                    // any other slicing orientation cannot be proven owner-aligned.
                    if (slicedSubviewDim(r) == partitionDim)
                        anySameOwner = true;
                    else
                        anyCrossOwner = true;
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

    } // namespace dhir
} // namespace mlir

#endif // DHIR_OWNERSHIP_ANALYSIS_H

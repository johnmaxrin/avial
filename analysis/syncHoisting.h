#ifndef SYNC_HOISTING_H
#define SYNC_HOISTING_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "llvm/Support/raw_ostream.h"
#include <cstdlib>

#include "arrayPartitionAnalysis.h"
#include "includes/dhirOps.h"
#include "includes/dhirDialect.h"

namespace mlir
{
    namespace dhir
    {
        // ====================================================================
        // DEFERRED SYNCHRONIZATION
        //
        // A replicate nested in a serial loop is synced after every iteration
        // because its shard may feed the next one.  When the shard is
        // *slab-local* -- every access addresses the partitioned dimension
        // with the shard's own IV at offset zero -- rank r only touches its
        // own slab, whose value depends only on its own history, so one
        // gather after the loop is enough.  Indices on the *other* dimensions
        // are unconstrained (they may be indirect, e.g. contcenters writes
        // coord[assign[i]][d]); only the partitioned dimension decides
        // locality.  A halo access fails the offset-zero test, which is what
        // keeps stencils on their per-iteration exchange.
        // ====================================================================

        // The nearest serial loop enclosing `op`, or null.  This is the loop a
        // deferred sync would be emitted after.
        inline mlir::Operation *nearestEnclosingSerialLoop(mlir::Operation *op)
        {
            for (mlir::Operation *p = op->getParentOp(); p; p = p->getParentOp())
            {
                if (mlir::isa<mlir::scf::ForOp, mlir::scf::WhileOp,
                              mlir::affine::AffineForOp>(p))
                    return p;
                if (mlir::isa<mlir::dhir::ScheduleOp>(p))
                    return nullptr;
            }
            return nullptr;
        }

        // The IV the partition analysis would shard on: the first loop in a
        // pre-order walk of the region, matching analyzeArrayForPartitioning.
        inline mlir::Value shardInductionVar(mlir::Operation *root)
        {
            mlir::Value iv;
            root->walk<mlir::WalkOrder::PreOrder>([&](mlir::Operation *op) {
                if (auto af = mlir::dyn_cast<mlir::affine::AffineForOp>(op))
                {
                    iv = af.getInductionVar();
                    return mlir::WalkResult::interrupt();
                }
                if (auto sf = mlir::dyn_cast<mlir::scf::ForOp>(op))
                {
                    iv = sf.getInductionVar();
                    return mlir::WalkResult::interrupt();
                }
                if (auto pf = mlir::dyn_cast<mlir::scf::ParallelOp>(op))
                {
                    if (!pf.getInductionVars().empty())
                        iv = pf.getInductionVars()[0];
                    return mlir::WalkResult::interrupt();
                }
                return mlir::WalkResult::advance();
            });
            return iv;
        }

        // Checks if an operation creates a view of another memref without modifying
        // its contents. These ops accept the viewed memref as their first operand,
        // allowing graph traversals to trace view chains without per-op accessors.
        inline bool isViewFormingOp(mlir::Operation *op)
        {
            return mlir::isa<mlir::memref::SubViewOp, mlir::memref::CastOp,
                             mlir::memref::ReinterpretCastOp,
                             mlir::memref::ExpandShapeOp,
                             mlir::memref::CollapseShapeOp,
                             mlir::memref::TransposeOp,
                             mlir::memref::ViewOp>(op);
        }

        // Resolves the root allocation that `value` ultimately references.
        inline mlir::Value viewRoot(mlir::Value value)
        {
            while (mlir::Operation *def = value.getDefiningOp())
            {
                if (!isViewFormingOp(def) || def->getNumOperands() == 0 ||
                    !mlir::isa<mlir::MemRefType>(def->getOperand(0).getType()))
                    break;
                value = def->getOperand(0);
            }
            return value;
        }

        // Discovers all values that may alias the same physical storage as `buffer`.
        //
        // Ascending to the root allocation before traversing downward ensures the
        // alias set is fully closed. Tracing only downward from `buffer` would omit
        // the original base buffer and any sibling views derived from that base,
        // which share the exact same underlying memory.
        inline llvm::SmallVector<mlir::Value> aliasSetOf(mlir::Value buffer)
        {
            llvm::SmallVector<mlir::Value> aliases;
            aliases.push_back(viewRoot(buffer));
            for (unsigned i = 0; i < aliases.size(); ++i)
                for (mlir::Operation *user : aliases[i].getUsers())
                    if (isViewFormingOp(user))
                        for (mlir::Value res : user->getResults())
                            if (mlir::isa<mlir::MemRefType>(res.getType()) &&
                                !llvm::is_contained(aliases, res))
                                aliases.push_back(res);
            if (!llvm::is_contained(aliases, buffer))
                aliases.push_back(buffer);
            return aliases;
        }

        // Checks whether `value` is defined within `container` or any of its nested regions.
        inline bool definedInsideOp(mlir::Value value, mlir::Operation *container)
        {
            mlir::Operation *owner = nullptr;
            if (auto arg = mlir::dyn_cast<mlir::BlockArgument>(value))
                owner = arg.getOwner()->getParentOp();
            else
                owner = value.getDefiningOp();
            return owner && container->isAncestor(owner);
        }

        // Determines if `value` remains invariant across all iterations of `loop`.
        // Values defined outside the loop are invariant; values defined inside qualify
        // only if produced by pure operations whose operands are themselves invariant.
        // Memory loads, loop induction variables, and iter_args are not invariant.
        inline bool isInvariantAcrossLoop(mlir::Value value, mlir::Operation *loop)
        {
            if (!value)
                return false;
            if (!definedInsideOp(value, loop))
                return true;
            mlir::Operation *def = value.getDefiningOp();
            if (!def || !mlir::isPure(def))
                return false;
            for (mlir::Value operand : def->getOperands())
                if (!isInvariantAcrossLoop(operand, loop))
                    return false;
            return true;
        }

        // Verifies whether the partitioned loop's bounds remain invariant across `loop`.
        //
        // Slab locality is valid only when shard boundaries remain fixed across
        // enclosing iterations. If loop bounds vary across timesteps (e.g., `for i = 0 to t+1`),
        // ownership of elements shifts between ranks on each iteration, invalidating
        // the assumption that each rank maintains a fixed slab for final gathering.
        inline bool shardBoundsInvariant(mlir::Value shardIV, mlir::Operation *loop)
        {
            auto arg = mlir::dyn_cast<mlir::BlockArgument>(shardIV);
            mlir::Operation *shardLoop = arg ? arg.getOwner()->getParentOp() : nullptr;
            if (!shardLoop)
                return false;

            llvm::SmallVector<mlir::Value, 6> extent;
            if (auto sf = mlir::dyn_cast<mlir::scf::ForOp>(shardLoop))
            {
                extent.push_back(sf.getLowerBound());
                extent.push_back(sf.getUpperBound());
                extent.push_back(sf.getStep());
            }
            else if (auto pf = mlir::dyn_cast<mlir::scf::ParallelOp>(shardLoop))
            {
                extent.append(pf.getLowerBound().begin(), pf.getLowerBound().end());
                extent.append(pf.getUpperBound().begin(), pf.getUpperBound().end());
                extent.append(pf.getStep().begin(), pf.getStep().end());
            }
            else if (auto af = mlir::dyn_cast<mlir::affine::AffineForOp>(shardLoop))
            {
                // The step is an attribute; only the bound operands can move.
                extent.append(af.getLowerBoundOperands().begin(),
                              af.getLowerBoundOperands().end());
                extent.append(af.getUpperBoundOperands().begin(),
                              af.getUpperBoundOperands().end());
            }
            else
                return false; // an unrecognised loop form is not a proof

            for (mlir::Value bound : extent)
                if (!isInvariantAcrossLoop(bound, loop))
                    return false;
            return true;
        }

        // Does every access to `buffer` inside `replicateOp` stay within the
        // rank's own slab of `partitionDim`?
        inline bool accessesStayInOwnSlab(mlir::Operation *replicateOp,
                                          mlir::Value buffer, mlir::Value shardIV,
                                          int partitionDim)
        {
            if (!shardIV || partitionDim < 0)
                return false;

            ArrayPartitioningAnalysis analysis(replicateOp, shardIV);
            llvm::SmallVector<mlir::Value> aliases = aliasSetOf(buffer);
            bool local = true;
            bool sawAccess = false;

            auto inspect = [&](mlir::Operation *access, mlir::Value memref) {
                if (!local)
                    return;
                if (memref != buffer)
                {
                    // Memory is accessed through an aliasing view: reported dimension
                    // and offset coordinates correspond to the view rather than the base
                    // buffer, so slab containment cannot be proven. Safely decline deferral.
                    if (llvm::is_contained(aliases, memref))
                        local = false;
                    return;
                }
                sawAccess = true;
                auto exact = analysis.getUnitStrideDimensionAndOffset(access, shardIV);
                // Not expressible as IV(+/-const) on a single dimension, a
                // different dimension, or a non-zero offset (a neighbour's
                // slab) all mean this rank reaches outside its own data.
                if (!exact || exact->first != partitionDim || exact->second != 0)
                    local = false;
            };

            replicateOp->walk([&](mlir::Operation *op) {
                if (auto ld = mlir::dyn_cast<mlir::memref::LoadOp>(op))
                    inspect(op, ld.getMemRef());
                else if (auto st = mlir::dyn_cast<mlir::memref::StoreOp>(op))
                    inspect(op, st.getMemRef());
                else if (auto ld = mlir::dyn_cast<mlir::affine::AffineLoadOp>(op))
                    inspect(op, ld.getMemRef());
                else if (auto st = mlir::dyn_cast<mlir::affine::AffineStoreOp>(op))
                    inspect(op, st.getMemRef());
            });

            return local && sawAccess;
        }

        // Only direct memory accesses prevent deferral: view-forming operations and
        // shape queries (memref.dim) merely create aliases or inspect metadata.
        // Because lowering generates these beside the replicate, treating them as
        // conflicting memory accesses would reject every valid candidate.
        inline bool touchedElsewhereInLoop(mlir::Operation *loop,
                                           mlir::Operation *replicateOp,
                                           mlir::Value buffer)
        {
            const bool trace = ::getenv("DHIR_TRACE_HOIST") != nullptr;

            llvm::SmallVector<mlir::Value> aliases = aliasSetOf(buffer);
            
            auto isAlias = [&](mlir::Value v) {
                return llvm::is_contained(aliases, v);
            };

            bool touched = false;
            loop->walk([&](mlir::Operation *op) {
                if (touched)
                    return mlir::WalkResult::interrupt();
                if (op == replicateOp || replicateOp->isProperAncestor(op))
                    return mlir::WalkResult::advance();

                bool accesses = false;
                if (auto ld = mlir::dyn_cast<mlir::memref::LoadOp>(op))
                    accesses = isAlias(ld.getMemRef());
                else if (auto st = mlir::dyn_cast<mlir::memref::StoreOp>(op))
                    accesses = isAlias(st.getMemRef());
                else if (auto ld = mlir::dyn_cast<mlir::affine::AffineLoadOp>(op))
                    accesses = isAlias(ld.getMemRef());
                else if (auto st = mlir::dyn_cast<mlir::affine::AffineStoreOp>(op))
                    accesses = isAlias(st.getMemRef());
                else if (auto cp = mlir::dyn_cast<mlir::memref::CopyOp>(op))
                    accesses = isAlias(cp.getSource()) || isAlias(cp.getTarget());
                else if (mlir::isa<mlir::memref::SubViewOp, mlir::memref::CastOp,
                                   mlir::memref::ReinterpretCastOp,
                                   mlir::memref::ExpandShapeOp,
                                   mlir::memref::CollapseShapeOp,
                                   mlir::memref::TransposeOp,
                                   mlir::memref::ViewOp,
                                   mlir::memref::DimOp, mlir::memref::RankOp,
                                   mlir::memref::AllocOp, mlir::memref::AllocaOp,
                                   mlir::memref::DeallocOp,
                                   mlir::dhir::ReplicateOp>(op))
                    accesses = false; // view, metadata, or an operand declaration
                else
                    for (mlir::Value operand : op->getOperands())
                        if (isAlias(operand))
                        {
                            accesses = true; // unknown op holding the buffer
                            break;
                        }

                if (!accesses)
                    return mlir::WalkResult::advance();
                if (trace)
                    llvm::errs() << "  [hoist]   accessed by: " << op->getName()
                                 << "\n";
                touched = true;
                return mlir::WalkResult::interrupt();
            });
            return touched;
        }

        // May this replicate's synchronization be deferred until after the
        // serial loop it sits in?  Every written buffer must be slab-local and
        // untouched elsewhere in that loop; otherwise the per-iteration sync
        // stands.  `loopOut` receives the loop to emit the sync after.
        inline bool canDeferSyncOutOfLoop(mlir::Operation *replicateOp,
                                          mlir::Operation *&loopOut)
        {
            loopOut = nullptr;
            auto rep = mlir::dyn_cast<mlir::dhir::ReplicateOp>(replicateOp);
            if (!rep)
                return false;

            const bool trace = ::getenv("DHIR_TRACE_HOIST") != nullptr;
            auto reject = [&](const char *why) {
                if (trace)
                    llvm::errs() << "  [hoist] reject: " << why << "\n";
                return false;
            };

            mlir::Operation *loop = nearestEnclosingSerialLoop(replicateOp);
            if (!loop)
                return reject("no enclosing serial loop");

            mlir::Value shardIV = shardInductionVar(replicateOp);
            if (!shardIV)
                return reject("no shard induction variable");

            llvm::SmallVector<mlir::Value> buffers(rep.getWrites());
            if (buffers.empty())
                return reject("no write buffers");

            for (mlir::Value buffer : buffers)
            {
                auto memTy = mlir::dyn_cast<mlir::MemRefType>(buffer.getType());
                if (!memTy)
                    return reject("write is not a memref");

                // Storage must persist across all iterations. Reallocating the buffer
                // inside the loop assigns distinct memory per iteration, meaning a
                // hoisted gather would collect only the final iteration's results.
                if (!isInvariantAcrossLoop(buffer, loop))
                    return reject("write buffer is not the same allocation on "
                                  "every iteration");

                ArrayPartitioningInfo info =
                    analyzeArrayForPartitioning(replicateOp, buffer);
                if (trace)
                    llvm::errs() << "  [hoist] write buffer: strategy="
                                 << (int)info.strategy << " dim="
                                 << info.partitionDimension << " halo="
                                 << info.haloLeft << "/" << info.haloRight
                                 << " (" << info.partitionReason << ")\n";
                if (info.strategy == ArrayPartitioningInfo::NO_PARTITION)
                    return reject("write output is NO_PARTITION");
                if (info.partitionDimension < 0)
                    return reject("write output has no partition dimension");
                if (info.haloLeft || info.haloRight)
                    return reject("write output needs a halo");

                if (!accessesStayInOwnSlab(replicateOp, buffer, shardIV,
                                           info.partitionDimension))
                    return reject("write accesses leave this rank's slab");

                if (touchedElsewhereInLoop(loop, replicateOp, buffer))
                    return reject("buffer touched elsewhere inside the loop");
            }

            // Reads must be slab-local too, or a rank would consume a slab it
            // never received.  A read left whole (NO_PARTITION) is replicated
            // on every rank and stays valid, so only partitioned reads are
            // constrained.
            for (mlir::Value buffer : rep.getReads())
            {
                if (!mlir::isa<mlir::MemRefType>(buffer.getType()))
                    continue;
                ArrayPartitioningInfo info =
                    analyzeArrayForPartitioning(replicateOp, buffer);
                if (trace)
                    llvm::errs() << "  [hoist] read buffer: strategy="
                                 << (int)info.strategy << " dim="
                                 << info.partitionDimension << " halo="
                                 << info.haloLeft << "/" << info.haloRight
                                 << "\n";
                if (info.strategy == ArrayPartitioningInfo::NO_PARTITION)
                    continue;
                if (info.haloLeft || info.haloRight)
                    return reject("read input needs a halo");
                if (!accessesStayInOwnSlab(replicateOp, buffer, shardIV,
                                           info.partitionDimension))
                    return reject("read accesses leave this rank's slab");
            }

            loopOut = loop;
            return true;
        }
        // ====================================================================
        // Resident Stencil Loops (Schedule IR / TaskOps)
        //
        // A stencil task reads its input array with a halo. When that input is
        // loop-carried (i.e. modified in-place by another task in the same
        // sequential loop), the buffer represents evolving loop state. Each
        // rank's owned partition is valid at the start of every iteration;
        // only boundary ghost rows reaching into neighbor partitions are stale.
        // In this case, arrays can remain resident across iterations: exchange
        // only ghost rows per iteration and defer the full-array gather until
        // loop termination, avoiding per-step gather/broadcast overhead.
        //
        // Uses viewRoot and aliasSetOf to conservatively track writes through
        // subviews or type casts as loop-carried writers. If loop-carried state
        // cannot be proven, the loop is treated as non-resident and retains
        // per-iteration full synchronization.
        // ====================================================================

        // Identifies the loop-carried state array read by a stencil task:
        // an input memref whose allocation is invariant across loop iterations
        // and is written by another task within the same loop. Returns null if
        // no such input exists (disqualifying the stencil from resident mode).
        inline mlir::Value stencilCarriedInput(mlir::dhir::TaskOp stencilTask,
                                               mlir::Operation *loop)
        {
            if (!stencilTask || !stencilTask->hasAttr("stencil") || !loop)
                return mlir::Value();

            for (mlir::Value in : stencilTask.getInputs())
            {
                if (!mlir::isa<mlir::MemRefType>(in.getType()))
                    continue;
                // The allocation must be invariant across iterations to be
                // valid for post-loop gathering.
                if (!isInvariantAcrossLoop(in, loop))
                    continue;

                mlir::Value root = viewRoot(in);
                llvm::SmallVector<mlir::Value> aliases = aliasSetOf(in);
                auto touchesStorage = [&](mlir::Value v) {
                    return llvm::is_contained(aliases, v) || viewRoot(v) == root;
                };

                bool writtenElsewhere = false;
                loop->walk([&](mlir::dhir::TaskOp other) {
                    if (writtenElsewhere || other == stencilTask)
                        return;
                    for (mlir::Value w : other.getOutputs())
                        if (touchesStorage(w)) { writtenElsewhere = true; return; }
                    for (mlir::Value w : other.getActualBuffer())
                        if (touchesStorage(w)) { writtenElsewhere = true; return; }
                });
                if (writtenElsewhere)
                    return in;
            }
            return mlir::Value();
        }

        // Determines if `loop` is a resident-stencil loop. Requires at least
        // one stencil task and requires all stencil tasks in the loop to read
        // a loop-carried input. A non-carried stencil task disqualifies the
        // entire loop, preserving per-iteration synchronization for safety.
        inline bool isResidentStencilLoop(mlir::Operation *loop)
        {
            if (!loop)
                return false;
            bool anyStencil = false;
            bool allCarried = true;
            loop->walk([&](mlir::dhir::TaskOp task) {
                if (!task->hasAttr("stencil"))
                    return;
                anyStencil = true;
                if (!stencilCarriedInput(task, loop))
                    allCarried = false;
            });
            return anyStencil && allCarried;
        }

    } // namespace dhir
} // namespace mlir

#endif // SYNC_HOISTING_H

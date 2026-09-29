#include "includes/utils.h"

using namespace mlir;

void attachDLTISpec(mlir::ModuleOp module, mlir::MLIRContext *context, SystemTopology systemTopo)
{
    mlir::OpBuilder builder(context);

    SmallVector<mlir::Attribute> deviceAttrs;

    // Iterate through the nodes in the topology
    for (const std::string &nodeID : systemTopo.cluster.node_ids)
    {

        const NodeInfo &node = systemTopo.nodes.at(nodeID);

        // --- Basic entries for each node ---
        auto typeEntry = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("type"),
            builder.getStringAttr("node"));

        auto archEntry = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("arch"),
            builder.getStringAttr(node.cpu_arch));

        // use cost from cluster config file
        float cost = node.cost;
        auto costEntry = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("cost"),
            builder.getF32FloatAttr(cost));

        // bandwidth entry
        auto bwEntry = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("bandwidth"),
            builder.getF32FloatAttr(node.bandwidth));

        // Node ID entry
        auto nodeIDEntry = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("node_id"),
            builder.getStringAttr(nodeID));

        // GPU count entry
        auto gpuCountEntry = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("gpu_count"),
            builder.getI32IntegerAttr(node.gpus.size()));

        // You can add more, e.g., gpu_arch_list, etc.
        SmallVector<mlir::Attribute> gpuArchs;
        SmallVector<mlir::Attribute> gpuIDs;

        for (auto &gpu : node.gpus)
        {
            gpuArchs.push_back(builder.getStringAttr(gpu.arch));
            gpuIDs.push_back(builder.getI32IntegerAttr(gpu.id));
        }

        auto gpuArch = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("gpu_arch"), builder.getArrayAttr(gpuArchs));

        auto gpuId = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("gpu_id"), builder.getArrayAttr(gpuIDs));

        // Absolute measured rates, appended last so the positions of every
        // pre-existing entry are unchanged.  A value of 0 means "uncalibrated";
        // consumers must fall back to the 1/cost path rather than treating 0 as a
        // rate, which would divide by zero or silently starve the node.
        auto computeStrided = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("compute_rate_strided"),
            builder.getF64FloatAttr(node.compute_rate_strided));
        auto computeContig = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("compute_rate_contiguous"),
            builder.getF64FloatAttr(node.compute_rate_contiguous));
        auto computeL1 = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("compute_rate_l1"),
            builder.getF64FloatAttr(node.compute_rate_l1));
        auto computeLLC = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("compute_rate_llc"),
            builder.getF64FloatAttr(node.compute_rate_llc));
        auto memBandwidth = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("memory_bandwidth"),
            builder.getF64FloatAttr(node.memory_bandwidth));
        auto overhead = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("overhead"),
            builder.getF64FloatAttr(node.overhead));
        auto threads = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("threads"),
            builder.getI32IntegerAttr(node.threads));
        auto l1Bytes = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("l1_bytes"),
            builder.getI64IntegerAttr(node.l1_bytes));
        auto llcBytes = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("llc_bytes"),
            builder.getI64IntegerAttr(node.llc_bytes));
        auto memoryBytes = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("memory_bytes"),
            builder.getI64IntegerAttr(node.memory_bytes));
        auto computeL1Ratio = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("compute_rate_l1_ratio"),
            builder.getF64FloatAttr(node.r_l1_ratio));
        auto computeLLCRatio = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("compute_rate_llc_ratio"),
            builder.getF64FloatAttr(node.r_llc_ratio));
        auto computeContigRatio = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("compute_rate_contiguous_ratio"),
            builder.getF64FloatAttr(node.r_contiguous_ratio));

        // Assemble this node's TargetDeviceSpecAttr
        llvm::SmallVector<mlir::DataLayoutEntryInterface, 24> entries = {
            typeEntry,
            archEntry,
            costEntry,
            nodeIDEntry,
            gpuCountEntry,
            gpuArch,
            gpuId,
            bwEntry,
            computeStrided,
            computeContig,
            computeL1,
            computeLLC,
            computeL1Ratio,
            computeLLCRatio,
            computeContigRatio,
            memBandwidth,
            overhead,
            threads,
            l1Bytes,
            llcBytes,
            memoryBytes};

        if (node.network.calibrated) {
            entries.push_back(mlir::DataLayoutEntryAttr::get(
                builder.getStringAttr("network_alpha"),
                builder.getF64FloatAttr(node.network.alpha_seconds)));
            entries.push_back(mlir::DataLayoutEntryAttr::get(
                builder.getStringAttr("network_beta"),
                builder.getF64FloatAttr(node.network.beta_seconds_per_byte)));
        }

        auto nodeAttr = mlir::TargetDeviceSpecAttr::get(context, entries);

        deviceAttrs.push_back(nodeAttr);
    }

    // Attach to module
    module->setAttr(
        "dhir.target_devices",
        builder.getArrayAttr(deviceAttrs));

    // Cluster-scope facts do not belong on any one device.  Both are attached only
    // when calibrated so that an uncalibrated build carries no attribute at all and
    // a consumer cannot mistake a default for a measurement.
    if (systemTopo.network.calibrated)
        module->setAttr("dhir.network", builder.getDictionaryAttr({
            builder.getNamedAttr("alpha_seconds",
                                 builder.getF64FloatAttr(systemTopo.network.alpha_seconds)),
            builder.getNamedAttr("beta_seconds_per_byte",
                                 builder.getF64FloatAttr(systemTopo.network.beta_seconds_per_byte)),
            builder.getNamedAttr("barrier_seconds",
                                 builder.getF64FloatAttr(systemTopo.network.barrier_seconds))}));

    if (systemTopo.machine.calibrated) {
        llvm::SmallVector<mlir::NamedAttribute, 16> machineAttrs = {
            builder.getNamedAttr("R_strided",
                                 builder.getF64FloatAttr(systemTopo.machine.r_strided)),
            builder.getNamedAttr("R_contiguous",
                                 builder.getF64FloatAttr(systemTopo.machine.r_contiguous)),
            builder.getNamedAttr("R_l1",
                                 builder.getF64FloatAttr(systemTopo.machine.r_l1)),
            builder.getNamedAttr("R_llc",
                                 builder.getF64FloatAttr(systemTopo.machine.r_llc)),
            builder.getNamedAttr("R_l1_ratio",
                                 builder.getF64FloatAttr(systemTopo.machine.r_l1_ratio)),
            builder.getNamedAttr("R_llc_ratio",
                                 builder.getF64FloatAttr(systemTopo.machine.r_llc_ratio)),
            builder.getNamedAttr("R_contiguous_ratio",
                                 builder.getF64FloatAttr(systemTopo.machine.r_contiguous_ratio)),
            builder.getNamedAttr("strided_flop_threshold",
                                 builder.getF64FloatAttr(systemTopo.machine.strided_flop_threshold)),
            builder.getNamedAttr("h_parallel_entry",
                                 builder.getF64FloatAttr(systemTopo.machine.h_parallel_entry)),
            builder.getNamedAttr("h_first_parallel_entry",
                                 builder.getF64FloatAttr(systemTopo.machine.h_first_parallel_entry)),
            builder.getNamedAttr("R_strided_serial",
                                 builder.getF64FloatAttr(systemTopo.machine.r_strided_serial)),
            builder.getNamedAttr("R_contiguous_serial",
                                 builder.getF64FloatAttr(systemTopo.machine.r_contiguous_serial)),
            builder.getNamedAttr("R_l1_serial",
                                 builder.getF64FloatAttr(systemTopo.machine.r_l1_serial)),
            builder.getNamedAttr("R_llc_serial",
                                 builder.getF64FloatAttr(systemTopo.machine.r_llc_serial)),
            builder.getNamedAttr("l1_bytes",
                                 builder.getI64IntegerAttr(systemTopo.machine.l1_bytes)),
            builder.getNamedAttr("llc_bytes",
                                 builder.getI64IntegerAttr(systemTopo.machine.llc_bytes)),
            builder.getNamedAttr("memory_bandwidth",
                                 builder.getF64FloatAttr(systemTopo.machine.memory_bandwidth)),
            builder.getNamedAttr("overhead",
                                 builder.getF64FloatAttr(systemTopo.machine.overhead)),
            builder.getNamedAttr("threads",
                                 builder.getI32IntegerAttr(systemTopo.machine.threads))
        };
        module->setAttr("dhir.machine", builder.getDictionaryAttr(machineAttrs));
    }
}

llvm::SmallVector<mlir::TargetDeviceSpecAttr> extractTargetDeviceSpecs(ModuleOp module)
{
    llvm::SmallVector<mlir::TargetDeviceSpecAttr> targetSpecVec;
    auto attr = module->getAttr("dhir.target_devices");

    if (!attr)
    {
        llvm::errs() << "No dhir.target_devices attribute found!\n";
        exit(0);
    }

    auto arrayAttr = mlir::dyn_cast<mlir::ArrayAttr>(attr);
    if (!arrayAttr)
    {
        llvm::errs() << "dhir.target_devices is not an ArrayAttr!\n";
        exit(0);
    }

    for (Attribute deviceAttr : arrayAttr)
    {
        auto deviceSpec = mlir::dyn_cast<mlir::TargetDeviceSpecAttr>(deviceAttr);
        if (!deviceSpec)
        {
            llvm::errs() << "Entry is not a TargetDeviceSpecAttr!\n";
            continue;
        }

        targetSpecVec.push_back(deviceSpec);

        // for (auto entry : deviceSpec.getEntries()) {
        //   auto dle = mlir::dyn_cast<mlir::DataLayoutEntryAttr>(entry);
        //   if (!dle) continue;

        //   auto key = dle.getKey().dyn_cast<StringAttr>();
        //   auto val = mlir::dyn_cast<StringAttr>(dle.getValue());
        //   if (key && val)
        //     llvm::outs() << "  " << key.getValue() << " = " << val.getValue() << "\n";
        // }
    }

    return targetSpecVec;
}

mlir::Attribute getDeviceAttribute(mlir::TargetDeviceSpecAttr deviceSpec, llvm::StringRef key)
{
    for (auto entry : deviceSpec.getEntries())
    {
        auto dle = mlir::dyn_cast<mlir::DataLayoutEntryAttr>(entry);
        if (!dle) continue;

        auto attrKey = mlir::dyn_cast<mlir::StringAttr>(dle.getKey());
        if (!attrKey) continue;

        if (attrKey.getValue() == key) return dle.getValue();
    }

    return nullptr;
}

SystemTopology parseSystemConfig(llvm::StringRef configFile)
{

    using json = nlohmann::json;
    std::ifstream f(configFile.str());
    if (!f.is_open())
    {
        llvm::errs() << "Could not open "<<configFile.str()<<"\n";
        exit(0);
    }

    json sys_config;
    f >> sys_config;

    SystemTopology system_topo = sys_config.get<SystemTopology>();

    // How to deal with Json in CC

    // for (auto &node_id : system_topo.cluster.node_ids)
    // {
    //   const NodeInfo &n = system_topo.nodes.at(node_id);
    //   llvm::errs() << "\nNode " << node_id << "\n";
    //   llvm::errs() << "  CPU arch: " << n.cpu_arch << "\n";
    //   llvm::errs() << "  GPUs: " << n.gpus.size() << "\n";

    //   for (auto &g : n.gpus)
    //   {
    //     llvm::errs() << "    GPU " << g.id
    //                  << " arch=" << g.arch
    //                  << " model=" << g.model
    //                  << "\n";
    //   }
    // }

    return sys_config;
}

/// Generates broadcast communication for collected buffers
///
/// When `perIteration` is set the caller is emitting inside a rebuilt loop, so
/// this fan-out runs once per iteration and becomes one `dhir.bcast`
/// (MPI_Bcast) per buffer.  Otherwise the original fan-out of point-to-point
/// sends is kept, root looping over every peer.
///
/// `perIteration` is the gate on converting a fan-out to a collective, and it
/// is supplied by the caller rather than probed from the insertion point: while
/// a loop body is being built through an scf body-builder callback the loop op
/// is not yet attached to its parent block, so walking up from the insertion
/// block cannot see the enclosing loops and silently reports "not in a loop".
/// The caller reads the compiler's own loop-nesting stack instead.
///
/// The gate exists because a collective's benefit is per execution.  cfd
/// materializes its `variables` buffer once per Runge-Kutta stage, 2000 x 3 =
/// 6000 times, so a tree there replaces 6000 serial fan-outs; a fan-out
/// executed once saves one log-P factor on a single transfer, which is
/// unmeasurable, while carrying exactly the same deadlock and count-arithmetic
/// risk.  Restricting the rewrite to per-iteration sites puts it where the
/// payload multiplies and leaves every once-executed transfer on the proven
/// point-to-point path.
///
/// @param rewriter The pattern rewriter for creating operations
/// @param loc Location for the generated operations
/// @param toBroadcast Vector of sub-buffers that need to be broadcast
/// @param rank The rank value (result of MPI rank query)
/// @param rootRank The MPI rank from which data is broadcast
/// @param comm The MPI communicator
/// @param retVal Return type for MPI operations
/// @param tag Tag for MPI operations
/// @param numRanks Total number of ranks/nodes (Value or constant)
/// @param perIteration This site runs once per iteration of an enclosing loop
void generateBroadcastCommunication(
    OpBuilder &rewriter,
    Location loc,
    SmallVectorImpl<Value> &toBroadcast,
    Value rank,
    Value rootRank,
    Value comm,
    mlir::Type retVal,
    Value tag,
    Value numRanks, // Added parameter
    bool perIteration)
{
    if (toBroadcast.empty())
        return;

    // A gather leaves the complete result in the root's base memref.  Every
    // other rank still owns only its local shard in that same base memref, so
    // the broadcast must operate on the base memref itself.  Reconstructing a
    // larger subview from shard views is both unnecessary and wrong for column
    // partitions (and for rank > 2): concatenation has no general layout.
    SmallVector<Value> buffers;
    auto unwrapBase = [](Value value) {
        while (Operation *def = value.getDefiningOp()) {
            auto view = dyn_cast<memref::SubViewOp>(def);
            if (!view)
                break;
            value = view.getSource();
        }
        return value;
    };
    for (Value value : toBroadcast) {
        if (!isa<MemRefType>(value.getType()))
            continue;
        Value base = unwrapBase(value);
        if (!llvm::is_contained(buffers, base))
            buffers.push_back(base);
    }

    if (buffers.empty())
        return;

    // A collective must be executed by every rank of the communicator, in
    // matching order, with matching counts and datatypes.  The rank guard is
    // built HERE, by this function, and not around its call sites, so emitting
    // an unguarded `dhir.bcast` in the guard's place leaves the collective at
    // exactly the block depth the guard occupied -- the same depth at which
    // this tree already emits unconditional mpi.barriers.  Every rank that
    // reached the old `scf.if` reached both of its branches' entry, so every
    // rank reaches the collective.  A collective left inside the guard would
    // instead hang every rank that skipped it, with no error and no output.
    if (perIteration) {
        for (Value buffer : buffers)
            rewriter.create<mlir::dhir::BcastOp>(loc, buffer, rootRank, comm);
        return;
    }

    Value numRanksIndex = numRanks;
    if (isa<IntegerType>(numRanks.getType()))
        numRanksIndex = rewriter.create<arith::IndexCastOp>(
            loc, rewriter.getIndexType(), numRanks);

    auto rootCond = rewriter.create<arith::CmpIOp>(
        loc, rewriter.getI1Type(), arith::CmpIPredicate::eq, rank, rootRank);

    // One deterministic send/receive phase per base buffer; reusing the tag
    // is safe because all ranks run the phases in the same order and MPI
    // preserves source/destination ordering.
    for (Value buffer : buffers) {
        auto ifOp = rewriter.create<scf::IfOp>(loc, TypeRange{}, rootCond, true);
        OpBuilder thenBuilder = ifOp.getThenBodyBuilder(rewriter.getListener());

        Value zero = thenBuilder.create<arith::ConstantIndexOp>(loc, 0);
        Value step = thenBuilder.create<arith::ConstantIndexOp>(loc, 1);
        auto forOp = thenBuilder.create<scf::ForOp>(loc, zero, numRanksIndex, step);
        OpBuilder forBuilder(forOp.getBody(), forOp.getBody()->begin());
        Value targetRank = forOp.getInductionVar();
        Value targetRankI32 = forBuilder.create<arith::IndexCastOp>(
            loc, rewriter.getI32Type(), targetRank);
        Value sendCond = forBuilder.create<arith::CmpIOp>(
            loc, rewriter.getI1Type(), arith::CmpIPredicate::ne,
            targetRankI32, rootRank);
        auto sendIf = forBuilder.create<scf::IfOp>(
            loc, TypeRange{}, sendCond, true);
        OpBuilder sendBuilder = sendIf.getThenBodyBuilder(forBuilder.getListener());
        sendBuilder.create<mpi::SendOp>(loc, retVal, buffer, tag,
                                        targetRankI32, comm);
        (void)sendIf.getElseBodyBuilder(forBuilder.getListener());

        OpBuilder elseBuilder = ifOp.getElseBodyBuilder(rewriter.getListener());
        elseBuilder.create<mpi::RecvOp>(loc, retVal, buffer, tag,
                                        rootRank, comm);
    }
}

/// Emit one MPI_Allgatherv (via dhir.allgatherv) that assembles a dim-0
/// partitioned buffer in place, replacing a gather-to-root followed by a
/// broadcast-to-all of the same base allocation.
///
/// startByNode[i]/sizeByNode[i] are node i's shard's dim-0 offset and row
/// count -- the exact values the gather path uses to build node i's shard
/// subview, so the collective moves precisely the memory the gather+broadcast
/// pair moved.  They are indexed by NODE; this function maps node -> MPI rank
/// through nodeToRankMap so the counts/displacements land at each peer's rank
/// slot, matching the partitioner's own placement.
///
/// counts[rank] and displs[rank] are in ELEMENTS (rows * the product of the
/// non-partition extents), which is what MPI_Allgatherv expects against an
/// element recvtype.  An off-by-one here is a silent wrong answer, so the
/// element scaling and the node->rank mapping are the only arithmetic and both
/// mirror the emitter that produced the shards.
///
/// REACHABILITY: this emits no rank guard.  The caller places it where an
/// unconditional mpi.barrier is already legal, so every rank of the
/// communicator reaches it with identical counts/displacements (both are
/// derived from loop-invariant totals and the shared rank/node map).
void generateAllgathervCommunication(
    OpBuilder &rewriter,
    Location loc,
    Value baseBuffer,
    llvm::ArrayRef<Value> startByNode,
    llvm::ArrayRef<Value> sizeByNode,
    Value nodeToRankMap,
    Value comm)
{
    auto memTy = dyn_cast<MemRefType>(baseBuffer.getType());
    if (!memTy || startByNode.size() != sizeByNode.size())
        return;
    const int64_t numNodes = static_cast<int64_t>(startByNode.size());
    if (numNodes == 0)
        return;

    Type indexTy = rewriter.getIndexType();
    Type i32 = rewriter.getI32Type();

    // rowElems = product of every extent except the dim-0 partition axis.  A
    // dim-0 slab of a row-major buffer is contiguous, so this scalar turns a
    // row offset/count into an element offset/count.  Built at runtime so a
    // dynamic non-partition extent is handled too.
    Value rowElems = rewriter.create<arith::ConstantIndexOp>(loc, 1);
    for (int64_t d = 1; d < memTy.getRank(); ++d)
    {
        Value extent = memTy.isDynamicDim(d)
            ? rewriter.create<memref::DimOp>(loc, baseBuffer, d).getResult()
            : rewriter.create<arith::ConstantIndexOp>(loc, memTy.getDimSize(d))
                  .getResult();
        rowElems = rewriter.create<arith::MulIOp>(loc, rowElems, extent);
    }

    auto tableTy = MemRefType::get({numNodes}, i32);
    Value counts = rewriter.create<memref::AllocOp>(loc, tableTy);
    Value displs = rewriter.create<memref::AllocOp>(loc, tableTy);

    for (int64_t i = 0; i < numNodes; ++i)
    {
        Value nodeIdx = rewriter.create<arith::ConstantIndexOp>(loc, i);
        Value rankI32 = rewriter.create<memref::LoadOp>(
            loc, nodeToRankMap, ValueRange{nodeIdx});
        Value rankIdx = rewriter.create<arith::IndexCastOp>(loc, indexTy, rankI32);

        Value countRows = sizeByNode[i];
        Value startRows = startByNode[i];
        Value countElems = rewriter.create<arith::MulIOp>(loc, countRows, rowElems);
        Value displElems = rewriter.create<arith::MulIOp>(loc, startRows, rowElems);
        // MPI counts/displs are int (i32).  This narrowing mirrors the existing
        // dynamic-count path in getRawPtrAndSize, which also truncates to i32
        // without a guard; a shard whose element extent exceeds 2^31 is already
        // unsupported there.
        Value countI32 = rewriter.create<arith::IndexCastOp>(loc, i32, countElems);
        Value displI32 = rewriter.create<arith::IndexCastOp>(loc, i32, displElems);
        rewriter.create<memref::StoreOp>(loc, countI32, counts, ValueRange{rankIdx});
        rewriter.create<memref::StoreOp>(loc, displI32, displs, ValueRange{rankIdx});
    }

    rewriter.create<mlir::dhir::AllgathervOp>(loc, baseBuffer, counts, displs, comm);

    // The collective is blocking, so the scratch tables are dead once it
    // returns; free them so a per-iteration site does not leak.
    rewriter.create<memref::DeallocOp>(loc, counts);
    rewriter.create<memref::DeallocOp>(loc, displs);
}

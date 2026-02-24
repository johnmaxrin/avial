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

        // Optional: cost based on number of GPUs or something else
        float cost = node.gpus.empty() ? 1.0f : 0.5f;
        auto costEntry = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("cost"),
            builder.getF32FloatAttr(cost));

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
        // Assemble this node's TargetDeviceSpecAttr
        auto nodeAttr = mlir::TargetDeviceSpecAttr::get(
            context,
            {typeEntry,
             archEntry,
             costEntry,
             nodeIDEntry,
             gpuCountEntry,
             gpuArch,
             gpuId});

        deviceAttrs.push_back(nodeAttr);
    }

    // Attach to module
    module->setAttr(
        "avial.target_devices",
        builder.getArrayAttr(deviceAttrs));
}

llvm::SmallVector<mlir::TargetDeviceSpecAttr> extractTargetDeviceSpecs(ModuleOp module)
{
    llvm::SmallVector<mlir::TargetDeviceSpecAttr> targetSpecVec;
    auto attr = module->getAttr("avial.target_devices");

    if (!attr)
    {
        llvm::errs() << "No avial.target_devices attribute found!\n";
        exit(0);
    }

    auto arrayAttr = mlir::dyn_cast<mlir::ArrayAttr>(attr);
    if (!arrayAttr)
    {
        llvm::errs() << "avial.target_devices is not an ArrayAttr!\n";
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

SystemTopology parseSystemConfig()
{

    using json = nlohmann::json;
    std::ifstream f("../system_config.json");
    if (!f.is_open())
    {
        llvm::errs() << "Could not open system_topology.json\n";
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
/// Rank 0 sends to all other ranks, remaining ranks receive from rank 0
///
/// @param rewriter The pattern rewriter for creating operations
/// @param loc Location for the generated operations
/// @param toBroadcast Vector of sub-buffers that need to be broadcast
/// @param rank The rank value (result of MPI rank query)
/// @param zero Constant zero value
/// @param comm The MPI communicator
/// @param retVal Return type for MPI operations
/// @param tag Tag for MPI operations
/// @param numRanks Total number of ranks/nodes (Value or constant)
void generateBroadcastCommunication(
    OpBuilder &rewriter,
    Location loc,
    SmallVectorImpl<Value> &toBroadcast,
    Value rank,
    Value zero,
    Value comm,
    mlir::Type retVal,
    Value tag,
    Value numRanks) // Added parameter
{
    if (toBroadcast.empty())
    {
        llvm::errs() << "No buffers to broadcast\n";
        return;
    }

    llvm::errs() << "\n=== Generating Broadcast Communication ===\n";
    llvm::errs() << "Number of buffers to broadcast: " << toBroadcast.size() << "\n";

    // Calculate total size needed for broadcasting
    // Sum all the first dimensions of the buffers in toBroadcast
    int64_t totalFirstDim = 0;
    int64_t secondDim = -1;

    for (Value subBuffer : toBroadcast)
    {
        auto memrefType = mlir::dyn_cast<mlir::MemRefType>(subBuffer.getType());

        llvm::errs() << "Memref Type: " << memrefType << "\n";

        if (!memrefType)
        {
            llvm::errs() << "Warning: Non-memref type in toBroadcast\n";
            continue;
        }

        auto shape = memrefType.getShape();
        if (shape.size() >= 2)
        {
            totalFirstDim += shape[0];
            if (secondDim == -1)
            {
                secondDim = shape[1];
            }
            else if (secondDim != shape[1])
            {
                llvm::errs() << "Warning: Inconsistent second dimension in buffers\n";
            }
        }

        else if (shape.size() < 2)
        {
            totalFirstDim += shape[0];
        }
    }

    llvm::errs() << "Total first dimension: " << totalFirstDim << "\n";
    llvm::errs() << "Second dimension: " << secondDim << "\n";

    // Get the source buffer (unwrap from first subview)
    Value sourceBuffer = toBroadcast[0];
    while (auto subviewOp = sourceBuffer.getDefiningOp<memref::SubViewOp>())
    {
        sourceBuffer = subviewOp.getSource();
    }

    // Create a combined subview that covers all the buffers to broadcast
    // This assumes all buffers are contiguous in the source buffer
    SmallVector<OpFoldResult> offsets;
    SmallVector<OpFoldResult> sizes;
    SmallVector<OpFoldResult> strides;

    // Get offset from the first buffer

    if (secondDim != -1)
    {
        if (auto firstSubview = toBroadcast[0].getDefiningOp<memref::SubViewOp>())
        {
            offsets = llvm::to_vector(firstSubview.getMixedOffsets());
        }
        else
        {
            // Default offsets if not a subview
            offsets = {rewriter.getIndexAttr(0), rewriter.getIndexAttr(0)};
        }

        // Set sizes: total first dimension and the common second dimension
        sizes = {
            rewriter.getIndexAttr(totalFirstDim),
            rewriter.getIndexAttr(secondDim)};

        // Default strides
        strides = {
            rewriter.getIndexAttr(1),
            rewriter.getIndexAttr(1)};
    }

    else
    {
        offsets.push_back(rewriter.getIndexAttr(0));
        sizes.push_back(rewriter.getIndexAttr(totalFirstDim));
        strides.push_back(rewriter.getIndexAttr(1));
    }

    // Create the combined subview for broadcasting
    Value broadcastBuffer = rewriter.create<memref::SubViewOp>(
        loc,
        sourceBuffer,
        offsets,
        sizes,
        strides);

    llvm::errs() << "Created combined broadcast buffer\n";

    // Generate broadcast communication using Send/Recv
    // Rank 0 sends to all other ranks, remaining ranks receive from rank 0
    auto cond = rewriter.create<arith::CmpIOp>(
        loc,
        rewriter.getI1Type(),
        arith::CmpIPredicate::eq,
        rank,
        zero);

    auto ifOp = rewriter.create<mlir::scf::IfOp>(
        loc,
        mlir::TypeRange{},
        cond,
        true);

    // Then block: Rank 0 - Send to all other ranks
    OpBuilder thenBuilder = ifOp.getThenBodyBuilder(rewriter.getListener());

    // Get total number of nodes/ranks
    // Assuming you have getNodes available in context, otherwise pass as parameter
    // We need to send to ranks 1, 2, 3, ... N-1

    // Create a loop to send to all ranks except rank 0
    // for (i = 1; i < num_ranks; i++) { send to rank i }

    auto one = thenBuilder.create<arith::ConstantIndexOp>(loc, 1);
    auto step = thenBuilder.create<arith::ConstantIndexOp>(loc, 1);

    // Convert numRanks to index type if it's not already
    Value numRanksIndex = numRanks;
    if (mlir::isa<mlir::IntegerType>(numRanks.getType()))
    {
        numRanksIndex = thenBuilder.create<arith::IndexCastOp>(
            loc,
            rewriter.getIndexType(),
            numRanks);
    }

    auto forOp = thenBuilder.create<scf::ForOp>(loc, one, numRanksIndex, step);
    OpBuilder forBuilder(forOp.getBody(), forOp.getBody()->begin());

    // Get loop induction variable (target rank)
    Value targetRank = forOp.getInductionVar();

    // Convert index to i32 for MPI
    auto targetRankI32 = forBuilder.create<arith::IndexCastOp>(
        loc,
        rewriter.getI32Type(),
        targetRank);

    // Send to this rank
    auto sendOp = forBuilder.create<mlir::mpi::SendOp>(
        loc,
        retVal,          // return type
        broadcastBuffer, // buffer to send
        tag,             // tag
        targetRankI32,   // destination rank
        comm             // communicator
    );

    llvm::errs() << "Generated broadcast sends from rank 0 to all other ranks\n";

    // Else block: Other ranks - Receive from rank 0
    OpBuilder elseBuilder = ifOp.getElseBodyBuilder(rewriter.getListener());

    auto recvOp = elseBuilder.create<mlir::mpi::RecvOp>(
        loc,
        retVal,          // return type
        broadcastBuffer, // buffer to receive into
        tag,             // tag
        zero,            // source rank (0)
        comm             // communicator
    );

    llvm::errs() << "Generated broadcast receive for other ranks from rank 0\n";
    llvm::errs() << "=== Broadcast Communication Complete ===\n\n";
}

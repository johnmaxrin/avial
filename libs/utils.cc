#include "includes/utils.h"

using namespace mlir;

void attachDLTISpec(mlir::ModuleOp module, mlir::MLIRContext *context, SystemTopology systemTopo)
{
    mlir::OpBuilder builder(context);

    SmallVector<mlir::Attribute> deviceAttrs;

    for (const std::string &nodeID : systemTopo.cluster.node_ids)
    {
        const NodeInfo &node = systemTopo.nodes.at(nodeID);

        auto typeEntry = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("type"), builder.getStringAttr("node"));
        auto archEntry = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("arch"), builder.getStringAttr(node.cpu_arch));

        float cost = node.cost;
        auto costEntry = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("cost"), builder.getF32FloatAttr(cost));
        auto nodeIDEntry = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("node_id"), builder.getStringAttr(nodeID));
        auto gpuCountEntry = mlir::DataLayoutEntryAttr::get(
            builder.getStringAttr("gpu_count"), builder.getI32IntegerAttr(node.gpus.size()));

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

        auto nodeAttr = mlir::TargetDeviceSpecAttr::get(
            context,
            {typeEntry, archEntry, costEntry, nodeIDEntry, gpuCountEntry, gpuArch, gpuId});

        deviceAttrs.push_back(nodeAttr);
    }

    module->setAttr("dhir.target_devices", builder.getArrayAttr(deviceAttrs));
}

FailureOr<SmallVector<TargetDeviceSpecAttr>> getTargetDevices(Operation *anchor)
{
    ModuleOp module = dyn_cast<ModuleOp>(anchor);
    if (!module)
        module = anchor->getParentOfType<ModuleOp>();
    if (!module)
    {
        anchor->emitError("cannot find enclosing module to read dhir.target_devices");
        return failure();
    }

    auto arr = module->getAttrOfType<ArrayAttr>("dhir.target_devices");
    if (!arr)
    {
        module->emitError("missing dhir.target_devices attribute");
        return failure();
    }

    SmallVector<TargetDeviceSpecAttr> out;
    for (Attribute a : arr)
    {
        auto spec = dyn_cast<TargetDeviceSpecAttr>(a);
        if (!spec)
        {
            module->emitError("dhir.target_devices entry is not a TargetDeviceSpecAttr");
            return failure();
        }
        out.push_back(spec);
    }
    return out;
}

SmallVector<TargetDeviceSpecAttr> extractTargetDeviceSpecs(ModuleOp module)
{
    auto r = getTargetDevices(module.getOperation());
    if (failed(r))
        exit(1);
    return *r;
}

Attribute getDeviceAttribute(TargetDeviceSpecAttr deviceSpec, StringRef key)
{
    for (auto entry : deviceSpec.getEntries())
    {
        auto dle = dyn_cast<DataLayoutEntryAttr>(entry);
        if (!dle)
            continue;
        auto attrKey = dyn_cast<StringAttr>(dle.getKey());
        if (!attrKey)
            continue;
        if (attrKey.getValue() == key)
            return dle.getValue();
    }
    return nullptr;
}

SystemTopology parseSystemConfig(StringRef configFile)
{
    using json = nlohmann::json;
    std::ifstream f(configFile.str());
    if (!f.is_open())
    {
        llvm::errs() << "Could not open " << configFile.str() << "\n";
        exit(1);
    }

    json sys_config;
    f >> sys_config;
    return sys_config.get<SystemTopology>();
}

FailureOr<SmallVector<DeviceChunk>>
computeCostBasedChunks(Operation *anchor, ArrayRef<TargetDeviceSpecAttr> devices,
                       int64_t lb, int64_t ub)
{
    if (devices.empty())
    {
        anchor->emitError("no target devices to partition over");
        return failure();
    }
    int64_t total = ub - lb;
    if (total <= 0)
    {
        anchor->emitError("cannot partition an empty iteration range");
        return failure();
    }

    const size_t n = devices.size();
    SmallVector<double> weights;
    double weightSum = 0.0;
    for (size_t i = 0; i < n; ++i)
    {
        double cost = 1.0;
        if (auto costAttr = dyn_cast_or_null<FloatAttr>(getDeviceAttribute(devices[i], "cost")))
            cost = costAttr.getValueAsDouble();
        if (!(cost > 0.0))
        {
            anchor->emitError("device cost must be > 0");
            return failure();
        }
        weights.push_back(1.0 / cost);
        weightSum += 1.0 / cost;
    }

    SmallVector<int64_t> sizes;
    int64_t assigned = 0;
    for (size_t i = 0; i < n; ++i)
    {
        int64_t c = static_cast<int64_t>((weights[i] / weightSum) * static_cast<double>(total));
        sizes.push_back(c);
        assigned += c;
    }
    int64_t remainder = total - assigned;
    for (int64_t i = 0; i < remainder; ++i)
        sizes[i % n]++;

    SmallVector<DeviceChunk> chunks;
    int64_t cur = lb;
    for (size_t i = 0; i < n; ++i)
    {
        if (sizes[i] <= 0)
            continue;
        chunks.push_back({cur, cur + sizes[i], devices[i], static_cast<int>(i)});
        cur += sizes[i];
    }
    return chunks;
}

int64_t nextRepId(Operation *root)
{
    int64_t maxId = 0;
    root->walk([&](Operation *op) {
        StringRef key;
        if (isa<dhir::TaskOp>(op))
            key = "repId";
        else if (isa<dhir::ReplicateOp>(op))
            key = "replicateID";
        else
            return;
        if (auto a = op->getAttrOfType<IntegerAttr>(key))
            maxId = std::max<int64_t>(maxId, a.getInt());
    });
    return maxId + 1;
}

Value makeSliceAlongDim(RewriterBase &rw, Location loc, Value v, int64_t dim,
                        int64_t start, int64_t size)
{
    auto type = dyn_cast<MemRefType>(v.getType());
    if (!type || type.getRank() <= dim)
        return v;

    SmallVector<OpFoldResult> offsets, sizes, strides;
    for (int64_t d = 0; d < type.getRank(); ++d)
    {
        strides.push_back(rw.getIndexAttr(1));
        if (d == dim)
        {
            offsets.push_back(rw.getIndexAttr(start));
            sizes.push_back(rw.getIndexAttr(size));
        }
        else
        {
            offsets.push_back(rw.getIndexAttr(0));
            if (type.isDynamicDim(d))
                sizes.push_back(OpFoldResult(rw.create<memref::DimOp>(loc, v, d).getResult()));
            else
                sizes.push_back(rw.getIndexAttr(type.getDimSize(d)));
        }
    }
    return rw.create<memref::SubViewOp>(loc, v, offsets, sizes, strides);
}

dhir::TaskOp createTaskShell(RewriterBase &rw, Location loc, const TaskSpec &s)
{
    auto task = rw.create<dhir::TaskOp>(
        loc, dhir::TaskRefType::get(rw.getContext()), s.device,
        ValueRange(s.reads), rw.getDenseI64ArrayAttr({0, 0}),
        ValueRange(s.writes), rw.getDenseI64ArrayAttr({s.outStart, s.outEnd}),
        ValueRange(s.bases));

    task->setAttr("name", rw.getStringAttr(s.name));
    task->setAttr("needBroadcast", rw.getBoolAttr(s.needBroadcast));
    task->setAttr("repId", s.repId ? s.repId : rw.getI64IntegerAttr(0));
    if (s.partitioned)
        task->setAttr("partitioned", rw.getBoolAttr(*s.partitioned));

    OpBuilder::InsertionGuard guard(rw);
    Block *blk = task.getRegion().empty() ? rw.createBlock(&task.getRegion())
                                          : &task.getRegion().front();
    rw.setInsertionPointToEnd(blk);
    if (blk->empty() || !blk->back().hasTrait<OpTrait::IsTerminator>())
        rw.create<dhir::YieldOp>(rw.getUnknownLoc());
    return task;
}

static bool isContiguousRegion(ArrayRef<int64_t> offsets, ArrayRef<int64_t> sizes,
                               ArrayRef<int64_t> baseShape)
{
    size_t n = sizes.size();
    size_t k = 0;
    while (k < n && sizes[k] == 1)
        ++k;
    for (size_t d = k + 1; d < n; ++d)
    {
        if (ShapedType::isDynamic(baseShape[d]))
            continue;
        if (offsets[d] != 0 || sizes[d] != baseShape[d])
            return false;
    }
    return true;
}

static bool getStaticSubview(Value v, Value &base, SmallVectorImpl<int64_t> &offsets,
                             SmallVectorImpl<int64_t> &sizes, SmallVectorImpl<int64_t> &baseShape,
                             bool &unitStrides)
{
    auto sv = v.getDefiningOp<memref::SubViewOp>();
    if (!sv)
        return false;
    auto srcType = dyn_cast<MemRefType>(sv.getSource().getType());
    if (!srcType)
        return false;
    auto isDyn = [](int64_t x) { return ShapedType::isDynamic(x); };
    if (llvm::any_of(sv.getStaticOffsets(), isDyn) || llvm::any_of(sv.getStaticSizes(), isDyn) ||
        llvm::any_of(sv.getStaticStrides(), isDyn))
        return false;
    base = sv.getSource();
    offsets.assign(sv.getStaticOffsets().begin(), sv.getStaticOffsets().end());
    sizes.assign(sv.getStaticSizes().begin(), sv.getStaticSizes().end());
    baseShape.assign(srcType.getShape().begin(), srcType.getShape().end());
    unitStrides = llvm::all_of(sv.getStaticStrides(), [](int64_t s) { return s == 1; });
    return true;
}

LogicalResult checkContiguousForMPI(Location loc, Value buf)
{
    Value base;
    SmallVector<int64_t> offs, sizes, shape;
    bool unit = true;
    // TODO: Prove runtime contiguity for dynamic memrefs before MPI transfer
    if (!getStaticSubview(buf, base, offs, sizes, shape, unit))
        return success();
    if (!unit || !isContiguousRegion(offs, sizes, shape))
        return emitError(loc) << "MPI transfer of a non-contiguous memref region is not supported "
                                 "(partition dimension must be the outermost dimension of the output)";
    return success();
}

FailureOr<Value> getTaskOutputRegion(OpBuilder &b, Location loc, Value written,
                                     ArrayRef<int64_t> outRanges)
{
    if (written.getDefiningOp<memref::SubViewOp>())
        return written;

    auto type = dyn_cast<MemRefType>(written.getType());
    if (!type)
        return emitError(loc) << "task output is not a memref";
    if (type.getRank() == 0)
        return written;
    if (outRanges.size() < 2)
        return emitError(loc) << "task has malformed outRanges";

    SmallVector<OpFoldResult> offsets, sizes, strides;
    for (int64_t d = 0; d < type.getRank(); ++d)
    {
        strides.push_back(b.getIndexAttr(1));
        if (d == 0)
        {
            offsets.push_back(b.getIndexAttr(outRanges[0]));
            sizes.push_back(b.getIndexAttr(outRanges[1] - outRanges[0]));
        }
        else
        {
            offsets.push_back(b.getIndexAttr(0));
            if (type.isDynamicDim(d))
                sizes.push_back(OpFoldResult(b.create<memref::DimOp>(loc, written, d).getResult()));
            else
                sizes.push_back(b.getIndexAttr(type.getDimSize(d)));
        }
    }
    return Value(b.create<memref::SubViewOp>(loc, written, offsets, sizes, strides));
}

static void emitBroadcastOfRegion(OpBuilder &b, Location loc, Value buf, Value rank,
                                  Value rootRank, Value comm, Type retVal, Value tag,
                                  Value numRanks)
{
    auto cond = b.create<arith::CmpIOp>(loc, b.getI1Type(), arith::CmpIPredicate::eq, rank, rootRank);
    auto ifOp = b.create<scf::IfOp>(loc, TypeRange{}, cond, true);

    OpBuilder thenBuilder = ifOp.getThenBodyBuilder(b.getListener());
    auto zeroIndex = thenBuilder.create<arith::ConstantIndexOp>(loc, 0);
    auto step = thenBuilder.create<arith::ConstantIndexOp>(loc, 1);

    Value numRanksIndex = numRanks;
    if (isa<IntegerType>(numRanks.getType()))
        numRanksIndex = thenBuilder.create<arith::IndexCastOp>(loc, b.getIndexType(), numRanks);

    auto forOp = thenBuilder.create<scf::ForOp>(loc, zeroIndex, numRanksIndex, step);
    OpBuilder forBuilder(forOp.getBody(), forOp.getBody()->begin());
    auto targetRankI32 = forBuilder.create<arith::IndexCastOp>(loc, b.getI32Type(), forOp.getInductionVar());
    auto sendCond = forBuilder.create<arith::CmpIOp>(loc, b.getI1Type(), arith::CmpIPredicate::ne, targetRankI32, rootRank);
    auto sendIf = forBuilder.create<scf::IfOp>(loc, TypeRange{}, sendCond, false);
    OpBuilder sendBuilder = sendIf.getThenBodyBuilder(forBuilder.getListener());
    sendBuilder.create<mpi::SendOp>(loc, retVal, buf, tag, targetRankI32, comm);

    OpBuilder elseBuilder = ifOp.getElseBodyBuilder(b.getListener());
    elseBuilder.create<mpi::RecvOp>(loc, retVal, buf, tag, rootRank, comm);
}

LogicalResult generateBroadcastCommunication(
    OpBuilder &rewriter, Location loc, SmallVectorImpl<Value> &toBroadcast,
    Value rank, Value rootRank, Value comm, Type retVal, Value tag, Value numRanks)
{
    if (toBroadcast.empty())
        return success();

    struct Entry
    {
        Value direct;
        Value base;
        SmallVector<int64_t> offsets, sizes, baseShape;
        bool mergeable = false;
        bool modified = false;
    };

    SmallVector<Entry> entries;
    for (Value v : toBroadcast)
    {
        Entry e;
        e.direct = v;
        bool unit = true;
        e.mergeable = getStaticSubview(v, e.base, e.offsets, e.sizes, e.baseShape, unit) && unit;
        entries.push_back(std::move(e));
    }

    // Merge regions of one base buffer that are identical or adjacent along a single dim.
    bool changed = true;
    while (changed)
    {
        changed = false;
        for (size_t a = 0; a < entries.size() && !changed; ++a)
        {
            for (size_t b = 0; b < entries.size() && !changed; ++b)
            {
                if (a == b || !entries[a].mergeable || !entries[b].mergeable ||
                    entries[a].base != entries[b].base)
                    continue;
                Entry &ea = entries[a];
                Entry &eb = entries[b];
                int64_t k = -1;
                bool ok = true;
                for (size_t d = 0; d < ea.sizes.size(); ++d)
                {
                    if (ea.offsets[d] == eb.offsets[d] && ea.sizes[d] == eb.sizes[d])
                        continue;
                    if (k == -1 && ea.offsets[d] + ea.sizes[d] == eb.offsets[d])
                        k = d;
                    else
                    {
                        ok = false;
                        break;
                    }
                }
                if (!ok)
                    continue;
                if (k >= 0)
                {
                    ea.sizes[k] += eb.sizes[k];
                    ea.modified = true;
                }
                entries.erase(entries.begin() + b);
                changed = true;
            }
        }
    }

    for (Entry &e : entries)
    {
        Value buf = e.direct;
        if (e.mergeable && e.modified)
        {
            SmallVector<OpFoldResult> offs, szs, strs;
            for (size_t d = 0; d < e.sizes.size(); ++d)
            {
                offs.push_back(rewriter.getIndexAttr(e.offsets[d]));
                szs.push_back(rewriter.getIndexAttr(e.sizes[d]));
                strs.push_back(rewriter.getIndexAttr(1));
            }
            buf = rewriter.create<memref::SubViewOp>(loc, e.base, offs, szs, strs);
        }
        if (failed(checkContiguousForMPI(loc, buf)))
            return failure();
        emitBroadcastOfRegion(rewriter, loc, buf, rank, rootRank, comm, retVal, tag, numRanks);
    }
    return success();
}

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
        builder.getStringAttr("gpu_arch"), builder.getArrayAttr(gpuArchs)
      );

      auto gpuId = mlir::DataLayoutEntryAttr::get(
        builder.getStringAttr("gpu_id"), builder.getArrayAttr(gpuIDs)
      );
    // Assemble this node's TargetDeviceSpecAttr
    auto nodeAttr = mlir::TargetDeviceSpecAttr::get(
        context,
        {typeEntry,
         archEntry,
         costEntry,
         nodeIDEntry,
         gpuCountEntry,
         gpuArch,
         gpuId
        });

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

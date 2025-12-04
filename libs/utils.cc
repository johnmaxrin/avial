#include "includes/utils.h"

using namespace mlir;

void attachDLTISpec(mlir::ModuleOp module, mlir::MLIRContext *context /* Receive Info as Params */)
{
  OpBuilder builder(context);

  auto typeEntry = DataLayoutEntryAttr::get(builder.getStringAttr("type"), builder.getStringAttr("node"));
  auto archEntry = DataLayoutEntryAttr::get(builder.getStringAttr("arch"), builder.getStringAttr("x86"));
  auto costEntry = DataLayoutEntryAttr::get(builder.getStringAttr("cost"), builder.getF32FloatAttr(0.2));

  auto node1target = TargetDeviceSpecAttr::get(context, {typeEntry, archEntry});

  auto typeEntry2 = DataLayoutEntryAttr::get(builder.getStringAttr("type"), builder.getStringAttr("node"));
  auto archEntry2 = DataLayoutEntryAttr::get(builder.getStringAttr("arch"), builder.getStringAttr("x86"));
  auto costEntry2 = DataLayoutEntryAttr::get(builder.getStringAttr("cost"), builder.getF32FloatAttr(0.8));

  auto node2target = TargetDeviceSpecAttr::get(context, {typeEntry2, archEntry2});

  SmallVector<Attribute> devices = {node1target, node2target};
  module->setAttr(
      "avial.target_devices",       // Expected attribute name in DLTIR
      builder.getArrayAttr(devices) // Store as an array
  );
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

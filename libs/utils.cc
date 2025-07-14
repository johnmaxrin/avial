#include "includes/utils.h"


using namespace mlir;

void attachDLTISpec(mlir::ModuleOp module, mlir::MLIRContext *context /* Receive Info as Params */) {
            OpBuilder builder(context);

            auto typeEntry = DataLayoutEntryAttr::get(builder.getStringAttr("type"), builder.getStringAttr("node"));
            auto archEntry = DataLayoutEntryAttr::get(builder.getStringAttr("arch"), builder.getStringAttr("x86"));
           
            auto node1target =  TargetDeviceSpecAttr::get(context, {typeEntry, archEntry});
          
            auto typeEntry2 = DataLayoutEntryAttr::get(builder.getStringAttr("type"), builder.getStringAttr("node"));
            auto archEntry2 = DataLayoutEntryAttr::get(builder.getStringAttr("arch"), builder.getStringAttr("x86"));
           
            auto node2target =  TargetDeviceSpecAttr::get(context, {typeEntry2, archEntry2});

            SmallVector<Attribute> devices = {node1target, node2target};
            module->setAttr(
                "avial.target_devices",  // Expected attribute name in DLTIR
        builder.getArrayAttr(devices)  // Store as an array
);
          
}


void extractTargetDeviceSpecs(ModuleOp module) {
  auto attr = module->getAttr("avial.target_devices");

  if (!attr) {
    llvm::errs() << "No avial.target_devices attribute found!\n";
    return;
  }

  auto arrayAttr = mlir::dyn_cast<mlir::ArrayAttr>(attr);
  if (!arrayAttr) {
    llvm::errs() << "avial.target_devices is not an ArrayAttr!\n";
    return;
  }

  for (Attribute deviceAttr : arrayAttr) {
    auto deviceSpec = mlir::dyn_cast<mlir::TargetDeviceSpecAttr>(deviceAttr);
    if (!deviceSpec) {
      llvm::errs() << "Entry is not a TargetDeviceSpecAttr!\n";
      continue;
    }

    llvm::outs() << "Found target device:\n";
    for (auto entry : deviceSpec.getEntries()) {
      auto dle = mlir::dyn_cast<mlir::DataLayoutEntryAttr>(entry);
      if (!dle) continue;

      auto key = dle.getKey().dyn_cast<StringAttr>();
      auto val = mlir::dyn_cast<StringAttr>(dle.getValue());
      if (key && val)
        llvm::outs() << "  " << key.getValue() << " = " << val.getValue() << "\n";
    }
  }
}
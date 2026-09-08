#pragma once

#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "includes/dhirDialect.h"
#include "includes/dhirOps.h"
#include "analysis/costModel.h"

namespace mlir
{
    namespace dhir
    {
#define GEN_PASS_DEF_OMPCOSTMODELREPORTPASS
#include "dialect/Passes.h.inc"

        /// Extracts target hardware characteristics from the `dhir.machine` DLTI attribute
        /// populated by `libs/utils.cc` from the system configuration. All attributes denote
        /// target system properties rather than host traits, ensuring compilation remains
        /// target-specific and independent of the build host.
        inline MachineModel machineModelFromModule(mlir::ModuleOp moduleOp,
                                                   const MachineModel &defaults)
        {
            MachineModel machine = defaults;
            auto dict = moduleOp->getAttrOfType<mlir::DictionaryAttr>("dhir.machine");
            if (!dict) return machine;

            auto readF64 = [&](StringRef name, double &out) {
                if (auto attr = dict.getAs<mlir::FloatAttr>(name))
                    if (attr.getValueAsDouble() > 0.0)
                        out = attr.getValueAsDouble();
            };
            auto readI64 = [&](StringRef name, int64_t &out) {
                if (auto attr = dict.getAs<mlir::IntegerAttr>(name))
                    if (attr.getInt() > 0) out = attr.getInt();
            };
            static const char *rateKeys[CC_Count] = {
                "R_strided", "R_llc", "R_l1", "R_contiguous"};
            static const char *serialKeys[CC_Count] = {
                "R_strided_serial", "R_llc_serial", "R_l1_serial",
                "R_contiguous_serial"};
            for (unsigned cls = 0; cls < CC_Count; ++cls) {
                readF64(rateKeys[cls], machine.rate[cls]);
                readF64(serialKeys[cls], machine.serialRate[cls]);
            }
            readF64("memory_bandwidth", machine.bandwidth);
            readF64("overhead", machine.startup);
            readF64("h_first_parallel_entry", machine.firstEntry);
            readF64("h_parallel_entry", machine.entry);
            readI64("l1_bytes", machine.l1Bytes);
            readI64("llc_bytes", machine.llcBytes);
            readI64("memory_bytes", machine.memoryBytes);
            if (auto attr = dict.getAs<mlir::IntegerAttr>("threads"))
                if (attr.getInt() > 0) machine.threads = int(attr.getInt());
            return machine;
        }

        /// Retrieves hardware attributes from the primary entry of `dhir.target_devices`,
        /// allowing node-specific capability parameters to supersede global cluster configurations.
        inline void machineModelFromTargetDevice(mlir::ModuleOp moduleOp,
                                                 MachineModel &machine)
        {
            auto devices = moduleOp->getAttrOfType<mlir::ArrayAttr>("dhir.target_devices");
            if (!devices || devices.empty()) return;
            auto spec = mlir::dyn_cast<mlir::TargetDeviceSpecAttr>(devices[0]);
            if (!spec) return;
            static const char *rateKeys[CC_Count] = {
                "compute_rate_strided", "compute_rate_llc", "compute_rate_l1",
                "compute_rate_contiguous"};
            static const char *serialKeys[CC_Count] = {
                "compute_rate_strided_serial", "compute_rate_llc_serial",
                "compute_rate_l1_serial", "compute_rate_contiguous_serial"};
            for (auto entry : spec.getEntries()) {
                auto key = mlir::dyn_cast<mlir::StringAttr>(entry.getKey());
                if (!key) continue;
                StringRef name = key.getValue();
                if (auto value = mlir::dyn_cast<mlir::FloatAttr>(entry.getValue())) {
                    double number = value.getValueAsDouble();
                    if (number <= 0.0) continue;
                    for (unsigned cls = 0; cls < CC_Count; ++cls) {
                        if (name == rateKeys[cls]) machine.rate[cls] = number;
                        if (name == serialKeys[cls]) machine.serialRate[cls] = number;
                    }
                    if (name == "memory_bandwidth") machine.bandwidth = number;
                    if (name == "overhead") machine.startup = number;
                    if (name == "omp_first_entry_latency") machine.firstEntry = number;
                    if (name == "omp_entry_latency") machine.entry = number;
                } else if (auto value = mlir::dyn_cast<mlir::IntegerAttr>(entry.getValue())) {
                    if (value.getInt() <= 0) continue;
                    if (name == "l1_bytes") machine.l1Bytes = value.getInt();
                    if (name == "llc_bytes") machine.llcBytes = value.getInt();
                    if (name == "memory_bytes") machine.memoryBytes = value.getInt();
                    if (name == "threads") machine.threads = int(value.getInt());
                }
            }
        }

        struct OMPCostModelReportPass
            : public mlir::dhir::impl::OMPCostModelReportPassBase<OMPCostModelReportPass>
        {
            using OMPCostModelReportPassBase::OMPCostModelReportPassBase;

            explicit OMPCostModelReportPass(const MachineModel &defaults)
                : defaults(defaults) {}

            void runOnOperation() override
            {
                auto moduleOp = dyn_cast<mlir::ModuleOp>(getOperation());
                if (!moduleOp) return;

                MachineModel machine = machineModelFromModule(moduleOp, defaults);
                machineModelFromTargetDevice(moduleOp, machine);

                if (machine.l1Bytes <= 0 || machine.llcBytes <= 0 ||
                    machine.threads <= 0) {
                    moduleOp.emitError()
                        << "OpenMP cost model needs l1_bytes, llc_bytes and "
                           "threads for the target; supply them in the system "
                           "config or via --dhir-omp-l1-bytes / "
                           "--dhir-omp-llc-bytes / --dhir-omp-threads";
                    signalPassFailure();
                    return;
                }

                for (auto fn : moduleOp.getOps<func::FuncOp>())
                {
                    if (fn.isDeclaration()) continue;
                    OMPCostModelResult result = computeOMPCostModel(
                        fn, machine.llcBytes, machine.threads, machine.l1Bytes);
                    result.print(llvm::outs(), fn.getName(), &machine);
                }
            }

        private:
            MachineModel defaults;
        };

        inline std::unique_ptr<::mlir::Pass>
        createOMPCostModelReportPass(const MachineModel &defaults)
        {
            return std::make_unique<OMPCostModelReportPass>(defaults);
        }
    } // namespace dhir
} // namespace mlir

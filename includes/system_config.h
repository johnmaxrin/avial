#pragma once
#include <string>
#include <vector>
#include <map>
#include "json.hpp"

struct GPUInfo {
    int id;
    std::string arch;
    std::string model;  
};

struct NetworkInfo {
    double alpha_seconds = 0.0;
    double beta_seconds_per_byte = 0.0;
    double barrier_seconds = 0.0;
    bool calibrated = false;
    bool is_root = false;
};

struct NodeInfo {
    std::string cpu_arch;
    std::vector<GPUInfo> gpus;
    float cost;
    float bandwidth;
    // Absolute per-node rates written by tests/cluster_calibrate.py.  Zero means
    // "not calibrated", which keeps every pre-existing config on the legacy
    // 1/cost path rather than silently substituting a default rate.
    double compute_rate_strided = 0.0;
    double compute_rate_contiguous = 0.0;
    double compute_rate_l1 = 0.0;
    double compute_rate_llc = 0.0;
    // Single-thread rate of each regime.  Work the parallelizer leaves serial
    // runs on one core; the measured speedup of this machine relates the two,
    // and it is nowhere near the thread count.
    double compute_rate_strided_serial = 0.0;
    double compute_rate_contiguous_serial = 0.0;
    double compute_rate_l1_serial = 0.0;
    double compute_rate_llc_serial = 0.0;
    // Creating the OpenMP thread team is a one-off cost on the first parallel
    // region, distinct from the per-entry latency below.
    double omp_first_entry_latency = 0.0;
    double omp_entry_latency = 0.0;
    double memory_bandwidth = 0.0;
    double overhead = 0.0;
    int threads = 0;
    int64_t l1_bytes = 0;
    int64_t llc_bytes = 0;
    int64_t memory_bytes = 0;
    double r_l1_ratio = 1.0;
    double r_llc_ratio = 1.0;
    double r_contiguous_ratio = 1.0;
    NetworkInfo network;
};

/// Cluster-wide reference rates, used to normalise the per-node values and to
/// pick a compute roof by innermost-loop stride class.
struct MachineInfo {
    double r_strided = 0.0;
    double r_contiguous = 0.0;
    double r_l1 = 0.0;                  // R_scalar / R_l1
    double r_llc = 0.0;                 // R_llc
    double r_l1_ratio = 1.0;            // r_l1 / r_strided
    double r_llc_ratio = 1.0;           // r_llc / r_strided
    double r_contiguous_ratio = 1.0;    // r_contiguous / r_strided
    double strided_flop_threshold = 0.5;
    double h_parallel_entry = 0.0;
    double h_first_parallel_entry = 0.0;
    double r_strided_serial = 0.0;
    double r_contiguous_serial = 0.0;
    double r_l1_serial = 0.0;
    double r_llc_serial = 0.0;
    int64_t l1_bytes = 0;
    int64_t llc_bytes = 0;
    double memory_bandwidth = 0.0;
    double overhead = 0.0;
    int64_t memory_bytes = 0;
    int threads = 0;
    bool calibrated = false;
};

struct ClusterInfo {
    int world_size;
    std::vector<std::string> node_ids;
};

struct SystemTopology {
    ClusterInfo cluster;
    std::map<std::string, NodeInfo> nodes;
    NetworkInfo network;
    MachineInfo machine;
};


using json = nlohmann::json;

inline void from_json(const json& j, GPUInfo& g) {
    g.id = j.at("id").get<int>();
    g.arch = j.at("arch").get<std::string>();
    g.model = j.value("model", "unknown");
}

inline void from_json(const json& j, NetworkInfo& n) {
    n.alpha_seconds = j.value("alpha_seconds", 0.0);
    n.beta_seconds_per_byte = j.value("beta_seconds_per_byte", 0.0);
    n.barrier_seconds = j.value("barrier_seconds", 0.0);
    n.calibrated = n.alpha_seconds > 0.0 || n.beta_seconds_per_byte > 0.0;
}

inline void from_json(const json& j, NodeInfo& n) {
    n.cpu_arch = j.at("cpu_arch").get<std::string>();
    n.gpus = j.at("gpus").get<std::vector<GPUInfo>>();
    n.cost = j.value("cost", 1.0f);
    n.bandwidth = j.value("bandwidth", 1.0f);
    n.compute_rate_strided = j.value("compute_rate_strided", 0.0);
    n.compute_rate_contiguous = j.value("compute_rate_contiguous", 0.0);
    n.compute_rate_l1 = j.value("compute_rate_l1", j.value("compute_rate_scalar", 0.0));
    n.compute_rate_llc = j.value("compute_rate_llc", 0.0);
    n.memory_bandwidth = j.value("memory_bandwidth", 0.0);
    n.overhead = j.value("overhead", 0.0);
    n.compute_rate_strided_serial = j.value("compute_rate_dram_serial", 0.0);
    n.compute_rate_contiguous_serial = j.value("compute_rate_contiguous_serial", 0.0);
    n.compute_rate_l1_serial = j.value("compute_rate_l1_serial", 0.0);
    n.compute_rate_llc_serial = j.value("compute_rate_llc_serial", 0.0);
    n.omp_first_entry_latency = j.value("omp_first_entry_latency", 0.0);
    n.omp_entry_latency = j.value("omp_entry_latency", 0.0);
    n.threads = j.value("threads", 0);
    n.l1_bytes = j.value("l1_bytes", int64_t(0));
    n.llc_bytes = j.value("llc_bytes", int64_t(0));
    n.memory_bytes = j.value("memory_bytes", int64_t(0));
    n.r_l1_ratio = (n.compute_rate_strided > 0.0 && n.compute_rate_l1 > 0.0)
                       ? (n.compute_rate_l1 / n.compute_rate_strided)
                       : j.value("r_l1_ratio", j.value("R_l1_ratio", 1.0));
    n.r_llc_ratio = (n.compute_rate_strided > 0.0 && n.compute_rate_llc > 0.0)
                        ? (n.compute_rate_llc / n.compute_rate_strided)
                        : j.value("r_llc_ratio", j.value("R_llc_ratio", 1.0));
    n.r_contiguous_ratio = (n.compute_rate_strided > 0.0 && n.compute_rate_contiguous > 0.0)
                               ? (n.compute_rate_contiguous / n.compute_rate_strided)
                               : j.value("r_contiguous_ratio", j.value("R_contiguous_ratio", 1.0));
    n.network = j.contains("network") ? j.at("network").get<NetworkInfo>()
                                      : NetworkInfo{0.0, 0.0, 0.0, false};
}

inline void from_json(const json& j, MachineInfo& m) {
    m.r_strided = j.value("R_strided", j.value("R_flop_per_second", 0.0));
    m.r_contiguous = j.value("R_contiguous", j.value("R_contiguous_flop_per_second", 0.0));
    m.r_l1 = j.value("R_l1", j.value("R_scalar", j.value("R_scalar_flop_per_second", 0.0)));
    m.r_llc = j.value("R_llc", j.value("R_llc_flop_per_second", 0.0));
    m.strided_flop_threshold = j.value("strided_flop_threshold", 0.5);
    m.h_parallel_entry = j.value("h_parallel_entry", j.value("h_parallel_entry_seconds", 0.0));
    m.h_first_parallel_entry = j.value("h_first_parallel_entry",
                                       j.value("h_first_parallel_entry_seconds", 0.0));
    m.r_strided_serial = j.value("R_dram_serial", j.value("R_strided_serial", 0.0));
    m.r_contiguous_serial = j.value("R_contiguous_serial", 0.0);
    m.r_l1_serial = j.value("R_l1_serial", 0.0);
    m.r_llc_serial = j.value("R_llc_serial", 0.0);
    m.l1_bytes = j.value("l1_bytes", int64_t(0));
    m.llc_bytes = j.value("llc_bytes", int64_t(0));
    m.memory_bytes = j.value("memory_bytes", int64_t(0));
    m.memory_bandwidth = j.value("memory_bandwidth", j.value("B_byte_per_second", 0.0));
    m.overhead = j.value("overhead", j.value("c_seconds", 0.0));
    m.threads = j.value("threads", 0);
    m.r_l1_ratio = (m.r_strided > 0.0 && m.r_l1 > 0.0) ? (m.r_l1 / m.r_strided) : j.value("R_l1_ratio", 1.0);
    m.r_llc_ratio = (m.r_strided > 0.0 && m.r_llc > 0.0) ? (m.r_llc / m.r_strided) : j.value("R_llc_ratio", 1.0);
    m.r_contiguous_ratio = (m.r_strided > 0.0 && m.r_contiguous > 0.0) ? (m.r_contiguous / m.r_strided) : j.value("R_contiguous_ratio", 1.0);
    m.calibrated = m.r_strided > 0.0;
}

inline void from_json(const json& j, ClusterInfo& c) {
    c.world_size = j.at("world_size").get<int>();
    c.node_ids = j.at("node_ids").get<std::vector<std::string>>();
}

inline void from_json(const json& j, SystemTopology& sys) {
    sys.cluster = j.at("cluster").get<ClusterInfo>();
    sys.nodes = j.at("nodes").get<std::map<std::string, NodeInfo>>();
    sys.network = j.contains("network") ? j.at("network").get<NetworkInfo>()
                                       : NetworkInfo{0.0, 0.0, 0.0, false};
    sys.machine = j.contains("machine") ? j.at("machine").get<MachineInfo>()
                                        : MachineInfo{};
}


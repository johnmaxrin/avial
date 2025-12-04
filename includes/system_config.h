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

struct NodeInfo {
    std::string cpu_arch;
    std::vector<GPUInfo> gpus;
};

struct ClusterInfo {
    int world_size;
    std::vector<std::string> node_ids;
};

struct SystemTopology {
    ClusterInfo cluster;
    std::map<std::string, NodeInfo> nodes;  
};


using json = nlohmann::json;

inline void from_json(const json& j, GPUInfo& g) {
    g.id = j.at("id").get<int>();
    g.arch = j.at("arch").get<std::string>();
    g.model = j.value("model", "unknown"); 
}

inline void from_json(const json& j, NodeInfo& n) {
    n.cpu_arch = j.at("cpu_arch").get<std::string>();
    n.gpus = j.at("gpus").get<std::vector<GPUInfo>>();
}

inline void from_json(const json& j, ClusterInfo& c) {
    c.world_size = j.at("world_size").get<int>();
    c.node_ids = j.at("node_ids").get<std::vector<std::string>>();
}

inline void from_json(const json& j, SystemTopology& sys) {
    sys.cluster = j.at("cluster").get<ClusterInfo>();
    sys.nodes = j.at("nodes").get<std::map<std::string, NodeInfo>>();
}

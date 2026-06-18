#include "runtimeTopology.h"

#include <mpi.h>

#include <hwloc.h>
#include <sys/utsname.h>

#include <cstring>
#include <cstdio>
#include <vector>

struct DiscoveredNode
{
    char cpuArch[32];
    int gpuCount;
};

static void discoverNode(DiscoveredNode *node)
{
    struct utsname sysinfo;
    uname(&sysinfo);

    strncpy(node->cpuArch, sysinfo.machine, sizeof(node->cpuArch) - 1);
    node->cpuArch[sizeof(node->cpuArch)-1] = '\0';

    hwloc_topology_t topology;
    hwloc_topology_init(&topology);
    hwloc_topology_set_io_types_filter(topology, HWLOC_TYPE_FILTER_KEEP_IMPORTANT);
    hwloc_topology_load(topology);

    int gpuCount = 0;
    hwloc_obj_t obj = nullptr;

    constexpr unsigned PCI_VENDOR_NVIDIA = 0x10de;

    while((obj=hwloc_get_next_obj_by_type(topology, HWLOC_OBJ_PCI_DEVICE, obj)) != nullptr)
    {
        // todo: compute capability isn't verified here. assumes any nvidia gpu is sm61 compatible. verify via CUDA driver API.
        if (obj->attr && obj->attr->pcidev.class_id >> 8 == 0x03 && obj->attr->pcidev.vendor_id == PCI_VENDOR_NVIDIA)
        {
            gpuCount++;
        }
    }

    node->gpuCount = gpuCount;

    hwloc_topology_destroy(topology);
}

static bool matchNode(const RuntimeNode &cfg, const DiscoveredNode &local)
{
    if (strcmp(cfg.cpuArch, local.cpuArch) != 0) return false;
    if (cfg.gpuCount != local.gpuCount) return false;
    return true;
}

extern "C" void
buildRankNodeMaps(
    const RuntimeTopology *topology,
    int *rankToNodeMap,
    int *nodeToRankMap)
{
    int worldRank, worldSize;
    MPI_Comm_rank(MPI_COMM_WORLD, &worldRank);
    MPI_Comm_size(MPI_COMM_WORLD, &worldSize);

    if (worldSize != topology->numNodes)
    {
        printf("Number of ranks != number of nodes\n");
        MPI_Abort(MPI_COMM_WORLD, -1);
    }

    DiscoveredNode node;
    discoverNode(&node);

    std::vector<DiscoveredNode> rankHardware(worldSize);
    MPI_Gather(&node, sizeof(DiscoveredNode), MPI_BYTE, rankHardware.data(), sizeof(DiscoveredNode), MPI_BYTE, 0, MPI_COMM_WORLD);

    std::vector<int> rankToNode(worldSize, -1);
    std::vector<int> nodeToRank(topology->numNodes, -1);

    if (worldRank == 0)
    {
        for(int r = 0; r < worldSize; r++)
        {
            const auto &info = rankHardware[r];

            for (int n = 0; n < topology->numNodes; n++)
            {
                if (nodeToRank[n] != -1) continue;

                if (matchNode(topology->nodes[n], info))
                {
                    rankToNode[r] = n;
                    nodeToRank[n] = r;
                    break;
                }
            }

            if (rankToNode[r] == -1)
            {
                printf("No node match for rank %d\n", r);
                MPI_Abort(MPI_COMM_WORLD, -1);
            }
        }
    }

    MPI_Bcast(rankToNode.data(), worldSize, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(nodeToRank.data(), topology->numNodes, MPI_INT, 0, MPI_COMM_WORLD);

    for (int i = 0; i < worldSize; i++) rankToNodeMap[i] = rankToNode[i];
    for (int i = 0; i < topology->numNodes; i++) nodeToRankMap[i] = nodeToRank[i];
}

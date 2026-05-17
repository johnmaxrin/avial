#include "runtimeTopology.h"

#include <mpi.h>

#include <cstring>
#include <cstdio>

extern "C" void buildRankToNodeMap(
    const RuntimeTopology *topology,
    int *rankToNodeMap,
    int *nodeToRankMap)
{
    int worldSize;

    MPI_Comm_size(MPI_COMM_WORLD, &worldSize);

    if (worldSize != topology->numNodes)
    {
        fprintf(stderr, "world size %d does not match configured node count %d\n", worldSize, topology->numNodes);
        MPI_Abort(MPI_COMM_WORLD, 1);
    }

    for (int i = 0; i < topology->numNodes; i++)
    {
        rankToNodeMap[i] = -1;
        nodeToRankMap[i] = -1;
    }

    char hostname[MPI_MAX_PROCESSOR_NAME];
    int namelen;

    MPI_Get_processor_name(hostname, &namelen);

    int matchedIdx = -1;

    for (int i = 0; i < topology->numNodes; i++)
    {
        if (std::strcmp(hostname, topology->nodes[i].nodeId) == 0)
        {
            matchedIdx = i;
            break;
        }
    }

    if (matchedIdx == -1)
    {
        fprintf(stderr, "hostname %s was not found in the cluster configuration\n", hostname);
        MPI_Abort(MPI_COMM_WORLD, 1);
    }

    MPI_Allgather(&matchedIdx, 1, MPI_INT, rankToNodeMap, 1, MPI_INT, MPI_COMM_WORLD);

    for (int r = 0; r < worldSize; r++)
    {
        int nodeIdx = rankToNodeMap[r];

        if (nodeIdx < 0 || nodeIdx >= topology->numNodes)
        {
            fprintf(stderr, "invalid node index %d nodeIdx from rank %d\n", nodeIdx, r);
            MPI_Abort(MPI_COMM_WORLD, 1);
        }

        if (nodeToRankMap[nodeIdx] != -1)
        {
            fprintf(stderr, "multiple nodes with hostname %s\n", topology->nodes[nodeIdx].nodeId);
            MPI_Abort(MPI_COMM_WORLD, 1);
        }

        nodeToRankMap[nodeIdx] = r;
    }
}

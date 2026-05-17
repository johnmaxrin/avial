#ifndef RUNTIMETOPOLOGY_H
#define RUNTIMETOPOLOGY_H

struct RuntimeNode
{
    const char *nodeId;
    int gpuCount;
    float cost;
};

struct RuntimeTopology
{
    int numNodes;
    RuntimeNode *nodes;
};

#endif

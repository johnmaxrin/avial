// Network benchmarking driver for DHIR cluster calibration.
// Quantifies spoke link characteristics (latency alpha, transmission cost beta, bandwidth),
// serialized hub collectives (gather and broadcast), simultaneous incast transfers,
// and global communicator barrier synchronization latency.
//
// Output format: CSV records prefixed with CLUSTERCAL emitted by rank 0 to standard output.

#include <mpi.h>
#include <unistd.h>

#include <algorithm>
#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>

namespace {

constexpr int kMaxSizes = 16;

long parseLong(const char *s, const char *what) {
  char *end = nullptr;
  errno = 0;
  long v = std::strtol(s, &end, 10);
  if (errno || !end || *end || v <= 0) {
    std::fprintf(stderr, "invalid %s: %s\n", what, s);
    MPI_Abort(MPI_COMM_WORLD, 2);
  }
  return v;
}

struct NodePlacement {
  char host[256];
  int localRank;
  int localSize;
  int nodeIndex;
};

// Point-to-point ping-pong benchmark between coordinator rank a and worker rank b.
// Evaluations:
//   1. Symmetric round-trip / 2 (full buffer transmitted in both directions).
//   2. Asymmetric Forward (a -> b payload, b -> a 1-byte ACK): broadcast cost witness.
//   3. Asymmetric Reverse (b -> a payload, a -> b 1-byte ACK): gather cost witness.
void pairPingPong(int a, int b, long bytes, long iters, long warmups, int rank,
                  double *symmetricOneWay, double *asymFwdRound, double *asymRevRound) {
  std::vector<unsigned char> buf(size_t(bytes), 0);
  unsigned char ack = 0;
  const bool active = (rank == a || rank == b);
  const int peer = (rank == a) ? b : a;

  auto symmetric = [&]() {
    if (rank == a) {
      MPI_Send(buf.data(), bytes, MPI_BYTE, peer, 41, MPI_COMM_WORLD);
      MPI_Recv(buf.data(), bytes, MPI_BYTE, peer, 41, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    } else {
      MPI_Recv(buf.data(), bytes, MPI_BYTE, peer, 41, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
      MPI_Send(buf.data(), bytes, MPI_BYTE, peer, 41, MPI_COMM_WORLD);
    }
  };

  // Forward phase: rank a transmits data payload; rank b returns a 1-byte ACK
  auto asymFwd = [&]() {
    if (rank == a) {
      MPI_Send(buf.data(), bytes, MPI_BYTE, peer, 45, MPI_COMM_WORLD);
      MPI_Recv(&ack, 1, MPI_BYTE, peer, 46, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    } else {
      MPI_Recv(buf.data(), bytes, MPI_BYTE, peer, 45, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
      MPI_Send(&ack, 1, MPI_BYTE, peer, 46, MPI_COMM_WORLD);
    }
  };

  // Reverse phase: rank b transmits data payload; rank a returns a 1-byte ACK
  auto asymRev = [&]() {
    if (rank == b) {
      MPI_Send(buf.data(), bytes, MPI_BYTE, peer, 47, MPI_COMM_WORLD);
      MPI_Recv(&ack, 1, MPI_BYTE, peer, 48, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    } else {
      MPI_Recv(buf.data(), bytes, MPI_BYTE, peer, 47, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
      MPI_Send(&ack, 1, MPI_BYTE, peer, 48, MPI_COMM_WORLD);
    }
  };

  double sym = 0.0, asymF = 0.0, asymR = 0.0;
  if (active) {
    for (long i = 0; i < warmups; ++i) symmetric();
    double t0 = MPI_Wtime();
    for (long i = 0; i < iters; ++i) symmetric();
    sym = (MPI_Wtime() - t0) / (2.0 * iters);

    for (long i = 0; i < warmups; ++i) asymFwd();
    t0 = MPI_Wtime();
    for (long i = 0; i < iters; ++i) asymFwd();
    asymF = (MPI_Wtime() - t0) / double(iters);

    for (long i = 0; i < warmups; ++i) asymRev();
    t0 = MPI_Wtime();
    for (long i = 0; i < iters; ++i) asymRev();
    asymR = (MPI_Wtime() - t0) / double(iters);
  }
  MPI_Barrier(MPI_COMM_WORLD);

  double mineSym = (rank == a) ? sym : 0.0;
  double mineAsymF = (rank == a) ? asymF : 0.0;
  double mineAsymR = (rank == a) ? asymR : 0.0;
  MPI_Allreduce(&mineSym, symmetricOneWay, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);
  MPI_Allreduce(&mineAsymF, asymFwdRound, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);
  MPI_Allreduce(&mineAsymR, asymRevRound, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);
}

// Mirrors conversions/dhirtompi.h: root receives incoming buffers sequentially from each worker
double hubGather(int root, long bytes, long iters, long warmups, int rank, int size,
                 bool syncEachRound) {
  std::vector<unsigned char> buf(size_t(bytes), 0);
  unsigned char token = 0;
  auto round = [&]() {
    if (rank == root) {
      for (int r = 0; r < size; ++r) {
        if (r == root) continue;
        MPI_Send(&token, 1, MPI_BYTE, r, 60, MPI_COMM_WORLD);
        MPI_Recv(buf.data(), bytes, MPI_BYTE, r, 61, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
      }
    } else {
      MPI_Recv(&token, 1, MPI_BYTE, root, 60, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
      MPI_Send(buf.data(), bytes, MPI_BYTE, root, 61, MPI_COMM_WORLD);
    }
  };

  for (long i = 0; i < warmups; ++i) round();
  MPI_Barrier(MPI_COMM_WORLD);

  double total = 0.0;
  if (syncEachRound) {
    for (long i = 0; i < iters; ++i) {
      MPI_Barrier(MPI_COMM_WORLD);
      double t0 = MPI_Wtime();
      round();
      total += MPI_Wtime() - t0;
    }
  } else {
    double t0 = MPI_Wtime();
    for (long i = 0; i < iters; ++i) round();
    total = MPI_Wtime() - t0;
  }
  double elapsed = total / double(iters);
  double mine = (rank == root) ? elapsed : 0.0, out = 0.0;
  MPI_Allreduce(&mine, &out, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);
  return out;
}

// Mirrors libs/utils.cc generateBroadcastCommunication: root transmits buffers sequentially by rank order
double hubBroadcast(int root, long bytes, long iters, long warmups, int rank, int size,
                    bool syncEachRound) {
  std::vector<unsigned char> buf(size_t(bytes), 0);
  unsigned char ack = 0;
  auto round = [&]() {
    if (rank == root) {
      for (int r = 0; r < size; ++r) {
        if (r == root) continue;
        MPI_Send(buf.data(), bytes, MPI_BYTE, r, 71, MPI_COMM_WORLD);
        MPI_Recv(&ack, 1, MPI_BYTE, r, 72, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
      }
    } else {
      MPI_Recv(buf.data(), bytes, MPI_BYTE, root, 71, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
      MPI_Send(&ack, 1, MPI_BYTE, root, 72, MPI_COMM_WORLD);
    }
  };

  for (long i = 0; i < warmups; ++i) round();
  MPI_Barrier(MPI_COMM_WORLD);

  double total = 0.0;
  if (syncEachRound) {
    for (long i = 0; i < iters; ++i) {
      MPI_Barrier(MPI_COMM_WORLD);
      double t0 = MPI_Wtime();
      round();
      total += MPI_Wtime() - t0;
    }
  } else {
    double t0 = MPI_Wtime();
    for (long i = 0; i < iters; ++i) round();
    total = MPI_Wtime() - t0;
  }
  double elapsed = total / double(iters), out = 0.0;
  double mine = (rank == root) ? elapsed : 0.0;
  MPI_Allreduce(&mine, &out, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);
  return out;
}

// Incast pattern: workers initiate sends concurrently while root posts asynchronous receives
double incast(int root, long bytes, long iters, long warmups, int rank, int size,
              bool syncEachRound) {
  std::vector<unsigned char> buf(size_t(bytes), 0);
  std::vector<unsigned char> recvBuf(size_t(bytes) * (size > 1 ? size - 1 : 1), 0);
  std::vector<MPI_Request> reqs(size > 1 ? size - 1 : 1);
  auto round = [&]() {
    if (rank == root) {
      for (int r = 0, k = 0; r < size; ++r) {
        if (r == root) continue;
        MPI_Irecv(recvBuf.data() + size_t(bytes) * k, bytes, MPI_BYTE, r, 51,
                  MPI_COMM_WORLD, &reqs[k]);
        ++k;
      }
      MPI_Waitall(size - 1, reqs.data(), MPI_STATUSES_IGNORE);
    } else {
      MPI_Send(buf.data(), bytes, MPI_BYTE, root, 51, MPI_COMM_WORLD);
    }
  };

  for (long i = 0; i < warmups; ++i) round();
  MPI_Barrier(MPI_COMM_WORLD);

  double total = 0.0;
  if (syncEachRound) {
    for (long i = 0; i < iters; ++i) {
      MPI_Barrier(MPI_COMM_WORLD);
      double t0 = MPI_Wtime();
      round();
      total += MPI_Wtime() - t0;
    }
  } else {
    double t0 = MPI_Wtime();
    for (long i = 0; i < iters; ++i) round();
    total = MPI_Wtime() - t0;
  }
  double elapsed = total / double(iters);
  double out = 0.0;
  double mine = (rank == root) ? elapsed : 0.0;
  MPI_Allreduce(&mine, &out, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);
  return out;
}

// Baseline benchmark using vendor MPI_Bcast implementation
double libBroadcast(int root, long bytes, long iters, long warmups) {
  std::vector<unsigned char> buf(size_t(bytes), 0);
  for (long i = 0; i < warmups; ++i)
    MPI_Bcast(buf.data(), bytes, MPI_BYTE, root, MPI_COMM_WORLD);
  MPI_Barrier(MPI_COMM_WORLD);
  double t0 = MPI_Wtime();
  for (long i = 0; i < iters; ++i)
    MPI_Bcast(buf.data(), bytes, MPI_BYTE, root, MPI_COMM_WORLD);
  double elapsed = (MPI_Wtime() - t0) / double(iters);
  double out = 0.0;
  MPI_Allreduce(&elapsed, &out, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);
  return out;
}

// Measures global communicator synchronization duration using MPI_Barrier
double barrierSeconds(long iters, long warmups) {
  for (long i = 0; i < warmups; ++i) MPI_Barrier(MPI_COMM_WORLD);
  double t0 = MPI_Wtime();
  for (long i = 0; i < iters; ++i) MPI_Barrier(MPI_COMM_WORLD);
  double elapsed = (MPI_Wtime() - t0) / double(iters);
  double out = 0.0;
  MPI_Allreduce(&elapsed, &out, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);
  return out;
}

}  // namespace

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  int rank = 0, size = 0;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  long netIters = argc > 1 ? parseLong(argv[1], "net iterations") : 100;
  long netWarmups = argc > 2 ? parseLong(argv[2], "net warmups") : 10;
  int repeats = argc > 3 ? int(parseLong(argv[3], "repeats")) : 2;

  std::vector<long> sizes;
  for (int i = 4; i < argc && int(sizes.size()) < kMaxSizes; ++i)
    sizes.push_back(parseLong(argv[i], "message size"));
  if (sizes.empty())
    sizes = {8, 1024, 32768, 262144, 1048576, 4194304, 16777216};

  // Split communicator by shared memory to detect co-located ranks on physical nodes
  MPI_Comm nodeComm = MPI_COMM_NULL;
  MPI_Comm_split_type(MPI_COMM_WORLD, MPI_COMM_TYPE_SHARED, rank, MPI_INFO_NULL, &nodeComm);
  int localRank = 0, localSize = 1;
  MPI_Comm_rank(nodeComm, &localRank);
  MPI_Comm_size(nodeComm, &localSize);
  int nodeLeader = rank;
  MPI_Allreduce(MPI_IN_PLACE, &nodeLeader, 1, MPI_INT, MPI_MIN, nodeComm);

  NodePlacement mine{};
  gethostname(mine.host, sizeof(mine.host) - 1);
  mine.localRank = localRank;
  mine.localSize = localSize;
  mine.nodeIndex = nodeLeader;

  std::vector<NodePlacement> all(rank == 0 ? size : 0);
  MPI_Gather(&mine, sizeof(NodePlacement), MPI_BYTE,
             rank == 0 ? all.data() : nullptr, sizeof(NodePlacement), MPI_BYTE, 0,
             MPI_COMM_WORLD);

  if (rank == 0) {
    std::puts("CLUSTERCAL,record,fields...");
    for (int r = 0; r < size; ++r) {
      const NodePlacement &x = all[r];
      std::printf("CLUSTERCAL,node,%d,%d,%s,%d,%d,%d\n", 0, r, x.host,
                  x.localRank, x.localSize, x.nodeIndex);
    }
    std::fflush(stdout);
  }

  for (int rep = 0; rep < repeats; ++rep) {
    // Spoke ping-pong measurements between coordinator (rank 0) and each worker
    for (long bytes : sizes) {
      for (int b = 1; b < size; ++b) {
        double sym = 0.0, asymF = 0.0, asymR = 0.0;
        pairPingPong(0, b, bytes, netIters, netWarmups, rank, &sym, &asymF, &asymR);
        if (rank == 0) {
          std::printf("CLUSTERCAL,link,%d,%d,%d,%ld,%ld,%.9g,%.9g,%.9g\n",
                      rep, 0, b, bytes, netIters, sym, asymF, asymR);
        }
      }
    }

    // Empirical collective pattern evaluations
    if (size > 1) {
      for (long bytes : sizes) {
        double inSync = incast(0, bytes, netIters, netWarmups, rank, size, true);
        double inPipe = incast(0, bytes, netIters, netWarmups, rank, size, false);
        double hgSync = hubGather(0, bytes, netIters, netWarmups, rank, size, true);
        double hgPipe = hubGather(0, bytes, netIters, netWarmups, rank, size, false);
        double hbSync = hubBroadcast(0, bytes, netIters, netWarmups, rank, size, true);
        double hbPipe = hubBroadcast(0, bytes, netIters, netWarmups, rank, size, false);
        double lb = libBroadcast(0, bytes, netIters, netWarmups);
        if (rank == 0) {
          std::printf("CLUSTERCAL,incast,%d,0,%ld,%ld,%.9g,%.9g\n",
                      rep, bytes, netIters, inSync, inPipe);
          std::printf("CLUSTERCAL,hubgather,%d,0,%ld,%ld,%.9g,%.9g\n",
                      rep, bytes, netIters, hgSync, hgPipe);
          std::printf("CLUSTERCAL,hubbcast,%d,0,%ld,%ld,%.9g,%.9g\n",
                      rep, bytes, netIters, hbSync, hbPipe);
          std::printf("CLUSTERCAL,libbcast,%d,0,%ld,%ld,%.9g,%.9g\n",
                      rep, bytes, netIters, lb, lb);
        }
      }
    }

    // Barrier synchronization latency benchmark
    double bar = barrierSeconds(netIters, netWarmups);
    if (rank == 0) {
      std::printf("CLUSTERCAL,barrier,%d,%ld,%.9g\n", rep, netIters, bar);
      std::fflush(stdout);
    }
  }

  MPI_Comm_free(&nodeComm);
  MPI_Finalize();
  return 0;
}

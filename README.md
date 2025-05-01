# 🥗 Avial : An MLIR Dialect for Distributed Heterogeneous Computing
Avial is a compiler infrastructure built using MLIR that enables efficient execution of programs across distributed and heterogeneous computing systems (CPU, GPU, cluster). Avial introduces a novel task-centric intermediate representation (IR) where tasks are first-class citizens, capturing their parallelism, device targets, and interdependencies. The infrastructure supports:

- High-level task modeling with explicit control over execution and communication.
- Optimizations for communication, task fusion, and scheduling across devices and nodes.
- Lowering to existing MLIR dialects, with code generation for multicore CPUs, GPUs, and distributed backends (e.g., MPI).

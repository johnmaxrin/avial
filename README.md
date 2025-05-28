# 🥗 Avial : An MLIR Dialect for Distributed Heterogeneous Computing
Avial is a compiler infrastructure built using MLIR that enables efficient execution of programs across distributed and heterogeneous computing systems (CPU, GPU, cluster). Avial introduces a novel task-centric intermediate representation (IR) where tasks are first-class citizens, capturing their parallelism, device targets, and interdependencies. The infrastructure supports:

## 🚧 Project Status  
![Current Focus](https://img.shields.io/badge/Current_Focus-Topology_Aware_Optimizations-blue) <br>
![Next Release](https://img.shields.io/badge/Next_Release-Multicore_+_GPU_+_Topology_Aware_Scheduling-white) <br>
![GitHub last commit](https://img.shields.io/github/last-commit/johnmaxrin/avial?color=teal)<br>
![Open Issues](https://img.shields.io/github/issues-raw/johnmaxrin/avial?label=issues)  


## Why is parallel programming hard?

Parallel programming is notoriously difficult. Developers must reason about concurrency, memory consistency, synchronization, and performance optimization, all of which are challenging even in a single-threaded environment. The situation is further complicated by the fragmented nature of parallel programming frameworks: multicore CPUs are commonly programmed using POSIX threads or OpenMP, distributed memory systems use MPI, and accelerators like GPUs are typically programmed using CUDA, OpenCL, or OpenACC. Each of these paradigms comes with its own abstractions and programming idioms.

> _In parallel programming, you need to think about how and where your code runs, not just what it does._

Unifying these paradigms into a single coherent programming or compilation model is non-trivial due to fundamental differences in their memory models, synchronization semantics, and communication mechanisms. While there have been commendable efforts at unifying heterogeneous computing within a node. Such as OpenCL, OpenACC, and more recently Mojo. There is a noticeable gap when it comes to extending these unifications across distributed environments. The gap remains largely due to the complexity of distributed computing: issues such as explicit data movement between the nodes and network topology cannot be abstracted away as easily.

## Why Avial Is Unique?

While MLIR includes dialects like omp for shared-memory parallelism and gpu for targeting accelerators such as CUDA or ROCm, there is currently no dialect that provides a unified abstraction for distributed heterogeneous computing, that is, for clusters of nodes with diverse compute units like CPUs and GPUs.

The `mpi` dialect in MLIR offers low-level building blocks that reflect traditional MPI operations (e.g., `send`, `recv`, `bcast`). However, it requires the programmer to manage rank assignments, data partitioning, topology awareness, and task scheduling manually. This is error-prone and non-trivial, especially as system complexity scales.

Our dialect builds on top of the MPI dialect, But raises the level of abstraction. Users express what computation needs to be performed and whether it should run on a CPU or GPU, without worrying about the underlying distributed communication or resource allocation. 

> _This dialect bridges the gap between `device` and `cluster` level parallelism, making it an MLIR dialect that can target distributed heterogeneous systems._

## The `Codedrop` Approach
In  high-performance computing environments, applications often contain a mix of compute regions. Some better suited for multicore CPUs, others for GPUs. Traditionally, orchestrating these different parts involves complex code: different frameworks (e.g., OpenMP, CUDA, MPI), manual device management, and tedious boilerplate. The CodeDrop approach introduces a task-oriented, declarative model that streamlines this process:
> _Drop your computation. Declare the target. Let the dialect take care of the rest._

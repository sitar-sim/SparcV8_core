# Parallel Simulation

The sitar_model of the `multicore` configuration can run on several
host threads at once, with each thread simulating some of the cores.
The result of a parallel run is identical to the result of a serial
run, cycle for cycle. The general page on [Parallel
Simulation](../parallel_simulation.md) explains why that holds, and
when a parallel run is faster. This page covers how to build and run
this configuration in parallel, and how its modules are divided among
threads.

---

## Building and running

Parallel simulation needs an executable built with OpenMP.

```sh
cd model/system_models/multicore/sitar_model
./build.sh --openmp
```

This produces `sparc_sim_sitar_multicore_openmp`, alongside the serial
executable. `--openmp` combines with `--logging`, which produces
`sparc_sim_sitar_multicore_logging_openmp`.

The number of threads is set with `--threads`, or with OpenMP's own
`OMP_NUM_THREADS`. Without either, the run uses one thread, since a
small system runs slower in parallel (see [Speed](#speed)).

```sh
./executable/sparc_sim_sitar_multicore_openmp my_test.hex my_test.expected 5000000 --threads 2
OMP_NUM_THREADS=2 ./executable/sparc_sim_sitar_multicore_openmp my_test.hex
```

With one thread, the executable runs serially. The number of threads is
limited to `NUM_CORES`, since a thread with no core of its own would
only add work at every barrier. `--stats` prints which modules each
thread ran.

```
=== threads ===
 2 thread(s):
	 thread 0 = cores[0] cores[1]
	 thread 1 = cores[2] cores[3] bridge mainMemory devices system
```

---

## Dividing the modules among threads

The units divided among threads are the modules directly under
`System`. These are each `cores[i]`, with its core, caches and MMU
inside it, and the four modules that every core shares: `bridge`,
`mainMemory`, `devices`, and `system` itself.

The division is **static**. A thread runs the same modules in every
phase of the whole run (see [Dividing the modules among
threads](../parallel_simulation.md#dividing-the-modules-among-threads)).

### The default division

By default each thread takes a block of cores with consecutive
numbers, as evenly as possible. When the cores do not divide evenly,
the lower-numbered threads take one core more. The four shared modules
do little work in a cycle, so they never get a thread of their own.
They join the last of the threads with the fewest cores.

| Cores | Threads | Default division |
|---|---|---|
| 4 | 2 | thread 0: cores 0 and 1. thread 1: cores 2 and 3, and the shared modules. |
| 4 | 3 | thread 0: cores 0 and 1. thread 1: core 2. thread 2: core 3, and the shared modules. |
| 4 | 4 | one core per thread, and the shared modules with core 3. |

### Choosing the division

`--thread-map` gives the thread of every module, in the order `--stats`
prints them: `cores[0]` to `cores[NUM_CORES-1]`, then `bridge`,
`mainMemory`, `devices` and `system`. The number of threads is then the
largest thread number named, plus 1.

```sh
# cores 0 and 1 on thread 0, cores 2 and 3 on thread 1, shared modules on thread 0
./executable/sparc_sim_sitar_multicore_openmp my_test.hex --thread-map 0,0,1,1,0,0,0,0
```

A good division gives every thread about the same work per phase. The
cores do most of the work. The shared modules are light, but the bridge
and main memory serve every core's bus traffic, so with many bus
transactions they add noticeably to their thread's load. A thread with
the shared modules can then be given one core fewer than the others.

### Binding threads to host CPUs

OpenMP's own environment variables bind each thread to one host CPU
for the whole run.

```sh
OMP_PROC_BIND=true OMP_PLACES=cores ./executable/sparc_sim_sitar_multicore_openmp ...
```

---

## When the run stops

A run stops when `System` calls `stop simulation`, once every running
core has halted (see [The end of a
run](structure.md#the-end-of-a-run)). Every thread leaves the parallel
loop after the phase in which that call was made, so a parallel run
ends on the same cycle as a serial run (see [When the run
stops](../parallel_simulation.md#when-the-run-stops)).

---

## Logging in a parallel run

A `--logging` build writes each core's instruction trace to its own
file in a parallel run too, exactly as in a serial run (see [Logging
and Debugging](debugging.md)). The Sitar module log is the one shared
stream, and lines written to it from several threads would interleave.
A parallel run therefore gives each thread its own module log,
`sitar.thread0.log`, `sitar.thread1.log`, and so on, which hold the
log lines of that thread's modules. `sitar.log` is then left empty.

---

## Speed

One SPARC core of this model does a fraction of a microsecond of work
in a phase, about what a barrier costs. The `multicore` configuration,
with 4 cores and the shared modules, has too little work per phase for
2 or more threads to gain. It runs a little slower in parallel than
serially (see the
[measurements](../parallel_simulation.md#measurements)). Its parallel
mode is therefore most useful as a check that a model keeps to Sitar's
two-phase rule, and as a starting point for larger models, such as the
64-core [speedup demonstration](../parallel_simulation.md#a-larger-model).


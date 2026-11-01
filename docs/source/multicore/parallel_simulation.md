# Parallel Simulation

The sitar_model of the `multicore` configuration can run on several
host threads at once, with each thread simulating some of the cores.
The result of a parallel run is identical to the result of a serial
run, cycle for cycle. This page explains why that holds, how to build
and run a parallel simulation, how the modules are divided among
threads, and when a parallel run is actually faster.

---

## Why the result does not change

Sitar runs a model in cycles of two phases. Within a phase every module
runs once, and modules exchange data only through nets. A value written
to a net in one phase can be read only in a later phase. The modules
therefore do not depend on each other within a phase, and they can run
in any order, or at the same time, without changing what any of them
computes.

A parallel run uses this. Each host thread runs its own share of the
modules for a phase, and then waits at a barrier until every thread has
finished that phase. Only then does any thread start the next phase.
There are two barriers per cycle, one after each phase. This is the
same scheme as Sitar's own parallel main, in its
`sitar_default_main.cpp`.

No module of this model draws random numbers, so no random number
generator has to be given to each thread.

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
small system runs slower in parallel (see [When a parallel run is
faster](#when-a-parallel-run-is-faster)).

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
phase of the whole run, and no module ever moves to another thread. A
core's state therefore stays in the caches of the host CPU that runs
it, which matters for speed as much as the division of work does.

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

The division keeps each module on one thread, but the operating system
can still move a thread from one host CPU to another. OpenMP's own
environment variables bind each thread to one CPU for the whole run.

```sh
OMP_PROC_BIND=true OMP_PLACES=cores ./executable/sparc_sim_sitar_multicore_openmp ...
```

On a host whose cores run two hardware threads each,
`OMP_PLACES=cores` puts each simulation thread on a core of its own,
and `OMP_PLACES=threads` lets two of them share a core.

---

## When the run stops

A run stops when `System` calls `stop simulation`, once every running
core has halted (see [The end of a
run](structure.md#the-end-of-a-run)). Sitar's stop is a single flag,
and in a parallel run every thread must see the same value of it, or
the threads leave the loop at different phases and wait for each other
at different barriers for ever.

`System` sets the flag only in the second phase of a cycle, and the
threads read it only after the barrier that ends the second phase. No
thread can set the flag again before every thread has passed the next
barrier, so every thread reads the same value, and the run ends on the
same cycle as a serial run. Any module added to this model that stops
the simulation must therefore do so in the second phase as well.

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

## When a parallel run is faster

A parallel run always gives the same result, but it is not always
faster. Whether it is depends on how much work each thread has in a
phase, compared with what the barrier at the end of the phase costs.

### The cost of a barrier

At a barrier every thread announces that it has finished the phase, and
waits until every other thread has done the same. The announcements go
through shared memory, so each barrier moves cache lines between the
host's cores, and a waiting thread notices the last arrival only after
that line reaches it. A barrier therefore costs a roughly fixed time,
whatever the work before it. On a typical host it is a fraction of a
microsecond to a few microseconds, and it grows with the number of
threads.

Let `W` be the time a serial run spends on one phase, `n` the number of
threads, and `B` the cost of one barrier. With the work divided evenly,
a parallel run spends about `W/n + B` on the phase, so

```text
speedup  =  W / (W/n + B)
```

When `W/n` is much larger than `B`, the speedup approaches `n`. When
`W/n` is about the size of `B` or smaller, the barriers take as long as
the work, and a parallel run can be slower than a serial one. A model
gains from parallel simulation when each thread has much more work per
phase than a barrier costs.

Three other effects lower the speedup further.

- **Uneven division.** Every thread waits for the slowest, so a phase
  takes as long as the thread with the most work in it.
- **Nets between threads.** A net written by a module on one thread and
  read by a module on another moves its data between host cores every
  time it is used. Modules that talk to each other a lot are best kept
  on the same thread.
- **Host cores.** Each thread needs a host core of its own. Two threads
  sharing a core through hyperthreading share its execution units and
  caches, and gain little.

### The multicore configuration

One SPARC core of this model does a fraction of a microsecond of work
in a phase, about what a barrier costs. The `multicore` configuration,
with 4 cores and the shared modules, has too little work per phase for
2 or more threads to gain. It runs a little slower in parallel than
serially, as the measurements below show. Its parallel mode is
therefore most useful as a check that a model keeps to Sitar's
two-phase rule, and as a starting point for larger models.

### A larger model

The folder `performance_evaluation/parallel_speedup/` in the source
repository holds a model built to show what parallel simulation gains.
It is not one of the configurations, and the validation suites do not
run it. Its `Top` holds 16 copies of this configuration's `System`,
built from the same `System.sitar` and `Core.sitar`, for 64 cores in
all. The systems share nothing. Every core runs the same program, which
multiplies its own private 24 x 24 integer matrices 16 times and keeps
all of its data in its own caches. A phase then has 16 times the work of
one system, between the same two barriers, and each thread runs a block
of whole systems, so no net crosses from one thread to another.

```sh
cd performance_evaluation/parallel_speedup
./build.sh
./run_speedup.sh            # 1, 2 and 4 threads
```

`run_speedup.sh` prints, for each thread count, the cycles simulated,
the time taken, the speedup over the first run, and `PASS` if every
core of every system halted with the same result. Its README describes
the files and how to change the program's length.

### Measurements

Both models below ran the demo's program, with caching on, on the
same host, a laptop with an Intel i5-5250U (2 cores, 2 hardware
threads each). The simulators were built as `build.sh` builds them.
Every parallel run simulated exactly the same cycles, with exactly the
same results, as the serial run.

| Model | Threads | Time | Speedup |
|---|---|---|---|
| `multicore` configuration, 4 cores, 10.5 million cycles | serial | 25.2 s | 1 |
| | 2 | 27.8 s | 0.91 |
| | 4 | 34.5 s | 0.73 |
| `parallel_speedup` demo, 16 systems of 4 cores, 10.5 million cycles | serial | 493 s | 1 |
| | 2 | 245 s | 2.02 |
| | 2, each bound to its own core | 237 s | 2.08 |
| | 4 | 252 s | 1.96 |

These numbers are particular to one small host, but they show the
pattern. With 4 cores, a phase holds too little work, and every thread
count is slower than serial. With 64 cores, 2 threads reach twice the
serial speed, and slightly more when each thread is bound to a core of
its own. A speedup a little above 2 is possible because each thread's
half of the model fits better in its own host core's caches than the
whole model fits in one. 4 threads gain less on this host than 2,
because they share its 2 physical cores. On a host with many cores, a
model with many cores per thread can use many more threads.

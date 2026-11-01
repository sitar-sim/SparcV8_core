# Parallel Simulation

A Sitar model can run on several host threads at once, with each
thread simulating some of its modules. The result of a parallel run is
identical to the result of a serial run, cycle for cycle. This page
explains why that holds, what a model's main loop must do for it, and
when a parallel run is actually faster.

Today two models in this project have a main loop that runs in
parallel: the sitar_model of the [`multicore`](multicore/index.md)
configuration, and the speedup demonstration described
[below](#a-larger-model). The other configurations run serially. How
to build and run the `multicore` configuration in parallel, and how its
modules are divided among threads, is in the multicore section's own
[Parallel Simulation](multicore/parallel_simulation.md) page.

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

A model whose modules draw random numbers needs a separate generator
for each thread, or the numbers drawn would depend on the order the
threads run in. No module in this project draws random numbers.

---

## Dividing the modules among threads

Each thread runs a fixed list of modules, the same in every phase of
the whole run. No module ever moves to another thread, so a module's
state stays in the caches of the host core that runs it. OpenMP's own
environment variables can also bind each thread to one host core for
the whole run.

```sh
OMP_PROC_BIND=true OMP_PLACES=cores <simulator> ...
```

On a host whose cores run two hardware threads each,
`OMP_PLACES=cores` puts each simulation thread on a core of its own,
and `OMP_PLACES=threads` lets two of them share a core.

---

## When the run stops

A model stops a run with `stop simulation`, which sets a single flag.
In a parallel run every thread must see the same value of it, or the
threads leave the loop at different phases and wait for each other at
different barriers for ever. A thread that has moved on into the next
phase could set the flag while a slower thread is still reading it
after the barrier.

The models here therefore stop the simulation in the second phase of a
cycle only, and their main loops read the flag only after the barrier
that ends the second phase. No thread can set the flag again before
every thread has passed the next barrier, so every thread reads the
same value, and the run ends on the same cycle as a serial run.

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

### A larger model

The folder `performance_evaluation/parallel_speedup/` in the source
repository holds a model built to show what parallel simulation gains.
It is not one of the configurations, and the validation suites do not
run it. Its `Top` holds 16 copies of the `multicore` configuration's
`System`,
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

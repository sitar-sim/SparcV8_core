# performance_evaluation/parallel_speedup/

A demonstration of parallel Sitar simulation's speedup. The model holds
16 independent copies of the `multicore` configuration's `System`, each
with 4 cores, its own bus, main memory and devices, for 64 cores in all.
Every system runs the same program, in which each core multiplies its
own private matrices. The systems never communicate, so each simulated
cycle has a lot of work for very little communication between threads,
the setting where a parallel run pays off. The `multicore`
configuration itself, with only 4 cores, runs slower in parallel. The
[Parallel Simulation](https://sitar-sim.github.io/SparcV8_core/parallel_simulation.html)
page explains why, and reports this demo's speedups.

## Files

- `src/Top.sitar` holds the 16 systems, and stops the run once all of
  them have halted. The systems themselves come from
  `model/system_models/multicore/sitar_model/src/System.sitar` and
  `Core.sitar`, built in unchanged.
- `src/speedup_sim.cpp` is the simulator's main. It loads the program
  into every system, turns caching on, runs the simulation on the
  requested number of host threads, and checks every core's result.
  Each thread runs a fixed block of whole systems.
- `program/private_matmul.c` is the program every core runs. Its `REPS`
  sets how long the run is.
- `run_speedup.sh` runs the demo at several thread counts and prints the
  speedups.

## Building and running

```sh
./build.sh                       # executable/speedup_sim_openmp
./run_speedup.sh                 # 1, 2 and 4 threads
./run_speedup.sh 1 2             # chosen thread counts
./executable/speedup_sim_openmp program/private_matmul.hex --threads 2
```

With `REPS` at 16 the program runs for about 10.5 million cycles, and a
serial run takes about 8 minutes on a laptop. Doubling `REPS` about
doubles the run. After
changing `REPS`, rebuild the program from this folder with

```sh
source ../../compiler/toolchain_env.sh
CRT0=crt0_multicore.s ../../compiler/compile_c.sh program/private_matmul.c program/private_matmul
```

Every run reports the cycles simulated, the time taken, and `PASS` if
every core of every system halted with the same result. The cycle count
and the results are the same whatever the number of threads.

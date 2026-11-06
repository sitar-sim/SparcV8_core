# OpenMP Programs

A program for the multicore system can use real OpenMP pragmas. The cross compiler,
`sparc-elf-gcc` 4.4, turns the pragmas into calls to a runtime library, and the toolchain has
no such library for a bare-metal target. The header
[`omp.h`](https://github.com/sitar-sim/SparcV8_core/blob/main/compiler/sparc_common_routines/omp.h)
provides one, written for this project. It implements OpenMP 3.0, with the limits listed
[below](#limits).

---

## A first program

```c
#include <omp.h>

int main(void)
{
    int i, sum = 0;

#pragma omp parallel for reduction(+:sum)
    for (i = 1; i <= 100; i++)
        sum += i;

    return sum;
}
```

The program needs two things from its build. The compiler option `-fopenmp` turns the pragmas
on, and the startup file `crt0_multicore.s` brings up all the cores. In a test's `.vprj` these
are two lines.

```
SOURCES = my_program.c
STARTUP = crt0_multicore.s
COMPILE_OPTIONS = -fopenmp
RUN_OPTIONS = --coherent
```

The same build by hand is as follows.

```sh
CRT0=crt0_multicore.s COMPILE_OPTIONS=-fopenmp $SPARC_HOME/compiler/compile_c.sh my_program.c
./executable/sparc_sim_cpp_multicore my_program.hex "" 5000000 --coherent
```

The compiler prints `unrecognized option '-pthread'`, because `-fopenmp` asks for that option
and this compiler has no threads library. The message is harmless.

The header holds the whole runtime, so the program includes it in its one source file, even
if it calls no `omp_` routine. Without it, the program does not link.

---

## How a program runs

The startup file calls `main()` on every core. The header defines `main()` itself and renames
the program's own, so that only core 0 runs the program, as OpenMP expects. Cores 1 and up wait
for work.

A parallel region's team of `n` threads is cores 0 to `n-1`, and a thread's number is its core's
ID. Core 0 fills in a description of the team, and then wakes each worker through a word that
only that worker waits on. At the end of the region, all the threads meet at a barrier, and the
workers go back to waiting.

When the program's `main()` returns, the workers halt, and core 0 halts with the return value in
`%o0`. The run then ends, since every core has halted. A program can also end with
`omp_end_program(o0, o1)`, which sets both registers, from outside any parallel region. A plain
`ta 0` is not enough, since it halts core 0 alone, and the run would go on until its cycle limit.
Each worker halts with `%o0` = 1, so a test can check that the workers stopped in an orderly way.

The header also turns the FPU on, on every core. The startup files leave it off, and a worker
would have no chance to turn it on before running part of a region.

### How many threads

At startup, core 0 waits a bounded time for the other cores to report in. A core held back by
`--run-cores` never does, so `omp_get_num_procs()` gives the number of cores really running,
and a program run with `--run-cores 1` still finishes, with every team having one thread. The
wait comes only when a core is missing. The test `on_one_core`, which does little else, takes
about 870 thousand cycles on the cpp_model.

A region gets as many threads as `num_threads`, `omp_set_num_threads()` or the default says, and
never more than the number of cores. The default is one thread for each core.

---

## Memory

OpenMP's threads share memory, so a program's shared data must reach every core. There are two
ways to run a program for which this holds.

| Run | Shared data | Timing |
|---|---|---|
| The default, MMU off and no options | Nothing is cached, so every load sees main memory | Every fetch and load goes over the bus, as in the [other programs](validation.md#how-long-the-tests-run) |
| `--always-cacheable --coherent` | Cached, and [coherent](programming.md#coherent-caches) | The most realistic |

With `--always-cacheable` alone a thread can read a stale copy of shared data, so a program gets
wrong answers, and a loop waiting on a shared flag may never end. The tests all set
`RUN_OPTIONS = --coherent`, so they are coherent whichever way they run.

`#pragma omp flush` compiles to `STBAR`, which orders stores in the model only as much as they
are already ordered, since the model has no store buffer. It does not refresh a cached copy.
Under `--coherent` it does not need to.

If a program turns the MMU on, its shared data must be identity-mapped, since the runtime's
uncached reads take a physical address. This is the same limit as for the rest of
[the library](programming.md#limits-of-these-routines). The OpenMP tests all run with the MMU
off, so this combination is untested.

---

## What is supported

| Feature | Notes |
|---|---|
| `parallel`, with `if`, `num_threads`, `shared`, `private`, `firstprivate`, `reduction`, `copyin` | A nested region has a team of one. |
| `for`, with `schedule(static, dynamic, guided, runtime)`, `ordered`, `lastprivate`, `nowait`, `collapse` | A plain `schedule(static)` is compiled inline, and its blocks are sized by the compiler. |
| `sections`, `single`, `copyprivate`, `master` | |
| `critical`, named and unnamed, `atomic`, `barrier`, `ordered`, `flush` | `atomic` takes one lock, since SPARC V8 has no compare-and-swap. |
| `task`, `taskwait` | Tasks run at once, on the thread that creates them. |
| `threadprivate` | Each core keeps its copies on its own stack, reached through `%g7`. |
| `omp_` routines for teams, levels, schedules and locks | All of those in OpenMP 3.0, but for the clock routines. |

### Limits

- **Tasks give no speedup.** A task runs when it is created, on the thread that creates it, which
  OpenMP allows. A program gets the right results, but all the tasks made by one `single` run on
  one core.
- **A nested region has a team of one**, so `omp_set_nested()` has no effect. This is also what a
  host's OpenMP does by default. At most `OMP_MAX_SERIAL_DEPTH` (8) nested regions can be open
  at once. Going deeper ends the run with the code `0xBAD0E571` in `%o0`.
- **There is no `omp_get_wtime()`,** since the system has no clock a program can read. The
  simulator reports cycles at the end of a run, so a program's timing is measured from outside.
- **`omp_set_dynamic()` has no effect.** Teams always have the number of threads asked for, up to
  the number of cores.
- **Loops that need 64-bit iteration counts do not link**, since `GOMP_loop_ull_*` is not provided.
- **OpenMP must not be used from an interrupt handler**, like the rest of the library.
- **A program has one source file**, as for every C program here, and the header goes in it.

---

## A worked example

[`openmp_matmul.c`](https://github.com/sitar-sim/SparcV8_core/blob/main/validation/multicore/examples/openmp_matmul/openmp_matmul.c)
multiplies two matrices with one pragma, where [the same work done by
hand](examples.md#parallel-matrix-multiply) needs flags and flushes.

```c
#pragma omp parallel for private(j, k) schedule(static)
for (i = 0; i < N; i++)
    for (j = 0; j < N; j++)
    {
        int32_t sum = 0;
        for (k = 0; k < N; k++)
            sum += a[i][k] * b[k][j];
        c[i][j] = sum;
    }
```

The table gives the cycles for each team size, on the sitar_model with `--always-cacheable
--coherent`. The program checks its answer by doing the same work again on core 0 alone. The
last column is for a copy of the program with that check taken out.

| Threads | Whole program | Without the check | Speedup, without the check |
|---|---|---|---|
| 1 | 3,338,310 | 1,848,091 | 1.00 |
| 2 | 2,489,576 | 1,060,430 | 1.74 |
| 3 | 2,210,160 | 760,176 | 2.43 |
| 4 | 2,098,131 | 666,029 | 2.77 |

The whole program gains far less, since about half of its single-thread run is the check, which
no number of threads can shorten. Without the check, the speedup still falls short of the number
of threads, since core 0 alone fills in the inputs, and all the cores share one bus.

To change the team's size, build with `COMPILE_OPTIONS="-fopenmp -DTHREADS=2"`.

---

## How the runtime was checked

The tests are in `validation/multicore/openmp/` (see [the validation suite](validation.md#openmp)).
Each one is a self-checking program, and eleven of the fifteen also build with the host's
`gcc -fopenmp`. The script `check_on_host.py` in that folder runs those eleven on the host with
four threads and compares their results with what the `.vprj` files hold the simulators to. So
those tests are checked against a real OpenMP implementation, and the runtime is checked against
the tests.

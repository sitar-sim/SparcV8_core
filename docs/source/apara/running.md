# Writing and Running APARA Programs

The `apara` configuration is one APARA engine on its own, with no SPARC
core around it. It is the place to write, run, and debug engine
programs, and to study the engine's timing, before using the engine
from a SPARC program (see [The Engine in a System](system.md)).

A run works like this: the simulator places the program in the
engine's IMEM, the initial data in its DMEM, and the initial register
values in its registers, starts one or more threads, and runs until
every thread it started has stopped. It then reports how each thread
stopped, and, if given the expected final state, checks it.

Like every configuration, `apara` comes as a fast functional model
(cpp_model) and a cycle-level timing model (sitar_model), with the same
command line.

---

## Building

From the repo root:

```bash
model/system_models/apara/cpp_model/build.sh      # executable/apara_sim_cpp
model/system_models/apara/sitar_model/build.sh    # executable/apara_sim_sitar (needs the sitar CLI)
```

---

## Running a program

Assemble the program (see [APARA Assembly Language and
Tools](assembly_and_tools.md)), then run the object file:

```bash
python3 compiler/apara/apara_as.py prog.mcode
model/system_models/apara/cpp_model/executable/apara_sim_cpp \
        -p 0x0 -i prog.obj -d data.map -a registers.txt -r results.txt
```

The options:

| Option | Meaning |
|---|---|
| `-p <pc>` | Start a thread at `<pc>` (hexadecimal, an IMEM word index). Repeat it to start threads 1, 2, and 3 too. Without `-p`, one thread starts at 0. |
| `-i <file>` | The object file. |
| `-d <file>` | DMEM's initial contents (a data file). |
| `-a <file>` | Initial register values. |
| `-r <file>` | The expected final state. The run prints `PASS`, or the mismatches and `FAIL`. |
| `--dump-results <file>` | Write the final state as a results file (`-` for the screen). |
| `--stats` | Print statistics: per-thread counts (cpp_model), or the pipeline's counters (sitar_model, see [APARA Timing Model](timing_model.md#knobs)). |
| `--trace` | Print every bundle executed (cpp_model). |
| `--max-bundles <n>` / `--max-cycles <n>` | Stop a run that does not end on its own (cpp_model / sitar_model). |
| `--latency-file <file>` | Change instruction latencies (sitar_model, see [APARA Timing Model](timing_model.md#timing-rules)). |

The file formats are described in [File
formats](assembly_and_tools.md#file-formats).

The exit status is 0 for `PASS`, or, without `-r`, when every thread
stopped with `$halt`. It is 1 otherwise (a mismatch, an exception, or a
thread still running at the limit), and 2 for an error in the command
line or the files. That makes the simulators easy to use from scripts.

### Watching a program run

`--trace` prints one line per bundle executed: its thread and address,
its instructions (without the `$null`s), and, if it did not continue to
the next bundle, where it went. For example, the end of a loop, from
`validation/apara/isa/control/control.mcode`:

```text
t0 0x0:  ? ($i64) $r1 > --1 $goto pc+0;  + $r2 ($i64) $r2 $r1;  -> 0x0
t0 0x0:  ? ($i64) $r1 > --1 $goto pc+0;  + $r2 ($i64) $r2 $r1;
t0 0x8:  ? ($f32) $r3 < $goto pc+16;  -> 0x18
t0 0x18:  ? ($i16) $r4 < $goto pc+16;  + $r5 ($i64) $r0 1;  -> 0x28
t0 0x28:  $call pc+32;  + $r10 ($i64) $r0 16;  -> 0x48
```

The bundle at 0x0 branches back to itself while `$r1` is above 0,
counting `$r1` down each time. On its last pass the branch is not
taken, and the thread falls through to 0x8.

A thread that stops on an exception is reported with the slot and the
cause:

```text
thread 1: stopped at 0x8 by an exception: slot 4 unaligned memory address;
```

---

## Tests

`validation/apara/` holds the engine's own test suites, one folder each:

| Folder | Tests | What they check |
|---|---|---|
| `isa/` | 29 | Every instruction, in one subfolder per class (`alu_int`, `alu_float`, `vector`, `cast`, `bits`, `cmov`, `memory`, `control`): each operation on each type, edge values (wraparound, sign extension, rounding), immediates and increments at their limits, and every exception. |
| `sequences/` | 7 | Instructions working together: full 8-slot bundles, loops, a recurrence in one bundle per step, a block copy with auto-increments, threads sharing DMEM, one thread's fault not stopping the others. |
| `hazards/` | 10 | The pipeline's handling of dependences between bundles (see [Hazards](#hazards)). |
| `predictor/` | 6 | The branch predictor: loops, nested loops, two branches sharing a predictor entry, calls and returns. Each test's mispredict count is derived from the [predictor's rules](timing_model.md#branch-prediction). |
| `asm_errors/` | 21 | Programs the assembler must reject: a register written twice in a bundle (also through multi-register writes and increments), too many control transfers, divides or memory operations in a bundle, values out of range, invalid types. |
| `timing/` | 10 | Microbenchmarks with exact cycle counts, derived by hand from the [timing rules](timing_model.md#timing-rules). Its `README.md` also has each test's counts for other settings of the [knobs](timing_model.md#knobs). |
| `kernels/` | 6 | Larger hand-scheduled programs: dot product, vector addition, SAXPY, reduction, and matrix products on one and four threads. |
| `c_programs/` | 11 | Programs compiled from C with the [C compiler](compiler.md): the language's features, sorting, a prime sieve, and linear algebra. |
| `deviations/` | 8 | Behavior where the model departs, on purpose, from the engine's reference model (see [Deviations and Findings](deviations.md)). |

Each folder has a `README.md` describing its tests.

### A test

A test is a source file and a `.vprj` file of the same name, in the
same spirit as the SPARC tests (see [Validation
Suite](../validation_suite.md)). The `.vprj` says how to run the program
and what to expect. For example, the timing test
`timing/t3_latency`:

```mcode
--8<-- "validation/apara/timing/t3_latency.mcode"
```

```text
--8<-- "validation/apara/timing/t3_latency.vprj"
```

The source's header explains where the expected count comes from. A
functional test sets registers and memory in `INIT`, and lists the
expected results in `RESULTS`. From `isa/control/control.vprj`:

```text
SOURCES = control.mcode

INIT =
r1 = 5
r3 = 0xbfc00000

RESULTS =
r1 = 0xffffffffffffffff
r2 = 0xf
```

The lines of `INIT` and `RESULTS`:

| Line | Meaning |
|---|---|
| `r3 = 0x10` | Thread 0's `$r3`. |
| `t1.r3 = 0x10` | Thread 1's `$r3`. |
| `m[0x80] = 0x0102030405060708` | The DMEM dword (8 bytes) at byte address 0x80. |
| `m[C+0x8] = 0x2f2` | In a C test: a dword of the global `C`. |
| `t1.pc = 0x9` | (`RESULTS` only) Where thread 1 stopped. |
| `error = 0x2000000` | (`RESULTS` only) Thread 0's ERROR register: 0x2000000 is a `$halt`. |

A value in `RESULTS` may be followed by a mask, which selects the bits
compared.

The other keys:

| Key | Meaning |
|---|---|
| `SOURCES = prog.mcode` | The program: mcode, C (`.c`, compiled first), or an object file (`.obj`). |
| `THREADS = 0x0 worker` | Start a thread at each of these IMEM addresses or labels. Default: one thread at 0x0. |
| `CYCLES = 12` | The exact cycle count on the timing model, with the default timing settings. |
| `MISPREDICTS = 2`, `BTB_PREDICTIONS = 3` | The exact branch predictor counts on the timing model. |
| `HAZARDS_UNLOCKED = 1` | The hazards the timing model must count when built without the interlock (see [Hazards](#hazards)). |
| `ASM_ERROR = written twice` | The program must not assemble, and the error message must contain this text. |
| `DEVIATION = <why>` | The test depends on one of the model's [deviations](deviations.md). |
| `MAX_CYCLES = 100000` | A larger limit, for a long test. |
| `APCC_FLAGS = -O0` | Options for the C compiler. |

### Running the tests

```bash
python3 validation/apara/run_tests.py                          # every suite, on the cpp_model
python3 validation/apara/run_tests.py --sitar                  # on the sitar_model, also checking the timing keys
python3 validation/apara/run_tests.py validation/apara/hazards --sitar   # one suite (or one .vprj)
```

The runner compiles or assembles each test, writes its files into
`validation/apara/build/<test>/`, runs it, and prints `PASS` or `FAIL`
for each, then a summary per suite:

```text
PASS  timing/t1_halt.vprj
...
  asm_errors     21/21 passed
  c_programs     11/11 passed
...
  timing         10/10 passed
OVERALL: 108 passed, 0 failed
```

The `apara` configuration runs only these suites: the SPARC suites need
a SPARC core (see [Validation Suite](../validation_suite.md#which-tests-run-on-which-configuration)).

### Adding a test

Write a source file and its `.vprj` in a suite's folder, and run the
suite. There is nothing to register: the runner finds every `.vprj`
file in the folders it is given. To find the expected values of a new
test, run it once with `--dump-results -` (see [Running a
program](#running-a-program)), and check every value by hand, or with an
independent calculation, before writing it down.

---

## Hazards

A **hazard** is a bundle reading a register before an older bundle of
the same thread has written its new value. The engine's pipeline
resolves every such read-after-write dependence in hardware: DECODE
tells REGFILE which registers a bundle reads and writes, and REGFILE
holds a bundle until every register it reads or writes has been written
back by the older bundles (see [Register locks and
tokens](timing_model.md#register-locks-and-tokens)). A program, or a
compiler, never needs to insert waits.

The other orderings are safe too:

- **Write after write**: the same locks hold a bundle that writes a
  register an older bundle has yet to write, so the newer value always
  lands last.
- **Write after read**: a bundle reads its registers when it is issued,
  in order, so a later bundle's write can never reach it.
- **Memory**: a thread's loads and stores reach DMEM in program order.
- **Other threads**: each thread has its own registers.

What the hardware does not resolve is within a single bundle: two
instructions writing the same register (directly, or through a
multi-register load, a cast's second register, or an increment). Every
instruction of a bundle reads the registers as they were before the
bundle, so a value written in a bundle cannot be read in the same
bundle. The assembler rejects a register written twice (the
`asm_errors/` tests).

The timing model checks the interlock on every run, in two ways, and
`--stats` reports both:

- **The lock masks.** The registers each bundle actually reads and
  writes when it executes must be among those DECODE locked for it.
  Otherwise the model prints an internal error, since the interlock
  would have missed a dependence, and counts a lock-mask violation
  (`lock-mask violations 0` otherwise). The test runner fails a test
  with any.
- **A hazard count**, kept apart from the locks: a bundle issued while a
  register it reads still has an older write outstanding. With the
  interlock it must be 0 (`RAW hazards 0`).

The `hazards/` tests check that the interlock is needed where it acts.
Built with the knob `engine.regfile.interlock = false` (in
`model/system_models/apara/sitar_model/src/Top.sitar`, see
[Knobs](timing_model.md#knobs)), REGFILE ignores its locks, and each
`hazards/` test must report exactly its `HAZARDS_UNLOCKED` count: the
reads that would get a stale value without the interlock. The tests of
independent bundles, write-after-write, and memory order must report
none. Run them that way with `--sitar`: the runner then checks only the
hazard counts, since the timing is no longer the engine's. Set the knob
back to `true`, and rebuild, afterwards.

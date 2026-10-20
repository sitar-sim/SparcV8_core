# APARA Validation Suite

The APARA engine has two sets of tests. The **engine suites** test the
engine on its own, in the `apara` configuration. The **system suites**
test a SPARC program using the engine, in the `sparc_apara`
configuration. This page describes what each set contains, how to run
it on both models, and how to add a test. The general format of the
SPARC tests, and the runner `validation/run_tests.py`, are described in
[Validation Suite](../validation_suite.md).

| Set | Folder | Configuration | Runner | Tests |
|---|---|---|---|---|
| Engine suites | `validation/apara/` | `apara` | `validation/apara/run_tests.py` | 108 |
| System suites | `validation/sparc_apara/` | `sparc_apara` | `validation/run_tests.py --config sparc_apara` | 26 |

The commands on this page use `$SPARC_HOME`, the repository's folder,
as set in step 2 of [Installation](../installation.md).

---

## Before running the tests

Each runner runs the plain build of its configuration's models. The
following commands build the C++ model and the Sitar model of both
configurations:

```sh
cd $SPARC_HOME/model/system_models/apara/cpp_model
./build.sh
cd $SPARC_HOME/model/system_models/apara/sitar_model
./build.sh
cd $SPARC_HOME/model/system_models/sparc_apara/cpp_model
./build.sh
cd $SPARC_HOME/model/system_models/sparc_apara/sitar_model
./build.sh
```

The Sitar models need Sitar (step 3 of Installation). The executables of
`apara` are `executable/apara_sim_cpp` and `executable/apara_sim_sitar`,
and those of `sparc_apara` are `executable/sparc_sim_cpp_sparc_apara`
and `executable/sparc_sim_sitar_sparc_apara`.

No cross-toolchain is needed to run the tests. The engine suites are
assembled by the runner itself, with the engine's assembler, which is a
Python program. The system suites' memory images are already built and
committed. The cross-toolchain is needed only to rebuild a system test
after a change to its sources (see [Rebuilding the memory
images](#rebuilding-the-memory-images)).

---

## The engine suites (validation/apara)

### What they contain

`validation/apara/` holds the engine's own test suites, one folder each:

| Folder | Tests | What they check |
|---|---|---|
| `isa/` | 29 | Every instruction, in one subfolder per class (`alu_int`, `alu_float`, `vector`, `cast`, `bits`, `cmov`, `memory`, `control`). The tests cover each operation on each type, edge values (wraparound, sign extension, rounding), immediates and increments at their limits, and every exception. |
| `sequences/` | 7 | Instructions working together. Examples are full 8-slot bundles, loops, a recurrence in one bundle per step, a block copy with auto-increments, threads sharing DMEM, and one thread's fault not stopping the others. |
| `hazards/` | 10 | The pipeline's handling of dependences between bundles (see [Hazards](running.md#hazards)). |
| `predictor/` | 6 | The branch predictor, with loops, nested loops, two branches sharing a predictor entry, and calls and returns. Each test's mispredict count is derived from the [predictor's rules](timing_model.md#branch-prediction). |
| `asm_errors/` | 21 | Programs the assembler must reject. Examples are a register written twice in a bundle (also through multi-register writes and increments), too many control transfers, divides or memory operations in a bundle, values out of range, and invalid types. |
| `timing/` | 10 | Microbenchmarks with exact cycle counts, derived by hand from the [timing rules](timing_model.md#timing-rules). Its `README.md` also has each test's counts for other settings of the [knobs](timing_model.md#knobs). |
| `kernels/` | 6 | Larger hand-scheduled programs. These are a dot product, a vector addition, SAXPY, a reduction, and matrix products on one and four threads. |
| `c_programs/` | 11 | Programs compiled from C with the [C compiler](compiler.md). They cover the language's features, sorting, a prime sieve, and linear algebra. |
| `deviations/` | 8 | Behavior where the model departs, on purpose, from the engine's reference model (see [Deviations and Findings](deviations.md)). |

Each folder has a `README.md` describing its tests. A good way to learn
the instruction set is to read the tests of `isa/` next to the
[Instruction Set](isa.md), and then the programs of `kernels/`.

### A test

A test is a source file and a `.vprj` file of the same name. The
`.vprj` says how to run the program and what to expect, in the same
spirit as the SPARC tests. For example, the timing test
`timing/t3_latency` is the following program:

```mcode
--8<-- "validation/apara/timing/t3_latency.mcode"
```

Its `.vprj` gives the exact cycle count that the timing model must
reach:

```text
--8<-- "validation/apara/timing/t3_latency.vprj"
```

The source's header explains where the expected count comes from. A
functional test sets registers and memory in `INIT`, and lists the
expected results in `RESULTS`. The following lines are from
`isa/control/control.vprj`:

```text
SOURCES = control.mcode

INIT =
r1 = 5
r3 = 0xbfc00000

RESULTS =
r1 = 0xffffffffffffffff
r2 = 0xf
```

The lines of `INIT` and `RESULTS` have the following forms:

| Line | Meaning |
|---|---|
| `r3 = 0x10` | Thread 0's `$r3`. |
| `t1.r3 = 0x10` | Thread 1's `$r3`. |
| `m[0x80] = 0x0102030405060708` | The DMEM dword (8 bytes) at byte address 0x80. |
| `m[C+0x8] = 0x2f2` | In a C test, a dword of the global `C`. |
| `t1.pc = 0x9` | (`RESULTS` only) Where thread 1 stopped. |
| `error = 0x2000000` | (`RESULTS` only) Thread 0's ERROR register. The value 0x2000000 is a `$halt`. |

A value in `RESULTS` may be followed by a mask, which selects the bits
that are compared.

The other keys are the following:

| Key | Meaning |
|---|---|
| `SOURCES = prog.mcode` | The program. It may be mcode, C (`.c`, compiled first), or an object file (`.obj`). |
| `THREADS = 0x0 worker` | Start a thread at each of these IMEM addresses or labels. The default is one thread at 0x0. |
| `CYCLES = 12` | The exact cycle count on the timing model, with the default timing settings. |
| `MISPREDICTS = 2`, `BTB_PREDICTIONS = 3` | The exact branch predictor counts on the timing model. |
| `HAZARDS_UNLOCKED = 1` | The hazards that the timing model must count when built without the interlock (see [Hazards](running.md#hazards)). |
| `ASM_ERROR = written twice` | The program must not assemble, and the error message must contain this text. |
| `DEVIATION = <why>` | The test depends on one of the model's [deviations](deviations.md). |
| `MAX_CYCLES = 100000` | A larger limit, for a long test. |
| `APCC_FLAGS = -O0` | Options for the C compiler. |

### Running the tests

The engine suites have their own runner, `validation/apara/run_tests.py`.
The following commands run every suite, first on the C++ model and then
on the Sitar model:

```sh
cd $SPARC_HOME
python3 validation/apara/run_tests.py
python3 validation/apara/run_tests.py --sitar
```

For each test, the runner assembles or compiles the program, writes its
files into `validation/apara/build/<test>/`, runs it, and prints `PASS`
or `FAIL`. It then prints a summary for each suite:

```text
PASS  timing/t1_halt.vprj
...
  asm_errors     21/21 passed
  c_programs     11/11 passed
  deviations     8/8 passed
  hazards        10/10 passed
  isa            29/29 passed
  kernels        6/6 passed
  predictor      6/6 passed
  sequences      7/7 passed
  timing         10/10 passed
OVERALL: 108 passed, 0 failed
```

With `--sitar`, the runner also checks the timing keys `CYCLES`,
`MISPREDICTS`, `BTB_PREDICTIONS` and `HAZARDS_UNLOCKED`. The runner can
also be given one suite, or one `.vprj`:

```sh
cd $SPARC_HOME
python3 validation/apara/run_tests.py validation/apara/hazards --sitar
python3 validation/apara/run_tests.py validation/apara/timing/t3_latency.vprj --sitar
```

A failing test can be run again by hand, with the files the runner left
in `validation/apara/build/<test>/`, and the options of [Running a
program](running.md#running-a-program), such as `--trace`.

### Adding a test

To add a test, write a source file and its `.vprj` in a suite's folder,
and run the suite. Nothing needs to be registered, because the runner
finds every `.vprj` file in the folders it is given. To find the
expected values of a new test, run it once with `--dump-results -` (see
[Running a program](running.md#running-a-program)). Then check every
value by hand, or with an independent calculation, before writing it
down.

---

## The system suites (validation/sparc_apara)

### What they contain

`validation/sparc_apara/` holds the tests of the SPARC using the engine.
Each test is a bare-metal SPARC C program, with one or more engine
programs. The tests are grouped in five folders:

| Folder | Tests | What they check |
|---|---|---|
| `basic/` | 8 | Each part of the engine's interface on its own. The tests cover IMEM and registers, running and polling, the completion interrupt, exceptions, four threads, the engine's own main-memory accesses, DMA and its interrupt, and a whole offload by DMA (`dma_dot_product`). |
| `setup/` | 5 | Bringing the engine up, with one thread. The tests cover its state at power-up, loading and reading back its memories, complete offloads of a program compiled from C (by polling and by interrupt), and loading a second program over the first. |
| `threads/` | 5 | The same program on 1, 2, 3 and 4 threads, each on its own slice of the data, and threads started and restarted at different times. |
| `interference/` | 5 | Whether threads, the SPARC and the DMA unit disturb one another (see [What may happen while threads run](system_programming.md#what-may-happen-while-threads-run)), and the one real interference, a race on shared data. |
| `linalg/` | 3 | Linear algebra offloaded to the engine. The tests are an 8x8 matrix product on four threads, SAXPY in floating point, and a four-thread dot product compiled from C. |

Each folder has a `README.md` describing its tests, and
`validation/sparc_apara/README.md` summarizes the protocol of
[Setting up and running the
engine](system_programming.md#setting-up-and-running-the-engine). The
tests also serve as worked examples for new programs, as listed in
[Going further](system_programming.md#going-further).

### A test

A system test is a folder with a SPARC C program, its engine programs,
and a `.vprj` file. The folder `basic/dma_dot_product/` holds the
following sources:

| File | What |
|---|---|
| `dma_dot_product.c` | The SPARC program. |
| `kernel.mcode` | The engine program. |
| `dma_dot_product.vprj` | How to build the test, and what to expect. |

Its `.vprj` names the SPARC program, its engine program, and the
expected registers:

```text
--8<-- "validation/sparc_apara/basic/dma_dot_product/dma_dot_product.vprj"
```

The line `MCODE = kernel.mcode` names an engine program. The build
script writes its C header, `kernel.mcode.h`, before it compiles the
SPARC program. A test may have several `MCODE` lines, and an engine
program may also be written in C (`MCODE = kernel.c`). The line
`STARTUP = crt0_interrupts.s` links the interrupt startup code, for a
test that takes the engine's interrupt. The other files in the folder,
such as `dma_dot_product.hex` and `kernel.mcode.h`, are written by the
build, and are committed so that the tests run without a
cross-toolchain.

Every test reports in the same way as the device tests. `%o0` is 1 if
every check passed, and `%o1` has one bit per check. The checks are
listed in the header comment of the test's C file. The SPARC program
computes the expected results itself.

The tests share some helpers, in `validation/sparc_apara/apara_common.h`:

| Helper | Does |
|---|---|
| `report_and_halt(ok, n)` | Writes 1 to `%o0` if all `n` checks passed, and 0 otherwise, writes `ok` to `%o1`, and halts. |
| `physical_word(p)` | Reads a word of main memory with an MMU-bypass load, past the data cache, for data that the engine has written there. |
| `dword_equals(o, v)` | Whether the 64-bit word at DMEM offset `o` equals the 32-bit value `v`, sign-extended. |
| `next_random(&state)` | The next number of a fixed pseudo-random sequence, for test data. |
| `enable_fpu()` | Turns on the SPARC's FPU, which the startup code leaves off. |
| `HALTED` | The completion word of a thread that ended with `$halt`. |

### Running the tests

The system suites run with the general runner, on `--config sparc_apara`.
The Sitar model needs a larger cycle limit than the default:

```sh
cd $SPARC_HOME
python3 validation/run_tests.py validation/sparc_apara --config sparc_apara
python3 validation/run_tests.py validation/sparc_apara --config sparc_apara --sitar --max-cycles 50000000
```

```
[PASS] validation/sparc_apara/basic/dma_dot_product/dma_dot_product.vprj
...
[PASS] validation/sparc_apara/threads/threads_4/threads_4.vprj

26/26 tests passed
```

One folder, or one test's folder, can be given instead:

```sh
cd $SPARC_HOME
python3 validation/run_tests.py validation/sparc_apara/basic --config sparc_apara
python3 validation/run_tests.py validation/sparc_apara/basic/dma_dot_product --config sparc_apara
```

A test's memory image can also be run by hand, as in [An example:
offloading a dot product](system_programming.md#an-example-offloading-a-dot-product).

### Rebuilding the memory images

*This section needs the cross-toolchain (step 4 of Installation).*

After a change to a test's C program or engine program, the following
command rebuilds the memory images of a folder of tests. It writes the
engine programs' headers, then compiles each SPARC program:

```sh
cd $SPARC_HOME
python3 validation/build_hex.py validation/sparc_apara
```

The runner then runs the new images. Rebuilt `.hex` files should be
committed together with the changed sources.

### Adding a test

To add a test, make a new folder in one of the five folders, with the
SPARC program, its engine programs, and a `.vprj` that names them. Then
build it and run it:

```sh
cd $SPARC_HOME
python3 validation/build_hex.py validation/sparc_apara/basic/my_test
python3 validation/run_tests.py validation/sparc_apara/basic/my_test --config sparc_apara
```

[Writing a new program](system_programming.md#writing-a-new-program)
builds such a test step by step. The file `validation/sparc_apara/REQUIRES`
names the components that these tests need, which are the SPARC core,
the devices and the engine. The runner therefore runs a new test in
`validation/sparc_apara/` only on the `sparc_apara` configuration (see
[Which tests run on which
configuration](../validation_suite.md#which-tests-run-on-which-configuration)).

---

## The whole suite on sparc_apara

The `sparc_apara` configuration also runs the general SPARC tests of
`validation/`, because its SPARC core is the one of
`core_l1cache_mmu_devices`. The following command runs every test that
the configuration can run, on the C++ model:

```sh
cd $SPARC_HOME
python3 validation/run_tests.py validation --config sparc_apara
```

```
skipped 108 test(s) under validation/apara: sparc_apara has no apara_standalone
291/291 tests passed (108 skipped)
```

The 291 tests are the SPARC tests and the 26 system tests. The runner
skips the 108 engine tests of `validation/apara/`, which only their own
runner runs.

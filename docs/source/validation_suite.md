# Validation Suite

Validating a processor model can mean different things: functional
(does each instruction do the right thing), timing or microarchitectural
(does it take the right number of cycles, in the right order), or both.
This project's SPARC suite, in `validation/asm/` and `validation/C/`, is
purely **functional**. There are no SPARC timing tests here. Both models drive the exact same `SparcCore` (see
[Models](index.md#models)), so this one suite validates both, and
catches a regression in either.

It checks the core's instruction-level behavior against the SPARC V8
manual, in two ways:

- **`validation/asm/`**, hand-written assembly, each test targeting one
  instruction (or a small family of closely related ones) in isolation.
- **`validation/C/`**, compiled from freestanding C, each test a small
  self-validating program (a sort, an FFT, a checksum) exercising many
  instructions together the way a real program would.

It consists of two things: the tests themselves (see "What's in a test"
below), and a script, `validation/run_tests.py`, that runs them all and
prints a pass/fail summary (see "The validation script" below).

Beside the SPARC suite, further suites test the components of the
larger configurations: the MMU, the peripheral devices, the caches, and
the APARA engine, both on its own (with timing tests too) and driven by
a SPARC program. Each suite runs only on the configurations that have
its components (see [Which tests run on which
configuration](#which-tests-run-on-which-configuration)).

This page covers how a test is put together, how to run the suite, and
how to add a new one. For actually *writing* a test program (the trap
table, the pass-fail convention, structuring a self-validating C test),
see [Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
and [Writing and Running C Programs](writing_and_running_c_programs.md).

---

## What's in a test

Every test is a matched set of files sharing one name, for example
`ADD.s`, `ADD.hex`, `ADD.objdump`, `ADD.vprj`, and `ADD.expected`
(`validation/asm/integer_alu/Arithmetic/Add/`). Only two of these are
written by hand:

- **`<name>.s` or `<name>.c`**, the source program.
- **`<name>.vprj`**, its expected final state, in the human-friendly
  format described below.

The rest are derived automatically, not hand-written (though `.hex` and
`.objdump` are still committed as build artifacts, see "The validation
script" below for why):

- **`<name>.hex`**, the memory image compiled from the source, loadable
  directly by either model.
- **`<name>.objdump`**, its disassembly plus full symbol table, useful
  for finding an address to give gdb, see
  [Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md#finding-addresses).
- **`<name>.expected`**, the `.vprj`'s checks rewritten into the plain
  format the checker executables themselves take as a direct
  command-line argument, see
  [Getting Started](getting_started.md#running-the-simulator).

In short, `.vprj` is what you write, once, by hand. `.expected` is what
`run_tests.py` generates from it, fresh, every time the test runs. It's
never edited directly, and doesn't need to be committed to git.

### The `.vprj` expected-results format

```
SOURCES = ADD.s

RESULTS =
g1=0x00000080
o0=0x00000005
o2=0xFFFFFFFB
```

- `SOURCES` names the paired `.s`/`.c` file.
- Each `RESULTS` line is either a register check (`<name>=<hex value>`,
  register mnemonics `g1`-`g7`, `o0`-`o7`, `l0`-`l7`, `i0`-`i7`,
  `f0`-`f31`, `psr`, `fpsr`, `y`, `wim`, `tbr`, `pc`, `npc`,
  `asr0`-`asr31`) or a memory check (`m[<hex addr>]=<hex value>`, a
  word-aligned 32-bit read).
- Either kind of line accepts an optional trailing mask
  (`m[0x148] = 0x00000021 0x00000021` checks only the bits set in the
  mask. See `validation/asm/floating_point/fp_exceptions/accrued_inexact.s`
  for a real example distinguishing individual FSR bits.)
- `asi = ...` lines are recognized and ignored.
  `MemCore` is a single flat address space with no ASI distinction.

Before running a test, `run_tests.py` parses this and normalizes it into
the plain `REG <name> <hex value> [mask]` / `MEM <addr> <hex value>
[mask]` format, writing it to a `.expected` file alongside the test.

Four optional lines, used by the device and APARA tests:

- `STARTUP = crt0_interrupts.s`, before `RESULTS`, links that startup
  file instead of `compiler/crt0.s` (C tests only).
- `MCODE = kernel.mcode`, before `RESULTS`, names an APARA engine
  program the test carries, in mcode or in C (`MCODE = kernel.c`).
  Before compiling, `build_hex.py` assembles or compiles it, and writes
  it out as a C header, `kernel.mcode.h` (or `kernel.c.h`), for the test
  to `#include` (C tests only, may be repeated). See [The Engine in a
  System](apara/system.md#carrying-the-engines-program).
- `MAX_CYCLES = 1000000`, before `RESULTS`, raises the cycle limit for
  a test that legitimately runs long (the runner uses the larger of this
  and its `--max-cycles`).
- `serial_out = "text"`, among the results, checks the exact bytes the
  program sent out through the Serial device (C-style escapes such as
  `\n` and `\x41` work). Only configurations with devices check it.

A test's received serial input, if it needs any, is a file named after
the test with the extension `.serial_in`, next to its `.hex`.

---

## The validation script

A two-phase pipeline, so the existing suite can be run without a
cross-compiler installed at all.

```sh
# phase 1 (needs the sparc-elf toolchain): assembles/compiles .s or .c
# into .hex, only needed when you add or edit a test's source
validation/build_hex.py validation

# phase 2: runs the already-built .hex against a model
validation/run_tests.py validation
```

```
[PASS] validation/asm/misc/save_restore/SAVE.vprj
[PASS] validation/asm/misc/stbar_unimp_nop_sethi/STBAR_UNIMP_NOP_SETHI.vprj

<passed>/<total> tests passed
```

Since `.hex` files are committed to git, phase 2 alone is enough to run
the existing suite. Phase 1 is only needed after adding or editing a
`.s`/`.c` source, and also (re)generates that test's `.objdump`.

You can point `run_tests.py` at any subset too, not just the
`validation` root:

```sh
validation/run_tests.py validation/asm/floating_point
validation/run_tests.py validation/C
```

It recurses to find `.vprj` files, so nesting is free. Tests the
configuration cannot run are skipped, and listed at the end (see [Which
tests run on which
configuration](#which-tests-run-on-which-configuration)).

### Options

| Option | Does |
|---|---|
| `--config NAME` | Which `system_models` configuration to run against, default `core_only`. E.g. `--config core_mmu` runs against `model/system_models/core_mmu/`'s own executables instead, and runs only the tests `core_mmu` can run. |
| `--sitar` | Run against the chosen configuration's Sitar-timed model instead of its plain C++ model (the default). Same CLI, same `.vprj` format, same PASS/FAIL/OVERALL output either way. See [Installation](installation.md) step 3 to build it. |
| `--max-cycles N` | Per-test cycle limit, default 200,000. A test that hasn't halted by then is reported as a failure, rather than hanging forever on a genuine bug. A "cycle" means one complete instruction executed against the plain C++ model, and an actual clock cycle against the Sitar-timed model, see [Getting Started](getting_started.md#building-the-sparc-models). |
| `-v` | Show every check's result, not just failures. |

```sh
validation/run_tests.py validation --config core_mmu --sitar -v
validation/run_tests.py validation/asm/control_transfer --max-cycles 50000
```

`validation/clean.sh [folder]` removes generated build byproducts (`.o`,
`.elf`, `.expected`) without touching `.hex`/`.s`/`.c`/`.vprj`/`.objdump`.

---

## Which tests run on which configuration

Not every test can run on every configuration: the MMU tests need an
MMU, the APARA tests an engine. Two small files decide which tests a
configuration runs, so that you can always point `run_tests.py` at the
whole of `validation/`:

- **`COMPONENTS`**, in each configuration's folder
  (`model/system_models/<config>/COMPONENTS`), lists what the
  configuration contains.
- **`REQUIRES`**, in a suite's folder, lists what its tests need.
  Requirements add up down the tree: a test needs everything its own
  folder's and every parent folder's `REQUIRES` file lists.

`run_tests.py --config <config>` runs the tests whose requirements the
configuration has, and lists the folders it skipped, with the reason:

```text
skipped 4 test(s) under validation/C/caches: core_only has no caches
skipped 8 test(s) under validation/C/devices: core_only has no devices
skipped 12 test(s) under validation/C/mmu: core_only has no mmu
skipped 108 test(s) under validation/apara: core_only has no apara_standalone
skipped 26 test(s) under validation/sparc_apara: core_only has no apara, devices

241/241 tests passed (158 skipped)
```

The components, and which configuration has which:

| Configuration | `COMPONENTS` |
|---|---|
| `core_only` | `sparc` |
| `core_mmu` | `sparc mmu` |
| `core_mmu_devices` | `sparc mmu devices` |
| `core_l1cache_mmu_devices` | `sparc mmu devices caches` |
| `sparc_apara` | `sparc mmu devices caches apara` |
| `apara` | `apara_standalone` (the engine alone, no SPARC core) |

And the suites, with what they require, and where they run:

| Folder | `REQUIRES` | Runs on |
|---|---|---|
| `asm/`, `C/` (the benchmarks), `test_simple_ADD/` | `sparc` | every SPARC configuration |
| `C/mmu/` | `sparc mmu` | `core_mmu` and later |
| `C/devices/` | `sparc devices` | `core_mmu_devices` and later |
| `C/caches/` | `sparc caches` | `core_l1cache_mmu_devices`, `sparc_apara` |
| `sparc_apara/` | `sparc devices apara` | `sparc_apara` |
| `apara/` | `apara_standalone` | `apara`, with its own runner, `validation/apara/run_tests.py` |

The engine's own suites, in `apara/`, are engine programs rather than
SPARC programs, so they have their own format and runner (see [Writing
and Running APARA Programs](apara/running.md#tests)). `run_tests.py
--config apara` says so, and stops.

A new configuration needs only its `COMPONENTS` file to work with every
existing suite. A new suite that needs more than the SPARC core gets a
`REQUIRES` file.

---

## The test collection

The SPARC suite has two sub-suites, side by side under `validation/`,
both using the same `.vprj` format and the same two-phase pipeline
above. The component suites follow in the next section.

- **`asm/`**  
    Hand-written assembly tests, each targeting one instruction (or a
    small family of closely related ones, such as every branch
    condition) in isolation: integer ALU ops, control transfer
    (branches, traps, call, jump, `rett`), loads and stores (including
    atomic and coprocessor variants), and floating point. Organized into
    category subfolders: `integer_alu/`, `floating_point/`,
    `control_transfer/`, `data_transfer/`, `misc/`. `compiler/assemble.sh`
    builds a test's `.s` into `.hex`/`.objdump`, called automatically by
    `build_hex.py` above.
- **`C/`**  
    Self-validating bare-metal C mini-benchmarks, each compiled program
    exercising a sequence of C-level operations together (loops, arrays,
    structs, global variables) the way a real program would, rather than
    one instruction in isolation. `compiler/compile_c.sh` builds a test's
    `.c` the same way. Every test here follows the same shape: compute
    something, compare it against a golden value computed once on the
    host machine and hardcoded right there in the source, and report
    pass (`1`) or fail (`0`) in `%o0`.
    Its `.vprj` then only ever has to check `o0=1`, instead of
    re-embedding the golden value a second time. See
    [Writing and Running C Programs](writing_and_running_c_programs.md#structuring-a-test-program)
    for the full convention, and `array_sum/array_sum.c` for a worked
    example.

    | Test | What it computes |
    |---|---|
    | `array_sum` | Sum of a small int array |
    | `matrix_mul` | 3x3 integer matrix multiply |
    | `fft` | 4-point integer radix-2 FFT |
    | `root_finding` | Integer square root via Newton-Raphson |
    | `integer_sort` | Bubble sort |
    | `gcd` | Euclidean algorithm |
    | `fibonacci` | Iterative Fibonacci |
    | `prime_sieve` | Sieve of Eratosthenes |
    | `checksum` | Byte-array checksum |
    | `dot_product` | Integer vector dot product |

Alongside them sits `test_simple_ADD/`, one more `.vprj` test, but its
main job is as the small worked example used throughout the docs (every
configuration's `run_simple_test.sh` reads the files here directly, and
`log_viewer/` symlinks to the reference trace produced here, rather than
keeping their own copies), see `validation/README.md`.

---

## Adding an asm test

1. Pick an existing category folder under `validation/asm/`
   (`integer_alu/`, `floating_point/`, `control_transfer/`,
   `data_transfer/`, `misc/`), or add a new subfolder for a new, focused
   group of tests.
2. Write `<name>.s`. See
   [Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
   for the full format: the required setup, the trap table, and the
   pass-fail convention every test shares.
3. Build and run it directly first, to find the actual final register
   values, see
   [Assembling to generate a memory image](writing_and_running_assembly_programs.md#assembling-to-generate-a-memory-image-hex)
   (`compiler/assemble.sh <name>.s`, then
   `model/system_models/core_only/cpp_model/executable/sparc_sim_cpp_core_only
   <name>.hex` with no expected-results argument, prints the final state).
4. Write `<name>.vprj`, naming `<name>.s` as its `SOURCES` and listing
   the register (and, if needed, memory) values from step 3 that you
   want checked, see the format above.
5. Run `validation/build_hex.py <folder>` to (re)generate `<name>.hex`
   and `<name>.objdump` through the suite's own tooling (`build_hex.py`
   finds a folder's `.vprj` files and reads `SOURCES` to know what to
   build, so this step needs the `.vprj` to already exist, from step 4).
6. Run `validation/run_tests.py <folder>` to check it passes.

No registration step anywhere else, `run_tests.py` and `build_hex.py`
both recurse automatically.

---

## Adding a C test

1. Add a new folder under `validation/C/`, one per test.
2. Write `<name>.c`, freestanding (no libc, see
   [Writing and Running C Programs](writing_and_running_c_programs.md)),
   following the same self-validating shape as the existing benchmarks:
   compute something, compare it against a golden value computed on the
   host, and report pass (`1`) or fail (`0`) in `%o0`.
3. Write `<name>.vprj`, naming `<name>.c` as its `SOURCES`. Since the
   test already computed its own pass/fail, its `RESULTS` is almost
   always just `o0=1`.
4. Run `validation/build_hex.py <folder>` to generate `<name>.hex` and
   `<name>.objdump` from it (picking `compiler/compile_c.sh`
   automatically, based on the `.c` extension). As with an asm test,
   this needs the `.vprj` to already exist, since `build_hex.py` reads
   its `SOURCES` line to know what to build.
5. Run `validation/run_tests.py <folder>` to check it passes.

---

## Component validation suites

The suite above is purely functional, and purely for the SPARC core
itself: every opcode, exercised in isolation or as part of a larger C
program. Alongside it, dedicated test suites validate individual
components, each living in its own folder:

- **`validation/C/mmu/`**  
    The MMU: register access, page-table walks, TLB hit/miss/fill,
    faults, probe and flush, bypass. See [Model
    Components](model_components.md#mmu).
- **`validation/C/devices/`**  
    The timer, interrupt controller (including interrupt delivery to a
    real trap handler, priority, masking, and IPIs), and serial device
    (output, polled and interrupt-driven input). Needs
    `core_mmu_devices`. See [Peripheral Devices](peripheral_devices.md).
    On the sitar_model these tests need more cycles than the default
    limit, so run them with `--max-cycles 5000000`.
- **`validation/C/caches/`**  
    The L1 caches: write-through, staleness until a flush (they are not
    coherent), device registers never cached, atomics on a cached line.
    Needs `core_l1cache_mmu_devices`. The whole suite above also runs
    through the caches on that configuration, and with every ordinary
    access cached if you set `SPARC_ALWAYS_CACHEABLE=1` in the
    environment.
- **`validation/sparc_apara/`**  
    An APARA engine driven from a SPARC program, in five suites:
    `basic/` (each part of the engine's interface), `setup/` (bringing
    the engine up, and complete offloads by polling and by interrupt),
    `threads/` (one to four engine threads), `interference/` (whether
    threads, the SPARC and the DMA unit disturb one another), and
    `linalg/` (linear algebra offloaded to the engine). Needs
    `sparc_apara`. On the sitar_model, run them with `--max-cycles
    50000000`. See [The Engine in a System](apara/system.md#tests).
- **`validation/apara/`**  
    The APARA engine on its own, with its own test format and runner,
    in nine suites: every instruction (`isa/`), sequences, hazards, the
    branch predictor, programs the assembler must reject, timing,
    hand-written kernels, programs compiled from C, and the model's
    deviations. Unlike the SPARC suite, it also checks timing: cycle
    and mispredict counts, derived by hand for the default timing
    settings, which the timing model must match exactly. See [Writing
    and Running APARA Programs](apara/running.md#tests).

For example, to run the MMU validation suite on `core_mmu`, build that
configuration first (see [Getting
Started](getting_started.md#building-the-sparc-models)):

```sh
model/system_models/core_mmu/cpp_model/build.sh
```

then run the suite against it:

```sh
validation/run_tests.py validation/C/mmu --config core_mmu
```

This same suite runs unmodified on any other configuration that also
includes an MMU, such as `core_mmu_devices`. Without `--config`, the
runner uses `core_only`, which has no MMU, and skips the whole suite.

---

## Credits: validation suite of the AJIT SPARC V8 processor

Most of `validation/asm/`'s tests, and the scripts that build and run
this suite, are adapted from the **AJIT processor project** (IIT
Bombay), specifically its `ajit32` instruction-level verification suite.
Many more tests have since been added as part of this project (the
quad-precision suite, the `validation/C/` benchmarks, and the MMU suite
above, none of which exist in AJIT's own tests). Tests adapted directly
from AJIT carry their original author credit inline, and are listed as
such in `validation/asm/README.md` and [Authors](authors.md). Tests
developed as part of this project are not AJIT-derived.

A handful of specific, well-understood divergences between this model's
behavior and AJIT's own reference results are documented, with
side-by-side expected-vs-actual data, in `docs/compliance/README.md`,
rather than silently patched or dropped. These are kept separate from
the maintained suite (`docs/compliance/`, not `validation/`), since they
represent understood implementation differences from AJIT's own
hardware, not bugs in this model.

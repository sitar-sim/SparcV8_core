# Validation Suite

Validating a processor model can mean different things: functional
(does each instruction do the right thing), timing or microarchitectural
(does it take the right number of cycles, in the right order), or both.
This project's suite, in `validation/`, is purely **functional**. There
are no timing tests here. Both models drive the exact same `SparcCore` (see
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
- `asi = ...` lines (an AJIT-format leftover) are recognized and ignored.
  `MemCore` is a single flat address space with no ASI distinction.

Before running a test, `run_tests.py` parses this and normalizes it into
the plain `REG <name> <hex value> [mask]` / `MEM <addr> <hex value>
[mask]` format, writing it to a `.expected` file alongside the test.

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

It recurses to find `.vprj` files, so nesting is free.

### Options

| Option | Does |
|---|---|
| `--sitar` | Run against the Sitar-timed model (`model/system_models/core_only/sitar_model/executable/sparc_sim_sitar_core_only`) instead of the plain C++ model (`model/system_models/core_only/cpp_model/executable/sparc_sim_cpp_core_only`, the default). Same CLI, same `.vprj` format, same PASS/FAIL/OVERALL output either way. See [Installation](installation.md) step 3 to build it. |
| `--max-cycles N` | Per-test cycle limit, default 10000. A test that hasn't halted by then is reported as a failure, rather than hanging forever on a genuine bug. A "cycle" means one complete instruction executed against the plain C++ model, and an actual clock cycle against the Sitar-timed model, see [Getting Started](getting_started.md#building-the-sparc-models). |
| `-v` | Show every check's result, not just failures. |

```sh
validation/run_tests.py validation --sitar -v
validation/run_tests.py validation/asm/control_transfer --max-cycles 50000
```

`validation/clean.sh [folder]` removes generated build byproducts (`.o`,
`.elf`, `.expected`) without touching `.hex`/`.s`/`.c`/`.vprj`/`.objdump`.

---

## The test collection

Two sub-suites, side by side under `validation/`, both using the same
`.vprj` format and the same two-phase pipeline above.

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

## Provenance

Most of `validation/asm/`'s tests, and the scripts that build and run
this suite, are adapted from the **AJIT processor project** (IIT
Bombay), specifically its `ajit32` instruction-level verification suite.
Individual test files carry their original author credit inline. See
[Authors](authors.md) for the full attribution, and
`validation/asm/README.md` for which tests were adapted as-is versus
written new for this project (the quad-precision suite, not present in
AJIT's own tests at all).

A handful of specific, well-understood divergences between this model's
behavior and AJIT's own reference results are documented, with
side-by-side expected-vs-actual data, in `docs/compliance/README.md`,
rather than silently patched or dropped. These are kept separate from
the maintained suite (`docs/compliance/`, not `validation/`), since they
represent understood implementation differences from AJIT's own
hardware, not bugs in this model.

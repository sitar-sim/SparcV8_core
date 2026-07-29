# Writing and Running Assembly Programs

In [Getting Started](getting_started.md), we discussed how you can view
and run an existing program provided in this repository on the C++/Sitar
models.
A variety of asm and C test programs are present in the `validation/`
folder. For each program, the test source (`.s` or `.c`), the generated
memory hex file, and the expected-results file are already included.

**This section deals with:**

1. writing your own asm programs,
2. assembling them to generate a memory image for the simulator,
3. running them on the simulator, and
4. the standard format for writing a test for inclusion in this project's validation framework.

This section assumes that you have built the models and the
toolchain release. See steps 2 and 5 in [Installation](installation.md).

Let's create a copy of the given simple asm program `test_simple_ADD`,
and modify it, for example, using `sub` instead of `add`.

```sh
mkdir temp_asm
cd temp_asm
cp ../validation/test_simple_ADD/test_simple_ADD.s test_simple_SUB.s
```

---

## Assembling to generate a memory image (.hex)

The conversion of asm/C programs to a memory image requires a cross-compiler toolchain, consisting of an assembler, utilities such as objdump/readelf, and also a compiler (for compiling C to asm).

If not already done in [Installation](installation.md) (step 5), run `compiler/install_toolchain.sh` to create a release.

The toolchain release lives at `compiler/toolchain/`. Add it to your PATH variable (on Linux systems) by sourcing `compiler/toolchain_env.sh`, so that its binaries and libraries can be accessed from any location:

```sh
source compiler/toolchain_env.sh
```

Next, this project provides scripts (`compiler/assemble.sh`, `compiler/compile_c.sh`) which are convenience wrappers around these toolchain executables.

To assemble a `.s` to `.hex`:

```sh
compiler/assemble.sh <file.s>
```

For example, from `temp_asm/`:

```sh
../compiler/assemble.sh test_simple_SUB.s
```

This also generates `test_simple_SUB.objdump`, its disassembly plus
full symbol table, useful for finding an address to give gdb, see
[Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md#finding-addresses).
See [Cross Compiler](cross_compiler.md) for more on what's in the
bundled toolchain.

---

## Running a test program

Rebuild the models with `--logging`, then run them on this test. From
the repo root:

```sh
model/cpp_model/build.sh --logging
model/cpp_model/sparc_sim_cpp temp_asm/test_simple_SUB.hex
```

This prints the final register state once the program halts, see
[Getting Started](getting_started.md#running-the-simulator) for the
full walkthrough, including the Sitar-timed model (which takes the
identical CLI) and observing the trace in the log viewer.

---

## Creating a test

A test is not just any program that runs on a model, but one that gives
a pass/fail indication after checking something. In this project, a
test consists of a source file and an expected-results file in a
specific format, see "Recommended format for a test program" below for
how the source file itself needs to be structured to make this
possible.

The simulator executables take the following arguments:

```
sparc_sim_cpp <hex_file> [expected_results_file] [max_cycles]
```

- **A hex file** (required): the memory image to run.
- **An expected-results file** (optional): if given, once the program
  halts, the final state is checked against it, and the executable
  prints a PASS/FAIL verdict per check plus an OVERALL result, instead
  of the detailed state.
- **A cycle limit** (optional): caps how long the simulator runs before
  giving up.

When no expected-results file is passed, as above, the executable just
prints the final register state. When one is passed, it's checked
directly instead.

Let's write an expected-results file for our test, and run with that.
`o0 = 5 - 7 = 0xfffffffe`, so `temp_asm/test_simple_SUB.expected`:

```
REG o0 0xfffffffe
```

Then run it:

```sh
model/cpp_model/sparc_sim_cpp temp_asm/test_simple_SUB.hex temp_asm/test_simple_SUB.expected
```

---

## Format for the expected-results file

`test_simple_SUB.expected` is a plain text file, one check per line:

- **`REG <name> <hex value> [mask]`** checks a register (mnemonics
  `g1`-`g7`, `o0`-`o7`, `l0`-`l7`, `i0`-`i7`, `f0`-`f31`, `psr`, `fpsr`,
  `y`, `wim`, `tbr`, `pc`, `npc`, `asr0`-`asr31`).
- **`MEM <hex addr> <hex value> [mask]`** checks a word-aligned 32-bit
  memory read.

Either kind accepts an optional trailing mask, to check only specific
bits.

---

## Recommended format for a test program

Because this model does not yet have any operating system, the test
program has to be self-sufficient. This means initializing the
processor state, setting up a trap table, then running the test part
and exiting while indicating pass/fail in some way to the simulator. In
the current scheme, the latter is achieved using `%g1` as a sentinel
register together with a deliberate final trap (`ta 0`), described in
full under "The pass-fail convention" below.

The following shows a typical structure of a test program:

```sparc
--8<-- "docs/source/examples/test_template/test_template.s"
```

Our own `test_simple_SUB` skips the trap table by simply disabling
traps entirely (`wr %g0, %psr`), the simplest thing that works when
nothing in the test could ever trap. Use the fuller structure above
instead for anything meant to join `validation/asm/`, where an
unexpected trap needs to be caught rather than silently forcing
`error_mode` for the wrong reason.

!!! note "Copy the trap table, don't retype it"
    The 256-entry trap table is always the same boilerplate. Copy it
    verbatim from any existing test under `validation/asm/`, then edit
    only the one slot you actually care about, see "The trap table"
    below.

### The pass-fail convention

Every test always halts the same way: a `ta 0` taken with traps disabled
(`ET=0`, cleared automatically on trap entry) forces the processor into
`error_mode` per the manual (Appendix C, Section C.8). This is what
`PROCESSOR STATE: ERROR` in `sparc_sim_cpp`'s output means, and it's
expected, not a bug.

`%g1` distinguishes a clean run from an unexpected trap:

- If the test's own final `ta 0` (step 5 above) is what triggers this,
  its trap-table slot (`SW_trap_0x80`) sets `%g1 = 0x80`. **This is
  success: nothing unexpected happened.**
- If *any other* trap occurs first (a bug, a mistake in the test, or a
  trap you're deliberately testing for), it's caught by *that* trap's own
  table slot, which records the trap number into `%g1` before re-trapping
  the same way. So `%g1`'s final value tells you exactly what happened,
  whether the test passed or not.

### The trap table

Each slot is a fixed 4 instructions: `mov <tt>, %g1; restore; ta 0;
nop`. To make a test verify a *specific* trap actually fires (rather
than just detecting an unexpected one), replace that one slot with
custom code. For example,
`validation/asm/floating_point/fp_exceptions/overflow.s` replaces its
`HW_trap_0x08` slot with `inc %g2; rett %r18; nop; nop`, which increments
a counter and *resumes* execution right after the trapping instruction
(via `rett`), instead of halting. This lets the test both confirm the
trap fired (`%g2`) and continue on to a normal exit (`%g1 = 0x80`).

---

## Adding it to the validation suite

Hand-writing a `.expected` file and running it yourself works for one
test at a time. To run your test alongside the rest of the suite
automatically instead, and have it re-checked every time the model
changes, the recommended practice is to wrap it as a `.vprj` file for use with the validation script.
See [Validation Suite: Adding an asm test](validation_suite.md#adding-an-asm-test) for details.

---

See `validation/asm/README.md` for the AJIT-adaptation attribution and
`docs/compliance/README.md` for documented, specific divergences from AJIT's
own reference results (kept separate from the maintained suite since they
represent understood implementation differences, not bugs).

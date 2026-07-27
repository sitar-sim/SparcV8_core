# Validation Suite

`validation/` holds this project's functional validation suite: 240
tests that check the core's instruction-level behavior against the SPARC
V8 manual. There are no timing tests here. Both models drive the exact
same `SparcCore` (see [Models](index.md#models)), so this one suite
validates both, and catches a regression in either.

This page covers how the suite itself is put together, how to run it,
and where a new test goes. For how to actually *write* a new test, see
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
and [Writing and Running C Programs](writing_and_running_c_programs.md).

---

## How it's organized

Every test is a pair of files: `<name>.s` or `<name>.c` (the program)
and `<name>.vprj` (its expected final state). There are two sub-suites,
side by side under `validation/`.

- **`asm/`**  
    230 hand-written assembly tests, one small instruction sequence per
    test, checking opcodes one at a time: integer ALU ops, control
    transfer (branches, traps, call, jump, `rett`), loads and stores
    (including atomic and coprocessor variants), and floating point.
    Organized into category subfolders: `integer_alu/`,
    `floating_point/`, `control_transfer/`, `data_transfer/`, `misc/`.
- **`C/`**  
    10 self-validating bare-metal C mini-benchmarks, each exercising a
    sequence of C-level operations together (loops, arrays, structs,
    global variables) rather than one instruction at a time. See
    "Self-validating C tests" below.

Both sub-suites use the same `.vprj` format and the same two-phase
build/run pipeline, described below.

---

## The `.vprj` expected-results format

```
SOURCES = ADD.s

RESULTS =
g1=0x00000080
o0=0x00000005
o2=0xFFFFFFFB
```

`SOURCES` names the paired `.s`/`.c` file. Each `RESULTS` line is either
a register check (`<name>=<hex value>`) or a memory check
(`m[<hex addr>]=<hex value>`, a word-aligned 32-bit read), either kind
optionally followed by a trailing mask to check only specific bits. See
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md#the-vprj-expected-results-file)
for the full field reference.

---

## Self-validating C tests

Every test in `validation/C/` follows the same shape: compute something,
compare it against a golden value computed once on the host machine and
hardcoded right there in the source, and report pass (`1`) or fail (`0`)
in `%o0`. Its `.vprj` then only ever has to check `o0=1`, instead of
re-embedding the golden value a second time. See
[Writing and Running C Programs](writing_and_running_c_programs.md#structuring-a-test-program)
for the full convention, and `array_sum/array_sum.c` for a worked
example.

The ten benchmarks:

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

---

## Running the suite

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

240/240 tests passed
```

`.hex` files are committed to git, so phase 2 alone is enough to run the
existing suite. Phase 1 is only needed after adding or editing a `.s`/`.c`
source, and also (re)generates that test's `.objdump`, useful for
finding addresses, see
[Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md#finding-addresses).

`run_tests.py` takes a folder, not just the `validation` root, so you can
point it at any subset:

```sh
validation/run_tests.py validation/asm/floating_point
validation/run_tests.py validation/C
```

It recurses to find `.vprj` files, so nesting is free.

### Options

| Option | Does |
|---|---|
| `--sitar` | Run against the Sitar-timed model (`model/sitar_model/executable/sitar_check_test`) instead of the plain C++ model (`model/cpp_model/check_test`, the default). Same CLI, same `.vprj` format, same PASS/FAIL/OVERALL output either way. See [Installation](installation.md) step 3 to build it. |
| `--max-cycles N` | Per-test cycle limit, default 10000. A test that hasn't halted by then is reported as a failure, rather than hanging forever on a genuine bug. |
| `-v` | Show every check's result, not just failures. |

```sh
validation/run_tests.py validation --sitar -v
validation/run_tests.py validation/asm/control_transfer --max-cycles 50000
```

`validation/clean.sh [folder]` removes generated build byproducts (`.o`,
`.elf`, `.expected`) without touching `.hex`/`.s`/`.c`/`.vprj`/`.objdump`.

---

## Where a new test goes

For `validation/asm/`, follow the existing category structure
(`integer_alu/`, `floating_point/`, `control_transfer/`, `data_transfer/`,
`misc/`), putting a new, focused group of tests in its own subfolder
inside the appropriate category. For `validation/C/`, add a new sibling
folder next to the ten above. Either way, `run_tests.py` and
`build_hex.py` both recurse automatically, no registration step needed
anywhere.

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

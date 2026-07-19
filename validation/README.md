# validation/

Functional validation suite for the SPARC V8 core model. No timing/pipeline
tests here -- these check instruction-level (and, later, C-level and
benchmark-level) functional correctness only.

## instruction_tests/

223 opcode-level assembly tests (as `<TEST>.s` + `<TEST>.vprj` pairs),
covering integer ALU ops, control transfer (branches/traps/call/jump/rett),
loads/stores (including atomic load-store and coprocessor variants), and
floating point.

Most of these tests, and the toolchain-driving scripts under `compiler/`, are
adapted from the **AJIT processor project** (IIT Bombay), specifically its
`ajit32` instruction-level verification suite
(`tests/verification/ajit32/instruction_tests/`). Reused with thanks --
individual test files carry their original author credit inline:
Neha Karanjkar, Piyush P. Soni, Titto Thomas, Madhav Desai, Aniket Deshmukh,
Ashfaque Ahammed.

The AJIT project's own `pipeline_verification/` test category was
deliberately **not** copied here -- those tests check microarchitectural
(pipeline/branch-predictor) behavior specific to the AJIT core's
implementation, not SPARC V8 ISA semantics, and are out of scope for this
project's functional-only validation.

**Quad-precision (`floating_point/*/f*q.s`, plus `fp2int/fqtoi.s`,
`int2fp/fitoq.s`, `fpConverts/f{s,d,q}to{s,d,q}.s` quad variants) are this
project's own tests, not adapted from AJIT.** AJIT's own suite assumes quad
ops are unimplemented (its `unimplemented/` category expects them to trap);
this project implements them for real (see `model/cpp_common_code/FloatingPointFunctions.h`),
so those AJIT tests don't apply here and were replaced with tests that check
this project's actual quad-precision behavior instead, including the
`FCMPq`/`FCMPEq` signaling-vs-quiet-NaN distinction and invalid/overflow/
division-by-zero exception detection.

**A handful of AJIT's double/single-precision floating-point tests were
moved to `compliance/` instead of being included here** -- see
`compliance/README.md` for a detailed writeup (with side-by-side expected-vs-
actual test data) of the one specific, well-understood divergence involved
(accrued-inexact FSR bit tracking), intended to be shared with AJIT's
authors.

### Test format and pass/fail convention

Each `.s` file is fully self-contained: it enables traps (PSR `ET=1`),
installs a complete 256-entry trap table, runs the instruction(s) under
test, and always exits via `ta 0`. Any *unexpected* trap during the test is
caught by its own trap-table entry, which records the trap number into
`%g1`, restores the register window, and re-traps via `ta 0` -- which, since
traps are now disabled (`ET=0`, cleared on trap entry), forces the processor
into `error_mode` per the manual (Appendix C, Section C.8) rather than
looping forever. So the core always halts the same way (`ta 0` taken with
`ET=0`), whether the test succeeded or hit an unexpected trap along the way;
`%g1` distinguishes the two: `0x80` (the trap type for a deliberate `ta 0`)
means "no unexpected trap occurred", anything else is the actual trap number
that occurred.

The matching `.vprj` file lists the expected final state as a `RESULTS`
block: `reg=hexvalue` lines (register mnemonics `g1`, `o0`-`o7`, `l0`-`l7`,
`i0`-`i7`, ...) and/or `m[addr]=value mask` lines for memory-state checks.
See `compiler/` for the scripts that build and check these.

### Running the tests

The pipeline is split into two phases, so that running the existing tests
never requires a cross-compiler to be installed:

```
model/cpp_model/build.sh              # build check_test (and sparc_cpp_sim), once
validation/run_tests.py <root_folder> [--max-cycles N] [-v]
```

`run_tests.py` (phase 2) only needs `check_test` built and each test's
`.hex` file to already exist -- and those `.hex` files **are committed to
git**, specifically so that someone who only wants to run the existing
suite against a modified model doesn't need `compiler/`'s sparc-elf
toolchain installed at all.

Pass `--sitar` to instead run the same suite against the actual Sitar
Top/Core/SparcThread model (see `model/sitar_model/build.py` to build it)
rather than the plain C++ core:

```
model/sitar_model/build.py            # requires the sitar CLI on PATH, once
validation/run_tests.py <root_folder> --sitar
```

If you add a new test or edit an existing `.s` source, its `.hex` is now
stale (or missing) and needs to be regenerated -- that's phase 1, and it
*does* need the toolchain (see `compiler/README.md`):

```
source compiler/toolchain_env.sh    # put the toolchain on PATH, if installed
validation/build_hex.py <root_folder>
```

then commit the resulting `.hex` file(s) alongside your `.s`/`.vprj`
change. `validation/clean.sh [root_folder]` removes the other generated
byproducts (`.o`, `.elf`, `.expected`) without touching `.hex`/`.s`/`.vprj`.

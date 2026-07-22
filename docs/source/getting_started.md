# Getting Started

This page assumes you've completed [Installation](installation.md). Let's
run something.

---

## The toolchain, in one picture

The build and run pipeline has three steps.

1. `sparc-elf-as` and `sparc-elf-ld` assemble and link `test.s` into `test.elf`.
2. `readelf` and `compiler/hexdump_to_memimage.py` convert `test.elf` into
   `test.hex`, a plain text memory image.
3. `sparc_cpp_sim` or `check_test` run `test.hex` on the plain C++ model.
   `sitar_check_test` runs the same `test.hex` on the Sitar timed model.
   Either path produces the final register state and a pass or fail result.

The `.hex` format is the one format both models load, through
`MemCore::initializeMemory()`. Everything upstream of it is identical
regardless of which model you run it on afterward.

---

## Run a single test by hand

The validation suite's `.hex` files are committed to git, so you can run
one immediately without needing the cross-toolchain:

```sh
model/cpp_model/sparc_cpp_sim validation/asm/integer_alu/Arithmetic/Add/ADD.hex
```

```
PROCESSOR STATE: ERROR
...
 In:
 i0 fffffffe
 i1 e0
 i2 2
 i3 e0
 ...
--------------------

Simulation halted (error_mode) after 46 cycles.
```

(`ERROR`/`error_mode` here just means the core hit its final `ta 0` with
traps disabled. This is the standard, deliberate way every test in this
suite signals "done". See
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md#the-pass-fail-convention).)

`sparc_cpp_sim` just runs a memory image and prints final register state.
It's handy for ad hoc use, but it doesn't check pass/fail. For that, use
`check_test` with the test's paired expected-results file:

```sh
model/cpp_model/check_test \
    validation/asm/integer_alu/Arithmetic/Add/ADD.hex \
    validation/asm/integer_alu/Arithmetic/Add/ADD.expected
```

```
PASS: i0 = 0xfffffffe
PASS: i1 = 0xe0
...
OVERALL: PASS (13 checks)
```

(`ADD.expected` is generated from the test's `.vprj` file by
`validation/run_tests.py`. See
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
for the full test-authoring format.)

To run the same test against the Sitar-timed model instead (same CLI,
same expected-results format, same output):

```sh
model/sitar_model/executable/sitar_check_test \
    validation/asm/integer_alu/Arithmetic/Add/ADD.hex \
    validation/asm/integer_alu/Arithmetic/Add/ADD.expected
```

---

## Run the whole suite

```sh
validation/run_tests.py validation/asm
```

```
[PASS] validation/asm/misc/save_restore/SAVE.vprj
[PASS] validation/asm/misc/stbar_unimp_nop_sethi/STBAR_UNIMP_NOP_SETHI.vprj

230/230 tests passed
```

Add `--sitar` to run the identical suite against the Sitar-timed model,
`-v` to see every check (not just failures), or point at a subfolder
(e.g. `validation/asm/floating_point`) to run a subset. See
`validation/README.md` for the full pipeline, including how to add a new
test and regenerate `.hex` files if you edit a `.s` source.

---

## Turning on logging (Sitar model only)

The plain C++ model has no notion of cycles or timing, so there's nothing
to log. The Sitar model can be rebuilt with per-cycle trace logging:

```sh
model/sitar_model/build.py --logging
model/sitar_model/executable/sitar_check_test  <hex>  <expected>  2> trace.log
```

Logging is off by default. Rebuild without `--logging` to go back to that.
It's noisy and slower, meant for debugging timing (e.g. verifying a
latency change actually took effect). Log lines are timestamped
`[t=<cycle>]`. See [Performance Modeling](performance_modeling.md) for a
worked example.

---

## What's next

- Write your own test: [Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
  or [Writing and Running C Programs](writing_and_running_c_programs.md).
- Understand how the pieces fit together: [Model Components](model_components.md).

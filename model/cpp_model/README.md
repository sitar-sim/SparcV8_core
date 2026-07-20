# cpp_model/

Standalone, plain-C++ fetch-decode-execute driver for `SparcCore`
(`../cpp_common_code/`): zero-delay, functional-only execution with no
Sitar dependency, no cycles, no memory latency. This is the fast, simple
reference model to check ISA-level correctness against; timing itself is
modeled only in `../sitar_model/`.

## What's what

- **`SparcStateMachine.h` / `.cpp`** -- the driver. `SparcStateMachine(core,
  mem)`, then `run(maxCycles)`: repeatedly fetches, decodes, and executes one
  instruction per call to `runOneCycle()` (memory-access instructions go
  through an explicit LOAD/STORE/atomic/FLUSH path; everything else through
  `SparcCore::executeInstruction()`), dispatching every trap via
  `SparcCore::executeTraps()` with no special-casing by trap type (Ref
  Section C.5 of the SPARC V8 manual). Runs until the core halts (enters
  `error_mode`, tracked as `halted`) or `maxCycles` is exceeded.
- **`main.cpp`** -- builds `sparc_cpp_sim`: loads a hex-dump memory image,
  runs it to completion, and prints a final register dump. Ad hoc use only
  -- it does not check pass/fail.
- **`check_test.cpp`** -- builds `check_test`: loads a hex-dump image, runs
  it to halt, then compares final register/memory state against an
  expected-results file and prints `PASS`/`FAIL` per check plus an
  `OVERALL` verdict. This is what `../../validation/run_tests.py` drives.
- **`build.sh`** -- builds both `sparc_cpp_sim` and `check_test` (links
  `../cpp_common_code/*.cpp` plus `-lquadmath`). Both binaries are
  gitignored build products.

## How to run it

Build once:

```sh
model/cpp_model/build.sh
```

Run a single memory image and see final register state:

```sh
model/cpp_model/sparc_cpp_sim  validation/asm/integer_alu/Arithmetic/Add/ADD.hex
# optional: cap the cycle count (default 1,000,000)
model/cpp_model/sparc_cpp_sim  validation/asm/integer_alu/Arithmetic/Add/ADD.hex  5000
```

Check one test's pass/fail verdict directly (expects an `.expected` file in
the normalized `REG`/`MEM` format produced from a test's `.vprj`, see
`../../validation/README.md`):

```sh
model/cpp_model/check_test  validation/asm/integer_alu/Arithmetic/Add/ADD.hex \
                             validation/asm/integer_alu/Arithmetic/Add/ADD.expected
```

```
PASS: i0 = 0xfffffffe
PASS: i1 = 0xe0
...
OVERALL: PASS (13 checks)
```

In practice you won't invoke `check_test` by hand like that -- the whole
suite (223 tests) is run via:

```sh
validation/run_tests.py validation/asm
```

See `../../validation/README.md` for the full pipeline (building `.hex`
files from `.s` sources, `--max-cycles`, `-v`, etc.).

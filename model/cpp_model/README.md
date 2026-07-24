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
  gitignored build products. `--logging`/`--no-logging` (default) controls
  whether `SparcCore::logger` (a `CoreLogger` -- see
  `../cpp_common_code/CoreLogger.h`) does real work or compiles to no-op
  stubs; with `--logging`, `sparc_cpp_sim` writes a full instruction/state
  trace to `sparc_trace.log`, viewable in `../../log_viewer/`.
- **`test/`** -- a minimal, beginner-friendly example program (see below).
  Its assembled memory image (`test_simple_ADD.hex`), a readable
  disassembly (`test_simple_ADD.objdump`), and its expected-results file
  (`test_simple_ADD.expected`) are committed alongside it, so trying it
  out needs no toolchain at all.

## How to run it

Commands below are relative to this directory (`model/cpp_model/`).

Build once:

```sh
./build.sh
```

### A first, minimal example

`test/test_simple_ADD.s` adds two numbers and puts the result in a
register, then halts. It's a good first program to read end to end.

```sh
cat test/test_simple_ADD.s
```

Run it and see the final register state:

```sh
./sparc_cpp_sim test/test_simple_ADD.hex
```

Or check it against its expected result:

```sh
./check_test test/test_simple_ADD.hex test/test_simple_ADD.expected
```

```
PASS: o0 = 0xc
PASS: l0 = 0x5
PASS: l1 = 0x7
OVERALL: PASS (3 checks)
```

### Inspecting a trace

```sh
./build.sh --logging
./sparc_cpp_sim test/test_simple_ADD.hex
```

Writes `sparc_trace.log` into the current directory; open it in
`../../log_viewer/viewer.html` (see that directory's `README.md`) to step
through fetch/trap/memory events alongside the disassembly and register
state.

### Next steps

To write your own assembly or C program, see
`../../docs/source/writing_and_running_assembly_programs.md` and
`../../docs/source/writing_and_running_c_programs.md`.

To run the full validation suite instead, from the repository root:

```sh
validation/run_tests.py validation/asm
```

See `../../validation/README.md` for the full pipeline.

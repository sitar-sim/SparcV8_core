# cpp_model/

Standalone, plain-C++ fetch-decode-execute driver for `SparcCore`
(`../cpp_common_code/`): a simple functional model, with no timing. Each
complete instruction execution is counted and reported as 1 "cycle" by
this model's own tooling, but that's just an iteration count, with no
notion of how long a real instruction or memory access would actually
take (unlike `../sitar_model/`, where a cycle is an actual elapsed clock
cycle). This is the fast, simple reference model to check ISA-level
correctness against.

## What's what

- **`SparcStateMachine.h` / `.cpp`** -- the driver. `SparcStateMachine(core,
  mem)`, then `run(maxCycles)`: repeatedly fetches, decodes, and executes one
  instruction per call to `runOneCycle()` (memory-access instructions go
  through an explicit LOAD/STORE/atomic/FLUSH path; everything else through
  `SparcCore::executeInstruction()`), dispatching every trap via
  `SparcCore::executeTraps()` with no special-casing by trap type (Ref
  Section C.5 of the SPARC V8 manual). Runs until the core halts (enters
  `error_mode`, tracked as `halted`) or `maxCycles` is exceeded.
- **`sparc_sim.cpp`** -- builds `sparc_sim_cpp`: loads a hex-dump memory
  image and runs it to halt (or the cycle limit). With no expected-results
  file, just prints the final processor state, ad hoc use, not a pass/fail
  check. Given one, instead compares final register/memory state against
  it and prints `PASS`/`FAIL` per check plus an `OVERALL` verdict. This is
  what `../../validation/run_tests.py` drives.
- **`build.sh`** -- builds `sparc_sim_cpp` (links `../cpp_common_code/*.cpp`
  plus `-lquadmath`). The binary is a gitignored build product.
  `--logging`/`--no-logging` (default) controls whether `SparcCore::logger`
  (a `CoreLogger` -- see `../cpp_common_code/CoreLogger.h`) does real work
  or compiles to no-op stubs; with `--logging`, `sparc_sim_cpp` writes a
  full instruction/state trace, named after the hex file it ran (`.hex`
  replaced by `.log`), viewable in `../../log_viewer/`.
- **`test/`** -- a minimal, beginner-friendly example program (see below):
  `test_simple_ADD.s`, its assembled memory image (`.hex`), a readable
  disassembly (`.objdump`), and its expected-results file (`.expected`).
  All four are symlinks into `../../validation/test_simple_ADD/` (the
  canonical copy, shared with `sitar_model/executable/`), so trying it
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
./sparc_sim_cpp test/test_simple_ADD.hex
```

Or check it against its expected result:

```sh
./sparc_sim_cpp test/test_simple_ADD.hex test/test_simple_ADD.expected
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
./sparc_sim_cpp test/test_simple_ADD.hex
```

Writes `test_simple_ADD.log` into the current directory. Open it in
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

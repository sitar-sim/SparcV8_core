# core_only/cpp_model/

Standalone, plain-C++ fetch-decode-execute driver for `SparcCore`
(`../../../cpp_common_code/`): a simple functional model, with no timing.
Each complete instruction execution is counted and reported as 1 "cycle"
by this model's own tooling, but that's just an iteration count, with no
notion of how long a real instruction or memory access would actually
take (unlike `../sitar_model/`, where a cycle is an actual elapsed clock
cycle). This is the fast, simple reference model to check ISA-level
correctness against.

## What's what

- **`src/sparc_sim.cpp`** -- this configuration's entry point: constructs
  a `MemCore`, a `SparcCore`, and the reusable
  `SparcStateMachine` (`../../../cpp_common_code/SparcStateMachine.h`)
  driving them together, loads a hex-dump memory image, and runs it to
  halt (or a cycle limit). With no expected-results file, just prints the
  final processor state, for ad hoc use, not a pass/fail check. Given
  one, instead compares final register/memory state against it and
  prints `PASS`/`FAIL` per check plus an `OVERALL` verdict. This is what
  `../../../../validation/run_tests.py` drives.
- **`build.sh`** -- thin wrapper around the shared
  `../../../build_scripts/build_cpp_model.sh`, which compiles
  `cpp_common_code/*.cpp` plus everything in this folder's own `src/` and
  writes the executable into `executable/`. `--logging`/`--no-logging`
  (default) controls whether `SparcCore::logger` (a `CoreLogger` -- see
  `../../../cpp_common_code/CoreLogger.h`) does real work or compiles to
  no-op stubs; with `--logging`, the built binary writes a full
  instruction/state trace, named after the hex file it ran (`.hex`
  replaced by `.log`), viewable in `../../../../log_viewer/`.
- **`run_simple_test.sh`** -- runs the default build against the bundled
  `test_simple_ADD` example (the canonical copy lives in
  `../../../../validation/test_simple_ADD/`, not a local copy).
- **`executable/`**, **`build/`** -- gitignored build output and scratch.
- **`test_simple_ADD.log`** -- a tracked reference trace (from a
  `--logging` build run against `test_simple_ADD`), used by
  `../../../../log_viewer/` as a ready-made example, kept up to date by
  a normal `--logging` run from this folder.

## How to run it

Commands below are relative to this directory.

Build once:

```sh
./build.sh
```

Run the bundled example and check it against its expected result:

```sh
./run_simple_test.sh
```

```
PASS: o0 = 0xc
PASS: l0 = 0x5
PASS: l1 = 0x7
OVERALL: PASS (3 checks)
```

`run_simple_test.sh` always runs the plain default build
(`executable/sparc_sim_cpp_core_only`, no `--logging`/`--debug`). A
`--logging` or `--debug` build gets its own suffixed executable name
instead (so both can exist in `executable/` at once -- see
`build_cpp_model.sh`'s comment), and is run directly rather than through
`run_simple_test.sh`:

### Inspecting a trace

```sh
./build.sh --logging
./executable/sparc_sim_cpp_core_only_logging \
    ../../../../validation/test_simple_ADD/test_simple_ADD.hex
```

Writes `test_simple_ADD.log` into the current directory. Open it in
`../../../../log_viewer/viewer.html` (see that directory's `README.md`) to
step through fetch/trap/memory events alongside the disassembly and
register state.

### Next steps

To write your own assembly or C program, see
`../../../../docs/source/writing_and_running_assembly_programs.md` and
`../../../../docs/source/writing_and_running_c_programs.md`.

To run the full validation suite instead, from the repository root:

```sh
validation/run_tests.py validation/asm
```

See `../../../../validation/README.md` for the full pipeline.

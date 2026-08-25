# core_only/sitar_model/

The timed model: drives `SparcCore` (`../../../cpp_common_code/`) through
the Sitar hardware-modeling DSL (a separate sibling repo), so that
(unlike `../cpp_model/`, which is instantaneous) instructions and memory
accesses actually take simulated cycles. Three independent, additive
latency knobs live here -- everything else about ISA behavior still
comes from `SparcCore`.

## What's what

- **`src/Top.sitar`** -- trivial wrapper module (`submodule core : Core`),
  required by `sitar compile`'s convention of looking for a module
  literally named `Top`.
- **`src/Core.sitar`** -- this configuration's own composition: runs
  `sparcThread` (from `../../../sitar_component_models/SparcThread.sitar`)
  and `mainMemory` (from `.../MainMemory.sitar`) as two parallel
  procedures sharing one `MemAccessInterface` struct, plus a third
  parallel branch that watches `sparcThread.HALT.VALUE` and, once it's
  set, prints `sparcThread.printInfo()` and calls `stop simulation`. This
  is the file that changes shape between configurations (a future
  configuration's `Core.sitar` wires in an MMU, a cache, or devices
  instead); `Top.sitar` and the procedures it composes do not.
- **`src/sparc_sim.cpp`** -- the `-m` custom main for `sitar compile`,
  building this configuration's executable: same CLI, expected-results
  format, and `PASS`/`FAIL`/`OVERALL` output as `../cpp_model/`'s, so
  `../../../../validation/run_tests.py` can point at either
  interchangeably.
- **`build.sh`** -- thin wrapper around the shared
  `../../../build_scripts/build_sitar_model.py`, which translates every
  `.sitar` file in `../../../sitar_component_models/` plus this folder's
  own `src/`, and writes the executable into `executable/`. Requires the
  `sitar` CLI on `PATH` (see the sibling `sitar` repo).
- **`run_simple_test.sh`** -- runs the default build against the bundled
  `test_simple_ADD` example (the canonical copy lives in
  `../../../../validation/test_simple_ADD/`, not a local copy).
- **`executable/`**, **`build/`** -- gitignored build output and scratch
  (`build/Output/` is the translated `.sitar` -> `.cpp`/`.h` output).
- **`test_simple_ADD.log`** -- a tracked reference trace (from a
  `--logging` build run against `test_simple_ADD`), kept up to date by a
  normal `--logging` run from this folder.

## Latency model

Three knobs, independent and additive -- e.g. a `LD` with opcode latency 1,
`MemoryInterface.delay` 2, and `MainMemory.delay` 3 takes 6 cycles total:

1. **Opcode latency** (`../../../sitar_component_models/cpp_code/OpcodeLatencies.h`)
   -- charged by `SparcThread` for every instruction, memory or not.
2. **`MemoryInterface.delay`** -- charged on the requester side, after the
   response is available (e.g. interconnect/cache latency).
3. **`MainMemory.delay`** -- charged by the memory itself before publishing
   its response (memory service time), shared by all requesters.

All three default to sensible values (`DEFAULT_PER_OPCODE_DELAY=1`, both
`delay` fields init to `0`) and all three accept `0` -- with everything at
`0` the model runs with zero elapsed simulated time, functionally identical
to `../cpp_model/`.

## How to build and run it

Commands below are relative to this directory.

Build:

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
(`executable/sparc_sim_sitar_core_only`). A `--logging` or `--debug`
build gets its own suffixed executable name instead (so both can exist
in `executable/` at once), and is run directly:

```sh
./build.sh --logging
./executable/sparc_sim_sitar_core_only_logging \
    ../../../../validation/test_simple_ADD/test_simple_ADD.hex
```

This writes two files into the current directory, instead of Sitar's
usual stderr output:

- **`test_simple_ADD.log`** -- `sparcThread`'s own log only, one
  tab-separated row per architectural event from `SparcCore`'s
  `CoreLogger`, with Sitar's usual `(time)hierarchicalId:` line prefix
  turned off. Same format the cpp model's `--logging` build writes (see
  `../../../cpp_common_code/CoreLogger.h`). Load it directly into
  `../../../../log_viewer/` (see that directory's `README.md`) with no
  extraction needed.
- **`sitar.log`** -- everything else: `mainMemory`/`ifetchThread`/the
  other `MemoryInterface` instances' own per-request/response messages,
  timestamped `[t=<cycle>]`, prefixed with each module's hierarchical id
  as usual.

To change a latency knob, edit the relevant source and rebuild:

- Opcode latency:
  `../../../sitar_component_models/cpp_code/OpcodeLatencies.h`
  (`DEFAULT_PER_OPCODE_DELAY` / `OPCODE_LATENCY_OVERRIDES`).
- `MemoryInterface.delay` / `MainMemory.delay`: both fields default to `0`
  (set in each procedure's own `init` block) and are otherwise only ever
  assigned from outside in `Core.sitar`'s `init` block, alongside the
  `interface = &memInterface` wiring, e.g.:

  ```
  init
  $
  sparcThread.ifetchThread.interface = &memInterface;
  sparcThread.ifetchThread.delay     = 2;   // add this line
  ...
  mainMemory.interface = &memInterface;
  mainMemory.delay     = 3;                 // add this line
  $
  ```

### Next steps

To write your own assembly or C program, see
`../../../../docs/source/writing_and_running_assembly_programs.md` and
`../../../../docs/source/writing_and_running_c_programs.md`.

To run the full validation suite instead, against this Sitar-timed model
rather than the plain C++ one, from the repository root:

```sh
validation/run_tests.py validation/asm --sitar
```

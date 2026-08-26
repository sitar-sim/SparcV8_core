# core_mmu/cpp_model/

The 0-delay functional driver for this configuration: `SparcStateMachine`
(`../../../cpp_common_code/`, reused unchanged from `core_only/`) driving
`SparcCore` through an `Mmu` instance (`../../../cpp_common_code/mmu/`)
instead of talking to `MemCore` directly. The MMU's own downstream target
is `MainMemory` (`../../../cpp_common_code/MainMemory.h`), reached
through `PhysicalMemoryInterface` (see `../../../cpp_common_code/
MemoryInterfaces.h`) -- not `MemCore` directly; this configuration has no
cache or devices yet. See `Plan_MMU_integration.md`.

## What's what

- **`src/sparc_sim.cpp`** -- this configuration's entry point. Same shape
  as `core_only/cpp_model/src/sparc_sim.cpp`, except it constructs a
  `MainMemory` and an `Mmu` on top of it: `MainMemory mem; Mmu mmu(mem);
  core.memCore = &mmu; SparcStateMachine runner(core, mmu);`. `MEM`
  checks in an expected-results file still read `MainMemory`'s
  underlying storage directly (bypassing the MMU), since they check
  physical memory state.
- **`build.sh`** -- thin wrapper around the shared
  `../../../build_scripts/build_cpp_model.sh`. Same flags as every other
  configuration's `build.sh` (`--logging`, `--debug`, `--debug-o0`).
- **`run_simple_test.sh`** -- runs the default build against the bundled
  `test_simple_ADD` example. This exercises the MMU only in its
  disabled, pass-through state (`test_simple_ADD` never enables it or
  sets up page tables) -- it confirms the MMU-in-the-loop wiring itself
  works, not translation. See `validation/C/mmu/` for real translation
  coverage.
- **`executable/`**, **`build/`** -- gitignored build output and scratch.

## How to run it

Commands below are relative to this directory.

```sh
./build.sh
./run_simple_test.sh
```

MMU statistics (`MmuStats::toString()`) are printed to stderr after every
run, regardless of pass/fail, for now -- see `Plan_MMU_integration.md`'s
"Proposed stats set".

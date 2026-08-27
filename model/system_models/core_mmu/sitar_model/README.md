# core_mmu/sitar_model/

The timed model for this configuration: the same `SparcThread` used by
`../../core_only/sitar_model/`, but with an `MmuUnit` procedure spliced in
between it and memory, and `MainMemoryPA` (the PM-shaped memory,
Ref `../../../cpp_common_code/MainMemory.h`) as the terminal node instead
of `MainMemoryVA`. See `Plan_MMU_integration.md`'s "Sitar timing model"
section for the full design and `../../../sitar_component_models/
MmuUnit.sitar`'s own header comment for the implementation.

## What's what

- **`src/Top.sitar`** -- trivial wrapper module (`submodule core : Core`),
  same convention as every other configuration's `Top.sitar`.
- **`src/Core.sitar`** -- this configuration's own composition: runs
  `sparcThread`, `mmu : MmuUnit`, and `mainMemory : MainMemoryPA` as three
  parallel branches of one `[ ... || ... || ... ]` block, plus the usual
  halt-watcher branch. `sparcThread`'s 5 memory-interface procedures'
  downstream pointers are wired to `&mmu.request`/`&mmu.response` instead
  of a memory procedure directly; `mmu`'s own `phyMemReadProcedure`/
  `phyMemWriteProcedure` are in turn wired to `&mainMemory.request`/
  `&mainMemory.response`. This is the one file that differs structurally
  from `../../core_only/sitar_model/src/Core.sitar` -- `SparcThread.sitar`
  and `MemoryInterface.sitar` needed zero changes to support the MMU
  being inserted (Ref the "lego block" interface contract,
  `Plan_SoC_Integration_Roadmap.md`).
- **`src/sparc_sim.cpp`** -- the `-m` custom main, same shape as every
  other configuration's, except `MEM` checks in an expected-results file
  read `TOP->core.mainMemory.mem.readWord()` (physical memory, bypassing
  the MMU, same convention `core_mmu/cpp_model/src/sparc_sim.cpp` uses).
- **`build.sh`** -- thin wrapper around the shared
  `../../../build_scripts/build_sitar_model.py`.
- **`run_simple_test.sh`** -- runs the default build against the bundled
  `test_simple_ADD` example. Like `core_mmu/cpp_model/run_simple_test.sh`,
  this only exercises the MMU in its disabled, pass-through state -- see
  `validation/C/mmu/` for real translation coverage, run against this
  driver via `--sitar --config core_mmu` (below).
- **`executable/`**, **`build/`** -- gitignored build output and scratch.

## Latency model

Every knob defaults to `0` -- with everything at `0` this model produces
the exact same cycle counts as `core_mmu/cpp_model/` (0 elapsed time) and,
with the MMU further disabled at runtime, the exact same counts as
`core_only/sitar_model/` too (the bypass path adds none of these). See
`../src/Core.sitar`'s own `init` block for the single consolidated,
commented list of every knob in this configuration -- the summary below
is what each one means, not where to set it.

- **Opcode latency, `MemoryInterface.delay`** -- same as
  `core_only/sitar_model/`, charged by `SparcThread`/its 5 memory-interface
  procedures, upstream of the MMU entirely.
- **`mmu.tlbLookupDelay`** -- TLB tag-compare cost. Charged once per
  ordinary translated access (hit or miss) and, separately, once for an
  entire-type TLB probe -- *not* for the other four probe types, which
  always walk fresh and never consult the TLB at all (Ref
  `Mmu.cpp`'s `probe()`).
- **`mmu.pageTableWalkStepDelay`** -- page-table walker control overhead,
  charged once per level actually visited during a walk (1-3 levels,
  depending where the walk terminates).
- **`mmu.tlbFillDelay`** -- cost of inserting a freshly-resolved entry
  into the TLB. Charged only on a fresh miss that successfully translates
  (not on a hit, not on a fault).
- **`mmu.registerAccessDelay`** -- MMU control/context/FSR/FAR register
  read or write (ASI 4).
- **`mmu.flushDelay`** -- TLB invalidate (ASI 3 write). No memory access
  at all -- the TLB is write-through (Ref `Plan_MMU_integration.md`), so
  a flush never needs to write anything back to memory first.
- **`mmu.phyMemReadProcedure.delay` / `phyMemWriteProcedure.delay`** --
  the MMU-to-memory interconnect, additive with `mainMemory.delay`
  exactly the way `MemoryInterface.delay`/`MainMemoryVA.delay` are on the
  virtual side.
- **`mainMemory.delay`** -- physical memory's own service latency,
  shared by every physical access the MMU makes (walk reads, R/M
  write-back, the final data access) -- so unlike `core_only`, a single
  translated access here can pay this delay more than once per
  instruction.

## How to build and run it

Commands below are relative to this directory.

```sh
./build.sh
./run_simple_test.sh
```

To run the full validation suite (asm, C, and the MMU-specific suite)
against this driver instead of `cpp_model`, from the repository root:

```sh
validation/run_tests.py validation/asm --sitar --config core_mmu
validation/run_tests.py validation/C --sitar --config core_mmu
validation/run_tests.py validation/C/mmu --sitar --config core_mmu
```

To change a knob, edit `src/Core.sitar`'s consolidated `init` block and
rebuild -- see "Latency model" above for what each one means.

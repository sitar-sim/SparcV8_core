# core_mmu/sitar_model/

The timed model for this configuration. Same `SparcThread` as
`../../core_only/sitar_model/`, but with `Mmu` spliced in between it and
memory, reaching physical memory over real Sitar ports and nets instead
of a procedure handshake. See `docs/source/model_configurations.md` for
the block diagram, and `src/System.sitar`'s own header comment for the
full design.

## What's what

- **`src/Top.sitar`** -- trivial wrapper module (`submodule system :
  System`), same convention as every other configuration's `Top.sitar`.
- **`src/System.sitar`** -- assembles `Core` and `PhysicalMainMemory` as
  sibling submodules, connected by two nets (`requestNet`,
  `responseNet`). Also owns the single consolidated, commented list of
  every latency knob in this configuration.
- **`src/Core.sitar`** -- the SPARC core plus the MMU: `sparcThread` and
  `mmu : Mmu` as two parallel procedures, plus the usual halt-watcher
  branch. Exposes two ports, `requestOut`/`responseIn`, wired to `mmu`'s
  own two `PhysicalMainMemoryInterface` instances at init.
  `SparcThread.sitar` and `VirtualMainMemoryInterface.sitar` needed zero
  changes to support any of this (Ref the "lego block" interface
  contract, `Plan_SoC_Integration_Roadmap.md`).
- **`src/sparc_sim.cpp`** -- the `-m` custom main, same shape as every
  other configuration's, except `MEM` checks in an expected-results file
  read `TOP->system.mainMemory.mem.readWord()` (physical memory,
  bypassing the MMU, same convention `core_mmu/cpp_model/src/sparc_sim.cpp`
  uses).
- **`build.sh`** -- thin wrapper around the shared
  `../../../build_scripts/build_sitar_model.py`.
- **`run_simple_test.sh`** -- runs the default build against the bundled
  `test_simple_ADD` example. Like `core_mmu/cpp_model/run_simple_test.sh`,
  this only exercises the MMU in its disabled, pass-through state. See
  `validation/C/mmu/` for real translation coverage, run against this
  driver via `--sitar --config core_mmu` (below).
- **`executable/`**, **`build/`** -- gitignored build output and scratch.

## Latency model

Every knob defaults to `0`. Unlike `core_only`, this configuration
cannot reach 0 elapsed cycles even at every knob's default: crossing a
net costs Sitar's own unavoidable minimum one cycle each way, and every
physical access, including every instruction fetch, crosses two nets
(`requestNet`, then `responseNet`). See `src/System.sitar`'s own init
block for the single consolidated, commented list of every knob in this
configuration. The summary below is what each one means, not where to
set it.

- **`sparcThread.<memory-interface procedure>.delay`** -- same as
  `core_only/sitar_model/`, charged upstream of the MMU entirely.
- **`mmu.tlbLookupDelay`** -- TLB tag-compare cost. Charged once per
  ordinary translated access, hit or miss, and once for an entire-type
  TLB probe. Not charged for the other four probe types, which always
  walk fresh and never consult the TLB (Ref `MmuCore.cpp`'s `probe()`).
- **`mmu.pageTableWalkStepDelay`** -- page-table walker control overhead.
  Charged once per level actually visited during a walk, one to three
  levels depending where the walk terminates.
- **`mmu.tlbFillDelay`** -- cost of inserting a freshly resolved entry
  into the TLB. Charged only on a fresh miss that successfully
  translates.
- **`mmu.registerAccessDelay`** -- MMU control, context, FSR, or FAR
  register read or write (ASI 4).
- **`mmu.flushDelay`** -- TLB invalidate (ASI 3 write). No memory access
  at all. The TLB is write-through, so a flush never needs to write
  anything back to memory first.
- **`mmu.phyMemReadProcedure.delay` / `phyMemWriteProcedure.delay`** --
  the MMU-to-memory interconnect, additive with `mainMemory.delay` and
  with requestNet/responseNet's own minimum latency.
- **`mainMemory.delay`** -- physical memory's own service latency,
  shared by every physical access the MMU makes. A single translated
  access can pay this more than once: a walk step, an R/M write-back,
  and the final data access are each a separate physical access.

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

To change a knob, edit `src/System.sitar`'s consolidated `init` block
and rebuild. See "Latency model" above for what each one means.

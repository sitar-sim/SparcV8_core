# TODO / Progress log

This file tracks overall project status and next steps. Update it as
milestones are reached rather than treating it as a historical log --
keep the "Current status" section accurate to the present state of the
repo, and move completed "Next steps" items into it.

## Current status (as of 2026-07-17)

**Milestone 1 -- standalone C++ core model: essentially done.**

- `model/cpp_code/`: `SparcCore` is a pure state + `execute_*()` library,
  with no structure/timing/sequencing of its own (that's Sitar's job).
  Closely follows the SPARC V8 manual, with section citations in comments.
- `model/cpp_standalone_model/`: a `Runner` class drives the same
  `SparcCore` through a fetch-decode-execute-trap FSM loop (Ref Appendix
  C.5) against a plain `MemCore` array, for functional testing with no
  Sitar dependency at all. `build.sh` builds `sparc_standalone_sim` and
  `check_test`.
- 7 confirmed `SparcCore`/decoder bugs fixed: `execute_Div` flags,
  `execute_Mul` SMUL truncation, SWAP byte-mask, SDIV overflow clamp value,
  `FqTOd` result-flag bug, plus an ASR off-by-one UB fix in `Registers.h`;
  and two more found via the full validation pass below -- a driver bug in
  `Runner.cpp` where an `execute_*` function (e.g. `execute_RETT`) setting
  `core.state = ERROR` directly, bypassing the normal trap-dispatch path,
  was never noticed by the halt-detection logic (`RETT4`/`RETT5`/`RETT6`
  hung instead of halting); and a `Decoder.cpp` op3 table bug that had
  `TADDcc`(`0x20`)/`TSUBcc`(`0x21`) swapped, so each executed as the other.
- Full IEEE-754 FP exception detection implemented for single/double
  (via host `<cfenv>`) and quad precision (via explicit bit-pattern
  checks in `FloatingPointFunctions.h` -- `fetestexcept` is unreliable
  for `__float128`, see the file-level comment there for why).
  Quad-precision arithmetic itself is fully supported (this project
  implements it "from scratch"/via libquadmath; AJIT's own suite assumes
  it's unimplemented -- see `README.md` Acknowledgments).
- `validation/`: self-built test harness (`run_tests.py` + `check_test.cpp`,
  folder-scoped, ajit-style `.vprj` REG/MEM expected-results format) plus
  223 instruction tests (adapted from AJIT's `ajit32` suite, plus new
  quad-precision tests written for this project). **Full suite run:
  223/223 passing** (see "Full validation pass" below -- item 1 done,
  opcode-wise coverage analysis still open).
- Test pipeline split into two phases so the suite can be run with no
  cross-compiler installed: `validation/build_hex.py` (phase 1, needs the
  sparc-elf toolchain, assembles `.s` -> `.hex`) and `validation/run_tests.py`
  (phase 2, only needs `check_test` built, runs the already-assembled
  `.hex` files). `.hex` files are committed to git for this reason;
  `.o`/`.elf`/`.expected` are not (`validation/clean.sh` removes them).
- `compliance/` now documents three independent, well-understood AJIT
  divergences (not bugs on either side, each with side-by-side
  original-vs-our_model `.vprj` evidence for AJIT's authors): (1) 10 tests,
  accrued-inexact FSR tracking; (2) 2 `RDPSR`/`WRPSR` tests, PSR
  `impl`/`ver` fields hardwired here vs. writable in AJIT (the corrected
  values were also folded back into `validation/`'s own copies of these
  two tests, now passing); (3) 14 of AJIT's own `unimplemented/`
  quad-precision tests, which this model actually executes for real
  instead of trapping (two incidental AJIT-corpus bugs also noted along
  the way: `fitoq.s`/`.vprj` never really tests `FITOQ`, and `fsubq.vprj`'s
  `SOURCES` points at `fmulq.s`).
- FLUSH: `execute_PreFlush` implemented (address computation only, no
  ASI, Ref Appendix B.32/C.9); wired all the way through
  `MemoryInterfaceThread.sitar` (new `FLUSH` access type, no-op in
  `DIRECT_INTERFACE_TO_MEM` mode) and a new `flushThread` in
  `SparcThread.sitar`/`Core.sitar`. Verified on both the standalone model
  and a minimal Sitar build (translate/compile/run) -- see FLUSH.hex log:
  flush dispatches, computes the correct address, and execution continues
  normally afterward with no crash/assert.
- Repo-wide `.gitignore` pass done (top-level `.gitignore` created;
  `model/.gitignore` now catches the two extensionless
  `cpp_standalone_model` binaries, which no prior pattern matched;
  `validation/.gitignore` updated per the `.hex`-tracking change above).
- Filed in the separate `sitar` repo's `TODO.md`: `sitar compile --cflags`
  doesn't propagate to the link step (`LIBS`/`LINKFLAGS`), only to
  `CCFLAGS` -- currently worked around here by manually re-invoking the
  final `g++` link command with `-lquadmath` appended. Not fixed yet
  (needs a `sitar` CLI change + doc update, deferred).

## Next steps

1. **Full validation pass.** ~~Run the entire `validation/` suite end to
   end (not just spot checks)~~ -- **done against the standalone model:
   223/223 passing**, all 7 previously-failing tests root-caused and fixed
   (see "Current status" above). Still open: run the same full suite
   against the Sitar-driven model too (only FLUSH has been spot-checked
   there so far), and separately do an opcode-wise coverage analysis of
   the SPARC V8 instruction set against `validation/instruction_tests/` to
   find gaps (opcodes with no test at all, not just currently-failing
   ones).

2. **Re-look at the Sitar model's design/architecture, complete it, and
   validate it.** `SparcThread`/`MemoryInterfaceThread`/`Core` grew
   somewhat organically (5 memory-interface threads, `DIRECT_INTERFACE_TO_MEM`
   as a per-thread bool, etc.) -- worth a deliberate design pass before
   adding latency/ports/caches on top, rather than continuing to bolt on.

3. **Documentation.** Write it up properly (architecture, how the C++
   core / Sitar model / standalone driver relate, how to build and run
   tests, how to add a new test). To be reviewed and iterated on
   together over a few passes rather than written once and left.

4. **Repo hygiene pass.** Systematically go through the repo and add:
   an install script, a top-level `README.md` rewrite (currently a
   two-line stub), `AUTHORS` (crediting the AJIT project sources
   explicitly, alongside this project's own authors), `LICENCE.md`.

5. **Opcode-wise latency model** -- as an include file, user-specifiable,
   living in the Sitar model (`model/`, *not* the cpp core, which stays
   timing-agnostic per the original design goal). Default latency = 1
   cycle for all opcodes unless overridden. Modify the Sitar code to add
   this per-opcode delay in cycles, *in addition to* whatever memory
   latency is separately incurred for memory-referencing instructions.

6. **`MemoryInterfaceThread` delay parameter.** Add a configurable delay
   (default 0), on the core side, so that even a directly-connected
   ("instantaneous") memory can have an access latency modeled without
   needing a real memory/cache module behind it.

7. **Three testbench configurations for the full Sitar model:**
   1. **Tightly coupled**: core + `MemCore` connected directly through
      `MemoryInterfaceThread` in `DIRECT_INTERFACE_TO_MEM` mode -- no
      ports/nets (this is the current/only configuration today).
   2. **Loosely coupled via ports**: a new `Memory.sitar` wrapping
      `MemCore`, communicating with `MemoryInterfaceThread` through
      ports/nets instead of a direct pointer, adding >=1 cycle of
      communication latency each way.
   3. **Core with split I/D caches**: core + separate instruction and
      data caches (connected via `MemoryInterfaceThread`), which in turn
      talk to an external memory over ports/nets. A model along these
      lines already exists in an older/v1 version of Sitar -- reuse/adapt
      the cache models from there rather than writing new ones from
      scratch.

# Next Steps / TODOs

For day-to-day, granular progress tracking, see `TODO.md` at the repo
root. This page summarizes the larger, still-open directions.

---

## Bare-metal C test suite

`validation/C/` is planned but not yet populated -- programs exercising
sequences of operations together (matrix multiply, compound data types)
rather than one opcode at a time, complementing `validation/asm/`'s
instruction-level coverage. See
[Writing and Running C Programs](writing_and_running_c_programs.md) for
the intended approach and current toolchain status.

## Remaining Sitar testbench configurations

The current Sitar model (`model/sitar_model/`) tightly couples
`SparcThread` to `MainMemory` via a shared struct and a same-phase
handshake (see [Model Components](model_components.md)). Two further
configurations are planned:

1. **Loosely coupled via ports** -- a variant wrapping `MemCore` behind
   real Sitar module ports/nets instead of the parallel-block handshake,
   adding at least one cycle of communication latency each way (as
   opposed to `MemoryInterface.delay`, which approximates latency without
   an actual port connection).
2. **Split instruction/data caches** -- core plus separate I/D caches,
   each a `MainMemory`-like persistent procedure, connected the same way
   `MainMemory` is today, in turn talking to an external memory over
   ports/nets. This is also the planned worked example for
   [Connecting other components](model_components.md#connecting-other-components).

## MMU, caches, and peripherals

This repository models the core only (see
[What this project offers](index.md#what-this-project-offers)). A
full SoC-level model built around this core -- MMU, caches as persistent
components (not just the illustrative example above), peripherals/devices
-- is planned as a separate repository/version, rather than growing this
one beyond a core model.

## Opcode-wise test coverage

A systematic pass comparing the full SPARC V8 instruction set against
`validation/asm/` was completed, finding and filling several real gaps
(a reserved/unassigned opcode encoding distinct from `UNIMP`, `STDFQ`,
FSR exception subtypes beyond invalid-operation, `Ticc` trap-number
wraparound). `CPop1`/`CPop2` (coprocessor operate) remain untested
deliberately -- this model has no coprocessor at all yet, so they're
deferred to whenever coprocessor support is added (see "MMU, caches, and
peripherals" above; a coprocessor is architecturally the same kind of
addition).

## Documentation

This documentation site itself -- expect it to keep growing, particularly
the [Connecting other components](model_components.md#connecting-other-components)
worked example once the split I/D-cache testbench above exists.

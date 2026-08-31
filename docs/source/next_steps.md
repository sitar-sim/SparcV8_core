# Next Steps / TODOs

For day-to-day, granular progress tracking, see `TODO.md` at the repo
root. This page summarizes the larger, still-open directions.

---

## Remaining Sitar testbench configurations

`SparcThread` talks to `VirtualMainMemory` (core_only) or `Mmu`
(core_mmu) via a shared struct and a same-phase handshake (see [Model
Components](model_components.md)). `core_mmu`'s MMU-to-memory link is
different: `PhysicalMainMemory` is a module, reached over real Sitar
ports and nets, adding Sitar's own unavoidable minimum one cycle of
latency each way. This is `Plan_SoC_Integration_Roadmap.md`'s
phased-development stage 2, done. See [Model
Configurations](model_configurations.md) for the block diagram.

One further configuration is planned:

- **Split instruction/data caches**. Core plus separate I/D caches, each
  a `VirtualMainMemory`/`PhysicalMainMemory`-like persistent component,
  connected the same way, in turn talking to an external memory over
  ports/nets. This is also the planned worked example for [Connecting
  other components](model_components.md#connecting-other-components).

## MMU, caches, and peripherals

The plan is to grow this repository into a fuller SoC-level model built
around the core (see `Plan_SoC_Integration_Roadmap.md`), rather than a
separate repository or version. The MMU (Ref Appendix H) is implemented
and validated, in a `core_mmu` configuration alongside the existing
`core_only` one. See `Plan_MMU_integration.md` and
`model/cpp_common_code/mmu/README.md`. L1 caches (as persistent
components, not just the illustrative example above) and peripherals
(timer, interrupt controller, serial) are still planned, not yet built.
See `Plan_Devices_integration.md` and `Plan_Caches_integration.md`.

## Opcode-wise test coverage

A systematic pass comparing the full SPARC V8 instruction set against
`validation/asm/` was completed, finding and filling several real gaps
(a reserved/unassigned opcode encoding distinct from `UNIMP`, `STDFQ`,
FSR exception subtypes beyond invalid-operation, `Ticc` trap-number
wraparound). `CPop1`/`CPop2` (coprocessor operate) remain untested
deliberately. This model has no coprocessor at all yet, so they're
deferred to whenever coprocessor support is added. See "MMU, caches, and
peripherals" above. A coprocessor is architecturally the same kind of
addition.

## Documentation

This documentation site itself is expected to keep growing, particularly
the [Connecting other components](model_components.md#connecting-other-components)
worked example once the split I/D-cache testbench above exists.

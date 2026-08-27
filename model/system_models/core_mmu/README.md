# system_models/core_mmu/

The SPARC V8 core connected to an MMU and main memory, no devices or
caches yet (Ref `Plan_SoC_Integration_Roadmap.md`'s "Phased development
order", stage 1).

- **`cpp_model/`** -- the 0-delay functional driver, implemented. See
  `cpp_model/README.md`.
- **`sitar_model/`** -- the Sitar-timed driver, implemented: `MmuUnit`
  (Ref `../../sitar_component_models/MmuUnit.sitar`) sits between
  `SparcThread` and `MainMemoryPA` as a real, independently-scheduled
  procedure, connected by the same procedure handshake `MainMemory`
  connects with today, per stage 1 -- converting that link to ports/nets
  is stage 2, planned in `Plan_Devices_integration.md`. See
  `sitar_model/README.md`.

See `Plan_MMU_integration.md` for the full plan and status.

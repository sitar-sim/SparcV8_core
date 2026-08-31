# system_models/core_mmu/

The SPARC V8 core connected to an MMU and main memory, no devices or
caches yet (Ref `Plan_SoC_Integration_Roadmap.md`'s "Phased development
order", stages 1-2).

- **`cpp_model/`** -- the 0-delay functional driver. See
  `cpp_model/README.md`.
- **`sitar_model/`** -- the Sitar-timed driver. `Mmu` (Ref
  `../../sitar_component_models/Mmu.sitar`) sits between `SparcThread`
  and `PhysicalMainMemory`. `SparcThread` talks to the MMU over a
  procedure handshake; the MMU talks to physical memory over real Sitar
  ports and nets. See `docs/source/model_configurations.md` for the
  block diagram, and `sitar_model/README.md` for the full breakdown.

See `Plan_MMU_integration.md` for the full plan and status.

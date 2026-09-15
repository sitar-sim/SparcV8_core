# system_models/core_mmu/

The SPARC V8 core connected to an MMU and main memory, no devices or
caches yet.

- **`cpp_model/`** -- the 0-delay functional driver. See
  `cpp_model/README.md`.
- **`sitar_model/`** -- the Sitar-timed driver. `Mmu` (Ref
  `../../sitar_component_models/Mmu.sitar`) sits between `SparcThread`
  and `PhysicalMainMemory`. `SparcThread` talks to the MMU over a
  procedure handshake; the MMU talks to physical memory over real Sitar
  ports and nets. See [Model
  Configurations](https://sitar-sim.github.io/SparcV8_core/model_configurations.html)
  for the block diagram, and `sitar_model/README.md` for the full
  breakdown.

See [Model
Components](https://sitar-sim.github.io/SparcV8_core/model_components.html#mmu)
for what the MMU implements.

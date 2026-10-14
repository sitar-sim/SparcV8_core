# system_models/core_l1cache_mmu_devices/

The SPARC V8 core with split L1 instruction and data caches, an MMU,
main memory, and the
[peripheral devices](https://sitar-sim.github.io/SparcV8_core/peripheral_devices.html).
The full single-core system: the core reaches the caches, the caches
reach the MMU on a miss, and below the MMU everything is as in
`core_mmu_devices/`.

- **`cpp_model/`** -- the 0-delay functional driver:
  `SparcStateMachine` -> `L1CachesCore` -> `MmuCore` -> `SystemBus`.
- **`sitar_model/`** -- the Sitar-timed driver: `L1Caches` sits between
  `SparcThread` and `Mmu` inside `Core`, so a cache hit needs no net
  crossing at all.

Both accept the cache options `--icache-lines`, `--icache-ways`,
`--dcache-lines`, `--dcache-ways` and `--always-cacheable`, besides
`core_mmu_devices`' own serial and timer options. See [Model
Components](https://sitar-sim.github.io/SparcV8_core/model_components.html#caches)
for what the caches do, and `validation/C/caches/` for their tests.

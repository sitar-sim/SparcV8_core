# sparc_apara/

The SPARC core of `core_l1cache_mmu_devices` (L1 caches, MMU, peripheral
devices) plus one APARA engine, with the system's physical addresses in
SystemAddressMap's AJIT_APARA layout: the engine's DMEM, control-unit and
DMA registers appear in the SPARC's physical address space, and the
engine's DMA and its own off-island accesses reach main memory.

- **`cpp_model/`** -- the 0-delay functional driver (`AparaSystemCore` on
  the `SystemBus`). See `cpp_model/README.md`.
- **`sitar_model/`** -- the Sitar-timed driver (`AparaEngine` and
  `AparaHost` beside the core, on a two-master `SystemInterconnect`).
  See `sitar_model/README.md`.

Same command line and test format as the other SPARC configurations.
Tests: `validation/sparc_apara/` (and every other SPARC suite: `validation/run_tests.py validation --config sparc_apara`). See [The Engine in
a System](https://sitar-sim.github.io/SparcV8_core/apara/system.html)
for the SPARC program's view of the engine.

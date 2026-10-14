# sparc_apara/

The SPARC core of `core_l1cache_mmu_devices` (L1 caches, MMU, peripheral
devices) plus one APARA engine, with the system's physical addresses in
SystemAddressMap's AJIT_APARA layout: the engine's DMEM, control-unit and
DMA registers appear in the SPARC's physical address space, and the
engine's DMA and its own off-island accesses reach main memory.

- **`cpp_model/`** -- the functional model (`AparaSystemCore` on the
  `SystemBus`).
- **`sitar_model/`** -- the timing model (`AparaEngine` and `AparaHost`
  beside the core, on a two-master `SystemInterconnect`).

Same command line and test format as the other SPARC configurations.
Tests: `validation/C/apara/` (and every other suite). See the
documentation's "The Engine in a System" page.

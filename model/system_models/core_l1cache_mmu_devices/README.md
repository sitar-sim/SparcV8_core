# system_models/core_l1cache_mmu_devices/

Planned configuration: the SPARC V8 core, split L1 instruction and data
caches, an [MMU](https://sitar-sim.github.io/SparcV8_core/model_components.html#mmu),
main memory, and the [peripherals](https://sitar-sim.github.io/SparcV8_core/peripheral_devices.html)
(timer, interrupt controller, serial device). The full stack: core
connects to the [caches](https://sitar-sim.github.io/SparcV8_core/model_components.html#caches-planned),
the caches connect to the MMU on a miss, and the MMU connects to the
same ports-and-nets bus `core_mmu_devices/` uses. This is one of the
three target testbench tiers. Not yet implemented.

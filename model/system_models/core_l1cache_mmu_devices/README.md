# system_models/core_l1cache_mmu_devices/

Planned configuration: the SPARC V8 core, split L1 instruction and data
caches, an MMU, main memory, and the peripherals (timer, interrupt
controller, serial device). The full stack: core connects to the caches,
the caches connect to the MMU on a miss, and the MMU connects to the same
ports-and-nets bus `core_mmu_devices/` uses (see
`../../../Plan_SoC_Integration_Roadmap.md`'s "Phased development order",
stage 4). This is one of the three target testbench tiers. Not yet
implemented -- see `../../../Plan_MMU_integration.md`,
`../../../Plan_Devices_integration.md`, and
`../../../Plan_Caches_integration.md` for the plan.

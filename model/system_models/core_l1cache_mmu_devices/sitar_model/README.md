# core_l1cache_mmu_devices/sitar_model/

The Sitar-timed driver for this configuration. The same four modules as
`core_mmu_devices/sitar_model/`, with `caches`
(`../../../sitar_component_models/L1Caches.sitar`) added inside `Core`,
between `sparcThread` and `mmu`. A hit is a same-phase procedure
handshake, so it costs only the hit-latency knob (default 0). A miss
costs the MMU's own time plus the eight doubleword transactions of the
line read, through the bridge.

```sh
./build.sh
./run_simple_test.sh
./executable/sparc_sim_sitar_core_l1cache_mmu_devices <program.hex> [expected] [max_cycles] [--stats] \
    [--icache-lines <n>] [--icache-ways <n>] [--dcache-lines <n>] [--dcache-ways <n>] [--always-cacheable] ...
```

The cache knobs (`icacheHitDelay`, `dcacheHitDelay`, `fillDelay`) are in
`src/System.sitar`'s consolidated knob block.

# core_l1cache_mmu_devices/cpp_model/

The 0-delay functional driver for this configuration. The same as
`core_mmu_devices/cpp_model/`, plus `L1CachesCore`
(`../../../cpp_common_code/cache/`) between `SparcStateMachine` and the
MMU. The caches' tags use the MMU's current context.

```sh
./build.sh
./run_simple_test.sh
./executable/sparc_sim_cpp_core_l1cache_mmu_devices <program.hex> [expected] [max_cycles] [--stats] \
    [--icache-lines <n>] [--icache-ways <n>] [--dcache-lines <n>] [--dcache-ways <n>] [--always-cacheable] \
    [--serial-in <file>] [--serial-out <file>] [--serial-pty] [--timer-tick-divider <n>]
```

`--stats` adds both caches' hit/miss/fill counts. `SPARC_ALWAYS_CACHEABLE=1`
in the environment does the same as `--always-cacheable`, which is how a
whole test suite is run with caching on.

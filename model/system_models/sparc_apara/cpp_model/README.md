# sparc_apara/cpp_model/

The 0-delay functional driver for this configuration. The same as
`core_l1cache_mmu_devices/cpp_model/`, plus one APARA engine,
`AparaSystemCore` (`../../../cpp_common_code/apara/`: the engine, its
control unit, and its DMA unit), attached to the `SystemBus`. The bus
routes the SPARC's accesses to the engine's three windows to it, and the
engine's DMA transfers and its own loads and stores outside its DMEM go
back through the same bus. After every SPARC instruction, the engine
runs one bundle, its DMA unit moves one piece of a copy (up to 8 bytes),
and its interrupt drives the Interrupt Controller's IRL 14 input.

```sh
./build.sh
./run_simple_test.sh
./executable/sparc_sim_cpp_sparc_apara <program.hex> [expected] [max_cycles] [--stats] \
    [--icache-lines <n>] [--icache-ways <n>] [--dcache-lines <n>] [--dcache-ways <n>] [--always-cacheable] \
    [--serial-in <file>] [--serial-out <file>] [--serial-pty] [--timer-tick-divider <n>]
```

`--stats` adds the number of bundles the engine ran. See [The Engine in
a System](https://sitar-sim.github.io/SparcV8_core/apara/system.html),
and `validation/C/apara/` for the tests.

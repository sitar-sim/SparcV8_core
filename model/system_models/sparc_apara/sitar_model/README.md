# sparc_apara/sitar_model/

The Sitar-timed driver for this configuration. The same modules as
`core_l1cache_mmu_devices/sitar_model/`, plus the APARA engine's two:
`engine` (`AparaEngine`, the engine's five-stage pipeline, as in the
`apara` configuration) and `host` (`AparaHost`, its control unit and DMA
unit). The bus becomes a `SystemInterconnect` with two masters, the
core and `host`, taken round robin. `host` reaches the engine's state,
in `engine.exec`, over five nets of its own.

```sh
./build.sh
./run_simple_test.sh
./executable/sparc_sim_sitar_sparc_apara <program.hex> [expected] [max_cycles] [--stats] \
    [--icache-lines <n>] [--icache-ways <n>] [--dcache-lines <n>] [--dcache-ways <n>] [--always-cacheable] ...
```

Every latency knob, the engine's included, is in `src/System.sitar`'s
consolidated knob block. `--stats` adds the engine's pipeline counters.
See [The Engine in a
System](https://sitar-sim.github.io/SparcV8_core/apara/system.html), and
its [Modules and
nets](https://sitar-sim.github.io/SparcV8_core/apara/system.html#modules-and-nets)
for the block diagram.

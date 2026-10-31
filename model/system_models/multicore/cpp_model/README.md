# multicore/cpp_model/

The 0-delay functional driver for this configuration. NUM_CORES copies
of `core_l1cache_mmu_devices/cpp_model/`'s island (`SparcStateMachine`
-> `L1CachesCore` -> `MmuCore`), all on one `SystemBus`.

```sh
./build.sh
./executable/sparc_sim_cpp_multicore <program.hex> [expected] [max_cycles] [--stats] \
    [--schedule <spec>] [--run-cores <m>] \
    [--icache-lines <n>] [--icache-ways <n>] [--dcache-lines <n>] [--dcache-ways <n>] [--always-cacheable] \
    [--serial-in <file>] [--serial-out <file>] [--serial-pty] [--timer-tick-divider <n>]
```

| File | What |
|---|---|
| `src/MulticoreConfig.h` | The compile-time knobs, `NUM_CORES` and `COHERENT`. |
| `src/Scheduler.h` / `.cpp` | How the cores are interleaved: rounds of turns, and the `rr:K`, `rr-fixed:K` and `random:SEED[:MAXTURN]` strategies. Also defines what a model cycle is here. |
| `src/sparc_sim.cpp` | Builds the system, runs the rounds, ticks the devices, and checks expected results per core. |

- **`--schedule <spec>`** picks the interleaving strategy (default
  `rr:1`). `SPARC_SCHEDULE` in the environment does the same.
- **`--run-cores <m>`** runs only cores 0 to m-1. The others never
  leave reset and count as halted. `SPARC_RUN_CORES` in the
  environment does the same, which is how the whole single-core suite
  is run on this configuration:
  `SPARC_RUN_CORES=1 validation/run_tests.py validation --config multicore`.
- **`--stats`** prints each core's counters, then the shared memory's
  and devices' counters.

With `--logging` builds, core 0's trace goes to `<program>.log` and core
`i`'s to `<program>.core<i>.log`.

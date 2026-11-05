# multicore/sitar_model/

The Sitar-timed driver for this configuration. `System` holds
`NUM_CORES` copies of `Core` (a `submodule_array`), each the
`core_l1cache_mmu_devices` core with its L1 caches and MMU, a
`CoherentBridge` (`../../../sitar_component_models/CoherentBridge.sitar`)
below their MMUs, and one `PhysicalMainMemory` and one
`PeripheralDevices`, connected by nets:

| Net | From | To |
|---|---|---|
| `coreRequestNet[i]` | `cores[i].requestOut` | `bridge.coreRequestIn[i]` |
| `coreResponseNet[i]` | `bridge.coreResponseOut[i]` | `cores[i].responseIn` |
| `interruptLevelNet[i]` | `devices.interruptLevelOut[i]` | `cores[i].interruptLevelIn` |
| `memoryRequestNet` / `memoryResponseNet` | `bridge` | `mainMemory`, and back |
| `devicesRequestNet` / `devicesResponseNet` | `bridge` | `devices`, and back |

Each core runs on its own, one instruction per cycle at most, and the
cores meet only at the bridge. The bridge serves one request at a time,
granting the cores round-robin, with `SystemBridge`'s timing, so with
one core running the timing is exactly `core_l1cache_mmu_devices`'. The
bridge also locks the bus from an `LDSTUB` or `SWAP`'s read to its write,
which makes those instructions atomic across cores.

The compile-time knobs `NUM_CORES` (default 4) and `COHERENT` (only
`false` so far) are `System`'s parameters, in `src/System.sitar`, next to
every latency knob. Unlike the single-core `Core.sitar`, a halted core
does not stop the simulation. `System` stops it once every running core
has halted.

```sh
./build.sh
./run_simple_test.sh
./executable/sparc_sim_sitar_multicore <program.hex> [expected] [max_cycles] [--stats] [--run-cores <m>] \
    [--icache-lines <n>] [--icache-ways <n>] [--dcache-lines <n>] [--dcache-ways <n>] [--always-cacheable] ...
```

`--run-cores <m>` (or `SPARC_RUN_CORES`) holds cores m and up in reset
(their RESET pin stays high). `--stats` adds the bridge's transaction
count per core, and the number of locked read-write pairs.

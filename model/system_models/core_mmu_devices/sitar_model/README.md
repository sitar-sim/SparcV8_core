# core_mmu_devices/sitar_model/

The Sitar-timed driver for this configuration. `System.sitar` assembles
four sibling modules, connected by nets:

- `core` (`src/Core.sitar`): `SparcThread` and `Mmu`, as in
  `core_mmu`, plus one branch that polls the interrupt-level net once
  per cycle and drives the level onto the core's IRL input pins;
- `bridge` (`../../../sitar_component_models/SystemBridge.sitar`):
  routes each physical access to memory or to the devices;
- `mainMemory` (`PhysicalMainMemory.sitar`);
- `devices` (`PeripheralDevices.sitar`): embeds the same
  `PeripheralDevicesCore` the cpp_model uses, ticks it once per cycle,
  services register accesses, and sends the interrupt level to `core`.

Every net crossing costs at least one cycle, so a memory access costs 2
cycles more than in `core_mmu` (four nets crossed instead of two), and
an interrupt reaches the core one cycle after it is raised.
`System.sitar`'s `init` block lists every latency knob in this
configuration in one place.

## How to run it

```sh
./build.sh
./run_simple_test.sh
./executable/sparc_sim_sitar_core_mmu_devices <program.hex> [expected] [max_cycles] [--stats] \
    [--serial-in <file>] [--serial-out <file>] [--serial-pty] [--timer-tick-divider <n>]
```

The options mean the same as for this configuration's cpp_model.

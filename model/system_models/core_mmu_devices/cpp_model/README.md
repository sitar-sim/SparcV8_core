# core_mmu_devices/cpp_model/

The 0-delay functional driver for this configuration. The same as
`core_mmu/cpp_model/`, except that the MMU's downstream target is a
`SystemBus` (`../../../cpp_common_code/SystemBus.h`) instead of a plain
`MainMemory`. The bus routes each physical address, by
`SystemAddressMap.h`, either to `MainMemory` or to the shared
`PeripheralDevicesCore` (`../../../cpp_common_code/devices/`).

After every core cycle the devices tick once
(`SparcStateMachine::afterEachCycle`), and the Interrupt Controller's
level for this core's thread slot (core 0, thread 0) is driven onto the
core's IRL input pins, sampled on the next cycle.

## What's what

- **`src/sparc_sim.cpp`** -- this configuration's entry point.
- **`build.sh`** -- thin wrapper around the shared
  `../../../build_scripts/build_cpp_model.sh` (`--logging`, `--debug`,
  `--debug-o0`).
- **`run_simple_test.sh`** -- runs the default build against the
  bundled `test_simple_ADD` example, which touches no device.
- **`executable/`** -- gitignored build output.

## How to run it

```sh
./build.sh
./run_simple_test.sh
./executable/sparc_sim_cpp_core_mmu_devices <program.hex> [expected] [max_cycles] [--stats] \
    [--serial-in <file>] [--serial-out <file>] [--serial-pty] [--timer-tick-divider <n>]
```

Transmitted serial bytes go to standard output unless `--serial-out` is
given. See the [Serial
Device](https://sitar-sim.github.io/SparcV8_core/peripheral_devices_serial_device.html)
page for the serial options.

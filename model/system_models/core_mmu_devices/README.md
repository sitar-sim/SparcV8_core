# system_models/core_mmu_devices/

The SPARC V8 core with an MMU, main memory, and the
[peripheral devices](https://sitar-sim.github.io/SparcV8_core/peripheral_devices.html)
(Timer, Serial, Interrupt Controller). The devices are one shared set
on the memory side of the MMU, reached by physical address like main
memory, the same way the AJIT processor organizes them.

- **`cpp_model/`** -- the 0-delay functional driver. The MMU's
  downstream target is a `SystemBus` (`../../cpp_common_code/SystemBus.h`),
  which routes each physical access to `MainMemory` or to
  `PeripheralDevicesCore` (`../../cpp_common_code/devices/`). See
  `cpp_model/README.md`.
- **`sitar_model/`** -- the Sitar-timed driver. Below the core's MMU
  sits a `SystemBridge` module, which routes each access over nets to
  `PhysicalMainMemory` or to the `PeripheralDevices` module. The
  Interrupt Controller reaches the core over its own net. See
  `sitar_model/README.md`.

See [Model
Configurations](https://sitar-sim.github.io/SparcV8_core/model_configurations.html)
for the block diagram, and `validation/C/devices/` for the device tests.

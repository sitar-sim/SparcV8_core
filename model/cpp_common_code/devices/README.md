# cpp_common_code/devices/

The peripheral devices, as plain C++ classes with no notion of timing,
shared unchanged by every driver (cpp_model and sitar_model). See the
[Peripheral Devices](https://sitar-sim.github.io/SparcV8_core/peripheral_devices.html)
pages for what each device does.

| File | What |
|---|---|
| `DeviceAddresses.h` | Register addresses (AJIT's default device map), bit fields, interrupt levels, and the register access convention every device class follows. |
| `TimerCore.h` / `.cpp` | The one-shot timer. |
| `SerialCore.h` / `.cpp` | The serial device (UART), its Tx and Rx state machines. |
| `SerialBackend.h` / `.cpp` | Where serial bytes go and come from: console, files, or a pty, chosen at run time. |
| `InterruptControllerCore.h` / `.cpp` | AJIT's multi-thread interrupt controller: 8 thread slots plus the IPI registers. |
| `PeripheralDevicesCore.h` / `.cpp` | The system's single shared set of the three devices: bus adaptation (doubleword physical requests to word registers), pin wiring, and per-cycle ticking. Implements `PhysicalMemoryInterface`. |

## Register access convention

Every device class takes register accesses as `(word address, 4-bit
lane mask, 32-bit data)`, exactly AJIT's own peripheral access shape:
bit `i` of the mask selects bits `[8i+7:8i]` of the word, and bit 3 is
the most significant byte, at the lowest address (big-endian). A byte
store to Tx at `0xFFFF3204` arrives as mask `0x8` with the byte in
bits `[31:24]`. `PeripheralDevicesCore` does the adaptation from the
doubleword-shaped physical bus once, for every device.

## Tests

`tests/` holds one standalone unit test per device class, each built
and run on its own (the build line is in each file's header comment):
`test_timer.cpp`, `test_serial.cpp`, `test_interrupt_controller.cpp`.
They live one folder down so the model build scripts' one-level
`*/*.cpp` glob does not pick up their `main()`. Whole-system device
tests, run as SPARC programs, are in `validation/C/devices/`.

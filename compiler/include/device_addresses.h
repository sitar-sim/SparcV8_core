// device_addresses.h
//
// Physical addresses of the peripheral device registers, for bare-metal
// C programs. Same file name and macro names as AJIT's own
// device_addresses.h / default_device_addresses.h
// (tools/ajit_access_routines_mt/include/ in the ajit-toolchain repo),
// so code written for AJIT compiles here unchanged, and the same values,
// so it finds every device where it expects it.
//
// Only the devices this model implements are listed. See
// https://sitar-sim.github.io/SparcV8_core/peripheral_devices.html for
// the address map and each register's format. The model's own copy of
// these values is model/cpp_common_code/devices/DeviceAddresses.h.

#ifndef DEVICE_ADDRESSES_H
#define DEVICE_ADDRESSES_H

#define ADDR_IO_MIN 0xFFFF0000
#define ADDR_IO_MAX 0xFFFFFFFF

// Interrupt Controller: one control register per hardware thread,
// at ADDR_INTERRUPT_CONTROLLER_MIN + 4*((2*core_id) + thread_id),
// followed by the inter-processor interrupt (IPI) registers.
#define ADDR_INTERRUPT_CONTROLLER_MIN              (ADDR_IO_MIN + 0x3000)
#define ADDR_INTERRUPT_CONTROLLER_CONTROL_REGISTER (ADDR_IO_MIN + 0x3000)
#define ADDR_INTERRUPT_CONTROLLER_IPI_BASE         (ADDR_IO_MIN + 0x3080)
#define ADDR_INTERRUPT_CONTROLLER_MAX              (ADDR_IO_MIN + 0x30FF)

// Timer
#define ADDR_TIMER_MIN              (ADDR_IO_MIN + 0x3100)
#define ADDR_TIMER_CONTROL_REGISTER (ADDR_IO_MIN + 0x3100)
#define ADDR_TIMER_MAX              (ADDR_IO_MIN + 0x311c)

// Serial device. Tx and Rx are byte registers.
#define ADDR_SERIAL_MIN                     (ADDR_IO_MIN + 0x3200)
#define ADDR_SERIAL_CONTROL_REGISTER        (ADDR_IO_MIN + 0x3200)
#define ADDR_SERIAL_TX_REGISTER             (ADDR_IO_MIN + 0x3204)
#define ADDR_SERIAL_RX_REGISTER             (ADDR_IO_MIN + 0x3208)
#define ADDR_SERIAL_BAUD_CONTROL_REGISTER   (ADDR_IO_MIN + 0x320c)
#define ADDR_SERIAL_BAUD_LIMIT_REGISTER     (ADDR_IO_MIN + 0x320c)
#define ADDR_SERIAL_BAUD_FREQUENCY_REGISTER (ADDR_IO_MIN + 0x3210)
#define ADDR_SERIAL_MAX                     (ADDR_IO_MIN + 0x3213)

// Interrupt levels of each source.
#define TIMER_IRL    10
#define IPI_IRL      11
#define SERIAL_IRL   12
#define EXTERNAL_IRL 14

#endif

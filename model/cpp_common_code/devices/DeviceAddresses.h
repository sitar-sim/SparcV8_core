//DeviceAddresses.h
//
//Peripheral device register addresses and bit-field layouts. See
//https://sitar-sim.github.io/SparcV8_core/peripheral_devices.html for
//the full device address map.
//
//Addresses follow AJIT's default device map
//(tools/ajit_access_routines_mt/include/default_device_addresses.h in
//the ajit-toolchain repo, branch marshal), so that software written
//for AJIT finds every device where it expects it.
//
//Register access convention, shared by every device class: a register
//is addressed by its word-aligned address, with a 4-bit byte-lane mask
//over that 32-bit word (bit i selects bits [8i+7:8i], so bit 3 is the
//most significant byte, which sits at the lowest address, big-endian)
//and the data in its natural lanes. This is exactly the shape of
//AJIT's own peripheral access command, and the same nibble convention
//MemCore::mergeMaskedBytes() already uses. A byte store to the Serial
//Tx register at 0xFFFF3204, for example, arrives as mask 0x8 with the
//byte in bits [31:24].

#ifndef DEVICE_ADDRESSES_H
#define DEVICE_ADDRESSES_H

#include <stdint.h>

namespace DeviceAddress
{
	//Interrupt Controller: one control register per hardware thread
	//slot, at INTERRUPT_CONTROLLER_MIN + 4*slot, where
	//slot = 2*core_id + thread_id (Ref InterruptControllerCore.h), then
	//the IPI register block.
	const uint32_t INTERRUPT_CONTROLLER_MIN = 0xFFFF3000;
	const uint32_t INTERRUPT_CONTROLLER_MAX = 0xFFFF30FF;
	const uint32_t IPI_BASE                 = 0xFFFF3080;

	const uint32_t TIMER_MIN     = 0xFFFF3100;
	const uint32_t TIMER_CONTROL = 0xFFFF3100;
	const uint32_t TIMER_MAX     = 0xFFFF311F;

	const uint32_t SERIAL_MIN            = 0xFFFF3200;
	const uint32_t SERIAL_CONTROL        = 0xFFFF3200;
	const uint32_t SERIAL_TX             = 0xFFFF3204; //byte
	const uint32_t SERIAL_RX             = 0xFFFF3208; //byte
	const uint32_t SERIAL_BAUD_LIMIT     = 0xFFFF320C;
	const uint32_t SERIAL_BAUD_FREQUENCY = 0xFFFF3210;
	const uint32_t SERIAL_MAX            = 0xFFFF3213;
}

namespace TimerControlBits
{
	const uint32_t EN_BIT             = 0;
	const uint32_t MAX_COUNT_LOW_BIT  = 1;
	const uint32_t MAX_COUNT_HIGH_BIT = 31;
}

namespace SerialControlBits
{
	const uint32_t TX_EN_BIT               = 0;
	const uint32_t RX_EN_BIT               = 1;
	const uint32_t RX_INTERRUPT_ENABLE_BIT = 2;
	const uint32_t TX_FULL_BIT             = 3; //read-only
	const uint32_t RX_FULL_BIT             = 4; //read-only
	const uint32_t UART_RESET_BIT          = 5;
}

//Interrupt levels (IRL) of each interrupt source, Ref
//peripheral_devices.md's "Interrupt levels" table.
namespace InterruptLevel
{
	const uint32_t TIMER    = 10;
	const uint32_t IPI      = 11;
	const uint32_t SERIAL   = 12;
	const uint32_t EXTERNAL = 14;
}

#endif

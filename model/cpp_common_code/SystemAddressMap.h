//SystemAddressMap.h
//
//Which target a physical address belongs to, below the MMU: main
//memory, the peripheral devices, or nothing. One table shared by every
//driver and configuration that has a physical bus with more than one
//target, so the cpp_model's SystemBus and the sitar_model's
//SystemBridge can never disagree about where an address goes.
//
//The peripheral window matches AJIT's (0xFFFF0000 to 0xFFFFFFFF, Ref
//AJIT's default_device_addresses.h). Individual device registers inside
//it are decoded by PeripheralDevicesCore.

#ifndef SYSTEM_ADDRESS_MAP_H
#define SYSTEM_ADDRESS_MAP_H

#include <stdint.h>
#include "MemCore.h"

namespace SystemAddressMap
{
	enum class Target { MAIN_MEMORY, PERIPHERAL_DEVICES, UNMAPPED };

	const uint64_t MAIN_MEMORY_MIN        = 0x0;
	const uint64_t MAIN_MEMORY_MAX        = (uint64_t) MemCore::memSize - 1;
	const uint64_t PERIPHERAL_DEVICES_MIN = 0xFFFF0000ULL;
	const uint64_t PERIPHERAL_DEVICES_MAX = 0xFFFFFFFFULL;

	inline Target decode(uint64_t physicalAddress)
	{
		if (physicalAddress <= MAIN_MEMORY_MAX)
			return Target::MAIN_MEMORY;
		if (physicalAddress >= PERIPHERAL_DEVICES_MIN && physicalAddress <= PERIPHERAL_DEVICES_MAX)
			return Target::PERIPHERAL_DEVICES;
		return Target::UNMAPPED;
	}
}

#endif

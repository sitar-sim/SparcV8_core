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
//
//Two layouts. FLAT (every configuration without an APARA engine): main
//memory and the devices. AJIT_APARA: also APARA engines, each with three
//windows (Ref the APARA parameter template), for cluster c, engine e:
//  DMEM           0x0100_0000 + c*0x40000 + e*0x10000, 64 KB (taking
//                 that part of main memory's range)
//  CCU registers  0xFFFE_0000 + c*0x200 + e*0x80, 128 bytes
//  DMA registers  0xFFFE_2000 + c*0x200 + e*0x80, 128 bytes
//The layout is chosen once, by the configuration's driver, before the
//run (layout()), and read only afterwards. Only main memory is ever
//cacheable (Ref MmuCore::isCacheableTarget()).

#ifndef SYSTEM_ADDRESS_MAP_H
#define SYSTEM_ADDRESS_MAP_H

#include <stdint.h>
#include "MemCore.h"

namespace SystemAddressMap
{
	enum class Target { MAIN_MEMORY, PERIPHERAL_DEVICES, APARA_ENGINE, UNMAPPED };

	const uint64_t MAIN_MEMORY_MIN        = 0x0;
	const uint64_t MAIN_MEMORY_MAX        = (uint64_t) MemCore::memSize - 1;
	const uint64_t PERIPHERAL_DEVICES_MIN = 0xFFFF0000ULL;
	const uint64_t PERIPHERAL_DEVICES_MAX = 0xFFFFFFFFULL;

	const uint64_t APARA_DMEM_BASE  = 0x01000000ULL;
	const uint64_t APARA_DMEM_BYTES = 0x10000ULL;
	const uint64_t APARA_CCU_BASE   = 0xFFFE0000ULL;
	const uint64_t APARA_DMA_BASE   = 0xFFFE2000ULL;
	const uint64_t APARA_UNIT_BYTES = 0x80ULL;
	inline uint64_t aparaDmemBase(unsigned int c, unsigned int e) { return APARA_DMEM_BASE + c * 0x40000ULL + e * 0x10000ULL; }
	inline uint64_t aparaCcuBase(unsigned int c, unsigned int e)  { return APARA_CCU_BASE + c * 0x200ULL + e * 0x80ULL; }
	inline uint64_t aparaDmaBase(unsigned int c, unsigned int e)  { return APARA_DMA_BASE + c * 0x200ULL + e * 0x80ULL; }

	enum class Profile { FLAT, AJIT_APARA };
	struct Layout
	{
		Profile      profile           = Profile::FLAT;
		unsigned int clusters          = 1;
		unsigned int enginesPerCluster = 1;
	};
	inline Layout& layout() { static Layout l; return l; }

	//The engine (cluster * enginesPerCluster + engine) whose window holds
	//the address, or -1.
	inline int aparaEngineAt(uint64_t a)
	{
		const Layout& l = layout();
		if (l.profile != Profile::AJIT_APARA)
			return -1;
		for (unsigned int c = 0; c < l.clusters; c++)
			for (unsigned int e = 0; e < l.enginesPerCluster; e++)
			{
				if ((a >= aparaDmemBase(c, e) && a - aparaDmemBase(c, e) < APARA_DMEM_BYTES)
				    || (a >= aparaCcuBase(c, e) && a - aparaCcuBase(c, e) < APARA_UNIT_BYTES)
				    || (a >= aparaDmaBase(c, e) && a - aparaDmaBase(c, e) < APARA_UNIT_BYTES))
					return (int) (c * l.enginesPerCluster + e);
			}
		return -1;
	}

	inline Target decode(uint64_t physicalAddress)
	{
		if (aparaEngineAt(physicalAddress) >= 0)
			return Target::APARA_ENGINE;
		if (physicalAddress <= MAIN_MEMORY_MAX)
			return Target::MAIN_MEMORY;
		if (physicalAddress >= PERIPHERAL_DEVICES_MIN && physicalAddress <= PERIPHERAL_DEVICES_MAX)
			return Target::PERIPHERAL_DEVICES;
		return Target::UNMAPPED;
	}
}

#endif

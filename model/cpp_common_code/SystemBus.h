//SystemBus.h
//
//The cpp_model's physical bus below the MMU, for configurations with
//more than one physical target. Implements PhysicalMemoryInterface,
//the same interface MainMemory implements, so it drops in wherever an
//MmuCore expects a PhysicalMemoryInterface&, and MmuCore needs no
//change. Each request goes to the target SystemAddressMap::decode()
//names for its address.
//
//An address that maps to nothing reads as 0 and ignores writes, with a
//warning, the same way AJIT's bridge treats an unmapped address. It
//does not raise a memory access exception.
//
//The sitar_model counterpart is the SystemBridge module, which uses the
//same address map but adds timing.

#ifndef SYSTEM_BUS_H
#define SYSTEM_BUS_H

#include "MemoryInterfaces.h"
#include "MainMemory.h"
#include "PeripheralDevicesCore.h"

class SystemBus : public PhysicalMemoryInterface
{
	public:
		SystemBus(MainMemory& mainMemory, PeripheralDevicesCore& peripheralDevices);

		void access(const PhysicalMemoryRequest& request, PhysicalMemoryResponse& response) override;

		uint64_t unmappedAccesses;

	private:
		MainMemory&            mainMemory_;
		PeripheralDevicesCore& peripheralDevices_;
};

#endif

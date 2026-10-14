//PeripheralDevicesCore.cpp

#include "PeripheralDevicesCore.h"
#include "DeviceAddresses.h"
#include <iostream>
#include <sstream>

namespace
{
	bool inRange(uint32_t address, uint32_t min, uint32_t max)
	{
		return address >= min && address <= max;
	}
}

PeripheralDevicesCore::PeripheralDevicesCore() :
	timerTickDivider(1),
	externalInterruptIn(false),
	cyclesSinceTimerTick_(0)
{
}

uint32_t PeripheralDevicesCore::readWord(uint32_t wordAddress, uint8_t laneMask)
{
	if (inRange(wordAddress, DeviceAddress::TIMER_MIN, DeviceAddress::TIMER_MAX))
	{
		stats.timerAccesses++;
		return timer.readRegister(wordAddress, laneMask);
	}
	if (inRange(wordAddress, DeviceAddress::SERIAL_MIN, DeviceAddress::SERIAL_MAX))
	{
		stats.serialAccesses++;
		return serial.readRegister(wordAddress, laneMask);
	}
	if (inRange(wordAddress, DeviceAddress::INTERRUPT_CONTROLLER_MIN, DeviceAddress::INTERRUPT_CONTROLLER_MAX))
	{
		stats.interruptControllerAccesses++;
		return interruptController.readRegister(wordAddress, laneMask);
	}
	stats.unmappedAccesses++;
	std::cerr << "\nWarning: PeripheralDevicesCore: read of unmapped device address 0x"
	          << std::hex << wordAddress << std::dec << ", returning 0";
	return 0;
}

void PeripheralDevicesCore::writeWord(uint32_t wordAddress, uint8_t laneMask, uint32_t data)
{
	if (inRange(wordAddress, DeviceAddress::TIMER_MIN, DeviceAddress::TIMER_MAX))
	{
		stats.timerAccesses++;
		timer.writeRegister(wordAddress, laneMask, data);
	}
	else if (inRange(wordAddress, DeviceAddress::SERIAL_MIN, DeviceAddress::SERIAL_MAX))
	{
		stats.serialAccesses++;
		serial.writeRegister(wordAddress, laneMask, data);
	}
	else if (inRange(wordAddress, DeviceAddress::INTERRUPT_CONTROLLER_MIN, DeviceAddress::INTERRUPT_CONTROLLER_MAX))
	{
		stats.interruptControllerAccesses++;
		interruptController.writeRegister(wordAddress, laneMask, data);
	}
	else
	{
		stats.unmappedAccesses++;
		std::cerr << "\nWarning: PeripheralDevicesCore: write to unmapped device address 0x"
		          << std::hex << wordAddress << std::dec << " ignored";
	}
}

void PeripheralDevicesCore::access(const PhysicalMemoryRequest& request, PhysicalMemoryResponse& response)
{
	response.valid    = true;
	response.mae      = false;
	response.readData = 0;

	//Word 0 is the lower address (low 32 bits of data, low byteMask
	//nibble), word 1 the upper one, Ref MmuCore.cpp's packing convention.
	uint32_t base = (uint32_t) (request.physicalAddress & ~0x7ULL);
	uint8_t  mask = request.byteMask;
	if (request.accessType == PhysicalAccessType::READ && mask == 0)
		mask = 0xFF;

	for (int half = 0; half < 2; half++)
	{
		uint8_t laneMask = (mask >> (4 * half)) & 0xF;
		if (laneMask == 0)
			continue;

		uint32_t wordAddress = base + 4 * half;
		if (request.accessType == PhysicalAccessType::READ)
			response.readData |= ((uint64_t) readWord(wordAddress, laneMask)) << (32 * half);
		else
			writeWord(wordAddress, laneMask, (uint32_t) (request.data >> (32 * half)));
	}
}

void PeripheralDevicesCore::tick()
{
	cyclesSinceTimerTick_++;
	if (cyclesSinceTimerTick_ >= timerTickDivider)
	{
		cyclesSinceTimerTick_ = 0;
		timer.tick();
	}
	serial.tick();

	interruptController.timerIn    = timer.intOut;
	interruptController.serialIn   = serial.intOut;
	interruptController.externalIn = externalInterruptIn;
	interruptController.tick();
}

std::string PeripheralDevicesCore::Stats::toString() const
{
	std::ostringstream ss;
	ss << "\n Peripheral device accesses:"
	   << "\n\t timer                = " << timerAccesses
	   << "\n\t serial               = " << serialAccesses
	   << "\n\t interrupt controller = " << interruptControllerAccesses
	   << "\n\t unmapped             = " << unmappedAccesses
	   << "\n";
	return ss.str();
}

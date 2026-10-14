//InterruptControllerCore.cpp

#include "InterruptControllerCore.h"
#include "DeviceAddresses.h"
#include "../MemCore.h"
#include <iostream>

namespace
{
	const uint32_t ENABLE_BIT       = 0x1u;
	const uint32_t LEVEL_MASK_BITS  = 0xFFFEu; //[15:1]
	const uint32_t INTERRUPTING_BIT = 31;

	//Lowest set level in vector (bits 1..15), or 0 if none.
	uint32_t lowestLevel(uint32_t vector)
	{
		for (uint32_t level = 1; level <= 15; level++)
			if (vector & (1u << level))
				return level;
		return 0;
	}
}

InterruptControllerCore::InterruptControllerCore() :
	timerIn(false), serialIn(false), externalIn(false)
{
	for (int s = 0; s < NUM_SLOTS; s++)
		slots[s] = Slot{State::DISABLED, 0, 0};
	for (int w = 0; w < NUM_IPI_WORDS; w++)
		ipiWords[w] = 0;
}

uint32_t InterruptControllerCore::incomingVector(int slot) const
{
	uint32_t vector = 0;
	if (timerIn)    vector |= 1u << InterruptLevel::TIMER;
	if (serialIn)   vector |= 1u << InterruptLevel::SERIAL;
	if (externalIn) vector |= 1u << InterruptLevel::EXTERNAL;

	uint32_t ipiActive = ipiWords[0] & ipiWords[1];
	if ((ipiActive >> slot) & 1u)
		vector |= 1u << InterruptLevel::IPI;
	return vector;
}

uint32_t InterruptControllerCore::readRegister(uint32_t wordAddress, uint8_t laneMask)
{
	(void) laneMask; //a read returns the whole word, the requester picks its lanes
	uint32_t offset = wordAddress - DeviceAddress::INTERRUPT_CONTROLLER_MIN;

	if (offset < 4u * NUM_SLOTS)
	{
		int s = offset / 4;
		const Slot& slot = slots[s];
		return (slot.controlRegister & 0xFFFFu)
		     | ((incomingVector(s) >> 1) << 16) //IRL i at bit 15+i
		     | ((slot.state == State::INTERRUPTING ? 1u : 0u) << INTERRUPTING_BIT);
	}

	uint32_t ipiOffset = wordAddress - DeviceAddress::IPI_BASE;
	if (wordAddress >= DeviceAddress::IPI_BASE && ipiOffset < 4u * NUM_IPI_WORDS)
		return ipiWords[ipiOffset / 4];

	std::cerr << "\nWarning: InterruptControllerCore: read of unmapped address 0x"
	          << std::hex << wordAddress << std::dec << ", returning 0";
	return 0;
}

void InterruptControllerCore::writeRegister(uint32_t wordAddress, uint8_t laneMask, uint32_t data)
{
	uint32_t offset = wordAddress - DeviceAddress::INTERRUPT_CONTROLLER_MIN;

	if (offset < 4u * NUM_SLOTS)
	{
		Slot& slot = slots[offset / 4];
		slot.controlRegister = MemCore::mergeMaskedBytes(slot.controlRegister, data, laneMask);

		if (!(slot.controlRegister & ENABLE_BIT))
		{
			//Disable, from any state: drops the interrupt level.
			slot.state          = State::DISABLED;
			slot.interruptLevel = 0;
		}
		else if (slot.state == State::DISABLED)
		{
			slot.state          = State::ENABLED;
			slot.interruptLevel = 0;
		}
		//else: already ENABLED or INTERRUPTING, only the mask changed.
		return;
	}

	uint32_t ipiOffset = wordAddress - DeviceAddress::IPI_BASE;
	if (wordAddress >= DeviceAddress::IPI_BASE && ipiOffset < 4u * NUM_IPI_WORDS)
	{
		uint32_t& word = ipiWords[ipiOffset / 4];
		word = MemCore::mergeMaskedBytes(word, data, laneMask);
		return;
	}

	std::cerr << "\nWarning: InterruptControllerCore: write to unmapped address 0x"
	          << std::hex << wordAddress << std::dec << " ignored";
}

void InterruptControllerCore::tick()
{
	for (int s = 0; s < NUM_SLOTS; s++)
	{
		Slot& slot = slots[s];
		if (slot.state != State::ENABLED)
			continue;

		uint32_t level = lowestLevel(incomingVector(s) & slot.controlRegister & LEVEL_MASK_BITS);
		if (level != 0)
		{
			slot.interruptLevel = level;
			slot.state          = State::INTERRUPTING;
		}
	}
}

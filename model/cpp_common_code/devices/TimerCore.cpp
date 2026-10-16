//TimerCore.cpp
//Original Author: Neha Karanjkar
//Model Author: Claude Opus 5.5 (high)
//The model code was adapted from a Sparc v8 core simulation model written
//by the first author in C++ and Sitar (2015-2017).

#include "TimerCore.h"
#include "DeviceAddresses.h"
#include "../BitManipulation.h"
#include "../MemCore.h"
#include <iostream>

TimerCore::TimerCore() :
	state(State::DISABLED),
	controlRegister(0),
	count(0),
	maxCount(0),
	intOut(false)
{
}

uint32_t TimerCore::readRegister(uint32_t wordAddress, uint8_t laneMask)
{
	(void) laneMask; //a read returns the whole word, the requester picks its lanes

	if (wordAddress != DeviceAddress::TIMER_CONTROL)
	{
		std::cerr << "\nWarning: TimerCore: read of unmapped timer address 0x"
		          << std::hex << wordAddress << std::dec << ", returning 0";
		return 0;
	}
	return controlRegister;
}

void TimerCore::writeRegister(uint32_t wordAddress, uint8_t laneMask, uint32_t data)
{
	if (wordAddress != DeviceAddress::TIMER_CONTROL)
	{
		std::cerr << "\nWarning: TimerCore: write to unmapped timer address 0x"
		          << std::hex << wordAddress << std::dec << " ignored";
		return;
	}

	controlRegister = MemCore::mergeMaskedBytes(controlRegister, data, laneMask);
	bool enableBit = readBits(controlRegister, TimerControlBits::EN_BIT, TimerControlBits::EN_BIT);

	if (!enableBit)
	{
		//Disable, from any state.
		state    = State::DISABLED;
		intOut   = false;
		count    = 0;
		maxCount = 0;
	}
	else if (state == State::DISABLED)
	{
		state    = State::ENABLED;
		intOut   = false;
		count    = 0;
		maxCount = readBits(controlRegister, TimerControlBits::MAX_COUNT_HIGH_BIT,
		                    TimerControlBits::MAX_COUNT_LOW_BIT);
	}
	//else: already ENABLED or INTERRUPTING, the enable write changes nothing.
}

void TimerCore::tick()
{
	if (state != State::ENABLED)
		return;

	count++;
	if (count >= maxCount)
	{
		intOut = true;
		state  = State::INTERRUPTING;
	}
}

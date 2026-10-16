//SerialCore.cpp
//Original Author: Neha Karanjkar
//Model Author: Claude Opus 5.5 (high)
//The model code was adapted from a Sparc v8 core simulation model written
//by the first author in C++ and Sitar (2015-2017).

#include "SerialCore.h"
#include "DeviceAddresses.h"
#include "../BitManipulation.h"
#include "../MemCore.h"
#include <iostream>

namespace
{
	//Index (0..3) of the most significant lane selected in laneMask, or
	//3 if none is selected. Bit i of the mask is bits [8i+7:8i].
	unsigned int mostSignificantLane(uint8_t laneMask)
	{
		for (int lane = 3; lane >= 0; lane--)
			if (laneMask & (1u << lane))
				return (unsigned int) lane;
		return 3;
	}
}

SerialCore::SerialCore() :
	txState(TxState::DISABLED),
	rxState(RxState::DISABLED),
	rxInterruptEnable(false),
	txByte(0),
	rxByte(0),
	baudLimit(0),
	baudFrequency(0),
	intOut(false),
	txTicksPerByte(1),
	backend_(makeSerialBackend(SerialBackendConfig())),
	txTicksRemaining_(0)
{
}

void SerialCore::setBackend(std::unique_ptr<SerialBackend> backend)
{
	backend_ = std::move(backend);
}

uint32_t SerialCore::readRegister(uint32_t wordAddress, uint8_t laneMask)
{
	if (wordAddress == DeviceAddress::SERIAL_CONTROL)
	{
		uint32_t reg = 0;
		writeBits(reg, SerialControlBits::TX_EN_BIT, SerialControlBits::TX_EN_BIT,
		          (txState != TxState::DISABLED) ? 1u : 0u);
		writeBits(reg, SerialControlBits::RX_EN_BIT, SerialControlBits::RX_EN_BIT,
		          (rxState != RxState::DISABLED) ? 1u : 0u);
		writeBits(reg, SerialControlBits::RX_INTERRUPT_ENABLE_BIT, SerialControlBits::RX_INTERRUPT_ENABLE_BIT,
		          rxInterruptEnable ? 1u : 0u);
		writeBits(reg, SerialControlBits::TX_FULL_BIT, SerialControlBits::TX_FULL_BIT,
		          (txState == TxState::TRANSMITTING) ? 1u : 0u);
		writeBits(reg, SerialControlBits::RX_FULL_BIT, SerialControlBits::RX_FULL_BIT,
		          (rxState == RxState::DATA_RECEIVED) ? 1u : 0u);
		//UART_reset is an action, never stored, so it always reads 0.
		return reg;
	}
	if (wordAddress == DeviceAddress::SERIAL_RX)
	{
		unsigned int lane = mostSignificantLane(laneMask);
		uint32_t result = ((uint32_t) rxByte) << (8 * lane);
		if (rxState == RxState::DATA_RECEIVED)
		{
			//Reading Rx clears Rx_full and the interrupt.
			rxState = RxState::ENABLED;
			intOut  = false;
		}
		return result;
	}
	if (wordAddress == DeviceAddress::SERIAL_BAUD_LIMIT)
		return baudLimit;
	if (wordAddress == DeviceAddress::SERIAL_BAUD_FREQUENCY)
		return baudFrequency;
	if (wordAddress == DeviceAddress::SERIAL_TX)
		return 0; //Tx is write-only

	std::cerr << "\nWarning: SerialCore: read of unmapped serial address 0x"
	          << std::hex << wordAddress << std::dec << ", returning 0";
	return 0;
}

void SerialCore::writeRegister(uint32_t wordAddress, uint8_t laneMask, uint32_t data)
{
	if (wordAddress == DeviceAddress::SERIAL_CONTROL)
	{
		//As AJIT does, unselected lanes count as 0, not as "unchanged".
		writeControl(MemCore::mergeMaskedBytes(0, data, laneMask));
	}
	else if (wordAddress == DeviceAddress::SERIAL_TX)
	{
		if (laneMask == 0)
		{
			std::cerr << "\nWarning: SerialCore: Tx write with an empty byte mask ignored";
			return;
		}
		//A Tx write only starts a transmission while TX_ENABLED. While
		//TRANSMITTING or DISABLED the byte is dropped, as in hardware.
		if (txState != TxState::ENABLED)
			return;

		txByte = (uint8_t) (data >> (8 * mostSignificantLane(laneMask)));
		txState = TxState::TRANSMITTING;
		txTicksRemaining_ = txTicksPerByte;
		if (txTicksRemaining_ == 0)
			finishTransmit();
	}
	else if (wordAddress == DeviceAddress::SERIAL_BAUD_LIMIT)
	{
		baudLimit = MemCore::mergeMaskedBytes(baudLimit, data, laneMask);
	}
	else if (wordAddress == DeviceAddress::SERIAL_BAUD_FREQUENCY)
	{
		baudFrequency = MemCore::mergeMaskedBytes(baudFrequency, data, laneMask);
	}
	else if (wordAddress == DeviceAddress::SERIAL_RX)
	{
		//Rx is read-only. Ignored.
	}
	else
	{
		std::cerr << "\nWarning: SerialCore: write to unmapped serial address 0x"
		          << std::hex << wordAddress << std::dec << " ignored";
	}
}

void SerialCore::writeControl(uint32_t control)
{
	if (readBits(control, SerialControlBits::UART_RESET_BIT, SerialControlBits::UART_RESET_BIT))
	{
		//Back to the power-up state. A byte still being transmitted is
		//dropped. The rest of this write's bits are not acted on.
		txState           = TxState::DISABLED;
		rxState           = RxState::DISABLED;
		rxInterruptEnable = false;
		intOut            = false;
		txTicksRemaining_ = 0;
		return;
	}

	bool txEn = readBits(control, SerialControlBits::TX_EN_BIT, SerialControlBits::TX_EN_BIT);
	bool rxEn = readBits(control, SerialControlBits::RX_EN_BIT, SerialControlBits::RX_EN_BIT);
	rxInterruptEnable = readBits(control, SerialControlBits::RX_INTERRUPT_ENABLE_BIT,
	                             SerialControlBits::RX_INTERRUPT_ENABLE_BIT);

	if (txEn)
	{
		if (txState == TxState::DISABLED)
			txState = TxState::ENABLED;
	}
	else
	{
		//Disabling while a byte is still being transmitted finishes
		//sending it first, so no program output is lost.
		if (txState == TxState::TRANSMITTING)
			finishTransmit();
		txState = TxState::DISABLED;
	}

	if (rxEn)
	{
		if (rxState == RxState::DISABLED)
			rxState = RxState::ENABLED;
	}
	else
	{
		//From any state: clears Rx_full and the interrupt.
		rxState = RxState::DISABLED;
		intOut  = false;
	}
}

void SerialCore::finishTransmit()
{
	backend_->writeByte(txByte);
	txState = TxState::ENABLED;
	txTicksRemaining_ = 0;
}

void SerialCore::tick()
{
	if (txState == TxState::TRANSMITTING)
	{
		if (txTicksRemaining_ > 0)
			txTicksRemaining_--;
		if (txTicksRemaining_ == 0)
			finishTransmit();
	}

	if (rxState == RxState::ENABLED)
	{
		uint8_t byte;
		if (backend_->tryReadByte(byte))
		{
			rxByte  = byte;
			rxState = RxState::DATA_RECEIVED;
			if (rxInterruptEnable)
				intOut = true;
		}
	}
}

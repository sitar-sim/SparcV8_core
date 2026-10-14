//SerialCore.h
//
//A memory-mapped serial device (UART), a single instance, exchanging
//bytes with the host through a SerialBackend (console, files, or a pty,
//Ref SerialBackend.h). Two independent state machines, transmit and
//receive, share one Control register.
//
//For the full register format, address mapping, and interrupt level,
//see https://sitar-sim.github.io/SparcV8_core/peripheral_devices_serial_device.html
//
//Register map (Ref DeviceAddresses.h): Control, Tx (byte), Rx (byte),
//baud limit, baud frequency, each at its own word address, matching
//AJIT's default device map. Byte registers follow AJIT's Serial.c: a Tx
//write takes its byte from the most significant selected lane, and an
//Rx read returns the byte in the most significant selected lane (lane 3,
//bits [31:24], for an ordinary `ldub` of the Rx address).
//
//Tx: a write to Tx while TX_ENABLED sets Tx_full and moves to
//TX_TRANSMITTING for txTicksPerByte ticks, after which the byte is sent
//to the backend, Tx_full clears, and the device returns to TX_ENABLED.
//With txTicksPerByte = 0 the byte is sent within the write itself.
//
//Rx: tick() checks the backend for an incoming byte while RX_ENABLED.
//Bytes are not consumed from the backend while the receiver is
//disabled or still holding an unread byte, so no input is lost.
//
//tick() is called once per model tick by whichever driver is running,
//the same as TimerCore::tick().

#ifndef SERIAL_CORE_H
#define SERIAL_CORE_H

#include <stdint.h>
#include <memory>
#include "SerialBackend.h"

class SerialCore
{
	public:
		enum class TxState { DISABLED, ENABLED, TRANSMITTING };
		enum class RxState { DISABLED, ENABLED, DATA_RECEIVED };

		//Starts with a CONSOLE backend and no input file. Call
		//setBackend() before simulation to choose another.
		SerialCore();

		void setBackend(std::unique_ptr<SerialBackend> backend);

		TxState  txState;
		RxState  rxState;
		bool     rxInterruptEnable;
		uint8_t  txByte;          //valid while txState == TRANSMITTING
		uint8_t  rxByte;          //valid while rxState == DATA_RECEIVED
		uint32_t baudLimit;
		uint32_t baudFrequency;
		bool     intOut;          //serial_int_out pin

		//Model ticks one byte takes to transmit (default 1). A plain
		//configuration knob, the same value in both drivers.
		uint32_t txTicksPerByte;

		//Register access, Ref DeviceAddresses.h's header comment for the
		//(word address, lane mask, data) convention shared by all devices.
		uint32_t readRegister (uint32_t wordAddress, uint8_t laneMask);
		void     writeRegister(uint32_t wordAddress, uint8_t laneMask, uint32_t data);

		//One model tick: advances a transmission in progress, and checks
		//the backend for an incoming byte.
		void tick();

	private:
		void writeControl(uint32_t control);
		void finishTransmit();

		std::unique_ptr<SerialBackend> backend_;
		uint32_t txTicksRemaining_;
};

#endif

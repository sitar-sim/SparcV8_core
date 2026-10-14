//PeripheralDevicesCore.h
//
//The system's single shared set of peripheral devices: Timer, Serial,
//and the Interrupt Controller, reached over the physical bus below the
//MMU like any other memory-mapped target (Ref
//https://sitar-sim.github.io/SparcV8_core/peripheral_devices.html).
//
//This class does three things, so that no driver has to:
//
//1. Bus adaptation. It implements PhysicalMemoryInterface, so it takes
//   the same doubleword-shaped request main memory takes (Ref
//   MemoryInterfaces.h). Each 32-bit half of the doubleword whose
//   byte-mask nibble is non-zero becomes one register access to
//   whichever device owns that word address, in the (word address, lane
//   mask, data) form every device class uses (Ref DeviceAddresses.h).
//   For a READ, the mask names the word(s) the requester needs, so a
//   register with a read side effect (Serial's Rx) is only touched when
//   it is really read. A READ with an empty mask reads both words.
//
//2. Pin wiring. The Timer's and Serial's interrupt outputs, and the
//   external interrupt input (externalInterruptIn, for a future
//   accelerator), feed the Interrupt Controller's inputs.
//
//3. Clocking. tick() advances every device by one model cycle, in a
//   fixed order (Timer, Serial, then the Interrupt Controller, which so
//   sees this cycle's fresh pin values). The Timer ticks once every
//   timerTickDivider cycles (default 1).
//
//Used unchanged by both drivers: the cpp_model calls tick() after
//every core cycle, the sitar_model's PeripheralDevices module calls it
//once per simulated cycle.

#ifndef PERIPHERAL_DEVICES_CORE_H
#define PERIPHERAL_DEVICES_CORE_H

#include <stdint.h>
#include <memory>
#include "MemoryInterfaces.h"
#include "TimerCore.h"
#include "SerialCore.h"
#include "InterruptControllerCore.h"

class PeripheralDevicesCore : public PhysicalMemoryInterface
{
	public:
		PeripheralDevicesCore();

		TimerCore               timer;
		SerialCore              serial;
		InterruptControllerCore interruptController;

		//Model cycles per timer tick. Default 1 (Ref TimerCore.h on why
		//timer counts are in model ticks, not hardware time).
		uint32_t timerTickDivider;

		//External interrupt input pin (IRL 14), driven from outside this
		//device set. Low by default.
		bool externalInterruptIn;

		void access(const PhysicalMemoryRequest& request, PhysicalMemoryResponse& response) override;

		void tick();

		//The interrupt level the Interrupt Controller presents to one
		//hardware thread (slot = 2*core_id + thread_id).
		uint32_t interruptLevel(int slot) const { return interruptController.interruptLevel(slot); }

		//Access counters, printed by a driver's --stats.
		struct Stats
		{
			uint64_t timerAccesses               = 0;
			uint64_t serialAccesses              = 0;
			uint64_t interruptControllerAccesses = 0;
			uint64_t unmappedAccesses            = 0;
			std::string toString() const;
		} stats;

	private:
		uint32_t readWord (uint32_t wordAddress, uint8_t laneMask);
		void     writeWord(uint32_t wordAddress, uint8_t laneMask, uint32_t data);

		uint32_t cyclesSinceTimerTick_;
};

#endif

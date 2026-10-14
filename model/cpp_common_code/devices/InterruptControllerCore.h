//InterruptControllerCore.h
//
//The interrupt controller: a single shared instance that routes the
//system's interrupt sources to the hardware threads of every core.
//
//For the full register format, address mapping, and interrupt levels,
//see https://sitar-sim.github.io/SparcV8_core/peripheral_devices_interrupt_controller.html
//
//Behavior follows AJIT's multi-thread interrupt controller
//(devices/src/InterruptControllerMT.c and
//devices/documentation/ajit_interrupt_controllers.tex in the
//ajit-toolchain repo's 64-bit multi-core C model). It has two parts.
//
//1. One slot per hardware thread, NUM_SLOTS in all (4 cores x 2
//   threads). Slot index = 2*core_id + thread_id. Each slot has its own
//   Control register, at INTERRUPT_CONTROLLER_MIN + 4*slot:
//
//     [0]      enable for this slot                        read/write
//     [15:1]   per-level enable mask, bit i = IRL i        read/write
//     [30:16]  incoming interrupt vector, IRL i at bit 15+i read only
//     [31]     1 while the slot is INTERRUPTING            read only
//
//   and its own state machine: DISABLED -> (enable written) -> ENABLED
//   -> (any enabled level active) -> INTERRUPTING, which holds the
//   slot's interrupt level until software clears the enable bit. When
//   several enabled levels are active at once, the lowest IRL wins.
//
//2. The inter-processor interrupt (IPI) block at IPI_BASE: 19 words.
//   Word 0 is the IPI mask and word 1 the IPI value, one bit per slot.
//   Slot s sees an IPI (IRL 11) while bit s is set in both. Words 2..17
//   are 8 bytes of message per destination slot, and word 18 a lock
//   word, both used only by software.
//
//Inputs: the Timer, Serial, and External interrupt pins are broadcast
//to every slot (each slot's own mask decides whether it takes them).
//The driver copies each pin's value into the fields below before
//calling tick().
//
//Deviation from AJIT: AJIT decodes the IPI word index from address bits
//[5:0] only, so words 16..18 alias onto words 0..2 (the lock word lands
//on slot 0's message). This class decodes all 19 words separately.

#ifndef INTERRUPT_CONTROLLER_CORE_H
#define INTERRUPT_CONTROLLER_CORE_H

#include <stdint.h>

class InterruptControllerCore
{
	public:
		static const int NUM_SLOTS     = 8;
		static const int NUM_IPI_WORDS = 19;

		enum class State { DISABLED, ENABLED, INTERRUPTING };

		struct Slot
		{
			State    state;
			uint32_t controlRegister; //as written, merged by byte lane
			uint32_t interruptLevel;  //0, or the level being delivered
		};

		InterruptControllerCore();

		static int slotIndex(uint32_t coreId, uint32_t threadId) { return 2 * coreId + threadId; }

		//Input pins, set by the driver each tick.
		bool timerIn;
		bool serialIn;
		bool externalIn;

		Slot     slots[NUM_SLOTS];
		uint32_t ipiWords[NUM_IPI_WORDS];

		//Register access, Ref DeviceAddresses.h's header comment for the
		//(word address, lane mask, data) convention shared by all devices.
		uint32_t readRegister (uint32_t wordAddress, uint8_t laneMask);
		void     writeRegister(uint32_t wordAddress, uint8_t laneMask, uint32_t data);

		//Re-evaluates every ENABLED slot against the current inputs.
		void tick();

		//The interrupt level the given slot is presenting to its thread.
		uint32_t interruptLevel(int slot) const { return slots[slot].interruptLevel; }

		//Active sources as seen by one slot, bit i = IRL i.
		uint32_t incomingVector(int slot) const;
};

#endif

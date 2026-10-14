//TimerCore.h
//
//A one-shot timer. Software writes a maximum count and an enable bit to
//a single Control register. The timer then counts timer ticks, and once
//the count reaches the maximum it raises its interrupt output and
//stops. The interrupt output stays asserted until software disables the
//timer.
//
//For the full register format, address mapping, and interrupt level,
//see https://sitar-sim.github.io/SparcV8_core/peripheral_devices_timer.html
//
//Behavior follows AJIT's timer (devices/src/Timer.c in the ajit-toolchain
//repo's 64-bit multi-core C model):
//  - the count starts at 0 on enable and counts up; the interrupt is
//    raised once count >= max_count, so max_count = 0 or 1 both fire on
//    the first tick;
//  - an enable write is only acted on from DISABLED (writing the enable
//    bit again while ENABLED or INTERRUPTING does not restart the timer);
//  - a read returns the Control register as last written, not the live
//    count (the live count is still visible here, as `count`, for
//    logging and debugging).
//
//This class is not wired to a real clock. tick() stands in for one edge
//of the timer's own clock_in, and whichever driver is running decides
//how many core cycles one tick is (a tick divider, default 1). In
//hardware the timer may run off a different clock than the core, so
//timer counts here are in model ticks, not hardware time.

#ifndef TIMER_CORE_H
#define TIMER_CORE_H

#include <stdint.h>

class TimerCore
{
	public:
		enum class State { DISABLED, ENABLED, INTERRUPTING };

		TimerCore();

		State    state;
		uint32_t controlRegister; //as last written (merged by byte lane)
		uint32_t count;           //ticks counted since the timer was enabled
		uint32_t maxCount;        //captured from controlRegister[31:1] on enable
		bool     intOut;          //timer_int_out pin

		//Register access, Ref DeviceAddresses.h's header comment for the
		//(word address, lane mask, data) convention shared by all devices.
		uint32_t readRegister (uint32_t wordAddress, uint8_t laneMask);
		void     writeRegister(uint32_t wordAddress, uint8_t laneMask, uint32_t data);

		//One clock_in edge. No-op unless the timer is ENABLED.
		void tick();
};

#endif

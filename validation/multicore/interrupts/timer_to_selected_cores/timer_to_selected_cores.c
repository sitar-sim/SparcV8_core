// timer_to_selected_cores.c
//
// One timer interrupt, taken by every core whose Interrupt Controller
// slot enables the timer's level, and by no other core. Cores 0 to 2
// enable the timer's level. Core 3 enables its slot with every level
// but the timer's. Once every core has set up its slot, core 0 starts
// the timer.
//
// The timer's interrupt stays active until software stops the timer, and
// a core's slot raises it again as soon as the core re-enables the slot.
// So core 0's handler stops the timer, and the handlers of cores 1 and 2
// wait for that before they return. A core reads what another core
// wrote with read_shared(), so the test also passes with
// SPARC_ALWAYS_CACHEABLE=1.
//
// Every core:
//   0. takes the timer interrupt exactly once (cores 0 to 2), or never
//      (core 3);
//   1. (core 0) sees every core ready before it starts the timer, and
//      the timer stopped afterwards; (cores 1 to 3) sees the timer
//      stopped before it reports.

#include "../../multicore_common.h"

// In .bss, so core 0 has cleared them before any core reaches main().
volatile uint32_t ready[NUM_CORES];
volatile uint32_t timer_interrupts[NUM_CORES];
volatile uint32_t timer_stopped;

void timer_handler(void)
{
	uint32_t id = this_core_id();
	int polls = 0;
	timer_interrupts[id]++;
	if (id == 0)
	{
		__ajit_write_timer_control_register_via_bypass__(0); //clear the source
		timer_stopped = 1;
	}
	else
	{
		while (read_shared(&timer_stopped) == 0 && polls < WAIT_LIMIT)
			polls++;
	}
}

int main(void)
{
	uint32_t ok = 0;
	uint32_t id = this_core_id();
	int k, polls, i;

	//The handler table is shared by every core. Core 0 cleared it with
	//.bss, and every core installs the same handler, so the writes agree.
	ajit_set_interrupt_handler(TIMER_IRL, timer_handler);
	if (id == 3)
		writeInterruptControlRegister(id, 0, (0xfffeu & ~(1u << TIMER_IRL)) | 1u);
	else
		writeInterruptControlRegister(id, 0, (1u << TIMER_IRL) | 1u);
	ready[id] = 1;

	if (id == 0)
	{
		int all_ready = 0;
		polls = 0;
		while (!all_ready && polls < WAIT_LIMIT)
		{
			all_ready = 1;
			for (k = 0; k < NUM_CORES; k++)
				if (read_shared(&ready[k]) == 0) all_ready = 0;
			polls++;
		}
		__ajit_write_timer_control_register_via_bypass__((100u << 1) | 1u);
		polls = 0;
		while (timer_interrupts[0] == 0 && polls < WAIT_LIMIT)
			polls++;
		for (i = 0; i < 200; i++) ; //time for a (wrong) second interrupt to show up
		if (timer_interrupts[0] == 1) ok |= 1 << 0;
		if (all_ready && read_shared(&timer_stopped) && __ajit_read_timer_control_register_via_bypass__() == 0)
			ok |= 1 << 1;
	}
	else
	{
		polls = 0;
		while (read_shared(&timer_stopped) == 0 && polls < WAIT_LIMIT)
			polls++;
		//Cores 1 and 2 wait for their own interrupt too. Core 3 waits as
		//long, to give a (wrong) interrupt time to show up.
		polls = 0;
		while (timer_interrupts[id] == 0 && polls < 2000)
			polls++;
		for (i = 0; i < 200; i++) ;
		if (timer_interrupts[id] == (id == 3 ? 0u : 1u)) ok |= 1 << 0;
		if (read_shared(&timer_stopped)) ok |= 1 << 1;
	}

	report_and_halt(ok, 2);
	return 0;
}

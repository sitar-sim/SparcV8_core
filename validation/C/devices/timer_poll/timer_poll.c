// timer_poll.c
//
// The Timer without interrupts: enable it, then watch the Interrupt
// Controller's live interrupt vector (readable even while the slot is
// disabled) until the timer's IRL 10 shows active.
//   0. the Control register reads back exactly as written
//   1. the timer does not fire immediately
//   2. the timer fires within WAIT_LIMIT polls
//   3. disabling the timer drops its interrupt
//   4. the Control register reads 0 after disabling

#include "../devices_common.h"
#include "ajit_mt_irc.h"

#define TIMER_ACTIVE_BIT (1u << (15 + TIMER_IRL))

int main(void)
{
	uint32_t ok = 0;
	//Max count 20000 ticks, enable. Large enough not to have fired by the
	//first poll even in the sitar_model, where an instruction takes several
	//cycles.
	uint32_t control = (20000u << 1) | 1u;

	__ajit_write_timer_control_register_via_bypass__(control);
	if (__ajit_read_timer_control_register_via_bypass__() == control) ok |= 1 << 0;
	if (!(readInterruptControlRegister(0, 0) & TIMER_ACTIVE_BIT)) ok |= 1 << 1;

	int polls = 0;
	while (!(readInterruptControlRegister(0, 0) & TIMER_ACTIVE_BIT) && polls < WAIT_LIMIT)
		polls++;
	if (polls > 0 && polls < WAIT_LIMIT) ok |= 1 << 2;

	__ajit_write_timer_control_register_via_bypass__(0);
	polls = 0;
	while ((readInterruptControlRegister(0, 0) & TIMER_ACTIVE_BIT) && polls < 10)
		polls++;
	if (!(readInterruptControlRegister(0, 0) & TIMER_ACTIVE_BIT)) ok |= 1 << 3;
	if (__ajit_read_timer_control_register_via_bypass__() == 0) ok |= 1 << 4;

	report_and_halt(ok, 5);
	return 0;
}

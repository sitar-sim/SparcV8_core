// device_never_cached.c
//
// Device registers are never cached, even with "always cacheable" set and
// an ordinary (non-bypass) load, so a register whose value changes on its
// own is seen to change. Here: the Interrupt Controller's live source
// bits while the timer counts down.
//   0. the timer is not yet active at the first read
//   1. later plain loads of the same address see it become active

#include "../caches_common.h"

#define IRC_SLOT0        ((volatile uint32_t*) ADDR_INTERRUPT_CONTROLLER_MIN)
#define TIMER_ACTIVE_BIT (1u << (15 + TIMER_IRL))

int main(void)
{
	uint32_t ok = 0;
	int polls = 0;

	set_always_cacheable();
	__ajit_write_timer_control_register_via_bypass__((20000u << 1) | 1u);

	if (!(*IRC_SLOT0 & TIMER_ACTIVE_BIT)) ok |= 1 << 0;
	while (!(*IRC_SLOT0 & TIMER_ACTIVE_BIT) && polls < 100000)
		polls++;
	if (polls < 100000) ok |= 1 << 1;

	__ajit_write_timer_control_register_via_bypass__(0);
	report_and_halt(ok, 2);
	return 0;
}

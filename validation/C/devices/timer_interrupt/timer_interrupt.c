// timer_interrupt.c
//
// A timer interrupt delivered through the Interrupt Controller to a real
// trap handler, using AJIT's interrupt dispatch scheme (Ref
// compiler/include/ajit_mt_irc.h and compiler/crt0_interrupts.s).
//   0. no interrupt before the timer is enabled
//   1. the handler runs exactly once
//   2. on entry, the handler finds the slot already disabled (bit 0
//      clear) by the generic handler
//   3. after return, the slot is enabled again and idle

#include "../devices_common.h"
#include "ajit_mt_irc.h"

volatile uint32_t timer_interrupts = 0;
volatile uint32_t slot_control_in_handler = 0xffffffff;

void timer_handler(void)
{
	slot_control_in_handler = readInterruptControlRegister(0, 0);
	timer_interrupts++;
	__ajit_write_timer_control_register_via_bypass__(0); //clear the source
}

int main(void)
{
	uint32_t ok = 0;

	ajit_initialize_interrupt_handlers_to_null();
	ajit_set_interrupt_handler(TIMER_IRL, timer_handler);
	writeInterruptControlRegister(0, 0, (1u << TIMER_IRL) | 1u);

	int i;
	for (i = 0; i < 100; i++) ;
	if (timer_interrupts == 0) ok |= 1 << 0;

	__ajit_write_timer_control_register_via_bypass__((100u << 1) | 1u);
	int polls = 0;
	while (timer_interrupts == 0 && polls < WAIT_LIMIT)
		polls++;
	for (i = 0; i < 200; i++) ; //time for a (wrong) second interrupt to show up
	if (timer_interrupts == 1) ok |= 1 << 1;
	if ((slot_control_in_handler & 0x1) == 0) ok |= 1 << 2;

	uint32_t slot = readInterruptControlRegister(0, 0);
	if ((slot & 0x1) && !(slot & 0x80000000u)) ok |= 1 << 3;

	report_and_halt(ok, 4);
	return 0;
}

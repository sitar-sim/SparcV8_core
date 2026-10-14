// irc_priority_and_mask.c
//
// Interrupt Controller masking and priority.
//   0. with only the serial level enabled in the mask, an active timer
//      is not delivered
//   1. the vector bits [30:16] still show both active sources
//   2. with both levels enabled and both sources active, the timer
//      (IRL 10) is delivered before the serial device (IRL 12)
//   3. both handlers ran exactly once

#include "../devices_common.h"
#include "ajit_mt_irc.h"

volatile uint32_t order[4];
volatile uint32_t count = 0;

void timer_handler(void)
{
	if (count < 4) order[count] = TIMER_IRL;
	count++;
	__ajit_write_timer_control_register_via_bypass__(0);
}

void serial_handler(void)
{
	if (count < 4) order[count] = SERIAL_IRL;
	count++;
	//One byte per phase: stop receiving first (the byte already received
	//stays readable, the next one stays queued in the input), then read.
	__ajit_serial_configure_via_bypass__(0, 0, 0);
	__ajit_read_serial_rx_register_via_bypass__();
}

int main(void)
{
	uint32_t ok = 0;
	int i, polls;

	ajit_initialize_interrupt_handlers_to_null();
	ajit_set_interrupt_handler(TIMER_IRL, timer_handler);
	ajit_set_interrupt_handler(SERIAL_IRL, serial_handler);

	//Make both sources active while the slot is still disabled.
	__ajit_write_timer_control_register_via_bypass__((1u << 1) | 1u);
	__ajit_serial_configure_via_bypass__(0, 1, 1);
	polls = 0;
	while (!(__ajit_read_serial_control_register_via_bypass__() & RX_FULL) && polls < WAIT_LIMIT)
		polls++;

	uint32_t vector = readInterruptControlRegister(0, 0);
	if ((vector & (1u << (15 + TIMER_IRL))) && (vector & (1u << (15 + SERIAL_IRL)))) ok |= 1 << 1;

	//Enable only the serial level: the timer must not be delivered, so
	//the first (and only) handler to run is the serial one.
	writeInterruptControlRegister(0, 0, (1u << SERIAL_IRL) | 1u);
	polls = 0;
	while (count == 0 && polls < WAIT_LIMIT)
		polls++;
	for (i = 0; i < 200; i++) ;
	if (count == 1 && order[0] == SERIAL_IRL) ok |= 1 << 0;

	//Make the serial device active again (its handler disabled the
	//receiver), then enable both levels with both sources active: the
	//timer goes first.
	disableInterruptController(0, 0);
	count = 0;
	__ajit_serial_configure_via_bypass__(0, 1, 1);
	polls = 0;
	while (!(__ajit_read_serial_control_register_via_bypass__() & RX_FULL) && polls < WAIT_LIMIT)
		polls++;
	writeInterruptControlRegister(0, 0, (1u << TIMER_IRL) | (1u << SERIAL_IRL) | 1u);
	polls = 0;
	while (count < 2 && polls < WAIT_LIMIT)
		polls++;
	for (i = 0; i < 200; i++) ;
	if (order[0] == TIMER_IRL && order[1] == SERIAL_IRL) ok |= 1 << 2;
	if (count == 2) ok |= 1 << 3;

	report_and_halt(ok, 4);
	return 0;
}

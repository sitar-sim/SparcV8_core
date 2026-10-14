// serial_rx_interrupt.c
//
// Receive bytes by interrupt: with Rx_interrupt_enable set, each byte
// from serial_rx_interrupt.serial_in raises IRL 12, and the handler reads
// it (which clears the interrupt).
//   0. exactly 3 interrupts, one per byte
//   1. the bytes arrive in order: 'x', 'y', 'z'

#include "../devices_common.h"
#include "ajit_mt_irc.h"

volatile uint32_t received = 0;
volatile char     bytes[4];

void serial_handler(void)
{
	char c = (char) __ajit_read_serial_rx_register_via_bypass__();
	if (received < 4)
		bytes[received] = c;
	received++;
}

int main(void)
{
	uint32_t ok = 0;

	ajit_initialize_interrupt_handlers_to_null();
	ajit_set_interrupt_handler(SERIAL_IRL, serial_handler);
	writeInterruptControlRegister(0, 0, (1u << SERIAL_IRL) | 1u);
	__ajit_serial_configure_via_bypass__(0, 1, 1);

	int polls = 0;
	while (received < 3 && polls < WAIT_LIMIT)
		polls++;
	int i;
	for (i = 0; i < 300; i++) ; //time for a (wrong) fourth interrupt

	if (received == 3) ok |= 1 << 0;
	if (bytes[0] == 'x' && bytes[1] == 'y' && bytes[2] == 'z') ok |= 1 << 1;

	report_and_halt(ok, 2);
	return 0;
}

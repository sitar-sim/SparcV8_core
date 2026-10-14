// serial_tx.c
//
// Transmit a string through the Serial device, one character at a time,
// waiting for Tx_full to clear between characters. The .vprj's
// serial_out line checks the exact bytes sent.
//   0. Tx_en reads back set after configuring
//   1. putchar refuses (returns 0) while the transmitter is disabled

#include "../devices_common.h"

int main(void)
{
	uint32_t ok = 0;

	if (__ajit_serial_putchar_via_bypass__('X') == 0) ok |= 1 << 1;

	__ajit_serial_configure_via_bypass__(1, 0, 0);
	if (__ajit_read_serial_control_register_via_bypass__() & TX_ENABLE) ok |= 1 << 0;

	char message[] = "Hello, serial!\n";
	__ajit_serial_puts_via_bypass__(message, sizeof(message) - 1);

	//Wait for the last character to finish before halting.
	int polls = 0;
	while ((__ajit_read_serial_control_register_via_bypass__() & TX_FULL) && polls < WAIT_LIMIT)
		polls++;

	report_and_halt(ok, 2);
	return 0;
}

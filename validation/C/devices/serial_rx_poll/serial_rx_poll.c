// serial_rx_poll.c
//
// Receive bytes by polling Rx_full, from serial_rx_poll.serial_in (the
// model feeds that file in as received bytes), then echo them back out.
//   0. the first byte received is 'S'
//   1. Rx_full is clear after reading the last byte (no more input)
//   2. all 5 bytes are received, in order (also checked by serial_out)

#include "../devices_common.h"

int main(void)
{
	uint32_t ok = 0;
	char buffer[5];
	int i;

	__ajit_serial_configure_via_bypass__(1, 1, 0);

	for (i = 0; i < 5; i++)
	{
		int polls = 0;
		while (!(__ajit_read_serial_control_register_via_bypass__() & RX_FULL) && polls < WAIT_LIMIT)
			polls++;
		buffer[i] = (char) __ajit_read_serial_rx_register_via_bypass__();
	}
	if (!(__ajit_read_serial_control_register_via_bypass__() & RX_FULL)) ok |= 1 << 1;
	if (buffer[0] == 'S') ok |= 1 << 0;
	if (buffer[1] == 'P' && buffer[2] == 'A' && buffer[3] == 'R' && buffer[4] == 'C') ok |= 1 << 2;

	__ajit_serial_puts_via_bypass__(buffer, 5);
	int polls = 0;
	while ((__ajit_read_serial_control_register_via_bypass__() & TX_FULL) && polls < WAIT_LIMIT)
		polls++;

	report_and_halt(ok, 3);
	return 0;
}

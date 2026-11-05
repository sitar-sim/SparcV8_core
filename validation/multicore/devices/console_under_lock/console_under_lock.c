// console_under_lock.c
//
// Every core prints lines at once through the one Serial device. The lock keeps each line in
// one piece. Which core goes first is not fixed, so the .vprj's serial_lines line
// accepts the lines in any order.
//
// Every core checks:
//   0. it got to the end
#include "../../multicore_common.h"
#include "multicore_platform.h"

#define LINES 3

static barrier_t barrier;

int main(void)
{
	uint32_t id = this_core_id(), line;
	char text[] = "core 0 line 0\n";

	if (id == 0)
		console_start();
	barrier_wait(&barrier, NUM_CORES);

	for (line = 0; line < LINES; line++)
	{
		text[5]  = '0' + id;
		text[12] = '0' + line;
		console_puts(text);
	}
	barrier_wait(&barrier, NUM_CORES);
	console_wait_until_sent();

	report_and_halt(1, 1);
	return 0;
}

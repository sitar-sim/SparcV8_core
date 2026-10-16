// cold_state.c
//
// The engine at power-up, before the SPARC has given it anything: no
// thread runs, and its memories and registers are all zero. The SPARC
// checks a sample of each, through the control unit and the DMEM window.
//   0. IMEM: every 32nd word is 0
//   1. DMEM: every 64th 32-bit word is 0
//   2. every register of every thread is 0
//   3. no thread reports a stop (none was started)
//   4. the engine's cycle counter runs

#include "../../apara_common.h"

int main(void)
{
	uint32_t ok = 0, i, t, r, zero;

	zero = 1;
	for (i = 0; i < 4096; i += 32)
		zero &= apara_read_imem(i) == 0;
	if (zero) ok |= 1 << 0;

	zero = 1;
	for (i = 0; i < 65536; i += 256)
		zero &= apara_dmem_read_word(i) == 0;
	if (zero) ok |= 1 << 1;

	zero = 1;
	for (t = 0; t < 4; t++)
		for (r = 1; r < 32; r++)
			zero &= apara_read_thread_register(t, r) == 0;
	if (zero) ok |= 1 << 2;

	zero = 1;
	for (t = 0; t < 4; t++)
		zero &= apara_poll_thread(t) == 0;
	if (zero) ok |= 1 << 3;

	uint64_t before = apara_read_timer();
	uint64_t after = apara_read_timer();
	if (after > before) ok |= 1 << 4;

	report_and_halt(ok, 5);
	return 0;
}

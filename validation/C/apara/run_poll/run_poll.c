// run_poll.c
//
// Load an engine program, set its registers, run it, poll until it stops.
//   0. the thread is not stopped right after it starts... (or has just
//      stopped: the program is short) -- the first poll sees either
//   1. its completion word is valid with the halt bit, no exception
//   2. it stopped after the $halt at `done`
//   3. its result register is 40 + 2
//   4. the 64-bit word it stored reads back big-endian through the DMEM
//      window (high half at the lower address)
//   5. the stop is reported only once

#include "../apara_common.h"
#include "kernel.mcode.h"

int main(void)
{
	uint32_t ok = 0;
	apara_load_program(kernel_program, KERNEL_PROGRAM_WORDS);
	apara_write_thread_register(0, 1, 40);
	apara_write_thread_register(0, 2, 2);
	apara_write_thread_register(0, 9, APARA_DMEM_BASE);
	apara_start_thread(0, KERNEL_START);

	uint32_t first = apara_poll_thread(0);
	if (first == 0 || first == (APARA_COMPLETION_VALID | APARA_ERROR_HALT)) ok |= 1 << 0;
	uint32_t w = first ? first : apara_wait_thread(0);
	if (w == (APARA_COMPLETION_VALID | APARA_ERROR_HALT)) ok |= 1 << 1;
	if (apara_thread_stop_pc(0) == KERNEL_DONE + 1) ok |= 1 << 2;
	if (apara_read_thread_register(0, 3) == 42) ok |= 1 << 3;
	if (apara_dmem_read_word(0x100) == 0 && apara_dmem_read_word(0x104) == 42) ok |= 1 << 4;
	if (apara_poll_thread(0) == 0) ok |= 1 << 5;

	report_and_halt(ok, 6);
	return 0;
}

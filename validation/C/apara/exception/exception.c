// exception.c
//
// An engine exception, as the host sees it.
//   0. the completion word is valid with the exception bit, not the halt bit
//   1. its slot 1 code is 1, integer divide by zero, the other slots 0
//   2. the thread stopped at the faulting bundle (its result not written)
//   3. after a reset, the thread runs again (a $halt at 8)

#include "../apara_common.h"
#include "kernel.mcode.h"

int main(void)
{
	uint32_t ok = 0;
	apara_load_program(kernel_program, KERNEL_PROGRAM_WORDS);
	apara_write_thread_register(0, 1, 7);
	apara_write_thread_register(0, 3, 99);
	apara_start_thread(0, KERNEL_START);
	uint32_t w = apara_wait_thread(0);
	if ((w & (APARA_COMPLETION_VALID | APARA_ERROR_EXCEPTION | APARA_ERROR_HALT)) == (APARA_COMPLETION_VALID | APARA_ERROR_EXCEPTION)) ok |= 1 << 0;
	if ((w & 0xffffff) == (1u << 3)) ok |= 1 << 1;
	if (apara_thread_stop_pc(0) == KERNEL_START && apara_read_thread_register(0, 3) == 99) ok |= 1 << 2;

	apara_reset_thread(0);
	apara_start_thread(0, 8);
	if (apara_wait_thread(0) == (APARA_COMPLETION_VALID | APARA_ERROR_HALT)) ok |= 1 << 3;

	report_and_halt(ok, 4);
	return 0;
}

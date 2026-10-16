// staggered.c
//
// Threads started at different times, and a thread started again: thread
// 0 runs alone on the first half of the vectors; then threads 1 and 2
// start on the two quarters of the second half while thread 0 is started
// again, on the first quarter, with new registers. Each stop is reported
// exactly once.
//   0. thread 0's first run is right
//   1. a second poll after a reported stop reports nothing
//   2. thread 0's second run is right
//   3. threads 1 and 2 are right
//   4. no thread reports a second stop afterwards

#include "../threads_common.h"

static void setup(uint32_t t, uint32_t first_block, uint32_t blocks, uint32_t result)
{
	apara_write_thread_register(t, 1, APARA_DMEM_BASE + 0x000 + 32 * first_block);
	apara_write_thread_register(t, 2, APARA_DMEM_BASE + 0x200 + 32 * first_block);
	apara_write_thread_register(t, 3, blocks - 1);
	apara_write_thread_register(t, 4, APARA_DMEM_BASE + result);
}

int main(void)
{
	uint32_t ok = 0, i, state = 5;

	for (i = 0; i < ELEMENTS; i++)
	{
		A[i] = (int8_t) next_random(&state);
		B[i] = (int8_t) next_random(&state);
	}
	apara_load_program(dot_kernel_program, DOT_KERNEL_PROGRAM_WORDS);
	apara_dma_load(0, 0x000, (uint32_t) A, ELEMENTS);
	apara_dma_load(1, 0x200, (uint32_t) B, ELEMENTS);

	setup(0, 0, 8, 0x400);
	apara_start_thread(0, DOT_KERNEL_START);
	if (apara_wait_thread(0) == HALTED && dword_equals(0x400, dot(0, 256))) ok |= 1 << 0;
	if (apara_poll_thread(0) == 0) ok |= 1 << 1;

	setup(1, 8, 4, 0x408);
	setup(2, 12, 4, 0x410);
	apara_start_thread(1, DOT_KERNEL_START);
	apara_start_thread(2, DOT_KERNEL_START);
	setup(0, 0, 4, 0x418);
	apara_start_thread(0, DOT_KERNEL_START);
	uint32_t d0 = apara_wait_thread(0), d1 = apara_wait_thread(1), d2 = apara_wait_thread(2);
	if (d0 == HALTED && dword_equals(0x418, dot(0, 128))) ok |= 1 << 2;
	if (d1 == HALTED && d2 == HALTED && dword_equals(0x408, dot(256, 128)) && dword_equals(0x410, dot(384, 128)))
		ok |= 1 << 3;
	if (apara_poll_thread(0) == 0 && apara_poll_thread(1) == 0 && apara_poll_thread(2) == 0) ok |= 1 << 4;

	report_and_halt(ok, 5);
	return 0;
}

// four_threads.c
//
// Four engine threads running the same program on their own data.
//   0-3. thread t's sum of its 8 bytes is right
//   4. every thread stopped normally

#include "../apara_common.h"
#include "kernel.mcode.h"

int main(void)
{
	uint32_t ok = 0, t, k;
	apara_load_program(kernel_program, KERNEL_PROGRAM_WORDS);
	for (t = 0; t < 4; t++)
	{
		//Bytes 16t+1 .. 16t+8 at DMEM byte 64t.
		uint32_t base = 16 * t + 1;
		apara_dmem_write_word(64 * t, (base << 24) | ((base + 1) << 16) | ((base + 2) << 8) | (base + 3));
		apara_dmem_write_word(64 * t + 4, ((base + 4) << 24) | ((base + 5) << 16) | ((base + 6) << 8) | (base + 7));
		apara_write_thread_register(t, 1, APARA_DMEM_BASE + 64 * t);
	}
	for (t = 0; t < 4; t++)
		apara_start_thread(t, KERNEL_START);
	uint32_t normal = 1;
	for (t = 0; t < 4; t++)
		normal &= apara_wait_thread(t) == (APARA_COMPLETION_VALID | APARA_ERROR_HALT);
	for (t = 0; t < 4; t++)
	{
		uint32_t expected = 0;
		for (k = 0; k < 8; k++)
			expected += 16 * t + 1 + k;
		if (apara_dmem_read_word(64 * t + 12) == expected && apara_dmem_read_word(64 * t + 8) == 0) ok |= 1u << t;
	}
	if (normal) ok |= 1 << 4;

	report_and_halt(ok, 5);
	return 0;
}

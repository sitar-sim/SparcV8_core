// disjoint_regions.c
//
// Four threads fill four neighbouring DMEM regions (64 dwords each, at
// 0x1000 + 0x208 t), with guard dwords before and after each. A thread
// writes only its own region: every value lands, and no guard changes.
//   0-3. thread t stopped normally and filled its region exactly
//   4. every guard dword is unchanged

#include "../../apara_common.h"
#include "../fill.mcode.h"

#define REGION(t) (0x1000 + 0x208 * (t))
#define GUARD     0x6a6a6a6au

int main(void)
{
	uint32_t ok = 0, t, i, same;

	apara_load_program(fill_program, FILL_PROGRAM_WORDS);
	for (t = 0; t < 4; t++)
	{
		apara_dmem_write_word(REGION(t) - 8, GUARD);
		apara_dmem_write_word(REGION(t) - 4, GUARD);
		apara_dmem_write_word(REGION(t) + 512, GUARD);
		apara_dmem_write_word(REGION(t) + 516, GUARD);
		apara_write_thread_register(t, 1, APARA_DMEM_BASE + REGION(t));
		apara_write_thread_register(t, 2, 63);
		apara_write_thread_register(t, 3, 1000 * (t + 1));
	}
	for (t = 0; t < 4; t++)
		apara_start_thread(t, FILL_START);
	for (t = 0; t < 4; t++)
	{
		uint32_t done = apara_wait_thread(t);
		same = 1;
		for (i = 0; i < 64; i++)
			same &= dword_equals(REGION(t) + 8 * i, (int32_t) (1000 * (t + 1) + i));
		if (done == HALTED && same) ok |= 1u << t;
	}
	same = 1;
	for (t = 0; t < 4; t++)
		same &= apara_dmem_read_word(REGION(t) - 8) == GUARD && apara_dmem_read_word(REGION(t) - 4) == GUARD
		     && apara_dmem_read_word(REGION(t) + 512) == GUARD && apara_dmem_read_word(REGION(t) + 516) == GUARD;
	if (same) ok |= 1 << 4;

	report_and_halt(ok, 5);
	return 0;
}

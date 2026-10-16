// reload_program.c
//
// Two programs one after the other in the same IMEM: squares.mcode
// fills DMEM, then sum.mcode, loaded over it, adds up what the first one
// left. The second program's loop branch sits where the first one's did,
// with another target: the branch predictor's stale entry costs a
// mispredict, but not a wrong result.
//   0. the first program stopped normally
//   1. it left 0, 1, 4, ..., 225 in DMEM
//   2. IMEM holds the second program after reloading
//   3. the second program stopped normally
//   4. its sum is 1240

#include "../../apara_common.h"
#include "squares.mcode.h"
#include "sum.mcode.h"

int main(void)
{
	uint32_t ok = 0, i, same;

	apara_load_program(squares_program, SQUARES_PROGRAM_WORDS);
	apara_write_thread_register(0, 1, APARA_DMEM_BASE + 0x100);
	apara_start_thread(0, SQUARES_START);
	if (apara_wait_thread(0) == HALTED) ok |= 1 << 0;
	same = 1;
	for (i = 0; i < 16; i++)
		same &= dword_equals(0x100 + 8 * i, (int32_t) (i * i));
	if (same) ok |= 1 << 1;

	apara_load_program(sum_program, SUM_PROGRAM_WORDS);
	same = 1;
	for (i = 0; i < SUM_PROGRAM_WORDS; i++)
		same &= apara_read_imem(i) == sum_program[i];
	if (same) ok |= 1 << 2;
	apara_write_thread_register(0, 1, APARA_DMEM_BASE + 0x100);
	apara_start_thread(0, SUM_START);
	if (apara_wait_thread(0) == HALTED) ok |= 1 << 3;
	if (dword_equals(0x180, 1240)) ok |= 1 << 4;

	report_and_halt(ok, 5);
	return 0;
}

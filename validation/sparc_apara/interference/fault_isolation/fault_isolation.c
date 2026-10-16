// fault_isolation.c
//
// One thread's exception stops only that thread: four threads divide,
// thread 2 by zero. The others finish normally; thread 2 reports the
// exception, stops at the divide, and leaves its result word alone.
// After a reset it runs again, with a good divisor.
//   0. threads 0, 1 and 3 stopped normally with the right quotients
//   1. thread 2 reports exception code 1 (integer divide by zero) in slot 1
//   2. thread 2 stopped at the divide (PC 0) and stored nothing
//   3. after a reset and a new divisor, thread 2 runs normally
//   4. its new quotient is right

#include "../../apara_common.h"
#include "divide.mcode.h"

int main(void)
{
	uint32_t ok = 0, t, done[4];

	apara_load_program(divide_program, DIVIDE_PROGRAM_WORDS);
	for (t = 0; t < 4; t++)
	{
		apara_dmem_write_word(0x600 + 8 * t, 0xeeeeeeeeu);
		apara_dmem_write_word(0x604 + 8 * t, 0xeeeeeeeeu);
		apara_write_thread_register(t, 1, 1000 + t);
		apara_write_thread_register(t, 2, t == 2 ? 0 : t + 1);
		apara_write_thread_register(t, 3, APARA_DMEM_BASE + 0x600 + 8 * t);
	}
	for (t = 0; t < 4; t++)
		apara_start_thread(t, DIVIDE_START);
	for (t = 0; t < 4; t++)
		done[t] = apara_wait_thread(t);
	if (done[0] == HALTED && done[1] == HALTED && done[3] == HALTED && dword_equals(0x600, 1000)
	    && dword_equals(0x608, 1001 / 2) && dword_equals(0x618, 1003 / 4))
		ok |= 1 << 0;
	if ((done[2] & APARA_COMPLETION_VALID) && (done[2] & APARA_ERROR_EXCEPTION) && !(done[2] & APARA_ERROR_HALT)
	    && APARA_ERROR_CODE(done[2], 1) == 1)
		ok |= 1 << 1;
	if (apara_thread_stop_pc(2) == 0 && apara_dmem_read_word(0x610) == 0xeeeeeeeeu) ok |= 1 << 2;

	apara_reset_thread(2);
	apara_write_thread_register(2, 2, 7);
	apara_start_thread(2, DIVIDE_START);
	if (apara_wait_thread(2) == HALTED) ok |= 1 << 3;
	if (dword_equals(0x610, 1002 / 7)) ok |= 1 << 4;

	report_and_halt(ok, 5);
	return 0;
}

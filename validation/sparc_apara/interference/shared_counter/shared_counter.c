// shared_counter.c
//
// The race the APARA instruction set leaves to software: four threads
// each add 1, 1000 times, to one shared DMEM word, with a load, an add
// and a store. Another thread's update can fall between a thread's load
// and its store, and is then lost: the shared word ends below 4000.
// How many are lost depends on the timing, and the threads must run at
// the same time for any to be: in the timing model the SPARC takes a
// few hundred cycles to start each thread, so with only 50 passes each
// thread would be done before the next one started. (The
// instruction set has no atomic read-modify-write; threads should work
// on their own data, as each one's private counter here does, and let
// the SPARC combine the results.)
//   0. every private counter is exactly 1000
//   1. the shared counter is at least 1000 and at most 4000
//   2. the shared counter is below 4000: updates were lost
//   3. every thread stopped normally

#include "../../apara_common.h"
#include "counter.mcode.h"

int main(void)
{
	uint32_t ok = 0, t, normal = 1, exact = 1;

	apara_load_program(counter_program, COUNTER_PROGRAM_WORDS);
	for (t = 0; t < 4; t++)
	{
		apara_write_thread_register(t, 1, APARA_DMEM_BASE + 0x800);
		apara_write_thread_register(t, 2, APARA_DMEM_BASE + 0x900 + 8 * t);
		apara_write_thread_register(t, 3, 999);
	}
	for (t = 0; t < 4; t++)
		apara_start_thread(t, COUNTER_START);
	for (t = 0; t < 4; t++)
		normal &= apara_wait_thread(t) == HALTED;
	for (t = 0; t < 4; t++)
		exact &= dword_equals(0x900 + 8 * t, 1000);
	uint32_t shared = apara_dmem_read_word(0x804);
	if (exact) ok |= 1 << 0;
	if (apara_dmem_read_word(0x800) == 0 && shared >= 1000 && shared <= 4000) ok |= 1 << 1;
	if (shared < 4000) ok |= 1 << 2;
	if (normal) ok |= 1 << 3;

	report_and_halt(ok, 4);
	return 0;
}

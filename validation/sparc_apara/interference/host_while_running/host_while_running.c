// host_while_running.c
//
// The SPARC works on DMEM while an engine thread runs: it writes and
// reads back its own 1 KB region, and watches the thread's progress word,
// which only ever grows. Neither disturbs the other.
//   0. the SPARC's region reads back as written, during the run
//   1. the progress word never went down, and stayed within 0..300
//   2. the SPARC saw the thread part-way (not only before or after)
//   3. the thread stopped normally, with the final count 300

#include "../../apara_common.h"
#include "progress.mcode.h"

int main(void)
{
	uint32_t ok = 0, i, same = 1, monotonic = 1, partway = 0, last = 0;

	apara_load_program(progress_program, PROGRESS_PROGRAM_WORDS);
	apara_write_thread_register(0, 1, APARA_DMEM_BASE + 0x2000);
	apara_write_thread_register(0, 2, 299);
	apara_start_thread(0, PROGRESS_START);
	for (i = 0; i < 256; i++)
	{
		apara_dmem_write_word(0x3000 + 4 * i, 0xc0de0000u + i);
		uint32_t p = apara_dmem_read_word(0x2004);
		if (p < last || p > 300) monotonic = 0;
		if (p > 0 && p < 300) partway = 1;
		last = p;
	}
	for (i = 0; i < 256; i++)
		same &= apara_dmem_read_word(0x3000 + 4 * i) == 0xc0de0000u + i;
	if (same) ok |= 1 << 0;
	if (monotonic) ok |= 1 << 1;
	if (partway) ok |= 1 << 2;
	if (apara_wait_thread(0) == HALTED && dword_equals(0x2000, 300)) ok |= 1 << 3;

	report_and_halt(ok, 4);
	return 0;
}

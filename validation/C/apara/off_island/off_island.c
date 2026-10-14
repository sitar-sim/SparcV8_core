// off_island.c
//
// The engine reading and writing the SPARC's main memory directly.
//   0. the engine stops normally
//   1. it read the main-memory word ($r2)
//   2. it wrote twice that word to main memory

#include "../apara_common.h"
#include "kernel.mcode.h"

volatile uint32_t data[2] __attribute__((aligned(8))) = {0x01020304, 0};

int main(void)
{
	uint32_t ok = 0;
	apara_load_program(kernel_program, KERNEL_PROGRAM_WORDS);
	apara_write_thread_register(0, 1, (uint32_t) data);
	apara_start_thread(0, KERNEL_START);
	if (apara_wait_thread(0) == (APARA_COMPLETION_VALID | APARA_ERROR_HALT)) ok |= 1 << 0;
	if (apara_read_thread_register(0, 2) == 0x01020304) ok |= 1 << 1;
	if (physical_word(&data[1]) == 0x02040608) ok |= 1 << 2;

	report_and_halt(ok, 3);
	return 0;
}

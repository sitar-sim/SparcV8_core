// offload_interrupt.c
//
// A complete offload of an engine program compiled from C
// (vector_stats.c, by apcc.py, carried here as vector_stats.c.h): load
// the program, copy the 64 input values into DMEM by DMA at the address
// the compiler gave the array, start thread 0 at main, and go on with its own work until
// the engine's interrupt (IRL 14) reports the stop, and
// read the sum, minimum and maximum from DMEM.
//   0. the thread stopped with $halt
//   1. the sum is right
//   2. the minimum is right
//   3. the maximum is right
//   4. the interrupt came exactly once
//   5. the SPARC did its own work meanwhile (the engine ran in parallel)

#include "../../apara_common.h"
#include "ajit_mt_irc.h"
#include "vector_stats.c.h"

static int32_t data[64];
volatile uint32_t interrupts = 0;
volatile uint32_t completion = 0;

void engine_handler(void)
{
	completion = apara_thread_completion(0);   // the stop, reported once
	apara_clear_interrupt(0);
	interrupts++;
}

int main(void)
{
	uint32_t ok = 0, i, state = 3;
	int32_t sum = 0, lo, hi;
	ajit_initialize_interrupt_handlers_to_null();
	ajit_set_interrupt_handler(EXTERNAL_IRL, engine_handler);
	writeInterruptControlRegister(0, 0, (1u << EXTERNAL_IRL) | 1u);

	for (i = 0; i < 64; i++)
		data[i] = (int32_t) (next_random(&state) & 0xffff) - 32768;
	lo = hi = data[0];
	for (i = 0; i < 64; i++)
	{
		sum += data[i];
		if (data[i] < lo) lo = data[i];
		if (data[i] > hi) hi = data[i];
	}

	apara_load_program(vector_stats_program, VECTOR_STATS_PROGRAM_WORDS);
	apara_load_dmem_image(vector_stats_dmem_image, VECTOR_STATS_DMEM_IMAGE_WORDS);
	apara_dma_load(0, VECTOR_STATS_DMEM_DATA, (uint32_t) data, sizeof(data));
	apara_start_thread(0, VECTOR_STATS_MAIN);
	apara_request_completion_interrupt(0);
	uint32_t work = 0;
	while (interrupts == 0 && work < WAIT_LIMIT)
		work++;                                  // the SPARC's own work
	for (i = 0; i < 100; i++)                    // a second interrupt would come here
		;
	if (completion == HALTED) ok |= 1 << 0;
	if (interrupts == 1) ok |= 1 << 4;
	if (work > 0) ok |= 1 << 5;
	if (dword_equals(VECTOR_STATS_DMEM_SUM, sum)) ok |= 1 << 1;
	if (dword_equals(VECTOR_STATS_DMEM_MINIMUM, lo)) ok |= 1 << 2;
	if (dword_equals(VECTOR_STATS_DMEM_MAXIMUM, hi)) ok |= 1 << 3;

	report_and_halt(ok, 6);
	return 0;
}

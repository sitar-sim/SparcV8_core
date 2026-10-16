// offload_poll.c
//
// A complete offload of an engine program compiled from C
// (vector_stats.c, by apcc.py, carried here as vector_stats.c.h): load
// the program, copy the 64 input values into DMEM by DMA at the address
// the compiler gave the array, start thread 0 at main, poll until it stops, and
// read the sum, minimum and maximum from DMEM.
//   0. the thread stopped with $halt
//   1. the sum is right
//   2. the minimum is right
//   3. the maximum is right

#include "../../apara_common.h"
#include "vector_stats.c.h"

static int32_t data[64];

int main(void)
{
	uint32_t ok = 0, i, state = 3;
	int32_t sum = 0, lo, hi;

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
	if (apara_wait_thread(0) == HALTED) ok |= 1 << 0;
	if (dword_equals(VECTOR_STATS_DMEM_SUM, sum)) ok |= 1 << 1;
	if (dword_equals(VECTOR_STATS_DMEM_MINIMUM, lo)) ok |= 1 << 2;
	if (dword_equals(VECTOR_STATS_DMEM_MAXIMUM, hi)) ok |= 1 << 3;

	report_and_halt(ok, 4);
	return 0;
}

// dot_threads.c
//
// A 1024-element int8 dot product split over the engine's four threads,
// the engine program compiled from C (dot_part.c): the SPARC passes each
// thread its part as the entry function's arguments ($r1..$r3), adds up
// the partial results, and checks them against its own.
//   0-3. thread t stopped normally with the right partial result
//   4. the whole dot product is right

#include "../../apara_common.h"
#include "dot_part.c.h"

static int8_t A[1024];
static int8_t B[1024];

int main(void)
{
	uint32_t ok = 0, i, t, state = 17;
	int32_t total = 0, whole = 0;

	for (i = 0; i < 1024; i++)
	{
		A[i] = (int8_t) next_random(&state);
		B[i] = (int8_t) next_random(&state);
		whole += (int32_t) A[i] * (int32_t) B[i];
	}
	apara_load_program(dot_part_program, DOT_PART_PROGRAM_WORDS);
	apara_dma_load(0, DOT_PART_DMEM_A, (uint32_t) A, 1024);
	apara_dma_load(1, DOT_PART_DMEM_B, (uint32_t) B, 1024);
	for (t = 0; t < 4; t++)
	{
		apara_write_thread_register(t, 1, t);
		apara_write_thread_register(t, 2, 256 * t);
		apara_write_thread_register(t, 3, 256);
		apara_start_thread(t, DOT_PART_PART);
	}
	for (t = 0; t < 4; t++)
	{
		uint32_t done = apara_wait_thread(t);
		int32_t part = 0;
		for (i = 256 * t; i < 256 * (t + 1); i++)
			part += (int32_t) A[i] * (int32_t) B[i];
		if (done == HALTED && dword_equals(DOT_PART_DMEM_PARTIAL + 8 * t, part)) ok |= 1u << t;
		total += (int32_t) apara_dmem_read_word(DOT_PART_DMEM_PARTIAL + 8 * t + 4);
	}
	if (total == whole) ok |= 1 << 4;

	report_and_halt(ok, 5);
	return 0;
}

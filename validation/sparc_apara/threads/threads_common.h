// threads_common.h
//
// Shared by threads_1 .. threads_4: a dot product of two 512-element
// int8 vectors split among `n` engine threads (dot_kernel.mcode). A is
// copied to DMEM 0 and B to DMEM 0x200 by DMA; thread t gets a run of the
// 16 32-byte blocks and stores its partial result at 0x400 + 8t.
//   0-3. thread t (if used) stopped with $halt, and its partial result is right
//   4. the partial results add up to the whole dot product

#ifndef THREADS_COMMON_H
#define THREADS_COMMON_H

#include "../apara_common.h"
#include "dot_kernel.mcode.h"

#define ELEMENTS 512
#define BLOCKS   16

static int8_t A[ELEMENTS];
static int8_t B[ELEMENTS];

static int32_t dot(uint32_t first, uint32_t count)
{
	int32_t s = 0;
	uint32_t i;
	for (i = first; i < first + count; i++)
		s += (int32_t) A[i] * (int32_t) B[i];
	return s;
}

static void run_threads(uint32_t n)
{
	uint32_t ok = 0, i, t, state = 11, first = 0, firsts[4], counts[4];
	int32_t total = 0;

	for (i = 0; i < ELEMENTS; i++)
	{
		A[i] = (int8_t) next_random(&state);
		B[i] = (int8_t) next_random(&state);
	}
	apara_load_program(dot_kernel_program, DOT_KERNEL_PROGRAM_WORDS);
	apara_dma_start(0, APARA_DMA_LOAD, (uint32_t) A, 0x000, 1, 0, ELEMENTS, 0);
	apara_dma_start(1, APARA_DMA_LOAD, (uint32_t) B, 0x200, 1, 0, ELEMENTS, 0);
	apara_dma_wait(0);
	apara_dma_wait(1);

	for (t = 0; t < n; t++)
	{
		counts[t] = BLOCKS / n + (t < BLOCKS % n ? 1 : 0);
		firsts[t] = first;
		first += counts[t];
		apara_write_thread_register(t, 1, APARA_DMEM_BASE + 0x000 + 32 * firsts[t]);
		apara_write_thread_register(t, 2, APARA_DMEM_BASE + 0x200 + 32 * firsts[t]);
		apara_write_thread_register(t, 3, counts[t] - 1);
		apara_write_thread_register(t, 4, APARA_DMEM_BASE + 0x400 + 8 * t);
	}
	for (t = 0; t < n; t++)
		apara_start_thread(t, DOT_KERNEL_START);
	for (t = 0; t < 4; t++)
	{
		if (t >= n)
		{
			ok |= 1u << t;   // unused
			continue;
		}
		uint32_t done = apara_wait_thread(t);
		int32_t part = dot(32 * firsts[t], 32 * counts[t]);
		total += part;
		if (done == HALTED && dword_equals(0x400 + 8 * t, part)) ok |= 1u << t;
	}
	int32_t sum = 0;
	for (t = 0; t < n; t++)
		sum += (int32_t) apara_dmem_read_word(0x400 + 8 * t + 4);
	if (sum == dot(0, ELEMENTS) && total == sum) ok |= 1 << 4;

	report_and_halt(ok, 5);
}

#endif

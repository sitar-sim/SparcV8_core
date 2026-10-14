// dma_dot_product.c
//
// A whole offload: two vectors from main memory into the engine's DMEM by
// DMA (two channels at once), the engine's dot product, the result back
// to main memory by DMA.
//   0. both DMA loads complete without error
//   1. the engine stops normally
//   2. the DMA store completes without error
//   3. the result in main memory is the SPARC's own dot product

#include "../apara_common.h"
#include "kernel.mcode.h"

#define N 32
int8_t a[N] __attribute__((aligned(8)));
int8_t b[N] __attribute__((aligned(8)));
volatile uint32_t result[2] __attribute__((aligned(8)));

int main(void)
{
	uint32_t ok = 0;
	int i, expected = 0;
	for (i = 0; i < N; i++)
	{
		a[i] = (int8_t) (i - 10);
		b[i] = (int8_t) (3 * i - 50);
		expected += a[i] * b[i];
	}

	apara_load_program(kernel_program, KERNEL_PROGRAM_WORDS);
	apara_dma_start(0, APARA_DMA_LOAD, (uint32_t) a, 0, 1, 0, N, 0);
	apara_dma_start(1, APARA_DMA_LOAD, (uint32_t) b, 256, 1, 0, N, 0);
	uint32_t s0 = apara_dma_wait(0), s1 = apara_dma_wait(1);
	if (!(s0 & APARA_DMA_FLAG_ERROR) && !(s1 & APARA_DMA_FLAG_ERROR)) ok |= 1 << 0;

	apara_write_thread_register(0, 9, APARA_DMEM_BASE);
	apara_write_thread_register(0, 10, APARA_DMEM_BASE + 256);
	apara_start_thread(0, KERNEL_START);
	if (apara_wait_thread(0) == (APARA_COMPLETION_VALID | APARA_ERROR_HALT)) ok |= 1 << 1;

	if (!(apara_dma_store(2, (uint32_t) result, 504, 8) & APARA_DMA_FLAG_ERROR)) ok |= 1 << 2;
	uint32_t hi = physical_word(&result[0]), lo = physical_word(&result[1]);
	if (lo == (uint32_t) expected && hi == (expected < 0 ? 0xffffffffu : 0)) ok |= 1 << 3;

	report_and_halt(ok, 4);
	return 0;
}

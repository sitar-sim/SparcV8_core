// dma_while_running.c
//
// The DMA unit copying into and out of DMEM while engine threads run on
// other parts of it: four threads compute the dot product (Ref
// ../../threads/) while two channels load 2 KB elsewhere in DMEM and a
// third copies another block out.
//   0. every thread's result is right
//   1. the 2 KB loaded during the run is all in DMEM
//   2. the block copied out during the run arrived in main memory
//   3. every thread stopped normally, every copy without error

#include "../../threads/threads_common.h"

static uint32_t incoming[512];
static uint32_t outgoing[64];

int main(void)
{
	uint32_t ok = 0, i, t, state = 9, same, normal = 1, right = 1;

	for (i = 0; i < ELEMENTS; i++)
	{
		A[i] = (int8_t) next_random(&state);
		B[i] = (int8_t) next_random(&state);
	}
	for (i = 0; i < 512; i++)
		incoming[i] = 0xd0000000u + i;
	for (i = 0; i < 64; i++)
		apara_dmem_write_word(0x5000 + 4 * i, 0x0b000000u + i);
	apara_load_program(dot_kernel_program, DOT_KERNEL_PROGRAM_WORDS);
	apara_dma_load(0, 0x000, (uint32_t) A, ELEMENTS);
	apara_dma_load(1, 0x200, (uint32_t) B, ELEMENTS);
	for (t = 0; t < 4; t++)
	{
		apara_write_thread_register(t, 1, APARA_DMEM_BASE + 0x000 + 128 * t);
		apara_write_thread_register(t, 2, APARA_DMEM_BASE + 0x200 + 128 * t);
		apara_write_thread_register(t, 3, 3);
		apara_write_thread_register(t, 4, APARA_DMEM_BASE + 0x400 + 8 * t);
		apara_start_thread(t, DOT_KERNEL_START);
	}
	apara_dma_start(0, APARA_DMA_LOAD, (uint32_t) incoming, 0x4000, 1, 0, 1024, 0);
	apara_dma_start(1, APARA_DMA_LOAD, (uint32_t) (incoming + 256), 0x4400, 1, 0, 1024, 0);
	apara_dma_start(2, APARA_DMA_STORE, 0x5000, (uint32_t) outgoing, 1, 0, 256, 0);
	uint32_t c0 = apara_dma_wait(0), c1 = apara_dma_wait(1), c2 = apara_dma_wait(2);
	for (t = 0; t < 4; t++)
	{
		normal &= apara_wait_thread(t) == HALTED;
		right &= dword_equals(0x400 + 8 * t, dot(128 * t, 128));
	}
	if (right) ok |= 1 << 0;
	same = 1;
	for (i = 0; i < 512; i++)
		same &= apara_dmem_read_word(0x4000 + 4 * i) == 0xd0000000u + i;
	if (same) ok |= 1 << 1;
	same = 1;
	for (i = 0; i < 64; i++)
		same &= physical_word(&outgoing[i]) == 0x0b000000u + i;
	if (same) ok |= 1 << 2;
	if (normal && !((c0 | c1 | c2) & APARA_DMA_FLAG_ERROR)) ok |= 1 << 3;

	report_and_halt(ok, 4);
	return 0;
}

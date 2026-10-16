// load_verify.c
//
// Loading the engine and reading back what was loaded: a 512-word
// program image into IMEM (through the control unit), 1 KB of DMEM
// written directly through the window, and 1 KB copied into DMEM by DMA
// and copied back out again.
//   0. IMEM words 0..511 read back as written
//   1. DMEM bytes 0..1023 (direct writes) read back
//   2. DMEM bytes 1024..2047 (a DMA load) read back directly
//   3. the same block, copied back to main memory by a DMA store, matches
//   4. neither DMA copy reported an error

#include "../../apara_common.h"

static uint32_t program[512];
static uint32_t block_in[256];
static uint32_t block_out[256];

int main(void)
{
	uint32_t ok = 0, i, same, state = 7;

	for (i = 0; i < 512; i++)
		program[i] = (next_random(&state) << 8) ^ next_random(&state);
	apara_load_program(program, 512);
	same = 1;
	for (i = 0; i < 512; i++)
		same &= apara_read_imem(i) == program[i];
	if (same) ok |= 1 << 0;

	for (i = 0; i < 256; i++)
		apara_dmem_write_word(4 * i, i * 0x01010101u ^ 0x5a000000u);
	same = 1;
	for (i = 0; i < 256; i++)
		same &= apara_dmem_read_word(4 * i) == (i * 0x01010101u ^ 0x5a000000u);
	if (same) ok |= 1 << 1;

	for (i = 0; i < 256; i++)
		block_in[i] = (next_random(&state) << 8) ^ i;
	uint32_t load = apara_dma_load(0, 1024, (uint32_t) block_in, 1024);
	same = 1;
	for (i = 0; i < 256; i++)
		same &= apara_dmem_read_word(1024 + 4 * i) == block_in[i];
	if (same) ok |= 1 << 2;

	uint32_t store = apara_dma_store(1, (uint32_t) block_out, 1024, 1024);
	same = 1;
	for (i = 0; i < 256; i++)
		same &= physical_word(&block_out[i]) == block_in[i];
	if (same) ok |= 1 << 3;
	if (!(load & APARA_DMA_FLAG_ERROR) && !(store & APARA_DMA_FLAG_ERROR)) ok |= 1 << 4;

	report_and_halt(ok, 5);
	return 0;
}

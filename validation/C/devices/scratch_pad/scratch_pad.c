// scratch_pad.c
//
// The scratch-pad at 0xFFFF2C00: 32 words, all 0 at reset, picked by
// address bits [6:2] so they repeat every 128 bytes across the 1 KB
// range. Byte and doubleword stores reach it through the bus like any
// other device access.

#include "../devices_common.h"

#define SCRATCH_PAD ((volatile uint32_t*) 0xFFFF2C00)

int main(void)
{
	uint32_t ok = 0;
	volatile uint8_t*  sp_bytes = (volatile uint8_t*) SCRATCH_PAD;
	volatile uint64_t* sp_dwords = (volatile uint64_t*) SCRATCH_PAD;

	// 0: reset value
	if (SCRATCH_PAD[0] == 0 && SCRATCH_PAD[31] == 0) ok |= 1 << 0;

	// 1: word store and load, words independent
	SCRATCH_PAD[0] = 0x11111111;
	SCRATCH_PAD[1] = 0x22222222;
	if (SCRATCH_PAD[0] == 0x11111111 && SCRATCH_PAD[1] == 0x22222222) ok |= 1 << 1;

	// 2: aliasing, word 2 repeats 128 bytes (32 words) and 896 bytes later
	SCRATCH_PAD[2] = 0xCAFEF00D;
	if (SCRATCH_PAD[2 + 32] == 0xCAFEF00D && SCRATCH_PAD[2 + 224] == 0xCAFEF00D) ok |= 1 << 2;

	// 3: a byte store changes only its byte
	sp_bytes[1] = 0xAA;
	if (SCRATCH_PAD[0] == 0x11AA1111) ok |= 1 << 3;

	// 4: a doubleword store writes two words, the first at the lower address
	sp_dwords[2] = 0x0102030405060708ULL;
	if (SCRATCH_PAD[4] == 0x01020304 && SCRATCH_PAD[5] == 0x05060708) ok |= 1 << 4;

	report_and_halt(ok, 5);
	return 0;
}

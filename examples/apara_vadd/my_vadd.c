// my_vadd.c: the SPARC offloads Z = X + Y, on 32 int16 elements, to the
// APARA engine, and checks the engine's result.

#include "apara_access_routines.h"
#include "vadd.mcode.h"

#define N 32
int16_t x[N] __attribute__((aligned(8)));
int16_t y[N] __attribute__((aligned(8)));

int main(void)
{
	uint32_t pass = 1;
	int i;

	for (i = 0; i < N; i++)
	{
		x[i] = (int16_t) (100 * i - 1000);
		y[i] = (int16_t) (7 * i);
	}

	apara_load_program(vadd_program, VADD_PROGRAM_WORDS);    // the engine's program
	apara_dma_load(0, 0, (uint32_t) x, sizeof(x));            // x -> DMEM offset 0
	apara_dma_load(1, 64, (uint32_t) y, sizeof(y));           // y -> DMEM offset 64

	apara_write_thread_register(0, 9, APARA_DMEM_BASE);      // $r9 = DMEM's window
	apara_start_thread(0, VADD_START);
	if (apara_wait_thread(0) != (APARA_COMPLETION_VALID | APARA_ERROR_HALT))
		pass = 0;

	// Z, at DMEM offset 128: two int16 elements in each 32-bit word.
	for (i = 0; i < N; i += 2)
	{
		uint32_t w = apara_dmem_read_word(128 + 2 * i);
		int16_t z0 = (int16_t) (w >> 16), z1 = (int16_t) w;
		if (z0 != (int16_t) (x[i] + y[i]) || z1 != (int16_t) (x[i + 1] + y[i + 1]))
			pass = 0;
	}

	// Report pass (1) or fail (0) in %o0, and halt.
	__asm__ __volatile__("mov %0, %%o0\n\tta 0" : : "r"(pass) : "o0");
	while (1) {}
	return 0;
}

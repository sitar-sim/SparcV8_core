// saxpy.c
//
// y = a*x + y on 32 floats, offloaded to an engine program compiled from
// C (saxpy_kernel.c). The values are chosen so every result is exact in
// single precision; the SPARC computes the same with its own FPU (which
// it first turns on) and compares bit for bit.
//   0. the thread stopped normally
//   1. every y[i] is right

#include "../../apara_common.h"
#include "saxpy_kernel.c.h"

static float x[32];
static float y[32];
static float expected[32];

int main(void)
{
	uint32_t ok = 0, i, right = 1;
	enable_fpu();
	float a = 1.5f;
	union { float f; uint32_t u; } bits;

	for (i = 0; i < 32; i++)
	{
		x[i] = (float) ((int32_t) i - 16) * 0.25f;
		y[i] = (float) (3 * (int32_t) i - 40) * 0.5f;
		expected[i] = a * x[i] + y[i];
	}
	apara_load_program(saxpy_kernel_program, SAXPY_KERNEL_PROGRAM_WORDS);
	apara_dma_load(0, SAXPY_KERNEL_DMEM_X, (uint32_t) x, sizeof(x));
	apara_dma_load(1, SAXPY_KERNEL_DMEM_Y, (uint32_t) y, sizeof(y));
	bits.f = a;
	apara_dmem_write_word(SAXPY_KERNEL_DMEM_A, bits.u);
	apara_start_thread(0, SAXPY_KERNEL_MAIN);
	if (apara_wait_thread(0) == HALTED) ok |= 1 << 0;
	for (i = 0; i < 32; i++)
	{
		bits.f = expected[i];
		right &= apara_dmem_read_word(SAXPY_KERNEL_DMEM_Y + 4 * i) == bits.u;
	}
	if (right) ok |= 1 << 1;

	report_and_halt(ok, 2);
	return 0;
}

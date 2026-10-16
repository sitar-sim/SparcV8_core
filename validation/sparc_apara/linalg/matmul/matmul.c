// matmul.c
//
// An 8x8 int8 matrix product on four engine threads (two rows each, Ref
// matmul.mcode): A and B transposed go to DMEM by DMA, C (int64) comes
// back to main memory by DMA, and the SPARC compares it with its own
// product.
//   0-3. thread t stopped normally
//   4. C is right, all 64 entries

#include "../../apara_common.h"
#include "matmul.mcode.h"

static int8_t A[8][8];
static int8_t BT[8][8];
static uint32_t C[128];       // 64 int64 entries, as big-endian word pairs

int main(void)
{
	uint32_t ok = 0, i, j, k, t, state = 13, right = 1;

	for (i = 0; i < 8; i++)
		for (j = 0; j < 8; j++)
		{
			A[i][j] = (int8_t) next_random(&state);
			BT[j][i] = (int8_t) next_random(&state);
		}
	apara_load_program(matmul_program, MATMUL_PROGRAM_WORDS);
	apara_dma_load(0, 0x00, (uint32_t) A, 64);
	apara_dma_load(1, 0x40, (uint32_t) BT, 64);
	for (t = 0; t < 4; t++)
	{
		apara_write_thread_register(t, 20, APARA_DMEM_BASE + 16 * t);
		apara_write_thread_register(t, 21, APARA_DMEM_BASE + 0x100 + 128 * t);
		apara_write_thread_register(t, 22, 1);
		apara_write_thread_register(t, 23, APARA_DMEM_BASE);
		apara_start_thread(t, MATMUL_START);
	}
	for (t = 0; t < 4; t++)
		if (apara_wait_thread(t) == HALTED) ok |= 1u << t;
	apara_dma_store(2, (uint32_t) C, 0x100, 512);
	for (i = 0; i < 8; i++)
		for (j = 0; j < 8; j++)
		{
			int32_t c = 0;
			for (k = 0; k < 8; k++)
				c += (int32_t) A[i][k] * (int32_t) BT[j][k];
			right &= physical_word(&C[2 * (8 * i + j)]) == (c < 0 ? 0xffffffffu : 0u)
			      && physical_word(&C[2 * (8 * i + j) + 1]) == (uint32_t) c;
		}
	if (right) ok |= 1 << 4;

	report_and_halt(ok, 5);
	return 0;
}

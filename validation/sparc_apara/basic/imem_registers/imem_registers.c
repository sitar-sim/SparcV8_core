// imem_registers.c
//
// The engine's IMEM and thread registers through its control unit (CCU).
//   0. IMEM words written read back
//   1. a 64-bit register written to thread 1 reads back
//   2. thread 3's register is separate from thread 1's
//   3. the engine's timer advances

#include "../../apara_common.h"

int main(void)
{
	uint32_t ok = 0;
	apara_write_imem(0, 0x80000000);
	apara_write_imem(4095, 0xdeadbeef);
	if (apara_read_imem(0) == 0x80000000 && apara_read_imem(4095) == 0xdeadbeef) ok |= 1 << 0;

	apara_write_thread_register(1, 5, 0x0123456789abcdefULL);
	apara_write_thread_register(3, 5, 0x1111111122222222ULL);
	if (apara_read_thread_register(1, 5) == 0x0123456789abcdefULL) ok |= 1 << 1;
	if (apara_read_thread_register(3, 5) == 0x1111111122222222ULL) ok |= 1 << 2;

	uint64_t t0 = apara_read_timer();
	uint64_t t1 = apara_read_timer();
	if (t1 > t0) ok |= 1 << 3;

	report_and_halt(ok, 4);
	return 0;
}

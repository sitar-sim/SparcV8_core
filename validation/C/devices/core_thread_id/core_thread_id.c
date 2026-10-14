// core_thread_id.c
//
// ASR29 reads as the hardwired core/thread ID word, (core << 8) | thread,
// and ignores writes. This single-core model is core 0, thread 0.

#include "../devices_common.h"

int main(void)
{
	uint32_t ok = 0;
	uint8_t core_id = 0xff, thread_id = 0xff;

	ajit_get_core_and_thread_id(&core_id, &thread_id);
	if (core_id == 0 && thread_id == 0) ok |= 1 << 0;

	__asm__ __volatile__("wr %%g0, 0x123, %%asr29" : : );
	if (__ajit_read_core_thread_id_word__() == 0) ok |= 1 << 1;

	report_and_halt(ok, 2);
	return 0;
}

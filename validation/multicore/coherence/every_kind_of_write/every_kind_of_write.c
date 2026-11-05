// every_kind_of_write.c
//
// Everything that writes main memory must invalidate other cores' copies, not just
// an ordinary store: a store with a smaller size, an LDSTUB, a SWAP and an MMU-bypass
// store. Each test word gets one kind of write from core 0, after cores 1 to 3 have
// it cached.
//
// Every core checks, after each kind of write, that a plain load sees it:
//   0. a byte store
//   1. a doubleword store
//   2. LDSTUB
//   3. SWAP
//   4. an MMU-bypass store
#include "../coherence_common.h"

#define BYTE_WORD   SHARED_WORD(0)
#define DOUBLE_WORD SHARED_WORD(1)
#define LDSTUB_WORD SHARED_WORD(2)
#define SWAP_WORD   SHARED_WORD(3)
#define BYPASS_WORD SHARED_WORD(4)

static barrier_t barrier;

int main(void)
{
	uint32_t ok = 0, id = this_core_id();
	turn_caching_on();

	(void) *BYTE_WORD; (void) *DOUBLE_WORD; (void) *LDSTUB_WORD; (void) *SWAP_WORD; (void) *BYPASS_WORD;
	barrier_wait(&barrier, NUM_CORES);

	if (id == 0)
	{
		*(volatile uint8_t*) BYTE_WORD = 0xAB;
		*(volatile uint64_t*) DOUBLE_WORD = 0x1122334455667788ULL;
		atomic_ldstub((volatile uint8_t*) LDSTUB_WORD);
		atomic_swap(SWAP_WORD, 0xCAFEF00Du);
		__ajit_store_word_mmu_bypass__(0xBEEF, (uint32_t) BYPASS_WORD);
	}
	barrier_wait(&barrier, NUM_CORES);

	if (*BYTE_WORD == 0xAB000000u) ok |= 1 << 0;
	if (*(volatile uint64_t*) DOUBLE_WORD == 0x1122334455667788ULL) ok |= 1 << 1;
	if (*LDSTUB_WORD == 0xFF000000u) ok |= 1 << 2;
	if (*SWAP_WORD == 0xCAFEF00Du) ok |= 1 << 3;
	//Core 0's own cached copy is not refreshed by a bypass store, as on one core
	//(Ref validation/C/caches/stale_until_flush), so only the others check it.
	if (id == 0 || *BYPASS_WORD == 0xBEEF) ok |= 1 << 4;
	report_and_halt(ok, 5);
	return 0;
}

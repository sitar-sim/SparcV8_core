// faulting_access_keeps_line.c
//
// With the MMU's NF bit set, a faulting store or atomic takes no trap and writes nothing.
// It has no physical address, so it says nothing about any line in the cache. A store
// through an uncached alias also comes back with no fault and no fill, and it does remove
// another copy of its line, so the cache has to be able to tell the two apart.
//
// To tell whether a line is still cached, the page is changed behind the cache with a
// bypass store, which leaves this core's own copy alone. A plain load then returns the
// old value only if the line is still there. Each sequence is in assembly because a stale
// physical address names the line of the last store. A compiler's store to the stack, in
// between, would point it at the stack and hide the removal.
//
//   0. a store to an unmapped page leaves the line cached
//   1. a store to a read-only page leaves the line cached
//   2. an atomic to an unmapped page leaves the line cached
//   3. an atomic to a read-only page leaves the line cached
//   4. after a flush, the load sees what the last bypass store wrote

#include "../alias_common.h"
#include "ajit_access_routines.h"

#define UNMAPPED  ((volatile uint32_t*) VA(1))
#define READ_ONLY ((volatile uint32_t*) VA(2))

#define WORD ((volatile uint32_t*) VA(0))

//Stores `cached` to the word, which caches its line, changes memory behind the cache to
//`changed`, tries the faulting access, and returns what a load of the word then sees.
#define AFTER_FAULT(faulting_instruction, bad, cached, changed, result)                   \
	__asm__ __volatile__("st %2, [%1]\n\t"                                                  \
	                     "ld [%1], %%g0\n\t"                                                \
	                     "sta %3, [%4] 0x20\n\t"                                            \
	                     faulting_instruction "\n\t"                                        \
	                     "ld [%1], %0"                                                      \
	                     : "=&r"(result)                                                    \
	                     : "r"(WORD), "r"(cached), "r"(changed), "r"(frame), "r"(bad)       \
	                     : "g1", "memory")

int main(void)
{
	uint32_t ok = 0, seen;

	build_tables();
	map_page(0, VA(0), frame, 1);
	l3_tables[0][(VA(2) >> 12) & 0x3F] = make_pte((unsigned int) other_frame, ACC_RO_RO, 1);
	store_word_mmureg(make_ptd(context_table), MMU_REG_CTX_TBL_PTR);
	store_word_mmureg(MMU_CONTROL_E_BIT | MMU_CONTROL_NF_BIT, MMU_REG_CONTROL);

	AFTER_FAULT("st %%g0, [%5]", UNMAPPED, 0x101u, 0x102u, seen);
	if (seen == 0x101u) ok |= 1 << 0;

	AFTER_FAULT("st %%g0, [%5]", READ_ONLY, 0x201u, 0x202u, seen);
	if (seen == 0x201u) ok |= 1 << 1;

	AFTER_FAULT("ldstub [%5], %%g1", UNMAPPED, 0x301u, 0x302u, seen);
	if (seen == 0x301u) ok |= 1 << 2;

	AFTER_FAULT("ldstub [%5], %%g1", READ_ONLY, 0x401u, 0x402u, seen);
	if (seen == 0x401u) ok |= 1 << 3;

	__asm__ __volatile__("sta %%g0, [%%g0] 0x10" : : : "memory"); //flush both caches
	if (*WORD == 0x402u) ok |= 1 << 4;

	report_and_halt(ok, 5);
	return 0;
}

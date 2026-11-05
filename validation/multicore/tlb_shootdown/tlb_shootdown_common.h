// tlb_shootdown_common.h
//
// Shared by the tests in validation/multicore/tlb_shootdown/. They use the page table setup of
// ../mmu_coherence/, and the shootdown in multicore_platform.h.

#ifndef TLB_SHOOTDOWN_COMMON_H
#define TLB_SHOOTDOWN_COMMON_H

#include "../mmu_coherence/mmu_coherence_common.h"
#include "multicore_platform.h"

// Writes a page table entry straight to memory.
static inline void write_pte(uint32_t context, uint32_t va, void* physical, uint32_t acc)
{
	__ajit_store_word_mmu_bypass__(make_pte((unsigned int) physical, acc, 1),
	                               (uint32_t) &l3_tables[context][(va >> 12) & 0x3F]);
}

#endif

// mmu_coherence_common.h
//
// Shared by the tests in validation/multicore/mmu_coherence/. They are the coherence
// tests with the MMU on, where a virtual and a physical address differ. Each core has
// its own view of a shared physical page, in some combination of virtual address and
// context, so an invalidate has to find a line from its physical address alone.
//
// Core 0 builds the page tables and each core then turns on its own MMU. The code, the
// stack, the barrier and the rest of the program's data stay identity mapped and
// cacheable, by setup_safe_l1_table(), so read_shared() still works on them, and
// everything is cached. Each core can then pick its context freely.

#ifndef MMU_COHERENCE_COMMON_H
#define MMU_COHERENCE_COMMON_H

#include "../multicore_common.h"
#include "multicore_sync.h"
#include "../../C/mmu/mmu_common.h"

#define CONTEXTS NUM_CORES

static unsigned int context_table[256]              __attribute__((aligned(1024)));
static unsigned int per_core_context_tables[NUM_CORES][256] __attribute__((aligned(1024)));
static unsigned int l1_tables[CONTEXTS][256]        __attribute__((aligned(1024)));
static unsigned int l2_tables[CONTEXTS][64]         __attribute__((aligned(1024)));
static unsigned int l3_tables[CONTEXTS][64]         __attribute__((aligned(1024)));

static unsigned int frame[1024]       __attribute__((aligned(4096)));
static unsigned int other_frames[NUM_CORES][1024] __attribute__((aligned(4096)));

// Virtual addresses in the mapped window, one page apart, so each is in a different set
// of the default cache. VA(p) + 0x8000 is in the same set as VA(p).
#define VA(page) (TEST_VA_BASE | (0x00010000u + (page) * 0x1000u))

// Scratch-pad word 12, which core 0 sets once the tables are ready.
#define TABLES_READY 0xFFFF2C30u

static barrier_t barrier;

static inline void sync_cores(void)
{
	barrier_wait(&barrier, NUM_CORES);
}

// Call on core 0, once per context a test uses, before map_page() and release_tables().
static void build_context(uint32_t context)
{
	l2_tables[context][(VA(0) >> 18) & 0x3F] = make_ptd(l3_tables[context]);
	setup_safe_l1_table(l1_tables[context], make_ptd(l2_tables[context]));
	context_table[context] = make_ptd(l1_tables[context]);
}

static void map_page(uint32_t context, uint32_t va, void* physical)
{
	l3_tables[context][(va >> 12) & 0x3F] = make_pte((unsigned int) physical, ACC_RWX_RWX, 1);
}

// Core 0 says the tables are ready, and the other cores wait for that.
static void release_tables(void)
{
	__ajit_store_word_mmu_bypass__(1, TABLES_READY);
}

static void wait_for_tables(void)
{
	while (__ajit_load_word_mmu_bypass__(TABLES_READY) != 1)
		;
}

static void set_context(uint32_t context)
{
	store_word_mmureg(context, MMU_REG_CONTEXT);
}

// Turns on this core's MMU, using the context table every core shares.
static void start_mmu(uint32_t context)
{
	store_word_mmureg(make_ptd(context_table), MMU_REG_CTX_TBL_PTR);
	set_context(context);
	store_word_mmureg(MMU_CONTROL_E_BIT, MMU_REG_CONTROL);
}

// Every kind of write, from core 0 through `writer`, each seen by every core through
// its own address `mine`. Every core calls this with its own `mine`. Five checks:
//   0. a store
//   1. a byte store
//   2. LDSTUB
//   3. SWAP
//   4. the store again, after all of them
static uint32_t check_every_kind_of_write(volatile uint32_t* writer, volatile uint32_t* mine)
{
	uint32_t ok = 0, id = this_core_id();

	(void) *mine;
	sync_cores();
	if (id == 0) *writer = 0x00001111u;
	sync_cores();
	if (*mine == 0x00001111u) ok |= 1 << 0;
	sync_cores();

	if (id == 0) *(volatile uint8_t*) writer = 0xAB;
	sync_cores();
	if (*mine == 0xAB001111u) ok |= 1 << 1;
	sync_cores();

	if (id == 0) atomic_ldstub((volatile uint8_t*) writer);
	sync_cores();
	if (*mine == 0xFF001111u) ok |= 1 << 2;
	sync_cores();

	if (id == 0) atomic_swap(writer, 0x00002222u);
	sync_cores();
	if (*mine == 0x00002222u) ok |= 1 << 3;
	sync_cores();

	if (id == 0) *writer = 0x00003333u;
	sync_cores();
	if (*mine == 0x00003333u) ok |= 1 << 4;
	sync_cores();

	return ok;
}

#endif

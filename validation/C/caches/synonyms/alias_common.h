// alias_common.h
//
// Shared by the tests in validation/C/caches/synonyms/. Each test maps one physical
// page at two "aliases", in some combination of virtual address and MMU context,
// with the MMU on, and calls check_alias_pair(). A cache holds at most one copy of
// a physical line, so a write through one alias must always be seen through the other.
//
// Both contexts map the code and stack the same way, by setup_safe_l1_table(), so a
// program can change context anywhere.

#ifndef ALIAS_COMMON_H
#define ALIAS_COMMON_H

#include <stdint.h>
#include "../../mmu/mmu_common.h"

#define CONTEXTS 2

static unsigned int context_table[256]     __attribute__((aligned(1024)));
static unsigned int l1_tables[CONTEXTS][256] __attribute__((aligned(1024)));
static unsigned int l2_tables[CONTEXTS][64]  __attribute__((aligned(1024)));
static unsigned int l3_tables[CONTEXTS][64]  __attribute__((aligned(1024)));
static unsigned int frame[1024]              __attribute__((aligned(4096)));
static unsigned int other_frame[1024]        __attribute__((aligned(4096)));

// Virtual addresses in the mapped window, one page apart. Page 0 and page 8 are in
// the same set of a 32 KB direct-mapped cache, and pages 0 and 4 of a 2-way one.
#define VA(page) (TEST_VA_BASE | (0x00010000u + (page) * 0x1000u))

typedef struct
{
	volatile uint32_t* word;
	uint32_t           context;
} alias_t;

static void build_tables(void)
{
	unsigned int c;
	for (c = 0; c < CONTEXTS; c++)
	{
		l2_tables[c][(VA(0) >> 18) & 0x3F] = make_ptd(l3_tables[c]);
		setup_safe_l1_table(l1_tables[c], make_ptd(l2_tables[c]));
		context_table[c] = make_ptd(l1_tables[c]);
	}
}

static void map_page(uint32_t context, uint32_t va, void* physical, uint32_t cacheable)
{
	l3_tables[context][(va >> 12) & 0x3F] = make_pte((unsigned int) physical, ACC_RWX_RWX, cacheable);
}

static void enable_mmu(void)
{
	store_word_mmureg(make_ptd(context_table), MMU_REG_CTX_TBL_PTR);
	store_word_mmureg(MMU_CONTROL_E_BIT, MMU_REG_CONTROL);
}

static uint32_t read_alias(alias_t a)
{
	store_word_mmureg(a.context, MMU_REG_CONTEXT);
	return *a.word;
}

// Six checks, all writing through `w` and reading through `r`. The word keeps the
// value of the last write, and each check starts from the copy it needs in the cache.
//   0. a store that misses, with the line cached under `r`
//   1. a store that hits, with the line cached under `w`
//   2. a byte store
//   3. LDSTUB
//   4. SWAP, which must also return the value before it
//   5. a read through `w` agrees at the end
static uint32_t check_one_direction(alias_t w, alias_t r, uint32_t base)
{
	uint32_t ok = 0, old;

	read_alias(r);                     //the line is now cached under r
	store_word_mmureg(w.context, MMU_REG_CONTEXT);
	*w.word = base + 1;
	if (read_alias(r) == base + 1) ok |= 1 << 0;

	read_alias(w);                     //cached under w
	store_word_mmureg(w.context, MMU_REG_CONTEXT);
	*w.word = base + 2;
	if (read_alias(r) == base + 2) ok |= 1 << 1;

	store_word_mmureg(w.context, MMU_REG_CONTEXT);
	*(volatile uint8_t*) w.word = 0xAB;
	if (read_alias(r) == (0xAB000000u | ((base + 2) & 0x00FFFFFFu))) ok |= 1 << 2;

	read_alias(r);
	store_word_mmureg(w.context, MMU_REG_CONTEXT);
	__asm__ __volatile__("ldstub [%1], %0" : "=r"(old) : "r"(w.word) : "memory");
	if (old == 0xAB && read_alias(r) == (0xFF000000u | ((base + 2) & 0x00FFFFFFu))) ok |= 1 << 3;

	read_alias(r);
	store_word_mmureg(w.context, MMU_REG_CONTEXT);
	old = base + 3;
	__asm__ __volatile__("swap [%1], %0" : "=r"(old) : "r"(w.word), "0"(old) : "memory");
	if (old == (0xFF000000u | ((base + 2) & 0x00FFFFFFu)) && read_alias(r) == base + 3) ok |= 1 << 4;

	if (read_alias(w) == base + 3) ok |= 1 << 5;
	return ok;
}

// Twelve checks: the six above in each direction.
static uint32_t check_alias_pair(alias_t a, alias_t b)
{
	return check_one_direction(a, b, 0x1000u) | (check_one_direction(b, a, 0x2000u) << 6);
}

static void report_and_halt(uint32_t checks_passed_bits, uint32_t number_of_checks)
{
	uint32_t all  = (1u << number_of_checks) - 1;
	uint32_t pass = (checks_passed_bits == all) ? 1 : 0;
	__asm__ __volatile__("mov %0, %%o0\n\tmov %1, %%o1\n\tta 0"
	                     : : "r"(pass), "r"(checks_passed_bits) : "o0", "o1");
	while (1) {}
}

#endif

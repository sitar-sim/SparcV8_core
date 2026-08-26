// selective_flush.c
//
// Selective TLB flush by type (Table H-2), exercised end to end: cache
// two separate region-level (level-1, 16MB) translations, remap both
// underlying page-table entries without flushing (first confirming both
// reads are still stale, i.e. the TLB really is caching), then issue a
// single region-type flush scoped to only one of the two regions, and
// confirm only that region's cached translation actually gets refreshed
// while the other one stays stale.
//
// Region A is l1_table[L1_INDEX_TEST] (VA[31:24]=0x10); region B is the
// next slot, l1_table[L1_INDEX_TEST+1] (VA[31:24]=0x11) -- set up by
// hand here, in addition to setup_safe_l1_table()'s usual single test
// slot, since this test specifically needs two independent region-level
// mappings to tell "flushed" apart from "not flushed".
//
// Needs at least 4 concurrently-resident level-1 TLB entries to pass:
// code, stack (both identity-mapped as level-1 huge-page leaves too, Ref
// setup_safe_l1_table()), plus regions A and B. MMU_TLB_LEVEL1_ENTRIES
// (MmuConfig.h) can be any positive integer for *correctness* -- a
// smaller value just means more evictions/re-walks, never a wrong
// translation -- but a value below 4 here means region A or B's own
// cached entry can be evicted by ordinary code/stack traffic before this
// test ever gets to its deliberate flush, which shows up as
// ok_stale_a/ok_stale_b unexpectedly false (the entry was already
// evicted and correctly re-walked, not "still cached and stale" as this
// test wants to observe) -- confirmed by hand at MMU_TLB_LEVEL1_ENTRIES
// = 2 while re-verifying the TLB sizing knobs. Not an MMU/Tlb bug: every
// other test in this suite passes unchanged at that size.

#include "../mmu_common.h"

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));

#define VA_A TEST_VA_BASE               // 0x10000000, L1 index 0x10
#define VA_B (TEST_VA_BASE + 0x01000000u) // 0x11000000, L1 index 0x11

#define PHYS_A1 0x01000000u // region A's original frame
#define PHYS_B1 0x02000000u // region B's original frame
#define PHYS_A2 0x03000000u // region A's frame after remap
#define PHYS_B2 0x04000000u // region B's frame after remap

int main(void)
{
    unsigned int ok_a1, ok_b1, ok_stale_a, ok_stale_b, ok_flushed_a, ok_unflushed_b;
    unsigned int pass, diag;

    // Seed both original frames while the MMU is still disabled -- plain
    // pointer derefs are raw physical accesses at this point.
    *((volatile unsigned int*) PHYS_A1) = 0xAAAA0001u;
    *((volatile unsigned int*) PHYS_B1) = 0xBBBB0001u;

    setup_safe_l1_table(l1_table, make_pte(PHYS_A1, ACC_RWX_RWX, 1)); // region A
    l1_table[L1_INDEX_TEST + 1] = make_pte(PHYS_B1, ACC_RWX_RWX, 1);  // region B
    enable_mmu_with_l1_table(context_table, l1_table);

    // Prime the TLB: one translated access per region caches its
    // level-1 leaf entry (Ref Tlb.h: a level-1 entry is tagged by
    // (context, VA[31:24]), i.e. exactly one region).
    ok_a1 = (*((volatile unsigned int*) VA_A) == 0xAAAA0001u) ? 1 : 0;
    ok_b1 = (*((volatile unsigned int*) VA_B) == 0xBBBB0001u) ? 1 : 0;

    // Remap both regions to new frames, and seed the new frames, without
    // flushing anything yet. Disable the MMU only for this step so the
    // writes to PHYS_A2/PHYS_B2 (not otherwise mapped) are raw physical
    // accesses; l1_table itself is identity-mapped either way (it lives
    // in the code region), so remapping it works regardless of E, but
    // disabling keeps this whole step in one simple, consistent window.
    store_word_mmureg(0, MMU_REG_CONTROL);
    *((volatile unsigned int*) PHYS_A2) = 0xAAAA0002u;
    *((volatile unsigned int*) PHYS_B2) = 0xBBBB0002u;
    l1_table[L1_INDEX_TEST]     = make_pte(PHYS_A2, ACC_RWX_RWX, 1);
    l1_table[L1_INDEX_TEST + 1] = make_pte(PHYS_B2, ACC_RWX_RWX, 1);
    store_word_mmureg(MMU_CONTROL_E_BIT, MMU_REG_CONTROL);

    // Neither region has been flushed yet -- both reads must still
    // return the OLD values, confirming the TLB is genuinely caching
    // (not re-walking every access).
    ok_stale_a = (*((volatile unsigned int*) VA_A) == 0xAAAA0001u) ? 1 : 0;
    ok_stale_b = (*((volatile unsigned int*) VA_B) == 0xBBBB0001u) ? 1 : 0;

    // Flush only region A (Table H-2: region flush matches VA[31:24]).
    mmu_flush(flush_probe_addr(VA_A, FLUSH_PROBE_TYPE_REGION));

    // Region A must now re-walk and see the new mapping; region B's
    // cached (stale) entry must be untouched by a flush scoped to A.
    ok_flushed_a   = (*((volatile unsigned int*) VA_A) == 0xAAAA0002u) ? 1 : 0;
    ok_unflushed_b = (*((volatile unsigned int*) VA_B) == 0xBBBB0001u) ? 1 : 0;

    pass = ok_a1 && ok_b1 && ok_stale_a && ok_stale_b && ok_flushed_a && ok_unflushed_b;
    diag = ok_a1 | (ok_b1 << 1) | (ok_stale_a << 2) | (ok_stale_b << 3)
           | (ok_flushed_a << 4) | (ok_unflushed_b << 5);

    __asm__ __volatile__("mov %0, %%o0" : : "r"(pass));
    __asm__ __volatile__("mov %0, %%o1" : : "r"(diag));
    __asm__ __volatile__("ta 0");
    while (1) {}
    return 0;
}

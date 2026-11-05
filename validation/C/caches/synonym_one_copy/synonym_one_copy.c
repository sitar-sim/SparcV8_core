// synonym_one_copy.c
//
// Two virtual pages map to one physical page, so one physical line has two virtual
// addresses, and they fall in different sets of a virtually indexed cache. A cache
// holds at most one copy of a physical line: installing the line under one address
// removes it under the other. A store through one address is therefore never
// missed by a load through the other, which would otherwise keep hitting its
// own old copy.
//
// Runs on one core, on every configuration with caches. The MMU is on and the pages
// are cacheable, so these are real translated cached accesses.
//
//   0. both addresses read the first value
//   1. a store through the second address is seen through the first
//   2. a store through the first address is seen through the second

#include "../../mmu/mmu_common.h"

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));
static unsigned int l2_table[64]       __attribute__((aligned(1024)));
static unsigned int l3_table[64]       __attribute__((aligned(1024)));
static unsigned int target_page[1024]  __attribute__((aligned(4096)));

int main(void)
{
    unsigned int ok = 0;
    unsigned int va1 = TEST_VA_BASE | 0x00034000u;
    unsigned int va2 = TEST_VA_BASE | 0x00035000u; //the next page, so a different set
    volatile unsigned int* first  = (volatile unsigned int*) va1;
    volatile unsigned int* second = (volatile unsigned int*) va2;

    target_page[0] = 0x11;

    l3_table[(va1 >> 12) & 0x3F] = make_pte((unsigned int) target_page, ACC_RWX_RWX, 1);
    l3_table[(va2 >> 12) & 0x3F] = make_pte((unsigned int) target_page, ACC_RWX_RWX, 1);
    l2_table[(va1 >> 18) & 0x3F] = make_ptd(l3_table);

    setup_safe_l1_table(l1_table, make_ptd(l2_table));
    enable_mmu_with_l1_table(context_table, l1_table);

    if (*first == 0x11 && *second == 0x11) ok |= 1 << 0;

    *second = 0x22;
    if (*first == 0x22) ok |= 1 << 1;

    *first = 0x33;
    if (*second == 0x33) ok |= 1 << 2;

    __asm__ __volatile__("mov %0, %%o0\n\tmov %1, %%o1\n\tta 0"
                         : : "r"(ok == 7 ? 1u : 0u), "r"(ok) : "o0", "o1");
    while (1) {}
    return 0;
}

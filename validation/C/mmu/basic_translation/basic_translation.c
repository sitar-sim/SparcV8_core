// basic_translation.c
//
// Ordinary 3-level page-table walk (Ref Appendix H.3): context table ->
// L1 -> L2 -> L3 -> leaf PTE, terminating at level 3 (the common,
// "normal" 4KB-page case -- Ref Table H-1). Confirms the walker
// correctly resolves all three levels and constructs the right
// physical address (PPN from the PTE, VA[11:0] as the page offset) --
// reading through the mapped VA must return what was written directly
// to the underlying physical frame, not to the VA's own numeric value
// (which would pass a bug that just left translation a no-op).

#include "../mmu_common.h"

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));
static unsigned int l2_table[64]       __attribute__((aligned(1024)));
static unsigned int l3_table[64]       __attribute__((aligned(1024)));
static unsigned int target_page[1024]  __attribute__((aligned(4096)));

int main(void)
{
    unsigned int va, l2_index, l3_index, pass, readback;
    unsigned int expected = 0xCAFEF00Du;

    va = TEST_VA_BASE | 0x00034000u;
    l2_index = (va >> 18) & 0x3F;
    l3_index = (va >> 12) & 0x3F;

    target_page[0] = expected;

    l3_table[l3_index] = make_pte((unsigned int) target_page, ACC_RWX_RWX, 1);
    l2_table[l2_index] = make_ptd(l3_table);

    setup_safe_l1_table(l1_table, make_ptd(l2_table));
    enable_mmu_with_l1_table(context_table, l1_table);

    readback = *((volatile unsigned int*) va);

    pass = (readback == expected) ? 1 : 0;

    __asm__ __volatile__("mov %0, %%o0" : : "r"(pass));
    __asm__ __volatile__("ta 0");
    while (1) {}
    return 0;
}

// mmu_disabled_bypass.c
//
// With the MMU disabled (Control Register E=0, its reset default), an
// ordinary access must reach physical memory untranslated (VA used
// directly as PA), and *not* be subject to whatever permissions a page
// table happens to describe. A page table is deliberately built here
// that would deny a store at the test address (ACC_RO_RO) if the MMU
// were active, specifically to prove the bypass really does skip the
// whole page-table/permission apparatus, rather than the store merely
// happening to succeed because nothing was ever configured.
//
// Note: `translate()`'s disabled-MMU branch also decides the `cacheable`
// result the caller gets back (Ref Mmu.cpp), but that value currently
// has no effect anywhere observable -- no cache exists yet to consume
// it, and it isn't captured in MmuStats either -- so it isn't checked
// here. See mmu/README.md's own note on this (the current formula can
// report cacheable=true when disabled if the always-cacheable control
// bit is set, matching AJIT's own Mmu.c, kept for that reason).

#include "../mmu_common.h"

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));

#define PHYS_TEST_ADDR 0x00500000u // a genuine, in-bounds physical address

int main(void)
{
    unsigned int ok_store, ok_readback, pass, diag;

    // Build a page table that WOULD deny a store here if the MMU were
    // active, but leave Control Register's E bit clear.
    setup_safe_l1_table(l1_table, make_pte(PHYS_TEST_ADDR, ACC_RO_RO, 1));
    context_table[0] = make_ptd(l1_table);
    store_word_mmureg(make_ptd(context_table), MMU_REG_CTX_TBL_PTR);
    // (Control Register left at its reset value: E=0, MMU disabled.)

    *((volatile unsigned int*) PHYS_TEST_ADDR) = 0xDEADBEEFu;
    ok_store = 1; // reaching this line at all means the store didn't fault

    ok_readback = (*((volatile unsigned int*) PHYS_TEST_ADDR) == 0xDEADBEEFu) ? 1 : 0;

    pass = ok_store && ok_readback;
    diag = ok_store | (ok_readback << 1);

    __asm__ __volatile__("mov %0, %%o0" : : "r"(pass));
    __asm__ __volatile__("mov %0, %%o1" : : "r"(diag));
    __asm__ __volatile__("ta 0");
    while (1) {}
    return 0;
}

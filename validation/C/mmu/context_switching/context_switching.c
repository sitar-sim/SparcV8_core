// context_switching.c
//
// Two independent contexts (0 and 1), each with its own L1 table,
// mapping the same VA to a different physical frame. Switching the
// Context Register must resolve that VA to the right context's own
// frame -- and, since neither switch below is followed by a flush, this
// also exercises the TLB's own context-qualified tagging (Ref Tlb.h: a
// cached leaf is tagged by (context, VA...), not VA alone) -- a stale,
// VA-only-tagged lookup would silently return the wrong context's data
// after the first switch.
//
// Both L1 tables get their own ordinary code/stack identity mapping via
// setup_safe_l1_table() (not just the one "test" entry that differs) --
// the Context Register governs translation for *every* access,
// including the program's own ongoing instruction fetches and stack
// accesses, so switching context without both tables covering those
// identically would crash the test immediately.

#include "../mmu_common.h"

static unsigned int context_table[256]  __attribute__((aligned(1024)));
static unsigned int l1_table_ctx0[256]  __attribute__((aligned(1024)));
static unsigned int l1_table_ctx1[256]  __attribute__((aligned(1024)));

#define PHYS_CTX0_FRAME 0x01000000u
#define PHYS_CTX1_FRAME 0x02000000u

int main(void)
{
    unsigned int ok_ctx0_initial, ok_ctx1, ok_ctx0_again, pass, diag;

    *((volatile unsigned int*) PHYS_CTX0_FRAME) = 0xC0C0C0C0u;
    *((volatile unsigned int*) PHYS_CTX1_FRAME) = 0xC1C1C1C1u;

    setup_safe_l1_table(l1_table_ctx0, make_pte(PHYS_CTX0_FRAME, ACC_RWX_RWX, 1));
    setup_safe_l1_table(l1_table_ctx1, make_pte(PHYS_CTX1_FRAME, ACC_RWX_RWX, 1));
    context_table[0] = make_ptd(l1_table_ctx0);
    context_table[1] = make_ptd(l1_table_ctx1);
    store_word_mmureg(make_ptd(context_table), MMU_REG_CTX_TBL_PTR);
    store_word_mmureg(MMU_CONTROL_E_BIT, MMU_REG_CONTROL);
    // Context Register defaults to 0 (Ref Appendix H.7's reset state).

    ok_ctx0_initial = (*((volatile unsigned int*) TEST_VA_BASE) == 0xC0C0C0C0u) ? 1 : 0;

    store_word_mmureg(1, MMU_REG_CONTEXT); // no flush -- see file comment
    ok_ctx1 = (*((volatile unsigned int*) TEST_VA_BASE) == 0xC1C1C1C1u) ? 1 : 0;

    store_word_mmureg(0, MMU_REG_CONTEXT); // switch back, again no flush
    ok_ctx0_again = (*((volatile unsigned int*) TEST_VA_BASE) == 0xC0C0C0C0u) ? 1 : 0;

    pass = ok_ctx0_initial && ok_ctx1 && ok_ctx0_again;
    diag = ok_ctx0_initial | (ok_ctx1 << 1) | (ok_ctx0_again << 2);

    __asm__ __volatile__("mov %0, %%o0" : : "r"(pass));
    __asm__ __volatile__("mov %0, %%o1" : : "r"(diag));
    __asm__ __volatile__("ta 0");
    while (1) {}
    return 0;
}

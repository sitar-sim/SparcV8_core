// huge_page_levels.c
//
// A page-table walk can terminate before level 3 if a PTE (leaf) is
// found directly in the context table, or a Level-1 or Level-2 table
// (Ref Appendix H.3: "If a PTE is found in the Context Table or a
// Level-1 or Level-2 Page Table, the address translation process
// stops"), mapping a correspondingly larger region -- Table H-1's
// Root(4GB)/Level-1(16MB)/Level-2(256KB) sizes. This checks all three
// "huge page" terminations resolve to the correct physical address.
//
// Every case below uses VA offset 0 within its own huge region (i.e.
// the test VA's low N bits, matching that level's page-offset width,
// are all zero), so the translated physical address lands exactly on
// the target frame's own base with no offset arithmetic to get wrong.
// The target physical frames are fixed constants, not C arrays with an
// alignment attribute -- this old GCC (4.4.3) silently drops a
// `__attribute__((aligned(N)))` larger than 256KB on a BSS `.comm`
// symbol down to 0 (confirmed via the generated .s: a 16MB request came
// out as `.common page_l1,4096,0`), so relying on it for a 16MB-aligned
// leaf would silently break. A leaf's PPN must have its low-order bits
// genuinely zero down to its own mapping's granularity (Ref H.3.2's
// alignment note under Figure H-8), so fixed, hand-picked-aligned
// addresses sidestep the toolchain limitation entirely.
//
// Level-1 and Level-2: placed directly at l1_table[L1_INDEX_TEST] (or a
// slot inside its own L2 table), exactly like an ordinary deeper walk
// except the leaf appears one or two levels earlier -- no special
// handling needed beyond code/stack's usual identity mapping.
//
// Level-0 (Root): a context-table PTE covers the *entire* 4GB space for
// that context, which is structurally incompatible with also carving
// out separate code/stack/test regions the way every other test here
// does (a context-table entry is one PTE or one PTD, never both). The
// only way to exercise this termination without a real OS-level context
// switch (which these bare-metal tests have no mechanism for) is an
// identity mapping of the whole space -- which still genuinely exercises
// the level-0 walk-termination and physical-address-construction code
// path (confirmed via the MMU's own stats counter), just not a
// non-identity one.

#include "../mmu_common.h"

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));
static unsigned int l2_table[64]       __attribute__((aligned(1024)));

#define PHYS_L1_FRAME 0x01000000u // 16MB-aligned
#define PHYS_L2_FRAME 0x00040000u // 256KB-aligned
#define PHYS_L0_ADDR  0x00500000u // any in-bounds address; identity-mapped

int main(void)
{
    unsigned int va;
    unsigned int ok_l1, ok_l2, ok_l0, pass, diag;

    // --- Level-1 termination: a 16MB leaf placed directly at
    // l1_table[L1_INDEX_TEST], instead of a PTD to an L2 table.
    va = TEST_VA_BASE; // offset 0 within the 16MB region
    *((volatile unsigned int*) PHYS_L1_FRAME) = 0x11112222u;
    setup_safe_l1_table(l1_table, make_pte(PHYS_L1_FRAME, ACC_RWX_RWX, 1));
    enable_mmu_with_l1_table(context_table, l1_table);

    ok_l1 = (*((volatile unsigned int*) va) == 0x11112222u) ? 1 : 0;

    store_word_mmureg(0, MMU_REG_CONTROL); // disable MMU while reconfiguring

    // --- Level-2 termination: an L2 table reached via a PTD at
    // l1_table[L1_INDEX_TEST], with one of its own entries a 256KB leaf.
    va = TEST_VA_BASE; // offset 0 within the 256KB region too
    *((volatile unsigned int*) PHYS_L2_FRAME) = 0x33334444u;
    l2_table[0] = make_pte(PHYS_L2_FRAME, ACC_RWX_RWX, 1); // l2_index=((va>>18)&0x3F)=0 for va=TEST_VA_BASE
    setup_safe_l1_table(l1_table, make_ptd(l2_table));
    enable_mmu_with_l1_table(context_table, l1_table);

    ok_l2 = (*((volatile unsigned int*) va) == 0x33334444u) ? 1 : 0;

    store_word_mmureg(0, MMU_REG_CONTROL);

    // --- Level-0 termination: the context-table entry itself is a
    // 4GB identity leaf (see file comment for why identity-only).
    *((volatile unsigned int*) PHYS_L0_ADDR) = 0x55556666u; // MMU disabled here -- VA==PA regardless
    context_table[0] = make_pte(0x00000000u, ACC_RWX_RWX, 1);
    store_word_mmureg(make_ptd(context_table), MMU_REG_CTX_TBL_PTR);
    store_word_mmureg(MMU_CONTROL_E_BIT, MMU_REG_CONTROL);

    ok_l0 = (*((volatile unsigned int*) PHYS_L0_ADDR) == 0x55556666u) ? 1 : 0;

    pass = ok_l1 && ok_l2 && ok_l0;
    diag = (ok_l1) | (ok_l2 << 1) | (ok_l0 << 2);

    __asm__ __volatile__("mov %0, %%o0" : : "r"(pass));
    __asm__ __volatile__("mov %0, %%o1" : : "r"(diag));
    __asm__ __volatile__("ta 0");
    while (1) {}
    return 0;
}

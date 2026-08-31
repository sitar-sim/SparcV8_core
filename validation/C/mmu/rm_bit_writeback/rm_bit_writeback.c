// rm_bit_writeback.c
//
// R (Referenced) and M (Modified) bit write-back on a leaf PTE (Ref
// MmuCore::translate()'s setR/setM logic): a load sets R (leaves M alone),
// a store sets both, and once both are already set, further accesses
// leave them set (not corrupted). The PTE lives in an ordinary static
// array (l3_table, in the identity-mapped code region), so its raw bit
// pattern can be read directly with a plain C array access, both before
// and after each translated access to the test page itself.
//
// Uses an ordinary level-3 (4KB) leaf, reached via a full 3-level walk
// -- the common case, and the level Table H-1 associates with R/M
// tracking in practice, though the manual does not restrict R/M
// updates to level-3 leaves specifically.

#include "../mmu_common.h"

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));
static unsigned int l2_table[64]       __attribute__((aligned(1024)));
static unsigned int l3_table[64]       __attribute__((aligned(1024)));

#define PHYS_LEAF_FRAME 0x01000000u

int main(void)
{
    unsigned int va, l2_index, l3_index;
    unsigned int pte;
    unsigned int ok_initial, ok_after_load, ok_after_store, ok_repeat, pass, diag;

    va = TEST_VA_BASE;
    l2_index = (va >> 18) & 0x3F; // 0 for va = TEST_VA_BASE
    l3_index = (va >> 12) & 0x3F; // 0 for va = TEST_VA_BASE

    l3_table[l3_index] = make_pte(PHYS_LEAF_FRAME, ACC_RWX_RWX, 1); // R=M=0
    l2_table[l2_index] = make_ptd(l3_table);
    setup_safe_l1_table(l1_table, make_ptd(l2_table));
    enable_mmu_with_l1_table(context_table, l1_table);

    pte = l3_table[l3_index];
    ok_initial = (PTE_R(pte) == 0 && PTE_M(pte) == 0) ? 1 : 0;

    (void) *((volatile unsigned int*) va); // LOAD
    pte = l3_table[l3_index];
    ok_after_load = (PTE_R(pte) == 1 && PTE_M(pte) == 0) ? 1 : 0;

    *((volatile unsigned int*) va) = 0xCAFEF00Du; // STORE
    pte = l3_table[l3_index];
    ok_after_store = (PTE_R(pte) == 1 && PTE_M(pte) == 1) ? 1 : 0;

    // Further accesses must leave both bits set, not reset or corrupt them.
    (void) *((volatile unsigned int*) va);
    *((volatile unsigned int*) va) = 0xCAFEF00Eu;
    pte = l3_table[l3_index];
    ok_repeat = (PTE_R(pte) == 1 && PTE_M(pte) == 1) ? 1 : 0;

    pass = ok_initial && ok_after_load && ok_after_store && ok_repeat;
    diag = ok_initial | (ok_after_load << 1) | (ok_after_store << 2) | (ok_repeat << 3);

    __asm__ __volatile__("mov %0, %%o0" : : "r"(pass));
    __asm__ __volatile__("mov %0, %%o1" : : "r"(diag));
    __asm__ __volatile__("ta 0");
    while (1) {}
    return 0;
}

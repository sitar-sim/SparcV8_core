// probe_types.c
//
// MMU probe (Table H-4), all 5 defined types, read via ASI 3 (Ref
// mmu_probe() in mmu_common.h). Probe never faults or affects the CPU,
// so no NF/trap handling is needed here -- just compare the raw
// returned value against what Table H-4 says for each entry-type case.
//
// The interesting cases (not just "finds an ordinary leaf") are the
// ones this project's own Mmu::probe() got wrong before a recent fix:
// Table H-4 says that for page/segment/region/context probes (types
// 0-3), a PTD or an invalid entry found *at* the probed level is
// returned as-is ("*" in the table), not treated as "not found" -- the
// one exception being a page probe (type 0, level 3), where a PTD makes
// no structural sense (no level-4 table to point to) and the table
// specifies 0 instead. p2/p3/p4 below exercise exactly this.

#include "../mmu_common.h"

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));
static unsigned int l2_table[64]       __attribute__((aligned(1024)));
static unsigned int l3_table[64]       __attribute__((aligned(1024)));

#define PHYS_LEAF_FRAME 0x01000000u

int main(void)
{
    unsigned int va, l2_index, l3_index;
    unsigned int leaf_pte, l2_ptd, l1_ptd;
    unsigned int p0, p1, p2, p3, p4, p5, pass, diag;
    unsigned int result;

    va = TEST_VA_BASE;
    l2_index = (va >> 18) & 0x3F; // 0 for va = TEST_VA_BASE
    l3_index = (va >> 12) & 0x3F; // 0 for va = TEST_VA_BASE

    leaf_pte = make_pte(PHYS_LEAF_FRAME, ACC_RWX_RWX, 1);
    l3_table[l3_index] = leaf_pte;
    l2_ptd = make_ptd(l3_table);
    l2_table[l2_index] = l2_ptd;
    l1_ptd = make_ptd(l2_table);

    setup_safe_l1_table(l1_table, l1_ptd);
    enable_mmu_with_l1_table(context_table, l1_table);

    // p0: type 4 (entire) on the mapped VA -- finds the leaf PTE, same
    // as an ordinary translation would.
    result = mmu_probe(flush_probe_addr(va, FLUSH_PROBE_TYPE_ENTIRE));
    p0 = (result == leaf_pte) ? 1 : 0;

    // p1: type 4 (entire) on an unmapped VA (l1_table has nothing valid
    // at this index) -- not found, returns 0.
    result = mmu_probe(flush_probe_addr(TEST_VA_BASE + 0x01000000u, FLUSH_PROBE_TYPE_ENTIRE));
    p1 = (result == 0u) ? 1 : 0;

    // p2: type 0 (page, target level 3) on the mapped VA -- the level-3
    // entry genuinely is a leaf PTE, so this is the "ordinary" case:
    // returns the PTE.
    result = mmu_probe(flush_probe_addr(va, FLUSH_PROBE_TYPE_PAGE));
    p2 = (result == leaf_pte) ? 1 : 0;

    // p3: type 2 (region, target level 1) on the mapped VA -- the
    // level-1 entry is a PTD (l1_ptd), not a leaf. Table H-4 says this
    // is still returned as-is, not "not found".
    result = mmu_probe(flush_probe_addr(va, FLUSH_PROBE_TYPE_REGION));
    p3 = (result == l1_ptd) ? 1 : 0;

    // p4: type 0 (page, target level 3), but with a PTD (not a leaf)
    // artificially placed at the level-3 table's own slot -- Table H-4's
    // one exception: a PTD at level 3 has no level-4 table to point to,
    // so this returns 0, unlike p3's analogous level-1 case.
    l3_table[l3_index] = make_ptd(l2_table); // any PTD-shaped value; l2_table reused purely as a valid-looking pointer target, never actually walked into
    mmu_flush(flush_probe_addr(0, FLUSH_PROBE_TYPE_ENTIRE));
    result = mmu_probe(flush_probe_addr(va, FLUSH_PROBE_TYPE_PAGE));
    p4 = (result == 0u) ? 1 : 0;
    l3_table[l3_index] = leaf_pte; // restore for p5

    // p5: type 3 (context, target level 0) -- the context-table entry
    // itself (context_table[0], a PTD pointing at l1_table) is a PTD,
    // not a leaf, and gets returned as-is, same reasoning as p3.
    mmu_flush(flush_probe_addr(0, FLUSH_PROBE_TYPE_ENTIRE));
    result = mmu_probe(flush_probe_addr(va, FLUSH_PROBE_TYPE_CONTEXT));
    p5 = (result == make_ptd(l1_table)) ? 1 : 0;

    pass = p0 && p1 && p2 && p3 && p4 && p5;
    diag = p0 | (p1 << 1) | (p2 << 2) | (p3 << 3) | (p4 << 4) | (p5 << 5);

    __asm__ __volatile__("mov %0, %%o0" : : "r"(pass));
    __asm__ __volatile__("mov %0, %%o1" : : "r"(diag));
    __asm__ __volatile__("ta 0");
    while (1) {}
    return 0;
}

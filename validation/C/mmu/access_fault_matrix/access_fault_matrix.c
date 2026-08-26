// access_fault_matrix.c
//
// The ACC x AT permission fault matrix (Ref Appendix H.5's table under
// "Invalid address, protection, and privilege violation errors..."),
// exercised end to end (an actual load/store, not just PTE inspection)
// for a representative spread of ACC values, checking the Fault Status
// Register's own AT/FT fields after each access.
//
// Uses explicit user-data-space accesses (ASI 0x0A) under NF=1 so a
// deliberate fault updates FSR/FAR without halting the whole test (Ref
// Appendix H.3's NF field -- note it explicitly excludes ASI 0x0B
// (supervisor data), so this only works via user-data ASI, not an
// ordinary C pointer dereference, which always uses the CPU's current
// ASI (0x0B) in supervisor mode).
//
// Each ACC value uses a level-1 (16MB) huge-page leaf placed directly
// at l1_table[L1_INDEX_TEST] -- simplest possible page-table shape,
// since this test only cares about the ACC field, not walk depth.

#include "../mmu_common.h"

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));

#define PHYS_FRAME 0x01000000u // 16MB-aligned, matches basic_translation's own choice

int main(void)
{
    unsigned int fsr;
    unsigned int pass, diag;
    unsigned int c0_load, c0_store, c1_load, c1_store, c2_load, c2_store, c4_load, c4_store, c6_load, c6_store;

    setup_safe_l1_table(l1_table, 0); // test entry filled in per-ACC below
    enable_mmu_with_l1_table(context_table, l1_table);
    store_word_mmureg(MMU_CONTROL_E_BIT | MMU_CONTROL_NF_BIT, MMU_REG_CONTROL);

    // --- ACC 0: Read Only (user and supervisor). Load ok, store faults.
    l1_table[L1_INDEX_TEST] = make_pte(PHYS_FRAME, ACC_RO_RO, 1);
    mmu_flush(flush_probe_addr(0, FLUSH_PROBE_TYPE_ENTIRE)); // invalidate the stale cached translation from the previous ACC
    (void) load_word_user_data((unsigned int*) TEST_VA_BASE);
    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    c0_load = (FSR_FT(fsr) == FT_NONE) ? 1 : 0;
    store_word_user_data(0x12345678u, (unsigned int*) TEST_VA_BASE);
    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    c0_store = (FSR_FT(fsr) == FT_PROTECTION_ERROR && FSR_AT(fsr) == AT_STORE_USER_DATA) ? 1 : 0;

    // --- ACC 1: Read/Write (user and supervisor). Both ok.
    l1_table[L1_INDEX_TEST] = make_pte(PHYS_FRAME, ACC_RW_RW, 1);
    mmu_flush(flush_probe_addr(0, FLUSH_PROBE_TYPE_ENTIRE)); // invalidate the stale cached translation from the previous ACC
    (void) load_word_user_data((unsigned int*) TEST_VA_BASE);
    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    c1_load = (FSR_FT(fsr) == FT_NONE) ? 1 : 0;
    store_word_user_data(0x12345678u, (unsigned int*) TEST_VA_BASE);
    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    c1_store = (FSR_FT(fsr) == FT_NONE) ? 1 : 0;

    // --- ACC 2: Read/Execute (user and supervisor). Load ok, store faults.
    l1_table[L1_INDEX_TEST] = make_pte(PHYS_FRAME, ACC_RX_RX, 1);
    mmu_flush(flush_probe_addr(0, FLUSH_PROBE_TYPE_ENTIRE)); // invalidate the stale cached translation from the previous ACC
    (void) load_word_user_data((unsigned int*) TEST_VA_BASE);
    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    c2_load = (FSR_FT(fsr) == FT_NONE) ? 1 : 0;
    store_word_user_data(0x12345678u, (unsigned int*) TEST_VA_BASE);
    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    c2_store = (FSR_FT(fsr) == FT_PROTECTION_ERROR && FSR_AT(fsr) == AT_STORE_USER_DATA) ? 1 : 0;

    // --- ACC 4: Execute Only (user and supervisor). Both data accesses fault.
    l1_table[L1_INDEX_TEST] = make_pte(PHYS_FRAME, ACC_X_X, 1);
    mmu_flush(flush_probe_addr(0, FLUSH_PROBE_TYPE_ENTIRE)); // invalidate the stale cached translation from the previous ACC
    (void) load_word_user_data((unsigned int*) TEST_VA_BASE);
    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    c4_load = (FSR_FT(fsr) == FT_PROTECTION_ERROR && FSR_AT(fsr) == AT_LOAD_USER_DATA) ? 1 : 0;
    store_word_user_data(0x12345678u, (unsigned int*) TEST_VA_BASE);
    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    c4_store = (FSR_FT(fsr) == FT_PROTECTION_ERROR && FSR_AT(fsr) == AT_STORE_USER_DATA) ? 1 : 0;

    // --- ACC 6: No Access (user) / Read+Execute (supervisor). A *user*
    // access (AT 0/4, what user-data ASI produces) is a privilege
    // violation, not a protection error -- Ref H.5's distinct FT here.
    l1_table[L1_INDEX_TEST] = make_pte(PHYS_FRAME, ACC_NA_RX, 1);
    mmu_flush(flush_probe_addr(0, FLUSH_PROBE_TYPE_ENTIRE)); // invalidate the stale cached translation from the previous ACC
    (void) load_word_user_data((unsigned int*) TEST_VA_BASE);
    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    c6_load = (FSR_FT(fsr) == FT_PRIVILEGE_VIOLATION && FSR_AT(fsr) == AT_LOAD_USER_DATA) ? 1 : 0;
    store_word_user_data(0x12345678u, (unsigned int*) TEST_VA_BASE);
    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    c6_store = (FSR_FT(fsr) == FT_PRIVILEGE_VIOLATION && FSR_AT(fsr) == AT_STORE_USER_DATA) ? 1 : 0;

    pass = c0_load && c0_store && c1_load && c1_store && c2_load && c2_store
           && c4_load && c4_store && c6_load && c6_store;
    diag = c0_load | (c0_store << 1) | (c1_load << 2) | (c1_store << 3) | (c2_load << 4)
           | (c2_store << 5) | (c4_load << 6) | (c4_store << 7) | (c6_load << 8) | (c6_store << 9);

    __asm__ __volatile__("mov %0, %%o0" : : "r"(pass));
    __asm__ __volatile__("mov %0, %%o1" : : "r"(diag));
    __asm__ __volatile__("ta 0");
    while (1) {}
    return 0;
}

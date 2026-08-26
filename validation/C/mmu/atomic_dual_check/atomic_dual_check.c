// atomic_dual_check.c
//
// This model's own documented deviation from AJIT (Ref
// docs/compliance/README.md, Issue 4): an atomic load-store (LDSTUB)
// is checked as a single, precise operation requiring both load and
// store permission before any memory access happens at all, rather
// than AJIT's split-transaction behavior (a locked plain read, checked
// as a load, then a separate unlocked plain write, checked as a
// store -- which can let the read complete before the write half
// faults).
//
// Set up a page with ACC=2 (Read/Execute, no write, for both user and
// supervisor -- Ref H.3.2's ACC table) and execute LDSTUB against it
// from user-data space (ASI 0x0A). The store-permission check fails
// immediately: this model's LDSTUB must fault before touching memory at
// all, leaving the target byte completely unmodified -- unlike AJIT,
// where the read half would have already completed. NF=1 (Ref
// Appendix H.3) lets the deliberate fault update FSR without halting
// the whole test, the same mechanism access_fault_matrix.c uses.

#include "../mmu_common.h"

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));

#define PHYS_FRAME 0x01000000u

int main(void)
{
    unsigned int fsr;
    unsigned int original_word, after_word;
    unsigned int ldstub_result;
    unsigned int ok_fault_type, ok_fault_at, ok_memory_unchanged, pass, diag;

    setup_safe_l1_table(l1_table, make_pte(PHYS_FRAME, ACC_RX_RX, 1));
    enable_mmu_with_l1_table(context_table, l1_table);
    store_word_mmureg(MMU_CONTROL_E_BIT | MMU_CONTROL_NF_BIT, MMU_REG_CONTROL);

    // Seed the target byte's containing word via the supervisor-data
    // identity path below the leaf -- MMU disabled momentarily so this
    // write bypasses the ACC=2 (no-write) restriction entirely, since
    // it's setup, not part of what's under test.
    store_word_mmureg(MMU_CONTROL_NF_BIT, MMU_REG_CONTROL); // E=0: disable
    *((volatile unsigned int*) PHYS_FRAME) = 0xAABBCCDDu;
    original_word = *((volatile unsigned int*) PHYS_FRAME);
    store_word_mmureg(MMU_CONTROL_E_BIT | MMU_CONTROL_NF_BIT, MMU_REG_CONTROL); // re-enable

    ldstub_result = 0;
    __asm__ __volatile__("ldstuba [%1] 0x0a, %0" : "=r"(ldstub_result) : "r"(TEST_VA_BASE) : "memory");

    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    ok_fault_type = (FSR_FT(fsr) == FT_PROTECTION_ERROR) ? 1 : 0;
    ok_fault_at = (FSR_AT(fsr) == AT_STORE_USER_DATA) ? 1 : 0;

    store_word_mmureg(MMU_CONTROL_NF_BIT, MMU_REG_CONTROL); // disable again to read the raw physical word safely
    after_word = *((volatile unsigned int*) PHYS_FRAME);
    ok_memory_unchanged = (after_word == original_word) ? 1 : 0;

    pass = ok_fault_type && ok_fault_at && ok_memory_unchanged;
    diag = ok_fault_type | (ok_fault_at << 1) | (ok_memory_unchanged << 2);

    __asm__ __volatile__("mov %0, %%o0" : : "r"(pass));
    __asm__ __volatile__("mov %0, %%o1" : : "r"(diag));
    __asm__ __volatile__("mov %0, %%o2" : : "r"(ldstub_result));
    __asm__ __volatile__("ta 0");
    while (1) {}
    return 0;
}

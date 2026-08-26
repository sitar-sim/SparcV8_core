// fsr_ow_bit.c
//
// FSR OW (Overwrite) bit and same-fault-class overwrite priority (Ref
// Appendix H.5): a fault of the same class (data-access, here) that
// occurs before the previous one is read via FSR sets OW=1, and FSR/FAR
// get updated to the NEW fault's info -- checked both by OW itself and
// by confirming the reported FT/AT actually changed to the second
// fault's own signature, not the first's (a same-class overwrite that
// merely raised OW without actually updating the fields would be a
// different, subtler bug this alone would miss). A single, unread-prior
// fault (the last check below) must show OW=0, ruling out an
// always-1-OW implementation.

#include "../mmu_common.h"

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));

#define PHYS_RO_FRAME 0x01000000u // ACC_RO_RO: protection error on a store
#define PHYS_NA_FRAME 0x02000000u // ACC_NA_RX: privilege violation on a user load

#define VA_RO TEST_VA_BASE
#define VA_NA (TEST_VA_BASE + 0x01000000u)

int main(void)
{
    unsigned int fsr;
    unsigned int ok_ow, ok_ow_ft, ok_ow_at, ok_single;
    unsigned int pass, diag;

    setup_safe_l1_table(l1_table, make_pte(PHYS_RO_FRAME, ACC_RO_RO, 1));
    l1_table[L1_INDEX_TEST + 1] = make_pte(PHYS_NA_FRAME, ACC_NA_RX, 1);
    enable_mmu_with_l1_table(context_table, l1_table);
    store_word_mmureg(MMU_CONTROL_E_BIT | MMU_CONTROL_NF_BIT, MMU_REG_CONTROL);

    // Fault 1 (DACCESS, protection error): store on the read-only region.
    store_word_user_data(0x11111111u, (unsigned int*) VA_RO);
    // Fault 2 (DACCESS, privilege violation), no FSR read in between:
    // load on the region denied to user mode entirely.
    (void) load_word_user_data((unsigned int*) VA_NA);

    // First FSR read of the test -- must show OW=1 and fault 2's own
    // signature (not fault 1's), proving the overwrite actually updated
    // the fields, not just the flag.
    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    ok_ow    = (FSR_OW(fsr) == 1) ? 1 : 0;
    ok_ow_ft = (FSR_FT(fsr) == FT_PRIVILEGE_VIOLATION) ? 1 : 0;
    ok_ow_at = (FSR_AT(fsr) == AT_LOAD_USER_DATA) ? 1 : 0;

    // A single fresh fault, with no unread prior (the read above just
    // cleared it) -- OW must be 0 this time.
    store_word_user_data(0x22222222u, (unsigned int*) VA_RO);
    fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
    ok_single = (FSR_OW(fsr) == 0 && FSR_FT(fsr) == FT_PROTECTION_ERROR && FSR_AT(fsr) == AT_STORE_USER_DATA) ? 1 : 0;

    pass = ok_ow && ok_ow_ft && ok_ow_at && ok_single;
    diag = ok_ow | (ok_ow_ft << 1) | (ok_ow_at << 2) | (ok_single << 3);

    __asm__ __volatile__("mov %0, %%o0" : : "r"(pass));
    __asm__ __volatile__("mov %0, %%o1" : : "r"(diag));
    __asm__ __volatile__("ta 0");
    while (1) {}
    return 0;
}

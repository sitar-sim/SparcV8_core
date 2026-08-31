// register_rw.c
//
// Basic MMU register read/write semantics (Ref Appendix H.4/H.6), no
// translation involved:
//   - Control, Context Table Pointer, and Context registers are
//     ordinary read/write storage.
//   - Reading the Fault Status Register clears it (H.5: "Reading the
//     Fault Status Register clears it").
//   - Writes to the Fault Status and Fault Address Registers are
//     ignored (H.5: "Writes to the Fault Status Register are ignored";
//     MmuCore.cpp applies the same to FAR, which the manual doesn't
//     separately call out but which has no defined write behavior
//     either since software only ever reads it).

#include "../mmu_common.h"

int main(void)
{
    unsigned int ok_control, ok_ctp, ok_context;
    unsigned int ok_fsr_write_ignored, ok_far_write_ignored;
    unsigned int pass, diag;

    // 0x1FE, not 0x1FF: bit0 is the Control Register's own E (Enable)
    // bit (Ref Figure H-10) -- setting it here, with no page tables
    // configured at all, would enable the MMU and corrupt every
    // subsequent memory access this test makes (including its own stack
    // spills). This test is about plain register storage, not
    // translation, so E must stay clear.
    store_word_mmureg(0x000001FEu, MMU_REG_CONTROL);
    ok_control = (load_word_mmureg(MMU_REG_CONTROL) == 0x000001FEu) ? 1 : 0;

    store_word_mmureg(0xABCDE000u, MMU_REG_CTX_TBL_PTR);
    ok_ctp = (load_word_mmureg(MMU_REG_CTX_TBL_PTR) == 0xABCDE000u) ? 1 : 0;

    store_word_mmureg(7u, MMU_REG_CONTEXT);
    ok_context = (load_word_mmureg(MMU_REG_CONTEXT) == 7u) ? 1 : 0;

    // FSR/FAR both reset to 0 (no fault has occurred). Writing them
    // must have no effect either way.
    store_word_mmureg(0xDEADBEEFu, MMU_REG_FAULT_STATUS);
    ok_fsr_write_ignored = (load_word_mmureg(MMU_REG_FAULT_STATUS) == 0u) ? 1 : 0;

    store_word_mmureg(0xDEADBEEFu, MMU_REG_FAULT_ADDR);
    ok_far_write_ignored = (load_word_mmureg(MMU_REG_FAULT_ADDR) == 0u) ? 1 : 0;

    pass = ok_control && ok_ctp && ok_context && ok_fsr_write_ignored && ok_far_write_ignored;
    diag = ok_control | (ok_ctp << 1) | (ok_context << 2) | (ok_fsr_write_ignored << 3) | (ok_far_write_ignored << 4);

    __asm__ __volatile__("mov %0, %%o0" : : "r"(pass));
    __asm__ __volatile__("mov %0, %%o1" : : "r"(diag));
    __asm__ __volatile__("ta 0");
    while (1) {}
    return 0;
}

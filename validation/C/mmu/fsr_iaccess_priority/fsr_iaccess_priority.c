// fsr_iaccess_priority.c
//
// An instruction-access fault must never overwrite an unread
// data-access fault in FSR/FAR (Ref Appendix H.5). Exercised for real,
// not suppressed: an ordinary supervisor-mode instruction fetch that
// faults always traps the processor regardless of NF (Ref Appendix H.3:
// NF's suppression explicitly excludes ASI 9, Supervisor Instruction --
// see Mmu.cpp's noFaultSuppressesTrap()), so the only way to inspect
// FSR *after* such a fault, before the program halts, is from inside
// the trap handler itself. crt0.s's own default handler for every trap
// (`mov N,%g1; restore; ta 0`) doesn't read FSR, so this test replaces
// just the one slot it needs -- instruction_access_exception, trap type
// 0x01 -- with a 4-instruction handler of its own: read FSR into %o0,
// halt. Deliberately not a `restore`-then-halt like crt0's own handlers
// -- this one wants its *own* freshly-read %o0 to be what the final
// halted state shows, not whatever %o0 held before the trap (trap entry
// shifts the register window, so the two are genuinely different
// physical registers).
//
// The replacement handler is written once, at file scope, so nothing
// but its own 4 instructions ends up there -- no compiler-generated
// prologue/epilogue -- then copied over the live trap table at runtime.
// crt0.s already pointed TBR at its own 4096-byte-aligned table, and
// each trap type's handler is a fixed 16-byte (4-instruction) slot at
// TBR_base + type*16; reading TBR back (outside of an active trap, so
// its low bits are exactly 0) gives that base address directly.
//
// Only FSR (not FAR) is checked -- H.5's fault-class-priority claim is
// about FSR's fields, and the replacement handler's fixed 4-instruction
// budget has no room to also read FAR. The expected value's mask (see
// the .vprj) covers only OW/FAV/FT/AT (bits 7:0), not the L (walk
// level) field -- this test is about whether the *first* fault's record
// survives, not which level it was found at (already covered by
// access_fault_matrix and huge_page_levels).

#include "../mmu_common.h"

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));

#define PHYS_RO_FRAME 0x01000000u // ACC_RO_RO: triggers the initial (data) fault
#define PHYS_NX_FRAME 0x02000000u // ACC_RW_RW: no execute permission for anybody

#define VA_RO TEST_VA_BASE
#define VA_NX (TEST_VA_BASE + 0x01000000u)

// Replacement instruction_access_exception handler: exactly 4
// instructions (16 bytes), matching crt0.s's own per-trap slot size.
// File-scope (basic) asm -- register names use a single '%', unlike the
// extended asm blocks below.
__asm__(
    ".global fsr_iaccess_handler\n"
    "fsr_iaccess_handler:\n"
    "\tmov 0x300, %l0\n"     // MMU_REG_FAULT_STATUS
    "\tlda [%l0] 0x04, %o0\n"
    "\tta 0\n"
    "\tnop\n"
);
extern int fsr_iaccess_handler[];

int main(void)
{
    unsigned int tbr;
    unsigned int* trap_slot_0x01;
    int i;

    setup_safe_l1_table(l1_table, make_pte(PHYS_RO_FRAME, ACC_RO_RO, 1));
    l1_table[L1_INDEX_TEST + 1] = make_pte(PHYS_NX_FRAME, ACC_RW_RW, 1);
    enable_mmu_with_l1_table(context_table, l1_table);
    store_word_mmureg(MMU_CONTROL_E_BIT | MMU_CONTROL_NF_BIT, MMU_REG_CONTROL);

    // Locate crt0.s's own trap table and overwrite just the
    // instruction_access_exception slot with the handler above.
    __asm__ __volatile__("rd %%tbr, %0" : "=r"(tbr));
    trap_slot_0x01 = (unsigned int*) (tbr + 0x01u * 16u);
    for (i = 0; i < 4; i++)
        trap_slot_0x01[i] = ((unsigned int*) fsr_iaccess_handler)[i];

    // Fault 1 (DACCESS, protection error), suppressed by NF, left
    // unread: store on the read-only region.
    store_word_user_data(0x11111111u, (unsigned int*) VA_RO);

    // Fault 2: a real instruction fetch from a no-execute region, in
    // supervisor mode (crt0 never leaves it) -- always traps (ASI 9 is
    // never suppressed), landing in the patched handler above, which
    // reads FSR into %o0 and halts. Nothing after this block ever runs.
    {
        unsigned int target = VA_NX;
        __asm__ __volatile__("jmp %0\n\tnop" : : "r"(target));
    }

    while (1) {} // not reached
    return 0;
}

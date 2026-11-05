// store_fault_traps_std.c
//
// A faulting store with the MMU's NF bit clear must take a data access exception, as a
// faulting load does. The store's reply carries the fault back to the core. Other tests
// of store faults set NF and read the fault status register, so they cannot tell whether
// the trap happened. This one requires it: the crt0 trap table leaves the trap type in
// %g1 and halts. If the store does not trap, the program goes on and reaches its own
// `ta 0`, and %g1 ends up holding that trap's type instead.
//
// In the .vprj: %g1 = 9, the trap type of a data access exception.

#include "../mmu_common.h"

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));

int main(void)
{
    setup_safe_l1_table(l1_table, 0); //nothing mapped at TEST_VA_BASE
    context_table[0] = make_ptd(l1_table);
    store_word_mmureg(make_ptd(context_table), MMU_REG_CTX_TBL_PTR);
    store_word_mmureg(MMU_CONTROL_E_BIT, MMU_REG_CONTROL);

    __asm__ __volatile__("mov %%g0, %%g1\n\t"
                         "set 0x10000000, %%g4\n\t"
                         "mov 0x55, %%g2\n\t"
                         "mov 0x66, %%g3\n\t"
                         "std %%g2, [%%g4]\n\t"
                         "mov %%g0, %%g1\n\t"
                         "ta 0"
                         : : : "g1", "g2", "g3", "g4", "memory");
    while (1) {}
    return 0;
}

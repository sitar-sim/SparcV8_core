// mmu_common.h
//
// Shared helpers for validation/C/mmu/ tests: MMU register and ASI
// access (Ref SPARC V8 Appendix H, Table H-5; Appendix I, Table I-1),
// PTE/PTD construction, and a standard "safe" page-table skeleton every
// test builds on. ASI/register-offset values match this project's own
// model/cpp_common_code/mmu/Addresses.h and AsiValues.h exactly (both,
// like AJIT's own mmu_access_routines.h, come directly from the manual,
// so there's nothing project-specific to diverge on).
//
// Included via a relative path ("../mmu_common.h") from each test's own
// subfolder -- compile_c.sh's gcc invocation has no extra -I flags, but
// plain #include "..." already searches relative to the including file,
// so no build-script change is needed.

#ifndef MMU_COMMON_H
#define MMU_COMMON_H

#define ASI_MMU_FLUSH_PROBE 0x03
#define ASI_MMU_REGISTER    0x04

// MMU register virtual addresses, VA[31:8] (Table H-5); VA[7:0] ignored.
#define MMU_REG_CONTROL      ((unsigned int*) 0x00000000)
#define MMU_REG_CTX_TBL_PTR  ((unsigned int*) 0x00000100)
#define MMU_REG_CONTEXT      ((unsigned int*) 0x00000200)
#define MMU_REG_FAULT_STATUS ((unsigned int*) 0x00000300)
#define MMU_REG_FAULT_ADDR   ((unsigned int*) 0x00000400)

// Control Register bits (Figure H-10).
#define MMU_CONTROL_E_BIT                0x00000001u
#define MMU_CONTROL_NF_BIT               0x00000002u
#define MMU_CONTROL_ALWAYS_CACHEABLE_BIT 0x00000100u

// PTE/PTD Entry Type encoding (Ref H.3.2).
#define PTE_ET_INVALID  0
#define PTE_ET_PTD      1
#define PTE_ET_PTE      2
#define PTE_ET_RESERVED 3

// R (Referenced) and M (Modified) bits within a leaf PTE (Ref H.3.2,
// Figure H-8). make_pte() below always constructs R=M=0 (a freshly
// created, unreferenced leaf); the MMU itself sets these on a real
// access (Ref Mmu::translate()'s setR/setM logic).
#define PTE_R(pte) (((pte) >> 5) & 0x1u)
#define PTE_M(pte) (((pte) >> 6) & 0x1u)

// ACC field (Ref H.3.2's ACC table).
#define ACC_RO_RO   0 // Read Only (user), Read Only (supervisor)
#define ACC_RW_RW   1 // Read/Write, Read/Write
#define ACC_RX_RX   2 // Read/Execute, Read/Execute
#define ACC_RWX_RWX 3 // Read/Write/Execute, Read/Write/Execute
#define ACC_X_X     4 // Execute Only, Execute Only
#define ACC_RO_RW   5 // Read Only (user), Read/Write (supervisor)
#define ACC_NA_RX   6 // No Access (user), Read/Execute (supervisor)
#define ACC_NA_RWX  7 // No Access (user), Read/Write/Execute (supervisor)

// FSR field extraction (Figure H-13).
#define FSR_OW(fsr)  ((fsr) & 0x1)
#define FSR_FAV(fsr) (((fsr) >> 1) & 0x1)
#define FSR_FT(fsr)  (((fsr) >> 2) & 0x7)
#define FSR_AT(fsr)  (((fsr) >> 5) & 0x7)
#define FSR_L(fsr)   (((fsr) >> 8) & 0x3)

// Fault Type (FT) values (Ref H.5).
#define FT_NONE                  0
#define FT_INVALID_ADDRESS_ERROR 1
#define FT_PROTECTION_ERROR      2
#define FT_PRIVILEGE_VIOLATION   3
#define FT_TRANSLATION_ERROR     4

// Access Type (AT) values (Ref H.5).
#define AT_LOAD_USER_DATA        0
#define AT_LOAD_SUPERVISOR_DATA  1
#define AT_LOAD_USER_INSTR       2
#define AT_LOAD_SUPERVISOR_INSTR 3
#define AT_STORE_USER_DATA       4
#define AT_STORE_SUPERVISOR_DATA 5
#define AT_STORE_USER_INSTR      6
#define AT_STORE_SUPERVISOR_INSTR 7

// SPARC V8 trap type numbers (Ref Chapter 7's trap table), used to check
// %g1 after a deliberately-uncaught (NF=0) MMU fault -- see crt0.s's
// trap table, which stores the trap number into %g1 before halting.
#define TRAP_INSTRUCTION_ACCESS_EXCEPTION 0x01
#define TRAP_DATA_ACCESS_EXCEPTION        0x09

static inline __attribute__((always_inline)) unsigned int load_word_mmureg(unsigned int* addr)
{
    unsigned int value;
    __asm__ __volatile__("lda [%1] 0x04, %0" : "=r"(value) : "r"(addr));
    return value;
}

static inline __attribute__((always_inline)) void store_word_mmureg(unsigned int value, unsigned int* addr)
{
    __asm__ __volatile__("sta %0, [%1] 0x04" : : "r"(value), "r"(addr));
}

// Explicit user-data-space (ASI 0x0A -- Ref Table I-1: 0x08=User
// Instruction, 0x09=Supervisor Instruction, 0x0A=User Data, 0x0B=
// Supervisor Data) access, distinct from an ordinary C pointer
// dereference (which always uses the CPU's current PSR-implied ASI --
// 0x0B, supervisor data, in every test here, since crt0.s runs with
// PSR.S=1). Needed to reach AT 0 (load) / AT 4 (store) of the fault
// matrix at all from supervisor-mode test code, and because NF's trap
// suppression explicitly excludes ASI 0x0B (Ref Appendix H.3): only a
// non-supervisor-data fault can be suppressed, so exercising the fault
// matrix under NF=1 without halting requires user-data ASI specifically.
static inline __attribute__((always_inline)) unsigned int load_word_user_data(unsigned int* addr)
{
    unsigned int value;
    __asm__ __volatile__("lda [%1] 0x0a, %0" : "=r"(value) : "r"(addr));
    return value;
}

static inline __attribute__((always_inline)) void store_word_user_data(unsigned int value, unsigned int* addr)
{
    __asm__ __volatile__("sta %0, [%1] 0x0a" : : "r"(value), "r"(addr));
}

static inline __attribute__((always_inline)) unsigned int mmu_probe(unsigned int* addr)
{
    unsigned int value;
    __asm__ __volatile__("lda [%1] 0x03, %0" : "=r"(value) : "r"(addr));
    return value;
}

static inline __attribute__((always_inline)) void mmu_flush(unsigned int* addr)
{
    __asm__ __volatile__("sta %%g0, [%0] 0x03" : : "r"(addr));
}

// Table H-6: a flush/probe address encodes VA[31:12] (page number) in
// its own bits[31:12] and the Type field in bits[11:8]; bits[7:0] are
// unused. Used for both flush (store) and probe (load) via ASI 3.
#define FLUSH_PROBE_TYPE_PAGE    0
#define FLUSH_PROBE_TYPE_SEGMENT 1
#define FLUSH_PROBE_TYPE_REGION  2
#define FLUSH_PROBE_TYPE_CONTEXT 3
#define FLUSH_PROBE_TYPE_ENTIRE  4

static inline __attribute__((always_inline)) unsigned int* flush_probe_addr(unsigned int va, unsigned int type)
{
    return (unsigned int*) ((va & 0xFFFFF000u) | (type << 8));
}

// PTD encoding (Ref Figure H-7): the Page Table Pointer field "appears
// on bits 35 through 6 of the physical address bus" and occupies PTD
// bits[31:2], with ET=1 (PTD) in bits[1:0]. table_addr must already be
// aligned to its own table's size (1024 bytes for an L1 table, 256 for
// L2/L3, both comfortably above the 64-byte granularity this encoding
// can represent) -- true of every static table declared in these tests
// (aligned(1024) throughout).
static inline __attribute__((always_inline)) unsigned int make_ptd(void* table_addr)
{
    unsigned int a = (unsigned int) table_addr;
    return ((a >> 6) << 2) | PTE_ET_PTD;
}

// Leaf PTE encoding (Ref H.3.2): PPN in bits[31:8] (= phys_addr[35:12],
// but physical addresses never exceed 32 bits in this model -- Ref
// Notes_multi_core_modeling.md), R=M=0 (freshly created, unreferenced),
// C in bit 7, ACC in bits[4:2], ET=2 (PTE) in bits[1:0]. Works uniformly
// for an ordinary 4KB leaf or a huge-page leaf at level 0/1/2, as long
// as phys_addr is aligned to that level's own mapping granularity
// (Table H-1) -- the resulting PPN's low bits come out zero either way.
static inline __attribute__((always_inline)) unsigned int make_pte(unsigned int phys_addr, unsigned int acc, unsigned int cacheable)
{
    return ((phys_addr >> 12) << 8) | (cacheable ? 0x80u : 0u) | (acc << 2) | PTE_ET_PTE;
}

// Every test's L1 table reserves these two indices (VA[31:24]) to
// identity-map the code (VA 0x00000000) and stack (VA 0x0F000000)
// regions, so that enabling the MMU never breaks the program currently
// running -- crt0.s sets %sp = 0x0ffffff0, near the top of the model's
// 256MB memory (Ref MemCore.h), nowhere near .text/.data/.bss at the
// bottom. Index 0x10 (VA 0x10000000) is left free as each test's own
// "playground" -- what goes there is entirely up to the test.
#define L1_INDEX_CODE  0x00
#define L1_INDEX_STACK 0x0F
#define L1_INDEX_TEST  0x10
#define TEST_VA_BASE   0x10000000u

// Fills l1_table[L1_INDEX_CODE] and l1_table[L1_INDEX_STACK] with
// identity-mapped, full-access, cacheable 16MB leaf PTEs, invalidates
// every other entry, then sets l1_table[L1_INDEX_TEST] to test_entry
// (whatever the caller wants there -- a further PTD, a differently-
// permissioned leaf, or left invalid/reserved for a fault test). Does
// not touch the context table or context register -- most tests only
// need context 0 (the reset default) and call this once; a test
// specifically about context-switching builds more than one L1 table
// and calls this once per context instead.
static inline __attribute__((always_inline)) void setup_safe_l1_table(unsigned int* l1_table, unsigned int test_entry)
{
    int i;
    for (i = 0; i < 256; i++) l1_table[i] = 0;
    l1_table[L1_INDEX_CODE]  = make_pte(0x00000000u, ACC_RWX_RWX, 1);
    l1_table[L1_INDEX_STACK] = make_pte(0x0F000000u, ACC_RWX_RWX, 1);
    l1_table[L1_INDEX_TEST]  = test_entry;
}

// Points context 0's context-table entry at l1_table (as a PTD) and
// enables the MMU (E=1), leaving NF and every other control bit clear.
// context_table must have at least 1 entry; every test here uses only
// context 0 unless it's specifically testing context-switching.
//
// The Context Table Pointer Register itself is PTD-shaped too (Figure
// H-11: address bits[35:4] in bits[31:2], low 2 bits reserved) -- the
// walker's own getPhyAddrFromPTD() treats it exactly like an ordinary
// PTD when locating the context-table entry, so it's built with the
// same make_ptd() used for every other level, not a plain address.
static inline __attribute__((always_inline)) void enable_mmu_with_l1_table(unsigned int* context_table, unsigned int* l1_table)
{
    context_table[0] = make_ptd(l1_table);
    store_word_mmureg(make_ptd(context_table), MMU_REG_CTX_TBL_PTR);
    store_word_mmureg(MMU_CONTROL_E_BIT, MMU_REG_CONTROL);
}

#endif

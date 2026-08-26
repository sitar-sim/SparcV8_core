//AsiValues.h
//
//SPARC V8 Address Space Identifier (ASI) assignments (Ref Appendix I in
//the SPARC V8 Architecture Reference Manual, Table I-1). A SPARC-ISA-level
//concept, not MMU-specific: ASI_USER_DATA/ASI_SUPERVISOR_DATA/etc. are the
//ordinary spaces every load/store/ifetch already carries (see
//SparcCore::execute_PreLoad and friends, core.addr_space), and the cache
//tag/data/flush ASIs below will be needed by the caches block too. Kept at
//this top level rather than under mmu/ for that reason.

#ifndef ASI_VALUES_H
#define ASI_VALUES_H

#include <stdint.h>

#define ASI_MMU_FLUSH_PROBE            0x03
#define ASI_MMU_REGISTER               0x04
#define ASI_MMU_DIAGNOSTIC_I            0x05
#define ASI_MMU_DIAGNOSTIC_I_D           0x06
#define ASI_MMU_DIAGNOSTIC_IO            0x07

#define ASI_USER_INSTRUCTION            0x08
#define ASI_SUPERVISOR_INSTRUCTION       0x09

#define ASI_USER_DATA                   0x0A
#define ASI_SUPERVISOR_DATA              0x0B

#define ASI_CACHE_TAG_I                  0x0C
#define ASI_CACHE_DATA_I                 0x0D
#define ASI_CACHE_TAG_I_D                0x0E
#define ASI_CACHE_DATA_I_D               0x0F

#define ASI_FLUSH_I_D_PAGE               0x10
#define ASI_FLUSH_I_D_SEGMENT            0x11
#define ASI_FLUSH_I_D_REGION             0x12
#define ASI_FLUSH_I_D_CONTEXT            0x13
#define ASI_FLUSH_I_D_USER               0x14

#define ASI_BLOCK_COPY                   0x17

#define ASI_FLUSH_I_PAGE                 0x18
#define ASI_FLUSH_I_SEGMENT              0x19
#define ASI_FLUSH_I_REGION                0x1A
#define ASI_FLUSH_I_CONTEXT               0x1B
#define ASI_FLUSH_I_USER                  0x1C

#define ASI_BLOCK_FILL                    0x1F

//All ASIs in 0x20-0x2F are MMU physical-address pass-through.
inline bool asiMmuPassThrough(uint8_t asi) { return asi >= 0x20 && asi <= 0x2F; }

inline bool asiIsIcacheFlush(uint8_t asi) { return asi >= 0x18 && asi <= 0x1C; }
inline bool asiIsDcacheFlush(uint8_t asi) { return asi >= 0x10 && asi <= 0x14; }
inline bool asiIsCacheTagOrData(uint8_t asi) { return asi >= 0x0C && asi <= 0x0F; }

inline bool asiIsReserved(uint8_t asi)
{
	return asi == 0x00 || asi == 0x15 || asi == 0x16 || asi == 0x1D || asi == 0x1E
		|| (asi >= 0x80 && asi <= 0xFF);
}
inline bool asiIsUnassigned(uint8_t asi)
{
	return asi == 0x01 || asi == 0x02 || (asi >= 0x30 && asi <= 0x7F);
}

inline bool asiIsMmuAccess(uint8_t asi)
{
	return asi == ASI_MMU_FLUSH_PROBE || asi == ASI_MMU_REGISTER
		|| asi == ASI_MMU_DIAGNOSTIC_I || asi == ASI_MMU_DIAGNOSTIC_I_D || asi == ASI_MMU_DIAGNOSTIC_IO;
}

inline bool asiIsUserOrSupervisor(uint8_t asi)
{
	return asi == ASI_USER_INSTRUCTION || asi == ASI_SUPERVISOR_INSTRUCTION
		|| asi == ASI_USER_DATA || asi == ASI_SUPERVISOR_DATA;
}

//Bit 0 of the ASI's low nibble set (0x9 or x..xB) identifies a
//supervisor-only space; see IS_SUPERVISOR_ASI in Ajit's ASI_values.h.
inline bool asiIsSupervisor(uint8_t asi) { return asi == 0x9 || (asi & 0xf) == 0xB; }

#endif

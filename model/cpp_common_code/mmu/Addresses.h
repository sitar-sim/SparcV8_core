//Addresses.h
//
//MMU-specific constants: the register-select decode (Ref Appendix H,
//Table H-5), the Control Register and Fault Status Register bit-field
//layouts (Figures H-10 and H-13), the PTE bit-field layout, and the
//Access Type (AT) / Fault Type (FT) enumerations (Ref Appendix H.5).
//General SPARC ASI values live in ../AsiValues.h instead, one level up,
//since they're not MMU-specific (the caches block needs the cache ASIs
//from that same file too).

#ifndef MMU_ADDRESSES_H
#define MMU_ADDRESSES_H

#include <stdint.h>
#include "MmuConfig.h"

namespace MmuRegisterSelect
{
	//VA[31:8] when accessed through ASI_MMU_REGISTER (Table H-5).
	const uint32_t CONTROL              = 0;
	const uint32_t CONTEXT_TABLE_POINTER = 1;
	const uint32_t CONTEXT              = 2;
	const uint32_t FAULT_STATUS         = 3;
	const uint32_t FAULT_ADDRESS        = 4;
}

namespace MmuControlBits
{
	//Figure H-10: IMPL[31:28] VER[27:24] SC[23:8] PSO[7] reserved[6:2] NF[1] E[0].
	const uint32_t E_BIT   = 0; //Enable
	const uint32_t NF_BIT  = 1; //No Fault
	const uint32_t PSO_BIT = 7;

	//SC[23:8] is fully implementation-defined (spec-legal either way, see
	//Plan_MMU_integration.md's "Deviations" section, item 4). Which bit,
	//within that range, means "always cacheable regardless of the PTE's
	//C bit" is a modeling choice, not a spec value -- lives in
	//MmuConfig.h alongside this model's other structural parameters.
	const uint32_t ALWAYS_CACHEABLE_BIT = MMU_CONTROL_ALWAYS_CACHEABLE_BIT;
}

namespace MmuFsrBits
{
	//Figure H-13: reserved[31:18] EBE[17:10] L[9:8] AT[7:5] FT[4:2] FAV[1] OW[0].
	const uint32_t OW_BIT       = 0;
	const uint32_t FAV_BIT      = 1;
	const uint32_t FT_LOW_BIT   = 2;
	const uint32_t FT_HIGH_BIT  = 4;
	const uint32_t AT_LOW_BIT   = 5;
	const uint32_t AT_HIGH_BIT  = 7;
	const uint32_t L_LOW_BIT    = 8;
	const uint32_t L_HIGH_BIT   = 9;
	const uint32_t EBE_LOW_BIT  = 10;
	const uint32_t EBE_HIGH_BIT = 17;
}

namespace PteBits
{
	//PTE/PTD field layout, common to every page-table level.
	const uint32_t ET_LOW_BIT  = 0;
	const uint32_t ET_HIGH_BIT = 1;
	const uint32_t ACC_LOW_BIT  = 2;
	const uint32_t ACC_HIGH_BIT = 4;
	const uint32_t R_BIT = 5; //Referenced
	const uint32_t M_BIT = 6; //Modified
	const uint32_t C_BIT = 7; //Cacheable
	const uint32_t PPN_LOW_BIT  = 8;
	const uint32_t PPN_HIGH_BIT = 31;

	//ET (Entry Type) encoding.
	const uint32_t ET_INVALID  = 0;
	const uint32_t ET_PTD      = 1; //points to the next-level table
	const uint32_t ET_PTE      = 2; //valid leaf entry
	const uint32_t ET_RESERVED = 3;
}

//Access Type (AT), Ref Appendix H.5. Computed from the ASI and whether
//the access is a load, store, or instruction fetch.
namespace AccessType
{
	const uint8_t LOAD_USER_DATA              = 0;
	const uint8_t LOAD_SUPERVISOR_DATA        = 1;
	const uint8_t LOAD_USER_INSTRUCTION       = 2;
	const uint8_t LOAD_SUPERVISOR_INSTRUCTION = 3;
	const uint8_t STORE_USER_DATA              = 4;
	const uint8_t STORE_SUPERVISOR_DATA        = 5;
	const uint8_t STORE_USER_INSTRUCTION       = 6;
	const uint8_t STORE_SUPERVISOR_INSTRUCTION = 7;
}

//Fault Type (FT), Ref Appendix H.5.
namespace FaultType
{
	const uint8_t NONE                  = 0;
	const uint8_t INVALID_ADDRESS_ERROR = 1;
	const uint8_t PROTECTION_ERROR      = 2;
	const uint8_t PRIVILEGE_VIOLATION   = 3;
	const uint8_t TRANSLATION_ERROR     = 4;
	const uint8_t ACCESS_BUS_ERROR      = 5;
	const uint8_t INTERNAL_ERROR        = 6;
}

namespace PageTableWalk
{
	const uint32_t PAGE_SIZE_BITS = 12; //4KB pages
	const uint32_t PHYSICAL_ADDRESS_BITS = 36;

	//Virtual address index fields into the context/L1/L2/L3 tables.
	const uint32_t L1_INDEX_LOW_BIT = 24, L1_INDEX_HIGH_BIT = 31;
	const uint32_t L2_INDEX_LOW_BIT = 18, L2_INDEX_HIGH_BIT = 23;
	const uint32_t L3_INDEX_LOW_BIT = 12, L3_INDEX_HIGH_BIT = 17;
}

#endif

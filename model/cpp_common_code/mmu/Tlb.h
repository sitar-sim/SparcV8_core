//Tlb.h
//
//The Page Descriptor Cache (PDC), Ref Appendix H in the SPARC V8 manual.
//Purpose-built for this port rather than a port of Ajit's generic
//associative-memory library (see Plan_MMU_integration.md); same sizing,
//associativity, and context-qualified tag semantics per level.
//
//Mirrors the page-table walk's own four levels (0 = context table, 1-3 =
//L1/L2/L3 tables). A cached entry is always a leaf PTE (ET == 2), never
//a PTD -- Mmu only ever inserts an entry once walkPageTables() has
//actually found a valid leaf, exactly as Ajit's writeTlbNewEntry() does.
//Because the page-table walk can terminate at any level (a "huge page"
//leaf found early, without descending further -- see
//Mmu::constructPhysicalAddr's level-dependent page-offset width), a
//level-0 entry is tagged by context alone (it covers the entire 4GB
//space for that context), a level-1 entry by (context, VA[31:24]) --
//covering a 16MB region -- level-2 by (context, VA[31:18]) -- 256KB --
//and level-3 by (context, VA[31:12]) -- one 4KB page, the common case.
//
//Sizing (see MmuConfig.h): level 0, 1, and 2 are fully associative,
//level 3 is set-associative, indexed by the low bits of the page number
//(VA[12] upward -- however many bits MMU_TLB_LEVEL3_SETS needs).

#ifndef MMU_TLB_H
#define MMU_TLB_H

#include <stdint.h>
#include "MmuConfig.h"

class Tlb
{
	public:
		Tlb();

		//Remove every entry, at every level (Ref Appendix H.7's "Reset").
		void clear();

		//Look up a full virtual address in the given context. Checks
		//levels 0..3 in order (a walk can terminate at any level, so
		//more than one level might in principle hold something relevant;
		//Ajit's own isTlbNewHit() and this both just take the first hit
		//found, level 0 first). On a hit, fills pte/level/phyAddrOfPte
		//and returns true.
		bool lookup(uint32_t va, uint32_t context, uint32_t& pte, uint8_t& level, uint64_t& phyAddrOfPte) const;

		//Insert an entry found via a page-table walk (a leaf PTE, at the
		//level the walk actually terminated at). Round-robin replacement
		//within the target set if it's already full, matching Ajit's own
		//`last_updated_offset_in_set`-style behavior.
		void insert(uint32_t va, uint32_t context, uint32_t pte, uint8_t level, uint64_t phyAddrOfPte);

		//Update the cached PTE value in place (after an R/M-bit
		//write-back to memory), if this exact entry is still present.
		//Avoids the re-walk Ajit's own translateToPhysicalAddress() does
		//to relocate a PTE it already had cached, by using the
		//phyAddrOfPte insert() already stored -- see Mmu.cpp.
		void updatePte(uint32_t va, uint32_t context, uint8_t level, uint32_t newPte);

		//Selective flush, Ref Appendix H.3 and Table H-2 (this TLB only
		//ever caches leaf PTEs, never PTDs, so Table H-3's PTD criteria
		//never apply here -- see the class comment above).
		//flushType: 0=page, 1=segment, 2=region, 3=context, 4=entire,
		//matching VA[11:8] of an ASI_MMU_FLUSH_PROBE access (Ref Table
		//H-6). va/context are only consulted for types 0-3.
		//
		//A cached entry may hold less VA precision than the flush type
		//nominally compares (e.g. a level-1 entry only knows VA[31:24],
		//but a page flush's criterion is "VA[31:12]_equal"). The manual
		//doesn't spell out this mixed-precision case directly, but it
		//follows from what a walk depth means: a level-1 leaf is a single
		//16MB mapping, so if any of its covered pages is the flush
		//target, the whole entry must go. The rule implemented here:
		//compare over min(the flush type's own bit width, the entry's own
		//stored bit width), from VA[31:12+n] as-is that's implied by the
		//existing "min" of the two -- see flush()'s implementation comment
		//for the exact widths.
		void flush(uint8_t flushType, uint32_t va, uint32_t context);

	private:
		struct Entry
		{
			bool     valid;
			uint32_t vaTag;         //meaning depends on level -- see class comment
			uint32_t context;
			uint32_t pte;
			uint8_t  level;
			uint64_t phyAddrOfPte;
		};

		//Sizing lives in MmuConfig.h, one level up -- these are just
		//short local aliases so the rest of this file stays readable.
		static const int LEVEL0_ENTRIES = MMU_TLB_LEVEL0_ENTRIES;
		static const int LEVEL1_ENTRIES = MMU_TLB_LEVEL1_ENTRIES;
		static const int LEVEL2_ENTRIES = MMU_TLB_LEVEL2_ENTRIES;
		static const int LEVEL3_SETS    = MMU_TLB_LEVEL3_SETS;
		static const int LEVEL3_WAYS    = MMU_TLB_LEVEL3_WAYS; //SETS * WAYS entries total

		//LEVEL3_SETS constraints (Ref MmuConfig.h's own comment on
		//MMU_TLB_LEVEL3_SETS for the reasoning): must be a power of two,
		//and small enough to leave at least 1 tag bit out of the level-3
		//tag's 20 bits (VA[31:12]).
		static_assert((LEVEL3_SETS & (LEVEL3_SETS - 1)) == 0, "MMU_TLB_LEVEL3_SETS must be a power of two");
		static_assert(LEVEL3_SETS >= 1 && LEVEL3_SETS <= (1 << 19),
		              "MMU_TLB_LEVEL3_SETS must leave at least 1 tag bit out of the level-3 tag's 20 bits (VA[31:12])");

		Entry level0_[LEVEL0_ENTRIES];
		Entry level1_[LEVEL1_ENTRIES];
		Entry level2_[LEVEL2_ENTRIES];
		Entry level3_[LEVEL3_SETS][LEVEL3_WAYS];

		int nextReplace0_;
		int nextReplace1_;
		int nextReplace2_;
		int nextReplace3_[LEVEL3_SETS];

		//How many low-order bits of the level-3 tag (i.e. starting at
		//VA[12]) select a set -- log2(LEVEL3_SETS), computed once in the
		//constructor (not on every lookup/insert). level3SetIndex() below
		//uses this instead of a hardcoded bit width, so LEVEL3_SETS is a
		//genuine parameter rather than only working for its current value.
		int level3SetIndexBits_;

		//The level-appropriate VA tag (see the class comment for what
		//each level actually stores) and, for level 3, which of the
		//LEVEL3_SETS sets it belongs to.
		static uint32_t vaTagForLevel(uint32_t va, uint8_t level);
		int level3SetIndex(uint32_t va) const;

		//How many of the top VA bits vaTagForLevel() above actually
		//distinguishes between two addresses, per level -- 0 (level 0,
		//context only), 8 (level 1), 14 (level 2), 20 (level 3). Used by
		//flush()'s mixed-precision comparison.
		static int vaTagBitsForLevel(uint8_t level);
};

#endif

//MmuStats.h
//
//Functional and architectural MMU statistics, common to both the cpp
//and Sitar models. Owned by MmuCore the same way SparcCore::logger is
//owned by SparcCore. Deliberately excludes anything timing-related,
//such as cycles spent walking.

#ifndef MMU_STATS_H
#define MMU_STATS_H

#include <cstdint>
#include <string>

class MmuStats
{
	public:
		MmuStats();

		//TLB hits per level (0-3), and misses (any access that needed a
		//page-table walk because it wasn't found at any level).
		uint32_t tlbHitsAtLevel[4];
		uint32_t tlbMisses;

		//Page-table walks, broken down by which level the walk
		//terminated at: a valid leaf PTE found at level L increments
		//walksTerminatedAtLevel[L]; a walk that found no valid PTE at
		//all (ET stayed 0/1/3 all the way to level 3) increments
		//walksNotFound.
		uint32_t walksTerminatedAtLevel[4];
		uint32_t walksNotFound;

		//Physical memory accesses issued purely to walk the page tables
		//(one per level actually visited), distinct from
		//translatedAccesses below, which counts the CPU-visible access
		//the translation was for, not the walk's own internal reads.
		uint32_t pageTableMemoryAccesses;

		//Faults, broken down by type (Ref Appendix H.5's FT field).
		uint32_t faultsInvalidAddress;
		uint32_t faultsProtection;
		uint32_t faultsPrivilege;
		uint32_t faultsTranslationError;

		uint32_t referencedBitWriteBacks;
		uint32_t modifiedBitWriteBacks;

		uint32_t registerReads;
		uint32_t registerWrites;

		uint32_t flushRequests;
		uint32_t probeRequests;
		uint32_t bypassAccesses;
		uint32_t translatedAccesses;

		uint32_t contextRegisterWrites;

		//A human-readable dump, one line per counter -- see Ajit's own
		//printMmuStatistics() for the precedent this follows.
		std::string toString() const;
};

#endif

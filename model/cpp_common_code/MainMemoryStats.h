//MainMemoryStats.h
//
//Functional/architectural counters for MainMemory, in the same spirit as
//mmu/MmuStats.h (owned by MainMemory the same way MmuStats is owned by
//Mmu -- every MainMemory gets one for free). Sized for later comparison
//against whatever access-count instrumentation AJIT's own memory-model
//hardware exposes, once that comparison is actually done -- not derived
//from reading any specific AJIT counter set today. Deliberately excludes
//anything timing-related, matching MmuStats.

#ifndef MAIN_MEMORY_STATS_H
#define MAIN_MEMORY_STATS_H

#include <cstdint>
#include <string>

class MainMemoryStats
{
	public:
		MainMemoryStats();

		//Every doubleword transaction, broken down by PhysicalAccessType.
		uint32_t reads;
		uint32_t maskedWrites;

		//Of the reads above: how many were locked (Ref
		//MemoryInterfaces.h's `lock` field) -- the first half of an
		//atomic load-store's now-decomposed (READ-locked, WRITE) pair.
		//Reserved/always 0 until multi-island arbitration exists; kept as
		//its own counter rather than folded into `reads` since it's the
		//only trace of "this was part of an atomic access" left once
		//atomicity no longer percolates down as its own request type.
		uint32_t lockedReads;

		//Of the writes/atomics above (byte_mask, Ref MemoryInterfaces.h):
		//how many actually touched all 8 bytes of the doubleword versus
		//only some of them -- e.g. every ordinary 32-bit store or
		//page-table-entry write is a partial (4-byte) access in this
		//model, never a full one, which is itself a fact worth being able
		//to see directly rather than inferring from other counters.
		uint32_t fullDoublewordAccesses;
		uint32_t partialAccesses;

		std::string toString() const;
};

#endif

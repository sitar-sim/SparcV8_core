//MainMemory.h
//
//Physical-memory endpoint for a configuration with an MMU. Implements
//PhysicalMemoryInterface, wrapping a MemCore for the actual backing
//storage. MemCore itself is untouched, still a flat, 32-bit-indexed
//array. This wrapper's own outward-facing methods are 64-bit,
//doubleword-shaped.
//
//Used only where an MMU is present. Where there is none, the core talks
//to a plain MemCore directly.

#ifndef MAIN_MEMORY_H
#define MAIN_MEMORY_H

#include "MemoryInterfaces.h"
#include "MemCore.h"
#include "MainMemoryStats.h"
#include <string>

class MainMemory : public PhysicalMemoryInterface
{
	public:
		bool initializeMemory(std::string hex_dump_file);

		//Plain physical-word read, unrelated to PhysicalMemoryInterface
		//below (an overload, not an override) -- for a testbench's own
		//MEM checks against expected results, which want physical memory
		//state directly with no doubleword/byte-mask reasoning. Mirrors
		//MemCore::readWord(uint32_t)'s role for core_only's own harness.
		uint32_t readWord(uint32_t address);

		//PhysicalMemoryInterface: {READ, WRITE} only -- no distinct
		//atomic type (Ref MemoryInterfaces.h's file comment on why
		//atomicity doesn't percolate this far down). MmuCore.cpp issues a
		//locked READ followed by an ordinary WRITE for an atomic access.
		void access(const PhysicalMemoryRequest& request, PhysicalMemoryResponse& response) override;

		MainMemoryStats stats;

	private:
		MemCore mem_;

		//physicalAddress is 64-bit at this interface, but MemCore is
		//still 32-bit-indexed (256MB, Ref MemCore.h) -- this model never
		//actually produces a PA outside that range today, so the cast is
		//safe, but the assert catches it loudly instead of silently
		//wrapping if that ever stops being true.
		static uint32_t toMemCoreAddress(uint64_t physicalAddress);
};

#endif

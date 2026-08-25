//MemoryAccessProvider.h
//
//Abstract interface for the three memory operations SparcCore and
//SparcStateMachine need: a word read (also used for instruction fetch),
//a masked doubleword store, and an atomic load-store. Whatever a given
//cpp_model configuration connects downstream (MemCore directly today,
//later an MMU or a cache) implements this the same way, so SparcCore and
//SparcStateMachine stay unchanged as that downstream target changes --
//see Plan_SoC_Integration_Roadmap.md's "lego-block interface contract".
//FLUSH needs no method here: it computes an address but touches no
//memory in this model (see SparcCore::execute_PreFlush).

#ifndef MEMORY_ACCESS_PROVIDER_H
#define MEMORY_ACCESS_PROVIDER_H

#include <stdint.h>

class MemoryAccessProvider
{
	public:
		virtual ~MemoryAccessProvider() {}

		virtual uint32_t readWord(uint32_t address) = 0;
		virtual void writeMaskedDoubleWord(uint32_t address, uint32_t word0, uint32_t word1, uint32_t byte_mask) = 0;
		virtual void atomicReadModifyWrite(uint32_t address, uint32_t word0, uint32_t word1, uint32_t byte_mask, uint32_t& readWord0, uint32_t& readWord1) = 0;
};

#endif

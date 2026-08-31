//MainMemory.cpp

#include "MainMemory.h"
#include "BitManipulation.h"
#include <cassert>

uint32_t MainMemory::toMemCoreAddress(uint64_t physicalAddress)
{
	assert((physicalAddress >> 32) == 0 &&
	       "MainMemory: physical address exceeds MemCore's 32-bit-addressable range");
	return (uint32_t) physicalAddress;
}

bool MainMemory::initializeMemory(std::string hex_dump_file)
{
	return mem_.initializeMemory(hex_dump_file);
}

uint32_t MainMemory::readWord(uint32_t address)
{
	return mem_.readWord(address);
}

void MainMemory::access(const PhysicalMemoryRequest& request, PhysicalMemoryResponse& response)
{
	response.valid    = true;
	response.mae      = false;
	response.readData = 0;

	uint32_t addr = toMemCoreAddress(request.physicalAddress);

	if (request.accessType == PhysicalAccessType::READ)
	{
		uint32_t word0 = mem_.readWord(addr);     //low 32 bits (Ref MmuCore.cpp's packing convention)
		uint32_t word1 = mem_.readWord(addr + 4); //high 32 bits
		response.readData = (((uint64_t) word1) << 32) | (uint64_t) word0;

		stats.reads++;
		if (request.lock) stats.lockedReads++;
		stats.fullDoublewordAccesses++; //a read always fetches the whole doubleword
	}
	else //WRITE
	{
		uint32_t word0 = (uint32_t) (request.data & 0xFFFFFFFFu);
		uint32_t word1 = (uint32_t) (request.data >> 32);

		uint32_t existing0 = mem_.readWord(addr);
		uint32_t existing1 = mem_.readWord(addr + 4);
		mem_.writeWord(addr,     MemCore::mergeMaskedBytes(existing0, word0, readBits(request.byteMask, 3, 0)));
		mem_.writeWord(addr + 4, MemCore::mergeMaskedBytes(existing1, word1, readBits(request.byteMask, 7, 4)));

		stats.maskedWrites++;
		if (request.byteMask == 0xFFu) stats.fullDoublewordAccesses++; else stats.partialAccesses++;
	}
}

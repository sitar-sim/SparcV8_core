//MainMemoryStats.cpp

#include "MainMemoryStats.h"
#include <sstream>

MainMemoryStats::MainMemoryStats()
	: reads(0), maskedWrites(0), lockedReads(0),
	  fullDoublewordAccesses(0), partialAccesses(0)
{
}

std::string MainMemoryStats::toString() const
{
	std::ostringstream out;
	out << "MainMemory statistics:\n";
	out << "  Reads                     = " << reads << "\n";
	out << "  Masked writes             = " << maskedWrites << "\n";
	out << "  Locked reads              = " << lockedReads << "\n";
	out << "  Full doubleword accesses  = " << fullDoublewordAccesses << "\n";
	out << "  Partial (masked) accesses = " << partialAccesses << "\n";
	return out.str();
}

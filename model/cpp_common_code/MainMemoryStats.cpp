//MainMemoryStats.cpp
//Original Author: Neha Karanjkar
//Model Author: Claude Opus 5.5 (high)
//The model code was adapted from a Sparc v8 core simulation model written
//by the first author in C++ and Sitar (2015-2017).

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

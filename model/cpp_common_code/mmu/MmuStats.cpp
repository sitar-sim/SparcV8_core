//MmuStats.cpp
//Original Author: Neha Karanjkar
//Model Author: Claude Opus 5.5 (high)
//The model code was adapted from a Sparc v8 core simulation model written
//by the first author in C++ and Sitar (2015-2017).

#include "MmuStats.h"
#include <sstream>

MmuStats::MmuStats()
	: tlbMisses(0), walksNotFound(0), pageTableMemoryAccesses(0),
	  faultsInvalidAddress(0), faultsProtection(0), faultsPrivilege(0), faultsTranslationError(0),
	  referencedBitWriteBacks(0), modifiedBitWriteBacks(0),
	  registerReads(0), registerWrites(0),
	  flushRequests(0), probeRequests(0), bypassAccesses(0), translatedAccesses(0),
	  contextRegisterWrites(0)
{
	for (int i = 0; i < 4; i++) { tlbHitsAtLevel[i] = 0; walksTerminatedAtLevel[i] = 0; }
}

std::string MmuStats::toString() const
{
	std::ostringstream out;
	out << "MMU statistics:\n";
	for (int i = 0; i < 4; i++)
		out << "  TLB hits at level " << i << "        = " << tlbHitsAtLevel[i] << "\n";
	out << "  TLB misses                  = " << tlbMisses << "\n";
	for (int i = 0; i < 4; i++)
		out << "  Walks terminated at level " << i << " = " << walksTerminatedAtLevel[i] << "\n";
	out << "  Walks, PTE not found        = " << walksNotFound << "\n";
	out << "  Page-table memory accesses  = " << pageTableMemoryAccesses << "\n";
	out << "  Faults, invalid address     = " << faultsInvalidAddress << "\n";
	out << "  Faults, protection          = " << faultsProtection << "\n";
	out << "  Faults, privilege violation = " << faultsPrivilege << "\n";
	out << "  Faults, translation error   = " << faultsTranslationError << "\n";
	out << "  Referenced-bit write-backs  = " << referencedBitWriteBacks << "\n";
	out << "  Modified-bit write-backs    = " << modifiedBitWriteBacks << "\n";
	out << "  Register reads              = " << registerReads << "\n";
	out << "  Register writes             = " << registerWrites << "\n";
	out << "  Flush requests              = " << flushRequests << "\n";
	out << "  Probe requests               = " << probeRequests << "\n";
	out << "  Bypass accesses              = " << bypassAccesses << "\n";
	out << "  Translated accesses          = " << translatedAccesses << "\n";
	out << "  Context register writes      = " << contextRegisterWrites << "\n";
	return out.str();
}

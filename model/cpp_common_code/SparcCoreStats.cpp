//SparcCoreStats.cpp

#include "SparcCoreStats.h"
#include <sstream>

SparcCoreStats::SparcCoreStats()
	: ifetches(0), loads(0), stores(0), atomicLoadStores(0), flushes(0),
	  annulledInstructions(0),
	  trapDataStoreError(0), trapInstructionAccessError(0), trapRRegisterAccessError(0),
	  trapInstructionAccessException(0), trapPrivilegedInstruction(0), trapIllegalInstruction(0),
	  trapFpDisabled(0), trapCpDisabled(0), trapUnimplementedFlush(0),
	  trapWindowOverflow(0), trapWindowUnderflow(0), trapMemAddressNotAligned(0),
	  trapFpException(0), trapCpException(0), trapDataAccessError(0),
	  trapDataAccessException(0), trapTagOverflow(0), trapDivisionByZero(0),
	  trapTicc(0), trapInterruptLevel(0),
	  fpInstructionsExecuted(0), fpTrapsUnimplementedFPop(0), fpTrapsUnfinishedFPop(0),
	  fpTrapsIEEE754Exception(0)
{
}

std::string SparcCoreStats::toString() const
{
	std::ostringstream out;
	out << "Core statistics:\n";
	out << "  Instructions executed (ifetches) = " << ifetches << "\n";
	out << "  Loads                            = " << loads << "\n";
	out << "  Stores                           = " << stores << "\n";
	out << "  Atomic load-stores               = " << atomicLoadStores << "\n";
	out << "  Flushes                          = " << flushes << "\n";
	out << "  Annulled instructions            = " << annulledInstructions << "\n";
	out << "  Traps, data store error          = " << trapDataStoreError << "\n";
	out << "  Traps, instruction access error  = " << trapInstructionAccessError << "\n";
	out << "  Traps, r register access error   = " << trapRRegisterAccessError << "\n";
	out << "  Traps, instruction access exc.   = " << trapInstructionAccessException << "\n";
	out << "  Traps, privileged instruction    = " << trapPrivilegedInstruction << "\n";
	out << "  Traps, illegal instruction       = " << trapIllegalInstruction << "\n";
	out << "  Traps, fp disabled               = " << trapFpDisabled << "\n";
	out << "  Traps, cp disabled               = " << trapCpDisabled << "\n";
	out << "  Traps, unimplemented FLUSH       = " << trapUnimplementedFlush << "\n";
	out << "  Traps, window overflow           = " << trapWindowOverflow << "\n";
	out << "  Traps, window underflow          = " << trapWindowUnderflow << "\n";
	out << "  Traps, mem address not aligned   = " << trapMemAddressNotAligned << "\n";
	out << "  Traps, fp exception              = " << trapFpException << "\n";
	out << "  Traps, cp exception              = " << trapCpException << "\n";
	out << "  Traps, data access error         = " << trapDataAccessError << "\n";
	out << "  Traps, data access exception     = " << trapDataAccessException << "\n";
	out << "  Traps, tag overflow              = " << trapTagOverflow << "\n";
	out << "  Traps, division by zero          = " << trapDivisionByZero << "\n";
	out << "  Traps, Ticc (software)           = " << trapTicc << "\n";
	out << "  Traps, interrupt level           = " << trapInterruptLevel << "\n";
	out << "  FP instructions executed         = " << fpInstructionsExecuted << "\n";
	out << "  FP traps, unimplemented FPop     = " << fpTrapsUnimplementedFPop << "\n";
	out << "  FP traps, unfinished FPop        = " << fpTrapsUnfinishedFPop << "\n";
	out << "  FP traps, IEEE 754 exception     = " << fpTrapsIEEE754Exception << "\n";
	return out.str();
}

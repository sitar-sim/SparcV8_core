//SparcCoreStats.h
//
//Functional instruction-mix counters for SparcCore, owned by it the
//same way MmuStats is owned by MmuCore. Deliberately excludes anything
//timing-related -- total elapsed cycles is each driver's own concern
//(SparcStateMachine::cyclesExecuted, or the Sitar model's own simulated
//time), not tracked here.

#ifndef SPARC_CORE_STATS_H
#define SPARC_CORE_STATS_H

#include <cstdint>
#include <string>

class SparcCoreStats
{
	public:
		SparcCoreStats();

		//One instruction fetch per instruction executed, so this also
		//counts total instructions executed.
		uint32_t ifetches;

		uint32_t loads;
		uint32_t stores;
		uint32_t atomicLoadStores;
		uint32_t flushes;

		//Annulling branches not taken (Ref Appendix B.4's `a` bit):
		//the delay-slot instruction is fetched but never executed.
		uint32_t annulledInstructions;

		//Traps, one counter per trap source, in the same order as
		//SparcCore::selectTrap()'s own dispatch chain (Ref Appendix
		//C.8, Table 7-1). trapTicc is the only software-raised trap
		//(a `Ticc` instruction executed); every other counter here is
		//hardware-detected.
		uint32_t trapDataStoreError;
		uint32_t trapInstructionAccessError;
		uint32_t trapRRegisterAccessError;
		uint32_t trapInstructionAccessException;
		uint32_t trapPrivilegedInstruction;
		uint32_t trapIllegalInstruction;
		uint32_t trapFpDisabled;
		uint32_t trapCpDisabled;
		uint32_t trapUnimplementedFlush;
		uint32_t trapWindowOverflow;
		uint32_t trapWindowUnderflow;
		uint32_t trapMemAddressNotAligned;
		uint32_t trapFpException;
		uint32_t trapCpException;
		uint32_t trapDataAccessError;
		uint32_t trapDataAccessException;
		uint32_t trapTagOverflow;
		uint32_t trapDivisionByZero;
		uint32_t trapTicc;
		uint32_t trapInterruptLevel;

		//Floating point, recorded in SparcCore::complete_fp_execution()
		//(Ref Appendix C.7). fpInstructionsExecuted counts every FPop1/
		//FPop2 that reached completion (trap-free up to that point).
		//The three trap counters below are mutually exclusive outcomes
		//of that same completion step, each also counted once in
		//trapFpException above (every one of the three sets
		//fp_exception=1) -- these three break trapFpException down
		//further, to its own precise cause.
		uint32_t fpInstructionsExecuted;
		uint32_t fpTrapsUnimplementedFPop;
		uint32_t fpTrapsUnfinishedFPop;
		uint32_t fpTrapsIEEE754Exception;

		//A human-readable dump, one line per counter -- see MmuStats'
		//own toString() for the precedent this follows.
		std::string toString() const;
};

#endif

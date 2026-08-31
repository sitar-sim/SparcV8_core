//SparcStateMachine.h
//
//Standalone fetch-decode-execute driver for SparcCore, zero-latency and
//functional only. Calls SparcCore's methods in the same order any
//driver would, performing memory accesses directly against whatever
//VirtualMemoryInterface it's given, with no latency of its own. What
//implements that interface, MemCore directly, an MMU, or a cache, is a
//per-configuration choice made by whoever constructs this class.
//
//Trap handling matches Appendix C exactly: every trap is dispatched via
//SparcCore::executeTraps(), with no special-casing by trap type. Per
//select_trap, the core enters error_mode and halts precisely when a
//trap occurs while traps are disabled, which falls straight out of
//SparcCore's own trap logic.
//
//SparcStateMachine has no notion of success or failure. It only tracks
//whether the core halted and how many cycles that took. Whether a given
//halt represents a passing or failing test is decided by comparing
//final register and memory state against that test's expected results.

#ifndef SPARC_STATE_MACHINE_H
#define SPARC_STATE_MACHINE_H

#include "SparcCore.h"
#include "MemoryInterfaces.h"
#include "Opcodes.h"
#include "DebugHooks.h"

class SparcStateMachine
{
	public:
		SparcStateMachine(SparcCore& core, VirtualMemoryInterface& mem);

		//Run until the core halts (enters error_mode) or maxCycles is
		//exceeded. Returns the same value as `halted` below.
		bool run(unsigned long maxCycles);

		bool          halted;          //true once the core has entered error_mode
		unsigned long cyclesExecuted;

	private:
		SparcCore& core;
		VirtualMemoryInterface& mem;

		void runOneCycle();

		//op has already been fetched and decoded; dispatch it to either the
		//explicit memory-access path (LOAD/STORE/atomic/FLUSH) or to
		//SparcCore::executeInstruction() (everything else).
		void executeCurrentInstruction(Opcode op);
};

#endif

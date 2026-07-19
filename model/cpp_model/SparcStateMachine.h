//SparcStateMachine.h
//
//Standalone fetch-decode-execute driver for SparcCore.
//
//Provides zero-latency, functional-only execution: for each instruction it
//calls SparcCore's methods (see the note above the commented-out
//SparcCore::run() in SparcCore.cpp) in the same order any driver of SparcCore
//would, but performs memory accesses directly against a MemCore with no
//modeled latency. This makes it suitable for functional (no-timing) testing
//of small assembly/machine-code programs, with no dependencies beyond plain
//C++ and this repository's cpp_common_code/ library.
//
//Trap handling matches Appendix C of the SPARC V8 manual exactly: every trap
//is dispatched via SparcCore::executeTraps() (Ref Section C.5, C.8) with no
//special-casing by trap type. Per select_trap (Section C.8), the core enters
//error_mode (halts) precisely when a trap occurs while traps are disabled
//(ET==0) -- this falls straight out of SparcCore's existing, already-correct
//trap logic, nothing SparcStateMachine-specific about it.
//
//SparcStateMachine itself has no notion of "success" or "failure" -- it only
//tracks whether the core halted (entered error_mode) and how many cycles
//that took. Test programs signal completion by halting (typically via a
//deliberate trap after installing their own trap table -- see
//validation/instruction_tests/README.md for the convention used there);
//whether a given halt represents a passing or failing test is decided by
//comparing final register/memory state against that test's expected
//results (see check_test.cpp), not by anything intrinsic to the halt itself.

#ifndef SPARC_STATE_MACHINE_H
#define SPARC_STATE_MACHINE_H

#include "SparcCore.h"
#include "MemCore.h"
#include "Opcodes.h"

class SparcStateMachine
{
	public:
		SparcStateMachine(SparcCore& core, MemCore& mem);

		//Run until the core halts (enters error_mode) or maxCycles is
		//exceeded. Returns the same value as `halted` below.
		bool run(unsigned long maxCycles);

		bool          halted;          //true once the core has entered error_mode
		unsigned long cyclesExecuted;

	private:
		SparcCore& core;
		MemCore&   mem;

		void runOneCycle();

		//op has already been fetched and decoded; dispatch it to either the
		//explicit memory-access path (LOAD/STORE/atomic/FLUSH) or to
		//SparcCore::executeInstruction() (everything else).
		void executeCurrentInstruction(Opcode op);
};

#endif

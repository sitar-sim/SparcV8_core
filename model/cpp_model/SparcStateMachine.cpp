//SparcStateMachine.cpp

#include "SparcStateMachine.h"
#include <cassert>

SparcStateMachine::SparcStateMachine(SparcCore& core_, MemCore& mem_)
	: core(core_), mem(mem_)
{
	halted         = false;
	cyclesExecuted = 0;
}

bool SparcStateMachine::run(unsigned long maxCycles)
{
	while (!halted && cyclesExecuted < maxCycles)
	{
		runOneCycle();
		cyclesExecuted++;
	}
	return halted;
}

void SparcStateMachine::runOneCycle()
{
	//-------------------------------------------------------------------
	//RESET state (Ref Section C.5, Appendix C of the SPARC V8 manual)
	//-------------------------------------------------------------------
	//RESET_pin is assumed permanently deasserted in this standalone model
	//(there is no external reset source), so the core unconditionally takes
	//a reset trap into EXECUTE state on the very first cycle.
	if (core.state == SparcCore::RESET)
	{
		core.state      = SparcCore::EXECUTE;
		core.trap       = true;
		core.reset_trap = true;
	}

	if (core.state != SparcCore::EXECUTE)
	{
		//core.state can reach ERROR either via executeTraps() below (see the
		//halted-detection there) or directly inside an execute_* function
		//(e.g. execute_RETT(), for the RETT-specific error conditions that
		//arise while ET=0 and therefore have no trap handler left to enter --
		//Ref Appendix C.24). Either way, once we're not in EXECUTE state the
		//core has halted and will never resume on its own.
		halted = true;
		return;
	}

	//-------------------------------------------------------------------
	//Check for traps raised externally, or carried over from the previous
	//instruction, before fetching the next instruction (Ref Section C.5:
	//"if (trap = 1) then execute_trap;" -- unconditional, every trap is
	//dispatched the same way; there is no special-casing by trap type).
	//-------------------------------------------------------------------
	core.checkExternalTraps();
	if (core.trap)
	{
		core.executeTraps(); //Ref Section C.8. select_trap enters
		                      //error_mode itself if traps are disabled
		                      //(ET==0); otherwise this dispatches
		                      //normally to the trap handler at the vector.

		if (core.state == SparcCore::ERROR)
		{
			halted = true;
			return;
		}
	}

	//-------------------------------------------------------------------
	//Instruction fetch (Ref Section C.5). Uses core.memCore, which must
	//have been pointed at this SparcStateMachine's MemCore instance beforehand.
	//-------------------------------------------------------------------
	core.instructionFetch();
	if (core.MAE)
	{
		core.trap                         = true;
		core.instruction_access_exception = true;
	}
	if (core.trap)
		return;

	if (core.annul)
	{
		//Previous instruction was an annulling branch not taken: skip this one.
		core.annul = false;
		core.reg.W_PC(core.reg.R_nPC());
		core.reg.W_nPC(core.reg.R_nPC() + 4);
		return;
	}

	//-------------------------------------------------------------------
	//Decode, check for instruction-related exceptions, and execute
	//(Ref Section C.6)
	//-------------------------------------------------------------------
	Opcode op = core.decoder.decode(&core.reg);
	core.checkInstructionException(op);
	if (core.trap)
		return;

	executeCurrentInstruction(op);

	if (!core.trap && (isFpop1Instruction(op) || isFpop2Instruction(op)))
		core.complete_fp_execution(op); //Ref Section C.7

	//Update PC/nPC, unless this was a branching instruction (which updates
	//PC/nPC itself) or a trap occurred (handled at the start of the next cycle).
	if (!core.trap && !isBranchInstruction(op))
	{
		core.reg.W_PC(core.reg.R_nPC());
		core.reg.W_nPC(core.reg.R_nPC() + 4);
	}
}

void SparcStateMachine::executeCurrentInstruction(Opcode op)
{
	//Memory instructions are not dispatched through SparcCore::executeInstruction()
	//-- it has no memory-access logic of its own (see the note above the
	//commented-out SparcCore::run() in SparcCore.cpp). Instead, follow SparcCore's
	//own Pre/Post split for memory ops: perform the "Pre" step (address/trap
	//computation), do the memory access directly against MemCore, then perform
	//the "Post" step.
	//
	//NOTE: branching on the specific isXInstruction() predicates below (rather
	//than the coarser isMemoryInstruction()) deliberately ensures STBAR falls
	//through to the executeInstruction() path, where it is actually handled;
	//isMemoryInstruction() classifies STBAR as a "memory instruction" too, but
	//it needs no separate memory access of its own.
	if (isLoadInstruction(op))
	{
		core.execute_PreLoad(op);
		if (!core.trap)
		{
			uint32_t alignedAddr = core.address & (~0x7u);
			uint32_t word0       = mem.readWord(alignedAddr);
			uint32_t word1       = mem.readWord(alignedAddr + 4);
			core.MAE             = false; //flat memory model: accesses never fault
			core.execute_PostLoad(op, word0, word1);
		}
	}
	else if (isStoreInstruction(op))
	{
		core.execute_PreStore(op);
		if (!core.trap)
		{
			uint32_t alignedAddr = core.address & (~0x7u);
			mem.writeMaskedDoubleWord(alignedAddr, core.writeWord0, core.writeWord1, core.byte_mask);
		}
	}
	else if (isLoadStoreAtomicInstruction(op))
	{
		core.execute_PreAtomicLoadStore(op);
		if (!core.trap)
		{
			uint32_t alignedAddr = core.address & (~0x7u);
			uint32_t word0, word1;
			mem.atomicReadModifyWrite(alignedAddr, core.writeWord0, core.writeWord1, core.byte_mask, word0, word1);
			core.MAE = false; //flat memory model: accesses never fault
			core.execute_PostAtomicLoadStore(op, word0, word1);
		}
	}
	else if (op == FLUSH)
	{
		//MemCore is a flat array with no instruction cache to invalidate, so
		//this standalone (no-timing) driver has nothing further to convey the
		//flush to -- computing the address is enough to keep decode/register
		//behavior faithful to the manual (Ref Appendix B.32).
		core.execute_PreFlush(op);
	}
	else
	{
		core.executeInstruction(op);
	}
}

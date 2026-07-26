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
	//Snapshot taken before RESET/checkExternalTraps below get a chance to
	//set core.trap fresh this cycle -- distinguishes that (reset_trap, or
	//an external interrupt just noticed: nothing has logged TRAP_RAISED
	//for either yet) from a trap carried over from last cycle (already
	//logged then, at the point it was actually raised -- see the three
	//other log_trap_raised() call sites below).
	bool trapWasAlreadyPending = core.trap;

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
		core.logger.log_generic(cyclesExecuted, "RESET", "reset_trap -> EXECUTE");
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
		if (!trapWasAlreadyPending)
		{
			//Fresh this cycle: reset_trap (set just above) or an
			//external interrupt (set by checkExternalTraps() just
			//above). Anything else reaching here was already logged
			//as TRAP_RAISED last cycle, at the point it was raised.
			core.logger.log_trap_raised(cyclesExecuted);
			debug_hook_trap_raised(core);
		}

		core.executeTraps(); //Ref Section C.8. select_trap enters
		                      //error_mode itself if traps are disabled
		                      //(ET==0); otherwise this dispatches
		                      //normally to the trap handler at the vector.

		if (core.state == SparcCore::ERROR)
		{
			core.logger.log_generic(cyclesExecuted, "HALT", "entering error_mode");
			halted = true;
			return;
		}
		core.logger.log_trap_enter(cyclesExecuted);
	}

	//-------------------------------------------------------------------
	//Instruction fetch (Ref Section C.5). Uses core.memCore, which must
	//have been pointed at this SparcStateMachine's MemCore instance beforehand.
	//-------------------------------------------------------------------
	core.instructionFetch();
	debug_hook_mem_access(core, DebugMemAccessKind::IFETCH, core.reg.R_PC(), core.reg.R_instruction(), 0);
	if (core.MAE)
	{
		core.trap                         = true;
		core.instruction_access_exception = true;
	}
	if (core.trap)
	{
		core.logger.log_trap_raised(cyclesExecuted);
		debug_hook_trap_raised(core);
		return;
	}

	if (core.annul)
	{
		//Previous instruction was an annulling branch not taken: skip this one.
		//Hook fires before PC/nPC are overwritten below -- see
		//DebugHooks.h's own comment -- so core.reg.PC/nPC here are still
		//the annulled instruction's own address and what it advances to.
		core.annul = false;
		core.logger.log_generic(cyclesExecuted, "ANNUL", "instruction annulled");
		debug_hook_annulled(core);
		core.reg.W_PC(core.reg.R_nPC());
		core.reg.W_nPC(core.reg.R_nPC() + 4);
		return;
	}

	//-------------------------------------------------------------------
	//Decode, check for instruction-related exceptions, and execute
	//(Ref Section C.6)
	//-------------------------------------------------------------------
	Opcode op = core.decoder.decode(&core.reg);
	core.logger.log_fetch(cyclesExecuted, op);

	core.checkInstructionException(op);
	if (core.trap)
	{
		core.logger.log_trap_raised(cyclesExecuted);
		debug_hook_trap_raised(core);
		return;
	}

	executeCurrentInstruction(op);
	if (core.trap)
	{
		core.logger.log_trap_raised(cyclesExecuted);
		debug_hook_trap_raised(core);
	}

	if (!core.trap && (isFpop1Instruction(op) || isFpop2Instruction(op)))
		core.complete_fp_execution(op); //Ref Section C.7

	//Instruction fully executed, PC/nPC not yet advanced -- see
	//DebugHooks.h/CoreLogger.h's file comments for why this exact point.
	core.logger.log_generic(cyclesExecuted, "EXECUTED", "");
	debug_hook_after_execute(core, op);

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
			//core.address (not alignedAddr): the instruction's own,
			//byte-precise target address -- matches SparcThread.sitar's
			//equivalent log_mem_read() call.
			core.logger.log_mem_read(cyclesExecuted, core.address, word0, word1, isDoubleLoadInstruction(op), core.MAE);
			debug_hook_mem_access(core, DebugMemAccessKind::LOAD, core.address, word0, word1);
		}
	}
	else if (isStoreInstruction(op))
	{
		core.execute_PreStore(op);
		if (!core.trap)
		{
			uint32_t alignedAddr = core.address & (~0x7u);
			mem.writeMaskedDoubleWord(alignedAddr, core.writeWord0, core.writeWord1, core.byte_mask);
			core.logger.log_mem_write(cyclesExecuted, core.address, core.writeWord0, core.writeWord1, core.byte_mask, false);
			debug_hook_mem_access(core, DebugMemAccessKind::STORE, core.address, core.writeWord0, core.writeWord1);
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
			core.logger.log_atomic(cyclesExecuted, core.address, word0, core.writeWord0, core.MAE);
			debug_hook_mem_access(core, DebugMemAccessKind::ATOMIC, core.address, word0, core.writeWord0);
		}
	}
	else if (op == FLUSH)
	{
		//MemCore is a flat array with no instruction cache to invalidate, so
		//this standalone (no-timing) driver has nothing further to convey the
		//flush to -- computing the address is enough to keep decode/register
		//behavior faithful to the manual (Ref Appendix B.32).
		core.execute_PreFlush(op);
		core.logger.log_generic(cyclesExecuted, "FLUSH", "");
		debug_hook_mem_access(core, DebugMemAccessKind::FLUSH, core.address, 0, 0);
	}
	else
	{
		core.executeInstruction(op);
	}
}

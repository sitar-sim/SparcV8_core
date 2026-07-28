//SparcCore.h
//
//author: Neha Karanjkar 
//March 2012

#ifndef SPARC_CORE_H
#define SPARC_CORE_H

#include"Registers.h"			// Models Sparc registers, and bus signals
#include"Opcodes.h"			// Enumerates instruction opcodes
#include"Decoder.h"			// Generates an opcode from a 32 bit instruction
#include"BitManipulation.h" 		// functions for bit manipulations
#include"ImplementationDependent.h" 	//All implementation dependent stuff put here
					//Eg. Number of implemented windows,
					//memory size, etc.


#include"CoreLogger.h"			//formats/emits this core's state as an architectural-event trace
#include"MemCore.h"			//Main memory model

#include<iostream>
#include<fstream>

class SparcCore
{

	public:

		//Main Functions
		void run();		//run behavior for a single clock cycle (used for functional modeling, without timing model)
		SparcCore();		//Constructor

		
		//processor ID and core ID
		//to identify a processor in a multiprocessor system
		//----------------------------------------------------------
		uint32_t processorID;
		uint32_t coreID;

		inline void	setProcessorID(unsigned int id) { processorID=id;};// reg.W_ASR(29,id); };
		uint32_t	getProcessorID(){return processorID;};
		inline void 	setCoreID(unsigned int id) { coreID=id;}; //reg.W_ASR(30,id); };
		uint32_t	getCoreID(){return coreID;};
		//----------------------------------------------------------



		//Main State Holders
		enum SparcStateType{RESET, ERROR, EXECUTE};
		SparcStateType state;
		Registers reg; 		


		//Instruction decoder
		Decoder decoder;	



		//Memory Interface related
		MemCore* memCore;	//pointer to memory, to be initialized by user

		bool instructionFetch();
			//Fetch instruction pointed by PC
			//and store it in instruction register.
			//(Uses memCore)
		//Loads and Stores go to the Cache.








//========= CORE FUNCTIONS ======================================
		
		void checkExternalTraps(); 
			//check pins for external interrupt request and
			//set trap signal if there are any traps
		void selectTrap();
			//Exmaines the state of all trap sources
			//and selects the highest priority trap to be serviced.
			//and places the vector location for this trap in tt register,
			//and resets all trap signals.
		void executeTraps(); 
			//selectTrap() and 
			//update PC, nPC to jump to the appropriate trap handler
		//__attribute__((optimize("O0"))): meant to be `call`ed live from
		//gdb (debug/sparc.gdb's sparc-print-traps) even in a --debug
		//build that otherwise keeps full -O3 -- same reasoning as
		//Registers::R_r()/CoreLogger::print_state().
		__attribute__((optimize("O0"))) std::string printTrap();
			//returns a string corresponding to the name of the trap that has occured.

		//Pure translation, not a state read: given a trap-type byte as
		//encoded in TBR's tt field (Registers::R_tt(), see selectTrap()),
		//returns the same name printTrap() would have shown for it at
		//raise time. tt is passed in explicitly and nothing here touches
		//core state, so unlike printTrap() (which depends on the
		//individual trap-cause flags selectTrap() clears once the trap
		//is serviced), this stays valid at any point afterward, e.g. from
		//CoreLogger::log_trap_enter().
		static __attribute__((optimize("O0"))) std::string trapTypeName(uint32_t tt);
		void checkInstructionException(Opcode op);
			//check for exceptions related to the fetched instruction,
			//such as fp_disabled and cp_disabled exception,
			//and illegal instructions
		void executeInstruction(Opcode op); 
			//contains code for executing each kind of instruction

		
		
		
		
		
		
		
		
		void dispatch_instruction(Opcode op);
			//calls checkInstructionException and if
			//no exception has occured, execute the instruction
		
		void complete_fp_execution(Opcode op);
		
		//Ancillary functions
		std::string printSparcState(); //return current state as a string.

		//Formats and emits this core's state as a trace of architectural
		//events -- see CoreLogger.h. Owned here (rather than by whatever
		//driver is stepping this core) so any driver gets one for free,
		//initialized and ready via this constructor, with no extra wiring.
		CoreLogger logger;




		//methods to execute subclasses of instructions
		//called by executeInstruction():
		//void execute_MemoryInstruction(Opcode op);
		//void execute_Load(Opcode op); 
		
		void execute_PreLoad(Opcode op);//calc address, addr_space and check for traps
		void execute_PostLoad(Opcode op, uint32_t readWord0, uint32_t readWord1); //store fetched word in appropriate registers
		
		//void execute_Store(Opcode op);
		void execute_PreStore(Opcode op);//calculate addr, addrspace, byte mask and words to be written
		
		void execute_PreAtomicLoadStore(Opcode op);
		void execute_PostAtomicLoadStore(Opcode op, uint32_t rWord0, uint32_t rWord1);

		void execute_PreFlush(Opcode op);//calc address (Ref Appendix B.32); no traps
				//are defined for FLUSH once implemented. The driver (SparcStateMachine.cpp /
				//SparcThread.sitar) is responsible for conveying the flush to
				//memory/cache -- SparcCore itself has no memory interface.



		void execute_SETHI(Opcode op);
		void execute_NOP(Opcode op);
		void execute_Logical(Opcode op);
		void execute_Shift(Opcode op);
		void execute_Add(Opcode op);
		void execute_Tadd(Opcode op);
		void execute_Sub(Opcode op);
		void execute_Tsub(Opcode op);
		void execute_MulStep(Opcode op);
		void execute_Mul(Opcode op); 
		void execute_Div(Opcode op);
		void execute_SaveRestore(Opcode op);
		void execute_Bicc(Opcode op);
		void execute_CALL(Opcode op);
		void execute_JMPL(Opcode op);
		void execute_RETT(Opcode op);
		void execute_Ticc(Opcode op); 
		void execute_ReadStateReg(Opcode op);
		void execute_WriteStateReg(Opcode op);
		void execute_STBAR(Opcode op);
		//floating point:
		void execute_FPop(Opcode op);
		void execute_FBfcc(Opcode op); 

		
		
		//Instructions NOT IMPLEMENTED
		//Cause an unimplemented instruction TRAP:
		void execute_CBccc(Opcode op){execute_UNIMP(op);};
		void execute_UNIMP(Opcode op){trap=1; illegal_instruction=1;};
		void execute_CPop(Opcode op){execute_UNIMP(op);};



		//small helper functions:
		void misaligned_fp_reg_trap();




		//Internal signals and flags
		//
		//
		//Signals used by ALL instructions
		bool 		trap;		//1 bit
		
		//Signals used by memory instructions
		bool		MAE;		//1 bit
		bool		annul;		//1 bit
		uint32_t 	address;	//32 bit
		uint32_t 	addr_space;	//8 bit
		uint32_t 	readWord0;	//32bit
		uint32_t 	readWord1;	//32bit
		uint32_t 	writeWord0;	//32bit
		uint32_t 	writeWord1;	//32bit
		uint32_t 	byte_mask; 	//8 bit

		
		
		uint32_t 	interrupt_level;//4bit
		uint32_t	ticc_trap_type; //7bit

		//Traps
		bool 		reset_trap;     
		bool 		instruction_access_exception;	
		bool		illegal_instruction; 
		bool		illegal_IU_instr; 
		bool		fp_disabled;
		bool		cp_disabled;
		bool		mem_address_not_aligned;
		bool		privileged_instruction;
		bool		fp_exception;
		bool		cp_exception;
		bool		data_access_exception;
		bool		window_overflow;
		bool		window_underflow;
		bool		trap_instruction;
		bool 		data_store_error;
		bool 		instruction_access_error;
		bool 		r_register_access_error;
		bool 		unimplemented_FLUSH;
		bool 		data_access_error;
		bool 		tag_overflow;	
		bool 		division_by_zero;


		//Some flags
		bool 		an_FPU_sequence_error_is_detected;
		bool 		a_CP_sequence_error_is_detected;
		bool 		implementation_has_no_floating_point_queue;
		bool 		implementation_has_no_coprocessor_queue;
		bool 		store_barrier_pending;


};

#endif

//SparcCore.cpp

#include"SparcCore.h"
#include"BitManipulation.h"
#include"ConvertToString.h"
#include"FloatingPointFunctions.h"
#include"MemCore.h"
#include"DebugRegistry.h"
#include<iostream>
#include<stdint.h>
#include<fstream>
#include<cstdlib>
#include<sstream>



//Constructor
SparcCore::SparcCore()	
{

	//Initialize internal signals
	state = RESET;
	trap=0;		

	//set processor and core ID to 0 by default
	processorID = 0;
	coreID = 0;

	reg.W_ASR(31,0);
	reg.W_ASR(30,0);

	//memory access related
	memCore=NULL;
	MAE=0;		
	annul=0;	
	address=0;	
	addr_space=0;	
	readWord0=0;
	readWord1=0;
	writeWord0=0;
	writeWord1=0;
	byte_mask=0;

	//traps-related
	interrupt_level=0;
	reset_trap=0;   
	instruction_access_exception=0;	
	illegal_instruction=0; 
	illegal_IU_instr=0; 
	fp_disabled=0;
	cp_disabled=0;
	mem_address_not_aligned=0;
	privileged_instruction=0;
	fp_exception=0;
	cp_exception=0;
	data_access_exception=0;
	window_overflow=0;
	window_underflow=0;
	trap_instruction=0;
	data_store_error=0;
	instruction_access_error=0;
	r_register_access_error=0;
	unimplemented_FLUSH=0;
	data_access_error=0;
	tag_overflow=0;	
	division_by_zero=0;

	ticc_trap_type=0;
	an_FPU_sequence_error_is_detected=0;
	a_CP_sequence_error_is_detected=0;
	implementation_has_no_floating_point_queue=1;
	implementation_has_no_coprocessor_queue=1;

	logger.init(*this); //do_print stays off, no ostream attached, until a
	                     //driver that wants a written trace calls this
	                     //again itself (see main.cpp) -- this call just
	                     //guarantees logger.print_state() always works.

	DebugRegistry::registerCore(this); //see DebugRegistry.h -- no-op
	                                    //unless built with --debug
};







//===================================================================================
// SparcCore::run() -- NOT USED, kept below (commented out) for historical reference
//===================================================================================
// This was the original prototype top-level fetch-decode-execute loop, written
// before memory-access latency modeling was introduced. Its dispatch for memory
// instructions (LOAD/STORE/atomic load-store) was never completed -- see the
// commented-out isMemoryInstruction() branch inside executeInstruction() below --
// so, as written, this function hits assert(0) on the first LOAD/STORE/atomic
// instruction it encounters.
//
// The top-level fetch-decode-execute sequencing now lives in driver code outside
// this file (e.g. model/cpp_model/SparcStateMachine.cpp, for zero-latency
// functional testing). Such drivers call SparcCore's methods (instructionFetch,
// decoder.decode, checkInstructionException, dispatch_instruction/executeInstruction,
// execute_Pre/PostLoad, execute_Pre/PostStore, execute_Pre/PostAtomicLoadStore,
// checkExternalTraps/executeTraps) in the same order that this function did, but
// perform memory accesses in whatever way suits their own timing model (e.g.
// zero-latency direct access, or a latency-modeling memory/cache interface)
// instead of this function's single-cycle assumption.
//===================================================================================
/*
void SparcCore::run()
{

	//Sparc State machine(Ref Section C.5 in Appendix C of Sparc manual)
	switch(state)
	{
		case RESET :
			{
				//if reset input is deasserted goto 
				//execute mode (start executing a reset-trap),
				//else stay in reset mode
				if(reg.R_bp_reset_in()==0) 
				{
					state=EXECUTE; 
					trap=1;
					reset_trap=1;
				} 
				else break;
			};
		case EXECUTE :
			{
				//check if reset is asserted
				if(reg.R_bp_reset_in()==1) 
				{
					state=RESET;
					break; 
				}


				//Check for external traps(on the processor pins)
				//if traps are enabled and unmasked traps
				//have occured, set trap=1
				checkExternalTraps();



				//Either the checking of processor pins in this
				//cycle, or execution of the previous
				//instruction might have caused a trap.
				//if so, execute traps.
				if(trap==1) 
					executeTraps();

				//executeTraps() may have changed the mode from
				//execute mode to reset or error mode
				if(state!=EXECUTE) break;



				//Emulated the delayed nature of
				//write-state-register instructions:
				//
				//
				//In this implementation, I have assumed 
				//that write to Special registers takes place instantaneously.
				//so delay is not implemented.



				//Now fetch the next instruction 
				instructionFetch();

				//instructionFetch reads the values of
				//reg.PC (program counter) and generates
				//an addr_space by checking if its a supervisor
				//mode(addr_space=8) or user-mode(addr_space=9)
				//and stores the fetched instruction from
				//location(addr_space,address) into
				//reg.instruction and modifies bit MAE
				//to indicate memory access exception(if any)

				if(trap==0) //no instruction access exception
				{
					//annul flag could have been set by 
					//the previous instruction if it 
					//was an annuling branch. If so,
					//do not execute the current
					//instruction.

					if (annul == 0) 
					{
						Opcode op;
						op=decoder.decode(&reg); //decode the instruction
						dispatch_instruction(op); 
						//check for exceptions,
						//and execute
						//instruction.
						//{see section C.6 in manual}
						
						if(trap==0 and (isFpop1Instruction(op) or isFpop2Instruction(op)))
						{
							//complete Floating point residual oprations
							complete_fp_execution(op);
							// { See Section C.7 in manual}
						}
						//find PC and nPC if this is not
						//a branching instruction
						if( (trap == 0) && (op!=CALL 
									&& op!=RETT 
									&& op!=JMPL
									&& (!(op>=BA && op<=BVS))
									&& (!isFBfccInstruction(op)) 
									&& op!=CBccc 
									&& (!(op>=TA && op<=TVS)) ) )
						{
							reg.W_PC(reg.R_nPC()); //PC=nPC
							reg.W_nPC(reg.R_nPC()+4); //nPC=nPC+4;
						};
						//If annul=0 and this was a
						//branch, PC and nPC are set
						//appropriately in the code for
						//each instruction execution

					}
					else //{ annul != 0 } 
					{
						//The previous instruction was an
						//annuling branch. So do not execute
						//the current instruction
						//just proceed to the next
						//instruction
						annul=0;
						reg.W_PC(reg.R_nPC()); //PC=nPC
						reg.W_nPC(reg.R_nPC()+4); //nPC=nPC+4;
					};
				}; ////no instruction access exception



				//if no error occured, stay in execute mode,
				//else goto error mode
				if(state!=ERROR) break;
			};
		case ERROR :
			{
				//stay in error mode until reset
				if(reg.R_bp_reset_in()!=1) break;
				else
				{
					state=RESET;
					reg.W_pb_error(0);
					break;
				};

			};
	};
};
*/








//Instruction fetch
bool SparcCore::instructionFetch() 
{
	//read instruction from the address formed by
	//PC,addr_space and store the fetched instruction in 
	//reg.instruction. Set bit MAE if there was a memory access
	//exception
	using namespace std;


	uint32_t addr;
	uint32_t instruction;

	uint32_t addr_space;
	if(reg.R_S() ==0)
		addr_space=8; //user-mode
	else
		addr_space=9; //supervisor-mode



	addr = reg.R_PC();
	assert(memCore!=NULL);
	instruction= memCore->readWord(addr);
	MAE=0;

	//check for instruction access exception
	if(  (MAE == 1) && (annul == 0) ) 
	{
		trap=1;
		instruction_access_exception=1;
	}

	//if memory read succeeded
	reg.W_instruction(instruction);
	return true; 
};




std::string SparcCore::printSparcState()
{
	switch(state)
	{
		case RESET : return "RESET";
		case EXECUTE :return "EXECUTE";
		case ERROR :return "ERROR";
		default : return "UNDEFINED STATE!";
	};
};









void SparcCore::checkInstructionException(Opcode op)
{
	//(Section C.6 in manual)
	//Instruction Dispatch : The dispatch_instruction macro
	//determines if the instruction is an FPop or CPop and generates an
	//fp_disabled or cp_disabled trap if appropriate.
	//Otherwise, the instruction is executed .
	//Unused bit patterns in the op, op2, op3, opf, and
	//i fields of instructions cause illegal_instruction traps. Other
	//fields that are defined to be unused are ignored and do not
	//cause traps.


	if ( ( (reg.R_op() == 0) and (reg.R_op2() == 0) ) //{UNIMP instruction }
			or
			( ((reg.R_op()==3) or (reg.R_op()==2)) and (op== unassigned) )
	   ) 
		illegal_IU_instr=1;
	else
		illegal_IU_instr=0;

	//check for illegal instruction exception
	if(illegal_IU_instr==1) 
	{
		trap=1;
		illegal_instruction=1;
	};



	//check for floating point unit or coprocessor absent exception
	if(isFloatingPointInstruction(op) and ((reg.R_EF() == 0) or (reg.R_bp_FPU_present() == 0))) 
	{
		trap = 1;
		fp_disabled = 1;
	};
	if( (op==CPop1 or op==CPop2 or op==CBccc) and ((reg.R_EC() == 0) or (reg.R_bp_CP_present() == 0)))
	{
		trap = 1;
		cp_disabled = 1;
	};
};







void SparcCore::dispatch_instruction(Opcode op)
{
	//Check for Instruction-related exceptions
	checkInstructionException(op);


	//Finally..... some action
	//Execute the instruction if no traps have occured so far.
	if(trap==0)
		executeInstruction(op);
	};













void SparcCore::executeInstruction(Opcode op)
{

	//Find the type of instruction and execute it	
	//if (isMemoryInstruction(op))		execute_MemoryInstruction(op);	
	if(op==SETHI)	 			execute_SETHI(op);
	else if(op==NOP)	 		execute_NOP(op);
	else if(op>=AND and op<=XNORcc) 	execute_Logical(op);
	else if(op>=SLL and op<=SRA)	 	execute_Shift(op);
	else if(op>=ADD and op<=ADDXcc) 	execute_Add(op);
	else if(op>=TADDcc and op<=TADDccTV) 	execute_Tadd(op);
	else if(op>=SUB and op<=SUBXcc) 	execute_Sub(op);
	else if(op>=TSUBcc and op<=TSUBccTV) 	execute_Tsub(op);
	else if(op==MULScc)	 		execute_MulStep(op);
	else if(op>=UMUL and op<=SMULcc) 	execute_Mul(op);
	else if(op>=UDIV and op<=SDIVcc) 	execute_Div(op);
	else if(op>=SAVE and op<=RESTORE) 	execute_SaveRestore(op);
	else if(op>=BA and op<=BVS)		execute_Bicc(op);
	else if(op>=FBA and op<=FBO)		execute_FBfcc(op);
	else if(op==CBccc)			execute_CBccc(op);
	else if(op==CALL)			execute_CALL(op);
	else if(op==JMPL)			execute_JMPL(op);
	else if(op==RETT)			execute_RETT(op);
	else if(op>=TA and op<=TVS)		execute_Ticc(op);
	else if(op>=RDY and op<=RDTBR)		execute_ReadStateReg(op);
	else if(op>=WRY and op<=WRTBR)	 	execute_WriteStateReg(op);
	else if(op==STBAR)			execute_STBAR(op);
	else if(op==UNIMP)			execute_UNIMP(op);
	else if(isFpop1Instruction(op) or isFpop2Instruction(op) )	execute_FPop(op);			
	else if(op==CPop1 or op==CPop2)		execute_CPop(op);
	else {assert(0);} //Unimplemented instruction
};



//Load Instructions ===================================


void SparcCore::execute_PreLoad(Opcode op)
{
	//Calculate address, addr_space, and check for traps	
	//as per Opcode. Called before performing a memory Read
	uint32_t operand1;
	uint32_t operand2;


	operand1= reg.R_r(reg.R_rs1());
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);


	//find out address and addr_space fields
	if(op>=LDSBA && op<=LDDA) //All Alternate-Space operations
	{
		if(reg.R_S() == 0)
		{ 
			trap = 1;
			privileged_instruction = 1;
		}
		else if(reg.R_i() == 1) 
		{ 
			trap = 1;
			illegal_instruction = 1;
		}
		else 
		{
			address = operand1 + reg.R_r(reg.R_rs2());
			addr_space = reg.R_asi();
		}

	}
	else //Not alternate Space
	{	address =operand1 + operand2;
		if(reg.R_S()==0)
			addr_space = 10;
		else
			addr_space =11;

	};



	if (trap == 0) //Check various kinds of traps 
	{
		//check for Floating-point unit related traps
		if ( (op>=LDF && op<=LDFSR) and ((reg.R_EF() == 0) or (reg.R_bp_FPU_present() == 0)))
		{
			trap = 1;
			fp_disabled = 1;
		}
		//check for coprocessor-related traps
		else if ( (op>=LDC && op<=LDCSR) and ((reg.R_EC() == 0) or (reg.R_bp_CP_present() == 0)))
		{
			trap = 1; 
			cp_disabled = 1;
		}
		//check for misaligned memory reference traps
		else if ( ( (op==LDD or op==LDDA or op==LDDF or op==LDDC) and (readBits(address,2,0) !=0)) 
				or ((op==LD or op==LDA or op==LDF or op==LDFSR or op==LDC or op==LDCSR) and (readBits(address,1,0)!= 0)) 
				or ((op==LDSH or op==LDSHA or op==LDUH or op==LDUHA) and (readBits(address,0,0)!=0) ) 
			)
		{
			trap = 1;
			mem_address_not_aligned = 1;
		}
		//check for other FPU and CP related traps
		else if (op==LDDF and (readBits(reg.R_rd(),0,0) != 0)) 
		{
			trap = 1; 
			fp_exception = 1; 
			reg.W_ftt(reg.invalid_fp_register);
		}
		else if ((op==LDF or op==LDDF or op==LDFSR) and (an_FPU_sequence_error_is_detected))
		{
			trap = 1;
			fp_exception = 1;
			reg.W_ftt(reg.sequence_error);
		}
		else if ((op>=LDC && op<=LDCSR) and (a_CP_sequence_error_is_detected))
		{
			trap = 1; 
			cp_exception = 1; 
			// possibly additional implementation-dependent actions 
		};
	};
};


void SparcCore::execute_PostLoad(Opcode op, uint32_t readWord0, uint32_t readWord1)
{

	//check for memory access related traps,
	//and if no traps have occured, store the 
	//fetched word/halfword/byte  into the 
	//destination register

	uint32_t byte =0;
	uint32_t halfword=0;
	uint32_t word=0;


	if (MAE == 1) 
	{
		trap = 1; 
		data_access_exception = 1;
	}
	else //MAE!=1
	{
		//======================================
		//Check for Double word operations
		//======================================

		if(op==LDD or op==LDDA or op==LDDF or op==LDDC) //Doubleword operations
		{
			switch(op)
			{
				case LDD :
				case LDDA :
					{
						reg.W_r( (reg.R_rd()&0x1E), readWord0);
						reg.W_r( (reg.R_rd()|0x01), readWord1);
						break;
					}
				case LDDF :
					{
						reg.W_f( (reg.R_rd() &0x1E), readWord0);
						reg.W_f( (reg.R_rd() |0x01), readWord1);
						break;
					}
				case LDDC :
					{
						//implementation dependent actions
						std::cerr<<"\nLDDC instruction not implemented";
						assert(0);
						break;
					}
				default :
					{
						assert(0);
					}

			};
		}
		else
		{
			//========================================
			//not double word ops.
			//select the appropriate word
			//========================================
			if(readBits(address, 2,2)==0)
				word = readWord0;
			else
				word = readWord1;

			if(op==LDSB or op==LDSBA or op==LDUB or op==LDUBA)//Byte operations 
			{
				uint32_t a =readBits(address,1,0);
				switch(a)
				{
					case 0: { byte = readBits(word,31,24);break;}
					case 1: { byte = readBits(word,23,16);break;}
					case 2: { byte = readBits(word,15,8 );break;}
					case 3: { byte = readBits(word,7,0  );break;}
					default:{ assert(0);}
				};
				if(op==LDSB or op==LDSBA) 
					word = sign_extend_byte(byte);
				else 
					word = zero_extend_byte(byte);
			}
			else if(op==LDSH or op==LDSHA or op==LDUH or op==LDUHA) //Halfword operations
			{

				uint32_t a =readBits(address,1,0);
				switch(a)
				{
					case 0: { halfword = readBits(word,31,16);break;}
					case 2: { halfword = readBits(word,15,0 );break;}
					default:{ assert(0);}

				};
				if (op==LDSH or op==LDSHA) 
					word = sign_extend_halfword(halfword);
				else
					word = zero_extend_halfword(halfword);
			}
			else //Word operations
				word = word;



			//Write the data loaded from memory into the destination register
			if (trap == 0) 
			{
				switch(op)
				{
					case LD  : 
					case LDA  : 
					case LDSH  : 
					case LDSHA  : 
					case LDUHA  : 
					case LDUH  : 
					case LDSB  : 
					case LDSBA  : 
					case LDUB  : 
					case LDUBA :
						{
							reg.W_r(reg.R_rd(), word); break;
						}

					case LDF :
						{
							reg.W_f(reg.R_rd(),word); break;
						}
					case LDC :
						{
							// implementation-dependent actions;
							assert("LDC instruction not implemented");
							break;
						}
					case LDFSR :
						{
							reg.W_FSR(word);
							break;
						}
					case LDCSR :
						{
							reg.W_CSR(word);
							break;
						}
					default:
						{
							assert(0);
							break;
						}
				};
			};
		};
	};


};








//Store Instructions ===================================



void SparcCore::execute_PreStore(Opcode op)
{
	//Calculate address, addr_space,
	//the word to be written and the byte mask,
	//Check for exceptions

	uint32_t operand1;
	uint32_t operand2;
	uint32_t data0=0;
	uint32_t data1=0;


	uint32_t implementation_dependent_value=0;


	operand1= reg.R_r(reg.R_rs1());
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);

	//check for priviledged and illegal instruction traps
	if((reg.R_S()== 0) and ( (op>=STBA and op<=STDA) or op==STDFQ or op==STDCQ) ) 
	{
		trap = 1;
		privileged_instruction = 1;
	}
	else if ((reg.R_i() == 1) and (op>=STBA and op<=STDA)) 
	{
		trap = 1;
		illegal_instruction = 1 ;
	}

	//calculate address and addr_space fields
	if (trap == 0)
	{

		if(op>=STBA and op<=STDA) //alternate
		{
			address=reg.R_r(reg.R_rs1()) + reg.R_r(reg.R_rs2());
			addr_space=reg.R_asi();
		}
		else //not alternate space
		{
			address =operand1 + operand2;
			if(reg.R_S()==0)
				addr_space = 10;
			else
				addr_space =11;
		};

		//check for Floating-point unit related traps
		if ( (op>=STF && op<=STDFQ) and ((reg.R_EF() == 0) or (reg.R_bp_FPU_present() == 0)))
		{
			trap = 1;
			fp_disabled = 1;
		}
		//check for coprocessor-related traps
		else if ( (op>=STC && op<=STDCQ) and ((reg.R_EC() == 0) or (reg.R_bp_CP_present() == 0)))
		{
			trap = 1; 
			cp_disabled = 1;
		};
	};


	if(trap==0)
	{

		//check for misaligned memory reference traps
		if ( ( (op==STD or op==STDA or op==STDF or op==STDFQ or op==STDC or op== STDCQ) and (readBits(address,2,0) !=0)) 
				or ((op==ST or op==STA or op==STF or op==STFSR or op==STC or op==STCSR) and (readBits(address,1,0)!= 0)) 
				or ((op==STH or op==STHA) and (readBits(address,0,0)!=0) ) 
		   )
		{
			trap = 1;
			mem_address_not_aligned = 1;
		}
		else
		{
			if (op==STDFQ and ((implementation_has_no_floating_point_queue) or (reg.R_qne()==0))) 
			{
				trap = 1; fp_exception = 1; reg.W_ftt(reg.sequence_error);
			};
			if (op==STDCQ and (implementation_has_no_coprocessor_queue))
			{
				trap = 1; cp_exception = 1; 
				//possibly additional implementation-dependent actions 
			};
			if (op==STDF and (readBits(reg.R_rd(),0,0) != 0)) 
			{
				trap = 1; 
				fp_exception = 1; 
				reg.W_ftt(reg.invalid_fp_register);
			};
		};
	};


	//find out data0, data1 and byte_mask fields for memory_write operation
	if(trap==0)
	{

		//First, find data 0 and byte_mask

		switch(op)
		{
			case STF   : {  byte_mask = 0x0F; data0 = reg.R_f(reg.R_rd()); break; } 
			case STC   : {  byte_mask = 0x0F; data0 = implementation_dependent_value; assert(0); break; } 
			case STDF  : {  byte_mask = 0x0F; data0 = reg.R_f((reg.R_rd() & 0x1E)); break; } 
			case STDC  : {  byte_mask = 0x0F; data0 = implementation_dependent_value; assert(0); break; } 

			case STD   :
			case STDA  : {  byte_mask = 0x0F; data0 = reg.R_r((reg.R_rd() & 0x1E)); break; } 
			case STDFQ : {  byte_mask = 0x0F; data0 = implementation_dependent_value; assert(0); break; } 
			case STDCQ : {  byte_mask = 0x0F; data0 = implementation_dependent_value; assert(0); break; } 
			case STFSR : {
					     //while ((FSR.qne = 1) and (trap = 0)) 
					     //{
					     //  wait for pending floating-point instructions to complete 
					     //}
					     byte_mask = 0x0F; data0 = reg.R_FSR();
					     break;
				     }
			case STCSR : { 
					     // implementation-dependent actions 
					     // byte_mask = 11112; data0 = CS
					     assert(0);// coprocessor not implemented
					     break; 
				     }
			case ST    :
			case STA   : {  byte_mask = 0x0F; data0 = reg.R_r(reg.R_rd()); break; } 

			case STH   :
			case STHA  : {
					     if(readBits(address,1,0) == 0) 
					     {

						     byte_mask = 0x0C; //mask=1100 
						     data0 = ((reg.R_r(reg.R_rd())<<16)); 
					     }
					     else if (readBits(address,1,0) == 2)
					     {
						     byte_mask = 0x03; //mask =0011
						     data0 = (reg.R_r(reg.R_rd()));
					     };
					     break;
				     } 

			case STB   :
			case STBA  :  {
					      uint32_t a = readBits(address, 1,0);
					      uint32_t d = reg.R_r(reg.R_rd());
					      switch(a)
					      {
						      case 0 : { byte_mask = 0x08; data0 = (d<<24); break;}
						      case 1 : { byte_mask = 0x04; data0 = (d<<16); break;}
						      case 2 : { byte_mask = 0x02; data0 = (d<<8 ); break;}
						      case 3 : { byte_mask = 0x01; data0 = d;       break;}

					      };
					      break;
				      };
			default : {assert(0);};
		};

		//Now, if it is a double-word operation, find data1 (byte_mask will be 0xFF in this case)
		if(isDoubleStoreInstruction(op))
		{
			switch(op)
			{
				case STD :
				case STDA :
					{
						data1 = reg.R_r(reg.R_rd() | 0x1); break;
					}
				case STDF :
					{
						data1 = reg.R_f(reg.R_rd() | 0x1); break;
					}
				case STDC :
					{
						data1 = implementation_dependent_value;
						assert(0);
						break;
					}
				case STDFQ :
					{
						data1 = implementation_dependent_value ;
						assert(0);
						break;
					}
				case STDCQ :
					{
						data1 = implementation_dependent_value ;
						assert(0);
						break;
					}
				default : {break;}
			};
		};

		//fields for writing to memory are :
		//	writeWord0 writeWord1 byte_mask   
		//	lower nibble of byte_mask is for word0, upper nibble for word 1
		//	Each bit of the nibble indicates if the corresponding byte of the word is to be 
		//      written or not


		if(isDoubleStoreInstruction(op))
		{
			writeWord0=data0;
			writeWord1=data1;
			assert(address%8==0);
			byte_mask=0xFF;
		}
		else
		{
			address=address&(~0x3);	//clear last 2 bits of address. Make address word-aligned

			if(address%8==0)	//write only within even word
			{
				writeWord0=data0;
			}
			else	//write only within odd word
			{
				writeWord1=data0;
				byte_mask=byte_mask<<4;
				address=address&(~(4)); //make the address point to an even-word
			};
		};

	};
	return;
};



//Logical instructions
void SparcCore::execute_Logical(Opcode op)
{
	//Logical Instructions 
	uint32_t operand2;
	uint32_t operand1;
	uint32_t result=0;

	//find operand2
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);

	operand1= reg.R_r(reg.R_rs1());


	//find result
	switch(op)
	{


		case AND:
		case ANDcc:
			{ result = operand1 & operand2; break;}
		case ANDN:
		case ANDNcc:
			{ result = operand1 & (~operand2); break;}
		case OR:
		case ORcc:
			{ result = operand1 | operand2; break;}
		case ORN:
		case ORNcc:
			{ result = operand1 | (~operand2); break;}
		case XOR:
		case XORcc:
			{ result = operand1 ^ operand2; break;}
		case XNOR:
		case XNORcc:
			{ result = operand1 ^ (~operand2); break;}
		default:{assert(0);};

	};

	//store the result and set flags
	reg.W_r(reg.R_rd(), result);
	switch(op)
	{
		case ANDcc :
		case ANDNcc :
		case ORcc :
		case ORNcc :
		case XORcc :
		case XNORcc:
			{
				reg.W_N( readBits(result,31,31));
				reg.W_Z( result == 0);
				reg.W_V( 0);
				reg.W_C( 0);
				break;
			};
		default:
			break;
	};
};




//SETHI instruction
void SparcCore::execute_SETHI(Opcode op)
{
	if(reg.R_rd()!=0)
	{
		reg.W_r(reg.R_rd(), (reg.R_imm22()<<10));
	};
};

//NOP instruction
void SparcCore::execute_NOP(Opcode op)
{
	//do nothing;

};




//Shift Instructions
void SparcCore::execute_Shift(Opcode op)
{
	uint32_t shift_count;
	uint32_t result=0;
	uint32_t operand1;
	uint32_t operand2;

	operand1= reg.R_r(reg.R_rs1());
	operand2= reg.R_r(reg.R_rs2());
	if(reg.R_i() == 0) 
		shift_count=readBits(operand2,4,0); //count specified in register r[rs2]
	else 
		shift_count=reg.R_rs2(); //count specified as immediate value in rs2 field in instruction
	shift_count=shift_count%32;
	if(shift_count==0) result = operand1;
	else
	{


		switch(op)
		{
			case SLL :{result= operand1<<shift_count; break;}
			case SRL :{result= operand1>>shift_count; break;}
			case SRA :{
					  //read the MSB
					  uint32_t sign = readBits(operand1,31,31);
					  result= operand1>>shift_count;
					  if(sign==0)
						  writeBits(result,31,(31-shift_count+1),0);
					  else
						  writeBits(result,31,(31-shift_count+1),0xffffffff);
					  break;
				  };
			default :assert(0);
		};
	};


	//store the result. No flags modified
	reg.W_r(reg.R_rd(), result);
};



//Add Instructions
void SparcCore::execute_Add(Opcode op)
{
	//Logical Instructions 
	uint32_t operand2;
	uint32_t operand1;
	uint32_t result=0;
	uint32_t C;



	//find operand2
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);

	operand1= reg.R_r(reg.R_rs1());
	C=reg.R_C();



	//find result
	switch(op)
	{


		case ADD:
		case ADDcc:
			{ result = operand1 + operand2; break;}
		case ADDX:
		case ADDXcc:
			{ result = operand1 + operand2 + C; break;}

		default:{assert(0);};

	};

	//store the result and set flags
	reg.W_r(reg.R_rd(), result);
	uint32_t a = readBits(operand1,31,31);
	uint32_t b = readBits(operand2,31,31);
	uint32_t c = readBits(result,31,31);
	switch(op)
	{
		case ADDcc :
		case ADDXcc :
			{
				reg.W_N( c);
				reg.W_Z( result == 0);
				reg.W_V( ( a && b && (! c)) || ( (!a) && (!b) && c) );
				reg.W_C( ( a && b ) || ( (!c) && ( a || b)) );
				break;
			};
		default:
			break;
	};
};


//Tadd Instructions - Tagged add
void SparcCore::execute_Tadd(Opcode op)
{
	//Logical Instructions 
	uint32_t operand2;
	uint32_t operand1;
	uint32_t result=0;
	uint32_t temp_V; //temp var



	//find operand2 and operand1
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);

	operand1= reg.R_r(reg.R_rs1());

	//get result
	result = operand1 + operand2;

	bool a = readBits(operand1,31,31);
	bool b = readBits(operand2,31,31);
	bool c = readBits(result  ,31,31);
	uint32_t d = readBits(operand1  ,1,0);
	uint32_t e = readBits(operand2  ,1,0);

	temp_V = ((a and b and (not c)) or ((not a) and (not b) and c) or ( (d!=0) or (e!=0)));

	if (op==TADDccTV and (temp_V == 1)) 
	{
		trap = 1; 
		tag_overflow = 1;
	}
	else 
	{
		reg.W_N(c);
		reg.W_Z(result == 0) ;
		reg.W_V(temp_V); 
		reg.W_C((a and b) or ((not c) and (a or b)));
		//write the result
		reg.W_r(reg.R_rd(), result);
	};
};



//Subtract Instructions
void SparcCore::execute_Sub(Opcode op)
{
	//Logical Instructions 
	uint32_t operand2;
	uint32_t operand1;
	uint32_t result=0;
	uint32_t C;



	//find operand2
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);

	operand1= reg.R_r(reg.R_rs1());
	C=reg.R_C();



	//find result
	switch(op)
	{


		case SUB:
		case SUBcc:
			{ result = operand1 - operand2; break;}
		case SUBX:
		case SUBXcc:
			{ result = operand1 - operand2 - C; break;}

		default:{assert(0);};

	};

	//store the result and set flags
	reg.W_r(reg.R_rd(), result);
	bool a = readBits(operand1,31,31);
	bool b = readBits(operand2,31,31);
	bool c = readBits(result  ,31,31);
	if(op==SUBcc or op==SUBXcc)
	{
		reg.W_N(c);
		reg.W_Z(result==0);
		reg.W_V((a and !b and !c) or ( !a and b and c));
		reg.W_C( (!a and b) or (c and(!a or b)) );
	};
};




//Tsub Instructions - Tagged subtract
void SparcCore::execute_Tsub(Opcode op)
{
	//Logical Instructions 
	uint32_t operand2;
	uint32_t operand1;
	uint32_t result=0;
	uint32_t temp_V; //temp var



	//find operand2 and operand1
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);

	operand1= reg.R_r(reg.R_rs1());

	//get result
	result = operand1 - operand2;

	bool a = readBits(operand1,31,31);
	bool b = readBits(operand2,31,31);
	bool c = readBits(result  ,31,31);
	uint32_t d = readBits(operand1  ,1,0);
	uint32_t e = readBits(operand2  ,1,0);

	temp_V = ((a and !b and !c) or (!a and b and c) or ((d!=0) or (e!=0) ));

	if (op==TSUBccTV and (temp_V == 1)) 
	{
		trap = 1; 
		tag_overflow = 1;
	}
	else 
	{
		reg.W_N(c);
		reg.W_Z(result == 0) ;
		reg.W_V(temp_V); 
		reg.W_C((!a and b) or (c and (!a or b)));
		//write the result
		reg.W_r(reg.R_rd(), result);
	};
};


//Bicc : Branch on Integer Condition Codes
void SparcCore::execute_Bicc(Opcode op)
{
	bool eval_icc=0; //whether the branch is to be taken or not
	uint32_t Z = reg.R_Z();
	uint32_t N = reg.R_N();
	uint32_t V = reg.R_V();
	uint32_t C = reg.R_C();

	switch(op)
	{
		case BNE 	:{eval_icc=  (Z == 0); 			break;}
		case BE 	:{eval_icc=  (Z == 1); 			break;} 
		case BG 	:{eval_icc=  ((Z or (N xor V)) == 0); 	break;} 
		case BLE 	:{eval_icc=  ((Z or (N xor V)) == 1);	break;}
		case BGE 	:{eval_icc=  ((N xor V) == 0);      	break;}
		case BL 	:{eval_icc=  ((N xor V) == 1);		break;}
		case BGU 	:{eval_icc=  ((C == 0) and (Z == 0));	break;}
		case BLEU	:{eval_icc=  ((C == 1) or (Z == 1));	break;}
		case BCC 	:{eval_icc=  (C == 0) ;			break;}
		case BCS 	:{eval_icc=  (C == 1) ;			break;}
		case BPOS	:{eval_icc=  (N == 0) ;			break;}
		case BNEG	:{eval_icc=  (N == 1) ;			break;}
		case BVC 	:{eval_icc=  (V == 0) ;			break;}
		case BVS 	:{eval_icc=  (V == 1) ;			break;}
		case BA 	:{eval_icc=1;				break;}
		case BN 	:{eval_icc=0;                          break;}
		default		:{assert(0); break;}
	};
	uint32_t pc=0;
	uint32_t npc=0;
	pc=reg.R_PC();
	npc=reg.R_nPC();


	reg.W_PC(npc); //PC=nPC
	if(eval_icc==1)
	{
		//take the branch
		reg.W_nPC( pc + sign_extend(reg.R_disp22()<<2, 23));
		if ((op==BA) and (reg.R_a() == 1))
		{
			annul=1; //only for annulling Branch-always
		};
	}
	else //do not take the branch
	{
		reg.W_nPC( npc + 4);
		if (reg.R_a() == 1) 
		{
			annul = 1; // only for annulling branches other than BA
		};
	};
};

//CALL
void SparcCore::execute_CALL(Opcode op)
{
	uint32_t pc=0;
	uint32_t npc=0;
	pc=reg.R_PC();
	npc=reg.R_nPC();

	reg.W_r(15,pc);
	reg.W_PC(npc);
	reg.W_nPC(pc + (reg.R_disp30()<<2) );
};

//Jump and link
void SparcCore::execute_JMPL(Opcode op)
{
	uint32_t operand2;
	uint32_t operand1;
	uint32_t jump_address;

	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);

	operand1= reg.R_r(reg.R_rs1());
	jump_address=operand1 + operand2;
	if(readBits(jump_address,1,0)!=0)
	{
		trap=1;
		mem_address_not_aligned=1;
	}
	else
	{
		//r[rd]=PC
		uint32_t pc=0;
		uint32_t npc=0;
		pc=reg.R_PC();
		npc=reg.R_nPC();


		reg.W_r(reg.R_rd(), pc);
		reg.W_PC(npc);
		reg.W_nPC(jump_address);
	}
};









void SparcCore::execute_MulStep(Opcode op)
{
	//Multiply Step Instruction 

	//operand 1
	uint32_t operand1;
	operand1= reg.R_r(reg.R_rs1());
	operand1= readBits(operand1,31,1);


	uint32_t NxorV ;
	NxorV =  (reg.R_N() ^ reg.R_V());
	NxorV = NxorV << 31;


	operand1 = (operand1 ^ NxorV);

	//operand 2 
	uint32_t operand2;
	if (readBits(reg.R_Y(),0,0) == 0) 
	{
		operand2= 0;
	}
	else if (reg.R_i() == 0)
	{
		operand2=reg.R_r(reg.R_rs2());
	}
	else
	{
		operand2=sign_extend(reg.R_simm13(),12);
	};


	uint32_t result = operand1 + operand2;

	//Y = r[rs1]<0> concat Y<31:1>;
	uint32_t Y =( (reg.R_r(reg.R_rs1())<<31) | readBits(reg.R_Y(),31,1) );
	reg.W_Y(Y);


	//store results

	if(reg.R_rd() != 0)
	{
		reg.W_r(reg.R_rd(),result);
	};


	uint32_t o1,o2,r;
	r =readBits(result,31,31);
	o1=readBits(operand1,31,31);
	o2=readBits(operand2,31,31);

	reg.W_N(r);
	if (result==0) reg.W_Z(1); else reg.W_Z(0);
	if( (o1 and o2 and !r) or (!o1 and !o2 and r)) reg.W_V(1); else reg.W_V(0);
	if( (o1 and o2) or (!r and (o1 or o2))) reg.W_C(1); else reg.W_C(0);

};




//Divide instructions
void SparcCore::execute_Div(Opcode op)
{
	uint32_t result=0;
	uint32_t operand1;
	uint32_t operand2;
	uint32_t temp_V=0;

	uint64_t temp_64bit;
	uint64_t dividend;


	//get operands
	operand1= reg.R_r(reg.R_rs1());
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);


	//check for divide by zero error
	if(operand2 == 0 )
	{
		trap=1;
		division_by_zero=1;
	}
	else //perform division
	{
		dividend   = concatBits(reg.R_Y(), operand1); 	//Y concat operand1
		if (op==UDIV or op==UDIVcc) 
		{
			temp_64bit = uint64_t( uint64_t(dividend) / uint64_t(operand2));

			result = readBits64(temp_64bit,31,0);
			if(readBits64(temp_64bit,63,32) == 0)
				temp_V = 0;
			else
				temp_V = 1;
		}
		else if(op == SDIV or op==SDIVcc)
		{
			temp_64bit = int64_t(int64_t(dividend) / int32_t(operand2));
			result = readBits64(temp_64bit,31,0);

			if( (readBits64(temp_64bit,63,31) == 0) or \
					(readBits64(temp_64bit,63,31) == 0x1FFFFFFFF) )		
				temp_V = 0;
			else
				temp_V = 1;
		};

		if(temp_V !=0) //result overflowed 32 bits, return largest appropriate int
		{
			if(op==UDIV or op==UDIVcc)
			{
				result = 0xFFFFFFFF; //2^32 - 1
			}
			else if(op ==SDIV or op==SDIVcc)
			{
				if((int64_t(temp_64bit)) > 0)
					result = 0x7FFFFFFF; //2^31 - 1
				else
					result = 0x80000000; //-2^31
			}
		};

		//store results
		if(reg.R_rd() != 0)
		{
			reg.W_r(reg.R_rd(),result);
		};

		//update flags -- only the "cc" variants (UDIVcc/SDIVcc) modify icc;
		//plain UDIV/SDIV must leave PSR unchanged.
		if(op==UDIVcc or op==SDIVcc)
		{
			reg.W_N(readBits(result,31,31));
			reg.W_Z(result == 0) ;
			reg.W_V(temp_V!=0);
			reg.W_C(0);
		};
	};

};




//Divide instructions
void SparcCore::execute_Mul(Opcode op)
{
	uint32_t result=0;
	uint32_t operand1;
	uint32_t operand2;

	//get operands
	operand1= reg.R_r(reg.R_rs1());
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);


	//perform mul
	if (op==UMUL or op==UMULcc) 
	{
		uint64_t mul_result = uint64_t(operand1) * uint64_t(operand2);
		result = readBits64(mul_result,31,0);
		reg.W_Y(readBits64(mul_result, 63,32));
	}
	else if(op==SMUL or op==SMULcc)
	{
		//Cast to int64_t *before* multiplying, so the multiplication itself
		//happens in 64-bit arithmetic -- int32_t*int32_t would compute (and
		//truncate/overflow) in 32-bit space first, losing the high bits of
		//the true product before the result is ever widened.
		int64_t  mul_result =  int64_t(int32_t(operand1)) * int64_t(int32_t(operand2));
		result = readBits64(mul_result,31,0);
		reg.W_Y(readBits64(mul_result, 63,32));
	}
	if( (reg.R_rd() != 0))
	{
		reg.W_r(reg.R_rd(),result); 
	};
	if(op==UMULcc or op==SMULcc)
	{
		reg.W_N(readBits(result,31,31));
		reg.W_Z(result == 0) ;
		reg.W_V(0); 
		reg.W_C(0);
	};
};


void SparcCore::execute_SaveRestore(Opcode op)
{
	uint32_t new_CWP;
	uint32_t result=0;
	uint32_t operand1;
	uint32_t operand2;

	operand1= reg.R_r(reg.R_rs1());
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);
	//SAVE
	if (op==SAVE) 
	{
		new_CWP = ((reg.R_CWP() - 1)%NWINDOWS);
		if( (reg.R_WIM() & (1<<new_CWP)) != 0)
		{
			trap = 1;
			window_overflow = 1;
		}
		else 
		{
			result = operand1 + operand2; // operands from old window 
			reg.W_CWP(new_CWP);
		}
	}
	else if (op==RESTORE) 
	{
		new_CWP = ((reg.R_CWP() + 1) % NWINDOWS);
		if((reg.R_WIM() & (1<<new_CWP) )!= 0)
		{
			trap = 1;
			window_underflow = 1; 
		}
		else 
		{
			result = operand1 + operand2; // operands from old window 
			reg.W_CWP(new_CWP);
		}
	};
	if((trap == 0) and (reg.R_rd() != 0))
	{
		reg.W_r(reg.R_rd(),result); // destination in new window 
	}
};



void SparcCore::execute_RETT(Opcode op)
{
	uint32_t new_cwp;
	uint32_t operand1;
	uint32_t operand2;

	operand1= reg.R_r(reg.R_rs1());
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);


	new_cwp = (reg.R_CWP() + 1) % NWINDOWS; 
	address = operand1 + operand2; 
	if (reg.R_ET() == 1)
	{
		trap = 1;
		if (reg.R_S() == 0) 
		{
			privileged_instruction = 1;
		}
		else 
			illegal_instruction = 1; //S !=0
	}
	else if (reg.R_S() == 0) 
	{
		trap = 1;
		privileged_instruction = 1;
		reg.W_tt(0x03); //trap type for privileged_instruction 
		state=ERROR;
	}
	else if ((reg.R_WIM() & 1<<new_cwp) != 0) 
	{
		trap = 1;
		window_underflow = 1;
		reg.W_tt(0x06); //trap type for window_underflow 
		state=ERROR;
	}
	else if (readBits(address,1,0) != 0)
	{
		trap = 1;
		mem_address_not_aligned = 1;
		reg.W_tt(0x07); //trap type for mem_address_not_aligned 
		state=ERROR;
	}
	else
	{
		reg.W_ET(1);
		reg.W_PC(reg.R_nPC());
		reg.W_nPC(address);
		reg.W_CWP( new_cwp);
		reg.W_S(reg.R_PS());
	};
};


//Trap on Integer Condition
//Instructions
void SparcCore::execute_Ticc(Opcode op)
{
	bool trap_eval_icc=0;
	bool Z=reg.R_Z();
	bool N=reg.R_N();
	bool V=reg.R_V();
	bool C=reg.R_C();

	uint32_t trap_number;

	switch(op)
	{
		case TNE :	{ trap_eval_icc = (Z == 0) ; break;};
		case TE :	{ trap_eval_icc = (Z == 1) ; break;};
		case TG : 	{ trap_eval_icc = ((Z or (N xor V)) == 0) ; break;};
		case TLE : 	{ trap_eval_icc = ((Z or (N xor V)) == 1) ; break;};
		case TGE : 	{ trap_eval_icc = ((N xor V) == 0) ; break;};
		case TL :  	{ trap_eval_icc = ((N xor V) == 1) ; break;};
		case TGU : 	{ trap_eval_icc = ((C == 0) and (Z == 0)) ; break;};
		case TLEU : 	{ trap_eval_icc = ((C == 1) or (Z == 1)) ; break;};
		case TCC :	{ trap_eval_icc = (C == 0) ; break;};
		case TCS :	{ trap_eval_icc = (C == 1) ; break;};
		case TPOS :	{ trap_eval_icc = (N == 0) ; break;};
		case TNEG :	{ trap_eval_icc = (N == 1) ; break;};
		case TVC :	{ trap_eval_icc = (V == 0) ; break;};
		case TVS :	{ trap_eval_icc = (V == 1) ; break;};
		case TA :       { trap_eval_icc=1; break;}
		case TN :       { trap_eval_icc=0; break;}
		default:	{assert(0);}
	};

	uint32_t operand1;
	uint32_t operand2;

	operand1= reg.R_r(reg.R_rs1());
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(readBits(reg.R_simm13(),7,0),8);

	trap_number = operand1 + operand2;

	if (trap_eval_icc == 1) 
	{
		trap = 1;
		trap_instruction = 1;
		ticc_trap_type = readBits(trap_number,6,0);

	}
	else 
	{
		reg.W_PC(reg.R_nPC()); //PC=nPC
		reg.W_nPC(reg.R_nPC()+4); //nPC=nPC+4;
	};
};


void SparcCore::execute_ReadStateReg(Opcode op)
{
	if ((op==RDPSR or op==RDWIM or op==RDTBR or (op==RDASR and (privileged_ASR(reg.R_rs1()) == 1))) and (reg.R_S()==0))
	{
		//Its a privileged instruction
		trap = 1;
		privileged_instruction = 1;
	}
	else if (op==RDASR && illegal_instruction_ASR(reg.R_rs1()) == 1) 
	{
		trap = 1;
		illegal_instruction = 1;
	}
	else if (reg.R_rd()!=0) 
	{
		uint32_t result;
		switch(op)
		{
			case RDY :    {result=reg.R_Y();break;}
			case RDASR :  {result=reg.R_ASR(reg.R_rs1()); break;}
			case RDPSR :  {result=reg.R_PSR(); break;}
			case RDWIM :  {result=reg.R_WIM(); break;}
			case RDTBR :  {result=reg.R_TBR(); break;}
			default :{assert(0);}
		};
		reg.W_r(reg.R_rd(),result);
	};
};



void SparcCore::execute_WriteStateReg(Opcode op)
{

	//No delay in updating the values of registers
	uint32_t operand1;
	uint32_t operand2;
	uint32_t result;
	uint32_t rd = reg.R_rd();

	operand1= reg.R_r(reg.R_rs1());
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);
	result = operand1 xor operand2;


	switch(op)
	{
		case WRY :   { reg.W_Y(result); break;}
		case WRASR : { 
				     if ( (privileged_ASR(rd) == 1) and (reg.R_S() == 0) )
				     {
					     trap = 1;
					     privileged_instruction = 1;
				     }
				     else if (illegal_instruction_ASR(rd) == 1)
				     {
					     trap = 1;
					     illegal_instruction = 1;
				     }
				     else
				     {
					     reg.W_ASR(rd,result);
				     };
				     break;
			     }
		case WRPSR : {
				     if (reg.R_S() == 0)
				     {
					     trap = 1;
					     privileged_instruction = 1;
				     }
				     else if (readBits(result,4,0) >= NWINDOWS)
				     {
					     trap = 1;
					     illegal_instruction = 1;
				     }
				     else 
				     {
					     //bits 31 to 24 of PSR are hardwired and cannot be changed by WRPSR instruction
					     uint32_t temp=reg.R_PSR();
					     writeBits(temp,23,0,result); //copy bits 0 to 23 of result into temp;
					     reg.W_PSR(temp);
				     };
				     break;
			     }
		case WRWIM : {
				     if (reg.R_S() == 0) 
				     {
					     trap = 1;
					     privileged_instruction = 1;
				     }
				     else 
				     {
					     reg.W_WIM(result);
					     //but don’t write bits corresponding to non-existent windows 
				     }
				     break;
			     }
		case WRTBR : {
				     if (reg.R_S() == 0) 
				     {
					     trap = 1;
					     privileged_instruction = 1;
				     }
				     else
				     {
					     uint32_t TBR=reg.R_TBR();
					     writeBits(TBR,31,12, readBits(result,31,12) );
					     reg.W_TBR(TBR);
				     };
				     break;
			     }
		default : assert(0); break;
	};

};

void SparcCore::execute_STBAR(Opcode op)
{
	store_barrier_pending=1;
	return;
};




//Atomic Loads Stores:
// Pre ops : determine : 
// 		address
// 		addr_space
// 		writeWord0
// 		writeWord1
// 		byte_mask


void SparcCore::execute_PreAtomicLoadStore(Opcode op)
{
	//1. find out address and addr_space fields
	uint32_t operand1=reg.R_r(reg.R_rs1());
	uint32_t operand2;
	if (reg.R_i() == 0)
		operand2= reg.R_r(reg.R_rs2());
	else 
		operand2= sign_extend(reg.R_simm13(),12);

	if (op==LDSTUB or op==SWAP) 
	{
		address = operand1 + operand2;
		if(reg.R_S()==0)
			addr_space = 10;
		else
			addr_space =11;
	}
	else if (op==LDSTUBA or op==SWAPA) 
	{
		if(reg.R_S()==0)
		{
			trap = 1;
			privileged_instruction = 1;
		}
		else if (reg.R_i() == 1) 
		{
			trap = 1;
			illegal_instruction = 1;
		}
		else
		{

			address=reg.R_r(reg.R_rs1()) + reg.R_r(reg.R_rs2());
			addr_space=reg.R_asi();
		};
	};

	if((op==SWAP or op==SWAPA) and (readBits(address,1,0)!= 0)) 
	{
		trap = 1;
		mem_address_not_aligned = 1;
	}

	if(trap==0)
	{
		//2. find out writeWord0,1 and byte_mask
		if(op == LDSTUB or op ==LDSTUBA) 
		{
			writeWord0 = 0xffffffff;
			writeWord1 = 0xffffffff;
			uint32_t a = readBits(address, 2,0);
			switch(a)
			{
				case 0 : { byte_mask = 0x08;  break;}
				case 1 : { byte_mask = 0x04;  break;}
				case 2 : { byte_mask = 0x02;  break;}
				case 3 : { byte_mask = 0x01;  break;}

				case 4 : { byte_mask = 0x80;  break;}
				case 5 : { byte_mask = 0x40;  break;}
				case 6 : { byte_mask = 0x20;  break;}
				case 7 : { byte_mask = 0x10;  break;}
				default : {assert(0);};
			};
			reg.W_pb_block_ldst_byte(1); 
		}
		else if (op ==SWAP or op==SWAPA)
		{
			uint32_t word = reg.R_r(reg.R_rd());
			writeWord0 = word;
			writeWord1 = word;

			//SWAP/SWAPA writes a full word (all 4 bytes), unlike LDSTUB's
			//byte write above -- address is guaranteed word-aligned by the
			//mem_address_not_aligned check just above, so a is 0 or 4.
			uint32_t a = readBits(address, 2,0);
			switch(a)
			{
				case 0 : { byte_mask = 0x0F;  break;} //word0: all 4 bytes
				case 2 : { byte_mask = 0x03;  break;}

				case 4 : { byte_mask = 0xF0;  break;} //word1: all 4 bytes
				case 6 : { byte_mask = 0x30;  break;}
				default : {assert(0);};
			};

			reg.W_pb_block_ldst_word(1); 
		};

	};
};

void SparcCore::execute_PostAtomicLoadStore(Opcode op, uint32_t rWord0, uint32_t rWord1)
{

	uint32_t byte =0;
	uint32_t word=0;


	if (MAE == 1) 
	{
		trap = 1; 
		data_access_exception = 1;
	}
	else //MAE!=1
	{
		if(readBits(address, 2,2)==0)
			word = rWord0;
		else
			word = rWord1;

		if(op==LDSTUB or op==LDSTUBA)//Byte operations 
		{
			uint32_t a =readBits(address,1,0);
			switch(a)
			{
				case 0: { byte = readBits(word,31,24);break;}
				case 1: { byte = readBits(word,23,16);break;}
				case 2: { byte = readBits(word,15,8 );break;}
				case 3: { byte = readBits(word,7,0  );break;}
				default:{ assert(0);}
			};
			word = zero_extend_byte(byte);
		}
		//if(op==SWAP or op==SWAPA) word=word//word operations

		reg.W_r(reg.R_rd(), word);

	};
	reg.W_pb_block_ldst_word(0);
	reg.W_pb_block_ldst_byte(0);
};


void SparcCore::execute_PreFlush(Opcode op)
{
	//Ref Appendix B.32 / Appendix C.9: address = r[rs1] + (r[rs2] or simm13).
	//Unlike loads/stores, FLUSH has no ASI/alternate-space field at all, and
	//no traps are defined for it once implemented -- the manual only allows
	//illegal_instruction/unimplemented_FLUSH as a discretionary choice for an
	//implementation that does not support FLUSH at all.
	//
	//This only computes the address; SparcCore has no memory/cache interface
	//of its own. The driver (SparcStateMachine.cpp for the standalone model,
	//SparcThread.sitar for the timed model) is responsible for conveying the
	//flush onward -- see MemoryInterface's FLUSH access type.
	uint32_t operand1 = reg.R_r(reg.R_rs1());
	uint32_t operand2;
	if (reg.R_i() == 0)
		operand2 = reg.R_r(reg.R_rs2());
	else
		operand2 = sign_extend(reg.R_simm13(), 12);

	address = operand1 + operand2;
};



void SparcCore::executeTraps() 
{
	if(trap==1)
	{
		selectTrap();
		//select the highest priority trap and place its code in tt
		if (state != ERROR)
		{
			//jump to the vector address in the next cycle
			reg.W_ET(0); 
			reg.W_PS(reg.R_S());
			reg.W_CWP((reg.R_CWP() - 1)%NWINDOWS);
			if (annul == 0) 
			{
				reg.W_r(17,reg.R_PC()); 
				reg.W_r(18,reg.R_nPC());
			}
			else // annul != 0 
			{
				reg.W_r(17, reg.R_nPC());
				reg.W_r(18, reg.R_nPC()+ 4); 
				annul = 0;
			};
			reg.W_S(1);
			if(reset_trap == 0)  
			{
				reg.W_PC(reg.R_TBR());
				reg.W_nPC(reg.R_TBR() + 4);
			}
			else // reset_trap = 1
			{ 
				reg.W_PC(0);
				reg.W_nPC(4); 
				reset_trap = 0;
			};
		};
	};
};



void SparcCore::selectTrap()
{
	//Exmaines the state of all trap sources
	//and selects the highest priority trap to be serviced.
	//and places the vector location for this trap in tt register,
	//and resets all trap signals.
	if (reset_trap == 1)
	{
		//ignore ET and leave tt unchanged
	} 
	else if (reg.R_ET() == 0) 
	{
		state = ERROR;
	}
	else if (data_store_error == 1)		      	{reg.W_tt(0B00101011); }
	else if (instruction_access_error == 1)		{reg.W_tt(0B00100001); }
	else if (r_register_access_error == 1)		{reg.W_tt(0B00100000); }
	else if (instruction_access_exception == 1)  	{reg.W_tt(0B00000001); }
	else if (privileged_instruction == 1)		{reg.W_tt(0B00000011); }
	else if (illegal_instruction == 1)		{reg.W_tt(0B00000010); }
	else if (fp_disabled == 1)			{reg.W_tt(0B00000100); }
	else if (cp_disabled == 1)			{reg.W_tt(0B00100100); }
	else if (unimplemented_FLUSH == 1)		{reg.W_tt(0B00100101); }
	else if (window_overflow == 1)			{reg.W_tt(0B00000101); }
	else if (window_underflow == 1)			{reg.W_tt(0B00000110); }
	else if (mem_address_not_aligned == 1)		{reg.W_tt(0B00000111); }
	else if (fp_exception == 1)			{reg.W_tt(0B00001000); }
	else if (cp_exception == 1)			{reg.W_tt(0B00101000); }
	else if (data_access_error == 1)	        {reg.W_tt(0B00101001); } 
	else if (data_access_exception == 1)		{reg.W_tt(0B00001001); }
	else if (tag_overflow == 1)			{reg.W_tt(0B00001010); }
	else if (division_by_zero == 1)			{reg.W_tt(0B00101010); }
	else if (trap_instruction == 1)			{reg.W_tt(0B10000000 | readBits( ticc_trap_type,6,0));}
	else if (interrupt_level > 0)			{reg.W_tt(0B00010000 | readBits( interrupt_level,3,0));}


	trap = 0;
	instruction_access_exception = 0; 
	illegal_instruction = 0;
	privileged_instruction = 0; 
	fp_disabled = 0; 
	cp_disabled = 0; 
	window_overflow = 0; 
	window_underflow = 0; 
	mem_address_not_aligned = 0; 
	fp_exception = 0; 
	cp_exception = 0; 
	data_access_exception = 0; 
	tag_overflow = 0; 
	division_by_zero = 0; 
	trap_instruction = 0; 
	interrupt_level = 0;

};



__attribute__((optimize("O0")))
std::string SparcCore::printTrap()
{
	//Examines the 	state of the processor
	//and returns a string for the name of the trap that 
	//has occured.
	using namespace std;
	string trap_name;
	if(trap==0) 	trap_name="NONE";
	else if(reset_trap == 1) 			trap_name="reset trap";
	else if (data_store_error == 1)		      	trap_name="data_store_error"; 
	else if (instruction_access_error == 1)		trap_name="instruction_access_error"; 
	else if (r_register_access_error == 1)		trap_name="r_register_access_error"; 
	else if (instruction_access_exception == 1)  	trap_name="instruction_access_exception"; 
	else if (privileged_instruction == 1)		trap_name="privileged_instruction"; 
	else if (illegal_instruction == 1)		trap_name="illegal_instruction"; 
	else if (fp_disabled == 1)			trap_name="fp_disabled"; 
	else if (cp_disabled == 1)			trap_name="cp_disabled"; 
	else if (unimplemented_FLUSH == 1)		trap_name="unimplemented_FLUSH"; 
	else if (window_overflow == 1)			trap_name="window_overflow"; 
	else if (window_underflow == 1)			trap_name="window_underflow"; 
	else if (mem_address_not_aligned == 1)		trap_name="mem_address_not_aligned"; 
	else if (fp_exception == 1)			trap_name="fp_exception"; 
	else if (cp_exception == 1)			trap_name="cp_exception"; 
	else if (data_access_error == 1)	        trap_name="data_access_error"; 
	else if (data_access_exception == 1)		trap_name="data_access_exception"; 
	else if (tag_overflow == 1)			trap_name="tag_overflow"; 
	else if (division_by_zero == 1)			trap_name="division_by_zero"; 
	else if (trap_instruction == 1)			trap_name="trap_instruction";
	else if (interrupt_level > 0)			trap_name="external_interrupt";

	if(trap_instruction == 1)
	{
		unsigned int trap_num =  ticc_trap_type;
		trap_name  = trap_name + "("+ ToString(trap_num)+")";
	}


	return trap_name;
};

__attribute__((optimize("O0")))
std::string SparcCore::trapTypeName(uint32_t tt)
{
	//Mirrors selectTrap()'s own encoding exactly (same file, above):
	//each case here is the identical bit pattern selectTrap() writes
	//into tt for that trap. None of selectTrap()'s branches ever write
	//0, so tt==0 uniquely identifies the reset trap (TBR's power-on
	//value, before selectTrap() has run for the first time).
	if (tt == 0)
		return "reset trap";
	if (tt & 0x80)
		return "trap_instruction(" + ToString(tt & 0x7F) + ")";
	if ((tt & 0xF0) == 0x10)
		return "external_interrupt(" + ToString(tt & 0x0F) + ")";

	switch (tt)
	{
		case 0x01: return "instruction_access_exception";
		case 0x02: return "illegal_instruction";
		case 0x03: return "privileged_instruction";
		case 0x04: return "fp_disabled";
		case 0x05: return "window_overflow";
		case 0x06: return "window_underflow";
		case 0x07: return "mem_address_not_aligned";
		case 0x08: return "fp_exception";
		case 0x09: return "data_access_exception";
		case 0x0A: return "tag_overflow";
		case 0x20: return "r_register_access_error";
		case 0x21: return "instruction_access_error";
		case 0x24: return "cp_disabled";
		case 0x25: return "unimplemented_FLUSH";
		case 0x28: return "cp_exception";
		case 0x29: return "data_access_error";
		case 0x2A: return "division_by_zero";
		case 0x2B: return "data_store_error";
	}

	std::stringstream ss;
	ss << "unknown(0x" << std::hex << tt << ")";
	return ss.str();
};






/*	
//Trap status types
data_store_error  			
instruction_access_error  		
r_register_access_error  		
instruction_access_exception    	
privileged_instruction  		
illegal_instruction  		
fp_disabled  			
cp_disabled  			
unimplemented_FLUSH  		
window_overflow  			
window_underflow  			
mem_address_not_aligned  		
fp_exception  			
cp_exception  			
data_access_error  	        
data_access_exception  		
tag_overflow  			
division_by_zero  			
trap_instruction  */		





void SparcCore::checkExternalTraps()
{
	//Check for external traps(on the processor pins)
	//if traps are enabled and unmasked traps
	//have occured, set trap=1
	if ( (reg.R_ET()==1)  && ( (reg.R_bp_IRL()==15) || (reg.R_bp_IRL()>reg.R_PIL())))
	{
		trap=1;
		interrupt_level=reg.R_bp_IRL();
	};
};


//Returns a value with only the highest set bit (among bits 4:0) of x retained, or 0 if none
//are set. Used by complete_fp_execution() to compute cexc on an IEEE_754_exception trap
//(Ref manual Appendix C.7: "cexc <- most_significant_bit_of(texc and TEM)").
static uint32_t mostSignificantSetBit5(uint32_t x)
{
	for (int i = 4; i >= 0; i--)
		if (readBits(x, i, i))
			return (1u << i);
	return 0;
}

void SparcCore::complete_fp_execution(Opcode op)
{
	//The complete_fp_execution() checks for floating-point traps and
	//maintains the Floating-point State Register (FSR).
	if (trap == 0) 
	{
		// no traps so far 
		if (reg.bp_FPU_present == 0) 
		{
			//no FPU is present 
			trap = 1;
			fp_exception = 1;
			reg.W_ftt(Registers::unimplemented_FPop);
			//std::cout<<"\n Trap type 1 \n";
		}
		else if (reg.fpu_c == 0) //not finished
		{
			trap = 1;
			fp_exception = 1;
			reg.W_ftt(Registers::unfinished_FPop);
			//std::cout<<"\n Trap type 2 \n";
		}
		else 
		{
			// FPU present; FPop executed and finished 
			if ( (reg.R_texc() & reg.R_TEM()) != 0)
			{
				//floating-point trap has occured
				reg.W_cexc(mostSignificantSetBit5(reg.R_texc() & reg.R_TEM())); //most significant bit of texc and TEM
				trap = 1;
				fp_exception = 1;
				reg.W_ftt(Registers::IEEE_754_exception);
				//std::cout<<"\n Trap type 3 \n";
			}
			else
			{
				// no floating-point trap 
				reg.W_cexc(reg.R_texc());
				reg.W_aexc(reg.R_aexc() | reg.R_texc());
				if (reg.fpu_single_result == 1) 
				{
					reg.W_f(reg.R_rd(), reg.sresult);
				}
				if (reg.fpu_double_result == 1)
				{
					int fpu_reg_num = readBits(reg.R_rd(),4,1);
					reg.f[2*fpu_reg_num]  =reg.dresult[0];
					reg.f[2*fpu_reg_num+1]=reg.dresult[1];
				}
				if (reg.fpu_quad_result == 1) 
				{
					int fpu_reg_num = readBits(reg.R_rd(),4,2);
					reg.f[4*fpu_reg_num]  =reg.qresult[0];
					reg.f[4*fpu_reg_num+1]=reg.qresult[1];
					reg.f[4*fpu_reg_num+2]=reg.qresult[2];
					reg.f[4*fpu_reg_num+3]=reg.qresult[3];
				}
				if (reg.fpu_compare == 1)
				{
					reg.W_fcc(reg.R_tfcc());
				}
				reg.W_ftt(0);
				reg.fpu_single_result=0;
				reg.fpu_double_result=0;
				reg.fpu_quad_result=0;
				reg.fpu_compare=0;
				reg.texc=0;
				reg.tfcc=0;
				reg.fpu_c=0;
			};
		};
	};

};

//FBfcc : Branch on Floating pointr Condition Codes
void SparcCore::execute_FBfcc(Opcode op)
{
	bool E,L,G,U;
	bool eval_fcc=0;

	E = (reg.R_fcc()==0)?1:0;
	L = (reg.R_fcc()==1)?1:0;
	G = (reg.R_fcc()==2)?1:0;
	U = (reg.R_fcc()==3)?1:0;
	
	switch(op)
	{
		case FBU 	:{eval_fcc=  (U == 1); 			break;}
		case FBG   	:{eval_fcc=  (G == 1); 			break;}
		case FBUG  	:{eval_fcc=  (G == 1 or U==1);		break;}
		case FBL   	:{eval_fcc=  (L == 1); 			break;}
		case FBUL  	:{eval_fcc=  (L == 1 or U==1);		break;}
		case FBLG  	:{eval_fcc=  (L == 1 or G==1);		break;}
		case FBNE  	:{eval_fcc=  (L == 1 or G==1 or U==1); 	break;}
		case FBE   	:{eval_fcc=  (E == 1); 			break;}
		case FBUE  	:{eval_fcc=  (E == 1 or U==1);		break;}
		case FBGE  	:{eval_fcc=  (E == 1 or G==1);		break;}
		case FBUGE 	:{eval_fcc=  (E == 1 or G==1 or U==1);	break;}
		case FBLE  	:{eval_fcc=  (E == 1 or L==1);		break;}
		case FBULE 	:{eval_fcc=  (E == 1 or L==1 or U==1);	break;}
		case FBO   	:{eval_fcc=  (E == 1 or L==1 or G==1);	break;}
		case FBA   	:{eval_fcc=  1; 			break;}
		case FBN   	:{eval_fcc=  0; 			break;}
		default : {assert(0);};
	};
	uint32_t pc=0;
	uint32_t npc=0;
	pc=reg.R_PC();
	npc=reg.R_nPC();

	reg.W_PC(npc); //PC=nPC
	if(eval_fcc==1)
	{
		//take the branch
		reg.W_nPC( pc + sign_extend(reg.R_disp22()<<2, 23));
		if ((op==FBA) and (reg.R_a() == 1))
		{
			annul=1; //only for annulling Branch-always
		};
	}
	else //do not take the branch
	{
		reg.W_nPC( npc + 4);
		if (reg.R_a() == 1) 
		{
			annul = 1; // only for annulling branches other than FBA
		};
	};


};


void SparcCore:: misaligned_fp_reg_trap()
{
	trap = 1;
	fp_exception = 1;
	reg.W_ftt(reg.invalid_fp_register);
};


void SparcCore::execute_FPop(Opcode op)
{
		//clear status signals:
		reg.sresult=0;
		for(int i=0;i<2;i++)reg.dresult[i]=0;
		for(int i=0;i<4;i++)reg.qresult[i]=0;
		reg.fpu_single_result =0;
		reg.fpu_double_result =0;
		reg.fpu_quad_result =0;
		reg.fpu_compare=0;
		reg.texc = 0;
		reg.tfcc = 0;
		reg.fpu_c =0;


		//get operand register addresses:
		uint32_t rs1 = reg.R_rs1();
		uint32_t rs2 = reg.R_rs2();
		uint32_t rd  = reg.R_rd();

		//double precision
		uint32_t rs1E = (readBits(reg.R_rs1(),4,1) << 1) | 0x00;
		uint32_t rs1O = (readBits(reg.R_rs1(),4,1) << 1) | 0x01;
		uint32_t rs2E = (readBits(reg.R_rs2(),4,1) << 1) | 0x00;
		uint32_t rs2O = (readBits(reg.R_rs2(),4,1) << 1) | 0x01;
		uint32_t rdE  = (readBits(reg.R_rd(),4,1) << 1) | 0x00;
		uint32_t rdO  = (readBits(reg.R_rd(),4,1) << 1) | 0x01;
		
		//quad precision
		uint32_t rs1EE = (readBits(reg.R_rs1(),4,2) << 2) | 0x00;
		uint32_t rs1EO = (readBits(reg.R_rs1(),4,2) << 2) | 0x01;
		uint32_t rs1OE = (readBits(reg.R_rs1(),4,2) << 2) | 0x02;
		uint32_t rs1OO = (readBits(reg.R_rs1(),4,2) << 2) | 0x03;
		uint32_t rs2EE = (readBits(reg.R_rs2(),4,2) << 2) | 0x00;
		uint32_t rs2EO = (readBits(reg.R_rs2(),4,2) << 2) | 0x01;
		uint32_t rs2OE = (readBits(reg.R_rs2(),4,2) << 2) | 0x02;
		uint32_t rs2OO = (readBits(reg.R_rs2(),4,2) << 2) | 0x03;
		uint32_t rdEE = (readBits(reg.R_rd(),4,2) << 2) | 0x00;
		uint32_t rdEO = (readBits(reg.R_rd(),4,2) << 2) | 0x01;
		uint32_t rdOE = (readBits(reg.R_rd(),4,2) << 2) | 0x02;
		uint32_t rdOO = (readBits(reg.R_rd(),4,2) << 2) | 0x03;

		uint32_t single_1    = reg.R_f(rs1);
		uint32_t single_2    = reg.R_f(rs2);
		
		uint32_t double_1[2] = {reg.R_f(rs1E), reg.R_f(rs1O)};
		uint32_t double_2[2] = {reg.R_f(rs2E), reg.R_f(rs2O)};
		
		uint32_t quad_1[4]   = {reg.R_f(rs1EE),reg.R_f(rs1EO),reg.R_f(rs1OE),reg.R_f(rs1OO)};
		uint32_t quad_2[4]   = {reg.R_f(rs2EE),reg.R_f(rs2EO),reg.R_f(rs2OE),reg.R_f(rs2OO)};



		switch(op)
		{
			//integer to float conversion
			case FiTOs :{reg.fpu_single_result=1;	convertIntToSingle(&single_2, &reg.sresult, &reg.texc);	break;}
			case FiTOd :{reg.fpu_double_result=1; 	convertIntToDouble(&single_2, &reg.dresult[0], &reg.texc);	break;}
			case FiTOq :{reg.fpu_quad_result  =1; 	convertIntToQuad  (&single_2, &reg.qresult[0], &reg.texc);	break;}
			//float to integer conversion
			case FsTOi :{reg.fpu_single_result=1;   convertSingleToInt(&single_2,    &reg.sresult, &reg.texc);   	break;}
			case FdTOi :{reg.fpu_single_result=1;   convertDoubleToInt(&double_2[0], &reg.sresult, &reg.texc);   	break;}
			case FqTOi :{reg.fpu_single_result=1;   convertQuadToInt  (&quad_2[0],   &reg.sresult, &reg.texc);   	break;}
			//convert between floating point formats
			case FsTOd :{reg.fpu_double_result=1;   convertSingleToDouble(&single_2,     &reg.dresult[0], &reg.texc); break;}
			case FsTOq :{reg.fpu_quad_result=1;     convertSingleToQuad  (&single_2,     &reg.qresult[0], &reg.texc); break;}

			case FdTOs :{reg.fpu_single_result=1;   convertDoubleToSingle(&double_2[0],  &reg.sresult, &reg.texc);    break;}
			case FdTOq :{reg.fpu_quad_result=1;     convertDoubleToQuad  (&double_2[0],  &reg.qresult[0], &reg.texc); break;}

			case FqTOs :{reg.fpu_single_result=1;   convertQuadToSingle  (&quad_2[0]  ,  &reg.sresult, &reg.texc);    break;}
			case FqTOd :{reg.fpu_double_result=1;   convertQuadToDouble  (&quad_2[0]  ,  &reg.dresult[0], &reg.texc); break;}

			//floating point MOV (Ref manual Appendix C.9: texc <- 0 for these -- exact, no exceptions possible)
			case FMOVs :{reg.fpu_single_result=1;   reg.sresult = single_2; break;}
			case FNEGs :{reg.fpu_single_result=1;   reg.sresult =(single_2 ^ ((uint32_t)0x80000000)); break;}
			case FABSs :{reg.fpu_single_result=1;   reg.sresult =(single_2 & ((uint32_t)0x7fffffff)); break;}

			//floating point square roots
			case FSQRTs :{reg.fpu_single_result=1;  sqrt_single(&single_2,    &reg.sresult, &reg.texc   ); break;}
			case FSQRTd :{reg.fpu_double_result=1;  sqrt_double(&double_2[0], &reg.dresult[0], &reg.texc); break;}
			case FSQRTq :{reg.fpu_quad_result  =1;  sqrt_quad  (&quad_2[0],   &reg.qresult[0], &reg.texc); break;}

			//floating point add and sub
			case FADDs  :{reg.fpu_single_result=1;  add_single(&single_1, &single_2, &reg.sresult, &reg.texc); 	break;}
			case FSUBs  :{reg.fpu_single_result=1;  sub_single(&single_1, &single_2, &reg.sresult, &reg.texc); 	break;}

			case FADDd  :{reg.fpu_double_result=1;  add_double(&double_1[0], &double_2[0], &reg.dresult[0], &reg.texc); break;}
			case FSUBd  :{reg.fpu_double_result=1;  sub_double(&double_1[0], &double_2[0], &reg.dresult[0], &reg.texc); break;}

			case FADDq  :{reg.fpu_quad_result=1;    add_quad(&quad_1[0], &quad_2[0], &reg.qresult[0], &reg.texc); break;}
			case FSUBq  :{reg.fpu_quad_result=1;    sub_quad(&quad_1[0], &quad_2[0], &reg.qresult[0], &reg.texc); break;}

			//floating point mul and div
			case FMULs  :{reg.fpu_single_result=1;  mul_single(&single_1, &single_2, &reg.sresult, &reg.texc); 	 break;}
			case FDIVs  :{reg.fpu_single_result=1;  div_single(&single_1, &single_2, &reg.sresult, &reg.texc); 	 break;}

			case FMULd  :{reg.fpu_double_result=1;  mul_double(&double_1[0], &double_2[0], &reg.dresult[0], &reg.texc); break;}
			case FDIVd  :{reg.fpu_double_result=1;  div_double(&double_1[0], &double_2[0], &reg.dresult[0], &reg.texc); break;}

			case FMULq  :{reg.fpu_quad_result=1;    mul_quad(&quad_1[0], &quad_2[0], &reg.qresult[0], &reg.texc);  	 break;}
			case FDIVq  :{reg.fpu_quad_result=1;    div_quad(&quad_1[0], &quad_2[0], &reg.qresult[0], &reg.texc); 	 break;}

			case FsMULd :{reg.fpu_double_result=1;  mul_single_to_double(&single_1, &single_2, &reg.dresult[0], &reg.texc); break;}
			case FdMULq :{reg.fpu_quad_result=1;    mul_double_to_quad  (&double_1[0], &double_2[0], &reg.qresult[0], &reg.texc);  break;}

			//floating point compare instructions
			//FCMP traps only on a signaling NaN operand; FCMPE traps on any NaN
			//operand (quiet or signaling) -- see compare_single/compare_e_single etc.
			case FCMPs  :{reg.fpu_compare=1; reg.W_tfcc(compare_single  (&single_1, &single_2, &reg.texc)); 	 break;}
			case FCMPEs :{reg.fpu_compare=1; reg.W_tfcc(compare_e_single(&single_1, &single_2, &reg.texc)); 	 break;}

			case FCMPd  :{reg.fpu_compare=1; reg.W_tfcc(compare_double  (&double_1[0], &double_2[0], &reg.texc)); 	 break;}
			case FCMPEd :{reg.fpu_compare=1; reg.W_tfcc(compare_e_double(&double_1[0], &double_2[0], &reg.texc)); 	 break;}

			case FCMPq  :{reg.fpu_compare=1; reg.W_tfcc(compare_quad  (&quad_1[0], &quad_2[0], &reg.texc)); 	 break;}
			case FCMPEq :{reg.fpu_compare=1; reg.W_tfcc(compare_e_quad(&quad_1[0], &quad_2[0], &reg.texc)); 	 break;}

			default : {
					  assert(0); //unimplemented floating point instruction!!
					  break;
				  };
		};


		reg.fpu_c =1;	//fpu operation completed
		
		//check for misaligned traps
		if( (reg.fpu_double_result and (readBits(reg.R_rs1(),0,0) != 0)) or (reg.fpu_quad_result   and (readBits(reg.R_rs1(),1,0) != 0)))
		{
			misaligned_fp_reg_trap();
		}

};



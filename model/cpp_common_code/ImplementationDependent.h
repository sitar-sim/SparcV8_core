//ImplementationDependent.h
//
//Implementation-defined SPARC V8 parameters that the manual leaves open
//(number of register windows, which ASRs are implemented, etc).

#ifndef IMPLEMENTATION_DEPENDENT_H
#define IMPLEMENTATION_DEPENDENT_H

#define MEMORY_SIZE 0x4000  //unused. Actual memory sizing is MemCore::memSize.
#define NWINDOWS 8
	//Number of Register windows in the implementation of Sparc V8
	//can be between 2 and 32
	//

//Delayed nature of Write State Register Instructions:
//The Write state register instructsions may take from 0 to 3 cycles
//to take effect. Eg. mov 0x05, %psr will actually update psr after upto 3
//cycles.
//This complicates the state machine, so Currently
//
//IMPLEMENTED DELAY =0 for all write state reg instructions



//Ancillary State Registers
//
//from manual:
//Implementation allows upto 31 Ancillary state registers.
//numbered from 1 to 31.
//ASRs 1 to 15 are reserved.
//How many ASRs are implemented in hardware and which of these
//are privileged is implementation dependent.
//

inline bool privileged_ASR(uint32_t  rs1){return 0;} //none is privileged
inline bool illegal_instruction_ASR(uint32_t reg_number) {return 0;} //none is illegal

#endif



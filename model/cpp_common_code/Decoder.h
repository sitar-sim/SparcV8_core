//Decoder.h
//
//Decodes the 32-bit instruction word into an Opcode. The instruction
//register and its bit fields are described in Registers.h. Opcodes are
//enumerated in Opcodes.h.

#ifndef DECODER_H
#define DECODER_H

#include"Opcodes.h"
#include"Registers.h"
#include<cassert>


class Decoder
{
	public:
		
		//The main function
		Opcode decode( Registers * reg);

		//Decodes intruction stored in reg.instruction
		//and returns an opcode.
		
		//The following types of instructions are not decoded, and
		//the function returns only the category name as Opcode:
		//	FPop1,FPop2,CPop1,CPop2,FBfcc,CBccc

		//In addition, the following might be returned:
		// UNIMP
		// unassigned
		// unimplemented
		



		//These functions are called by decode() internally
		Opcode decodeBicc (Registers * reg);
		Opcode decodeArith(Registers * reg);
		Opcode decodeTicc (Registers * reg);
		Opcode decodeLoadStore(Registers * reg);



		//These functions are coded here to decode the FP and CP
		//instructions, but they're not used as of now.
		Opcode decodeFBfcc(Registers * reg);
		Opcode decodeCBccc(Registers * reg);
		Opcode decodeFPop1(Registers * reg);
		Opcode decodeFPop2(Registers * reg);
		
		//When op==3

};

#endif


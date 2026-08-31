//Opcodes.h
//
//Enumerates every SPARC V8 instruction opcode.

#ifndef OPCODES_H
#define OPCODES_H

#include<iostream>

//WARNING: do not change the order of opcodes. SparcCore.cpp relies on
//it for range checks like `if (op>=LDSB and op<=LDD)`.
enum Opcode
{
		//Memory-related instructions------------------------
		//Load
		LDSB,	// 001001 Load Signed Byte
		LDSH,	// 001010 Load Signed Halfword
		LDUB,	// 000001 Load Unsigned Byte
		LDUH,	// 000010 Load Unsigned Halfword
		LD,	// 000000 Load Word
		LDD,	// 000011 Load Doubleword
		
		LDSBA,	//† 011001 Load Signed Byte from Alternate space
		LDSHA,	//† 011010 Load Signed Halfword from Alternate space
		LDUBA,	//† 010001 Load Unsigned Byte from Alternate space
		LDUHA,	//† 010010 Load Unsigned Halfword from Alternate space
		LDA,	//† 010000 Load Word from Alternate space
		LDDA,	//† 010011 Load Doubleword from Alternate space
		
		LDF,	// 100000 Load Floating-point Register
		LDDF,	// 100011 Load Double Floating-point Register
		LDFSR,	// 100001 Load Floating-point State Register
		
		LDC,	// 110000 Load Coprocessor Register
		LDDC,	// 110011 Load Double Coprocessor Register
		LDCSR,	// 110001 Load Coprocessor State Register


		//Store
		STB,	// 000101 Store Byte
		STH,	// 000110 Store Halfword
		ST,	// 000100 Store Word
		STD,	// 000111 Store Doubleword
		
		STBA,	//† 010101 Store Byte into Alternate space
		STHA,	//† 010110 Store Halfword into Alternate space
		STA,	//† 010100 Store Word into Alternate space
		STDA,	//† 010111 Store Doubleword into Alternate space
		
		STF,	// 100100 Store Floating-point
		STDF,	// 100111 Store Double Floating-point
		STFSR,	// 100101 Store Floating-point State Register
		STDFQ,	//† 100110 Store Double Floating-point deferred-trap Queue

		STC,	// 110100 Store Coprocessor
		STDC,	// 110111 Store Double Coprocessor
		STCSR,	// 110101 Store Coprocessor State Register
		STDCQ,	//† 110110 Store Double Coprocessor Queue

		
		//Atomic Load/Store
		LDSTUB,	// 001101 Atomic Load-Store Unsigned Byte
		LDSTUBA,//† 011101 Atomic Load-Store Unsigned Byte into Alternate space


		//SWAP Register with Memory,
		SWAP,	// 001111 SWAP register with memory
		SWAPA,	//† 011111 SWAP register with Alternate space memory

		//---end-of-memory-related-instructions----------------------------------




		//SETHI Instruction
		SETHI,	// 00 100 Set High-Order 22 bits

		//NOP Instruction
		NOP,	// 00 100 No Operation




		//Logical   
		AND,	// 000001 And
		ANDcc,	// 010001 And and modify icc
		ANDN,	// 000101 And Not
		ANDNcc,	// 010101 And Not and modify icc
		OR,	// 000010 Inclusive Or
		ORcc,	// 010010 Inclusive Or and modify icc
		ORN,	// 000110 Inclusive Or Not
		ORNcc,	// 010110 Inclusive Or Not and modify icc
		XOR,	// 000011 Exclusive Or
		XORcc,	// 010011 Exclusive Or and modify icc
		XNOR,	// 000111 Exclusive Nor
		XNORcc,	// 010111 Exclusive Nor and modify icc

		//Shift  
		SLL,	// 100101 Shift Left Logical
		SRL,	// 100110 Shift Right Logical
		SRA,	// 100111 Shift Right Arithmetic

		//Add  
		 
		ADD,	// 000000 Add
		ADDcc,	// 010000 Add and modify icc
		ADDX,	// 001000 Add with Carry
		ADDXcc,	// 011000 Add with Carry and modify icc

		//Tagged Add
		   
		TADDcc,	// 100000 Tagged Add and modify icc
		TADDccTV,// 100010 Tagged Add, modify icc and Trap on Overflow


		//Subtract  
		 
		SUB,	// 000100 Subtract
		SUBcc,	// 010100 Subtract and modify icc
		SUBX,	// 001100 Subtract with Carry
		SUBXcc,	// 011100 Subtract with Carry and modify icc

		//Tagged Subtract
		   
		TSUBcc,	// 100001 Tagged Subtract and modify icc
		TSUBccTV,	// 100011 Tagged Subtract, modify icc and Trap on Overflow

		//Multiply Step
		MULScc,	// 100100 Multiply Step and modify iccif

		//Multiply  
		 
		UMUL,	// 001010 Unsigned Integer Multiply
		SMUL,	// 001011 Signed Integer Multiply
		UMULcc,	// 011010 Unsigned Integer Multiply and modify icc
		SMULcc,	// 011011 Signed Integer Multiply and modify icc

		//Divide  
		 
		UDIV,	// 001110 Unsigned Integer Divide
		SDIV,	// 001111 Signed Integer Divide
		UDIVcc,	// 011110 Unsigned Integer Divide and modify icc
		SDIVcc,	// 011111 Signed Integer Divide and modify icc


		//SAVE and RESTORE  
		 
		SAVE,	// 111100 Save caller’s window
		RESTORE,	// 111101 Restore caller’s window


		//Branch on Integer Condition Codes  
		//Bicc,
		//opcode cond operation icc test
		BA,	// 1000 Branch Always 1
		BN,	// 0000 Branch Never 0
		BNE,	// 1001 Branch on Not Equal not Z
		BE,	// 0001 Branch on Equal Z
		BG,	// 1010 Branch on Greater not (Z or (N xor V))
		BLE,	// 0010 Branch on Less or Equal Z or (N xor V)
		BGE,	// 1011 Branch on Greater or Equal not (N xor V)
		BL,	// 0011 Branch on Less N xor V
		BGU,	// 1100 Branch on Greater Unsigned not (C or Z)
		BLEU,	// 0100 Branch on Less or Equal Unsigned (C or Z)
		BCC,	// 1101 Branch on Carry Clear (Greater than or Equal, Unsigned) not C
		BCS,	// 0101 Branch on Carry Set (Less than, Unsigned) C
		BPOS,	// 1110 Branch on Positive not N
		BNEG,	// 0110 Branch on Negative N
		BVC,	// 1111 Branch on Overflow Clear not V
		BVS,	// 0111 Branch on Overflow Set V

		//Branch on Floatingpoint
		//Condition
		//Codes 
		//FBfcc,	//opcode cond operation fcc test
		FBA,	// 1000 Branch Always 1
		FBN,	// 0000 Branch Never 0
		FBU,	// 0111 Branch on Unordered U
		FBG,	// 0110 Branch on Greater G
		FBUG,	// 0101 Branch on Unordered or Greater G or U
		FBL,	// 0100 Branch on Less L
		FBUL,	// 0011 Branch on Unordered or Less L or U
		FBLG,	// 0010 Branch on Less or Greater L or G
		FBNE,	// 0001 Branch on Not Equal L or G or U
		FBE,	// 1001 Branch on Equal E
		FBUE,	// 1010 Branch on Unordered or Equal E or U
		FBGE,	// 1011 Branch on Greater or Equal E or G
		FBUGE,	// 1100 Branch on Unordered or Greater or Equal E or G or U
		FBLE,	// 1101 Branch on Less or Equal E or L
		FBULE,	// 1110 Branch on Unordered or Less or Equal E or L or U
		FBO,	// 1111 Branch on Ordered E or L or G


		//Branch on
		//Coprocessor
		//Condition Codes
		CBccc, 	//opcode cond bp_CP_cc[1:0] test
		CBA,	// 1000 Always
		CBN,	// 0000 Never
		CB3,	// 0111 3
		CB2,	// 0110 2
		CB23,	// 0101 2 or 3
		CB1,	// 0100 1
		CB13,	// 0011 1 or 3
		CB12,	// 0010 1 or 2
		CB123,	// 0001 1 or 2 or 3
		CB0,	// 1001 0
		CB03,	// 1010 0 or 3
		CB02,	// 1011 0 or 2
		CB023,	// 1100 0 or 2 or 3
		CB01,	// 1101 0 or 1
		CB013,	// 1110 0 or 1 or 3
		CB012,	// 1111 0 or 1 or 2


		//Call and Link
		//Instruction opcode op operation
		CALL,	// 01 Call and Link


		//Jump and Link
		//Instruction  
		JMPL,	// 111000 Jump and Link

		//Return from Trap
		//Instruction  
		RETT,	//† 111001 Return from Trap

		//Trap on Integer Condition Codes Instruction
		//Ticc,
		//opcode cond operation icc test
		TA,	// 1000 Trap Always 1
		TN,	// 0000 Trap Never 0
		TNE,	// 1001 Trap on Not Equal not Z
		TE,	// 0001 Trap on Equal Z
		TG,	// 1010 Trap on Greater not (Z or (N xor V))
		TLE,	// 0010 Trap on Less or Equal Z or (N xor V)
		TGE,	// 1011 Trap on Greater or Equal not (N xor V)
		TL,	// 0011 Trap on Less N xor V
		TGU,	// 1100 Trap on Greater Unsigned not (C or Z)
		TLEU,	// 0100 Trap on Less or Equal Unsigned (C or Z)
		TCC,	// 1101 Trap on Carry Clear (Greater than or Equal, Unsigned) not C
		TCS,	// 0101 Trap on Carry Set (Less Than, Unsigned) C
		TPOS,	// 1110 Trap on Positive not N
		TNEG,	// 0110 Trap on Negative N
		TVC,	// 1111 Trap on Overflow Clear not V
		TVS,	// 0111 Trap on Overflow Set V

		//Read State Register  
		//opcode op3 rs1 operation
		RDY,	// 101000 0 Read Y Register
		RDASR,	//‡ 101000 1 - 15 Read Ancillary State Register (reserved)
		//RDASR,	//‡ 101000 16 - 31 (implementation-dependent)
		RDPSR,	//† 101001 reserved Read Processor State Register
		RDWIM,	//† 101010 reserved Read Window Invalid Mask Register
		RDTBR,	//† 101011 reserved Read Trap Base Register

		//Write State Register  
		//opcode op3 rd operation
		WRY,	// 110000 0 Write Y Register
		WRASR,	//‡ 110000 1 - 15 Write Ancillary State Register (reserved)
		//WRASR,	//‡ 110000 16 - 31 (implementation-dependent)
		WRPSR,	//† 110001 reserved Write Processor State Register
		WRWIM,	//† 110010 reserved Write Window Invalid Mask Register
		WRTBR,	//† 110011 reserved Write Trap Base Register

		//STBAR Instruction
		STBAR,	// 101000 Store Barrier

		//Unimplemented Instruction 
		//opcode op op2 operation
		UNIMP,	// 00 000 Unimplemented

		//Flush Instruction
		//Memory  
		FLUSH,	// 111011 Flush Instruction Memory



		//Floating-point
		//Operate (FPop)
		 

		//Convert Integer to Floating
		//point   opcode opf operation
		//Fpop1:
		FiTOs,	// 011000100 Convert Integer to Single
		FiTOd,	// 011001000 Convert Integer to Double
		FiTOq,	// 011001100 Convert Integer to Quad


		////Convert Floating point to
		//Integer   opcode opf operation
		FsTOi,	// 011010001 Convert Single to Integer
		FdTOi,	// 011010010 Convert Double to Integer
		FqTOi,	// 011010011 Convert Quad to Integer

		//Convert Between Floatingpoint
		//Formats   opcode opf operation
		FsTOd,	// 011001001 Convert Single to Double
		FsTOq,	// 011001101 Convert Single to Quad
		FdTOs,	// 011000110 Convert Double to Single
		FdTOq,	// 011001110 Convert Double to Quad
		FqTOs,	// 011000111 Convert Quad to Single
		FqTOd,	// 011001011 Convert Quad to Double
		

		//Floating-point Move
		//  opcode opf operation
		FMOVs,	// 000000001 Move
		FNEGs,	// 000000101 Negate
		FABSs,	// 000001001 Absolute Value

		//Floating-point Square Root
		//  opcode opf operation
		FSQRTs,	// 000101001 Square Root Single
		FSQRTd,	// 000101010 Square Root Double
		FSQRTq,	// 000101011 Square Root Quad


		//Floating-point Add and
		//Subtract   opcode opf operation
		FADDs,	// 001000001 Add Single
		FADDd,	// 001000010 Add Double
		FADDq,	// 001000011 Add Quad
		FSUBs,	// 001000101 Subtract Single
		FSUBd,	// 001000110 Subtract Double
		FSUBq,	// 001000111 Subtract Quad


		//Floating-point Multiply and Divide  
		//opcode opf operation
		FMULs,	// 001001001 Multiply Single
		FMULd,	// 001001010 Multiply Double
		FMULq,	// 001001011 Multiply Quad
		FsMULd,	// 001101001 Multiply Single to Double
		FdMULq,	// 001101110 Multiply Double to Quad
		FDIVs,	// 001001101 Divide Single
		FDIVd,	// 001001110 Divide Double
		FDIVq,	// 001001111 Divide Quad

		//Floating-point Compare  
		//opcode opf operation
		//Fpop2
		FCMPs,	// 001010001 Compare Single
		FCMPd,	// 001010010 Compare Double
		FCMPq,	// 001010011 Compare Quad
		FCMPEs,	// 001010101 Compare Single and Exception if Unordered
		FCMPEd,	// 001010110 Compare Double and Exception if Unordered
		FCMPEq,	// 001010111 Compare Quad and Exception if Unordered

		//Coprocessor Operate
		   
		CPop1,	// 110110 Coprocessor Operate
		CPop2,	// 110111 Coprocessor Operate
		unimplemented,	//I dunno what this means as of now: it appears in the instruction-format-section in the manual
		unassigned	//causes an exception


};



std::string printOpcode(Opcode op); //return a string for the opcode name




//Some useful functions to identify instruction groups used by Sparc Core

inline bool isFBfccInstruction(Opcode op)
{
	return(op>=FBA and op<=FBO);
};


inline bool isMemoryInstruction(Opcode op)
{
	return((op>=LDSB and op<=SWAPA) or(op==FLUSH) or(op==STBAR));
};
inline bool isBranchInstruction(Opcode op)
{
	return(op==CALL or op==RETT or op==JMPL or (op>=BA && op<=BVS) or isFBfccInstruction(op) or op==CBccc or (op>=TA && op<=TVS));
};
inline bool isLoadInstruction(Opcode op)
{
	return(op>=LDSB && op<=LDCSR);
};
inline bool isDoubleLoadInstruction(Opcode op)
{
	return(op==LDD or op==LDDA or op==LDDF or op==LDDC);

};
inline bool isStoreInstruction(Opcode op)
{
	return(op>=STB && op<=STDCQ);
};
inline bool isDoubleStoreInstruction(Opcode op)
{
	return(op==STD or op==STDA or op==STDF or op==STDFQ or op==STDCQ);
};
inline bool isLoadStoreAtomicInstruction(Opcode op)
{
	return(op>=LDSTUB and op<=SWAPA);
};



inline bool isFpop1Instruction(Opcode op)
{
	return(op>=FiTOs and op<=FDIVq);
};

inline bool isFpop2Instruction(Opcode op)
{
	return(op>=FCMPs and op<=FCMPEq);
};

inline bool isFloatingPointInstruction(Opcode op)
{

	return( (op>=FBA and op<=FBO) or (op>=FiTOs and op<=FCMPEq));
};
#endif


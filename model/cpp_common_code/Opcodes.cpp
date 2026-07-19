//Opcodes.cpp

#include"Opcodes.h"

//202 Opcodes in total


std::string printOpcode(Opcode op)
{
	switch(op)
	{

		//Load
		case LDSB: return "LDSB";	// 001001 Load Signed Byte
		case LDSH: return "LDSH";	// 001010 Load Signed Halfword
		case LDUB: return "LDUB";	// 000001 Load Unsigned Byte
		case LDUH: return "LDUH";	// 000010 Load Unsigned Halfword
		case LD: return "LD";	// 000000 Load Word
		case LDD: return "LDD";	// 000011 Load Doubleword
		case LDSBA: return "LDSBA";	//† 011001 Load Signed Byte from Alternate space
		case LDSHA: return "LDSHA";	//† 011010 Load Signed Halfword from Alternate space
		case LDUBA: return "LDUBA";	//† 010001 Load Unsigned Byte from Alternate space
		case LDUHA: return "LDUHA";	//† 010010 Load Unsigned Halfword from Alternate space
		case LDA: return "LDA";	//† 010000 Load Word from Alternate space
		case LDDA: return "LDDA";	//† 010011 Load Doubleword from Alternate space
		case LDF: return "LDF";	// 100000 Load Floating-point Register
		case LDDF: return "LDDF";	// 100011 Load Double Floating-point Register
		case LDFSR: return "LDFSR";	// 100001 Load Floating-point State Register
		case LDC: return "LDC";	// 110000 Load Coprocessor Register
		case LDDC: return "LDDC";	// 110011 Load Double Coprocessor Register
		case LDCSR: return "LDCSR";	// 110001 Load Coprocessor State Register


		//Store
		case STB: return "STB";	// 000101 Store Byte
		case STH: return "STH";	// 000110 Store Halfword
		case ST: return "ST";	// 000100 Store Word
		case STD: return "STD";	// 000111 Store Doubleword
		case STBA: return "STBA";	//† 010101 Store Byte into Alternate space
		case STHA: return "STHA";	//† 010110 Store Halfword into Alternate space
		case STA: return "STA";	//† 010100 Store Word into Alternate space
		case STDA: return "STDA";	//† 010111 Store Doubleword into Alternate space
		case STF: return "STF";	// 100100 Store Floating-point
		case STDF: return "STDF";	// 100111 Store Double Floating-point
		case STFSR: return "STFSR";	// 100101 Store Floating-point State Register
		case STDFQ: return "STDFQ";	//† 100110 Store Double Floating-point deferred-trap Queue

		case STC: return "STC";	// 110100 Store Coprocessor
		case STDC: return "STDC";	// 110111 Store Double Coprocessor
		case STCSR: return "STCSR";	// 110101 Store Coprocessor State Register
		case STDCQ: return "STDCQ";	//† 110110 Store Double Coprocessor Queue

		//Atomic Load/Store
		case LDSTUB: return "LDSTUB";	// 001101 Atomic Load-Store Unsigned Byte
		case LDSTUBA: return "LDSTUBA";//† 011101 Atomic Load-Store Unsigned Byte into Alternate space


		//SWAP Register with case Memory: return "Memory";
		case SWAP: return "SWAP";	// 001111 SWAP register with memory
		case SWAPA: return "SWAPA";	//† 011111 SWAP register with Alternate space memory

		//SETHI Instruction
		case SETHI: return "SETHI";	// 00 100 Set High-Order 22 bits

		//NOP Instruction
		case NOP: return "NOP";	// 00 100 No Operation




		//Logical   
		case AND: return "AND";	// 000001 And
		case ANDcc: return "ANDcc";	// 010001 And and modify icc
		case ANDN: return "ANDN";	// 000101 And Not
		case ANDNcc: return "ANDNcc";	// 010101 And Not and modify icc
		case OR: return "OR";	// 000010 Inclusive Or
		case ORcc: return "ORcc";	// 010010 Inclusive Or and modify icc
		case ORN: return "ORN";	// 000110 Inclusive Or Not
		case ORNcc: return "ORNcc";	// 010110 Inclusive Or Not and modify icc
		case XOR: return "XOR";	// 000011 Exclusive Or
		case XORcc: return "XORcc";	// 010011 Exclusive Or and modify icc
		case XNOR: return "XNOR";	// 000111 Exclusive Nor
		case XNORcc: return "XNORcc";	// 010111 Exclusive Nor and modify icc

		//Shift  
		case SLL: return "SLL";	// 100101 Shift Left Logical
		case SRL: return "SRL";	// 100110 Shift Right Logical
		case SRA: return "SRA";	// 100111 Shift Right Arithmetic

		//Add  
		 
		case ADD: return "ADD";	// 000000 Add
		case ADDcc: return "ADDcc";	// 010000 Add and modify icc
		case ADDX: return "ADDX";	// 001000 Add with Carry
		case ADDXcc: return "ADDXcc";	// 011000 Add with Carry and modify icc

		//Tagged Add
		   
		case TADDcc: return "TADDcc";	// 100000 Tagged Add and modify icc
		case TADDccTV: return "TADDccTV";// 100010 Tagged case Add: return "Add"; modify icc and Trap on Overflow


		//Subtract  
		 
		case SUB: return "SUB";	// 000100 Subtract
		case SUBcc: return "SUBcc";	// 010100 Subtract and modify icc
		case SUBX: return "SUBX";	// 001100 Subtract with Carry
		case SUBXcc: return "SUBXcc";	// 011100 Subtract with Carry and modify icc

		//Tagged Subtract
		   
		case TSUBcc: return "TSUBcc";	// 100001 Tagged Subtract and modify icc
		case TSUBccTV: return "TSUBccTV";	// 100011 Tagged case Subtract: return "Subtract"; modify icc and Trap on Overflow

		//Multiply Step
		case MULScc: return "MULScc";	// 100100 Multiply Step and modify iccif

		//Multiply  
		 
		case UMUL: return "UMUL";	// 001010 Unsigned Integer Multiply
		case SMUL: return "SMUL";	// 001011 Signed Integer Multiply
		case UMULcc: return "UMULcc";	// 011010 Unsigned Integer Multiply and modify icc
		case SMULcc: return "SMULcc";	// 011011 Signed Integer Multiply and modify icc

		//Divide  
		 
		case UDIV: return "UDIV";	// 001110 Unsigned Integer Divide
		case SDIV: return "SDIV";	// 001111 Signed Integer Divide
		case UDIVcc: return "UDIVcc";	// 011110 Unsigned Integer Divide and modify icc
		case SDIVcc: return "SDIVcc";	// 011111 Signed Integer Divide and modify icc


		//SAVE and RESTORE  
		 
		case SAVE: return "SAVE";	// 111100 Save caller’s window
		case RESTORE: return "RESTORE";	// 111101 Restore caller’s window


		//Branch on Integer Condition Codes  
		//opcode cond operation icc test
		case BA: return "BA";	// 1000 Branch Always 1
		case BN: return "BN";	// 0000 Branch Never 0
		case BNE: return "BNE";	// 1001 Branch on Not Equal not Z
		case BE: return "BE";	// 0001 Branch on Equal Z
		case BG: return "BG";	// 1010 Branch on Greater not (Z or (N xor V))
		case BLE: return "BLE";	// 0010 Branch on Less or Equal Z or (N xor V)
		case BGE: return "BGE";	// 1011 Branch on Greater or Equal not (N xor V)
		case BL: return "BL";	// 0011 Branch on Less N xor V
		case BGU: return "BGU";	// 1100 Branch on Greater Unsigned not (C or Z)
		case BLEU: return "BLEU";	// 0100 Branch on Less or Equal Unsigned (C or Z)
		case BCC: return "BCC";	// 1101 Branch on Carry Clear (Greater than or case Equal: return "Equal"; Unsigned) not C
		case BCS: return "BCS";	// 0101 Branch on Carry Set (Less case than: return "than"; Unsigned) C
		case BPOS: return "BPOS";	// 1110 Branch on Positive not N
		case BNEG: return "BNEG";	// 0110 Branch on Negative N
		case BVC: return "BVC";	// 1111 Branch on Overflow Clear not V
		case BVS: return "BVS";	// 0111 Branch on Overflow Set V

		//Branch on Floatingpoint
		//Condition
		//Codes  
		//opcode cond operation fcc test
		case FBA: return "FBA";	// 1000 Branch Always 1
		case FBN: return "FBN";	// 0000 Branch Never 0
		case FBU: return "FBU";	// 0111 Branch on Unordered U
		case FBG: return "FBG";	// 0110 Branch on Greater G
		case FBUG: return "FBUG";	// 0101 Branch on Unordered or Greater G or U
		case FBL: return "FBL";	// 0100 Branch on Less L
		case FBUL: return "FBUL";	// 0011 Branch on Unordered or Less L or U
		case FBLG: return "FBLG";	// 0010 Branch on Less or Greater L or G
		case FBNE: return "FBNE";	// 0001 Branch on Not Equal L or G or U
		case FBE: return "FBE";	// 1001 Branch on Equal E
		case FBUE: return "FBUE";	// 1010 Branch on Unordered or Equal E or U
		case FBGE: return "FBGE";	// 1011 Branch on Greater or Equal E or G
		case FBUGE: return "FBUGE";	// 1100 Branch on Unordered or Greater or Equal E or G or U
		case FBLE: return "FBLE";	// 1101 Branch on Less or Equal E or L
		case FBULE: return "FBULE";	// 1110 Branch on Unordered or Less or Equal E or L or U
		case FBO: return "FBO";	// 1111 Branch on Ordered E or L or G


		//Branch on
		//Coprocessor
		//Condition Codes
		 
		//opcode cond bp_CP_cc[1:0] test
		case CBA: return "CBA";	// 1000 Always
		case CBN: return "CBN";	// 0000 Never
		case CB3: return "CB3";	// 0111 3
		case CB2: return "CB2";	// 0110 2
		case CB23: return "CB23";	// 0101 2 or 3
		case CB1: return "CB1";	// 0100 1
		case CB13: return "CB13";	// 0011 1 or 3
		case CB12: return "CB12";	// 0010 1 or 2
		case CB123: return "CB123";	// 0001 1 or 2 or 3
		case CB0: return "CB0";	// 1001 0
		case CB03: return "CB03";	// 1010 0 or 3
		case CB02: return "CB02";	// 1011 0 or 2
		case CB023: return "CB023";	// 1100 0 or 2 or 3
		case CB01: return "CB01";	// 1101 0 or 1
		case CB013: return "CB013";	// 1110 0 or 1 or 3
		case CB012: return "CB012";	// 1111 0 or 1 or 2


		//Call and Link
		//Instruction opcode op operation
		case CALL: return "CALL";	// 01 Call and Link


		//Jump and Link
		//Instruction  
		case JMPL: return "JMPL";	// 111000 Jump and Link

		//Return from Trap
		//Instruction  
		case RETT: return "RETT";	//† 111001 Return from Trap

		//Trap on Integer Condition Codes Instruction
		//opcode cond operation icc test
		case TA: return "TA";	// 1000 Trap Always 1
		case TN: return "TN";	// 0000 Trap Never 0
		case TNE: return "TNE";	// 1001 Trap on Not Equal not Z
		case TE: return "TE";	// 0001 Trap on Equal Z
		case TG: return "TG";	// 1010 Trap on Greater not (Z or (N xor V))
		case TLE: return "TLE";	// 0010 Trap on Less or Equal Z or (N xor V)
		case TGE: return "TGE";	// 1011 Trap on Greater or Equal not (N xor V)
		case TL: return "TL";	// 0011 Trap on Less N xor V
		case TGU: return "TGU";	// 1100 Trap on Greater Unsigned not (C or Z)
		case TLEU: return "TLEU";	// 0100 Trap on Less or Equal Unsigned (C or Z)
		case TCC: return "TCC";	// 1101 Trap on Carry Clear (Greater than or case Equal: return "Equal"; Unsigned) not C
		case TCS: return "TCS";	// 0101 Trap on Carry Set (Less case Than: return "Than"; Unsigned) C
		case TPOS: return "TPOS";	// 1110 Trap on Positive not N
		case TNEG: return "TNEG";	// 0110 Trap on Negative N
		case TVC: return "TVC";	// 1111 Trap on Overflow Clear not V
		case TVS: return "TVS";	// 0111 Trap on Overflow Set V

		//Read State Register  
		//opcode op3 rs1 operation
		case RDY: return "RDY";	// 101000 0 Read Y Register
		case RDASR: return "RDASR";	//‡ 101000 1 - 15 Read Ancillary State Register (reserved)
		//case RDASR: return "RDASR";	//‡ 101000 16 - 31 (implementation-dependent)
		case RDPSR: return "RDPSR";	//† 101001 reserved Read Processor State Register
		case RDWIM: return "RDWIM";	//† 101010 reserved Read Window Invalid Mask Register
		case RDTBR: return "RDTBR";	//† 101011 reserved Read Trap Base Register

		//Write State Register  
		//opcode op3 rd operation
		case WRY: return "WRY";	// 110000 0 Write Y Register
		case WRASR: return "WRASR";	//‡ 110000 1 - 15 Write Ancillary State Register (reserved)
		//case WRASR: return "WRASR";	//‡ 110000 16 - 31 (implementation-dependent)
		case WRPSR: return "WRPSR";	//† 110001 reserved Write Processor State Register
		case WRWIM: return "WRWIM";	//† 110010 reserved Write Window Invalid Mask Register
		case WRTBR: return "WRTBR";	//† 110011 reserved Write Trap Base Register

		//STBAR Instruction
		case STBAR: return "STBAR";	// 101000 Store Barrier

		//Unimplemented Instruction 
		//opcode op op2 operation
		case UNIMP: return "UNIMP";	// 00 000 Unimplemented

		//Flush Instruction
		//Memory  
		case FLUSH: return "FLUSH";	// 111011 Flush Instruction Memory



		//Floating-point
		//Operate (FPop)
		 
		 
		//case FPop1: return "FPop1";	// 110100 Floating-point operate
		//case FPop2: return "FPop2";	// 110101 Floating-point operate

		//Convert Integer to Floating
		//point   opcode opf operation
		case FiTOs: return "FiTOs";	// 011000100 Convert Integer to Single
		case FiTOd: return "FiTOd";	// 011001000 Convert Integer to Double
		case FiTOq: return "FiTOq";	// 011001100 Convert Integer to Quad


		////Convert Floating point to
		//Integer   opcode opf operation
		case FsTOi: return "FsTOi";	// 011010001 Convert Single to Integer
		case FdTOi: return "FdTOi";	// 011010010 Convert Double to Integer
		case FqTOi: return "FqTOi";	// 011010011 Convert Quad to Integer

		//Convert Between Floatingpoint
		//Formats   opcode opf operation
		case FsTOd: return "FsTOd";	// 011001001 Convert Single to Double
		case FsTOq: return "FsTOq";	// 011001101 Convert Single to Quad
		case FdTOs: return "FdTOs";	// 011000110 Convert Double to Single
		case FdTOq: return "FdTOq";	// 011001110 Convert Double to Quad
		case FqTOs: return "FqTOs";	// 011000111 Convert Quad to Single
		case FqTOd: return "FqTOd";	// 011001011 Convert Quad to Double
		
		


		//Floating-point Move
		//  opcode opf operation
		case FMOVs: return "FMOVs";	// 000000001 Move
		case FNEGs: return "FNEGs";	// 000000101 Negate
		case FABSs: return "FABSs";	// 000001001 Absolute Value

		//Floating-point Square Root
		//  opcode opf operation
		case FSQRTs: return "FSQRTs";	// 000101001 Square Root Single
		case FSQRTd: return "FSQRTd";	// 000101010 Square Root Double
		case FSQRTq: return "FSQRTq";	// 000101011 Square Root Quad


		//Floating-point Add and
		//Subtract   opcode opf operation
		case FADDs: return "FADDs";	// 001000001 Add Single
		case FADDd: return "FADDd";	// 001000010 Add Double
		case FADDq: return "FADDq";	// 001000011 Add Quad
		case FSUBs: return "FSUBs";	// 001000101 Subtract Single
		case FSUBd: return "FSUBd";	// 001000110 Subtract Double
		case FSUBq: return "FSUBq";	// 001000111 Subtract Quad


		//Floating-point Multiply and Divide  
		//opcode opf operation
		case FMULs: return "FMULs";	// 001001001 Multiply Single
		case FMULd: return "FMULd";	// 001001010 Multiply Double
		case FMULq: return "FMULq";	// 001001011 Multiply Quad
		case FsMULd: return "FsMULd";	// 001101001 Multiply Single to Double
		case FdMULq: return "FdMULq";	// 001101110 Multiply Double to Quad
		case FDIVs: return "FDIVs";	// 001001101 Divide Single
		case FDIVd: return "FDIVd";	// 001001110 Divide Double
		case FDIVq: return "FDIVq";	// 001001111 Divide Quad

		//Floating-point Compare  
		//opcode opf operation
		case FCMPs: return "FCMPs";	// 001010001 Compare Single
		case FCMPd: return "FCMPd";	// 001010010 Compare Double
		case FCMPq: return "FCMPq";	// 001010011 Compare Quad
		case FCMPEs: return "FCMPEs";	// 001010101 Compare Single and Exception if Unordered
		case FCMPEd: return "FCMPEd";	// 001010110 Compare Double and Exception if Unordered
		case FCMPEq: return "FCMPEq";	// 001010111 Compare Quad and Exception if Unordered

		//Coprocessor Operate
		   
		case CPop1: return "CPop1";	// 110110 Coprocessor Operate
		case CPop2: return "CPop2";	// 110111 Coprocessor Operate
		case unimplemented: return "unimplemented"; //I dunno what this means as of now: it appears in the instruction-format-section in the manual
		default: return "NOT DECODED!!!!!!";


	};
};






		
	

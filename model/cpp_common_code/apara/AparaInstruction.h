//AparaInstruction.h
//Original author: Madhav Desai, IITB
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the APARA engine specification and
//reference C implementation developed by Prof. Madhav Desai, IITB
//
//One decoded APARA instruction, and the decoder from a 32-bit word.
//
//Instruction word (Ref the APARA ISA, engine_isp/isa/
//FINAL_INSTRUCTION_FORMATS.TXT): bit 31 marks the first instruction of
//a bundle, bits [30:26] are the opcode, and the rest depend on the
//instruction class. The field layouts here are the reference assembler's
//own (McodeBinaryCode.cpp), so that its object files decode unchanged:
//
//  ALU      type[25:21] rd[20:16] rs1[15:11] imm[10] rs2[4:0] | imm10[9:0]
//  VALU     (an ALU opcode with a vector type) replicate in bit 10
//  DOT      type rd rs1 accumulate[10] rs2
//  FSQRT    type rd rs1
//  VREDUCE  type rd rs1 subop[10:6]
//  CAST     dest-type[25:21] rd src-type[14:10] rs2
//  CMOV     type rd rs1 cond[10:8] incr[7:6] rs2
//  PACK     rd log2(packed)[15:12] log2(word)[11:9] rs2
//  SET      byte-index[23:21] rd value16[15:0]
//  SLICE    high[5:1] in [25:21] rd high[0] in [15] low[14:9] rs2
//  LOAD/STORE type rd rs1 imm[10] incr[9:5] rs2 | imm10[9:0]
//  BRANCH   type[25:22] cond[21:19] incr[18:17] jump12[16:5] rs2
//  CALL     imm[25] jump25[24:0] | rs2
//  RETURN, NULL, NOP, HALT: no operands
//
//Signed fields (immediates, increments, jumps) are sign-extended. CMOV's
//2-bit increment is sign-extended too (the reference decoder does not,
//so its "decrement by 1" becomes +3: a documented deviation).

#ifndef APARA_INSTRUCTION_H
#define APARA_INSTRUCTION_H

#include <stdint.h>
#include <string>
#include "AparaTypes.h"

namespace apara
{
	enum class Opcode : uint8_t
	{
		NOP = 0x00, CALL = 0x01, BRANCH = 0x02, RETURN = 0x03,
		ADD = 0x04, SUB = 0x05, MUL = 0x06, DIV = 0x07,
		OR = 0x08, AND = 0x09, XOR = 0x0A, NOR = 0x0B, NAND = 0x0C, XNOR = 0x0D,
		SHL = 0x0E, SHR = 0x0F,
		FSQRT = 0x10, DOT = 0x11, CAST = 0x12, LOAD = 0x13, STORE = 0x14,
		SET = 0x15, VREDUCE = 0x16, CMOV = 0x17, PACK = 0x18, SLICE = 0x19,
		NULL_OP = 0x1A, HALT = 0x1B
	};

	//Branch and CMOV conditions, compared against 0.
	enum class Condition : uint8_t { ALWAYS = 0, EQ = 1, GT = 2, LT = 3, GE = 4, LE = 5, NE = 6, NEVER = 7 };

	//What an instruction is, for the bundle slot rules and the timing model.
	enum class InstructionClass : uint8_t
	{
		NONE,       //NOP, NULL
		ALU,        //scalar integer/float arithmetic and logic, SET, SLICE, PACK, CMOV
		VECTOR,     //VALU, VREDUCE
		DOT,
		CAST,
		DIVIDE,     //DIV, FSQRT (the shared divide/square-root unit)
		MEMORY,     //LOAD, STORE
		CONTROL,    //BRANCH, CALL, RETURN
		HALT
	};

	struct Instruction
	{
		uint32_t word        = 0;
		bool     bundleStart = false;
		bool     valid       = false;
		Opcode   opcode      = Opcode::NOP;
		InstructionClass klass = InstructionClass::NONE;

		uint8_t  rd = 0, rs1 = 0, rs2 = 0;
		Type     type;          //source type (ALU, VALU, DOT, FSQRT, VREDUCE), test type (BRANCH, CMOV),
		                        //transfer type (LOAD, STORE), destination type (CAST)
		Type     castSource;    //CAST only
		Type     destType;      //result type, inferred from `type` as the reference model does
		bool     isVector    = false; //an ALU opcode with a vector type: VALU

		bool     immediate   = false; //ALU, LOAD, STORE: imm form. CALL: label form.
		int32_t  immValue    = 0;     //sign-extended imm10
		int32_t  increment   = 0;     //auto-increment (LOAD/STORE: elements, BRANCH/CMOV: added to rs2)
		int32_t  jump        = 0;     //BRANCH/CALL: PC-relative, in instruction words
		Condition condition  = Condition::ALWAYS;
		bool     flag        = false; //DOT accumulate, VALU replicate
		Opcode   subOpcode   = Opcode::ADD; //VREDUCE
		uint16_t packedBits  = 0, wordBits = 0; //PACK
		uint8_t  sliceHigh   = 0, sliceLow = 0; //SLICE
		uint8_t  setByteIndex = 0;   //SET
		uint16_t setValue    = 0;    //SET

		static Instruction decode(uint32_t word);

		//A bundle holding one of these must be a full 8-slot bundle.
		bool needsFullBundle() const
		{
			return klass == InstructionClass::CONTROL || klass == InstructionClass::MEMORY
			       || opcode == Opcode::DIV || opcode == Opcode::FSQRT;
		}
		bool isControl() const { return klass == InstructionClass::CONTROL; }

		//Registers this instruction reads and writes, as bit masks (bit i
		//= register i), for the register-file lock model.
		uint32_t readMask() const;
		uint32_t writeMask() const;

		//As assembly text (close to the reference disassembler's).
		std::string toString() const;

		//Number of 64-bit registers a LOAD writes or a STORE reads.
		unsigned int transferRegisters() const { return type.bits <= 64 ? 1 : type.bits / 64; }
		unsigned int transferBytes() const { return type.bits / 8; }

	private:
		bool checkValidity() const;
	};

	std::string opcodeName(Opcode op);
}

#endif

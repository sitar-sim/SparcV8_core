//AparaOperations.h
//
//The value computations of the APARA instructions, as pure functions of
//operand values (no engine state). AparaCore calls these; the unit tests
//call them directly.
//
//Register value conventions (as the reference model's):
//  - A scalar narrower than 64 bits lives in the low bits of a register.
//    Signed operations sign-extend their operands from the type's width;
//    unsigned integer operations use the full 64-bit register values.
//  - Integer ALU results are 64-bit. Float results are in the type's
//    format, in the low bits.
//  - A vector packs 64/width elements per register, element 0 in the
//    most significant bits.

#ifndef APARA_OPERATIONS_H
#define APARA_OPERATIONS_H

#include <stdint.h>
#include "AparaTypes.h"
#include "AparaInstruction.h"

namespace apara
{
	//Exception codes, as written into a slot's 3 bits of ERROR.
	//(Deviation: the reference reports these as messages and continues.)
	enum class ExceptionCode : uint8_t
	{
		NONE            = 0,
		INT_DIV_ZERO    = 1, //integer division by zero
		FLOAT_DIV_ZERO  = 2, //float division by zero
		FLOAT_NAN       = 3, //a float arithmetic result is not a number
		                     //4 is reserved
		FLOAT_SQRT_NEG  = 5, //square root of a negative float
		UNALIGNED       = 6, //memory address not a multiple of the transfer size
		ILLEGAL         = 7  //undefined instruction, or no valid bundle at the PC (slot 0)
	};
	std::string exceptionName(ExceptionCode c);

	struct OpResult
	{
		uint64_t      value[4] = {0, 0, 0, 0};
		unsigned int  count    = 1;           //result registers
		ExceptionCode exception = ExceptionCode::NONE;
	};

	//Element i (0 = most significant) of a vector register.
	inline uint64_t element(uint64_t reg, unsigned int bits, unsigned int i)
	{
		unsigned int n = 64 / bits;
		return (reg >> ((n - 1 - i) * bits)) & lowMask(bits);
	}

	//An element value widened to 64 bits: sign-extended for signed types,
	//as is for unsigned and float types.
	inline uint64_t widen(const Type& t, uint64_t v)
	{
		v &= lowMask(t.bits);
		return t.isSigned() ? signExtend(v, t.bits) : v;
	}

	//Scalar ALU: ADD..SHR on (a, b) of type t.
	OpResult scalarAlu(Opcode op, const Type& t, uint64_t a, uint64_t b);
	//Element-wise vector ADD, SUB, MUL. With replicate, b's low element is
	//used for every element.
	OpResult vectorAlu(Opcode op, const Type& t, uint64_t a, uint64_t b, bool replicate);
	OpResult squareRoot(const Type& t, uint64_t a);
	OpResult dot(const Type& t, uint64_t a, uint64_t b, bool accumulate, uint64_t acc);
	OpResult vectorReduce(Opcode subOp, const Type& t, uint64_t a);
	//CAST from `src` (the source registers in[0..]) to `dst`.
	OpResult cast(const Type& dst, const Type& src, const uint64_t* in, unsigned int inCount);
	OpResult pack(unsigned int packedBits, unsigned int wordBits, const uint64_t* in, unsigned int inCount);
	uint64_t slice(uint64_t v, unsigned int high, unsigned int low);

	//Branch and CMOV conditions: v of type t compared with 0. Signed
	//integers compare as values of the type's width, unsigned integers as
	//64-bit unsigned values, floats by value (a NaN satisfies only "!=" and
	//"always"). Deviations: the reference compares an unsigned value as a
	//signed 64-bit one, and a float's sign-extended bit pattern.
	bool conditionHolds(Condition c, const Type& t, uint64_t v);
}

#endif

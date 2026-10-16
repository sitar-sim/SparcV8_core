//AparaTypes.h
//Original author: Madhav Desai, IITB
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the APARA engine specification and
//reference C implementation developed by Prof. Madhav Desai, IITB
//
//The APARA engine's data types and number formats.
//
//Every instruction that operates on data names a type with a 5-bit code
//(Ref the APARA ISA, engine_isp/isa/isa.txt in the APARA repository).
//A type is an element width (4 to 256 bits) and three flags: unsigned,
//float, and vector. A vector type packs 64/width elements into one
//64-bit register, element 0 in the most significant bits.
//
//The narrow float formats follow the APARA reference model
//(McodeMachine's McodeFpuUtils.cpp), which this file reimplements:
//  f4  E2M1: 3 magnitude codes {0, 0.5, 1, 1.5, 2, 3, inf, nan}, no
//      subnormals, the sign in bit 3;
//  f8  E4M3, bias 7;
//  f16 E5M10, bias 15 (IEEE half precision layout);
//  f32, f64: IEEE single and double.
//Arithmetic on narrow floats is done in double precision, then rounded
//back with the same conversion rules as the reference model: a single
//round bit (round half up on magnitude), saturation to infinity on
//overflow, and flush to zero below the smallest subnormal.

#ifndef APARA_TYPES_H
#define APARA_TYPES_H

#include <stdint.h>
#include <string>

namespace apara
{
	enum class TypeCode : uint8_t
	{
		I4 = 0x00, I8 = 0x01, I16 = 0x02, I32 = 0x03, I64 = 0x04,
		U4 = 0x05, U8 = 0x06, U16 = 0x07, U32 = 0x08, U64 = 0x09,
		F4 = 0x0A, F8 = 0x0B, F16 = 0x0C, F32 = 0x0D, F64 = 0x0E,
		U128 = 0x0F, U256 = 0x10,
		VU4 = 0x11, VU8 = 0x12, VU16 = 0x13, VU32 = 0x14,
		VF4 = 0x15, VF8 = 0x16, VF16 = 0x17, VF32 = 0x18,
		VI4 = 0x19, VI8 = 0x1A, VI16 = 0x1B, VI32 = 0x1C
	};

	struct Type
	{
		uint16_t bits      = 0; //element width
		bool     isUnsigned = false;
		bool     isFloat    = false;
		bool     isVector   = false;
		TypeCode code       = TypeCode::I4;
		bool     valid      = false;

		//From a 5-bit code. `valid` is false for codes 0x1D..0x1F.
		static Type fromCode(uint32_t code5);

		bool isSigned() const { return !isUnsigned && !isFloat; }
		//Elements per 64-bit register (1 for a scalar of 64 bits or more).
		unsigned int elementsPerRegister() const { return bits >= 64 ? 1 : 64 / bits; }

		//As written in assembly, e.g. "$vi8", "$f32".
		std::string name() const;
	};

	//A mask of the low `bits` bits (bits 1..64).
	inline uint64_t lowMask(unsigned int bits) { return bits >= 64 ? ~0ULL : ((1ULL << bits) - 1); }

	//Sign-extends x from bit (bits - 1).
	inline uint64_t signExtend(uint64_t x, unsigned int bits)
	{
		if (bits >= 64) return x;
		uint64_t m = 1ULL << (bits - 1);
		x &= lowMask(bits);
		return (x ^ m) - m;
	}

	//Number formats.
	double   floatToDouble(unsigned int bits, uint64_t value);
	uint64_t doubleToFloat(unsigned int bits, double value);
}

#endif

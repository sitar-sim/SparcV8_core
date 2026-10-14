//AparaTypes.cpp

#include "AparaTypes.h"
#include <cmath>
#include <cstring>

namespace apara
{

Type Type::fromCode(uint32_t code5)
{
	Type t;
	t.code  = (TypeCode) (code5 & 0x1F);
	t.valid = true;
	switch (code5 & 0x1F)
	{
		case 0x00: t.bits = 4;   break;
		case 0x01: t.bits = 8;   break;
		case 0x02: t.bits = 16;  break;
		case 0x03: t.bits = 32;  break;
		case 0x04: t.bits = 64;  break;
		case 0x05: t.bits = 4;   t.isUnsigned = true; break;
		case 0x06: t.bits = 8;   t.isUnsigned = true; break;
		case 0x07: t.bits = 16;  t.isUnsigned = true; break;
		case 0x08: t.bits = 32;  t.isUnsigned = true; break;
		case 0x09: t.bits = 64;  t.isUnsigned = true; break;
		case 0x0A: t.bits = 4;   t.isFloat = true; break;
		case 0x0B: t.bits = 8;   t.isFloat = true; break;
		case 0x0C: t.bits = 16;  t.isFloat = true; break;
		case 0x0D: t.bits = 32;  t.isFloat = true; break;
		case 0x0E: t.bits = 64;  t.isFloat = true; break;
		case 0x0F: t.bits = 128; t.isUnsigned = true; break;
		case 0x10: t.bits = 256; t.isUnsigned = true; break;
		case 0x11: t.bits = 4;   t.isUnsigned = true; t.isVector = true; break;
		case 0x12: t.bits = 8;   t.isUnsigned = true; t.isVector = true; break;
		case 0x13: t.bits = 16;  t.isUnsigned = true; t.isVector = true; break;
		case 0x14: t.bits = 32;  t.isUnsigned = true; t.isVector = true; break;
		case 0x15: t.bits = 4;   t.isFloat = true; t.isVector = true; break;
		case 0x16: t.bits = 8;   t.isFloat = true; t.isVector = true; break;
		case 0x17: t.bits = 16;  t.isFloat = true; t.isVector = true; break;
		case 0x18: t.bits = 32;  t.isFloat = true; t.isVector = true; break;
		case 0x19: t.bits = 4;   t.isVector = true; break;
		case 0x1A: t.bits = 8;   t.isVector = true; break;
		case 0x1B: t.bits = 16;  t.isVector = true; break;
		case 0x1C: t.bits = 32;  t.isVector = true; break;
		default:   t.valid = false; break;
	}
	return t;
}

std::string Type::name() const
{
	std::string s = "$";
	if (isVector) s += "v";
	s += isFloat ? "f" : (isUnsigned ? "u" : "i");
	return s + std::to_string(bits);
}

//----------------------------------------------------------------------
//Number formats (Ref this file's header comment)
//----------------------------------------------------------------------

namespace
{
	uint64_t doubleBits(double d) { uint64_t b; std::memcpy(&b, &d, 8); return b; }
	double   bitsToDouble(uint64_t b) { double d; std::memcpy(&d, &b, 8); return d; }

	const uint64_t F64_EXP_ALL_ONES = 0x7FF;
	const uint64_t F64_MANTISSA_MASK = (1ULL << 52) - 1;

	double infinity() { return bitsToDouble(F64_EXP_ALL_ONES << 52); }
	double notANumber() { return bitsToDouble((F64_EXP_ALL_ONES << 52) | F64_MANTISSA_MASK); }

	double f4ToDouble(uint64_t v)
	{
		static const double magnitude[6] = {0.0, 0.5, 1.0, 1.5, 2.0, 3.0};
		unsigned int m = v & 0x7;
		double value = (m < 6) ? magnitude[m] : (m == 6 ? infinity() : notANumber());
		return (v & 0x8) ? -value : value;
	}

	//f8 (E4M3, bias 7) and f16 (E5M10, bias 15): exponent all ones is
	//infinity/NaN, exponent 0 is zero/subnormal.
	double narrowToDouble(uint64_t v, unsigned int expBits, unsigned int manBits, int bias, double subnormalUnit)
	{
		unsigned int width = 1 + expBits + manBits;
		uint64_t sign = (v >> (width - 1)) & 1;
		uint64_t e = (v >> manBits) & ((1u << expBits) - 1);
		uint64_t m = v & ((1u << manBits) - 1);
		if (e == 0)
		{
			double value = m * subnormalUnit;
			return sign ? -value : value;
		}
		uint64_t exp64 = (e == ((1u << expBits) - 1)) ? F64_EXP_ALL_ONES : (uint64_t) ((int64_t) e - bias + 1023);
		return bitsToDouble((sign << 63) | (exp64 << 52) | (m << (52 - manBits)));
	}

	uint64_t doubleToF4(double d)
	{
		uint64_t b = doubleBits(d);
		uint64_t sign = (b >> 60) & 0x8;
		if (((b >> 52) & F64_EXP_ALL_ONES) == F64_EXP_ALL_ONES)
			return sign | 0x6 | ((b & F64_MANTISSA_MASK) ? 1 : 0);
		double a = std::fabs(d);
		uint64_t code;
		if      (a <= 0.25) code = 0; //0.0
		else if (a < 0.75)  code = 1; //0.5
		else if (a <= 1.25) code = 2; //1.0
		else if (a < 1.75)  code = 3; //1.5
		else if (a <= 2.5)  code = 4; //2.0
		else if (a < 3.5)   code = 5; //3.0
		else                code = 6; //infinity
		return sign | code;
	}

	//f8 and f16 from double: one round bit (round half up on the
	//magnitude), saturate to infinity on overflow, subnormals rounded the
	//same way but clamped at the largest subnormal mantissa, flushed to
	//zero below them. Exactly the reference model's rules, including its
	//maxNormalExp (8 for f8, 15 for f16) and minSubnormalExp (-9, -25).
	uint64_t doubleToNarrow(double d, unsigned int expBits, unsigned int manBits, int bias,
	                        int maxNormalExp, int minSubnormalExp)
	{
		unsigned int width = 1 + expBits + manBits;
		uint64_t b = doubleBits(d);
		uint64_t sign = ((b >> 63) & 1) << (width - 1);
		uint64_t e64 = (b >> 52) & F64_EXP_ALL_ONES;
		uint64_t m64 = b & F64_MANTISSA_MASK;
		uint64_t expAllOnes = ((1u << expBits) - 1) << manBits;
		uint64_t manMax = (1u << manBits) - 1;

		if (e64 == F64_EXP_ALL_ONES)
		{
			uint64_t m = m64 >> (52 - manBits);
			if (m == 0 && m64 != 0) m = 1;
			return sign | expAllOnes | m;
		}
		int realExp = (int) e64 - 1023;
		if (realExp > maxNormalExp)
			return sign | expAllOnes;
		int minNormalExp = 1 - bias;
		if (realExp < minNormalExp)
		{
			if (realExp < minSubnormalExp)
				return sign;
			int shift = minNormalExp - realExp;
			uint64_t bits = (1ULL << 52) | m64;
			uint64_t round = (bits >> (52 + shift - manBits - 1)) & 1;
			uint64_t m = (bits >> (52 + shift - manBits)) + round;
			if (m > manMax) m = manMax;
			return sign | m;
		}
		uint64_t round = (m64 >> (52 - manBits - 1)) & 1;
		uint64_t e = (uint64_t) (realExp + bias);
		uint64_t m = (m64 >> (52 - manBits)) + round;
		if (m > manMax)
		{
			m = 0;
			e += 1;
			if (e >= ((1u << expBits) - 1))
				return sign | expAllOnes;
		}
		return sign | (e << manBits) | m;
	}
}

double floatToDouble(unsigned int bits, uint64_t v)
{
	switch (bits)
	{
		case 4:  return f4ToDouble(v & 0xF);
		case 8:  return narrowToDouble(v & 0xFF, 4, 3, 7, 0.001953125);
		case 16: return narrowToDouble(v & 0xFFFF, 5, 10, 15, 0.000000059604644775390625);
		case 32: { uint32_t w = (uint32_t) v; float f; std::memcpy(&f, &w, 4); return (double) f; }
		default: return bitsToDouble(v);
	}
}

uint64_t doubleToFloat(unsigned int bits, double d)
{
	switch (bits)
	{
		case 4:  return doubleToF4(d);
		case 8:  return doubleToNarrow(d, 4, 3, 7, 8, -9);
		case 16: return doubleToNarrow(d, 5, 10, 15, 15, -25);
		case 32: { float f = (float) d; uint32_t w; std::memcpy(&w, &f, 4); return w; }
		default: return doubleBits(d);
	}
}

}

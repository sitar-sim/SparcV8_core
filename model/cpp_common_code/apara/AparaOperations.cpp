//AparaOperations.cpp

#include "AparaOperations.h"
#include <cmath>
#include <cstring>

namespace apara
{

std::string exceptionName(ExceptionCode c)
{
	switch (c)
	{
		case ExceptionCode::NONE:         return "none";
		case ExceptionCode::INT_DIV_ZERO: return "integer divide by zero";
		case ExceptionCode::FLOAT_DIV_ZERO:  return "float divide by zero";
		case ExceptionCode::FLOAT_NAN:       return "float result is NaN";
		case ExceptionCode::FLOAT_SQRT_NEG:  return "square root of a negative float";
		case ExceptionCode::UNALIGNED:    return "unaligned memory address";
		case ExceptionCode::ILLEGAL:      return "illegal instruction or bundle";
	}
	return "unknown";
}

namespace
{
	uint64_t integerOp(Opcode op, bool isSigned, uint64_t x, uint64_t y, ExceptionCode& e)
	{
		switch (op)
		{
			case Opcode::ADD:  return x + y;
			case Opcode::SUB:  return x - y;
			case Opcode::MUL:  return x * y;
			case Opcode::DIV:
				if (y == 0) { e = ExceptionCode::INT_DIV_ZERO; return 0; }
				if (!isSigned) return x / y;
				if ((int64_t) x == INT64_MIN && (int64_t) y == -1) return x; //the one overflowing quotient
				return (uint64_t) ((int64_t) x / (int64_t) y);
			case Opcode::OR:   return x | y;
			case Opcode::AND:  return x & y;
			case Opcode::XOR:  return x ^ y;
			case Opcode::NOR:  return ~(x | y);
			case Opcode::NAND: return ~(x & y);
			case Opcode::XNOR: return ~(x ^ y);
			//Shift counts use their low 6 bits (as the reference does, on
			//the hosts it runs on). A signed right shift is arithmetic.
			case Opcode::SHL:  return x << (y & 63);
			case Opcode::SHR:  return isSigned ? (uint64_t) ((int64_t) x >> (y & 63)) : x >> (y & 63);
			default:           e = ExceptionCode::ILLEGAL; return 0;
		}
	}

	//Float arithmetic is done in double precision and rounded to the
	//type's format (as the reference does). Deviation: the reference has
	//no divide for f4, f8, f16; here every width divides.
	uint64_t floatOp(Opcode op, unsigned int bits, uint64_t a, uint64_t b, ExceptionCode& e)
	{
		double x = floatToDouble(bits, a & lowMask(bits));
		double y = floatToDouble(bits, b & lowMask(bits));
		double r;
		switch (op)
		{
			case Opcode::ADD: r = x + y; break;
			case Opcode::SUB: r = x - y; break;
			case Opcode::MUL: r = x * y; break;
			case Opcode::DIV:
				if (y == 0.0) { e = ExceptionCode::FLOAT_DIV_ZERO; return 0; }
				r = x / y;
				break;
			default: e = ExceptionCode::ILLEGAL; return 0;
		}
		if (std::isnan(r)) { e = ExceptionCode::FLOAT_NAN; return 0; }
		return doubleToFloat(bits, r);
	}

	//A float converted to an integer type: truncated toward zero,
	//saturated to the type's range, NaN to 0.
	uint64_t floatToInteger(double d, const Type& t)
	{
		if (std::isnan(d)) return 0;
		d = std::trunc(d);
		if (t.isSigned())
		{
			double lo = -std::ldexp(1.0, t.bits - 1), hi = std::ldexp(1.0, t.bits - 1);
			if (d <= lo) return (uint64_t) (int64_t) lo & lowMask(t.bits);
			if (d >= hi) return lowMask(t.bits - 1);
			return (uint64_t) (int64_t) d & lowMask(t.bits);
		}
		if (d <= 0.0) return 0;
		if (d >= std::ldexp(1.0, t.bits)) return lowMask(t.bits);
		return (uint64_t) d;
	}

	double integerToDouble(const Type& t, uint64_t v)
	{
		uint64_t w = widen(t, v);
		return t.isSigned() ? (double) (int64_t) w : (double) w;
	}

	//One element value converted between types (Ref cast()).
	uint64_t convertElement(const Type& dst, const Type& src, uint64_t v)
	{
		if (!src.isFloat && !dst.isFloat)
			return widen(src, v) & lowMask(dst.bits);
		double d = src.isFloat ? floatToDouble(src.bits, v & lowMask(src.bits)) : integerToDouble(src, v);
		return dst.isFloat ? doubleToFloat(dst.bits, d) : floatToInteger(d, dst);
	}

	uint64_t placeElement(uint64_t reg, unsigned int bits, unsigned int i, uint64_t v)
	{
		unsigned int shift = (64 / bits - 1 - i) * bits;
		return (reg & ~(lowMask(bits) << shift)) | ((v & lowMask(bits)) << shift);
	}
}

OpResult scalarAlu(Opcode op, const Type& t, uint64_t a, uint64_t b)
{
	OpResult r;
	if (t.isFloat)
		r.value[0] = floatOp(op, t.bits, a, b, r.exception);
	else if (t.isUnsigned)
		r.value[0] = integerOp(op, false, a, b, r.exception);
	else
		r.value[0] = integerOp(op, true, signExtend(a, t.bits), signExtend(b, t.bits), r.exception);
	return r;
}

OpResult vectorAlu(Opcode op, const Type& t, uint64_t a, uint64_t b, bool replicate)
{
	OpResult r;
	unsigned int n = t.elementsPerRegister();
	uint64_t out = 0;
	for (unsigned int i = 0; i < n && r.exception == ExceptionCode::NONE; i++)
	{
		uint64_t x = element(a, t.bits, i);
		uint64_t y = replicate ? (b & lowMask(t.bits)) : element(b, t.bits, i);
		uint64_t v = t.isFloat ? floatOp(op, t.bits, x, y, r.exception)
		                       : integerOp(op, t.isSigned(), widen(t, x), widen(t, y), r.exception);
		out = placeElement(out, t.bits, i, v);
	}
	r.value[0] = out;
	return r;
}

//Deviation: the reference does not implement FSQRT. As its float32 and
//float64 helpers would: pow(x, 0.5), rounded to the type.
OpResult squareRoot(const Type& t, uint64_t a)
{
	OpResult r;
	double x = floatToDouble(t.bits, a & lowMask(t.bits));
	if (x < 0.0) { r.exception = ExceptionCode::FLOAT_SQRT_NEG; return r; }
	double s = std::pow(x, 0.5);
	if (std::isnan(s)) { r.exception = ExceptionCode::FLOAT_NAN; return r; }
	r.value[0] = doubleToFloat(t.bits, s);
	return r;
}

//Integer dot products accumulate in 64 bits. Float dot products
//accumulate in single precision, one element product at a time, and
//give an f32 (as the reference does). Deviation: the reference ignores
//$accumulate for floats; here the f32 in the destination is the start.
OpResult dot(const Type& t, uint64_t a, uint64_t b, bool accumulate, uint64_t acc)
{
	OpResult r;
	unsigned int n = t.elementsPerRegister();
	if (t.isFloat)
	{
		float sum = 0.0f;
		if (accumulate) { uint32_t w = (uint32_t) acc; std::memcpy(&sum, &w, 4); }
		for (unsigned int i = 0; i < n; i++)
		{
			double x = floatToDouble(t.bits, element(a, t.bits, i));
			double y = floatToDouble(t.bits, element(b, t.bits, i));
			sum = (float) ((double) sum + x * y);
		}
		uint32_t w; std::memcpy(&w, &sum, 4);
		r.value[0] = w;
	}
	else
	{
		uint64_t sum = accumulate ? acc : 0;
		for (unsigned int i = 0; i < n; i++)
			sum += widen(t, element(a, t.bits, i)) * widen(t, element(b, t.bits, i));
		r.value[0] = sum;
	}
	return r;
}

//Integer reductions give a 64-bit result, float reductions an f32
//rounded after every step (as the reference does).
//Deviations: each reduction starts from its operation's identity (the
//reference starts from 0, so its "*" and "&" reductions always give 0),
//and unsigned elements are zero-extended (the reference sign-extends).
OpResult vectorReduce(Opcode subOp, const Type& t, uint64_t a)
{
	OpResult r;
	unsigned int n = t.elementsPerRegister();
	if (t.isFloat)
	{
		if (subOp != Opcode::ADD && subOp != Opcode::MUL) { r.exception = ExceptionCode::ILLEGAL; return r; }
		uint64_t accum = doubleToFloat(32, subOp == Opcode::MUL ? 1.0 : 0.0);
		for (unsigned int i = 0; i < n; i++)
		{
			double x = floatToDouble(t.bits, element(a, t.bits, i));
			double s = floatToDouble(32, accum);
			accum = doubleToFloat(32, subOp == Opcode::MUL ? x * s : x + s);
		}
		r.value[0] = accum;
		return r;
	}
	uint64_t accum;
	switch (subOp)
	{
		case Opcode::ADD: case Opcode::OR: case Opcode::XOR: accum = 0;    break;
		case Opcode::MUL:                                   accum = 1;    break;
		case Opcode::AND: case Opcode::XNOR:                accum = ~0ULL; break;
		default: r.exception = ExceptionCode::ILLEGAL; return r;
	}
	for (unsigned int i = 0; i < n; i++)
	{
		uint64_t x = widen(t, element(a, t.bits, i));
		switch (subOp)
		{
			case Opcode::ADD:  accum += x;          break;
			case Opcode::MUL:  accum *= x;          break;
			case Opcode::OR:   accum |= x;          break;
			case Opcode::AND:  accum &= x;          break;
			case Opcode::XOR:  accum ^= x;          break;
			default:           accum = ~(accum ^ x); break; //XNOR
		}
	}
	r.value[0] = accum;
	return r;
}

//A scalar cast converts the low bits of one register. A vector cast
//converts every element of its source registers and packs the results;
//it changes the element width by at most one step, so a widening cast
//writes two registers and a narrowing cast reads two.
//Integer results are truncated to the destination width.
//Deviations: the reference does not mask a cast from a 64-bit source,
//and does not implement casts to or from floats (here: integer to float
//uses the source's full width and signedness; float to integer
//truncates toward zero and saturates; NaN becomes 0).
OpResult cast(const Type& dst, const Type& src, const uint64_t* in, unsigned int inCount)
{
	OpResult r;
	if (!src.isVector)
	{
		r.value[0] = convertElement(dst, src, in[0] & lowMask(src.bits));
		r.count = 1;
		return r;
	}
	unsigned int perIn = src.elementsPerRegister(), perOut = dst.elementsPerRegister();
	unsigned int total = perIn * inCount;
	r.count = total / perOut;
	for (unsigned int k = 0; k < total; k++)
	{
		uint64_t v = convertElement(dst, src, element(in[k / perIn], src.bits, k % perIn));
		r.value[k / perOut] = placeElement(r.value[k / perOut], dst.bits, k % perOut, v);
	}
	return r;
}

//PACK concatenates the low wordBits bits of consecutive registers, the
//first register in the most significant position, into 64-bit results
//(as the reference does).
OpResult pack(unsigned int packedBits, unsigned int wordBits, const uint64_t* in, unsigned int inCount)
{
	OpResult r;
	r.count = 0;
	uint64_t current = 0;
	unsigned int bitsAdded = 0;
	for (unsigned int i = 0; i < inCount; i++)
	{
		current = (wordBits >= 64 ? 0 : current << wordBits) | (in[i] & lowMask(wordBits));
		bitsAdded += wordBits;
		if (bitsAdded == 64 || i == inCount - 1)
		{
			r.value[r.count++] = current;
			current = 0;
			bitsAdded = 0;
		}
	}
	(void) packedBits;
	return r;
}

uint64_t slice(uint64_t v, unsigned int high, unsigned int low)
{
	unsigned int width = high - low + 1;
	return (v << (63 - high)) >> (64 - width);
}

bool conditionHolds(Condition c, const Type& t, uint64_t v)
{
	if (c == Condition::ALWAYS) return true;
	if (c == Condition::NEVER)  return false;
	int sign; //-1, 0, +1
	if (t.isFloat)
	{
		double d = floatToDouble(t.bits, v & lowMask(t.bits));
		if (std::isnan(d)) return c == Condition::NE;
		sign = d < 0.0 ? -1 : (d > 0.0 ? 1 : 0);
	}
	else if (t.isUnsigned)
		sign = v != 0 ? 1 : 0;
	else
	{
		int64_t s = (int64_t) signExtend(v, t.bits);
		sign = s < 0 ? -1 : (s > 0 ? 1 : 0);
	}
	switch (c)
	{
		case Condition::EQ: return sign == 0;
		case Condition::GT: return sign > 0;
		case Condition::LT: return sign < 0;
		case Condition::GE: return sign >= 0;
		case Condition::LE: return sign <= 0;
		case Condition::NE: return sign != 0;
		default:            return false;
	}
}

}

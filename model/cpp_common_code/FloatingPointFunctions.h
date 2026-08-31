//FloatingPointFunctions.h
//
//Functions to convert ints and floats between formats, and to detect
//IEEE 754 exceptions for the SPARC V8 floating-point instructions
//(Ref Appendix C.9, where each op returns (result, texc, c)).
//
//Assumptions: the host machine is little-endian (the simulated SPARC is
//big-endian), float is 4 bytes and double is 8 bytes in standard IEEE
//representation on the host, and memory in both is organized as 32-bit
//words, so a word swap is used instead of a bit swap.
//
//Every function that can raise an IEEE 754 exception takes a trailing
//uint32_t* texc out-parameter, filled with the 5-bit exception code
//(bit4 invalid, bit3 overflow, bit2 underflow, bit1 division-by-zero,
//bit0 inexact, matching FSR's cexc/aexc/TEM layout). Single and double
//precision use the host FPU's own IEEE 754 exception flags directly,
//via feclearexcept()/fetestexcept() bracketing each operation.
//
//Quad precision (__float128) does not use fenv: __float128 arithmetic
//goes through libquadmath/libgcc TF-mode routines rather than native
//FPU instructions, and does not reliably raise the host's hardware fenv
//flags. Invalid and overflow conditions for quad ops are instead
//detected directly from the IEEE 754 special-value rules on the
//operands and result (quadAddSubIsInvalid, quadMulIsInvalid,
//quadDivIsInvalid, quadSqrtIsInvalid, quadIsOverflow, isSignalingNaNQ
//below). Underflow and inexact are not detected for quad precision and
//always report 0, since neither can be determined from the operands and
//result alone without hardware support or a higher-precision reference.
//
//Comparisons (compare_*/compare_e_*) are handled separately from fenv.
//The manual's distinction between FCMP, which traps only on a signaling
//NaN operand, and FCMPE, which traps on any NaN operand, requires
//inspecting the NaN's own bit pattern directly, not a single fenv
//outcome.


#include<stdint.h>
#include<cassert>
#include<cstring>
#include<cmath>
#include<cfenv>

extern "C" {
#include "quadmath.h"	//for quad precision floating point type
}

#pragma STDC FENV_ACCESS ON

//Maps the host FPU's IEEE 754 exception flags (as raised by the immediately preceding
//floating-point operation) to a SPARC FSR-style 5-bit texc value. Callers must have called
//std::feclearexcept(FE_ALL_EXCEPT) before the operation being measured.
inline uint32_t hostFEtoTexc()
{
	int e = std::fetestexcept(FE_INVALID | FE_OVERFLOW | FE_UNDERFLOW | FE_DIVBYZERO | FE_INEXACT);
	uint32_t texc = 0;
	if (e & FE_INVALID)   texc |= 0x10; //nv
	if (e & FE_OVERFLOW)  texc |= 0x08; //of
	if (e & FE_UNDERFLOW) texc |= 0x04; //uf
	if (e & FE_DIVBYZERO) texc |= 0x02; //dz
	if (e & FE_INEXACT)   texc |= 0x01; //nx
	return texc;
}

//A NaN is "signaling" (as opposed to "quiet") when the most significant bit of its mantissa
//is 0. (Quiet NaNs have that bit set to 1.) Needed to distinguish FCMP (traps only on a
//signaling NaN) from FCMPE (traps on any NaN) -- see the file-level comment above.
inline bool isSignalingNaN_single(float f)
{
	uint32_t bits;
	memcpy(&bits, &f, sizeof(bits));
	uint32_t exponent = (bits >> 23) & 0xFF;
	uint32_t mantissa = bits & 0x7FFFFFu;
	bool isNaN   = (exponent == 0xFF) && (mantissa != 0);
	bool isQuiet = (mantissa & 0x400000u) != 0;
	return isNaN && !isQuiet;
}

inline bool isSignalingNaN_double(double d)
{
	uint64_t bits;
	memcpy(&bits, &d, sizeof(bits));
	uint64_t exponent = (bits >> 52) & 0x7FFu;
	uint64_t mantissa = bits & 0xFFFFFFFFFFFFFULL;
	bool isNaN   = (exponent == 0x7FF) && (mantissa != 0);
	bool isQuiet = (mantissa & 0x8000000000000ULL) != 0;
	return isNaN && !isQuiet;
}

//===================================================================================
// Quad-precision (__float128) IEEE 754 "invalid" and "overflow" exception detection.
//===================================================================================
//__float128 arithmetic goes through libquadmath/libgcc TF-mode routines rather than
//native FPU instructions, so (unlike float/double) it does not reliably raise the
//host's hardware fenv flags -- confirmed empirically: 0Q/0Q and sqrtq(-1Q) correctly
//set FE_INVALID, but a genuinely inexact quad division does *not* set FE_INEXACT
//(likely because that particular routine is implemented via integer bit manipulation
//that never executes a hardware FP instruction). Rather than rely on an unreliable
//signal, invalid/overflow conditions are detected directly from the IEEE 754 754
//special-value rules on the operands/result themselves -- the same technique already
//used for FCMP/FCMPE's signaling-vs-quiet NaN distinction above.
//
//Underflow and inexact are NOT detected for quad precision (always report 0 for
//those bits): unlike invalid/overflow, they cannot be determined from the
//operands/result alone without either hardware support or an independent
//higher-than-quad-precision reference to compare against, neither of which is
//available here.

inline bool isSignalingNaNQ(__float128 x)
{
	uint64_t lo, hi;
	memcpy(&lo, reinterpret_cast<const char*>(&x),     8);
	memcpy(&hi, reinterpret_cast<const char*>(&x) + 8, 8);
	//binary128 layout (little-endian host): hi = sign(1)+exponent(15)+mantissa[111:64](48 bits),
	//lo = mantissa[63:0]
	uint64_t exponent = (hi >> 48) & 0x7FFFu;
	bool isNaN   = (exponent == 0x7FFFu) && ( (hi & 0xFFFFFFFFFFFFULL) != 0 || lo != 0 );
	bool isQuiet = (hi & 0x800000000000ULL) != 0; //MSB of the 112-bit mantissa
	return isNaN && !isQuiet;
}

//invalid condition for FADDq/FSUBq: a signaling NaN operand, or combining opposite-signed
//infinities (e.g. (+inf) + (-inf), or (+inf) - (+inf))
inline bool quadAddSubIsInvalid(__float128 x, __float128 y, bool isSub)
{
	if (isSignalingNaNQ(x) || isSignalingNaNQ(y)) return true;
	if (isinfq(x) && isinfq(y))
	{
		__float128 yEff = isSub ? -y : y;
		return (signbitq(x) != 0) != (signbitq(yEff) != 0);
	}
	return false;
}

//invalid condition for FMULq: a signaling NaN operand, or 0 * infinity (either order)
inline bool quadMulIsInvalid(__float128 x, __float128 y)
{
	if (isSignalingNaNQ(x) || isSignalingNaNQ(y)) return true;
	bool xZero = (x == 0), yZero = (y == 0);
	bool xInf  = isinfq(x), yInf  = isinfq(y);
	return (xZero && yInf) || (xInf && yZero);
}

//invalid condition for FDIVq: a signaling NaN operand, or 0/0, or infinity/infinity
inline bool quadDivIsInvalid(__float128 x, __float128 y)
{
	if (isSignalingNaNQ(x) || isSignalingNaNQ(y)) return true;
	bool xZero = (x == 0), yZero = (y == 0);
	bool xInf  = isinfq(x), yInf  = isinfq(y);
	return (xZero && yZero) || (xInf && yInf);
}

//division-by-zero condition for FDIVq: a finite, nonzero dividend divided by zero
//(0/0 is "invalid", not "division-by-zero" -- see FSR_division-by-zero in the manual)
inline bool quadDivIsDivByZero(__float128 x, __float128 y)
{
	return (y == 0) && (x != 0) && !isnanq(x) && !isinfq(x);
}

//invalid condition for FSQRTq: a signaling NaN operand, or a negative operand (-0 is valid)
inline bool quadSqrtIsInvalid(__float128 x)
{
	if (isSignalingNaNQ(x)) return true;
	return !isnanq(x) && x < 0;
}

//overflow: result is infinite while every operand was finite (i.e. the operation itself,
//not an infinite operand, produced the infinity)
inline bool quadIsOverflow(__float128 result, __float128 x)
{
	return isinfq(result) && !isinfq(x) && !isnanq(x);
}
inline bool quadIsOverflow(__float128 result, __float128 x, __float128 y)
{
	return isinfq(result) && !isinfq(x) && !isnanq(x) && !isinfq(y) && !isnanq(y);
}

//reverse the order of words in destination
void wordSwap(uint32_t* destination, int num_words)
{
	if(num_words<=1)
		return;
	else
	{


		assert(sizeof(char)==1);

		char* dest_ptr  = (char *)destination;
		char temp[32*4];

		for(int i=0;i<num_words;i++)
			for(int j=0;j<4;j++)
				temp[4*i+j] = dest_ptr[(num_words-i-1)*4+j];

		for(int i=0;i<num_words*4;i++)
			dest_ptr[i]=temp[i];
	}
}

//=========================================
//Convert Int to floating point:
//=========================================

void  convertIntToSingle(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//check that float is represented on this Host machine as 4 Bytes
	assert(sizeof(float)==4);

	//interpret number, first as signed 32bit int
	//and then typecast to float
	int32_t* xs   = reinterpret_cast<int32_t*>(x);

	std::feclearexcept(FE_ALL_EXCEPT);
	float  result = (float) (*xs);
	*texc = hostFEtoTexc();

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&result;
	memcpy(dest_ptr, source_ptr, sizeof(float));

};


void convertIntToDouble(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//check that double is represented on this Host machine as 8 Bytes
	assert(sizeof(double)==8);

	//interpret number, first as signed 32bit int
	//and then typecast to double
	int32_t* xs   = reinterpret_cast<int32_t*>(x);

	std::feclearexcept(FE_ALL_EXCEPT);
	double  result = (double) (*xs);
	*texc = hostFEtoTexc();

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&result;
	memcpy(dest_ptr, source_ptr, sizeof(double));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, 2);

};


void convertIntToQuad(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//check that double is represented on this Host machine as 8 Bytes
	assert(sizeof(__float128)==16);

	//interpret number, first as signed 32bit int
	//and then typecast to quad precision
	int32_t* xs   = reinterpret_cast<int32_t*>(x);
	__float128  result = (__float128) (*xs);
	*texc = 0; //a 32-bit int always converts exactly to quad precision: no exception is possible

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&result;
	memcpy(dest_ptr, source_ptr, sizeof(__float128));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination,4);

};


//=========================================
//Convert floating point to Int:
//=========================================

void convertSingleToInt(uint32_t *x, uint32_t* destination, uint32_t* texc )
{
	assert(sizeof(float)==4);
	//interpret number as float
	float* x1   = reinterpret_cast<float*>(x);

	//cast to Int
	std::feclearexcept(FE_ALL_EXCEPT);
	int x2 = (int) (*x1);
	*texc = hostFEtoTexc();

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&x2;
	memcpy(dest_ptr, source_ptr, sizeof(float));
};



void convertDoubleToInt(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//check that double is represented on this Host machine as 8 Bytes
	assert(sizeof(double)==8);


	//reverse word order of input to change endianness
	uint32_t temp[2] = {x[1],x[0]};

	//interpret as a double
	double x1;
	memcpy(&x1, temp, sizeof(double));

	//cast to int
	std::feclearexcept(FE_ALL_EXCEPT);
	int    x2 = (int)(x1);
	*texc = hostFEtoTexc();

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&x2;
	memcpy(dest_ptr, source_ptr, sizeof(uint32_t));

};

void convertQuadToInt(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//check that double is represented on this Host machine as 16 Bytes
	assert(sizeof(__float128)==16);


	//reverse word order of input to change endianness
	uint32_t temp[4] = {x[3],x[2],x[1],x[0]};

	//interpret as a quad
	__float128 x1;
	memcpy(&x1, temp, sizeof(__float128));

	//cast to int
	int    x2 = (int)(x1);
	//invalid: NaN, infinite, or magnitude too large to represent as a 32-bit int
	bool outOfRange = !isnanq(x1) && !isinfq(x1) &&
		(x1 > (__float128)2147483647.0 || x1 < -(__float128)2147483648.0);
	*texc = (isnanq(x1) || isinfq(x1) || outOfRange) ? 0x10 : 0;

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&x2;
	memcpy(dest_ptr, source_ptr, sizeof(uint32_t));

};


//=========================================
//Convert between floating point formats:
//=========================================

void convertSingleToDouble(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//check that double is represented on this Host machine as 8 Bytes
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);

	//interpret number as single,
	//and then typecast to double
	float* xs   = reinterpret_cast<float*>(x);

	std::feclearexcept(FE_ALL_EXCEPT);
	double  result = (double) (*xs);
	*texc = hostFEtoTexc();

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&result;
	memcpy(dest_ptr, source_ptr, sizeof(double));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, 2);

};


void convertSingleToQuad(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//check that double is represented on this Host machine as 8 Bytes
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);

	//interpret number as single,
	//and then typecast to quad
	float* xs   = reinterpret_cast<float*>(x);
	__float128  result = (__float128) (*xs);
	*texc = isSignalingNaN_single(*xs) ? 0x10 : 0; //widening: always exact, except a signaling NaN source is invalid

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&result;
	memcpy(dest_ptr, source_ptr, sizeof(__float128));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, 4);

};

void convertDoubleToSingle(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//check that double is represented on this Host machine as 8 Bytes
	assert(sizeof(double)==8);
	assert(sizeof(float)==4);


	//reverse word order of input to change endianness
	uint32_t temp[2] = {x[1],x[0]};

	//interpret as a double
	double x1;
	memcpy(&x1, temp, sizeof(double));

	//cast to single
	std::feclearexcept(FE_ALL_EXCEPT);
	float    x2 = (float)(x1);
	*texc = hostFEtoTexc();

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&x2;
	memcpy(dest_ptr, source_ptr, sizeof(float));

};


void convertDoubleToQuad(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//check that double is represented on this Host machine as 8 Bytes
	assert(sizeof(double)==8);
	assert(sizeof(float)==4);
	assert(sizeof(__float128)==16);


	//reverse word order of input to change endianness
	uint32_t temp[2] = {x[1],x[0]};

	//interpret as a double
	double x1;
	memcpy(&x1, temp, sizeof(double));

	//cast to quad
	__float128    x2 = (__float128)(x1);
	*texc = isSignalingNaN_double(x1) ? 0x10 : 0; //widening: always exact, except a signaling NaN source is invalid

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&x2;
	memcpy(dest_ptr, source_ptr, sizeof(__float128));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, 4);
};


void convertQuadToSingle(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//check that double is represented on this Host machine as 8 Bytes
	assert(sizeof(double)==8);
	assert(sizeof(float)==4);
	assert(sizeof(__float128)==16);


	//reverse word order of input to change endianness
	uint32_t temp[4] = {x[3], x[2], x[1],x[0]};

	//interpret as a quad
	__float128 x1;
	memcpy(&x1, temp, sizeof(__float128));

	//cast to single
	float    x2 = (float)(x1);
	//invalid: signaling NaN source. overflow: narrowing pushed a finite quad value out of single's range.
	*texc = isSignalingNaNQ(x1) ? 0x10 : (quadIsOverflow((__float128)x2, x1) ? 0x08 : 0);

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&x2;
	memcpy(dest_ptr, source_ptr, sizeof(float));

};

void convertQuadToDouble(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//check that double is represented on this Host machine as 8 Bytes
	assert(sizeof(double)==8);
	assert(sizeof(float)==4);
	assert(sizeof(__float128)==16);


	//reverse word order of input to change endianness
	uint32_t temp[4] = {x[3], x[2], x[1],x[0]};

	//interpret as a quad
	__float128 x1;
	memcpy(&x1, temp, sizeof(__float128));

	//cast to double
	double    x2 = (double)(x1);
	//invalid: signaling NaN source. overflow: narrowing pushed a finite quad value out of double's range.
	*texc = isSignalingNaNQ(x1) ? 0x10 : (quadIsOverflow((__float128)x2, x1) ? 0x08 : 0);

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&x2;
	memcpy(dest_ptr, source_ptr, sizeof(double));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, 2);

};

//===================================
// Floating point Square Root
//===================================

void sqrt_single(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);

	//interpret number as single,
	float* xs   = reinterpret_cast<float*>(x);

	//find sqare root
	std::feclearexcept(FE_ALL_EXCEPT);
	float  result = sqrt(*xs);
	*texc = hostFEtoTexc();

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&result;
	memcpy(dest_ptr, source_ptr, sizeof(float));

};

void sqrt_double(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);

	//reverse word order of input to change endianness
	uint32_t temp[2] = {x[1],x[0]};

	//interpret number as double
	double x1;
	memcpy(&x1, temp, sizeof(double));

	//find sqare root
	std::feclearexcept(FE_ALL_EXCEPT);
	double  result = sqrt(x1);
	*texc = hostFEtoTexc();

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&result;
	memcpy(dest_ptr, source_ptr, sizeof(double));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, 2);
};

void sqrt_quad(uint32_t *x, uint32_t* destination, uint32_t* texc )
{

	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);

	//reverse word order of input to change endianness
	uint32_t temp[4] = {x[3], x[2], x[1],x[0]};

	//interpret number as quad
	__float128 x1;
	memcpy(&x1, temp, sizeof(__float128));

	//find sqare root
	__float128  result = sqrtq(x1);
	*texc = quadSqrtIsInvalid(x1) ? 0x10 : 0;

	//store result in destination:
	char *dest_ptr   = (char *)destination;
	char *source_ptr = (char *)&result;
	memcpy(dest_ptr, source_ptr, sizeof(__float128));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, 4);
};


void add_single(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef float FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =1; //size in words


	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);


	//interpret numbers as FLOAT_TYPE
	FLOAT_TYPE x1, y1;
	memcpy(&x1, x, sizeof(FLOAT_TYPE));
	memcpy(&y1, y, sizeof(FLOAT_TYPE));

	//find result
	std::feclearexcept(FE_ALL_EXCEPT);
	FLOAT_TYPE result = x1 + y1;
	*texc = hostFEtoTexc();
	memcpy(destination, &result, sizeof(FLOAT_TYPE));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, FLOAT_TYPE_SIZE);
};

void sub_single(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef float FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =1; //size in words


	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);


	//interpret numbers as FLOAT_TYPE
	FLOAT_TYPE x1, y1;
	memcpy(&x1, x, sizeof(FLOAT_TYPE));
	memcpy(&y1, y, sizeof(FLOAT_TYPE));

	//find result
	std::feclearexcept(FE_ALL_EXCEPT);
	FLOAT_TYPE result = x1 - y1;
	*texc = hostFEtoTexc();
	memcpy(destination, &result, sizeof(FLOAT_TYPE));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination,FLOAT_TYPE_SIZE);
};

void add_double(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef double FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =2; //size in words


	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);

	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	//reverse words in operands
	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};


	//interpret numbers as FLOAT_TYPE
	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	//find result
	std::feclearexcept(FE_ALL_EXCEPT);
	FLOAT_TYPE result = x2 + y2;
	*texc = hostFEtoTexc();
	memcpy(destination, &result, sizeof(FLOAT_TYPE));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, FLOAT_TYPE_SIZE);


};
void sub_double(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef double FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =2; //size in words


	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);

	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	//reverse words in operands
	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};


	//interpret numbers as FLOAT_TYPE
	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	//find result
	std::feclearexcept(FE_ALL_EXCEPT);
	FLOAT_TYPE result = x2 - y2;
	*texc = hostFEtoTexc();
	memcpy(destination, &result, sizeof(FLOAT_TYPE));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, FLOAT_TYPE_SIZE);


};

void add_quad(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef __float128 FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =4; //size in words


	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);

	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	//reverse words in operands
	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};


	//interpret numbers as FLOAT_TYPE
	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	//find result
	FLOAT_TYPE result = x2 + y2;
	*texc = quadAddSubIsInvalid(x2, y2, false) ? 0x10 : (quadIsOverflow(result, x2, y2) ? 0x08 : 0);
	memcpy(destination, &result, sizeof(FLOAT_TYPE));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, FLOAT_TYPE_SIZE);

};

void sub_quad(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef __float128 FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =4; //size in words


	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);

	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	//reverse words in operands
	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};


	//interpret numbers as FLOAT_TYPE
	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	//find result
	FLOAT_TYPE result = x2 - y2;
	*texc = quadAddSubIsInvalid(x2, y2, true) ? 0x10 : (quadIsOverflow(result, x2, y2) ? 0x08 : 0);
	memcpy(destination, &result, sizeof(FLOAT_TYPE));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, FLOAT_TYPE_SIZE);

};


void mul_single(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef float FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =1; //size in words


	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);


	//interpret numbers as FLOAT_TYPE
	FLOAT_TYPE x1, y1;
	memcpy(&x1, x, sizeof(FLOAT_TYPE));
	memcpy(&y1, y, sizeof(FLOAT_TYPE));

	//find result
	std::feclearexcept(FE_ALL_EXCEPT);
	FLOAT_TYPE result = x1 * y1;
	*texc = hostFEtoTexc();
	memcpy(destination, &result, sizeof(FLOAT_TYPE));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination,FLOAT_TYPE_SIZE);
};

void div_single(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef float FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =1; //size in words


	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);


	//interpret numbers as FLOAT_TYPE
	FLOAT_TYPE x1, y1;
	memcpy(&x1, x, sizeof(FLOAT_TYPE));
	memcpy(&y1, y, sizeof(FLOAT_TYPE));

	//find result
	std::feclearexcept(FE_ALL_EXCEPT);
	FLOAT_TYPE result = x1 / y1;
	*texc = hostFEtoTexc();
	memcpy(destination, &result, sizeof(FLOAT_TYPE));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination,FLOAT_TYPE_SIZE);
};

void mul_double(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef double FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =2; //size in words


	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);

	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	//reverse words in operands
	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};


	//interpret numbers as FLOAT_TYPE
	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	//find result
	std::feclearexcept(FE_ALL_EXCEPT);
	FLOAT_TYPE result = x2 * y2;
	*texc = hostFEtoTexc();
	memcpy(destination, &result, sizeof(FLOAT_TYPE));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, FLOAT_TYPE_SIZE);


};


void div_double(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef double FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =2; //size in words


	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);

	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	//reverse words in operands
	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};


	//interpret numbers as FLOAT_TYPE
	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	//find result
	std::feclearexcept(FE_ALL_EXCEPT);
	FLOAT_TYPE result = x2 / y2;
	*texc = hostFEtoTexc();
	memcpy(destination, &result, sizeof(FLOAT_TYPE));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, FLOAT_TYPE_SIZE);


};

void mul_quad(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef __float128 FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =4; //size in words


	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);

	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	//reverse words in operands
	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};


	//interpret numbers as FLOAT_TYPE
	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	//find result
	FLOAT_TYPE result = x2 * y2;
	*texc = quadMulIsInvalid(x2, y2) ? 0x10 : (quadIsOverflow(result, x2, y2) ? 0x08 : 0);
	memcpy(destination, &result, sizeof(FLOAT_TYPE));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, FLOAT_TYPE_SIZE);


};

void div_quad(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef __float128 FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =4; //size in words


	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);

	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	//reverse words in operands
	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};


	//interpret numbers as FLOAT_TYPE
	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	//find result
	FLOAT_TYPE result = x2 / y2;
	if      (quadDivIsInvalid(x2, y2))       *texc = 0x10;
	else if (quadDivIsDivByZero(x2, y2))     *texc = 0x02;
	else if (quadIsOverflow(result, x2, y2)) *texc = 0x08;
	else                                     *texc = 0;
	memcpy(destination, &result, sizeof(FLOAT_TYPE));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination, FLOAT_TYPE_SIZE);


};



void mul_single_to_double(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{

	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);


	//interpret numbers as single
	float x1, y1;
	memcpy(&x1, x, sizeof(float));
	memcpy(&y1, y, sizeof(float));

	//find result in double the precision of source
	std::feclearexcept(FE_ALL_EXCEPT);
	double  result = (double)(x1) * (double)(y1);
	*texc = hostFEtoTexc();

	//store result in destination:
	memcpy(destination, &result, sizeof(double));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination,2);
};


void mul_double_to_quad(uint32_t *x, uint32_t* y, uint32_t* destination, uint32_t* texc )
{
	typedef double FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =2; //size in words

	//some checks
	assert(sizeof(float)==4);
	assert(sizeof(double)==8);
	assert(sizeof(__float128)==16);



	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	//reverse words in operands
	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};


	//interpret numbers as double
	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	//find result in double the precision of source
	__float128  result = (__float128)(x2) * (__float128)(y2);
	//invalid: a signaling NaN operand, or 0 * infinity (either order). Overflow is not
	//possible here: a double*double product always fits comfortably within quad's much
	//larger range.
	bool xZero = (x2 == 0), yZero = (y2 == 0);
	bool xInf  = std::isinf(x2), yInf = std::isinf(y2);
	bool invalid = isSignalingNaN_double(x2) || isSignalingNaN_double(y2) ||
		(xZero && yInf) || (xInf && yZero);
	*texc = invalid ? 0x10 : 0;

	//store result in destination:
	memcpy(destination, &result, sizeof(__float128));

	//reverse the order of words in destination, because
	//host is little endian, whereas target (SPARC v8) is Big endian
	wordSwap(destination,4);
};


//===================================
// Floating point Compare
//===================================
//FCMP traps only on a signaling NaN operand; FCMPE traps on any NaN operand (quiet or
//signaling). See SPARC V8 manual Appendix B, "Floating-Point Compare Instructions".

int compare_single(uint32_t *x, uint32_t* y, uint32_t* texc)
{
	assert(sizeof(float)==4);

	float x1, y1;
	memcpy(&x1, x, sizeof(float));
	memcpy(&y1, y, sizeof(float));

	bool anyNaN = std::isnan(x1) || std::isnan(y1);
	bool sNaN   = isSignalingNaN_single(x1) || isSignalingNaN_single(y1);
	*texc = sNaN ? 0x10 : 0x00;

	int tfcc;
	if      (anyNaN)  tfcc=3;
	else if (x1==y1)  tfcc=0;
	else if (x1 <y1)  tfcc=1;
	else              tfcc=2;

	return tfcc;
};

int compare_e_single(uint32_t *x, uint32_t* y, uint32_t* texc)
{
	assert(sizeof(float)==4);

	float x1, y1;
	memcpy(&x1, x, sizeof(float));
	memcpy(&y1, y, sizeof(float));

	bool anyNaN = std::isnan(x1) || std::isnan(y1);
	*texc = anyNaN ? 0x10 : 0x00;

	int tfcc;
	if      (anyNaN)  tfcc=3;
	else if (x1==y1)  tfcc=0;
	else if (x1 <y1)  tfcc=1;
	else              tfcc=2;

	return tfcc;
};

int compare_double(uint32_t *x, uint32_t* y, uint32_t* texc)
{
	assert(sizeof(double)==8);

	typedef double FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =2; //size in words

	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	//reverse words in operands
	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};

	//interpret numbers as double
	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	bool anyNaN = std::isnan(x2) || std::isnan(y2);
	bool sNaN   = isSignalingNaN_double(x2) || isSignalingNaN_double(y2);
	*texc = sNaN ? 0x10 : 0x00;

	int tfcc;
	if      (anyNaN)  tfcc=3;
	else if (x2==y2)  tfcc=0;
	else if (x2 <y2)  tfcc=1;
	else              tfcc=2;

	return tfcc;
};

int compare_e_double(uint32_t *x, uint32_t* y, uint32_t* texc)
{
	assert(sizeof(double)==8);

	typedef double FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =2; //size in words

	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	//reverse words in operands
	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};

	//interpret numbers as double
	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	bool anyNaN = std::isnan(x2) || std::isnan(y2);
	*texc = anyNaN ? 0x10 : 0x00;

	int tfcc;
	if      (anyNaN)  tfcc=3;
	else if (x2==y2)  tfcc=0;
	else if (x2 <y2)  tfcc=1;
	else              tfcc=2;

	return tfcc;
};

int compare_quad(uint32_t *x, uint32_t* y, uint32_t* texc)
{
	assert(sizeof(__float128)==16);

	typedef __float128 FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =4; //size in words

	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	//reverse words in operands
	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};

	//interpret numbers as quad (128-bit)
	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	//FCMPq traps only on a signaling NaN operand (see compare_single/compare_e_single above
	//for the FCMP-vs-FCMPE distinction)
	bool anyNaN = isnanq(x2) || isnanq(y2);
	bool sNaN   = isSignalingNaNQ(x2) || isSignalingNaNQ(y2);
	*texc = sNaN ? 0x10 : 0x00;

	int tfcc;
	if      (anyNaN) tfcc=3;
	else if (x2==y2) tfcc=0;
	else if (x2 <y2) tfcc=1;
	else             tfcc=2;

	return tfcc;
};

int compare_e_quad(uint32_t *x, uint32_t* y, uint32_t* texc)
{
	assert(sizeof(__float128)==16);

	typedef __float128 FLOAT_TYPE;
	const int FLOAT_TYPE_SIZE =4; //size in words

	uint32_t x1[FLOAT_TYPE_SIZE];
	uint32_t y1[FLOAT_TYPE_SIZE];

	for(int i=0; i<FLOAT_TYPE_SIZE; i++)
	{
		x1[i] = x[FLOAT_TYPE_SIZE-1-i];
		y1[i] = y[FLOAT_TYPE_SIZE-1-i];
	};

	FLOAT_TYPE x2, y2;
	memcpy(&x2, x1, sizeof(FLOAT_TYPE));
	memcpy(&y2, y1, sizeof(FLOAT_TYPE));

	//FCMPEq traps on any NaN operand, quiet or signaling
	bool anyNaN = isnanq(x2) || isnanq(y2);
	*texc = anyNaN ? 0x10 : 0x00;

	int tfcc;
	if      (anyNaN) tfcc=3;
	else if (x2==y2) tfcc=0;
	else if (x2 <y2) tfcc=1;
	else             tfcc=2;

	return tfcc;
};

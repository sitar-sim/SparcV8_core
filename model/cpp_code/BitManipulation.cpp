//BitManipulation.cpp



//Functions for bit manipulations of 32bit unsigned integers
//Neha Karanjkar March 2013


#include"BitManipulation.h"
#include<cassert>
#include<stdint.h>
#include<sstream>
#include<string>
#include<bitset>


//check if an unsigned integer is a power of two
bool isPowerOfTwo(unsigned int x)
{
 while (((x & 1) == 0) && x > 1) /* While x is even and > 1 */
   x >>= 1;
 return (x == 1);
}



uint32_t readBits(uint32_t reg, unsigned int h, unsigned int l)
{
	//returns a continuous set of bits from position h to l from reg.
	//the selected bits are right justified into a 32bit result.
	//31<=h<=l<=0

	assert(h<32);
	assert(l<=h);
	reg=reg<<(31-h); 
	reg=reg>>(31-h+l);
	return reg;
};


uint64_t readBits64(uint64_t reg, unsigned int h, unsigned int l)
{
	//returns a continuous set of bits from position h to l from reg.
	//the selected bits are right justified into a 32bit result.
	//63<=h<=l<=0

	assert(h<64);
	assert(l<=h);
	reg=reg<<(63-h); 
	reg=reg>>(63-h+l);
	return reg;
};



//write a value into a bit field of a register
void writeBits(uint32_t & reg, unsigned int h, unsigned int l, uint32_t value)
{

	assert(h<32);
	assert(l<=h);
	uint32_t mask=-1; 
	mask=mask>>(31-h+l);
	value=value&mask; //crop value to be written to fit into the bit field
	value=value<<l;   //move the cropped bits into proper place for insertion

	mask=mask<<l;
	reg=reg&(~mask);  //clear the bits to be written in reg

	reg=reg|value;    //insert value into reg

};

uint64_t concatBits(uint32_t A, uint32_t B, unsigned int B_width)
//concatenate A with B. If B_width is specified, crop B to the last B_width bits
//and concatenate this to A
{
	assert(B_width<=32);

	uint64_t result=0x00;
	result=result|A; //copy A

	if(B_width>0)
	{
		result=result<<B_width; //make space for B
		result=result|(readBits(B,B_width-1,0));//concat B
	};
	return result;
};






std::string getBitString(uint32_t reg)
{
	using namespace std;
	stringstream S;
	string str;
	S<<bitset<32>(reg);
	str=S.str();
	return str;
};

std::string getBitString(uint64_t reg)
{
	using namespace std;
	stringstream S;
	string str;
	S<<bitset<64>(reg);
	str=S.str();
	return str;
};




uint32_t sign_extend(uint32_t val, unsigned int highest_bit)
{
	assert(highest_bit<=31);
	uint32_t result=val;
	uint32_t sign;
	//find out the sign
	sign=readBits(val, highest_bit,highest_bit);
	//copy the sign bit to the most significant bits
	if(sign==0)
		writeBits(result, 31, highest_bit, 0);
	else
		writeBits(result, 31, highest_bit, 0xffffffff);
	return result;
};

uint32_t zero_extend(uint32_t val, unsigned int highest_bit)
{
	assert(highest_bit<=31);
	uint32_t result=val;
	//copy 0 to the most significant bits
	if(highest_bit<31)
		writeBits(result, 31, highest_bit+1, 0);
	return result;
};




////In .BitManipulation.h:
//inline uint32_t sign_extend_byte(uint32_t byte){return sign_extend(byte, 7);};
//inline uint32_t zero_extend_byte(uint32_t byte){return zero_extend(byte, 7);};
//inline uint32_t sign_extend_halfword(uint32_t halfword){return sign_extend(halfword, 15);};
//inline uint32_t zero_extend_halfword(uint32_t halfword){return zero_extend(halfword, 15);};
//

//Testbench
/*
int main()
{
	uint32_t x= 0xffffffff;
	uint32_t y= 0;
	uint32_t a,b,c;

	std::cout<<"\n\n";
	getBitString(readBits(x,0,0));
	getBitString(readBits(x,31,31));
	getBitString(readBits(x,15,15));
	getBitString(readBits(x,15,0));
	getBitString(readBits(x,31,16));
	getBitString(readBits(x,31,30));

	writeBits(y,31,31,x);
	writeBits(y,0,0,x);
	writeBits(y,15,15,x);
	writeBits(y,29,28,x);
	writeBits(y,3,2,x);

	std::cout<<"\n\n";
	getBitString(readBits(y,31,0));

	std::cout<<"\n\n";
	a= readBits(x,17,0);
	getBitString(a);
	a=sign_extend(a,17);
	getBitString(a);

	std::cout<<"\n\n";
	a= 0xAAAA;
	getBitString(a);
	getBitString(sign_extend_byte(a));
	getBitString(zero_extend_byte(a));
	getBitString(sign_extend_halfword(a));
	getBitString(zero_extend_halfword(a));

	std::cout<<"\n\n";






	return 0;
}

*/










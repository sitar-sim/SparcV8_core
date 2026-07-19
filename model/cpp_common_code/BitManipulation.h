//BitManipulation.h
#ifndef BIT_MANIPULATION_H
#define BIT_MANIPULATION_H



//Functions for bit manipulations of 32bit unsigned integers
//Neha Karanjkar March 2013

#include<stdint.h>
#include<iostream>

//check if an unsigned integer is a power of two
bool isPowerOfTwo(unsigned int x);


uint32_t readBits(uint32_t reg, unsigned int h, unsigned int l);
//returns a continuous set of bits from position h to l from reg.
//the selected bits are right justified into a 32bit result.
//31<=h<=l<=0


uint64_t readBits64(uint64_t reg, unsigned int h, unsigned int l);
//returns a continuous set of bits from position h to l from reg.
//the selected bits are right justified into a 64bit result.
//63<=h<=l<=0




void writeBits(uint32_t & reg, unsigned int h, unsigned int l, uint32_t value);
//inserts a value into a continuous set of bits between positions h and l
//in reg. If the value is larger, it is cropped and the least significant h-l+1
//bits are inserted


uint64_t concatBits(uint32_t A, uint32_t B, unsigned int B_width=32);
//concatenate A with B. If B_width is specified, crop B to the last(least significant) B_width bits
//and concatenate this to A




std::string getBitString(uint32_t reg);
//returns the bits in reg as a 32-bit bitset string.


std::string getBitString(uint64_t reg);
//returns the bits in reg as a 64-bit bitset string.



uint32_t sign_extend(uint32_t val, unsigned int highest_bit);
//copy the bit in position 'highest_bit' into bits 31 to highest_bit
uint32_t zero_extend(uint32_t val, unsigned int highest_bit);
//write '0' in bits 31 to highest bit+1



inline uint32_t sign_extend_byte(uint32_t byte){return sign_extend(byte, 7);}
inline uint32_t zero_extend_byte(uint32_t byte){return zero_extend(byte, 7);}


inline uint32_t sign_extend_halfword(uint32_t halfword){return sign_extend(halfword, 15);}
inline uint32_t zero_extend_halfword(uint32_t halfword){return zero_extend(halfword, 15);}
#endif

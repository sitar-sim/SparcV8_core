
#ifndef MEMCORE_H
#define MEMCORE_H
//MemCore.h
//
//Functional model of a random-access memory
//implemented as a word addressable array of 32bit words
//
//
//NOTE:Addresses supplied to MemCore for Read/Write functions are Byte addresses!!
//and have to be converted to word addresses

#include<fstream>
#include<stdint.h>
#include<cassert>
#include<vector>
#include<iostream>
#include"BitManipulation.h"


class MemCore
{
	public:
		static const unsigned int memSize = 0x10000000;  //Memory size in bytes = 256MB
		static const unsigned int nwords = memSize>>2; //Number of 32bit words in memory
		std::vector<uint32_t> core;  //size =nwords
		MemCore(); //constructor




		//initialize memory by reading from a hexdump file
		//the text file has format (\naddr, word, word, [word], ...)
		bool initializeMemory(std::string hex_dump_file); 

		inline uint32_t readWord(uint32_t address) 		
		{
			address=address>>2;
			if(address<nwords) 
				return core[address]; 
			else 
			{
				std::cerr<<"\n MemCore.h: Trying to access an address (0x"<<std::hex<<address<<std::dec<<") larger than memory size";
				return 0;
			}
		};

		inline void writeWord(uint32_t address, uint32_t word)	
		{
			address=address>>2;
			if(address<nwords) 
				core[address]=word; 
			else 
			{
				std::cerr<<"\n MemCore.h: Trying to access an address (0x"<<std::hex<<address<<std::dec<<") larger  than memory size";
				return ;
			}
		};
		inline uint32_t* readBlock(uint32_t address, unsigned int blocksize)
		{
			address=address>>2;
			if((address+blocksize)<nwords) 
				return &core[address]; 
			else 
			{
				std::cerr<<"\n MemCore.h: Trying to access an address (0x"<<std::hex<<address<<std::dec<<") larger than memory size";
				return &core[0];
			}
		};
		inline void writeBlock(uint32_t address, unsigned int blocksize, uint32_t * blockPtr)
		{
			address=address>>2;
			if((address+blocksize)<nwords)
			{

				for(unsigned int i=0;i<blocksize; i++)
				{
					core[address+i]=*blockPtr;
					blockPtr++;
				};
			}
			else
			{
				std::cerr<<"\n MemCore.h: Trying to access an address (0x"<<std::hex<<address<<std::dec<<") larger than memory size";
				return ;
			}
		};


		//--------------------------------------------------------------------------------
		//Masked doubleword read-modify-write helpers.
		//Used to implement STORE and atomic Load-Store (LDSTUB/SWAP) instructions, which
		//write only a subset of the bytes of a doubleword, leaving the rest unchanged.
		//(See SparcCore::execute_PreStore / execute_PreAtomicLoadStore, which compute
		// word0, word1 and byte_mask from the instruction; low nibble of byte_mask
		// selects bytes of word0, high nibble selects bytes of word1.)
		//NOTE: 'address' must already be doubleword(8-byte)-aligned; the caller is
		//responsible for this (address & ~0x7).
		//--------------------------------------------------------------------------------

		static inline uint32_t mergeMaskedBytes(uint32_t existing_word, uint32_t new_word, uint32_t nibble_mask)
		//overwrite, in existing_word, each byte i (i=0..3, MSB to LSB) whose bit is set in nibble_mask
		//with the corresponding byte from new_word. Bytes with a clear mask bit are left unchanged.
		{
			uint32_t result = existing_word;
			for(unsigned int i=0;i<=3;i++)
			{
				if(readBits(nibble_mask, i, i))
				{
					uint32_t byte_val = readBits(new_word, 8*(i+1)-1, 8*i);
					writeBits(result, 8*(i+1)-1, 8*i, byte_val);
				};
			};
			return result;
		};

		inline void writeMaskedDoubleWord(uint32_t address, uint32_t word0, uint32_t word1, uint32_t byte_mask)
		//STORE: read-modify-write the doubleword at address, updating only the bytes selected by byte_mask
		{
			uint32_t existing0 = readWord(address);
			uint32_t existing1 = readWord(address+4);
			writeWord(address,   mergeMaskedBytes(existing0, word0, readBits(byte_mask,3,0)));
			writeWord(address+4, mergeMaskedBytes(existing1, word1, readBits(byte_mask,7,4)));
		};

		inline void atomicReadModifyWrite(uint32_t address, uint32_t word0, uint32_t word1, uint32_t byte_mask, uint32_t& readWord0, uint32_t& readWord1)
		//Atomic Load-Store (LDSTUB/SWAP): read the existing doubleword into readWord0/readWord1
		//(the value returned to the processor), then write back a copy with only the bytes
		//selected by byte_mask overwritten by word0/word1.
		{
			readWord0 = readWord(address);
			readWord1 = readWord(address+4);
			writeWord(address,   mergeMaskedBytes(readWord0, word0, readBits(byte_mask,3,0)));
			writeWord(address+4, mergeMaskedBytes(readWord1, word1, readBits(byte_mask,7,4)));
		};



};

#endif





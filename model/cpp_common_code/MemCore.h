//MemCore.h
//
//A flat, byte-addressed functional memory: a word-addressable array of
//32-bit words underneath. Addresses passed to its read/write functions
//are byte addresses, converted internally to word addresses.

#ifndef MEMCORE_H
#define MEMCORE_H

#include<fstream>
#include<stdint.h>
#include<cassert>
#include<vector>
#include<iostream>
#include"BitManipulation.h"
#include"MemoryInterfaces.h"


class MemCore : public VirtualMemoryInterface
{
	public:
		static const unsigned int memSize = 0x10000000;  //Memory size in bytes = 256MB
		static const unsigned int nwords = memSize>>2; //Number of 32bit words in memory
		std::vector<uint32_t> core;  //size =nwords
		MemCore(); //constructor




		//initialize memory by reading from a hexdump file
		//the text file has format (\naddr, word, word, [word], ...)
		bool initializeMemory(std::string hex_dump_file); 

		//Address of the word holding a given byte address, for setting a
		//gdb watchpoint directly on simulated memory (see
		//debug/sparc.gdb's sparc-watch-mem command and
		//docs/source/examining_core_state_with_gdb.md) -- e.g.
		//`watch *mem.wordPtr(0x2000)`. __attribute__((optimize("O0"))):
		//meant to be `call`ed live from gdb even in a --debug build that
		//otherwise keeps full -O3, same reasoning as
		//Registers::R_r()/CoreLogger::print_state(). __attribute__((used)):
		//unlike those two, nothing in the model itself ever calls this --
		//only gdb does -- so without `used` the compiler drops it entirely
		//(dead-code elimination), leaving no callable body at all.
		__attribute__((optimize("O0"), used))
		inline uint32_t* wordPtr(uint32_t address)
		{
			address = address >> 2;
			assert(address < nwords);
			return &core[address];
		};

		//Plain word read, unrelated to the VirtualMemoryInterface interface
		//below (an overload, not an override -- C++ picks whichever
		//matches a given call site's argument list). Kept exactly as it
		//was before the MMU block: used internally by
		//writeMaskedDoubleWord()/atomicReadModifyWrite() below, and
		//externally wherever code already holds a concrete MemCore and
		//just wants a word, with no ASI/fault reasoning to do (e.g. the
		//MEM checks in each configuration's own sparc_sim.cpp, and
		//MainMemory.sitar).
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

		//VirtualMemoryInterface interface: a flat array never faults
		//(mae always false), and asi doesn't affect a memory with no
		//notion of address spaces or translation. LOAD reads both words
		//of the doubleword at request.address (already aligned by the
		//caller -- Ref SparcStateMachine.cpp), matching STORE/ATOMIC_LS's
		//own doubleword shape; IFETCH only ever needs one word, left in
		//readWord0 (readWord1 unused, Ref MemoryInterfaces.h).
		inline void access(const VirtualMemoryRequest& request, VirtualMemoryResponse& response) override
		{
			response.valid     = true;
			response.mae       = false;
			response.readWord0 = 0;
			response.readWord1 = 0;

			switch (request.accessType)
			{
				case MemAccessType::IFETCH:
					response.readWord0 = readWord(request.address);
					break;
				case MemAccessType::LOAD:
					response.readWord0 = readWord(request.address);
					response.readWord1 = readWord(request.address + 4);
					break;
				case MemAccessType::STORE:
				{
					uint32_t existing0 = readWord(request.address);
					uint32_t existing1 = readWord(request.address + 4);
					writeWord(request.address,     mergeMaskedBytes(existing0, request.word0, readBits(request.byteMask, 3, 0)));
					writeWord(request.address + 4, mergeMaskedBytes(existing1, request.word1, readBits(request.byteMask, 7, 4)));
					break;
				}
				case MemAccessType::ATOMIC_LS:
					response.readWord0 = readWord(request.address);
					response.readWord1 = readWord(request.address + 4);
					writeWord(request.address,     mergeMaskedBytes(response.readWord0, request.word0, readBits(request.byteMask, 3, 0)));
					writeWord(request.address + 4, mergeMaskedBytes(response.readWord1, request.word1, readBits(request.byteMask, 7, 4)));
					break;
				case MemAccessType::FLUSH:
				case MemAccessType::NO_ACCESS:
				default:
					break;
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

		//STORE/ATOMIC_LS logic itself now lives inline in access() above
		//(the VirtualMemoryInterface entry point) -- mergeMaskedBytes()
		//stays a public static helper since MainMemory.cpp also uses it
		//directly for the analogous physical-side doubleword merge.

};

#endif





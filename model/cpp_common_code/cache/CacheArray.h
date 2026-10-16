//CacheArray.h
//Original Author: Neha Karanjkar
//Model Author: Claude Opus 5.5 (high)
//The model code was adapted from a Sparc v8 core simulation model written
//by the first author in C++ and Sitar (2015-2017).
//
//One virtually indexed, virtually tagged (VIVT) cache's storage and
//lookup: the lines, their tags, and replacement. No access policy at all
//(what is cached, when to fetch, write-through): that is
//L1CachesCore's job, which owns two of these.
//
//Organization follows AJIT's own L1 caches (cache/src/CacheInterface.c
//in the ajit-toolchain repo's 64-bit multi-core C model):
//  - lines of CACHE_LINE_BYTES (64) bytes, 8 doublewords;
//  - numberOfLines lines in sets of `ways` lines (ways = 1: direct mapped);
//  - set index = (va / 64) mod sets;
//  - tag = (va / (64 * sets)) | (context << 24), so the same virtual
//    address in two MMU contexts is two different lines;
//  - each line also keeps the page's ACC bits (Ref Appendix H), so a hit
//    can be refused if the access type is not allowed;
//  - replacement: an invalid way if there is one, else round-robin within
//    the set.

#ifndef CACHE_ARRAY_H
#define CACHE_ARRAY_H

#include <stdint.h>
#include <vector>
#include "MemoryInterfaces.h"

class CacheArray
{
	public:
		struct Line
		{
			bool     valid;
			uint32_t tag;
			uint8_t  acc;
			uint64_t data[CACHE_LINE_DOUBLEWORDS];
		};

		//numberOfLines and ways must be powers of two, ways <= numberOfLines.
		CacheArray(unsigned int numberOfLines, unsigned int ways);

		//Reorganizes (and empties) the cache. Same rules as the constructor.
		void configure(unsigned int numberOfLines, unsigned int ways);

		unsigned int numberOfLines() const { return (unsigned int) lines_.size(); }
		unsigned int ways()          const { return ways_; }
		unsigned int sets()          const { return sets_; }

		//Index of the valid line holding (va, context), or -1.
		int find(uint32_t va, uint32_t context) const;

		//Picks the line to hold (va, context), which must not already be
		//cached, and installs `data` there.
		int fill(uint32_t va, uint32_t context, uint8_t acc, const uint64_t* data);

		uint64_t readDoubleword(int index, uint32_t va) const;

		//Merges data's bytes selected by byteMask (bit j = bits [8j+7:8j],
		//the same packing as VirtualMemoryRequest's word0/word1) into the
		//doubleword holding va.
		void writeBytes(int index, uint32_t va, uint64_t data, uint8_t byteMask);

		void flushAll();

		const Line& line(int index) const { return lines_[index]; }

	private:
		unsigned int setIndex(uint32_t va) const;
		uint32_t     tagOf(uint32_t va, uint32_t context) const;

		std::vector<Line> lines_;
		std::vector<int>  lastReplacedWay_; //per set, for round-robin
		unsigned int      ways_;
		unsigned int      sets_;
		unsigned int      logSets_;
};

#endif

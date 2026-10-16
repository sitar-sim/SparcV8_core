//CacheArray.cpp
//Original Authors: Madhav Desai, Neha Karanjkar, Aniket Deshmukh
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the VIVT L1 cache model developed by
//the original authors.

#include "CacheArray.h"
#include <cassert>

namespace
{
	unsigned int log2Exact(unsigned int x)
	{
		unsigned int log = 0;
		while ((1u << log) < x)
			log++;
		assert((1u << log) == x && "CacheArray: sizes must be powers of two");
		return log;
	}

	const unsigned int LOG_LINE_BYTES = 6; //CACHE_LINE_BYTES = 64
}

CacheArray::CacheArray(unsigned int numberOfLines, unsigned int ways)
{
	configure(numberOfLines, ways);
}

void CacheArray::configure(unsigned int numberOfLines, unsigned int ways)
{
	assert(ways >= 1 && ways <= numberOfLines);
	log2Exact(numberOfLines);
	ways_    = ways;
	sets_    = numberOfLines / ways;
	logSets_ = log2Exact(sets_);
	lines_.assign(numberOfLines, Line());
	lastReplacedWay_.assign(sets_, -1);
	flushAll();
}

unsigned int CacheArray::setIndex(uint32_t va) const
{
	return (va >> LOG_LINE_BYTES) & (sets_ - 1);
}

uint32_t CacheArray::tagOf(uint32_t va, uint32_t context) const
{
	return (va >> (LOG_LINE_BYTES + logSets_)) | (context << 24);
}

int CacheArray::find(uint32_t va, uint32_t context) const
{
	unsigned int first = setIndex(va) * ways_;
	uint32_t     tag   = tagOf(va, context);
	for (unsigned int w = 0; w < ways_; w++)
		if (lines_[first + w].valid && lines_[first + w].tag == tag)
			return (int) (first + w);
	return -1;
}

int CacheArray::fill(uint32_t va, uint32_t context, uint8_t acc, const uint64_t* data)
{
	assert(find(va, context) < 0);
	unsigned int set   = setIndex(va);
	unsigned int first = set * ways_;

	int way = -1;
	for (unsigned int w = 0; w < ways_ && way < 0; w++)
		if (!lines_[first + w].valid)
			way = (int) w;
	if (way < 0)
		way = (lastReplacedWay_[set] + 1) % (int) ways_;
	lastReplacedWay_[set] = way;

	Line& l = lines_[first + way];
	l.valid = true;
	l.tag   = tagOf(va, context);
	l.acc   = acc;
	for (unsigned int i = 0; i < CACHE_LINE_DOUBLEWORDS; i++)
		l.data[i] = data[i];
	return (int) (first + way);
}

uint64_t CacheArray::readDoubleword(int index, uint32_t va) const
{
	return lines_[index].data[(va >> 3) & (CACHE_LINE_DOUBLEWORDS - 1)];
}

void CacheArray::writeBytes(int index, uint32_t va, uint64_t data, uint8_t byteMask)
{
	uint64_t& dw = lines_[index].data[(va >> 3) & (CACHE_LINE_DOUBLEWORDS - 1)];
	for (unsigned int j = 0; j < 8; j++)
		if (byteMask & (1u << j))
		{
			uint64_t laneMask = 0xFFULL << (8 * j);
			dw = (dw & ~laneMask) | (data & laneMask);
		}
}

void CacheArray::flushAll()
{
	for (size_t i = 0; i < lines_.size(); i++)
		lines_[i].valid = false;
	for (size_t s = 0; s < lastReplacedWay_.size(); s++)
		lastReplacedWay_[s] = -1;
}

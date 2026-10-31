//ScratchPadCore.cpp
//Original Author: Neha Karanjkar
//Model Author: Claude Opus 5.5 (high)
//The model code was adapted from a Sparc v8 core simulation model written
//by the first author in C++ and Sitar (2015-2017).

#include "ScratchPadCore.h"
#include "../MemCore.h"

ScratchPadCore::ScratchPadCore()
{
	for (unsigned int i = 0; i < NUM_WORDS; i++)
		words[i] = 0;
}

uint32_t ScratchPadCore::readRegister(uint32_t wordAddress, uint8_t laneMask)
{
	(void) laneMask; //a read returns the whole word, the requester picks its lanes
	return words[wordIndex(wordAddress)];
}

void ScratchPadCore::writeRegister(uint32_t wordAddress, uint8_t laneMask, uint32_t data)
{
	unsigned int i = wordIndex(wordAddress);
	words[i] = MemCore::mergeMaskedBytes(words[i], data, laneMask);
}

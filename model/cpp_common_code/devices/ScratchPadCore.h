//ScratchPadCore.h
//Original Author: Neha Karanjkar
//Model Author: Claude Opus 5.5 (high)
//The model code was adapted from a Sparc v8 core simulation model written
//by the first author in C++ and Sitar (2015-2017).
//
//A small scratch-pad memory: 32 words of plain read/write storage in
//the device window, shared by every core. Being a device, it is never
//cached, so all cores always see the same value in it, even before
//their MMUs and caches are set up. That makes it the natural place for
//boot-time flags between cores (AJIT's CORTOS keeps its page-table-ready
//and init-done flags in its first two words).
//
//Behavior follows AJIT's scratch-pad (devices/src/ScratchPad.c in the
//ajit-toolchain repo's 64-bit multi-core C model):
//  - 32 words, all 0 at reset;
//  - the word is picked by address bits [6:2] only, so the 32 words
//    repeat every 128 bytes across the device's address range
//    (SCRATCH_PAD_MIN to SCRATCH_PAD_MAX, 1 KB);
//  - reads have no side effects.
//One difference: a write here merges only the byte lanes in its mask
//(the same convention every device class here follows, Ref
//DeviceAddresses.h), while AJIT's C model writes the whole word for any
//mask. Word stores, the only kind CORTOS uses, behave the same in both.

#ifndef SCRATCH_PAD_CORE_H
#define SCRATCH_PAD_CORE_H

#include <stdint.h>

class ScratchPadCore
{
	public:
		static const unsigned int NUM_WORDS = 32;

		ScratchPadCore();

		uint32_t words[NUM_WORDS];

		//Register access, Ref DeviceAddresses.h's header comment for the
		//(word address, lane mask, data) convention shared by all devices.
		uint32_t readRegister (uint32_t wordAddress, uint8_t laneMask);
		void     writeRegister(uint32_t wordAddress, uint8_t laneMask, uint32_t data);

		static unsigned int wordIndex(uint32_t wordAddress) { return (wordAddress & 0x7F) >> 2; }
};

#endif

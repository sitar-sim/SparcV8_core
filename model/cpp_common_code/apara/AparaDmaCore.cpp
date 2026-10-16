//AparaDmaCore.cpp
//Original author: Madhav Desai, IITB
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the APARA engine specification and
//reference C implementation developed by Prof. Madhav Desai, IITB

#include "AparaDmaCore.h"
#include "AparaCore.h"
#include <cstring>
#include <algorithm>

namespace apara
{

void AparaDmaCore::reset()
{
	std::memset(reg_, 0, sizeof(reg_));
	for (unsigned int c = 0; c < CHANNELS; c++)
		progress_[c] = Progress{false, 0, 0};
	nextChannel_ = 0;
	interrupt_ = false;
}

uint32_t AparaDmaCore::readRegister(unsigned int channel, unsigned int index) const
{
	return reg_[channel % CHANNELS][index % REGISTERS];
}

void AparaDmaCore::writeRegister(unsigned int channel, unsigned int index, uint32_t value, uint8_t laneMask, uint64_t now)
{
	unsigned int c = channel % CHANNELS, i = index % REGISTERS;
	uint32_t mask = 0;
	for (unsigned int b = 0; b < 4; b++)
		if (laneMask & (1u << b))
			mask |= 0xFFu << (8 * b);
	reg_[c][i] = (reg_[c][i] & ~mask) | (value & mask);
	if (i != 0)
		return;
	uint32_t r0 = reg_[c][0];
	if (!(r0 & FLAG_INTERRUPT_ENABLE))
		interrupt_ = false;
	if ((r0 & FLAG_SCHEDULED) && !(r0 & (FLAG_STARTED | FLAG_COMPLETED | FLAG_ERROR)) && !progress_[c].active)
		start(c, now);
}

void AparaDmaCore::start(unsigned int c, uint64_t now)
{
	uint32_t* R = reg_[c];
	R[0] = (R[0] & ~FLAG_SCHEDULED) | FLAG_STARTED;
	R[7] = (uint32_t) now;
	uint8_t op = (uint8_t) (R[0] >> 24);
	if ((op != LOAD && op != STORE) || R[6] == 0)
	{
		finish(c, now, op != LOAD && op != STORE);
		return;
	}
	if (R[4] == 0)
	{
		finish(c, now, false);
		return;
	}
	progress_[c] = Progress{true, 0, 0};
}

bool AparaDmaCore::nextPiece(Piece& p)
{
	for (unsigned int i = 0; i < CHANNELS; i++)
	{
		unsigned int c = (nextChannel_ + i) % CHANNELS;
		if (!progress_[c].active)
			continue;
		const uint32_t* R = reg_[c];
		const Progress& g = progress_[c];
		bool load = (R[0] >> 24) == LOAD;
		uint64_t srcBase = ((uint64_t) ((R[0] >> 20) & 0xF) << 32) | R[1];
		uint64_t dstBase = ((uint64_t) ((R[0] >> 16) & 0xF) << 32) | R[2];
		uint64_t bpb = R[6], gap = R[5];
		//A load gathers (the source steps by the gap), a store scatters.
		uint64_t src = srcBase + g.burst * (load ? gap : bpb) + g.offset;
		uint64_t dst = dstBase + g.burst * (load ? bpb : gap) + g.offset;
		uint64_t left = bpb - g.offset;
		unsigned int bytes = (unsigned int) std::min<uint64_t>(left, std::min(8 - (src & 7), 8 - (dst & 7)));
		p.channel = c;
		p.toDmem = load;
		p.systemAddress = load ? src : dst;
		p.dmemAddress = (uint32_t) ((load ? dst : src) % DMEM_BYTES);
		p.bytes = bytes;
		return true;
	}
	return false;
}

void AparaDmaCore::pieceDone(const Piece& p, uint64_t now)
{
	unsigned int c = p.channel % CHANNELS;
	Progress& g = progress_[c];
	if (!g.active)
		return;
	g.offset += p.bytes;
	if (g.offset >= reg_[c][6])
	{
		g.offset = 0;
		g.burst++;
		if (g.burst >= reg_[c][4])
			finish(c, now, false);
	}
	nextChannel_ = (c + 1) % CHANNELS;
}

void AparaDmaCore::finish(unsigned int c, uint64_t now, bool error)
{
	uint32_t* R = reg_[c];
	progress_[c].active = false;
	R[0] = (R[0] & ~FLAG_STARTED) | FLAG_COMPLETED | (error ? FLAG_ERROR : 0);
	R[6] = (uint32_t) now;
	if (R[0] & FLAG_INTERRUPT_ENABLE)
		interrupt_ = true;
}

bool AparaDmaCore::busy() const
{
	for (unsigned int c = 0; c < CHANNELS; c++)
		if (progress_[c].active)
			return true;
	return false;
}

}

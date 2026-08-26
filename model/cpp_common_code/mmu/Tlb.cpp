//Tlb.cpp

#include "Tlb.h"
#include "Addresses.h"
#include "BitManipulation.h"

Tlb::Tlb()
{
	//log2(LEVEL3_SETS), computed once here rather than on every
	//lookup/insert. LEVEL3_SETS' own static_asserts (Tlb.h) already
	//guarantee it's a power of two, so this loop always lands on an
	//exact result.
	level3SetIndexBits_ = 0;
	while ((1 << level3SetIndexBits_) < LEVEL3_SETS) level3SetIndexBits_++;

	clear();
}

void Tlb::clear()
{
	for (int i = 0; i < LEVEL0_ENTRIES; i++) level0_[i].valid = false;
	for (int i = 0; i < LEVEL1_ENTRIES; i++) level1_[i].valid = false;
	for (int i = 0; i < LEVEL2_ENTRIES; i++) level2_[i].valid = false;
	for (int s = 0; s < LEVEL3_SETS; s++)
		for (int w = 0; w < LEVEL3_WAYS; w++)
			level3_[s][w].valid = false;

	nextReplace0_ = 0;
	nextReplace1_ = 0;
	nextReplace2_ = 0;
	for (int s = 0; s < LEVEL3_SETS; s++) nextReplace3_[s] = 0;
}

uint32_t Tlb::vaTagForLevel(uint32_t va, uint8_t level)
{
	switch (level)
	{
		case 0:  return 0;                    //context alone identifies a level-0 entry
		case 1:  return readBits(va, 31, 24);  //16MB region
		case 2:  return readBits(va, 31, 18);  //256KB region
		default: return readBits(va, 31, 12);  //4KB page
	}
}

int Tlb::level3SetIndex(uint32_t va) const
{
	//The set-index field is level3SetIndexBits_ wide, starting at
	//VA[12] (Ref Tlb.h's class comment). readBits() requires h >= l, so
	//the degenerate 1-set case (0 bits wide) needs its own branch --
	//every VA maps to the one and only set.
	if (level3SetIndexBits_ == 0) return 0;
	return (int) readBits(va, 12 + level3SetIndexBits_ - 1, 12);
}

int Tlb::vaTagBitsForLevel(uint8_t level)
{
	switch (level)
	{
		case 0:  return 0;
		case 1:  return 8;
		case 2:  return 14;
		default: return 20;
	}
}

bool Tlb::lookup(uint32_t va, uint32_t context, uint32_t& pte, uint8_t& level, uint64_t& phyAddrOfPte) const
{
	for (int i = 0; i < LEVEL0_ENTRIES; i++)
	{
		const Entry& e = level0_[i];
		if (e.valid && e.context == context)
		{
			pte = e.pte; level = 0; phyAddrOfPte = e.phyAddrOfPte;
			return true;
		}
	}

	uint32_t tag1 = vaTagForLevel(va, 1);
	for (int i = 0; i < LEVEL1_ENTRIES; i++)
	{
		const Entry& e = level1_[i];
		if (e.valid && e.context == context && e.vaTag == tag1)
		{
			pte = e.pte; level = 1; phyAddrOfPte = e.phyAddrOfPte;
			return true;
		}
	}

	uint32_t tag2 = vaTagForLevel(va, 2);
	for (int i = 0; i < LEVEL2_ENTRIES; i++)
	{
		const Entry& e = level2_[i];
		if (e.valid && e.context == context && e.vaTag == tag2)
		{
			pte = e.pte; level = 2; phyAddrOfPte = e.phyAddrOfPte;
			return true;
		}
	}

	uint32_t tag3 = vaTagForLevel(va, 3);
	int set = level3SetIndex(va);
	for (int w = 0; w < LEVEL3_WAYS; w++)
	{
		const Entry& e = level3_[set][w];
		if (e.valid && e.context == context && e.vaTag == tag3)
		{
			pte = e.pte; level = 3; phyAddrOfPte = e.phyAddrOfPte;
			return true;
		}
	}

	return false;
}

void Tlb::insert(uint32_t va, uint32_t context, uint32_t pte, uint8_t level, uint64_t phyAddrOfPte)
{
	Entry newEntry;
	newEntry.valid        = true;
	newEntry.vaTag        = vaTagForLevel(va, level);
	newEntry.context      = context;
	newEntry.pte          = pte;
	newEntry.level        = level;
	newEntry.phyAddrOfPte = phyAddrOfPte;

	if (level == 0)
	{
		int slot = -1;
		for (int i = 0; i < LEVEL0_ENTRIES; i++) if (!level0_[i].valid) { slot = i; break; }
		if (slot < 0) { slot = nextReplace0_; nextReplace0_ = (nextReplace0_ + 1) % LEVEL0_ENTRIES; }
		level0_[slot] = newEntry;
	}
	else if (level == 1)
	{
		int slot = -1;
		for (int i = 0; i < LEVEL1_ENTRIES; i++) if (!level1_[i].valid) { slot = i; break; }
		if (slot < 0) { slot = nextReplace1_; nextReplace1_ = (nextReplace1_ + 1) % LEVEL1_ENTRIES; }
		level1_[slot] = newEntry;
	}
	else if (level == 2)
	{
		int slot = -1;
		for (int i = 0; i < LEVEL2_ENTRIES; i++) if (!level2_[i].valid) { slot = i; break; }
		if (slot < 0) { slot = nextReplace2_; nextReplace2_ = (nextReplace2_ + 1) % LEVEL2_ENTRIES; }
		level2_[slot] = newEntry;
	}
	else
	{
		int set = level3SetIndex(va);
		int slot = -1;
		for (int w = 0; w < LEVEL3_WAYS; w++) if (!level3_[set][w].valid) { slot = w; break; }
		if (slot < 0) { slot = nextReplace3_[set]; nextReplace3_[set] = (nextReplace3_[set] + 1) % LEVEL3_WAYS; }
		level3_[set][slot] = newEntry;
	}
}

void Tlb::updatePte(uint32_t va, uint32_t context, uint8_t level, uint32_t newPte)
{
	if (level == 0)
	{
		for (int i = 0; i < LEVEL0_ENTRIES; i++)
			if (level0_[i].valid && level0_[i].context == context) { level0_[i].pte = newPte; return; }
	}
	else if (level == 1)
	{
		uint32_t tag = vaTagForLevel(va, 1);
		for (int i = 0; i < LEVEL1_ENTRIES; i++)
			if (level1_[i].valid && level1_[i].context == context && level1_[i].vaTag == tag) { level1_[i].pte = newPte; return; }
	}
	else if (level == 2)
	{
		uint32_t tag = vaTagForLevel(va, 2);
		for (int i = 0; i < LEVEL2_ENTRIES; i++)
			if (level2_[i].valid && level2_[i].context == context && level2_[i].vaTag == tag) { level2_[i].pte = newPte; return; }
	}
	else
	{
		uint32_t tag = vaTagForLevel(va, 3);
		int set = level3SetIndex(va);
		for (int w = 0; w < LEVEL3_WAYS; w++)
			if (level3_[set][w].valid && level3_[set][w].context == context && level3_[set][w].vaTag == tag) { level3_[set][w].pte = newPte; return; }
	}
}

//Ref Table H-2 flush criteria: page/segment/region flush types match if
//((ACC of the cached PTE) >= 6, OR the contexts are equal), AND the VA
//ranges match (see the mixed-precision comment in Tlb.h). Context flush
//matches if (ACC <= 5) AND the contexts are equal, with no VA check.
//Entire flush is handled by the caller (a plain clear()).
static bool pteAccIsGlobal(uint32_t pte) { return readBits(pte, 4, 2) >= 6; }

void Tlb::flush(uint8_t flushType, uint32_t va, uint32_t context)
{
	if (flushType == 4) { clear(); return; }

	if (flushType == 3)
	{
		for (int i = 0; i < LEVEL0_ENTRIES; i++)
			if (level0_[i].valid && !pteAccIsGlobal(level0_[i].pte) && level0_[i].context == context) level0_[i].valid = false;
		for (int i = 0; i < LEVEL1_ENTRIES; i++)
			if (level1_[i].valid && !pteAccIsGlobal(level1_[i].pte) && level1_[i].context == context) level1_[i].valid = false;
		for (int i = 0; i < LEVEL2_ENTRIES; i++)
			if (level2_[i].valid && !pteAccIsGlobal(level2_[i].pte) && level2_[i].context == context) level2_[i].valid = false;
		for (int s = 0; s < LEVEL3_SETS; s++)
			for (int w = 0; w < LEVEL3_WAYS; w++)
				if (level3_[s][w].valid && !pteAccIsGlobal(level3_[s][w].pte) && level3_[s][w].context == context) level3_[s][w].valid = false;
		return;
	}

	//page=0 -> 20 bits, segment=1 -> 14 bits, region=2 -> 8 bits.
	int flushBits = (flushType == 0) ? 20 : (flushType == 1) ? 14 : 8;

	Entry* const levels[4] = {0, 0, 0, 0}; //placeholder, iterate arrays directly below
	(void) levels;

	for (int i = 0; i < LEVEL0_ENTRIES; i++)
	{
		Entry& e = level0_[i];
		if (!e.valid) continue;
		bool accOk = pteAccIsGlobal(e.pte) || (e.context == context);
		int n = flushBits < vaTagBitsForLevel(0) ? flushBits : vaTagBitsForLevel(0); //min(), level 0 always 0
		bool vaOk = (n == 0); //level 0 stores no VA precision: any page/segment/region within this context's whole space matches
		if (accOk && vaOk) e.valid = false;
	}
	for (int i = 0; i < LEVEL1_ENTRIES; i++)
	{
		Entry& e = level1_[i];
		if (!e.valid) continue;
		bool accOk = pteAccIsGlobal(e.pte) || (e.context == context);
		int entryBits = vaTagBitsForLevel(1);
		int n = flushBits < entryBits ? flushBits : entryBits;
		uint32_t queryTop = n == 0 ? 0 : (va >> (32 - n));
		uint32_t entryTop = n == 0 ? 0 : (e.vaTag >> (entryBits - n));
		if (accOk && queryTop == entryTop) e.valid = false;
	}
	for (int i = 0; i < LEVEL2_ENTRIES; i++)
	{
		Entry& e = level2_[i];
		if (!e.valid) continue;
		bool accOk = pteAccIsGlobal(e.pte) || (e.context == context);
		int entryBits = vaTagBitsForLevel(2);
		int n = flushBits < entryBits ? flushBits : entryBits;
		uint32_t queryTop = n == 0 ? 0 : (va >> (32 - n));
		uint32_t entryTop = n == 0 ? 0 : (e.vaTag >> (entryBits - n));
		if (accOk && queryTop == entryTop) e.valid = false;
	}
	for (int s = 0; s < LEVEL3_SETS; s++)
	{
		for (int w = 0; w < LEVEL3_WAYS; w++)
		{
			Entry& e = level3_[s][w];
			if (!e.valid) continue;
			bool accOk = pteAccIsGlobal(e.pte) || (e.context == context);
			int entryBits = vaTagBitsForLevel(3);
			int n = flushBits < entryBits ? flushBits : entryBits;
			uint32_t queryTop = n == 0 ? 0 : (va >> (32 - n));
			uint32_t entryTop = n == 0 ? 0 : (e.vaTag >> (entryBits - n));
			if (accOk && queryTop == entryTop) e.valid = false;
		}
	}
}

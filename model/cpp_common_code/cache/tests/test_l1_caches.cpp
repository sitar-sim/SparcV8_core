//test_l1_caches.cpp
//
//Standalone unit test for L1CachesCore and CacheArray, against a fake MMU
//(a flat memory that counts what reaches it), to check the access policy
//described in L1CachesCore.h: hits and misses, line fills, non-cacheable
//misses, write-through and write-allocate, atomics, every flush, ACC
//checks, contexts, and set-associative replacement.
//
//Lives in cache/tests/, one level below the cache sources, so that
//model/build_scripts/build_cpp_model.sh's cpp_common_code/*/*.cpp glob
//doesn't pick up its main().
//
//Build:
//  g++ -std=c++11 -I.. -I../.. -o test_l1_caches test_l1_caches.cpp ../L1CachesCore.cpp ../CacheArray.cpp
//Run:
//  ./test_l1_caches

#include "../L1CachesCore.h"
#include "AsiValues.h"
#include <iostream>
#include <map>

static int numChecks = 0;
static int numFailed = 0;

static void check(bool condition, const std::string& description)
{
	numChecks++;
	if (condition)
		std::cout << "PASS: " << description << "\n";
	else
	{
		std::cout << "FAIL: " << description << "\n";
		numFailed++;
	}
}

//A flat, word-addressed memory standing in for the MMU.
class FakeMmu : public VirtualMemoryInterface
{
	public:
		std::map<uint32_t, uint32_t> words;
		bool    cacheable = true;
		bool    suppressedFault = false;
		uint8_t acc       = 3;
		int     lineReads = 0, loads = 0, stores = 0, atomics = 0, ifetches = 0, other = 0;
		int     dwordsRead = 0; //doublewords actually read for line reads

		//A virtual page mapped to a different physical page, for synonyms.
		//Pages with no entry are identity mapped.
		std::map<uint32_t, uint32_t> pageMap;
		uint32_t physical(uint32_t va)
		{
			return pageMap.count(va & ~0xFFFu) ? pageMap[va & ~0xFFFu] | (va & 0xFFFu) : va;
		}

		uint32_t word(uint32_t a) { a = physical(a); return words.count(a) ? words[a] : 0; }
		uint64_t dword(uint32_t a) { a &= ~7u; return ((uint64_t) word(a + 4) << 32) | word(a); }

		void access(const VirtualMemoryRequest& q, VirtualMemoryResponse& r) override
		{
			r.valid = true;
			r.mae   = false;
			switch (q.accessType)
			{
				case MemAccessType::READ_LINE:
				{
					lineReads++;
					r.cacheable = cacheable;
					r.acc       = acc;
					r.physicalAddress = physical(q.address);
					unsigned int off = (q.address >> 3) & 7;
					if (cacheable)
					{
						for (unsigned int i = 0; i < 8; i++)
							r.line[i] = dword((q.address & ~63u) + 8 * i);
						dwordsRead += 8;
					}
					else if (q.byteMask != 0)
					{
						r.line[off] = dword(q.address);
						dwordsRead += 1;
					}
					r.readWord0 = (uint32_t) r.line[off];
					r.readWord1 = (uint32_t) (r.line[off] >> 32);
					break;
				}
				case MemAccessType::LOAD:
					loads++;
					r.readWord0 = word(q.address & ~7u);
					r.readWord1 = word((q.address & ~7u) + 4);
					break;
				case MemAccessType::IFETCH:
					ifetches++;
					r.readWord0 = word(q.address & ~3u);
					break;
				case MemAccessType::STORE:
				case MemAccessType::ATOMIC_LS:
				{
					if (suppressedFault) { r.cacheable = false; r.physicalAddressValid = false; return; } //as with the NF bit set
					if (q.accessType == MemAccessType::STORE) { stores++; r.cacheable = cacheable; } else atomics++;
					r.physicalAddress = physical(q.address);
					r.physicalAddressValid = true;
					uint32_t a = q.address & ~7u;
					r.readWord0 = word(a);
					r.readWord1 = word(a + 4);
					uint32_t w[2] = {word(a), word(a + 4)};
					uint32_t in[2] = {q.word0, q.word1};
					for (int h = 0; h < 2; h++)
						for (int b = 0; b < 4; b++)
							if (q.byteMask & (1u << (4 * h + b)))
								w[h] = (w[h] & ~(0xFFu << (8 * b))) | (in[h] & (0xFFu << (8 * b)));
					words[physical(a)] = w[0];
					words[physical(a + 4)] = w[1];
					break;
				}
				default:
					other++;
					break;
			}
		}
};

static VirtualMemoryRequest req(MemAccessType t, uint32_t address, uint32_t asi,
                                uint32_t w0 = 0, uint32_t w1 = 0, uint32_t mask = 0)
{
	return VirtualMemoryRequest{true, t, address, asi, w0, w1, mask};
}

static VirtualMemoryResponse run(L1CachesCore& c, const VirtualMemoryRequest& q)
{
	VirtualMemoryResponse r{};
	c.access(q, r);
	return r;
}

static void testInstructionHitMiss()
{
	FakeMmu mmu;
	mmu.words[0x1000] = 0xAAAA0000; mmu.words[0x1004] = 0xBBBB0004; mmu.words[0x103C] = 0xCCCC003C;
	L1CachesCore c(mmu);

	VirtualMemoryResponse r = run(c, req(MemAccessType::IFETCH, 0x1004, ASI_SUPERVISOR_INSTRUCTION));
	check(r.readWord0 == 0xBBBB0004 && mmu.lineReads == 1, "ifetch miss: one line read, the right word returned");
	r = run(c, req(MemAccessType::IFETCH, 0x1000, ASI_SUPERVISOR_INSTRUCTION));
	check(r.readWord0 == 0xAAAA0000 && mmu.lineReads == 1, "ifetch in the same line hits, nothing downstream");
	r = run(c, req(MemAccessType::IFETCH, 0x103C, ASI_SUPERVISOR_INSTRUCTION));
	check(r.readWord0 == 0xCCCC003C && mmu.lineReads == 1, "the last word of the line hits too");
	check(c.instructionStats.readHits == 2 && c.instructionStats.readMisses == 1, "instruction cache counts 2 hits, 1 miss");
}

static void testDataReadAndNonCacheable()
{
	FakeMmu mmu;
	mmu.words[0x2000] = 1; mmu.words[0x2004] = 2;
	L1CachesCore c(mmu);
	VirtualMemoryResponse r = run(c, req(MemAccessType::LOAD, 0x2000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	check(r.readWord0 == 1 && r.readWord1 == 2 && mmu.lineReads == 1, "load miss fills the line, returns the doubleword");
	run(c, req(MemAccessType::LOAD, 0x2008, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	check(mmu.lineReads == 1, "load from the same line hits");

	FakeMmu u;
	u.cacheable = false;
	u.words[0x3000] = 7;
	L1CachesCore d(u);
	run(d, req(MemAccessType::LOAD, 0x3000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	r = run(d, req(MemAccessType::LOAD, 0x3000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	check(r.readWord0 == 7 && u.lineReads == 2 && u.dwordsRead == 2,
	      "non-cacheable: every load goes down, one doubleword each, nothing installed");
	check(d.dataStats.uncachedMisses == 2, "non-cacheable misses are counted");
}

static void testBypassAsisForwarded()
{
	FakeMmu mmu;
	L1CachesCore c(mmu);
	run(c, req(MemAccessType::LOAD, 0x4000, 0x20, 0, 0, 0x0F));
	run(c, req(MemAccessType::LOAD, 0x4000, 0x20, 0, 0, 0x0F));
	check(mmu.loads == 2 && mmu.lineReads == 0, "bypass-ASI loads are forwarded every time, never cached");
}

static void testWriteThroughAndAllocate()
{
	FakeMmu mmu;
	mmu.words[0x5000] = 0x11111111;
	L1CachesCore c(mmu);

	run(c, req(MemAccessType::STORE, 0x5000, ASI_SUPERVISOR_DATA, 0x22222222, 0, 0x0F));
	check(mmu.stores == 1 && mmu.word(0x5000) == 0x22222222, "store miss is written through");
	check(mmu.lineReads == 1 && c.dataStats.lineFills == 1, "store miss then allocates the line");

	run(c, req(MemAccessType::STORE, 0x5004, ASI_SUPERVISOR_DATA, 0, 0x33333333, 0xF0));
	check(mmu.stores == 2 && mmu.word(0x5004) == 0x33333333 && mmu.lineReads == 1,
	      "store hit is written through too, no new fill");
	VirtualMemoryResponse r = run(c, req(MemAccessType::LOAD, 0x5000, ASI_SUPERVISOR_DATA, 0, 0, 0xFF));
	check(r.readWord0 == 0x22222222 && r.readWord1 == 0x33333333 && mmu.lineReads == 1,
	      "the cached line holds both stored words");

	FakeMmu u;
	u.cacheable = false;
	L1CachesCore d(u);
	run(d, req(MemAccessType::STORE, 0x6000, ASI_SUPERVISOR_DATA, 5, 0, 0x0F));
	check(u.lineReads == 0 && d.dataStats.lineFills == 0,
	      "store to a non-cacheable line: no write-allocate read at all (the MMU's store reply says so)");
}

static void testAtomicUpdatesCachedLine()
{
	FakeMmu mmu;
	mmu.words[0x7000] = 0x000000FF;
	L1CachesCore c(mmu);
	run(c, req(MemAccessType::LOAD, 0x7000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	VirtualMemoryResponse r = run(c, req(MemAccessType::ATOMIC_LS, 0x7000, ASI_SUPERVISOR_DATA, 0xAB000000, 0, 0x08));
	check(mmu.atomics == 1 && r.readWord0 == 0x000000FF, "atomic is forwarded and returns the old value");
	r = run(c, req(MemAccessType::LOAD, 0x7000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	check(r.readWord0 == 0xAB0000FF && mmu.lineReads == 1, "atomic's stored byte is visible in the cached line");
}

static void testFlushes()
{
	FakeMmu mmu;
	L1CachesCore c(mmu);
	auto warm = [&]() {
		run(c, req(MemAccessType::IFETCH, 0x8000, ASI_SUPERVISOR_INSTRUCTION));
		run(c, req(MemAccessType::LOAD, 0x9000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	};
	auto cachedI = [&]() { return c.instructionCache.find(0x8000, 0) >= 0; };
	auto cachedD = [&]() { return c.dataCache.find(0x9000, 0) >= 0; };

	warm();
	run(c, req(MemAccessType::STORE, 0, 0x10, 0, 0, 0x0F));
	check(!cachedI() && !cachedD() && mmu.stores == 0, "ASI 0x10 store flushes both caches, not forwarded");
	warm();
	run(c, req(MemAccessType::STORE, 0, 0x18, 0, 0, 0x0F));
	check(!cachedI() && cachedD(), "ASI 0x18 store flushes only the instruction cache");
	warm();
	run(c, req(MemAccessType::FLUSH, 0x8000, ASI_SUPERVISOR_DATA));
	check(!cachedI() && !cachedD(), "the FLUSH instruction flushes both caches");
	warm();
	run(c, req(MemAccessType::STORE, 0x000, ASI_MMU_REGISTER, 0x100, 0, 0x0F));
	check(!cachedI() && !cachedD() && mmu.stores == 1, "an MMU control register write is forwarded, then flushes both");
	warm();
	run(c, req(MemAccessType::STORE, 0x200, ASI_MMU_REGISTER, 1, 0, 0x0F));
	check(!cachedI() && cachedD(), "an MMU context register write keeps the data cache (lines are context-tagged)");
}

static void testAccAndContext()
{
	FakeMmu mmu;
	mmu.acc = 2; //read/execute only
	L1CachesCore c(mmu);
	run(c, req(MemAccessType::LOAD, 0xA000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	run(c, req(MemAccessType::STORE, 0xA000, ASI_SUPERVISOR_DATA, 1, 0, 0x0F));
	check(c.dataStats.writeMisses == 1, "a store to a read/execute-only cached line is a miss (the MMU decides)");

	FakeMmu m2;
	uint32_t ctx = 0;
	L1CachesCore d(m2);
	d.dataCache.configure(512, 2); //two ways, so both contexts' lines fit in one set
	d.currentContext = [&]() { return ctx; };
	run(d, req(MemAccessType::LOAD, 0xB000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	ctx = 5;
	m2.pageMap[0xB000] = 0xC000; //context 5 maps this page elsewhere
	run(d, req(MemAccessType::LOAD, 0xB000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	check(m2.lineReads == 2, "the same address in another context is a different line");
	ctx = 0;
	m2.pageMap.erase(0xB000);
	run(d, req(MemAccessType::LOAD, 0xB000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	check(m2.lineReads == 2, "back in context 0, the original line still hits");

	//A page both contexts map to the same physical page is a synonym, and only
	//one copy is kept, so a store in one context is seen in the other.
	ctx = 5;
	m2.words[0xD000] = 0x11;
	run(d, req(MemAccessType::LOAD, 0xD000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	ctx = 0;
	run(d, req(MemAccessType::LOAD, 0xD000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	check(d.dataStats.synonymsRemoved == 1, "a page shared between contexts keeps one copy");
	run(d, req(MemAccessType::STORE, 0xD000, ASI_SUPERVISOR_DATA, 0x22, 0, 0x0F));
	ctx = 5;
	check(run(d, req(MemAccessType::LOAD, 0xD000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F)).readWord0 == 0x22,
	      "a store in one context is seen in the other");
}

static void testReplacement()
{
	FakeMmu mmu;
	L1CachesCore c(mmu);
	c.dataCache.configure(4, 2); //2 sets of 2 ways
	//Set 0 addresses: line numbers 0, 2, 4 -> 0x000, 0x080, 0x100.
	run(c, req(MemAccessType::LOAD, 0x000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	run(c, req(MemAccessType::LOAD, 0x080, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	run(c, req(MemAccessType::LOAD, 0x000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	check(mmu.lineReads == 2, "2-way: two lines in one set both stay cached");
	run(c, req(MemAccessType::LOAD, 0x100, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	check(c.dataCache.find(0x000, 0) < 0 && c.dataCache.find(0x080, 0) >= 0,
	      "third line in the set replaces round-robin in fill order (way 0 after ways 0, 1), not LRU");

	FakeMmu m2;
	L1CachesCore d(m2);
	d.dataCache.configure(4, 1); //direct mapped, 4 sets
	run(d, req(MemAccessType::LOAD, 0x000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	run(d, req(MemAccessType::LOAD, 0x100, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	run(d, req(MemAccessType::LOAD, 0x000, ASI_SUPERVISOR_DATA, 0, 0, 0x0F));
	check(m2.lineReads == 3, "direct mapped: two lines mapping to the same set evict each other");
}

//An invalidate removes exactly the named line, from both caches, and a later
//access misses and reads memory again.
static void testInvalidate()
{
	FakeMmu mmu;
	L1CachesCore c(mmu);
	mmu.words[0x7000] = 0x11;
	mmu.words[0x8000] = 0x22;
	run(c, req(MemAccessType::LOAD, 0x7000, ASI_SUPERVISOR_DATA));
	run(c, req(MemAccessType::LOAD, 0x8000, ASI_SUPERVISOR_DATA));
	run(c, req(MemAccessType::IFETCH, 0x7000, ASI_SUPERVISOR_INSTRUCTION));

	c.invalidatePhysicalLine(0x7010); //any address within the line
	check(c.dataStats.invalidatesHit == 1 && c.instructionStats.invalidatesHit == 1,
	      "an invalidate removes the line from both caches");

	int before = mmu.lineReads;
	mmu.words[0x7000] = 0x33;
	check(run(c, req(MemAccessType::LOAD, 0x8000, ASI_SUPERVISOR_DATA)).readWord0 == 0x22 && mmu.lineReads == before,
	      "another line stays cached");
	check(run(c, req(MemAccessType::LOAD, 0x7000, ASI_SUPERVISOR_DATA)).readWord0 == 0x33 && mmu.lineReads == before + 1,
	      "the invalidated data line misses and reads the new value");
	check(run(c, req(MemAccessType::IFETCH, 0x7000, ASI_SUPERVISOR_INSTRUCTION)).readWord0 == 0x33 && mmu.lineReads == before + 2,
	      "the invalidated instruction line misses and reads the new value");

	c.invalidatePhysicalLine(0x9000);
	check(c.dataStats.invalidates == 2 && c.dataStats.invalidatesHit == 1, "an invalidate of an uncached line finds nothing");
}

//The line is found from its physical address alone, whatever the virtual
//address was, in every set it could be in. 32 KB = 8 candidate sets per
//physical address, and this virtual address is in a different one from
//its physical address.
static void testInvalidateFindsLineByPhysicalAddress()
{
	FakeMmu mmu;
	L1CachesCore c(mmu);
	for (uint32_t color = 0; color < 8; color++)
	{
		uint32_t va = 0x10000 + color * 0x1000 + 0x40;
		mmu.pageMap[va & ~0xFFFu] = 0x90000;
		mmu.words[0x90040] = 0xAB;
		check(run(c, req(MemAccessType::LOAD, va, ASI_SUPERVISOR_DATA)).readWord0 == 0xAB, "read through a mapped page");
		uint64_t hits = c.dataStats.invalidatesHit;
		c.invalidatePhysicalLine(0x90040);
		check(c.dataStats.invalidatesHit == hits + 1, "the line is found by its physical address");
		mmu.pageMap.erase(va & ~0xFFFu);
	}
}

static void testInvalidateSetAssociative()
{
	FakeMmu mmu;
	L1CachesCore c(mmu);
	c.dataCache.configure(32, 4); //8 sets, smaller than a page: one candidate set
	mmu.words[0x7000] = 0x11;
	mmu.words[0x7200] = 0x22; //the same set, a different way
	run(c, req(MemAccessType::LOAD, 0x7000, ASI_SUPERVISOR_DATA));
	run(c, req(MemAccessType::LOAD, 0x7200, ASI_SUPERVISOR_DATA));
	int before = mmu.lineReads;
	c.invalidatePhysicalLine(0x7200);
	run(c, req(MemAccessType::LOAD, 0x7000, ASI_SUPERVISOR_DATA));
	check(mmu.lineReads == before, "the other way of the set stays cached");
	run(c, req(MemAccessType::LOAD, 0x7200, ASI_SUPERVISOR_DATA));
	check(mmu.lineReads == before + 1, "only the matching way is removed");
}

//Two virtual addresses for one physical line, in different sets. A cache
//holds at most one copy, so a store through one is never missed by the other.
static void testSynonyms()
{
	FakeMmu mmu;
	L1CachesCore c(mmu);
	mmu.pageMap[0x10000] = 0x90000;
	mmu.pageMap[0x11000] = 0x90000;
	mmu.words[0x90000] = 0x11;

	run(c, req(MemAccessType::LOAD, 0x10000, ASI_SUPERVISOR_DATA));
	check(c.dataStats.synonymsRemoved == 0, "the first copy removes nothing");
	check(run(c, req(MemAccessType::LOAD, 0x11000, ASI_SUPERVISOR_DATA)).readWord0 == 0x11 && c.dataStats.synonymsRemoved == 1,
	      "a second copy removes the first");

	VirtualMemoryRequest store = req(MemAccessType::STORE, 0x11000, ASI_SUPERVISOR_DATA);
	store.word0 = 0x22;
	store.byteMask = 0x0F;
	run(c, store);
	check(run(c, req(MemAccessType::LOAD, 0x10000, ASI_SUPERVISOR_DATA)).readWord0 == 0x22,
	      "a store through one address is seen through the other");
	check(c.dataStats.synonymsRemoved == 2, "and that read removed the other copy again");

	//An atomic never fills, so it removes a copy under another address itself.
	run(c, req(MemAccessType::ATOMIC_LS, 0x11000, ASI_SUPERVISOR_DATA, 0x33, 0, 0x0F));
	check(c.dataStats.synonymsRemoved == 3, "an atomic through one address removes the copy under the other");
	check(run(c, req(MemAccessType::LOAD, 0x10000, ASI_SUPERVISOR_DATA)).readWord0 == 0x33,
	      "and the atomic is seen through the other address");

	//So does a store through an alias that is not cacheable.
	run(c, req(MemAccessType::LOAD, 0x10000, ASI_SUPERVISOR_DATA));
	mmu.cacheable = false;
	run(c, req(MemAccessType::STORE, 0x11000, ASI_SUPERVISOR_DATA, 0x44, 0, 0x0F));
	mmu.cacheable = true;
	check(run(c, req(MemAccessType::LOAD, 0x10000, ASI_SUPERVISOR_DATA)).readWord0 == 0x44,
	      "a store through an uncached alias is seen through the cached one");

	//A fault that the NF bit suppresses looks the same, but it has no address.
	run(c, req(MemAccessType::LOAD, 0x10000, ASI_SUPERVISOR_DATA));
	uint64_t removed = c.dataStats.synonymsRemoved;
	mmu.suppressedFault = true;
	run(c, req(MemAccessType::STORE, 0x11000, ASI_SUPERVISOR_DATA, 0x55, 0, 0x0F));
	run(c, req(MemAccessType::ATOMIC_LS, 0x11000, ASI_SUPERVISOR_DATA, 0x55, 0, 0x0F));
	mmu.suppressedFault = false;
	check(c.dataStats.synonymsRemoved == removed, "a fault suppressed by the NF bit removes nothing");
}

//The race in a timing model: the invalidate arrives while a fill is on its way.
//The fill read the line before the write, so it may hold old data. It serves its
//read, and is not installed.
static void testInvalidateDuringFill()
{
	FakeMmu mmu;
	L1CachesCore c(mmu);
	mmu.words[0x7000] = 0x11;

	VirtualMemoryRequest load = req(MemAccessType::LOAD, 0x7000, ASI_SUPERVISOR_DATA);
	VirtualMemoryResponse response{};
	c.begin(load, response);
	check(c.needsDownstream(), "a miss needs a fill");
	VirtualMemoryResponse reply{};
	mmu.access(c.downstreamRequest(), reply); //the fill reads the old value
	mmu.words[0x7000] = 0x22;                 //another core writes it
	c.invalidatePhysicalLine(0x7000);         //and its invalidate arrives first
	c.downstreamDone(reply);
	check(response.readWord0 == 0x11, "the read that started the fill is served");
	check(c.dataStats.fillsAbandoned == 1 && c.dataStats.lineFills == 0, "the line is not installed");
	check(run(c, load).readWord0 == 0x22, "the next read misses and sees the new value");

	//An invalidate of some other line changes nothing.
	mmu.words[0x8000] = 0x33;
	VirtualMemoryRequest other = req(MemAccessType::LOAD, 0x8000, ASI_SUPERVISOR_DATA);
	c.begin(other, response);
	mmu.access(c.downstreamRequest(), reply);
	c.invalidatePhysicalLine(0x9000);
	c.downstreamDone(reply);
	int before = mmu.lineReads;
	check(run(c, other).readWord0 == 0x33 && mmu.lineReads == before, "a fill of another line is installed");

	//A write-allocate fill behaves the same way.
	VirtualMemoryRequest store = req(MemAccessType::STORE, 0xA000, ASI_SUPERVISOR_DATA);
	store.word0 = 0x44;
	store.byteMask = 0x0F;
	c.begin(store, response);
	mmu.access(c.downstreamRequest(), reply);
	c.downstreamDone(reply); //the store is done, and the fill starts
	check(c.needsDownstream(), "a store miss fetches the line");
	mmu.access(c.downstreamRequest(), reply);
	c.invalidatePhysicalLine(0xA000);
	uint64_t abandoned = c.dataStats.fillsAbandoned;
	c.downstreamDone(reply);
	check(c.dataStats.fillsAbandoned == abandoned + 1, "a write-allocate fill is abandoned too");
}

int main()
{
	testInstructionHitMiss();
	testDataReadAndNonCacheable();
	testBypassAsisForwarded();
	testWriteThroughAndAllocate();
	testAtomicUpdatesCachedLine();
	testFlushes();
	testAccAndContext();
	testReplacement();
	testInvalidate();
	testInvalidateFindsLineByPhysicalAddress();
	testInvalidateSetAssociative();
	testSynonyms();
	testInvalidateDuringFill();

	std::cout << "\n" << (numFailed == 0 ? "OVERALL: PASS" : "OVERALL: FAIL")
	          << " (" << numChecks << " checks, " << numFailed << " failed)\n";
	return numFailed == 0 ? 0 : 1;
}

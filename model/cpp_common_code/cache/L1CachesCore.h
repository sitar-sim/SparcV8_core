//L1CachesCore.h
//
//A core's split L1 caches: an instruction cache and a data cache, both
//VIVT (Ref CacheArray.h), sitting between the core and the MMU. Implements
//VirtualMemoryInterface, the same interface the MMU implements, so it
//drops in between SparcStateMachine and MmuCore with neither changing.
//IFETCH requests go to the instruction cache, everything else to the
//data cache.
//
//Access policy follows AJIT's L1 caches (cache/src/Icache.c, Dcache.c in
//the ajit-toolchain repo's 64-bit multi-core C model):
//
//  - Only accesses with ASIs 8..B (user/supervisor instruction/data) are
//    cached. Everything else (MMU registers and flush/probe, bypass ASIs,
//    ...) is forwarded to the MMU unchanged.
//  - A hit needs the line's ACC bits to allow the access. Otherwise it is
//    treated as a miss, and the MMU raises the fault.
//  - Read miss (IFETCH or LOAD): a READ_LINE to the MMU. If the MMU says
//    the page is cacheable, the line is installed, else only the one
//    doubleword was read and nothing is installed.
//  - Write-through with write-allocate: every STORE is forwarded. On a
//    hit the line is updated too. On a miss the line is then fetched,
//    but only if the MMU's reply to the store says the line may be cached
//    (a faulting store, even one whose trap NF suppresses, never
//    allocates, as in AJIT).
//  - ATOMIC_LS is forwarded (its locked read never uses the cache), and a
//    cached copy of the line is updated with the bytes it stores.
//  - Flushes, always of a whole cache: a STORE with ASI 0x10..0x14 flushes
//    both caches, 0x18..0x1C the instruction cache, and neither is
//    forwarded. A STORE to the MMU's registers or flush/probe (ASI 3, 4)
//    is forwarded and then flushes both, except that a write of the MMU
//    Context Register does not flush the data cache (its lines are tagged
//    with the context). The FLUSH instruction flushes both.
//  - Whether anything is cacheable at all is the MMU's decision (its
//    READ_LINE reply): with the MMU disabled, only if the MMU Control
//    Register's "always cacheable" bit is set, as in AJIT.
//
//One request is serviced at a time. The work is split into small steps
//so that a timing model can perform each downstream access with real
//simulated time (Ref L1Caches.sitar), while access() below runs the same
//steps instantly for the cpp_model:
//
//    begin(request, response);
//    while (needsDownstream())
//    {
//        //perform downstreamRequest() on the MMU, then:
//        downstreamDone(theMmusResponse);
//    }
//    //response is complete

#ifndef L1_CACHES_CORE_H
#define L1_CACHES_CORE_H

#include <stdint.h>
#include <functional>
#include <string>
#include "MemoryInterfaces.h"
#include "CacheArray.h"
#include "CacheConfig.h"

//A downstream that must never be used: what a timing model passes to
//L1CachesCore's constructor when it performs every downstream access
//itself through the step functions (Ref L1Caches.sitar), never calling
//access().
class UnusedVirtualMemory : public VirtualMemoryInterface
{
	public:
		void access(const VirtualMemoryRequest&, VirtualMemoryResponse& response) override
		{
			response.mae = true; //never reached in a correctly built model
		}
};

class L1CachesCore : public VirtualMemoryInterface
{
	public:
		explicit L1CachesCore(VirtualMemoryInterface& downstream);

		CacheArray instructionCache;
		CacheArray dataCache;

		//Where the current MMU context comes from (part of every tag).
		//Returns 0 unless set, e.g. by a configuration with an MMU.
		std::function<uint32_t()> currentContext;

		//VirtualMemoryInterface: the whole access, instantly.
		void access(const VirtualMemoryRequest& request, VirtualMemoryResponse& response) override;

		//The same access, step by step (Ref this file's header comment).
		void begin(const VirtualMemoryRequest& request, VirtualMemoryResponse& response);
		bool needsDownstream() const { return step_ != Step::DONE; }
		const VirtualMemoryRequest& downstreamRequest() const { return downstreamRequest_; }
		void downstreamDone(const VirtualMemoryResponse& downstreamResponse);

		//What the last completed access was, for a timing model's knobs.
		bool lastAccessWasInstructionHit() const { return lastHit_ && lastWasInstruction_; }
		bool lastAccessWasDataHit()        const { return lastHit_ && !lastWasInstruction_; }
		bool lastAccessInstalledLine()     const { return lastInstalled_; }

		struct CacheStats
		{
			uint64_t accesses   = 0; //cacheable-ASI accesses looked up
			uint64_t readHits   = 0;
			uint64_t readMisses = 0;
			uint64_t writeHits  = 0;
			uint64_t writeMisses = 0;
			uint64_t lineFills  = 0; //lines installed
			uint64_t uncachedMisses = 0; //misses the MMU said were not cacheable
			uint64_t forwarded  = 0; //non-cacheable-ASI accesses passed to the MMU
			uint64_t flushes    = 0;
		};
		CacheStats instructionStats;
		CacheStats dataStats;
		std::string statsToString() const;

	private:
		enum class Step { DONE, FORWARD, FILL_FOR_READ, FILL_FOR_WRITE };

		void finishWithRequest();
		void flushInstructionCache();
		void flushDataCache();
		void serveReadFromLine(int index);

		VirtualMemoryInterface& downstream_;

		Step                   step_;
		VirtualMemoryRequest   request_;
		VirtualMemoryResponse* response_;
		VirtualMemoryRequest   downstreamRequest_;
		bool                   isInstruction_;
		uint32_t               context_;

		bool lastHit_;
		bool lastWasInstruction_;
		bool lastInstalled_;
};

#endif

//L1CachesCore.cpp
//Original Authors: Madhav Desai, Neha Karanjkar, Aniket Deshmukh
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the VIVT L1 cache model developed by
//the original authors.

#include "L1CachesCore.h"
#include "AsiValues.h"
#include <sstream>

namespace
{
	bool isCachedAsi(uint32_t asi) { return asi >= 0x8 && asi <= 0xB; }

	//AJIT's accessPermissionsOk() (cache/src/CacheInterface.c): whether a
	//cached line's ACC field (Ref Appendix H, Table H-6) allows the
	//access. Instruction-ness and privilege come from the ASI.
	bool accessAllowed(uint8_t acc, uint32_t asi, bool isWrite)
	{
		bool supervisor = (asi == ASI_SUPERVISOR_INSTRUCTION || asi == ASI_SUPERVISOR_DATA);
		bool ifetch     = (asi == ASI_SUPERVISOR_INSTRUCTION || asi == ASI_USER_INSTRUCTION);
		switch (acc)
		{
			case 0:  return !ifetch && !isWrite;
			case 1:  return !ifetch;
			case 2:  return !isWrite;
			case 3:  return true;
			case 4:  return ifetch;
			case 5:  return supervisor ? !ifetch : !(ifetch || isWrite);
			case 6:  return supervisor && !isWrite;
			case 7:  return supervisor;
			default: return false;
		}
	}

	bool isContextRegisterWrite(const VirtualMemoryRequest& r)
	{
		return r.asi == ASI_MMU_REGISTER && ((r.address >> 8) & 0x7) == 2;
	}
}

L1CachesCore::L1CachesCore(VirtualMemoryInterface& downstream) :
	instructionCache(DEFAULT_ICACHE_LINES, DEFAULT_ICACHE_WAYS),
	dataCache(DEFAULT_DCACHE_LINES, DEFAULT_DCACHE_WAYS),
	downstream_(downstream),
	step_(Step::DONE),
	request_(),
	response_(nullptr),
	downstreamRequest_(),
	isInstruction_(false),
	context_(0),
	lastHit_(false),
	lastWasInstruction_(false),
	lastInstalled_(false)
{
}

void L1CachesCore::access(const VirtualMemoryRequest& request, VirtualMemoryResponse& response)
{
	begin(request, response);
	while (needsDownstream())
	{
		VirtualMemoryResponse r{};
		downstream_.access(downstreamRequest(), r);
		downstreamDone(r);
	}
	response.valid = true;
}

void L1CachesCore::flushInstructionCache()
{
	instructionCache.flushAll();
	instructionStats.flushes++;
}

void L1CachesCore::flushDataCache()
{
	dataCache.flushAll();
	dataStats.flushes++;
}

void L1CachesCore::serveReadFromLine(int index)
{
	CacheArray& cache = isInstruction_ ? instructionCache : dataCache;
	uint64_t dw = cache.readDoubleword(index, request_.address);
	if (isInstruction_)
		response_->readWord0 = (request_.address & 0x4u) ? (uint32_t) (dw >> 32) : (uint32_t) dw;
	else
	{
		response_->readWord0 = (uint32_t) dw;
		response_->readWord1 = (uint32_t) (dw >> 32);
	}
}

void L1CachesCore::begin(const VirtualMemoryRequest& request, VirtualMemoryResponse& response)
{
	request_  = request;
	response_ = &response;
	response.readWord0 = 0;
	response.readWord1 = 0;
	response.mae       = false;

	step_          = Step::DONE;
	lastHit_       = false;
	lastInstalled_ = false;
	isInstruction_ = (request.accessType == MemAccessType::IFETCH);
	lastWasInstruction_ = isInstruction_;
	context_       = currentContext ? currentContext() : 0;
	downstreamRequest_ = request;

	uint32_t asi = request.asi;
	bool cachedAsi = isCachedAsi(asi);

	switch (request.accessType)
	{
		case MemAccessType::IFETCH:
		case MemAccessType::LOAD:
		{
			CacheArray& cache = isInstruction_ ? instructionCache : dataCache;
			CacheStats& stats = isInstruction_ ? instructionStats : dataStats;
			if (!cachedAsi)
			{
				stats.forwarded++;
				step_ = Step::FORWARD;
				break;
			}
			stats.accesses++;
			int index = cache.find(request.address, context_);
			if (index >= 0 && accessAllowed(cache.line(index).acc, asi, false))
			{
				stats.readHits++;
				lastHit_ = true;
				serveReadFromLine(index);
				break;
			}
			stats.readMisses++;
			downstreamRequest_.accessType = MemAccessType::READ_LINE;
			if (isInstruction_)
				downstreamRequest_.byteMask = (request.address & 0x4u) ? 0xF0 : 0x0F;
			step_ = Step::FILL_FOR_READ;
			break;
		}

		case MemAccessType::STORE:
			if (asiIsDcacheFlush((uint8_t) asi)) //0x10..0x14: flush both, not forwarded
			{
				flushInstructionCache();
				flushDataCache();
				break;
			}
			if (asiIsIcacheFlush((uint8_t) asi)) //0x18..0x1C: flush the instruction cache only
			{
				flushInstructionCache();
				break;
			}
			if (cachedAsi)
			{
				dataStats.accesses++;
				int index = dataCache.find(request.address, context_);
				lastHit_ = index >= 0 && accessAllowed(dataCache.line(index).acc, asi, true);
				if (lastHit_) dataStats.writeHits++; else dataStats.writeMisses++;
			}
			else
				dataStats.forwarded++;
			step_ = Step::FORWARD; //write-through, always
			break;

		case MemAccessType::ATOMIC_LS:
			if (!cachedAsi)
				dataStats.forwarded++;
			step_ = Step::FORWARD;
			break;

		case MemAccessType::FLUSH:
			//The FLUSH instruction: AJIT issues it as a store with the
			//flush-I&D ASI, so both caches are flushed, nothing forwarded.
			flushInstructionCache();
			flushDataCache();
			break;

		default:
			step_ = Step::FORWARD;
			break;
	}
}

void L1CachesCore::downstreamDone(const VirtualMemoryResponse& r)
{
	switch (step_)
	{
		case Step::FORWARD:
		{
			response_->readWord0 = r.readWord0;
			response_->readWord1 = r.readWord1;
			response_->mae       = r.mae;
			step_ = Step::DONE;

			bool cachedAsi = isCachedAsi(request_.asi);
			if (request_.accessType == MemAccessType::STORE)
			{
				if (cachedAsi && !r.mae)
				{
					uint64_t data = ((uint64_t) request_.word1 << 32) | request_.word0;
					int index = dataCache.find(request_.address, context_);
					if (lastHit_ && index >= 0)
						dataCache.writeBytes(index, request_.address, data, (uint8_t) request_.byteMask);
					else if (r.cacheable) //only if the MMU says the stored-to line may be cached
					{
						//Write-allocate: fetch the line, but read nothing at
						//all if it turns out not to be cacheable (empty mask).
						downstreamRequest_ = request_;
						downstreamRequest_.accessType = MemAccessType::READ_LINE;
						downstreamRequest_.byteMask   = 0;
						step_ = Step::FILL_FOR_WRITE;
					}
				}
				else if (request_.asi == ASI_MMU_FLUSH_PROBE || request_.asi == ASI_MMU_REGISTER)
				{
					flushInstructionCache();
					if (!isContextRegisterWrite(request_))
						flushDataCache();
				}
			}
			else if (request_.accessType == MemAccessType::ATOMIC_LS && cachedAsi && !r.mae)
			{
				int index = dataCache.find(request_.address, context_);
				if (index >= 0)
				{
					uint64_t data = ((uint64_t) request_.word1 << 32) | request_.word0;
					dataCache.writeBytes(index, request_.address, data, (uint8_t) request_.byteMask);
				}
			}
			break;
		}

		case Step::FILL_FOR_READ:
		{
			step_ = Step::DONE;
			CacheArray& cache = isInstruction_ ? instructionCache : dataCache;
			CacheStats& stats = isInstruction_ ? instructionStats : dataStats;
			if (r.mae)
			{
				response_->mae = true;
				break;
			}
			if (r.cacheable)
			{
				int index = cache.fill(request_.address, context_, r.acc, r.line);
				stats.lineFills++;
				lastInstalled_ = true;
				serveReadFromLine(index);
			}
			else
			{
				stats.uncachedMisses++;
				uint64_t dw = r.line[(request_.address >> 3) & (CACHE_LINE_DOUBLEWORDS - 1)];
				if (isInstruction_)
					response_->readWord0 = (request_.address & 0x4u) ? (uint32_t) (dw >> 32) : (uint32_t) dw;
				else
				{
					response_->readWord0 = (uint32_t) dw;
					response_->readWord1 = (uint32_t) (dw >> 32);
				}
			}
			break;
		}

		case Step::FILL_FOR_WRITE:
			step_ = Step::DONE;
			//The store itself already completed. A line that is not
			//cacheable (or a fault on this extra read) just means nothing
			//is installed.
			if (!r.mae && r.cacheable && dataCache.find(request_.address, context_) < 0)
			{
				dataCache.fill(request_.address, context_, r.acc, r.line);
				dataStats.lineFills++;
				lastInstalled_ = true;
			}
			break;

		case Step::DONE:
		default:
			break;
	}
}

std::string L1CachesCore::statsToString() const
{
	std::ostringstream ss;
	const char* names[2] = {"Instruction cache", "Data cache"};
	const CacheStats* all[2] = {&instructionStats, &dataStats};
	const CacheArray* caches[2] = {&instructionCache, &dataCache};
	for (int i = 0; i < 2; i++)
	{
		const CacheStats& s = *all[i];
		ss << "\n " << names[i] << " (" << caches[i]->numberOfLines() << " lines, "
		   << caches[i]->ways() << "-way):"
		   << "\n\t accesses        = " << s.accesses
		   << "\n\t read hits       = " << s.readHits
		   << "\n\t read misses     = " << s.readMisses
		   << "\n\t write hits      = " << s.writeHits
		   << "\n\t write misses    = " << s.writeMisses
		   << "\n\t lines filled    = " << s.lineFills
		   << "\n\t uncached misses = " << s.uncachedMisses
		   << "\n\t forwarded       = " << s.forwarded
		   << "\n\t flushes         = " << s.flushes
		   << "\n";
	}
	return ss.str();
}

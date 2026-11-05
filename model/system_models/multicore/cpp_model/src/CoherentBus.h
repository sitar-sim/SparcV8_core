//CoherentBus.h
//Author: Neha Karanjkar
//
//The cpp_model's counterpart of CoherentBridge.sitar's coherence: what every
//core's MMU reaches SystemBus through. A plain SystemBus has no idea which core
//is asking, so each core gets a Port of its own, which knows.
//
//When `coherent` is set, a write to main memory removes that line from every
//other core's caches, at once. Nothing else can be running at that moment,
//since the cores take turns a whole instruction at a time, so none of the
//timing questions of the sitar_model arise. `snoopFilter` leaves out repeated
//invalidates, exactly as the bridge does.

#ifndef COHERENT_BUS_H
#define COHERENT_BUS_H

#include "L1CachesCore.h"
#include "MemoryInterfaces.h"
#include "SystemAddressMap.h"
#include "SystemBus.h"
#include <stdint.h>
#include <vector>

class CoherentBus
{
	public:
		CoherentBus(SystemBus& bus, unsigned int numCores) :
			coherent(false), snoopFilter(false), invalidatesSent(0), invalidatesFiltered(0),
			bus_(bus), caches_(numCores, nullptr), lastInvalidate_(numCores)
		{
			for (unsigned int i = 0; i < numCores; i++)
				ports_.push_back(Port(*this, i));
		}

		bool     coherent;
		bool     snoopFilter;
		uint64_t invalidatesSent;
		uint64_t invalidatesFiltered;

		PhysicalMemoryInterface& port(unsigned int coreId) { return ports_[coreId]; }
		void attachCaches(unsigned int coreId, L1CachesCore* caches) { caches_[coreId] = caches; }

	private:
		class Port : public PhysicalMemoryInterface
		{
			public:
				Port(CoherentBus& owner, unsigned int coreId) : owner_(&owner), coreId_(coreId) {}
				void access(const PhysicalMemoryRequest& request, PhysicalMemoryResponse& response) override
				{
					owner_->access(coreId_, request, response);
				}
			private:
				CoherentBus* owner_;
				unsigned int coreId_;
		};

		struct LastInvalidate
		{
			bool     valid = false;
			uint64_t line  = 0;
		};

		void access(unsigned int coreId, const PhysicalMemoryRequest& request, PhysicalMemoryResponse& response)
		{
			if (request.accessType == PhysicalAccessType::READ)
				lastInvalidate_[coreId].valid = false;
			bus_.access(request, response);
			if (coherent && request.accessType == PhysicalAccessType::WRITE &&
			    SystemAddressMap::decode(request.physicalAddress) == SystemAddressMap::Target::MAIN_MEMORY)
				sendInvalidates(coreId, request.physicalAddress);
		}

		void sendInvalidates(unsigned int writer, uint64_t physicalAddress)
		{
			uint64_t line = physicalAddress & ~((uint64_t) CACHE_LINE_BYTES - 1);
			for (unsigned int c = 0; c < caches_.size(); c++)
			{
				if (c == writer)
					continue;
				if (snoopFilter && lastInvalidate_[c].valid && lastInvalidate_[c].line == line)
				{
					invalidatesFiltered++;
					continue;
				}
				lastInvalidate_[c].valid = true;
				lastInvalidate_[c].line  = line;
				invalidatesSent++;
				caches_[c]->invalidatePhysicalLine(line);
			}
		}

		SystemBus&                  bus_;
		std::vector<L1CachesCore*>  caches_;
		std::vector<LastInvalidate> lastInvalidate_;
		std::vector<Port>           ports_;
};

#endif

//DebugRegistry.cpp
//
//See DebugRegistry.h.

#include "DebugRegistry.h"
#include "SparcCore.h"
#include "MemCore.h"

#ifdef SPARC_DEBUG_HOOKS_ENABLED

namespace DebugRegistry
{
	std::vector<SparcCore*> cores;
	std::vector<MemCore*>   memories;

	void registerCore(SparcCore* core)
	{
		cores.push_back(core);
	}

	void registerMemCore(MemCore* mem)
	{
		memories.push_back(mem);
	}

	SparcCore* findCoreByID(uint32_t coreid)
	{
		for (size_t i = 0; i < cores.size(); i++)
			if (cores[i]->getCoreID() == coreid)
				return cores[i];
		return 0;
	}

	MemCore* firstMemCore()
	{
		if (memories.empty())
			return 0;
		return memories[0];
	}
}

#endif

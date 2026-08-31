//DebugRegistry.h
//
//Lets a debugger reach a live SparcCore/MemCore from any stopped frame,
//in either model, without caring who constructed it or which frame it's
//lexically reachable from. SparcCore/MemCore each register themselves
//here once, in their own constructor. findCoreByID()/firstMemCore() are
//what debug/sparc.gdb's commands are built on.
//
//Only real when built with -DSPARC_DEBUG_HOOKS_ENABLED. Otherwise every
//function is a no-op stub returning null, so registerCore()/
//registerMemCore() are safe to call unconditionally regardless of build
//mode.

#ifndef DEBUG_REGISTRY_H
#define DEBUG_REGISTRY_H

#include <cstddef>
#include <cstdint>
#include <vector>

class SparcCore;
class MemCore;

#ifdef SPARC_DEBUG_HOOKS_ENABLED

namespace DebugRegistry
{
	extern std::vector<SparcCore*> cores;
	extern std::vector<MemCore*>   memories;

	void registerCore(SparcCore* core);
	void registerMemCore(MemCore* mem);

	//Reliable-under-gdb accessors: like Registers::R_r()/MemCore::wordPtr(),
	//pinned to -O0 (and kept alive with `used`, since nothing in the model
	//itself calls these -- only gdb does) so `call`/`print` of them stays
	//reliable even in a --debug build that otherwise keeps full -O3.
	//
	//findCoreByID searches by the core's own coreID field (set via
	//SparcCore::setCoreID()), not by registration order -- coreID is the
	//architectural identity a user actually thinks in terms of; today
	//there's exactly one core, always coreID 0. Returns nullptr if no
	//match. firstMemCore() ignores coreid entirely: memory isn't owned
	//per-core in this model (today there's exactly one MemCore regardless
	//of core count), so there is nothing to select between yet.
	__attribute__((optimize("O0"), used)) SparcCore* findCoreByID(uint32_t coreid);
	__attribute__((optimize("O0"), used)) MemCore* firstMemCore();
}

#else

namespace DebugRegistry
{
	inline void registerCore(SparcCore*) {}
	inline void registerMemCore(MemCore*) {}
	inline SparcCore* findCoreByID(uint32_t) { return 0; }
	inline MemCore* firstMemCore() { return 0; }
}

#endif

#endif

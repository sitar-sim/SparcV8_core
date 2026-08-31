//DebugHooks.cpp
//
//See DebugHooks.h. Deliberately empty. The value of each function is
//that it exists, by a stable name, for a debugger to break on.

#include "DebugHooks.h"

#ifdef SPARC_DEBUG_HOOKS_ENABLED

void debug_hook_after_execute(SparcCore& core, Opcode op)
{
}

void debug_hook_trap_raised(SparcCore& core)
{
}

void debug_hook_mem_access(SparcCore& core, DebugMemAccessKind kind, uint32_t address, uint32_t word0, uint32_t word1)
{
}

void debug_hook_annulled(SparcCore& core)
{
}

#endif

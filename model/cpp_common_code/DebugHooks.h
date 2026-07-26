//DebugHooks.h
//
//Named, otherwise-empty functions called from the same points in the
//instruction loop that CoreLogger logs from (see CoreLogger.h), purely so
//a host debugger has a stable place to break on by name -- e.g. (gdb)
//`break debug_hook_after_execute if core.reg.PC==0x2054 && core.coreID==0`
//-- instead of a source file:line, which drifts every time the driver code
//is edited (and doesn't exist at all for the sitar model, whose driver is
//generated C++). Nothing here is gdb-specific (plain -g/DWARF info plus a
//noinline symbol works under any debugger); gdb is simply the one this
//repository documents and ships convenience commands for -- see
//docs/source/examining_core_state_with_gdb.md and debug/sparc.gdb.
//
//Only real (and only then declared noinline, so the optimizer can't fold
//the empty body away and remove the breakpoint target) when built with
//-DSPARC_DEBUG_HOOKS_ENABLED (see build.sh/build.py's --debug). Otherwise
//this is a plain empty inline function -- calls to it compile away to
//nothing, same zero-cost-when-unused principle as CoreLogger's own logging
//gate.
//
//Not every CoreLogger event has a hook here -- only ones a `watch` (a
//native gdb hardware watchpoint on a memory location or register) can't
//already reach just as well. "PC/register/memory reaches a value" is a
//`watch` or a plain `break ... if`, no hook needed. What's left, and does
//need a hook, is state-machine *transitions* that aren't a single value
//changing: an instruction finishing (executed, trapped, or annulled), or a
//memory access completing.
//
//Together these four cover every way one iteration of the fetch-decode-
//execute loop can conclude: debug_hook_after_execute (executed -- this
//also fires, alongside debug_hook_trap_raised, for an instruction that
//trapped partway through -- see that hook's own comment), debug_hook_
//trap_raised (a trap pre-empted execution entirely), debug_hook_annulled
//(a delay-slot instruction was skipped, never decoded). debug_hook_
//mem_access is a sub-event within debug_hook_after_execute's instruction,
//not an alternative to it.

#ifndef DEBUG_HOOKS_H
#define DEBUG_HOOKS_H

#include <cstdint>
#include "Opcodes.h" //for the Opcode enum

class SparcCore; //forward declaration only, same reasoning as CoreLogger.h

//Which kind of memory reference debug_hook_mem_access just saw. Its own
//small enum (not the sitar_model-only MemAccessType in
//src/cpp_code/MemAccessInterface.h) since this header is shared by both
//models and must not depend on either one's own internals.
enum class DebugMemAccessKind { IFETCH, LOAD, STORE, ATOMIC, FLUSH };

#ifdef SPARC_DEBUG_HOOKS_ENABLED

//Instruction fully executed (registers/memory/PSR all updated), but before
//PC/nPC advance to the next instruction -- for most instructions, this is
//the point after which core.reg.R_PC() still names the instruction that
//just ran. (Branch instructions update PC/nPC themselves, earlier, inside
//executeCurrentInstruction()/executeInstruction() -- so for those this hook
//still fires once per instruction, just after PC has already moved.) Also
//fires for an instruction that raised a trap partway through execution --
//there is no early return between executeCurrentInstruction() and this
//hook in that case, matching CoreLogger's own EXECUTED event, which is
//equally unconditional -- so debug_hook_trap_raised and this can both fire
//for the same instruction.
void debug_hook_after_execute(SparcCore& core, Opcode op) __attribute__((noinline));

//A trap has just been detected (core.trap became true), from any of the
//several places that can happen (external/reset, fetch access exception,
//decode exception, execute-time exception -- see the log_trap_raised()
//call sites in SparcStateMachine.cpp/SparcThread.sitar, which this mirrors
//exactly). Useful for "why did this program unexpectedly trap", which
//isn't a single value changing, so a `watch` can't catch it directly. Fires
//before SparcCore::selectTrap() clears the trap-cause flags (core.
//illegal_instruction, core.window_overflow, ...) or computes TBR's tt
//field, so those flags -- not TBR -- are what's actually inspectable here
//(see core.printTrap(), which reads the same flags).
void debug_hook_trap_raised(SparcCore& core) __attribute__((noinline));

//A memory reference of the given kind has just completed. address/word0/
//word1 are that reference's own address and data (the instruction word,
//for IFETCH; whatever was read, for LOAD/ATOMIC; whatever was written, for
//STORE; both zero for FLUSH). Read core.MAE for whether it faulted (always
//false today, in this flat-memory model with no cache/MMU -- see
//CoreLogger::log_mem_read()'s comment -- but a condition on core.MAE will
//start actually firing selectively once one exists). e.g. (gdb)
//`break debug_hook_mem_access if core.MAE` to catch a faulting access and
//inspect kind/address/word0/word1 right there, or
//`break debug_hook_mem_access if kind==DebugMemAccessKind::LOAD && address==0x2000`
//for a specific one.
void debug_hook_mem_access(SparcCore& core, DebugMemAccessKind kind, uint32_t address, uint32_t word0, uint32_t word1) __attribute__((noinline));

//A delay-slot instruction was annulled (skipped due to an untaken
//annulling branch) -- never fetched-for-real or decoded, so unlike the
//hooks above there is no Opcode to pass. Fires before PC/nPC are updated
//for the skip (matching debug_hook_after_execute's own convention), so
//core.reg.R_PC()/R_nPC() here are the annulled instruction's own address
//and what it would have advanced to -- enough to cross-check against an
//objdump (see debug/sparc.gdb's sparc-print-annulled).
void debug_hook_annulled(SparcCore& core) __attribute__((noinline));

#else

inline void debug_hook_after_execute(SparcCore&, Opcode) {}
inline void debug_hook_trap_raised(SparcCore&) {}
inline void debug_hook_mem_access(SparcCore&, DebugMemAccessKind, uint32_t, uint32_t, uint32_t) {}
inline void debug_hook_annulled(SparcCore&) {}

#endif

#endif

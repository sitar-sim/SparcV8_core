//MmuCore.h
//
//The SPARC Reference MMU (Ref Appendix H). Ported from Ajit's C model
//and rewritten as a C++ class. The page-table walk, fault matrix,
//PTE/PPN encoding, and FSR/FAR/OW/R/M semantics are ported faithfully.
//The pthread/mutex/pipe scaffolding Ajit's version needed for
//concurrent hardware threads is dropped: this driver is strictly
//sequential.
//
//Implements VirtualMemoryInterface, so it plugs in wherever
//SparcStateMachine expects one, and drives whatever sits downstream
//through PhysicalMemoryInterface: a 36-bit physical address,
//zero-padded into 64 bits, with every downstream transaction
//doubleword-shaped.
//
//Deliberate deviations from Ajit:
//
//- No deferred instruction-fetch-fault commit. This driver has no
//  pipeline, so no fetch is ever speculative or squashed.
//- Atomic load-store (LDSTUB/SWAP) is checked as a single, precise
//  operation requiring both load and store permission before any
//  memory access happens, rather than Ajit's split-transaction (locked
//  read, then separate unlocked write) permission checking. See
//  docs/compliance/ for the full write-up.
//- MMU probe supports all five types, not just Ajit's entire-only.
//
//tlbLookup/beginWalk/recordWalkStep/checkAndRecordFault/
//commitTranslation/computeAndStageRMUpdate/commitRMTlbUpdate, plus
//probe/flush/readRegister/writeRegister, are public step-by-step
//primitives. translate()/probe() are built from them, and the cpp_model
//calls translate()/probe() directly, back to back with no waits. The
//Sitar timing model drives the same primitives one physical access at a
//time, interleaving real `wait`s between them. They're public because
//Sitar-generated code calling them is a method of a different generated
//class, the same reason SparcCore::execute_PreLoad/execute_PostLoad are
//public.

#ifndef MMUCORE_H
#define MMUCORE_H

#include "MemoryInterfaces.h"
#include "Tlb.h"
#include "MmuStats.h"
#include "../MultiThreadingConfig.h"
#include <cstdint>
#include <string>

class CoreLogger;

class MmuCore : public VirtualMemoryInterface
{
	public:
		//downstream: whatever this MMU forwards translated or
		//pass-through accesses to, over PhysicalMemoryInterface
		//(MainMemory today). threadId: which hardware thread within this
		//MMU's core this instance represents -- registers are kept
		//thread-indexed internally (MAX_THREADS, matching Ajit's
		//MMU_MAX_NUMBER_OF_THREADS) even though only thread_id 0 is used
		//until SMT support lands, so that extension needs no interface
		//change later.
		explicit MmuCore(PhysicalMemoryInterface& downstream, int threadId = 0);

		//Dispatches on request.accessType to handleReadAccess()/
		//handleWriteAccess()/handleAtomicAccess() below -- those three
		//hold the actual logic (ASI-based register/flush/probe/pass-
		//through dispatch, then CASE 6's translate()), carried over
		//unchanged from when they were this class's own three separately-
		//named VirtualMemoryInterface methods.
		void access(const VirtualMemoryRequest& request, VirtualMemoryResponse& response) override;

		//Model-configuration: is an MMU present at all for this core.
		//Independent of "enabled" (the Control Register's own E bit,
		//read/written like any other register through this same
		//interface) -- see Plan_SoC_Integration_Roadmap.md's
		//architecture point 2.
		bool mmuIsPresent;

		//True (the default): each hardware thread keeps its own
		//independent MMU register state (Control/CTP/Context/FSR/FAR),
		//so two threads sharing this MMU can genuinely run different
		//contexts. False: every register write is broadcast to every
		//thread slot instead, forcing all threads to mirror one shared
		//context.
		//
		//Corresponds to Ajit's own "multi_context" flag (Mmu.c),
		//verified directly against Ajit's source: same polarity, same
		//broadcast-on-write behavior. In Ajit this is a per-core,
		//runtime setting -- parsed from a hardware-description string at
		//simulator startup ("mcmunit"/"scmunit" tokens, Ancillary.c),
		//the same mechanism that decides whether a core has an MMU or an
		//FPU at all -- not a compile-time constant, which is why it
		//isn't in MultiThreadingConfig.h alongside NUM_THREADS_PER_CORE.
		//This port has no equivalent config-string parser yet, so it's
		//just a public field, defaulted to true and left for whatever
		//constructs the MmuCore to override.
		bool independentMmuContextPerThread;

		//Model-configuration: should this run actually use the TLB
		//(Ref MmuConfig.h's MMU_TLB_PRESENT, the compile-time axis for
		//whether TLB hardware exists at all)? Defaults to MMU_TLB_PRESENT.
		//False (regardless of MMU_TLB_PRESENT): the TLB is never looked
		//at, updated, or flushed -- every access re-walks the page
		//tables, and MmuStats' TLB hit/miss counters stay at zero, since
		//there is nothing to hit or miss. True requires MMU_TLB_PRESENT
		//to also be true -- MmuCore asserts this the first time it would
		//touch the TLB, rather than at construction, since this field
		//can be changed after construction.
		bool tlbEnabled;

		MmuStats stats;

		//Optional: if set, key MMU events are logged via
		//logger->log_generic(*simulatedTime, event, detail), sharing the
		//one per-core trace file with core events. Not required for the
		//MMU to function.
		void setLogger(CoreLogger* logger, const unsigned long* simulatedTime);

		//---------------------------------------------------------------
		// Step-by-step translation primitives (Ref this file's header
		// comment). Called in this order by translate() (unchanged,
		// still cpp_model's only entry point) and independently
		// duplicated in the same order by Mmu.sitar's own behavior:
		//   1. tlbLookup()
		//   2. if miss: beginWalk(), then a loop of
		//      (fetch walkCurPhyAddr()) + recordWalkStep(fetchedPte)
		//      until it returns false
		//   3. checkAndRecordFault() -- stop here if it returns true
		//   4. commitTranslation()
		//   5. computeAndStageRMUpdate() -- if true, write back
		//      stagedUpdatedPte() to walkResultPhyAddrOfPte(), then
		//      commitRMTlbUpdate()
		//---------------------------------------------------------------

		//TLB lookup for (va, context), only if tlbActive(). On a hit,
		//stores the found (pte, level, phyAddrOfPte) as the walk result
		//(same fields a walk would populate) and returns true. Does
		//nothing and returns false if the TLB isn't active (not even a
		//stats-recorded "miss" -- Ref tlbEnabled's own comment) or on a
		//genuine miss.
		bool tlbLookup(uint32_t va, uint32_t context);

		//The current context register's value (contextRegister_ is
		//private, thread-indexed internally) -- every step primitive
		//above takes context as an explicit parameter rather than
		//reading the register itself, so Sitar's own dispatch (living
		//outside this class) needs this to supply it.
		uint32_t currentContext() const { return contextRegister_[threadId_ & 1]; }

		//Ref the Control Register's E bit (Ref Appendix H.3) -- whether
		//translation is actually active right now (independent of
		//mmuIsPresent, Ref that field's own comment). translate() used
		//to check this internally as its very first step (mmuIsPresent
		//&& !mmuEnabled() -> bypass, VA==PA, before touching the TLB or
		//walking at all); Sitar's own CASE-6 dispatch needs to replicate
		//that same decision, so this needs to be public too.
		bool mmuEnabled() const;
		bool alwaysCacheable() const;

		//Ref Appendix H.3's NF (No Fault) control-register field: once
		//checkAndRecordFault() has recorded a fault, this decides
		//whether the CPU trap that would normally follow (mae=true) gets
		//suppressed instead -- callers (handleReadAccess/WriteAccess and
		//Sitar's own dispatch alike) check this exactly where they'd
		//otherwise set mae=true.
		bool noFaultSuppressesTrap(uint32_t asi) const;

		//Starts a page-table walk for (va, context): computes the L1/L2/
		//L3 index bits and the level-0 (context-table) physical address,
		//ready for the first fetch of walkCurPhyAddr().
		void beginWalk(uint32_t va, uint32_t context);

		//Classifies the entry just fetched from walkCurPhyAddr(). If
		//it's a PTD and the walk hasn't reached stopAtLevel, advances to
		//the next level (computes and stores the next physical address)
		//and returns true ("fetch again"); otherwise records the final
		//(pte, level, phyAddrOfPte) as the walk result and returns
		//false. stopAtLevel is 3 (walk as far as a leaf allows) for an
		//ordinary translation; probe()'s own page/segment/region/context
		//types (Ref Table H-4) instead want to stop at one specific
		//level even if a PTD sits there, so they pass their own target
		//level instead of taking the default.
		bool recordWalkStep(uint32_t fetchedPte, uint8_t stopAtLevel = 3);

		//The physical address the walk needs fetched next -- valid after
		//beginWalk(), or after a recordWalkStep() call that returned
		//true.
		uint64_t walkCurPhyAddr() const { return walkCurPhyAddr_; }

		//Ref Appendix H.5's fault matrix, applied to the walk-or-TLB-hit
		//result. Records the fault (recordFault()/updateFsrFar()) and
		//returns true if one occurred; returns false (nothing recorded)
		//on a clean translation.
		bool checkAndRecordFault(uint32_t asi, bool isWrite, bool isAtomic, bool isInstructionFetch, uint32_t va);

		//Only called when checkAndRecordFault() returned false. Inserts
		//into the TLB if this translation came from a fresh walk (not a
		//hit), and returns the translated physical address/cacheable/acc
		//via the same out-params translate() itself used to expose them.
		void commitTranslation(uint32_t va, uint32_t context, uint64_t& physicalAddr, bool& cacheable, uint8_t& acc);

		//Ref Appendix H.7: decides if R (always) or M (isWrite only)
		//needs setting on the just-translated PTE. If so, stages the
		//updated PTE value (stagedUpdatedPte()) and returns true --
		//caller then writes it back to walkResultPhyAddrOfPte() and
		//calls commitRMTlbUpdate(). Returns false (nothing staged, no
		//write-back needed) if both bits were already set.
		bool computeAndStageRMUpdate(bool isWrite);

		//Updates the TLB's cached copy of the just-written-back PTE, if
		//still present. Ref translate()'s own comment for why this MMU
		//is write-through (a flush never needs a write-back).
		void commitRMTlbUpdate(uint32_t va, uint32_t context);

		//The physical address the just-completed walk (or TLB hit)
		//found its result PTE at -- where a staged R/M update gets
		//written back.
		uint64_t walkResultPhyAddrOfPte() const { return walkResultPhyAddrOfPte_; }

		//The PTE value and level the just-completed walk (or TLB hit)
		//found -- probe()'s own non-entire types (page/segment/region/
		//context) need these directly (Ref Table H-4's per-entry-type
		//return rules), not just whether a translation succeeded.
		uint32_t walkResultPte() const { return walkResultPte_; }
		uint8_t  walkResultLevel() const { return walkResultLevel_; }

		//The PTE value staged by computeAndStageRMUpdate(), valid only
		//when it returned true.
		uint32_t stagedUpdatedPte() const { return stagedUpdatedPte_; }

		//---------------------------------------------------------------
		// ASI-dispatched operations other than an ordinary translated
		// access -- probe/flush (ASI 3), register read/write (ASI 4).
		// Public for the same reason as the step primitives above: an
		// entire probe or an ordinary register access is a single atomic
		// (no downstream physical access) operation from Mmu.sitar's
		// point of view too, so it's called directly rather than
		// decomposed further.
		//---------------------------------------------------------------
		bool probe(uint32_t va, uint32_t& resultPte);
		void flush(uint32_t va);
		uint32_t readRegister(uint32_t addr);
		void writeRegister(uint32_t addr, uint32_t word0, uint32_t word1, uint32_t byteMask);

	private:
		PhysicalMemoryInterface& downstream_;
		int threadId_;
		Tlb tlb_;

		//Sizing lives in MultiThreadingConfig.h, shared with the core
		//and (eventually) the cache -- MAX_THREADS is just a short local
		//alias so the rest of this file stays readable.
		static const int MAX_THREADS = NUM_THREADS_PER_CORE;

		uint32_t controlRegister_[MAX_THREADS];
		uint32_t contextTablePointerRegister_[MAX_THREADS];
		uint32_t contextRegister_[MAX_THREADS];
		uint32_t faultStatusRegister_[MAX_THREADS];
		uint32_t faultAddressRegister_[MAX_THREADS];

		//Ajit's NOFAULT/IACCESS_FAULT/DACCESS_FAULT, needed for the FSR
		//overwrite (OW) priority rules (Ref Appendix H.5): a data-access
		//fault is never overwritten by an instruction-access fault.
		enum FaultClass { NO_FAULT = 0, IACCESS_FAULT = 1, DACCESS_FAULT = 2 };
		uint8_t faultClass_[MAX_THREADS];

		//---------------------------------------------------------------
		// Walk-in-progress and walk-result state. Promoted from what
		// were function-local variables in walkPageTables()/translate()
		// (Ref Plan_MMU_integration.md's "Sitar timing model" section):
		// a walk now spans multiple physical-access boundaries (one
		// beginWalk()/recordWalkStep() sequence per level visited), so
		// this state has to survive between those calls rather than
		// living on the stack of one opaque function.
		//---------------------------------------------------------------
		uint32_t walkL1Index_, walkL2Index_, walkL3Index_; //fixed for one walk, set by beginWalk()
		uint8_t  walkCurLevel_;                            //level the next fetch (walkCurPhyAddr_) is at
		uint64_t walkCurPhyAddr_;                          //address to fetch next

		uint32_t walkResultPte_;         //final PTE (walk-terminated-here, or TLB hit)
		uint8_t  walkResultLevel_;       //level that PTE was found/cached at
		uint64_t walkResultPhyAddrOfPte_;//physical address that PTE itself lives at (R/M write-back target)
		bool     translateWasTlbHit_;    //gates whether commitTranslation() needs to insert

		uint32_t stagedUpdatedPte_;      //pending R/M-updated PTE value, set by computeAndStageRMUpdate()

		CoreLogger* logger_;
		const unsigned long* simulatedTime_;
		void log(const std::string& event, const std::string& detail);

		//Every tlb_ touch point (translate(), probe(), flush(),
		//writeRegister()'s CTP-write side effect) calls this instead of
		//reading tlbEnabled directly, so the MMU_TLB_PRESENT invariant is
		//checked in exactly one place.
		bool tlbActive() const;

		//The shared translate-and-permission-check step behind CASE 6 of
		//the dispatch (an ordinary instruction/data access, as opposed to
		//an MMU-register/flush/probe/pass-through one). Handles the
		//MMU-absent-or-disabled pass-through case internally too (Ajit
		//has this check in two places -- its CASE 2 dispatch shortcut and
		//again inside translateToPhysicalAddress(); this unifies them,
		//since they're functionally equivalent). Returns false, with
		//mae-worthy fault state recorded, on a page fault.
		//
		//isAtomic changes the permission check itself, not just which AT
		//value is used: an atomic load-store (LDSTUB/SWAP) is checked as
		//a single, precise operation requiring *both* load and store
		//permission against the page's ACC value, faulting before any
		//memory access at all if either would fail. This deviates from
		//Ajit's own implementation (a locked plain read, permission-
		//checked as a load, followed by a separate unlocked plain write,
		//permission-checked as a store -- so a read-permitted,
		//write-forbidden page lets the read complete and become visible
		//before the write half faults). See docs/compliance/ for the
		//write-up of why: the manual's own default trap model (Ref
		//Chapter 7) requires ordinary MMU faults on a "multiple-access"
		//instruction (its own term for LDSTUB/SWAP/LDD) to be precise,
		//unlike the one exception it does carve out (non-resumable
		//machine-check faults) -- Ajit's split-transaction behavior isn't
		//precise for this case.
		bool translate(uint32_t va, uint32_t asi, bool isInstructionFetch, bool isWrite, bool isAtomic,
		                uint64_t& physicalAddr, bool& cacheable, uint8_t& acc);

		//The three per-accessType handlers access() dispatches to.
		//isInstructionFetch/readSecondWord: handleReadAccess() covers both
		//IFETCH (one word, isInstructionFetch=true) and LOAD (two words --
		//Ref MemoryInterfaces.h's readWord0/readWord1 -- isInstructionFetch=
		//false) through one function, since every ASI-based special case
		//(register/probe/pass-through/cache) behaves identically for both;
		//only CASE 6's ordinary translated access reads a second word, and
		//only for LOAD. A LOAD's second word reuses the same translate()
		//call's physical address +4 rather than translating it separately
		//-- safe because the caller (SparcStateMachine.cpp) always aligns
		//to an 8-byte boundary first, and a doubleword access 8-byte-
		//aligned can never cross a 4KB page boundary.
		void handleReadAccess(uint32_t address, uint32_t asi, bool isInstructionFetch, bool readSecondWord,
		                       uint32_t& readWord0, uint32_t& readWord1, bool& mae);
		void handleWriteAccess(uint32_t address, uint32_t word0, uint32_t word1, uint32_t byte_mask, uint32_t asi, bool& mae);
		void handleAtomicAccess(uint32_t address, uint32_t word0, uint32_t word1, uint32_t byte_mask, uint32_t asi,
		                         uint32_t& readWord0, uint32_t& readWord1, bool& mae);

		uint32_t readPageTableEntryFromMemory(uint64_t physAddr);
		void writePageTableEntryToMemory(uint64_t physAddr, uint32_t value);

		//The half-select adaptation between this class's own 32-bit-word
		//shaped public interface and PhysicalMemoryInterface's
		//64-bit-doubleword-shaped one -- Ref MemoryInterfaces.h's file
		//comment for the AJIT ACB citation this mimics. physAddr need
		//only be word-aligned (4 bytes); the doubleword-aligned base and
		//which half physAddr falls in are both derived here. Shared by
		//readWord()'s CASE 6 and readPageTableEntryFromMemory(), which
		//are otherwise identical operations once translated to a
		//physical address.
		uint32_t readPhysicalWord(uint64_t physAddr, bool& mae);

		//One physical READ transaction returning both 32-bit halves of
		//the doubleword at physAddr (internally doubleword-aligned, same
		//as readPhysicalWord()). A LOAD's word0 (address) and word1
		//(address+4) are always the same doubleword (Ref
		//MemoryInterfaces.h: the caller always 8-byte-aligns first), so
		//handleReadAccess()'s LOAD path uses this instead of calling
		//readPhysicalWord() twice -- two calls to the same address were
		//functionally harmless (idempotent instant read) but would
		//double-charge every LOAD's fetch once this is a real timed
		//transaction on the Sitar side.
		void readPhysicalDoubleword(uint64_t physAddr, uint32_t& word0, uint32_t& word1, bool& mae);

		//word0/word1/byte_mask: same doubleword-at-once shape
		//writeMaskedDoubleWord() already receives at the virtual
		//interface (word0 at the doubleword-aligned base, word1 at
		//base+4, byte_mask's low nibble selecting word0's bytes, high
		//nibble word1's) -- physAddr must already be doubleword-aligned
		//(same precondition as the virtual interface's own address).
		//Packs directly into PhysicalMemoryInterface's (data, byteMask)
		//shape, no half-select needed since both sides are already
		//doubleword-shaped. Shared by writeMaskedDoubleWord()'s CASE 6
		//and writePageTableEntryToMemory() (which constructs a
		//single-half write by zeroing the other word and masking it out).
		void writePhysicalMaskedDoubleWord(uint64_t physAddr, uint32_t word0, uint32_t word1, uint32_t byte_mask, bool& mae);

		//Same doubleword packing as writePhysicalMaskedDoubleWord(), for
		//atomicReadModifyWrite()'s two call sites (bypass and CASE 6) --
		//returns the pre-write doubleword contents, unpacked the same way.
		void atomicReadModifyWritePhysical(uint64_t physAddr, uint32_t word0, uint32_t word1, uint32_t byte_mask,
		                                    uint32_t& readWord0, uint32_t& readWord1, bool& mae);

		static uint64_t getPhyAddrFromPTD(uint32_t ptd, uint32_t index);
		static uint64_t constructPhysicalAddr(uint32_t pte, uint8_t level, uint32_t va);
		static uint8_t computeAccessType(uint32_t asi, bool isWrite);
		static uint8_t computeFaultType(uint8_t at, uint32_t pte);

		void recordFault(uint8_t at, uint8_t faultType, uint8_t level, uint32_t va, bool isInstructionFetch);
		void updateFsrFar(uint32_t fsrVal, uint32_t farVal, uint8_t faultClass);
};

#endif //MMUCORE_H

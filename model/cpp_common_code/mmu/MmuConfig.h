//MmuConfig.h
//
//Compile-time MMU structural/sizing parameters. These are modeling
//choices, not values the SPARC V8 manual mandates (unlike the register
//bit-field layouts etc. in Addresses.h). No constructor parameter,
//build flag, or runtime config -- change a value here and recompile.
//See mmu/README.md's "Configuration" section for more.

#ifndef MMU_CONFIG_H
#define MMU_CONFIG_H

//Whether this build includes TLB (Page Descriptor Cache) hardware at
//all. This is a genuine part of the model, not just a host-simulation-
//speed detail -- with a TLB present, translation results are cached and
//MmuStats' TLB hit/miss/walk counters reflect that; without one, every
//access re-walks the page tables and those counters behave accordingly.
//The sizing constants below are only meaningful when this is true.
//
//This is the compile-time axis; the runtime axis (should the TLB
//actually be used for a *specific* run, given that it's present) is
//MmuCore::tlbEnabled, which must be false whenever this is false --
//MmuCore asserts that at run time.
static const bool MMU_TLB_PRESENT = true;

// TLB (Page Descriptor Cache) sizing, one constant per walk-termination
// level -- Ref Tlb.h's class comment for why there are 4 levels at all.
// Follows AJIT's own design doc ("The AJIT Processor", Madhav P. Desai,
// IIT Bombay -- docs/processor/ajit_processor_description.pdf in the
// ajit-toolchain repo, section 4.3), which states TLB sizes of
// 2/4/16/256 entries for levels 0-3. This disagrees with the actual
// C_multi_core_multi_thread/mmu/include/TlbNew.h source we ported from
// (which hardcodes 2/8/16/64, confirmed directly against its
// findOrAllocateSetAssociativeMemory(...) calls) -- the design doc is
// treated as authoritative here, on the assumption the C model's own
// sizing is simply stale relative to it.

//Level 0 (context-table-direct "Root" leaves): fully associative.
//Any positive integer is safe.
static const int MMU_TLB_LEVEL0_ENTRIES = 2;

//Level 1 (16MB "region" leaves): fully associative.
//Any positive integer is safe.
static const int MMU_TLB_LEVEL1_ENTRIES = 4;

//Level 2 (256KB "segment" leaves): fully associative.
//Any positive integer is safe.
static const int MMU_TLB_LEVEL2_ENTRIES = 16;

//Level 3 (ordinary 4KB pages) ways per set. Any positive integer is
//safe; typically 1-8. The design doc gives only a total entry count
//(256) for level 3, not a sets x ways split -- 8 ways is this model's
//own choice, keeping the per-lookup search cost fixed regardless of
//total TLB size (Ref MMU_TLB_LEVEL3_SETS below, which absorbs all of
//the doc's size increase instead).
static const int MMU_TLB_LEVEL3_WAYS = 8;

//Level 3 (ordinary 4KB pages) number of sets: 256 total entries / 8
//ways = 32 sets. Must be a power of two (Tlb::level3SetIndex()
//extracts a fixed-width bit field of the VA to pick a set, and a bit
//field can only select a power-of-two-sized range). Valid range: 1 to
//2^19. Upper bound derived from the level-3 tag itself being VA[31:12]
//(20 bits) -- at least 1 of those bits must remain after removing the
//set-index bits, or entries within a set could never be told apart, so
//the set index can be at most 19 bits wide. Tlb's constructor asserts
//both constraints at construction time.
static const int MMU_TLB_LEVEL3_SETS = 32;

// Control Register SC field (Ref Appendix H.3: implementation-defined).
// This model's own choice of which SC bit means "always cacheable,
// regardless of the PTE's own C bit". Valid range: 8-23 (Figure H-10's
// SC field -- anywhere outside that collides with a spec-mandated bit
// instead of an implementation-defined one). Bit 8 matches the AJIT
// model this was ported from; an older AJIT generation used bit 11
// instead (Ref Plan_MMU_integration.md's "Deviations" item 4) -- drift
// between AJIT generations, not a spec requirement either way.
static const int MMU_CONTROL_ALWAYS_CACHEABLE_BIT = 8;

#endif

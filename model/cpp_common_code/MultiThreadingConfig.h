//MultiThreadingConfig.h
//
//Number of hardware threads (SMT) per core. SPARC V8 itself has no
//notion of multithreading -- this is purely an implementation choice
//about how many independent {register file, trap state, MMU register
//set, ...} slots one core's hardware provides, matching AJIT's own
//multi-threaded cores (branch marshal, MMU_MAX_NUMBER_OF_THREADS).
//
//Lives here, one level above mmu/, rather than inside the MMU's own
//MmuConfig.h, because it's not MMU-specific: the core's own register
//file and (eventually) an L1 cache's per-thread state need the same
//number, and should all size off this one constant rather than each
//picking their own.
//
//This model currently only ever constructs thread 0 -- see Mmu.h's own
//constructor comment -- so this value is not yet exercised beyond
//sizing per-thread arrays.
//
//CAVEAT: some call sites (Mmu.cpp's `threadId_ & 1` thread-index
//selection) hardcode an assumption that this is exactly 2, via a
//power-of-2 bitmask trick. Changing this value alone does NOT make
//those call sites correct for a different thread count -- they would
//need updating to something like `threadId_ % NUM_THREADS_PER_CORE`
//first.

#ifndef MULTI_THREADING_CONFIG_H
#define MULTI_THREADING_CONFIG_H

static const int NUM_THREADS_PER_CORE = 2;

#endif

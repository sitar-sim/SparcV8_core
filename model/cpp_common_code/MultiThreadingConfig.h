//MultiThreadingConfig.h
//
//Number of hardware threads (SMT) per core: how many independent
//register file, trap state, and MMU register set slots one core's
//hardware provides. SPARC V8 itself has no notion of multithreading,
//this is an implementation choice.
//
//Lives one level above mmu/, not inside MmuConfig.h, since the core's
//own register file and a future L1 cache's per-thread state need the
//same number.
//
//This model currently only ever constructs thread 0, so this value is
//not yet exercised beyond sizing per-thread arrays.
//
//Some call sites (MmuCore.cpp's `threadId_ & 1` thread-index selection)
//hardcode an assumption that this is exactly 2. Changing this value
//alone does not make those call sites correct for a different thread
//count.

#ifndef MULTI_THREADING_CONFIG_H
#define MULTI_THREADING_CONFIG_H

static const int NUM_THREADS_PER_CORE = 2;

#endif

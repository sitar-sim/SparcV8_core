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
//Only 1 is supported so far: every configuration constructs one thread
//per core. The multithreaded configurations will allow 1, 2, or 4, once
//the core, the MMU, and the caches handle more than one thread; until
//then the static_assert below stops a build with any other value.

#ifndef MULTI_THREADING_CONFIG_H
#define MULTI_THREADING_CONFIG_H

static const int NUM_THREADS_PER_CORE = 1;

static_assert(NUM_THREADS_PER_CORE == 1, "only 1 thread per core is supported so far");

#endif

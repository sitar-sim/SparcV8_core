// multicore_sync.h
//
// Synchronization routines for programs running on several cores: the
// atomic instructions themselves, mutexes, an atomic counter, a ticket
// lock, a barrier and a semaphore. All of them are small inline
// functions. Every structure here works if it starts out all zero, except
// a semaphore, which is given its count with SEMAPHORE_INITIALIZER.
//
// Three things hold for all of them.
//
// - They wait by spinning, without a limit. A core waiting for a lock
//   that is never released stays here until the run's cycle limit.
// - The caches are not coherent, so they read shared state with uncached
//   loads, which take a physical address (Ref multicore_core.h). That works
//   as it is by default, and matters only if a program turns the MMU on and
//   maps shared data elsewhere. AJIT's own mutex routines spin with a
//   plain load, which would never see the release here if the lock's line
//   were cached.
// - They are not safe to use from an interrupt handler. A handler that
//   waits for a lock its own core already holds waits for ever.
//
// A lock protects the data, but it does not refresh the cache. Data shared
// under a lock must also be read with read_shared(), or after a
// flush_caches() inside the critical section.

#ifndef MULTICORE_SYNC_H
#define MULTICORE_SYNC_H

#include <stdint.h>
#include "multicore_core.h"

#define MULTICORE_MAX_CORES 4

//---------------------------------------------------------------------
// The atomic instructions
//---------------------------------------------------------------------

// LDSTUB: reads the byte at p and sets it to 0xFF, as one indivisible
// action. Returns the old value, so 0 means this core was the one that
// changed it.
static inline uint8_t atomic_ldstub(volatile uint8_t* p)
{
	uint32_t old;
	__asm__ __volatile__("ldstub [%1], %0" : "=r"(old) : "r"(p) : "memory");
	return (uint8_t) old;
}

// SWAP: exchanges the word at p with value, as one indivisible action.
// Returns the old value.
static inline uint32_t atomic_swap(volatile uint32_t* p, uint32_t value)
{
	__asm__ __volatile__("swap [%1], %0" : "=r"(value) : "r"(p), "0"(value) : "memory");
	return value;
}

// STBAR: earlier stores reach memory before later ones. The model never
// reorders stores, so this does nothing there, but the architecture allows
// it, so correct programs use it before releasing a lock.
static inline void memory_fence(void)
{
	__asm__ __volatile__("stbar" : : : "memory");
}

//---------------------------------------------------------------------
// Mutexes, with the names and arguments of AJIT's routines
//---------------------------------------------------------------------
// Each spins on an uncached load while the lock is held, and tries the
// atomic instruction again only once it looks free. Atomic instructions
// lock the whole bus, so spinning on them would slow every other core.

// Uses the byte at mutex_address. 0 means free.
static inline void acquire_mutex_using_ldstub(int mutex_address)
{
	volatile uint8_t* lock = (volatile uint8_t*) mutex_address;
	while (atomic_ldstub(lock) != 0)
		while (read_shared_byte(lock) != 0)
			;
}

// Returns 1 if the lock was free and is now held by this core, else 0.
static inline int try_acquire_mutex_using_ldstub(int mutex_address)
{
	return atomic_ldstub((volatile uint8_t*) mutex_address) == 0;
}

static inline void release_mutex_using_ldstub(int mutex_address)
{
	memory_fence();
	*(volatile uint8_t*) mutex_address = 0;
}

// Uses the word at mutex_address. 0 means free.
static inline void acquire_mutex_using_swap(int mutex_address)
{
	volatile uint32_t* lock = (volatile uint32_t*) mutex_address;
	while (atomic_swap(lock, 1) != 0)
		while (read_shared(lock) != 0)
			;
}

static inline void release_mutex_using_swap(int mutex_address)
{
	memory_fence();
	*(volatile uint32_t*) mutex_address = 0;
}

//---------------------------------------------------------------------
// Atomic counter
//---------------------------------------------------------------------
// SPARC V8 has no compare-and-swap or fetch-and-add instruction, so a
// counter is guarded by a lock byte of its own.

typedef struct
{
	volatile uint8_t  guard;
	volatile uint32_t value;
} atomic_counter_t;

// Adds delta and returns the value before the addition.
static inline uint32_t atomic_fetch_and_add(atomic_counter_t* c, uint32_t delta)
{
	uint32_t old;
	acquire_mutex_using_ldstub((int) &c->guard);
	old = read_shared(&c->value);
	c->value = old + delta;
	release_mutex_using_ldstub((int) &c->guard);
	return old;
}

static inline uint32_t atomic_counter_read(atomic_counter_t* c)
{
	return read_shared(&c->value);
}

//---------------------------------------------------------------------
// Ticket lock
//---------------------------------------------------------------------
// A mutex that serves waiting cores strictly in the order they arrived,
// so no core can be overtaken for ever. Each core takes the next ticket
// and waits until its number is called.

typedef struct
{
	atomic_counter_t  next_ticket;
	volatile uint32_t now_serving;
} ticket_lock_t;

// Returns this core's ticket, which is its position in the order.
static inline uint32_t ticket_lock_acquire(ticket_lock_t* l)
{
	uint32_t ticket = atomic_fetch_and_add(&l->next_ticket, 1);
	while (read_shared(&l->now_serving) != ticket)
		;
	return ticket;
}

static inline void ticket_lock_release(ticket_lock_t* l)
{
	memory_fence();
	//Only the holder ever writes this.
	l->now_serving = read_shared(&l->now_serving) + 1;
}

//---------------------------------------------------------------------
// Barrier
//---------------------------------------------------------------------
// No core leaves barrier_wait() until num_cores cores have entered it. A
// barrier can be reused at once. Each pass through it flips a "sense", and
// the last core to arrive flips the shared one, which releases the others.
// A core that is slow to notice cannot be caught by the next pass, because
// it is waiting for a particular value, not for a count.

typedef struct
{
	atomic_counter_t  arrived;
	volatile uint32_t sense;
	volatile uint32_t local_sense[MULTICORE_MAX_CORES];
} barrier_t;

static inline void barrier_wait(barrier_t* b, uint32_t num_cores)
{
	uint32_t id = this_core_id();
	//Only this core writes its own entry, so its cached copy is never old.
	uint32_t sense = !b->local_sense[id];
	b->local_sense[id] = sense;
	if (atomic_fetch_and_add(&b->arrived, 1) == num_cores - 1)
	{
		//Every other core is now waiting, so nobody else touches `arrived`.
		b->arrived.value = 0;
		memory_fence();
		b->sense = sense;
	}
	else
	{
		while (read_shared(&b->sense) != sense)
			;
	}
}

//---------------------------------------------------------------------
// Semaphore
//---------------------------------------------------------------------
// A count of free resources. semaphore_wait() takes one, waiting until
// there is one, and semaphore_post() returns one.

typedef struct
{
	volatile uint8_t  guard;
	volatile uint32_t count;
} semaphore_t;

#define SEMAPHORE_INITIALIZER(n) { 0, (n) }

// Returns 1 if a resource was taken, 0 if there were none free.
static inline int semaphore_try_wait(semaphore_t* s)
{
	int taken = 0;
	uint32_t count;
	acquire_mutex_using_ldstub((int) &s->guard);
	count = read_shared(&s->count);
	if (count > 0)
	{
		s->count = count - 1;
		taken = 1;
	}
	release_mutex_using_ldstub((int) &s->guard);
	return taken;
}

static inline void semaphore_wait(semaphore_t* s)
{
	while (!semaphore_try_wait(s))
		;
}

static inline void semaphore_post(semaphore_t* s)
{
	acquire_mutex_using_ldstub((int) &s->guard);
	s->count = read_shared(&s->count) + 1;
	release_mutex_using_ldstub((int) &s->guard);
}

#endif

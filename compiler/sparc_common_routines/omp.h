// omp.h
//
// OpenMP on the bare `multicore` configuration: the omp_* routines of OpenMP 3.0, and
// the GOMP_* routines that sparc-elf-gcc 4.4's -fopenmp turns the pragmas into. Written
// for this project. There is no libgomp in the toolchain.
//
//     #include <omp.h>
//     int main(void)
//     {
//         #pragma omp parallel
//         ...
//         return 0;
//     }
//
// A program is built with `COMPILE_OPTIONS = -fopenmp` and `STARTUP = crt0_multicore.s` in
// its .vprj, and it must include this header, which holds the whole runtime, in its one
// source file.
//
// HOW A PROGRAM RUNS. crt0_multicore.s calls main() on every core. This header defines
// main() itself and renames the program's own, with the #define at the end of the file, so
// that only core 0 runs the program. The other cores wait in worker_loop() for a team to
// join. When the program's main() returns, or calls omp_end_program(), the workers halt
// too, so the run ends. A plain `ta 0` would halt core 0 alone and the run would not end.
//
// A TEAM. A team of n threads is cores 0 to n-1, and a thread's number is its core's ID.
// There is one team at a time, since a parallel region nested in another runs with a team
// of one, which OpenMP allows. Core 0 fills in the team and then wakes each worker through
// a word of its own, so a worker never reads a team that is still being filled in.
//
// WORK-SHARING. A loop, `sections` or `single` takes a slot in a ring. Threads meet in a
// slot by counting the work-shares each has entered, since with `nowait` they can be in
// different ones at once. The first to arrive fills the slot in. A thread that gets a whole
// ring ahead waits until the slowest has left the slot it needs.
//
// MEMORY. The runtime's own reads use read_shared(), so it never hangs on a stale copy.
// A program's shared data must be coherent too, and OpenMP programs need either the default
// uncached run or --coherent. With --always-cacheable alone a thread can read stale shared
// data. As elsewhere in this library, the uncached reads take a physical address, so shared
// data must be identity-mapped if a program turns the MMU on.
//
// FLOATING POINT. The startup files leave the FPU off. This header turns it on, on every
// core, since a worker has no chance to do so itself before running part of a region.
//
// THREADPRIVATE. gcc compiles it to thread-local variables, which SPARC reaches through %g7.
// Each core keeps its copies on its own stack, set up by omp_set_up_thread_local_variables().
//
// LIMITS.
//   - Tasks run at once, on the thread that creates them, which OpenMP allows. A program
//     gets the right results with tasks, but no speedup from them.
//   - Nested regions always have a team of one, so omp_set_nested() has no effect.
//   - There is no omp_get_wtime(), since the system has no clock a program can read.
//   - Loops that need 64-bit iteration counts (GOMP_loop_ull_*) do not link.
//   - Do not use OpenMP from an interrupt handler.

#ifndef OMP_H
#define OMP_H

#include <stdint.h>
#include "multicore_core.h"
#include "multicore_sync.h"
// Defines ajit_generic_interrupt_handler(), which crt0_multicore.s's interrupt entry calls.
#include "ajit_mt_irc.h"

//----------------------------------------------------------------------
// The omp_* interface
//----------------------------------------------------------------------

typedef enum
{
	omp_sched_static  = 1,
	omp_sched_dynamic = 2,
	omp_sched_guided  = 3,
	omp_sched_auto    = 4
} omp_sched_t;

typedef struct
{
	volatile uint32_t word;
} omp_lock_t;

typedef struct
{
	volatile uint32_t word;
	volatile uint32_t owner;
	volatile uint32_t depth;
} omp_nest_lock_t;

void omp_set_num_threads(int n);
int  omp_get_num_threads(void);
int  omp_get_max_threads(void);
int  omp_get_thread_num(void);
int  omp_get_num_procs(void);
int  omp_in_parallel(void);
void omp_set_dynamic(int on);
int  omp_get_dynamic(void);
void omp_set_nested(int on);
int  omp_get_nested(void);
void omp_set_schedule(omp_sched_t kind, int modifier);
void omp_get_schedule(omp_sched_t* kind, int* modifier);
int  omp_get_thread_limit(void);
void omp_set_max_active_levels(int n);
int  omp_get_max_active_levels(void);
int  omp_get_level(void);
int  omp_get_ancestor_thread_num(int level);
int  omp_get_team_size(int level);
int  omp_get_active_level(void);

void omp_init_lock(omp_lock_t* lock);
void omp_destroy_lock(omp_lock_t* lock);
void omp_set_lock(omp_lock_t* lock);
void omp_unset_lock(omp_lock_t* lock);
int  omp_test_lock(omp_lock_t* lock);
void omp_init_nest_lock(omp_nest_lock_t* lock);
void omp_destroy_nest_lock(omp_nest_lock_t* lock);
void omp_set_nest_lock(omp_nest_lock_t* lock);
void omp_unset_nest_lock(omp_nest_lock_t* lock);
int  omp_test_nest_lock(omp_nest_lock_t* lock);

// Not part of OpenMP. Ends the whole run from outside any parallel region: the workers halt,
// and core 0 halts with these values in %o0 and %o1. A program's main() returning r does
// the same as omp_end_program(r, 0).
void omp_end_program(uint32_t o0, uint32_t o1);

//----------------------------------------------------------------------
// The runtime's state
//----------------------------------------------------------------------

#define OMP_RING_SLOTS        8      //work-shares a thread can be ahead of the slowest
#define OMP_MAX_SERIAL_DEPTH  8      //nested regions, each with a team of one
#define OMP_CENSUS_POLLS      20000  //how long core 0 waits at startup for a core to arrive

#define OMP_GO_RUN   1
#define OMP_GO_STOP  2

#define OMP_FATAL_NESTED_TOO_DEEP 0xBAD0E571u

typedef struct
{
	volatile uint32_t lock;
	volatile uint32_t tag;          //1 + the count of the work-share using this slot, 0 if unused
	volatile uint32_t threads_left; //how many threads have left it
	volatile int32_t  kind;         //an omp_sched_t
	volatile int32_t  next, end, incr, chunk, start;
	volatile uint32_t ordered;      //1 if the loop has an ordered clause
	volatile int32_t  ordered_turn; //the first iteration of the chunk allowed in `ordered` now
	void* volatile    copyprivate;
} omp_work_share_t;

// What a thread keeps for each level of nesting it is in.
typedef struct
{
	uint32_t work_shares_entered;   //counts from 0xffffffff, so the first one is 0
	uint32_t static_trip;           //chunks taken so far of a static loop
	uint32_t holds_chunk;           //1 if this thread holds a chunk of an ordered loop
	int32_t  chunk_start, chunk_end;
} omp_context_t;

typedef struct
{
	uint32_t in_team;               //1 if inside a parallel region with a team over one
	uint32_t thread_num;            //in that team
	uint32_t team_size;             //of that team, 1 otherwise
	uint32_t serial_depth;          //nested regions with a team of one, inside it
	uint32_t level;                 //all enclosing parallel regions
	int32_t  nthreads_var;          //the team size a region gets by default
	int32_t  run_sched_kind;        //schedule(runtime)
	int32_t  run_sched_chunk;
	omp_context_t    context[OMP_MAX_SERIAL_DEPTH + 1];
	omp_work_share_t serial_ws[OMP_MAX_SERIAL_DEPTH + 1];
} omp_thread_t;

typedef struct
{
	void (*volatile fn)(void*);
	void* volatile  data;
	volatile uint32_t size;
	volatile uint32_t first_work_share;   //what a worker's count starts from
	volatile int32_t  nthreads_var;       //what a worker inherits
	volatile int32_t  run_sched_kind;
	volatile int32_t  run_sched_chunk;
	atomic_counter_t  barrier_arrived;
	volatile uint32_t barrier_generation;
	omp_work_share_t  ws[OMP_RING_SLOTS];
} omp_team_t;

static omp_team_t      omp_team;
static omp_thread_t    omp_threads[MULTICORE_MAX_CORES];
static volatile uint32_t omp_go[MULTICORE_MAX_CORES];
static volatile uint32_t omp_core_online[MULTICORE_MAX_CORES];
static uint32_t        omp_num_procs = 1;
static volatile uint32_t omp_critical_lock;
static volatile uint32_t omp_atomic_lock;

static inline omp_thread_t* omp_this_thread(void)
{
	return &omp_threads[this_core_id()];
}

static inline int32_t omp_read(volatile int32_t* p)
{
	return (int32_t) read_shared((volatile uint32_t*) p);
}

// Whether a thread is working in the shared team now, rather than alone in a nested region
// or outside every region.
static inline int omp_in_shared_team(omp_thread_t* t)
{
	return t->in_team && t->serial_depth == 0;
}

static inline uint32_t omp_current_team_size(omp_thread_t* t)
{
	return omp_in_shared_team(t) ? t->team_size : 1;
}

static inline uint32_t omp_current_thread_num(omp_thread_t* t)
{
	return omp_in_shared_team(t) ? t->thread_num : 0;
}

static void omp_halt_this_core(uint32_t o0, uint32_t o1)
{
	__asm__ __volatile__("mov %0, %%o0\n\tmov %1, %%o1\n\tta 0"
	                     : : "r"(o0), "r"(o1) : "o0", "o1");
	while (1) {}
}

static void omp_stop_workers(void)
{
	uint32_t i;
	for (i = 1; i < omp_num_procs; i++)
		omp_go[i] = OMP_GO_STOP;
}

// Something a program did that the runtime cannot carry out. The run ends with the code in %o0.
static void omp_fatal(uint32_t code)
{
	omp_stop_workers();
	omp_halt_this_core(code, 0);
}

//----------------------------------------------------------------------
// Barrier. It counts generations, so nothing needs resetting between teams of different sizes.
//----------------------------------------------------------------------

static void omp_barrier(omp_thread_t* t)
{
	uint32_t size = omp_current_team_size(t);
	uint32_t generation;
	if (size <= 1)
		return;
	generation = read_shared(&omp_team.barrier_generation);
	if (atomic_fetch_and_add(&omp_team.barrier_arrived, 1) == size - 1)
	{
		omp_team.barrier_arrived.value = 0;
		memory_fence();
		omp_team.barrier_generation = generation + 1;
	}
	else
	{
		while (read_shared(&omp_team.barrier_generation) == generation)
			;
	}
}

//----------------------------------------------------------------------
// Work-shares
//----------------------------------------------------------------------

static inline omp_context_t* omp_context(omp_thread_t* t)
{
	return &t->context[t->serial_depth];
}

static inline omp_work_share_t* omp_current_work_share(omp_thread_t* t)
{
	if (omp_in_shared_team(t))
		return &omp_team.ws[omp_context(t)->work_shares_entered % OMP_RING_SLOTS];
	return &t->serial_ws[t->serial_depth];
}

// Enters the next work-share, and returns its slot with the slot's lock held. *first is 1
// for the first thread to arrive, which must fill the slot in before unlocking.
static omp_work_share_t* omp_enter_work_share(omp_thread_t* t, int* first)
{
	omp_context_t* c = omp_context(t);
	omp_work_share_t* w;
	uint32_t tag;

	c->work_shares_entered++;
	c->static_trip = 0;
	c->holds_chunk = 0;
	w = omp_current_work_share(t);
	if (!omp_in_shared_team(t))
	{
		acquire_mutex_using_swap((int) &w->lock);
		*first = 1;
		return w;
	}

	tag = c->work_shares_entered + 1;
	while (1)
	{
		acquire_mutex_using_swap((int) &w->lock);
		if (read_shared(&w->tag) == tag)
		{
			*first = 0;
			return w;
		}
		if (read_shared(&w->tag) == 0 || read_shared(&w->threads_left) == t->team_size)
		{
			w->tag = tag;
			w->threads_left = 0;
			*first = 1;
			return w;
		}
		//An earlier work-share is still using this slot. Wait without the lock, since on a
		//schedule that runs the cores in lock step, retrying with it held could keep the
		//thread that must leave the slot from ever getting it.
		release_mutex_using_swap((int) &w->lock);
		while (read_shared(&w->tag) != tag && read_shared(&w->threads_left) != t->team_size)
			;
	}
}

// A thread passes the turn on only once it has the turn. A chunk whose iterations all skipped
// `ordered` must still wait here, or it would move the turn past an older chunk, whose thread
// would then wait forever.
static void omp_release_ordered_turn(omp_context_t* c, omp_work_share_t* w)
{
	if (c->holds_chunk)
	{
		while (omp_read(&w->ordered_turn) != c->chunk_start)
			;
		memory_fence();
		w->ordered_turn = c->chunk_end;
		c->holds_chunk = 0;
	}
}

static void omp_leave_work_share(omp_thread_t* t)
{
	omp_work_share_t* w = omp_current_work_share(t);
	omp_release_ordered_turn(omp_context(t), w);
	if (omp_in_shared_team(t))
	{
		acquire_mutex_using_swap((int) &w->lock);
		w->threads_left = read_shared(&w->threads_left) + 1;
		release_mutex_using_swap((int) &w->lock);
	}
}

static void omp_fill_in_loop(omp_work_share_t* w, int32_t kind, long start, long end, long incr, long chunk, uint32_t ordered)
{
	if (kind == omp_sched_auto)
		kind = omp_sched_static;
	if (kind != omp_sched_static && chunk < 1)
		chunk = 1;
	w->kind  = kind;
	w->start = start;
	w->next  = start;
	w->end   = end;
	w->incr  = incr;
	w->chunk = chunk;
	w->ordered = ordered;
	w->ordered_turn = start;
}

static inline int32_t omp_iterations_between(int32_t from, int32_t to, int32_t incr)
{
	return incr > 0 ? (to - from + incr - 1) / incr : (from - to - incr - 1) / -incr;
}

// A thread's next chunk of a static loop, which depends only on its number. With no chunk
// size, the iterations are divided as evenly as possible, and each thread has one chunk.
static int omp_take_static_chunk(omp_thread_t* t, omp_work_share_t* w, int32_t* first, int32_t* last)
{
	omp_context_t* c = omp_context(t);
	int32_t  start = omp_read(&w->start), end = omp_read(&w->end), incr = omp_read(&w->incr);
	int32_t  chunk = omp_read(&w->chunk);
	int32_t  n = omp_iterations_between(start, end, incr);
	int32_t  id = omp_current_thread_num(t), size = omp_current_team_size(t);
	int32_t  from, to;

	if (chunk <= 0)
	{
		int32_t q = n / size, extra = n % size;
		if (c->static_trip > 0)
			return 0;
		if (id < extra)
		{
			q++;
			extra = 0;
		}
		from = q * id + extra;
		to   = from + q;
	}
	else
	{
		from = (c->static_trip * size + id) * chunk;
		to   = from + chunk;
	}
	c->static_trip++;
	if (from >= n)
		return 0;
	*first = start + from * incr;
	*last  = to < n ? start + to * incr : end;
	return 1;
}

// A thread's next chunk of a dynamic or guided loop, whichever thread asks next.
static int omp_take_shared_chunk(omp_thread_t* t, omp_work_share_t* w, int32_t* first, int32_t* last)
{
	int32_t next, end, incr, chunk, left, taken = 0;

	acquire_mutex_using_swap((int) &w->lock);
	next = omp_read(&w->next);
	end  = omp_read(&w->end);
	incr = omp_read(&w->incr);
	chunk = omp_read(&w->chunk);
	left = omp_iterations_between(next, end, incr);
	if (left > 0)
	{
		if (omp_read(&w->kind) == omp_sched_guided)
		{
			int32_t size = omp_current_team_size(t);
			int32_t share = (left + size - 1) / size;
			if (share > chunk)
				chunk = share;
		}
		*first = next;
		*last  = chunk < left ? next + chunk * incr : end;
		w->next = *last;
		taken = 1;
	}
	release_mutex_using_swap((int) &w->lock);
	return taken;
}

static int omp_take_chunk(omp_thread_t* t, int32_t* first, int32_t* last)
{
	omp_work_share_t* w = omp_current_work_share(t);
	omp_context_t* c = omp_context(t);
	int taken;

	omp_release_ordered_turn(c, w);
	if (omp_read(&w->kind) == omp_sched_static)
		taken = omp_take_static_chunk(t, w, first, last);
	else
		taken = omp_take_shared_chunk(t, w, first, last);
	if (taken && read_shared(&w->ordered))
	{
		c->holds_chunk = 1;
		c->chunk_start = *first;
		c->chunk_end   = *last;
	}
	return taken;
}

static int omp_start_loop(omp_sched_t kind, uint32_t ordered, long start, long end, long incr, long chunk, long* first, long* last)
{
	omp_thread_t* t = omp_this_thread();
	int is_first;
	omp_work_share_t* w = omp_enter_work_share(t, &is_first);
	if (is_first)
		omp_fill_in_loop(w, kind, start, end, incr, chunk, ordered);
	release_mutex_using_swap((int) &w->lock);
	return omp_take_chunk(t, (int32_t*) first, (int32_t*) last);
}

static int omp_next_chunk(long* first, long* last)
{
	return omp_take_chunk(omp_this_thread(), (int32_t*) first, (int32_t*) last);
}

//----------------------------------------------------------------------
// Parallel regions
//----------------------------------------------------------------------

// Starts a region. A combined construct (`parallel for`, `parallel sections`) has its first
// work-share filled in here, and its threads go straight to asking for chunks.
static void omp_start_region(void (*fn)(void*), void* data, unsigned requested, int combined,
                             omp_sched_t kind, long start, long end, long incr, long chunk)
{
	omp_thread_t* t = omp_this_thread();
	uint32_t i, size = requested != 0 ? requested : (uint32_t) t->nthreads_var;

	if (size > omp_num_procs)
		size = omp_num_procs;
	if (size <= 1 || t->level > 0)
	{
		if (t->serial_depth == OMP_MAX_SERIAL_DEPTH)
			omp_fatal(OMP_FATAL_NESTED_TOO_DEEP);
		t->serial_depth++;
		t->level++;
		omp_context(t)->work_shares_entered = 0xffffffffu;
		if (combined)
		{
			int is_first;
			omp_work_share_t* w = omp_enter_work_share(t, &is_first);
			omp_fill_in_loop(w, kind, start, end, incr, chunk, 0);
			release_mutex_using_swap((int) &w->lock);
		}
		return;
	}

	omp_team.fn   = fn;
	omp_team.data = data;
	omp_team.size = size;
	omp_team.nthreads_var    = t->nthreads_var;
	omp_team.run_sched_kind  = t->run_sched_kind;
	omp_team.run_sched_chunk = t->run_sched_chunk;
	for (i = 0; i < OMP_RING_SLOTS; i++)
		omp_team.ws[i].tag = 0;
	omp_team.first_work_share = 0xffffffffu;
	if (combined)
	{
		omp_fill_in_loop(&omp_team.ws[0], kind, start, end, incr, chunk, 0);
		omp_team.ws[0].tag = 1;
		omp_team.ws[0].threads_left = 0;
		omp_team.first_work_share = 0;
	}

	t->in_team    = 1;
	t->thread_num = 0;
	t->team_size  = size;
	t->level      = 1;
	t->context[0].work_shares_entered = omp_team.first_work_share;
	t->context[0].static_trip = 0;
	t->context[0].holds_chunk = 0;

	memory_fence();
	for (i = 1; i < size; i++)
		omp_go[i] = OMP_GO_RUN;
}

static void omp_worker_loop(uint32_t id)
{
	omp_thread_t* t = &omp_threads[id];
	uint32_t go;

	while (1)
	{
		while ((go = read_shared(&omp_go[id])) == 0)
			;
		omp_go[id] = 0;
		if (go == OMP_GO_STOP)
			omp_halt_this_core(1, 0);

		t->in_team      = 1;
		t->thread_num   = id;
		t->team_size    = read_shared(&omp_team.size);
		t->serial_depth = 0;
		t->level        = 1;
		t->nthreads_var    = omp_read(&omp_team.nthreads_var);
		t->run_sched_kind  = omp_read(&omp_team.run_sched_kind);
		t->run_sched_chunk = omp_read(&omp_team.run_sched_chunk);
		t->context[0].work_shares_entered = read_shared(&omp_team.first_work_share);
		t->context[0].static_trip = 0;
		t->context[0].holds_chunk = 0;

		((void (*)(void*)) read_shared((volatile uint32_t*) &omp_team.fn))
			((void*) read_shared((volatile uint32_t*) &omp_team.data));

		omp_barrier(t);
		t->in_team = 0;
	}
}

//----------------------------------------------------------------------
// What -fopenmp calls: regions
//----------------------------------------------------------------------

void GOMP_parallel_start(void (*fn)(void*), void* data, unsigned num_threads)
{
	omp_start_region(fn, data, num_threads, 0, omp_sched_static, 0, 0, 1, 0);
}

void GOMP_parallel_end(void)
{
	omp_thread_t* t = omp_this_thread();
	if (t->serial_depth > 0)
	{
		t->serial_depth--;
		t->level--;
		return;
	}
	omp_barrier(t);
	t->in_team   = 0;
	t->team_size = 1;
	t->level     = 0;
}

void GOMP_barrier(void)
{
	omp_barrier(omp_this_thread());
}

//----------------------------------------------------------------------
// What -fopenmp calls: critical, atomic, ordered
//----------------------------------------------------------------------

void GOMP_critical_start(void)
{
	acquire_mutex_using_swap((int) &omp_critical_lock);
}

void GOMP_critical_end(void)
{
	release_mutex_using_swap((int) &omp_critical_lock);
}

// A named critical section brings its own word, which the compiler creates, zeroed. The word
// itself serves as the lock.
void GOMP_critical_name_start(void** word)
{
	acquire_mutex_using_swap((int) word);
}

void GOMP_critical_name_end(void** word)
{
	release_mutex_using_swap((int) word);
}

void GOMP_atomic_start(void)
{
	acquire_mutex_using_swap((int) &omp_atomic_lock);
}

void GOMP_atomic_end(void)
{
	release_mutex_using_swap((int) &omp_atomic_lock);
}

// A thread enters when every earlier chunk of the loop is finished. It keeps its turn until
// it asks for another chunk, so that later iterations of its chunk may enter too.
void GOMP_ordered_start(void)
{
	omp_thread_t* t = omp_this_thread();
	omp_context_t* c = omp_context(t);
	omp_work_share_t* w = omp_current_work_share(t);
	if (c->holds_chunk)
		while (omp_read(&w->ordered_turn) != c->chunk_start)
			;
}

void GOMP_ordered_end(void)
{
}

//----------------------------------------------------------------------
// What -fopenmp calls: loops. A plain schedule(static) is compiled inline, with no calls.
//----------------------------------------------------------------------

_Bool GOMP_loop_static_start(long s, long e, long i, long chunk, long* first, long* last)
{
	return omp_start_loop(omp_sched_static, 0, s, e, i, chunk, first, last);
}

_Bool GOMP_loop_dynamic_start(long s, long e, long i, long chunk, long* first, long* last)
{
	return omp_start_loop(omp_sched_dynamic, 0, s, e, i, chunk, first, last);
}

_Bool GOMP_loop_guided_start(long s, long e, long i, long chunk, long* first, long* last)
{
	return omp_start_loop(omp_sched_guided, 0, s, e, i, chunk, first, last);
}

_Bool GOMP_loop_runtime_start(long s, long e, long i, long* first, long* last)
{
	omp_thread_t* t = omp_this_thread();
	return omp_start_loop((omp_sched_t) t->run_sched_kind, 0, s, e, i, t->run_sched_chunk, first, last);
}

_Bool GOMP_loop_ordered_static_start(long s, long e, long i, long chunk, long* first, long* last)
{
	return omp_start_loop(omp_sched_static, 1, s, e, i, chunk, first, last);
}

_Bool GOMP_loop_ordered_dynamic_start(long s, long e, long i, long chunk, long* first, long* last)
{
	return omp_start_loop(omp_sched_dynamic, 1, s, e, i, chunk, first, last);
}

_Bool GOMP_loop_ordered_guided_start(long s, long e, long i, long chunk, long* first, long* last)
{
	return omp_start_loop(omp_sched_guided, 1, s, e, i, chunk, first, last);
}

_Bool GOMP_loop_ordered_runtime_start(long s, long e, long i, long* first, long* last)
{
	omp_thread_t* t = omp_this_thread();
	return omp_start_loop((omp_sched_t) t->run_sched_kind, 1, s, e, i, t->run_sched_chunk, first, last);
}

_Bool GOMP_loop_static_next(long* first, long* last)          { return omp_next_chunk(first, last); }
_Bool GOMP_loop_dynamic_next(long* first, long* last)         { return omp_next_chunk(first, last); }
_Bool GOMP_loop_guided_next(long* first, long* last)          { return omp_next_chunk(first, last); }
_Bool GOMP_loop_runtime_next(long* first, long* last)         { return omp_next_chunk(first, last); }
_Bool GOMP_loop_ordered_static_next(long* first, long* last)  { return omp_next_chunk(first, last); }
_Bool GOMP_loop_ordered_dynamic_next(long* first, long* last) { return omp_next_chunk(first, last); }
_Bool GOMP_loop_ordered_guided_next(long* first, long* last)  { return omp_next_chunk(first, last); }
_Bool GOMP_loop_ordered_runtime_next(long* first, long* last) { return omp_next_chunk(first, last); }

void GOMP_loop_end(void)
{
	omp_thread_t* t = omp_this_thread();
	omp_leave_work_share(t);
	omp_barrier(t);
}

void GOMP_loop_end_nowait(void)
{
	omp_leave_work_share(omp_this_thread());
}

void GOMP_parallel_loop_static_start(void (*fn)(void*), void* data, unsigned n, long s, long e, long i, long chunk)
{
	omp_start_region(fn, data, n, 1, omp_sched_static, s, e, i, chunk);
}

void GOMP_parallel_loop_dynamic_start(void (*fn)(void*), void* data, unsigned n, long s, long e, long i, long chunk)
{
	omp_start_region(fn, data, n, 1, omp_sched_dynamic, s, e, i, chunk);
}

void GOMP_parallel_loop_guided_start(void (*fn)(void*), void* data, unsigned n, long s, long e, long i, long chunk)
{
	omp_start_region(fn, data, n, 1, omp_sched_guided, s, e, i, chunk);
}

void GOMP_parallel_loop_runtime_start(void (*fn)(void*), void* data, unsigned n, long s, long e, long i)
{
	omp_thread_t* t = omp_this_thread();
	omp_start_region(fn, data, n, 1, (omp_sched_t) t->run_sched_kind, s, e, i, t->run_sched_chunk);
}

//----------------------------------------------------------------------
// What -fopenmp calls: sections, which are a dynamic loop over section numbers from 1
//----------------------------------------------------------------------

static unsigned omp_next_section(void)
{
	long first, last;
	return omp_next_chunk(&first, &last) ? (unsigned) first : 0;
}

unsigned GOMP_sections_start(unsigned count)
{
	omp_thread_t* t = omp_this_thread();
	int is_first;
	omp_work_share_t* w = omp_enter_work_share(t, &is_first);
	if (is_first)
		omp_fill_in_loop(w, omp_sched_dynamic, 1, (long) count + 1, 1, 1, 0);
	release_mutex_using_swap((int) &w->lock);
	return omp_next_section();
}

unsigned GOMP_sections_next(void)
{
	return omp_next_section();
}

void GOMP_sections_end(void)
{
	GOMP_loop_end();
}

void GOMP_sections_end_nowait(void)
{
	GOMP_loop_end_nowait();
}

void GOMP_parallel_sections_start(void (*fn)(void*), void* data, unsigned n, unsigned count)
{
	omp_start_region(fn, data, n, 1, omp_sched_dynamic, 1, (long) count + 1, 1, 1);
}

//----------------------------------------------------------------------
// What -fopenmp calls: single
//----------------------------------------------------------------------

_Bool GOMP_single_start(void)
{
	omp_thread_t* t = omp_this_thread();
	int is_first;
	omp_work_share_t* w = omp_enter_work_share(t, &is_first);
	release_mutex_using_swap((int) &w->lock);
	omp_leave_work_share(t);
	return is_first;
}

// `single copyprivate`. The thread that runs the block gets NULL here, and passes the address
// of its data to GOMP_single_copy_end(). A barrier holds the others until the address is ready.
void* GOMP_single_copy_start(void)
{
	omp_thread_t* t = omp_this_thread();
	int is_first;
	void* data;
	omp_work_share_t* w = omp_enter_work_share(t, &is_first);
	release_mutex_using_swap((int) &w->lock);
	if (is_first)
		return 0;
	omp_barrier(t);
	data = (void*) read_shared((volatile uint32_t*) &w->copyprivate);
	omp_leave_work_share(t);
	return data;
}

void GOMP_single_copy_end(void* data)
{
	omp_thread_t* t = omp_this_thread();
	omp_current_work_share(t)->copyprivate = data;
	omp_barrier(t);
	omp_leave_work_share(t);
}

//----------------------------------------------------------------------
// What -fopenmp calls: tasks, which run at once
//----------------------------------------------------------------------

void GOMP_task(void (*fn)(void*), void* data, void (*copy_fn)(void*, void*), long size, long align, _Bool if_clause, unsigned flags)
{
	(void) if_clause;
	(void) flags;
	if (copy_fn)
	{
		char* raw = __builtin_alloca(size + align - 1);
		char* copy = (char*) (((uint32_t) raw + align - 1) & ~((uint32_t) align - 1));
		copy_fn(copy, data);
		fn(copy);
	}
	else
		fn(data);
}

void GOMP_taskwait(void)
{
}

//----------------------------------------------------------------------
// omp_* routines
//----------------------------------------------------------------------

void omp_set_num_threads(int n)
{
	if (n > 0)
		omp_this_thread()->nthreads_var = n;
}

int omp_get_num_threads(void)
{
	return omp_current_team_size(omp_this_thread());
}

int omp_get_max_threads(void)
{
	int n = omp_this_thread()->nthreads_var;
	return n < (int) omp_num_procs ? n : (int) omp_num_procs;
}

int omp_get_thread_num(void)
{
	return omp_current_thread_num(omp_this_thread());
}

int omp_get_num_procs(void)
{
	return omp_num_procs;
}

int omp_in_parallel(void)
{
	return omp_this_thread()->in_team;
}

void omp_set_dynamic(int on)
{
	(void) on;
}

int omp_get_dynamic(void)
{
	return 0;
}

void omp_set_nested(int on)
{
	(void) on;
}

int omp_get_nested(void)
{
	return 0;
}

void omp_set_schedule(omp_sched_t kind, int modifier)
{
	omp_thread_t* t = omp_this_thread();
	t->run_sched_kind  = kind;
	t->run_sched_chunk = modifier;
}

void omp_get_schedule(omp_sched_t* kind, int* modifier)
{
	omp_thread_t* t = omp_this_thread();
	*kind     = (omp_sched_t) t->run_sched_kind;
	*modifier = t->run_sched_chunk;
}

int omp_get_thread_limit(void)
{
	return omp_num_procs;
}

void omp_set_max_active_levels(int n)
{
	(void) n;
}

int omp_get_max_active_levels(void)
{
	return 1;
}

int omp_get_level(void)
{
	return omp_this_thread()->level;
}

int omp_get_active_level(void)
{
	return omp_this_thread()->in_team;
}

// The levels of the regions enclosing a thread are: 0, outside them all, then at most one
// with a shared team, which if present is level 1, and then those with a team of one.
int omp_get_ancestor_thread_num(int level)
{
	omp_thread_t* t = omp_this_thread();
	if (level < 0 || level > (int) t->level)
		return -1;
	return (level == 1 && t->in_team) ? (int) t->thread_num : 0;
}

int omp_get_team_size(int level)
{
	omp_thread_t* t = omp_this_thread();
	if (level < 0 || level > (int) t->level)
		return -1;
	return (level == 1 && t->in_team) ? (int) t->team_size : 1;
}

void omp_init_lock(omp_lock_t* lock)
{
	lock->word = 0;
}

void omp_destroy_lock(omp_lock_t* lock)
{
	(void) lock;
}

void omp_set_lock(omp_lock_t* lock)
{
	acquire_mutex_using_swap((int) &lock->word);
}

void omp_unset_lock(omp_lock_t* lock)
{
	release_mutex_using_swap((int) &lock->word);
}

int omp_test_lock(omp_lock_t* lock)
{
	return atomic_swap(&lock->word, 1) == 0;
}

// A nested lock's owner and depth are written only by the thread that holds the lock. Another
// thread only compares the owner with itself, and it can never match, so that read needs no lock.
void omp_init_nest_lock(omp_nest_lock_t* lock)
{
	lock->word = 0;
	lock->owner = 0;
	lock->depth = 0;
}

void omp_destroy_nest_lock(omp_nest_lock_t* lock)
{
	(void) lock;
}

static inline uint32_t omp_nest_owner_id(void)
{
	return this_core_id() + 1;
}

void omp_set_nest_lock(omp_nest_lock_t* lock)
{
	uint32_t me = omp_nest_owner_id();
	if (read_shared(&lock->owner) != me)
	{
		acquire_mutex_using_swap((int) &lock->word);
		lock->owner = me;
	}
	lock->depth = read_shared(&lock->depth) + 1;
}

void omp_unset_nest_lock(omp_nest_lock_t* lock)
{
	uint32_t depth = read_shared(&lock->depth) - 1;
	lock->depth = depth;
	if (depth == 0)
	{
		lock->owner = 0;
		release_mutex_using_swap((int) &lock->word);
	}
}

int omp_test_nest_lock(omp_nest_lock_t* lock)
{
	uint32_t me = omp_nest_owner_id();
	uint32_t depth;
	if (read_shared(&lock->owner) != me)
	{
		if (atomic_swap(&lock->word, 1) != 0)
			return 0;
		lock->owner = me;
	}
	depth = read_shared(&lock->depth) + 1;
	lock->depth = depth;
	return depth;
}

void omp_end_program(uint32_t o0, uint32_t o1)
{
	omp_stop_workers();
	omp_halt_this_core(o0, o1);
}

//----------------------------------------------------------------------
// Startup
//----------------------------------------------------------------------

// Core 0 finds out which cores are running. A core held back by --run-cores never arrives,
// and nothing else tells a program how many there are.
static void omp_take_census(void)
{
	uint32_t c, polls;
	omp_num_procs = 1;
	for (c = 1; c < MULTICORE_MAX_CORES; c++)
	{
		for (polls = 0; read_shared(&omp_core_online[c]) != 1; polls++)
			if (polls >= OMP_CENSUS_POLLS)
				return;
		omp_num_procs = c + 1;
	}
}

// Turns the FPU on (the PSR's EF bit).
static void omp_enable_fpu(void)
{
	uint32_t psr;
	__asm__ __volatile__("rd %%psr, %0" : "=r"(psr));
	psr |= 1u << 12;
	__asm__ __volatile__("wr %0, %%psr\n\tnop\n\tnop\n\tnop" : : "r"(psr));
}

// The linker's layout of thread-local variables (Ref sparc.ld). With SPARC's layout, %g7 points
// just past a thread's copies, which start with .tdata's initial values, and then .tbss, zeroed.
extern char __tdata_start[], __tdata_end[], __tbss_end[];
extern char __tls_align[];

// `copies` must be room for omp_thread_local_bytes(), aligned to __tls_align.
static uint32_t omp_thread_local_bytes(void)
{
	uint32_t align = (uint32_t) __tls_align;
	return ((uint32_t) (__tbss_end - __tdata_start) + align - 1) & ~(align - 1);
}

static void omp_set_up_thread_local_variables(char* copies)
{
	uint32_t i, size = omp_thread_local_bytes();
	uint32_t initialized = (uint32_t) (__tdata_end - __tdata_start);
	char* thread_pointer = copies + size;
	for (i = 0; i < size; i++)
		copies[i] = i < initialized ? __tdata_start[i] : 0;
	__asm__ __volatile__("mov %0, %%g7" : : "r"(thread_pointer) : "g7");
}

int omp_program_main();

int main(void)
{
	uint32_t id = this_core_id();
	omp_thread_t* t = &omp_threads[id];
	//This frame lasts as long as the core runs, so its thread-local variables can live in it.
	char* raw = __builtin_alloca(omp_thread_local_bytes() + 8);
	omp_set_up_thread_local_variables((char*) (((uint32_t) raw + 7) & ~7u));

	omp_enable_fpu();
	t->team_size = 1;
	t->context[0].work_shares_entered = 0xffffffffu;
	if (id != 0)
	{
		omp_core_online[id] = 1;
		omp_worker_loop(id);
	}

	omp_take_census();
	t->nthreads_var    = omp_num_procs;
	t->run_sched_kind  = omp_sched_dynamic;
	t->run_sched_chunk = 1;
	omp_end_program(omp_program_main(), 0);
	return 0;
}

#define main omp_program_main

#endif

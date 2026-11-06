# Programming the Multicore System

Every core starts at PC 0 and runs the same program. A multicore
program is therefore one program that every core runs, which reads the
core ID to decide what each core does. This page covers the startup
file that prepares every core, how a program finds its core ID, how
cores share data and wait for each other, with and without coherent
caches, how each core takes its own interrupts, and the routines this
project provides for all of this. [Example Programs](examples.md) puts
these pieces together in two complete programs. A program can instead
leave the division of work to OpenMP's pragmas, as [OpenMP
Programs](openmp.md) describes.

---

## The startup file

C programs for the `multicore` configuration start from
[`compiler/crt0_multicore.s`](https://github.com/sitar-sim/SparcV8_core/blob/main/compiler/crt0_multicore.s),
selected with a `STARTUP` line in the program's `.vprj`.

```
SOURCES = my_test.c
STARTUP = crt0_multicore.s
```

It is `crt0_interrupts.s` (see [Writing and Running C
Programs](../writing_and_running_c_programs.md#taking-interrupts)) with
three additions.

1. **A stack for each core.** Core `i`'s stack starts at
   `0x0fffffa0 - i * 0x100000`, so each core has 1 MB of stack of its
   own.
2. **One-time initialization by core 0.** Core 0 clears `.bss`, the
   area of uninitialized global variables, before any core runs
   `main()`.
3. **A release flag.** When it has finished, core 0 writes 1 to word 0
   of the [Scratch-pad](../peripheral_devices_scratch_pad.md). The
   other cores wait for that value before calling `main()`.

The scratch-pad holds the flag because it is a device, and devices are
never cached. Every core therefore sees core 0's write at once, whatever
the state of its own caches and MMU. Programs that use this startup file
should leave scratch-pad word 0 alone.

Because `crt0_multicore.s` takes interrupts, a program using it must
include `ajit_mt_irc.h`, which defines the interrupt dispatch function
it calls.

---

## Finding the core ID

`ajit_get_core_and_thread_id()` (in
`compiler/include/ajit_access_routines.h`) returns the core and thread
ID from ASR29.

```c
#include "ajit_access_routines.h"
#include "ajit_mt_irc.h"

int main(void)
{
	uint8_t core_id, thread_id;
	ajit_get_core_and_thread_id(&core_id, &thread_id);

	volatile uint32_t* results = (volatile uint32_t*) 0x00100000;
	results[core_id] = 0xA0 + core_id;   // each core writes its own word

	__asm__ __volatile__("ta 0");        // every core must halt
	return 0;
}
```

Each core then works on its own part of the data, chosen by its ID, and
halts with `ta 0` when it is done. The run ends once every core has
halted.

---

## Sharing data between cores

Main memory is shared, so a value one core stores can be loaded by any
other. Two properties of the caches decide how a program must go about
it.

- **The caches are write-through.** Every store goes to main memory at
  once, as well as to the core's own cache. A core's stores also reach
  memory in the order the program makes them, since a core has at most
  one access on the bus at a time.
- **By default, the caches are not coherent.** A store by one core does
  not remove an old copy of that line from another core's cache. A core
  that has the line cached keeps reading its old copy. The `--coherent`
  option changes this (see [Coherent caches](#coherent-caches)), and this
  section describes a program written for the default.

Whether anything is cached at all is decided by the MMU. With the MMU
off, as in the examples and tests here, nothing is cached unless the
simulator's "always cacheable" option is set
(`SPARC_ALWAYS_CACHEABLE=1` or `--always-cacheable`). With the MMU on,
the page tables decide. A program that works only with the caches out
of the way is fragile, so the programs here are written to work either
way, and the validation suite runs them both ways.

A core can make sure it reads what another core has written in three
ways.

1. **An uncached load.** A load with an MMU-bypass ASI never uses the
   cache. `read_shared()` (in `multicore_core.h`) reads a word this
   way. With the MMU off, a variable's address is its physical address,
   so `read_shared(&flag)` works on any global variable.
2. **A cache flush.** `flush_caches()` (also in `multicore_core.h`)
   empties the core's own caches with a store to ASI `0x10`. Every load
   after it comes from main memory, until the lines are cached again.
   This suits reading a large block of data that another core has
   produced.
3. **A device.** Devices are never cached. The startup file's release
   flag lives in the scratch-pad for this reason.

Stores need no such care, because the caches are write-through.

### Waiting for another core

The simplest way for cores to coordinate is through **flags**, words
that only one core ever writes. A core announces that something is ready
by storing to its own flag, and another core waits by reading that flag
until it changes.

```c
// core k, after publishing its result:
partial_sum[k] = sum;
done[k] = 1;            // stores reach memory in order, so the sum is there first

// core 0:
while (read_shared(&done[k]) == 0)
	;
total += read_shared(&partial_sum[k]);
```

The tests bound every wait with `WAIT_LIMIT` polls, so a program whose
partner never answers fails its check instead of running until the
cycle limit.

---

## Coherent caches

With the `--coherent` option, a store by one core removes that line from
every other core's caches. A plain load then always returns the latest
value, and none of the care above is needed. A program can be written as
if the caches were not there. The test
`coherence/lock_and_counter_with_plain_loads` does this, with a spinlock
and a counter that use only plain loads.

```sh
./executable/sparc_sim_sitar_multicore my_test.hex --coherent
```

A program written for the default, with uncached loads or flushes, also
runs correctly with `--coherent`. The reverse is not true. A program that
relies on coherence fails without it, usually by waiting for ever on an old
cached copy.

Coherence has a cost. A line that several cores write is removed from the
others on each write, even when the cores use different words of it, which is
called **false sharing**. Each core then misses more, though no value ever
changes. The test `coherence/false_sharing` shows this. Data that different
cores write often is better kept in separate lines, 64 bytes apart.

Two limits remain. A store does not update the writer's own instruction
cache, so a core running code it has just changed must still execute `FLUSH`.
Other cores need no flush for that code. A bypass store does not update the
writer's own cached copy either, though it does remove other cores' copies.

Coherence works with the MMU on as well, whatever virtual addresses and contexts
the cores use, because an invalidate goes by physical address. The tests in
`mmu_coherence/` cover the combinations.

---

## Locks and synchronization

A word written by more than one core needs a lock. Two cores
incrementing the same counter can each read the old value and each
write back one more, and one of the increments is lost. In the test
`atomics/counter_without_lock`, four cores each add 1 to a counter 100
times. Running in step on the sitar_model, they end with a total of just
100, not 400. The cpp_model schedules that were tried give between 100
and 215, and none of them reaches 400.

A lock in turn needs an atomic instruction. SPARC V8 has two, and both
are atomic across cores in both models (see [The bus
lock](structure.md#the-bus-lock)).

- **`LDSTUB`** reads a byte and sets it to `0xFF`. It returns 0 only if
  this core was the one that set it.
- **`SWAP`** exchanges a word with a register.

The routines below are small inline functions in two headers in
`compiler/sparc_common_routines/`, which `compile_c.sh` puts on the
include path. `multicore_core.h` holds what the earlier sections use,
and `multicore_sync.h` holds everything built on the atomic instructions.

### A mutex

A mutex is one byte or word in shared memory, and 0 means free. Global
variables start at 0, so a mutex needs no setup.

```c
#include "ajit_mt_irc.h"       // needed by the startup file
#include "multicore_sync.h"

static volatile uint8_t  counter_lock;
static volatile uint32_t counter;

acquire_mutex_using_ldstub((int) &counter_lock);
counter = read_shared(&counter) + 1;
release_mutex_using_ldstub((int) &counter_lock);
```

The routines have the names and arguments of AJIT's own. While the lock
is held, a waiting core spins on an uncached load, and tries the atomic
instruction again only when the lock looks free. Spinning on the atomic
instruction itself would lock the bus over and over and slow every
other core.

Spinning on an uncached load is a deliberate difference from AJIT's
routines, which spin with a plain load. Without coherent caches, a plain
load could keep reading an old cached copy of the lock and never see it
released. The routines work the same way with `--coherent` on or off.

### What a lock does not do

This section applies when the caches are not coherent. A lock makes sure
only one core is inside, but it does not refresh the cache. Inside the
lock, a plain load can still return this core's old copy of the data.
Data shared under a lock must be read with
`read_shared()`, as above, or with a plain load after `flush_caches()`
inside the lock, as the test `sync_library/flush_inside_lock` does.

### The other routines

| Routine | What it is for |
|---|---|
| `atomic_ldstub()`, `atomic_swap()` | The two instructions themselves. |
| `memory_fence()` | `STBAR`. It keeps earlier stores ahead of later ones. The model never reorders stores, so here it has no effect, but the architecture allows reordering, so a correct program uses it, as the release routines do. |
| `acquire_mutex_using_swap()`, `release_mutex_using_swap()` | A mutex in one word, using `SWAP`. |
| `try_acquire_mutex_using_ldstub()` | Takes the mutex only if it is free, and returns whether it did. |
| `atomic_fetch_and_add()`, `atomic_counter_read()` | An `atomic_counter_t`. SPARC V8 has no fetch-and-add instruction, so the counter has a lock byte of its own. |
| `ticket_lock_acquire()`, `ticket_lock_release()` | A `ticket_lock_t`. Unlike a mutex, it serves cores strictly in the order they arrived, so no core can be overtaken for ever. |
| `barrier_wait()` | A `barrier_t`. No core leaves until the given number of cores have arrived. It can be reused at once. |
| `semaphore_wait()`, `semaphore_try_wait()`, `semaphore_post()` | A `semaphore_t`, a count of free resources, initialized with `SEMAPHORE_INITIALIZER(n)`. |

Three limits apply to all of them.

- They wait by spinning, without a limit, so a lock that is never
  released keeps a core spinning until the run's cycle limit.
- Their uncached loads take a physical address. The MMU is off when a
  program starts, so this works as it is by default. A program that turns
  the MMU on must keep the locks and other shared structures at virtual
  addresses equal to their physical addresses, as the tests in
  `mmu_coherence/` do.
- They are not safe to use from an interrupt handler. A handler that
  waits for a lock its own core already holds waits for ever.

### Mixing `LDSTUB` and `SWAP` on one lock

`LDSTUB` looks only at the byte it names, and the machine is big-endian,
so byte 0 is the most significant byte of a word. A `SWAP` of the value
1 leaves that byte 0, and an `LDSTUB` on the same word would see the
lock as free. A program that uses both on one lock must `SWAP` a value
with the top byte set, as the test `atomics/mixed_instructions` does.
The routines above use each lock with one instruction only, so they do
not have this problem.

---

## Interrupts on several cores

The Interrupt Controller has a slot for each core, and core `i` takes
its interrupts from slot `2i` (see [Interrupts](structure.md#interrupts)).
Each core enables its own slot, and the levels it wants, by writing its
own slot's control register. Bit 0 enables the slot, and bit `n` lets
level `n` through.

```c
uint32_t id = this_core_id();
ajit_set_interrupt_handler(TIMER_IRL, timer_handler);
writeInterruptControlRegister(id, 0, (1u << TIMER_IRL) | 1u);
```

The table of handlers that `ajit_set_interrupt_handler()` fills in,
`ajit_global_interrupt_handlers`, is one global array, shared by every
core. Core 0 clears it with the rest of `.bss`. Every core can safely
install the same handler for a level, since the writes agree. A handler
that must act differently on each core reads the core ID itself.

- **Device interrupts.** The Timer and the Serial device raise their
  level in every slot, and each slot's mask decides which cores take
  it. A core that leaves the timer's level out of its mask never sees
  the timer. The test `interrupts/timer_to_selected_cores` does this.
- **Inter-processor interrupts (IPIs).** One core interrupts another
  through the controller's IPI block, using the routines in
  `compiler/include/ajit_ipi.h`. The sender enables the destination's
  IPI mask bit, then calls `__ajit_set_ipi_interrupt__()`, which writes
  an 8-byte message for the destination and sets its IPI value bit. The
  destination's handler reads the message and clears its value bit with
  `__ajit_clear_ipi_interrupt__()`. See [Inter-processor
  interrupts](../peripheral_devices_interrupt_controller.md#inter-processor-interrupts-ipi)
  for the registers.

The IPI routines change the shared mask and value words by
read-modify-write. If two cores send IPIs at the same time, one core's
change can be lost. The routines in the next section take care of this.
A program that uses `ajit_ipi.h` directly should hold a mutex while
sending an IPI, or send them from one core at a time, as the test
`interrupts/ipi_from_core0` does.

---

## Devices and the MMU across cores

The header
[`compiler/sparc_common_routines/multicore_platform.h`](https://github.com/sitar-sim/SparcV8_core/blob/main/compiler/sparc_common_routines/multicore_platform.h)
holds what several cores need in order to share the devices and the page tables. A
program includes it in place of `ajit_mt_irc.h`.

### A shared console

One core calls `console_start()` once. After that, any core can call `console_puts()`,
which prints a whole string under a lock, so that lines from different cores never mix.
A run ends when every core has halted, so a program calls `console_wait_until_sent()`
before halting, or its last character can be lost.

### Sending IPIs

Each core calls `ipi_start_on_this_core()` with its handler, before any core sends it
an IPI. A core then sends with `ipi_send()`, and a handler reads the message and clears
the IPI with `ipi_receive()`.

```c
static void handler(void)
{
	uint32_t source;
	void* pointer = ipi_receive(&source);
	// ...
}

int main(void)
{
	ipi_start_on_this_core(handler);
	// ...
	ipi_send(destination_core, some_pointer);
```

Both routines change the controller's registers under one lock. A handler needs that
lock too, so a core holds it only with its interrupts off, using `interrupts_off()` and
`interrupts_restore()`. Otherwise a handler could interrupt the core that holds the
lock, and wait for it for ever. A sender whose destination has not yet taken its last
IPI waits without the lock, since the destination's handler needs the lock in order to
clear that IPI.

### TLB shootdown

Each core's TLB is its own, and a core goes on using its TLB's copy of a page table
entry after another core has changed the entry in memory. Emptying the caches does not
help. The test `tlb_shootdown/stale_without_shootdown` shows this. A core that changes
an entry must therefore get every core to drop its copy.

```c
tlb_shootdown_start_on_this_core();      // on each core, once
// ...
// On the core that changes the entry, after writing it to memory:
tlb_shootdown_page(va, context, NUM_CORES);
```

`tlb_shootdown_page()` drops this core's copy, sends an IPI to each of the others, and
waits for each to answer. It returns the number of cores that did not answer, which is 0
unless a core has halted or has stopped taking interrupts. It waits a bounded time, so such
a core cannot hold it up for ever. When it returns 0, no core can use the old translation.
A core that did not answer still can, so a nonzero result needs the program's attention.
Only one shootdown runs at a time. A core waiting for its turn keeps its interrupts on, so
it can take the one under way.

A handler drops a translation with a store using ASI 3, which also empties that core's
L1 caches. A cached line of the old page therefore goes as well, even with coherence
off.

### Limits of these routines

The locks and the shootdown's shared words are reached at their physical addresses, so
with the MMU on a program's data must be identity-mapped. The shootdown installs its
own IPI handler, so a program cannot use it alongside IPIs of its own. A handler must
not send IPIs or start a shootdown.

---

## Routines provided

| Routine or name | Where | What it does |
|---|---|---|
| `ajit_get_core_and_thread_id()` | `compiler/include/ajit_access_routines.h` | Reads the core and thread ID from ASR29. |
| `__ajit_load_word_mmu_bypass__()`, `__ajit_store_word_mmu_bypass__()`, and byte versions | `compiler/include/ajit_access_routines.h` | Uncached loads and stores, by physical address. |
| `writeInterruptControlRegister()`, `enableInterrupt()`, `setInterruptMask()`, and others | `compiler/include/ajit_mt_irc.h` | Set up a core's own Interrupt Controller slot. |
| `ajit_set_interrupt_handler()` | `compiler/include/ajit_mt_irc.h` | Installs the handler for an interrupt level, in the table every core shares. |
| `__ajit_enable_ipi_interrupt__()`, `__ajit_set_ipi_interrupt__()`, `__ajit_clear_ipi_interrupt__()`, `ajitIpiMessageAddress()` | `compiler/include/ajit_ipi.h` | Send, receive and clear inter-processor interrupts. |
| `this_core_id()` | `compiler/sparc_common_routines/multicore_core.h` | This core's ID, as a number. |
| `read_shared()`, `read_shared_byte()` | `compiler/sparc_common_routines/multicore_core.h` | Read a word or byte another core writes, with an uncached load. |
| `flush_caches()` | `compiler/sparc_common_routines/multicore_core.h` | Empties this core's own L1 caches. |
| Mutexes, atomic counter, ticket lock, barrier, semaphore | `compiler/sparc_common_routines/multicore_sync.h` | See [Locks and synchronization](#locks-and-synchronization). |
| `console_start()`, `console_puts()`, `console_wait_until_sent()` | `compiler/sparc_common_routines/multicore_platform.h` | See [A shared console](#a-shared-console). |
| `ipi_start_on_this_core()`, `ipi_send()`, `ipi_try_send()`, `ipi_pending()`, `ipi_receive()` | `compiler/sparc_common_routines/multicore_platform.h` | See [Sending IPIs](#sending-ipis). |
| `interrupts_off()`, `interrupts_restore()` | `compiler/sparc_common_routines/multicore_platform.h` | Hold this core's maskable interrupts off, and let them back on. |
| `mmu_context()`, `mmu_set_context()`, `tlb_flush_page()`, `tlb_flush_entire()` | `compiler/sparc_common_routines/multicore_platform.h` | Read or change this core's MMU context, and drop its own translations. |
| `tlb_shootdown_start_on_this_core()`, `tlb_shootdown_page()` | `compiler/sparc_common_routines/multicore_platform.h` | See [TLB shootdown](#tlb-shootdown). |
| OpenMP's `omp_` routines, and the runtime behind its pragmas | `compiler/sparc_common_routines/omp.h` | See [OpenMP Programs](openmp.md). |
| `report_and_halt()` | `validation/multicore/multicore_common.h` | Reports this core's checks in `%o0` and `%o1`, and halts. |
| `finish_and_wait_for_all()` | `validation/multicore/multicore_common.h` | Marks this core finished in a word of its own and waits for the others, so that every core can check a final result. |
| `NUM_CORES`, `SHARED_BASE`, `WAIT_LIMIT` | `validation/multicore/multicore_common.h` | The number of cores the tests assume, a shared area for results at `0x00100000`, and the bound on every wait loop. |

The routines in `compiler/include/` follow the names and signatures of
AJIT's own access routines, so code written for AJIT compiles here
unchanged. The interrupt levels' names, `TIMER_IRL`, `IPI_IRL` and
`SERIAL_IRL`, are in `compiler/include/device_addresses.h`. `multicore_common.h` belongs to
the validation suite. A program outside `validation/multicore/` can
include it by its path, or copy what it needs. The IPI routines of `ajit_ipi.h` write a
message only once the destination is free, so an IPI not yet taken keeps its message.

A program can also leave the division of work to OpenMP's pragmas, which run on top of these
routines. See [OpenMP Programs](openmp.md).

# Programming the Multicore System

Every core starts at PC 0 and runs the same program. A multicore
program is therefore one program that every core runs, which reads the
core ID to decide what each core does. This page covers the startup
file that prepares every core, how a program finds its core ID, how
cores share data and wait for each other while the caches are not
coherent, how each core takes its own interrupts, and the routines this
project provides for all of this. [Example Programs](examples.md) puts
these pieces together in two complete programs.

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
   `0x0ffffff0 - i * 0x100000`, so each core has 1 MB of stack of its
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
- **The caches are not coherent.** A store by one core does not remove
  an old copy of that line from another core's cache. A core that has
  the line cached keeps reading its old copy.

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
   cache. `read_shared()` (in `multicore_common.h`) reads a word this
   way. With the MMU off, a variable's address is its physical address,
   so `read_shared(&flag)` works on any global variable.
2. **A cache flush.** `flush_caches()` (also in `multicore_common.h`)
   empties the core's own caches with a store to ASI `0x10`. Every load
   after it comes from main memory, until the lines are cached again.
   This suits reading a large block of data that another core has
   produced.
3. **A device.** Devices are never cached. The startup file's release
   flag lives in the scratch-pad for this reason.

Stores need no such care, because the caches are write-through.

### Waiting for another core

Until the cores have atomic operations (a later stage), cores
coordinate through **flags**, words that only one core ever writes. A
core announces that something is ready by storing to its own flag, and
another core waits by reading that flag until it changes.

```c
// core k, after publishing its result:
partial_sum[k] = sum;
done[k] = 1;            // stores reach memory in order, so the sum is there first

// core 0:
while (read_shared(&done[k]) == 0)
	;
total += read_shared(&partial_sum[k]);
```

A word written by more than one core needs a lock, and a lock needs an
atomic operation. Two cores incrementing the same counter, for example,
can each read the old value and each write back one more, losing an
increment. The examples here therefore give each core its own words to
write. The `multicore` cpp_model runs each instruction to completion,
so `LDSTUB` and `SWAP` are atomic there, but the sitar_model does not
lock the bus for them yet (see [Assumptions](structure.md#assumptions)).

The tests bound every wait with `WAIT_LIMIT` polls, so a program whose
partner never answers fails its check instead of running until the
cycle limit.

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
change can be lost. Until the cores have atomic operations, a program
should therefore send IPIs from one core at a time, as the test
`interrupts/ipi_from_core0` does. The IPI block's lock word is meant
for this purpose once a lock can be built.

---

## Routines provided

| Routine or name | Where | What it does |
|---|---|---|
| `ajit_get_core_and_thread_id()` | `compiler/include/ajit_access_routines.h` | Reads the core and thread ID from ASR29. |
| `__ajit_load_word_mmu_bypass__()`, `__ajit_store_word_mmu_bypass__()`, and byte versions | `compiler/include/ajit_access_routines.h` | Uncached loads and stores, by physical address. |
| `writeInterruptControlRegister()`, `enableInterrupt()`, `setInterruptMask()`, and others | `compiler/include/ajit_mt_irc.h` | Set up a core's own Interrupt Controller slot. |
| `ajit_set_interrupt_handler()` | `compiler/include/ajit_mt_irc.h` | Installs the handler for an interrupt level, in the table every core shares. |
| `__ajit_enable_ipi_interrupt__()`, `__ajit_set_ipi_interrupt__()`, `__ajit_clear_ipi_interrupt__()`, `ajitIpiMessageAddress()` | `compiler/include/ajit_ipi.h` | Send, receive and clear inter-processor interrupts. |
| `this_core_id()` | `validation/multicore/multicore_common.h` | This core's ID, as a number. |
| `read_shared()` | `validation/multicore/multicore_common.h` | Reads a word another core writes, with an uncached load. |
| `flush_caches()` | `validation/multicore/multicore_common.h` | Empties this core's own L1 caches. |
| `report_and_halt()` | `validation/multicore/multicore_common.h` | Reports this core's checks in `%o0` and `%o1`, and halts. |
| `NUM_CORES`, `SHARED_BASE`, `WAIT_LIMIT` | `validation/multicore/multicore_common.h` | The number of cores the tests assume, a shared area for results at `0x00100000`, and the bound on every wait loop. |

The routines in `compiler/include/` follow the names and signatures of
AJIT's own access routines, so code written for AJIT compiles here
unchanged. The interrupt levels' names, `TIMER_IRL`, `IPI_IRL` and
`SERIAL_IRL`, are in `compiler/include/device_addresses.h`. `multicore_common.h` belongs to
the validation suite. A program outside `validation/multicore/` can
include it by its path, or copy what it needs.

A library of synchronization routines (locks and barriers) and support
for OpenMP programs are planned, once the cores have atomic operations.

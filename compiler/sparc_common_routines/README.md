# compiler/sparc_common_routines/

Header-only routines for programs running on several cores, in the
`multicore` configuration. `compile_c.sh` puts this folder on the include
path, so a program only needs the `#include`.

| Header | What it holds |
|---|---|
| `multicore_core.h` | This core's ID, uncached reads of what another core wrote, and flushing this core's caches. |
| `multicore_sync.h` | The atomic instructions (`LDSTUB`, `SWAP`), mutexes with the names and arguments of AJIT's, an atomic counter, a ticket lock, a barrier and a semaphore. |
| `multicore_platform.h` | A console shared under a lock, sending and taking IPIs, holding interrupts off, the MMU's context and TLB flushes, and TLB shootdown. |

All of these are written for this project. Where a routine has an AJIT
name, it has AJIT's arguments, so code written for AJIT compiles here. Each
header's comments give its limits. In short, the routines wait by spinning, and
they are not safe to use from an interrupt handler. Their uncached reads take a
physical address, which matters only if a program turns the MMU on and maps
shared data at a different physical address.

The caches are not coherent by default, so a lock does not refresh this core's
cache. Data shared under a lock must be read with `read_shared()`, or after
`flush_caches()` inside the lock. With the simulator's `--coherent` option a plain
load also works, and the routines themselves work the same either way.

The startup file, `crt0_multicore.s`, stays in `compiler/`, where a test's
`STARTUP` line looks for it. The tests of these routines are in
`validation/multicore/sync_library/`, `atomics/`, `devices/`, `interrupts/` and `tlb_shootdown/`, and
the "Programming the Multicore System" page of the documentation explains how
to use them.

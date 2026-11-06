# Validation Suite

`validation/multicore/` holds the programs that run on several cores at
once. They assume the default build, with four cores. This page lists
them, shows how each core's results are checked, and how to run the
suite on both models. See [Validation Suite](../validation_suite.md) for
the test pipeline that every suite shares.

---

## Checking each core's results

Every core reports for itself, as the device tests do on one core.
`%o0` is 1 if every one of the core's checks passed, and `%o1` has one
bit per check. A test's `.vprj` names a core by prefixing a register
with `core<i>.`. A register line without a prefix checks core 0, so
every single-core test keeps working.

```
RESULTS =
o0=0x00000001
core1.o0=0x00000001
core2.o0=0x00000001
core3.o0=0x00000001
m[0x100000]=0x000000a0
```

Memory checks (`m[...]`) read main memory directly, which every core
shares. The run ends once every core has halted, and a core that never
halts makes the test fail when the cycle limit is reached.

The C tests start from `crt0_multicore.s` (their `.vprj`'s `STARTUP`
line) and include `multicore_common.h` (see [Routines
provided](programming.md#routines-provided)). The tests of the
synchronization library also include `multicore_sync.h`.

---

## The tests

| Test | Checks |
|---|---|
| `boot/release_flag_asm` | In assembly, without the startup file. Cores 1 to 3 wait on a release flag in the scratch-pad, set by core 0, then each core writes its own word of memory. Each core's ASR29 is checked too. |
| `boot/crt0_multicore` | What the startup file promises every core: its ASR29 value, its own stack region, `.bss` cleared, and the release flag set. Each core records its arrival in shared memory. |
| `boot/staggered_halt` | Core `i` counts to `(i + 1) * 3000` before halting, so the cores halt far apart, and the run still waits for all of them. |
| `boot/deep_calls_mmu_on` | A call chain deeper than the register windows, with the MMU on. A window overflow writes above the stack pointer, so the startup file must leave room above its first one. |
| `interrupts/ipi_from_core0` | Core 0 sends an inter-processor interrupt to each of cores 1 to 3 in turn. Each takes exactly one, with the right message, and core 0 takes none. |
| `interrupts/timer_to_selected_cores` | Cores 0 to 2 enable the timer's level and core 3 does not. Cores 0 to 2 each take exactly one timer interrupt, and core 3 takes none. |
| `interrupts/ipi_ping_pong` | Two pairs of cores pass an IPI back and forth at the same time. Every IPI arrives, from the right core, with the right pointer. |
| `interrupts/ipi_all_to_all` | Every core sends to every other core at once. All arrive, with message headers and pointers that agree, and each sender's in order. |
| `devices/console_under_lock` | Every core prints lines at once. They come out whole, in any order. |
| `devices/scratch_pad_across_cores` | A write by one core is seen by the others, also through the alias, and byte stores by different cores to one word all take effect. |
| `examples/parallel_sum` | The [parallel array sum](examples.md#parallel-array-sum) example. Checks each core's partial sum and the total. |
| `examples/parallel_matmul` | The [parallel matrix multiply](examples.md#parallel-matrix-multiply) example. Checks every element of the product. |

### Atomic instructions

The tests in `atomics/` check `LDSTUB` and `SWAP` themselves across
cores, with bare instruction loops rather than the library routines.
Each is built so that a broken instruction shows up as a wrong final
result, however the cores interleave.

| Test | Checks |
|---|---|
| `atomics/ldstub_counter` | Every core adds to one counter 100 times under a lock taken with `LDSTUB`. The total must be exact, or two cores were inside at once. |
| `atomics/ldstub_counter_asm` | The same test in assembly, without the startup file or the library. |
| `atomics/swap_counter` | The same with a lock taken with `SWAP`. |
| `atomics/ldstub_one_winner` | Every core does `LDSTUB` on each byte of a row. Exactly one core can read 0 from each byte, so the wins must add up to the number of bytes. |
| `atomics/swap_keeps_every_value` | Five different values are held by the cores and one shared word, and the cores keep swapping them. Each value must still exist exactly once at the end. |
| `atomics/ldstub_neighbour_bytes` | Each core uses `LDSTUB` on its own byte of one shared word, so a model that wrote back more than that byte would disturb a neighbour. |
| `atomics/mixed_instructions` | One lock, taken with `LDSTUB`, `SWAP`, `LDSTUBA` and `SWAPA` by different cores. All four must exclude each other. |
| `atomics/lock_in_scratchpad` | Locks in a device, the scratch-pad, rather than in main memory. |
| `atomics/unmapped_address` | Atomic instructions to an address that maps to nothing must not leave the bus locked, while other cores carry on. |
| `atomics/counter_without_lock` | The program `ldstub_counter` with no lock, showing additions being lost. The total depends on the interleaving, so only its limits are checked. |

### The synchronization library

The tests in `sync_library/` check the routines of
[`multicore_sync.h`](programming.md#locks-and-synchronization).

| Test | Checks |
|---|---|
| `sync_library/mutex_routines` | The AJIT-named mutexes on two counters, and that trying a mutex this core already holds fails. |
| `sync_library/fetch_and_add` | Every value of an atomic counter is handed out exactly once. |
| `sync_library/ticket_lock_order` | A log kept under a ticket lock must read 0, 1, 2 and so on, so cores were served in ticket order. |
| `sync_library/barrier_phases` | Cores doing different amounts of work meet at one reused barrier. After each pass, every core must have reached that phase. |
| `sync_library/semaphore_limit` | A semaphore with a count of 2 never lets more than 2 cores in. |
| `sync_library/flush_inside_lock` | A counter under a mutex, read with a plain load after a flush inside the lock. This matters when run with the caches on. |

### Coherence

The tests in `coherence/` run with coherence on, through a `RUN_OPTIONS`
line in each `.vprj`, and each core turns caching on for itself. They read
shared data with plain cached loads. Each reader first brings the data into its
cache, because a line that was never cached proves nothing, since a miss reads
memory anyway.

| Test | Checks |
|---|---|
| `coherence/write_seen_by_plain_load` | After a core writes a word the others hold in their caches, a plain load sees the new value. |
| `coherence/stale_without_coherence` | The same program with coherence off. The others go on reading the old value until they flush, which shows the first test really tests something. |
| `coherence/lock_and_counter_with_plain_loads` | A spinlock and a counter using only plain loads, with an exact total. |
| `coherence/every_kind_of_write` | A byte store, a doubleword store, `LDSTUB`, `SWAP` and a bypass store all remove other cores' copies. |
| `coherence/instruction_cache` | Other cores run code a core has changed, with no flush, and the writer runs it after `FLUSH`. |
| `coherence/false_sharing` | Cores writing different words of one line never see a wrong value. |
| `coherence/fill_race` | A write during another core's line fill must not leave a stale line. See [Coherence](structure.md#coherence). |
| `coherence/snoop_filter` | With the snoop filter on, invalidates are still delivered to a core that has fetched the line again. |

The litmus tests have the cores do a few reads and writes at the same moment, 100
times over with varying delays, and check that an outcome memory ordering forbids
never happens.

| Test | The cores do | Forbidden |
|---|---|---|
| `coherence/litmus_mp` | Core 0 writes data and then a flag, and others read the flag and then the data. | Seeing the flag but not the data. |
| `coherence/litmus_sb` | Two cores each write one word and read the other. | Both reading 0. TSO allows this, but this model has no store buffer. |
| `coherence/litmus_lb` | Two cores each read one word and write the other. | Both reading 1. |
| `coherence/litmus_iriw` | Two cores write different words, and two others read them in opposite orders. | The readers disagreeing about the order of the writes. |
| `coherence/litmus_corr` | Core 0 writes a word twice, and others read it twice. | Seeing the writes go backwards. |
| `coherence/litmus_2plus2w` | Two cores each write both words, in opposite orders. | A final state that needs a cycle in the order of writes. |

### With the MMU on

In `coherence/` the MMU is off, so a virtual and a physical address are the same.
The tests in `mmu_coherence/` give each core its own view of a shared physical page,
so an invalidate has to find its line from the physical address alone. They run with
`--coherent`, and everything is cached.

| Test | Virtual address | Context | What else |
|---|---|---|---|
| `mmu_coherence/diff_va_across_cores` | Different per core | Shared | Each in a different cache set. Every kind of write. |
| `mmu_coherence/same_va_diff_context` | Same | Different per core | The tags all differ. Every kind of write. |
| `mmu_coherence/diff_va_diff_context` | Different per core | Different per core | Every kind of write. |
| `mmu_coherence/separate_page_tables` | Different per core | A context table per core | Every kind of write. |
| `mmu_coherence/same_va_diff_pa` | Same, different physical pages | Different per core | Not synonyms, so a write must not disturb another core's line. |
| `mmu_coherence/line_in_another_context` | Same | A reader switches away and back | An invalidate goes by physical address, whatever context is running. Runs with two ways, so that the second context's line does not evict the first. |
| `mmu_coherence/code_through_another_address` | Different per core | Shared | The instruction cache. |
| `mmu_coherence/lock_through_aliases` | Different per core | Different per core | A spinlock and a counter, with plain loads. |
| `mmu_coherence/fill_race` | Different per core | Shared | A write during a fill. |
| `mmu_coherence/litmus_mp` | Different per core | Shared | Message passing. |
| `mmu_coherence/pte_write_race` | Same | Shared | Core 0 rewrites a page table entry while other cores walk to it. The R update must not undo the write. |
| `mmu_coherence/pte_update_through_stale_tlb` | Same | Shared | A store through a TLB entry that is out of date must set the M bit in the entry in memory, not write the old copy back. |
| `mmu_coherence/pte_keeps_both_bits` | Same | Shared | One core stores and another loads, each walking at once. The entry ends with both R and M set. |

On one core, `validation/C/caches/synonyms/` covers the same combinations, with
the MMU on and on every configuration with caches. Each test maps one physical page
at two addresses, and writes through one with a store that misses, a store that hits,
a byte store, `LDSTUB` and `SWAP`, and reads through the other. The test
`faulting_access_keeps_line` covers a store or atomic that faults with the MMU's NF bit
set. Such a fault looks like a store to an uncached page, but it has no physical address,
so it must not remove a line.

### TLB shootdown

A shootdown needs the page table setups above, with an IPI to each core and an answer
from each. `tlb_shootdown/` tests `tlb_shootdown_page()`.

| Test | Checks |
|---|---|
| `tlb_shootdown/stale_without_shootdown` | Why it is needed. After core 0 changes an entry, a core that empties its caches still reads the old page, until it drops its TLB entry. |
| `tlb_shootdown/remap_page` | Core 0 keeps moving a page between two physical pages. Each round, every core reads the page chosen. |
| `tlb_shootdown/revoke_write` | Write permission taken away. A store by every core faults, and does not reach memory. |
| `tlb_shootdown/from_every_core` | Every core moves a page of its own at once, so shootdowns overlap. |
| `tlb_shootdown/other_context` | The other cores are running in another context when the entry changes. |
| `tlb_shootdown/waits_for_every_core` | The other cores hold their interrupts off for a while. The shootdown must not return before they have answered. |
| `tlb_shootdown/core_that_does_not_answer` | One core holds its interrupts off until two shootdowns have returned. Each must return anyway, and report that core, though the second cannot even send it an IPI. |

### OpenMP

`openmp/` tests the [OpenMP runtime](openmp.md) with real pragmas, through programs that also
build with the host's `gcc -fopenmp`. The script `check_on_host.py` in that folder runs the
eleven that fit on a host, with four threads, and compares their results with what the `.vprj`
files expect. The four it skips depend on this system. They count its cores, end the run with
an error code, run on one core, or print on its console.

| Test | Checks |
|---|---|
| `openmp/parallel_team` | Team sizes through `num_threads`, `if` and `omp_set_num_threads()`, the data clauses, many regions in a row, and the settings a worker takes from the thread that started the region. |
| `openmp/loop_schedules` | Every schedule, on its own and combined with `parallel`, also `collapse`, loops with no iterations, and the size of a guided loop's first chunk. Every iteration runs exactly once. |
| `openmp/ordered_loops` | `ordered` blocks run in the loop's order under every schedule, also when a chunk skips the block and finishes before an older one. |
| `openmp/sync_constructs` | `critical`, named and unnamed, `atomic`, `reduction`, `barrier`, `master` and `flush`. |
| `openmp/single_and_nowait` | `single` and `copyprivate`, and one thread held back until the others have filled the runtime's ring of work-shares. |
| `openmp/sections` | Each section runs once, in any size of team, also with `lastprivate` and `nowait`. |
| `openmp/locks` | `omp_` locks and nested locks, also the owner of a nested lock. |
| `openmp/nested_and_orphaned` | A nested region has a team of one, and work-sharing pragmas work outside the function holding the region. |
| `openmp/nested_too_deep` | Nesting past the limit ends the run with the code `0xBAD0E571`. |
| `openmp/tasks` | Tasks run, with their own copies of `firstprivate` data, and `taskwait` finishes. |
| `openmp/threadprivate` | Each thread has its own copy, initialized, and `copyin` works. |
| `openmp/floating_point` | Every core can use the FPU in a region. |
| `openmp/on_one_core` | With `--run-cores 1` a program finishes, with teams of one. |
| `openmp/num_procs` | `omp_get_num_procs()` finds all four cores, and a program's return value reaches `%o0`. |
| `openmp/console_in_a_region` | The console routines work from inside a region. |
| `examples/openmp_matmul` | The [worked example](openmp.md#a-worked-example), checked against the same product done by core 0 alone. |

A hang in the runtime shows up as a run reaching its cycle limit, so these tests are the exception
to the bounded waits described [below](#checking-that-the-tests-can-fail).

### Checking that the tests can fail

A test that cannot fail proves nothing, so these were also run on a
sitar_model with the bus lock turned off. Eight of the ten `atomics/`
tests and five of the six `sync_library/` tests then fail.
`counter_without_lock` and `ldstub_neighbour_bytes` pass, as they
should, since neither relies on the lock. `semaphore_limit` also passes
in that run, so it is not a sensitive test of the lock underneath it,
but it does fail when the semaphore itself is removed. `flush_inside_lock`
fails when its flush is removed and the caches are on, and
`unmapped_address` fails if an access to an unmapped address leaves the
bus locked for good.

The `coherence/` tests were checked the same way, with deliberate mistakes in the
model.

| Mistake | Tests that then fail |
|---|---|
| No invalidates sent | All but `stale_without_coherence`, and all of `mmu_coherence/` but `same_va_diff_pa`, which needs none, in both models. |
| A fill in progress installs its line regardless | `fill_race` and `litmus_corr`, on the sitar_model only, since the cpp_model has no such race. |
| The snoop filter never forgets | `snoop_filter`, in both models. |
| The instruction cache is not invalidated | `instruction_cache`, in both models. |
| An older copy of a line is not removed on a fill | `code_aliases` and three others in `C/caches/synonyms/`, in both models. |
| The search for a line looks only in the set its physical address names | Most of `C/caches/synonyms/` and `mmu_coherence/`, in both models. |
| A line keeps its virtual address in place of its physical address | Most of `C/caches/synonyms/` and `mmu_coherence/`, in both models. |
| An atomic does not remove a copy under another address | Six of `C/caches/synonyms/`, in both models. |
| A store through an uncached alias does not remove the cached copy | `uncached_alias`, in both models. |
| A fault suppressed by the NF bit removes a line, as an uncached store does | `faulting_access_keeps_line`, in both models. |
| An invalidate clears the whole set, not just the matching line | `same_va_diff_pa`, in both models. |
| Tags ignore the context | `diff_pa_same_va` and `line_in_another_context`, in both models. |
| An R or M update writes back the old copy of the entry | `pte_update_through_stale_tlb` in both models, and also `pte_write_race` and `pte_keeps_both_bits` on the sitar_model, since the cpp_model has no such race. |
| An R or M update reads the entry again, without holding the bus | `pte_write_race` and `pte_keeps_both_bits`, on the sitar_model. |
| A TLB flush does nothing | Every shootdown test but the two about waiting, and also `pte_keeps_both_bits`, in both models. |
| A shootdown's handler does not drop the translation, or no IPIs are sent | `remap_page`, `revoke_write`, `from_every_core` and `other_context`, in both models. |
| The handler flushes the running context, not the one named | `other_context`, in both models. |
| The starter does not drop its own translation | `remap_page`, `revoke_write` and `from_every_core`, in both models. |
| The starter does not wait for answers | `waits_for_every_core` and `core_that_does_not_answer`, in both models. |
| The starter waits without a limit to send an IPI | `core_that_does_not_answer`, which then never ends, on the cpp_model. |
| No shootdown lock | `from_every_core`, in both models. |
| No lock around the IPI registers and the console | `console_under_lock`, `ipi_ping_pong`, `ipi_all_to_all`, and most shootdown tests, in both models. |
| Senders wait for a busy destination by retrying under the lock | `ipi_all_to_all`, which then never ends, in both models. |
| A message is written before checking for an IPI not yet taken | `ipi_all_to_all`, in both models. |

The first of these shows why each litmus test also checks that a plain load sees
the writes at the end of each round. A stale cache only ever shows old values, which
is not an outcome any litmus test forbids.

Every wait for another core is bounded, so a broken model makes a test
fail rather than run until its cycle limit.

The OpenMP tests were checked the same way, with mistakes in the runtime. Each mistake below was
run on the cpp_model under its default schedule and under `rr:1`, and on the sitar_model, and each
is caught on all three unless the table says otherwise.

| Mistake | Tests that then fail |
|---|---|
| A barrier does not wait | Most of `openmp/`. |
| `critical`, named or unnamed, takes no lock, or all names share one lock | `sync_constructs`. |
| `atomic` takes no lock | `sync_constructs`, `parallel_team`, `nested_and_orphaned` and `floating_point`. |
| A loop's chunks are taken without the lock | `loop_schedules`, `ordered_loops`, `sections`, `single_and_nowait`, `nested_and_orphaned` and `floating_point`. |
| `ordered` does not wait, or a chunk passes on a turn it does not hold | `ordered_loops`. |
| A slot of the work-share ring is taken over too early | `single_and_nowait`. |
| A thread waits for a ring slot by retrying under the lock | `single_and_nowait`, on the cpp_model only. The cores run in lock step there, and the thread that must leave the slot never gets the lock. |
| Every thread is first in a work-share, or none is first in `single` | Several tests, among them `single_and_nowait`. |
| `copyprivate` passes no data, or skips its barrier | `single_and_nowait`. |
| `num_threads` is ignored | `parallel_team`, `nested_and_orphaned` and `nested_too_deep`. |
| A team is not limited to the cores | `parallel_team`. |
| The census assumes every core is running | `on_one_core`. |
| A nested region gets a real team | `nested_and_orphaned`. |
| A nested region's level is not undone | `nested_and_orphaned`, `parallel_team` and `loop_schedules`. |
| A worker keeps its old settings | `parallel_team`. |
| Static chunks ignore the thread number | `loop_schedules` and `ordered_loops`. |
| Guided ignores the share of what is left | `loop_schedules`. |
| A dynamic loop overruns on its last chunk | `loop_schedules` and `nested_and_orphaned`. |
| A task's data is not copied, or not aligned | `tasks`. |
| A lock test always takes the lock, or a nested lock does not check its owner or depth | `locks`. |
| The FPU is left off | `floating_point` and `tasks`. |
| Thread-local data is shared, or not initialized | `threadprivate`. |
| Nesting too deep is not caught | `nested_too_deep`. |
| Workers are not stopped at the end | Nearly every test, which then reach their cycle limit. |

---

## Running the suite

```sh
validation/run_tests.py validation/multicore --config multicore
validation/run_tests.py validation/multicore --config multicore --sitar
```

The tests are written to pass whatever the interleaving of the cores,
whether or not the caches are in use, and whether or not they are coherent.
Running them under several cpp scheduling strategies, with the caches on,
and with coherence on, checks all of this. Tests that need one mode ask for
it themselves in their `.vprj`.

```sh
SPARC_ALWAYS_CACHEABLE=1 validation/run_tests.py validation/multicore --config multicore --sitar
SPARC_ALWAYS_CACHEABLE=1 SPARC_COHERENT=1 validation/run_tests.py validation/multicore --config multicore --sitar
for s in rr:1 rr:4 rr-fixed:1 random:7:32 random:99:3; do
    SPARC_SCHEDULE=$s validation/run_tests.py validation/multicore --config multicore
done
```

The single-core suites run on this configuration too, on core 0 alone.

```sh
for d in asm C test_simple_ADD; do
    SPARC_RUN_CORES=1 validation/run_tests.py validation/$d --config multicore
done
```

With one core running, both models reproduce `core_l1cache_mmu_devices`
cycle for cycle, so these runs also check that the multicore models
did not change what a single core does.

---

## What the suite does not cover

The tests are thorough in what they check, but some things have not been tested.

- **Other numbers of cores.** The tests assume four cores. An OpenMP program was run by hand
  on builds with one, two and three cores, on both models, and gave the right answer, but the
  suite does not run on those builds.
- **Features together.** OpenMP has not been run with the MMU on, or with TLB shootdown.
- **Long runs.** Each test is short. The longest run for about 20 million cycles.
- **Fairness.** Only the ticket lock's order is checked. No test measures whether a core can be
  held off by the others under a plain mutex.
- **The cpp_model against the sitar_model.** Each is checked against a test's expected results.
  Nothing compares their cycle counts, since these differ by design.
- **The real AJIT hardware.** The model follows AJIT's documents, and has not been compared with
  traces from the hardware.

---

## How long the tests run

With the MMU off nothing is cached, so on the sitar_model every
instruction fetch of every core goes through the one shared bus, and the
cores slow each other down. `boot/staggered_halt` takes about 1.1
million cycles with four cores, hence the `MAX_CYCLES` line in its
`.vprj`, and about 150 thousand with `SPARC_ALWAYS_CACHEABLE=1`. The
[Execution Model](execution_model.md#the-sitar_model-cores-run-side-by-side)
page shows how the cycle count grows with the number of cores.

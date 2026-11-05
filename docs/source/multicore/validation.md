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

On one core, `validation/C/caches/synonyms/` covers the same combinations, with
the MMU on and on every configuration with caches. Each test maps one physical page
at two addresses, and writes through one with a store that misses, a store that hits,
a byte store, `LDSTUB` and `SWAP`, and reads through the other. The test
`faulting_access_keeps_line` covers a store or atomic that faults with the MMU's NF bit
set. Such a fault looks like a store to an uncached page, but it has no physical address,
so it must not remove a line.

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

The first of these shows why each litmus test also checks that a plain load sees
the writes at the end of each round. A stale cache only ever shows old values, which
is not an outcome any litmus test forbids.

Every wait for another core is bounded, so a broken model makes a test
fail rather than run until its cycle limit.

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

## How long the tests run

With the MMU off nothing is cached, so on the sitar_model every
instruction fetch of every core goes through the one shared bus, and the
cores slow each other down. `boot/staggered_halt` takes about 1.1
million cycles with four cores, hence the `MAX_CYCLES` line in its
`.vprj`, and about 150 thousand with `SPARC_ALWAYS_CACHEABLE=1`. The
[Execution Model](execution_model.md#the-sitar_model-cores-run-side-by-side)
page shows how the cycle count grows with the number of cores.

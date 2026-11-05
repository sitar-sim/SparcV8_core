# validation/multicore/atomics/

Tests that `LDSTUB` and `SWAP` are atomic across cores. They use bare
instruction loops, not the library's mutexes, so that a failure points at the
instruction and the bus, not at a routine built on top of them.

In the sitar_model each of these instructions is two bus transactions, a read
and then a write, and the bridge's lock keeps other cores off the bus between
them (`model/sitar_component_models/CoherentBridge.sitar`). In the cpp_model each
instruction runs to completion, so nothing can come between them.

Each test is built so that a broken instruction leaves a wrong final result,
however the cores interleave. Every core checks for itself, with one bit per
check in `%o1`, and the comment at the top of each source file lists its checks.

| Test | Idea | What a failure means |
|---|---|---|
| `ldstub_counter` | Every core adds to one counter under an `LDSTUB` lock. | The total is short, so two cores were inside at once. |
| `ldstub_counter_asm` | The same in assembly, with no startup file or library. | The same, with the instruction sequence in plain view. |
| `swap_counter` | The same with a `SWAP` lock. | The same, for `SWAP`. |
| `ldstub_one_winner` | Every core does `LDSTUB` on each byte of a row and counts the zeros. | The wins add up to too many, so two cores both read 0. |
| `swap_keeps_every_value` | Five values are swapped around between the cores and one word. | A value was duplicated or lost. |
| `ldstub_neighbour_bytes` | Each core uses its own byte of one word. | An atomic write changed more than its byte. |
| `mixed_instructions` | One lock, taken by `LDSTUB`, `SWAP`, `LDSTUBA` and `SWAPA`. | The forms do not exclude one another. |
| `lock_in_scratchpad` | Locks in a device, not in memory. | The bus lock does not cover the devices. |
| `unmapped_address` | Atomics to an address that maps to nothing, among normal traffic. | The bus stayed locked, and the run reaches its cycle limit. |
| `counter_without_lock` | `ldstub_counter` with no lock. | Only its limits are checked, since the number of lost additions depends on the interleaving. |

`mixed_instructions` also shows a pitfall. `LDSTUB` sees only the first byte of
a big-endian word, so a `SWAP` on the same lock has to write a value with its top
byte set.

## Running them

```sh
validation/run_tests.py validation/multicore/atomics --config multicore --sitar
validation/run_tests.py validation/multicore/atomics --config multicore
SPARC_ALWAYS_CACHEABLE=1 validation/run_tests.py validation/multicore/atomics --config multicore --sitar
SPARC_SCHEDULE=random:7:32 validation/run_tests.py validation/multicore/atomics --config multicore
```

## Checking that they can fail

With the bus lock turned off in `CoherentBridge.sitar` (by setting `busLocked`
to `false` where it is assigned from `request.lock`), every test here fails on
the sitar_model except `counter_without_lock` and `ldstub_neighbour_bytes`, which
do not rely on the lock. `unmapped_address` also fails with the lock left stuck
after an access to an unmapped address, which is the failure it is there to catch.

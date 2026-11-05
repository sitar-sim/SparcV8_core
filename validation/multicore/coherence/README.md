# validation/multicore/coherence/

Tests of coherent caches, in the `multicore` configuration with `--coherent`. A write
to main memory removes that line from every other core's caches, in both models
(`model/sitar_component_models/CoherentBridge.sitar`,
`model/system_models/multicore/cpp_model/src/CoherentBus.h`,
`model/cpp_common_code/cache/L1CachesCore.h`).

Each test's `.vprj` asks for its mode with a `RUN_OPTIONS` line, and each core turns
caching on for itself. These tests read shared data with plain cached loads, unlike the
rest of `validation/multicore/`, and each reader first brings the data into its cache,
because a line that was never cached proves nothing. A miss reads memory anyway.

| Test | Idea | What a failure means |
|---|---|---|
| `write_seen_by_plain_load` | A core writes a word the others hold cached. | The invalidate did not arrive. |
| `stale_without_coherence` | The same with coherence off, so the others keep the old value until they flush. | The test above would prove nothing, or coherence is on when it should not be. |
| `lock_and_counter_with_plain_loads` | A spinlock and a counter, with plain loads only. | A core waits for ever or a count is lost. |
| `every_kind_of_write` | Byte and doubleword stores, `LDSTUB`, `SWAP`, and a bypass store. | One kind of write does not invalidate. |
| `instruction_cache` | Cores run code one core has changed. | Invalidates do not reach the instruction cache. |
| `false_sharing` | Cores write different words of one line. | An invalidate changed a value. Each invalidate should only cost a miss. |
| `fill_race` | Core 0 writes while others keep forcing fills of that line. | A fill in progress installed a stale line. |
| `snoop_filter` | With the filter on, a core fetches the line again before each write. | The filter left out an invalidate that was needed. |
| `litmus_mp`, `litmus_sb`, `litmus_lb`, `litmus_iriw`, `litmus_corr`, `litmus_2plus2w` | The classic memory-ordering tests, 100 rounds each with varying delays. | An outcome memory ordering forbids happened. |

`litmus_sb` forbids an outcome that SPARC's TSO allows, because this model has no store
buffer. If one is ever added, that check must go.

## Running them

```sh
validation/run_tests.py validation/multicore/coherence --config multicore --sitar
validation/run_tests.py validation/multicore/coherence --config multicore
SPARC_SNOOP_FILTER=1 validation/run_tests.py validation/multicore/coherence --config multicore --sitar
SPARC_SCHEDULE=random:7:32 validation/run_tests.py validation/multicore/coherence --config multicore
```

## Checking that they can fail

Each of these was run with a deliberate mistake in the model, and the named tests
fail.

| Mistake | Fails |
|---|---|
| No invalidates sent | All but `stale_without_coherence`, in both models. |
| A fill in progress installs its line regardless | `fill_race` and `litmus_corr`, on the sitar_model. |
| The snoop filter never forgets | `snoop_filter`, in both models. |
| The instruction cache is not invalidated | `instruction_cache`, in both models. |
| An older copy of a line is not removed on a fill | `validation/C/caches/synonyms/`, in both models. |

Three of these tests are shaped by what such a mistake would otherwise hide.
`fill_race` evicts its line rather than flushing, since a flush slows the readers so
much that few fills overlap a write. `snoop_filter` is in assembly, because compiled C
writes its local variables to the stack, and each of those stores sends an invalidate
that hides a mistake in the filter. Each litmus test also checks that a plain load
sees the writes after each round, because a stale cache only ever shows old values,
which is not an outcome any litmus test forbids.


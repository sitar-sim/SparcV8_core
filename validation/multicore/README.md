# validation/multicore/

Programs that run on several cores at once, for the `multicore`
configuration. Every core runs the same program from PC 0 and uses its
core ID (ASR29) to decide what to do. The tests assume the
configuration's default build, `NUM_CORES = 4`.

C tests start from `compiler/crt0_multicore.s` (their `.vprj`'s
`STARTUP` line), which gives each core its own stack, has core 0 clear
`.bss`, and holds the other cores until core 0 releases them. They
include `multicore_common.h`, and every core reports for itself, as the
`C/devices/` tests do on one core: `%o0` = 1 if all of its checks
passed, `%o1` = one bit per check. The run ends once every core has
halted. A `.vprj` checks each core's registers with a core prefix
(`core2.o0 = 1`; no prefix means core 0) and shared memory with `m[...]`
lines.

| Test | Checks |
|---|---|
| `boot/release_flag_asm` | In assembly, without `crt0_multicore.s`: cores 1 to 3 wait on a release flag in the scratch-pad, set by core 0, then each core writes its own word of memory. Also each core's ASR29. |
| `boot/crt0_multicore` | What `crt0_multicore.s` promises every core: its ASR29, its own stack region, `.bss` cleared, the release flag set. Each core records its arrival in shared memory. |
| `boot/staggered_halt` | Core `i` counts to `(i+1)*3000` before halting, so the cores halt far apart, and the run still waits for all of them. |
| `boot/deep_calls_mmu_on` | A call chain deeper than the register windows, with the MMU on, so the startup file must leave room above its first stack pointer. |

The other folders have the rest of the tests. `interrupts/` covers per-core
interrupts and IPIs, `examples/` holds the worked examples of the docs,
`atomics/` tests `LDSTUB` and `SWAP` across cores, `sync_library/` tests
the routines of `compiler/sparc_common_routines/multicore_sync.h`, `coherence/`
tests coherent caches, and `mmu_coherence/` tests them with the MMU on. The
last four have READMEs of their own.

```sh
validation/run_tests.py validation/multicore --config multicore
validation/run_tests.py validation/multicore --config multicore --sitar
```

With the MMU off nothing is cached, so on the sitar_model every
instruction fetch of every core goes through the one bridge, and the
cores slow each other down: `staggered_halt` takes about 1.1 million
cycles with four cores (hence its `MAX_CYCLES` line), and about 150
thousand with `SPARC_ALWAYS_CACHEABLE=1`.

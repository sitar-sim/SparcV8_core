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
provided](programming.md#routines-provided)).

---

## The tests

| Test | Checks |
|---|---|
| `boot/release_flag_asm` | In assembly, without the startup file. Cores 1 to 3 wait on a release flag in the scratch-pad, set by core 0, then each core writes its own word of memory. Each core's ASR29 is checked too. |
| `boot/crt0_multicore` | What the startup file promises every core: its ASR29 value, its own stack region, `.bss` cleared, and the release flag set. Each core records its arrival in shared memory. |
| `boot/staggered_halt` | Core `i` counts to `(i + 1) * 3000` before halting, so the cores halt far apart, and the run still waits for all of them. |
| `interrupts/ipi_from_core0` | Core 0 sends an inter-processor interrupt to each of cores 1 to 3 in turn. Each takes exactly one, with the right message, and core 0 takes none. |
| `interrupts/timer_to_selected_cores` | Cores 0 to 2 enable the timer's level and core 3 does not. Cores 0 to 2 each take exactly one timer interrupt, and core 3 takes none. |
| `examples/parallel_sum` | The [parallel array sum](examples.md#parallel-array-sum) example. Checks each core's partial sum and the total. |
| `examples/parallel_matmul` | The [parallel matrix multiply](examples.md#parallel-matrix-multiply) example. Checks every element of the product. |

Every wait for another core is bounded, so a broken model makes a test
fail rather than run until its cycle limit.

---

## Running the suite

```sh
validation/run_tests.py validation/multicore --config multicore
validation/run_tests.py validation/multicore --config multicore --sitar
```

The tests are written to pass whatever the interleaving of the cores
and whether or not the caches are in use. Running them under several
cpp scheduling strategies, and with the caches on, checks both.

```sh
SPARC_ALWAYS_CACHEABLE=1 validation/run_tests.py validation/multicore --config multicore --sitar
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

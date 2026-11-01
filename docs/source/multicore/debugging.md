# Logging and Debugging

The logging and gdb support of the single-core configurations works on
the `multicore` configuration too, with each core logged and debugged
on its own. This page covers what changes when there are several cores.
See [Logging](../logging.md) and [Examining Core State with
GDB](../examining_core_state_with_gdb.md) for the tools themselves.

---

## Logging

A build with `--logging` writes a separate instruction trace for each
core, so the traces of different cores never interleave.

```sh
cd model/system_models/multicore/sitar_model
./build.sh --logging
./executable/sparc_sim_sitar_multicore_logging my_test.hex
```

| File | Contents |
|---|---|
| `my_test.log` | Core 0's trace, the same name the single-core configurations use. |
| `my_test.core1.log`, `my_test.core2.log`, ... | The trace of each other core. |
| `sitar.log` | The sitar_model's own module log, as in the single-core configurations. It records, for example, when each core halts. |

Each trace can be opened in the [log viewer](../logging.md#the-log-viewer)
on its own. The cpp_model writes the same per-core trace files. A
parallel run of the sitar_model writes one module log per host thread
instead of `sitar.log` (see [Parallel Simulation](parallel_simulation.md#logging-in-a-parallel-run)).

---

## Debugging with gdb

A build with `--debug` supports the commands of `debug/sparc.gdb`. Every
command that concerns one core's state takes a `coreid=` option. On a
breakpoint, leaving it out means any core can trigger it. When reading
registers, leaving it out means core 0.

```sh
cd model/system_models/multicore/sitar_model
./build.sh --debug
gdb ./executable/sparc_sim_sitar_multicore_debug
```

```
(gdb) source ../../../../debug/sparc.gdb
(gdb) sparc-break pc=0x2a40 coreid=2
(gdb) run my_test.hex
(gdb) sparc-print-reg asr29 coreid=2
asr29 = 0x50520200 (1347551744)
(gdb) sparc-print-reg pc coreid=1
(gdb) sparc-break-trap coreid=3
(gdb) continue
```

ASR29 holds the core ID in bits 15 to 8, so `sparc-print-reg asr29`
shows at a glance which core a register dump belongs to. Main memory is
shared, so the memory commands (`sparc-print-mem` and the memory
watchpoints) see the same memory whichever core is named. The device
registers cannot be read or watched from gdb, and `sparc-print-mem`
reports an error for an address outside main memory. See the [GDB
Command Reference](../gdb_command_reference.md) for every command.

---

## Statistics

`--stats` prints each core's counters (instructions, loads, stores,
cache hits and misses, TLB counters) under its own heading, then the
counters of main memory and the devices. The sitar_model also prints
the number of bus transactions each core made, which shows how much
each core used the shared bus.

---

## Finding data races

A program whose result depends on the order of the cores' memory
accesses has a data race. The cpp_model's scheduling strategies (see
[Execution Model](execution_model.md)) are the tool for finding one. A
program that gives the same result under several strategies and seeds,
and on the sitar_model, is unlikely to depend on the interleaving.

```sh
for s in rr:1 rr:4 rr-fixed:1 random:7:32 random:99:3; do
    SPARC_SCHEDULE=$s validation/run_tests.py validation/multicore --config multicore
done
```

Running with `SPARC_ALWAYS_CACHEABLE=1` as well catches programs that
read an old cached copy of shared data.

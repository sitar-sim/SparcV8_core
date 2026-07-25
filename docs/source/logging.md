# Logging

Logging plays an important role in working with this model: it's how you
watch a program execute instruction by instruction (see
[Getting Started](getting_started.md)), confirm a timing change actually
took effect (see [Performance Modeling](performance_modeling.md)), or
work out why a test is failing without single-stepping a debugger. This
page covers how logging is actually put together across both models, and
how to narrow it down to just the part of a run you care about.

---

## The current scheme

`SparcCore` owns a `CoreLogger` (`SparcCore::logger`) -- one per core
instance, not per driver. Both `cpp_model` and `sitar_model` drive the
same `SparcCore`, so both produce the *identical* trace format from it
(one tab-separated row per architectural event -- fetch, trap, memory
access -- with the entire current-window state), viewable the same way in
`log_viewer/` regardless of which model produced it. See
`log_viewer/README.md` and `model/cpp_common_code/CoreLogger.h`.

A driver uses `CoreLogger` one of two ways:

- **`do_print=true`** (`cpp_model/main.cpp`) -- `CoreLogger` writes each
  row directly to a given `ostream` itself.
- **`do_print=false`** (`sitar_model`) -- each `log_*()` call just
  *returns* the formatted row; the caller (`SparcThread.sitar`) forwards
  it into Sitar's own `log<<` mechanism instead of writing it directly.

That second path is where Sitar's *own* per-module logging comes in.
Every Sitar module/procedure owns a `sitar::logger` (unrelated to
`CoreLogger` -- this is Sitar's own class, see
[Sitar's Logging documentation](https://sitar-sim.github.io/sitar/3_language_and_examples/logging.html)
for the full mechanism), which can be pointed at:

- **A common stream** -- Sitar's own default. `setHierarchicalOstream(TOP, stream)`
  (see `sitar_check_test.cpp`) points *every* module/procedure's logger at
  the same `ostream`, so everything ends up interleaved together in one
  place.
- **A per-module stream** -- pointing just *one* procedure's `.log` at
  its own dedicated `ostream`. This is what `sitar_check_test.cpp` does
  for `sparcThread` specifically: `sparcThread.log.setOstream(&sparcTraceFile)`
  plus `useDefaultPrefix=false`/`setPrefix("")` (to drop Sitar's own
  `(time)hierarchicalId:` prefix), giving `sparcThread`'s own trace --
  pure `CoreLogger` rows, nothing else -- a clean file (`sparc_trace.log`)
  completely separate from `mainMemory`/the `MemoryInterface` instances'
  own messages (`sitar.log`). See `model/sitar_model/README.md`.

---

## Compile-time on/off

Two macros, both tied to the same `--logging` flag (`model/cpp_model/build.sh`
and `model/sitar_model/build.py` both expose it; `build.py --logging` passes
`--cflags=-DSPARC_LOGGING_ENABLED` through to `sitar compile` alongside
Sitar's own `--logging`, so one flag controls both):

- **`SPARC_LOGGING_ENABLED`** -- gates `CoreLogger`. Without it (the
  default), every `log_*()` method compiles down to a trivial `return "";`
  stub -- none of the state-collection/formatting code exists in the
  binary at all, not just skipped at runtime. See `CoreLogger.h`'s file
  comment.
- **`SITAR_ENABLE_LOGGING`** -- gates Sitar's own `sitar::logger` class
  the same way (see `sitar_logger.h` in the separate `sitar` repo).

This is why logging is a rebuild, not a runtime flag: formatting the
entire current-window state (~50 fields) on every single instruction is
real, non-negligible cost, and a `--no-logging` build pays literally none
of it.

---

## Selective on/off at runtime

Even within a `--logging` build, you don't have to log everything. Sitar's
`sitar::logger` has runtime `turnON()`/`turnOFF()`/`isON()` methods,
checked on every `log<<` call -- cheap to toggle as often as you like (see
Sitar's own Logging documentation, linked above, for the full mechanism).

`Core.sitar` has a commented-out example of this: a fourth branch in the
top-level parallel block, alongside `sparcThread`, `mainMemory`, and the
halt-detection monitor, that turns `sparcThread.log` on and off each
cycle based on both simulated time and PC. Copy it out and adjust the two
conditions to your own needs:

```sitar
||
	do
		wait until (this_phase==0);
		$
		bool inTimeWindow = current_time.cycle() >= 1000 && current_time.cycle() < 2000;
		bool inPCRange    = sparcThread.core.reg.R_PC() >= 0x2000 && sparcThread.core.reg.R_PC() < 0x2100;
		if (inTimeWindow && inPCRange)
			sparcThread.log.turnON();
		else
			sparcThread.log.turnOFF();
		$;
		wait(1,0);
	while (1) end do;
```

The `wait(1,0)` at the end matters more than it looks: without it, this
loop never lets simulated time actually advance. `wait until (cond)`
returns immediately once `cond` is already true, which it still is on
the very next iteration with nothing else in the loop to change that --
so it spins at the same simulated instant forever, and hits Sitar's
iteration-limit safety net almost immediately. One cycle is plenty; this
only needs to re-check once per cycle.

Since this toggles `sparcThread.log` itself, it narrows `sparc_trace.log`
down directly -- rows outside the window/range are simply never written,
not filtered out afterward -- turning a long run's trace into something
small and targeted enough to load into `log_viewer/` right away.

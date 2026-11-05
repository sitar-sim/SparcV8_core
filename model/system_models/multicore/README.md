# system_models/multicore/

NUM_CORES SPARC V8 cores, each with its own split L1 instruction and
data caches and its own MMU, sharing one main memory and one set of
[peripheral devices](https://sitar-sim.github.io/SparcV8_core/peripheral_devices.html)
(Timer, Serial, Interrupt Controller, scratch-pad). Each core is
`core_l1cache_mmu_devices`' island, unchanged. Core `i` reads
`0x50520000 | (i << 8)` from ASR29 and takes its interrupts from the
Interrupt Controller's slot for core `i`, thread 0. Every core starts at
the reset PC (0) and runs the same program, which uses the core ID to
decide what each core does.

One compile-time knob, in `cpp_model/src/MulticoreConfig.h` for the
cpp_model and as `System`'s parameter in `sitar_model/src/System.sitar`
for the sitar_model:

- **`NUM_CORES`** (1 to 4, default 4).

One run-time option, in both models:

- **`--coherent`** (or `SPARC_COHERENT=1`, off by default): a write by one
  core removes that line from the other cores' caches. `--snoop-filter`
  leaves out repeated invalidates.

- **`cpp_model/`** -- the 0-delay functional driver: the cores take
  turns on one host thread, in rounds, with a run-time choice of
  interleaving (`--schedule`, see `cpp_model/src/Scheduler.h`).
- **`sitar_model/`** -- the Sitar-timed driver: `NUM_CORES` `Core`
  modules running side by side, meeting at a `CoherentBridge`, which
  serves one physical request at a time, granting the cores
  round-robin.

The run ends when every core has halted. Expected-results lines may
name a core (`REG core2.o0 ...`). A line with no core prefix checks
core 0, so every single-core test runs unchanged with `--run-cores 1`.

# The Multicore System

The `multicore` configuration models several SPARC V8 cores that share
one main memory and one set of peripheral devices. Each core has its
own split L1 instruction and data caches and its own MMU, exactly as in
the single-core [`core_l1cache_mmu_devices`](../model_configurations.md)
configuration. The cores reach memory and the devices over one shared
bus, so a program can run on all of them at once and share data
through memory. The design follows AJIT's multicore processor wherever
that design is known.

---

## The system at a glance

- **Cores.** `NUM_CORES` cores, 4 by default. Core `i` has core ID `i`.
  It reads `0x50520000 | (i << 8)` from ASR29, the same register AJIT
  software uses to find its own core and thread.
- **Caches and MMU.** Each core has its own L1 caches and MMU. The
  caches are write-through, so main memory always holds every value a
  core has written.
- **Coherence.** None yet. A core's caches can keep an old copy of a
  line after another core writes to it. Programs read shared data with
  uncached loads, or flush their caches first.
- **Memory and devices.** One main memory and one set of devices
  (Timer, Serial, Interrupt Controller, [Scratch-pad](../peripheral_devices_scratch_pad.md)),
  shared by every core. The Interrupt Controller has a slot for each
  core and delivers each core its own interrupts.
- **Startup.** Every core starts at PC 0 and runs the same program,
  which reads its core ID to decide what to do.
- **End of a run.** A run ends when every core has halted.

---

## Status

The configuration is being built in stages.

| Stage | Contents | Status |
|---|---|---|
| 1 | The cores, the shared bus, startup of every core, checking each core's results, per-core interrupts | Done |
| 2 | Atomic `LDSTUB` and `SWAP` across cores, and a library of synchronization routines (locks, barriers) | Planned |
| 3 | Write-invalidate cache coherence, the `COHERENT` knob | Planned |
| 4 | Shared devices from several cores (a console under a lock, TLB shootdown through IPIs) | Planned |
| 5 | OpenMP programs, with a bare-metal OpenMP runtime | Planned |
| 6 | Context switching and a scheduler on each core | Planned |
| 7 | Parallel simulation of the sitar_model on several host threads | Done, with speedup measurements on a larger host to follow |

These pages describe what is done, and grow with each stage.

---

## Building and running

Both models are built like any other configuration.

```sh
cd model/system_models/multicore/cpp_model   && ./build.sh
cd model/system_models/multicore/sitar_model && ./build.sh
```

A program then runs on all cores at once.

```sh
./executable/sparc_sim_cpp_multicore <program.hex> [expected] [max_cycles] [--stats] \
    [--schedule <spec>] [--run-cores <m>] ...
```

The other options are those of `core_l1cache_mmu_devices` (cache sizes,
serial and timer options), and they apply to every core.

- **`--run-cores <m>`** runs only cores 0 to `m-1`. The others never
  leave reset, and the run does not wait for them. With `--run-cores 1`,
  any single-core program runs unchanged. The environment variable
  `SPARC_RUN_CORES` does the same.
- **`--schedule <spec>`** (cpp_model only) chooses how the cores'
  instructions are interleaved. See [Execution Model](execution_model.md).
- **`--threads <n>`** and **`--thread-map <list>`** (sitar_model, built
  with `--openmp`) run the simulation on several host threads. See
  [Parallel Simulation](parallel_simulation.md).
- **`--stats`** prints each core's counters, then the shared memory's and
  devices' counters. The sitar_model also prints the number of bus
  transactions each core made.

---

## Compile-time knobs

| Knob | Default | Where | Description |
|---|---|---|---|
| `NUM_CORES` | 4 | cpp_model: [`MulticoreConfig.h`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/multicore/cpp_model/src/MulticoreConfig.h)<br>sitar_model: `System`'s parameter in [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/multicore/sitar_model/src/System.sitar) | Number of cores, 1 to 4. The Interrupt Controller has slots for 4 cores. |
| `COHERENT` | `false` | the same two files | Whether a write by one core invalidates that line in the other cores' caches. Only `false` is implemented so far, and the build stops with an error if it is set to `true`. |

Every Sitar latency knob of the single-core configuration is also in
`System.sitar`, set the same for every core, along with the bus's own
`bridge.delay`. See [Model Configuration
Settings](../model_configuration_settings.md#multicore-multicore).

---

## In these pages

- **[Model Structure and Assumptions](structure.md)** shows how each
  model is built, how the shared bus arbitrates between cores, and
  where the model makes its own assumptions.
- **[Execution Model](execution_model.md)** describes how the cpp_model
  and the sitar_model run several cores, and why their results can
  differ for some programs.
- **[Programming the Multicore System](programming.md)** covers the
  startup file, the core ID, sharing data without coherent caches,
  interrupts on several cores, and the routines provided.
- **[Example Programs](examples.md)** walks through a parallel array
  sum and a parallel matrix multiply.
- **[Logging and Debugging](debugging.md)** covers per-core traces,
  gdb with several cores, and finding data races.
- **[Validation Suite](validation.md)** lists the multicore tests and
  how to run them.
- **[Parallel Simulation](parallel_simulation.md)** runs the sitar_model
  on several host threads, and explains when that is faster.

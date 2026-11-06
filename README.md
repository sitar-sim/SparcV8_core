# SparcV8_core

Models of SPARC V8 processor systems, built with the
[Sitar](https://sitar-sim.github.io/sitar/) modeling and simulation
framework, for teaching and research in computer architecture. They
range from a single core on its own to a four-core system with caches,
MMUs and shared peripheral devices, and a system with a vector
accelerator beside the core. Each system can run real SPARC programs,
written in assembly or C, and is checked against an instruction-level
validation suite.

**Documentation:** https://sitar-sim.github.io/SparcV8_core/

## What it offers

- **A complete SPARC V8 core.** The integer unit, the floating-point
  unit (including quad precision), register windows, traps, and the
  whole memory-access instruction set.
- **Two models of every system.** A `cpp_model`, a fast functional
  model with no notion of time, and a `sitar_model`, a cycle-timed
  model with configurable latencies for each opcode, cache, MMU, bus
  and memory. Both share the same C++ components, so they always agree
  on what a program computes.
- **System components.** The SPARC Reference MMU, split L1 instruction
  and data caches, a shared bus, and peripheral devices (timer,
  interrupt controller, serial device, scratch-pad) compatible with
  those of IIT Bombay's AJIT processor.
- **A multicore system.** Several cores sharing memory and devices,
  with per-core interrupts, inter-processor interrupts, atomic
  instructions, optional coherent caches, TLB shootdown, a library of
  locks and barriers, C programs with real OpenMP pragmas, example
  parallel programs, and a choice of how the cores' instructions
  interleave.
- **The APARA accelerator.** A four-threaded vector compute engine,
  on its own or beside the SPARC core, with its own assembler and C
  compiler.
- **Parallel simulation.** A Sitar model can run on several host
  threads with results identical to a serial run.
  `performance_evaluation/parallel_speedup/` demonstrates a 64-core
  model that runs about twice as fast on 2 threads.
- **Tools for studying a run.** `--stats` performance counters,
  instruction traces with a browser-based log viewer, and gdb
  commands for examining a running model's state.
- **Validation.** Hundreds of assembly and C tests, run on every
  configuration they apply to, in both models.

## Configurations

One folder per configuration under `model/system_models/`, each with
both a `cpp_model` and a `sitar_model`.

| Configuration | What it models |
|---|---|
| `core_only` | The core and main memory. |
| `core_mmu` | Adds the SPARC Reference MMU. |
| `core_mmu_devices` | Adds a timer, an interrupt controller, a serial device and a scratch-pad. |
| `core_l1cache_mmu_devices` | Adds split L1 instruction and data caches. |
| `multicore` | Four cores (`NUM_CORES`, 1 to 4), each with its own caches and MMU, sharing memory and devices over one bus. |
| `apara` | An APARA engine on its own. |
| `sparc_apara` | `core_l1cache_mmu_devices` plus one APARA engine, which the SPARC program loads, runs and exchanges data with. |

## Quick start

Building the `cpp_model`s and running the tests needs only `git`,
`g++` and Python 3. The `sitar_model`s
also need [Sitar](https://github.com/sitar-sim/sitar), and compiling
your own programs needs the bundled cross-toolchain (see the
Installation page of the documentation).

```sh
git clone https://github.com/sitar-sim/SparcV8_core.git
cd SparcV8_core
export SPARC_HOME=$(pwd)

cd model/system_models/core_only/cpp_model
./build.sh
./executable/sparc_sim_cpp_core_only $SPARC_HOME/validation/test_simple_ADD/test_simple_ADD.hex

$SPARC_HOME/validation/run_tests.py $SPARC_HOME/validation
```

The documentation's Getting Started page walks through building the
models, running and tracing a program, the validation suite, compiling
a C program, and debugging with gdb.

## Repository layout

- `model/` holds the models. `cpp_common_code/` has the C++
  components (core, MMU, caches, memory, devices, APARA engine),
  `sitar_component_models/` the Sitar modules built around them, and
  `system_models/` one folder per configuration.
- `validation/` holds the test suites (`asm/`, `C/`, `multicore/`,
  `sparc_apara/`, `apara/`) and `run_tests.py`, which runs the suites a
  configuration can run.
- `compiler/` holds the SPARC cross-toolchain and its scripts, the
  startup files, bare-metal C routines for the devices and the APARA
  engine (`include/`), locks and other routines for multicore programs
  (`sparc_common_routines/`), and the APARA engine's assembler and C compiler
  (`apara/`).
- `performance_evaluation/` holds models and programs for measuring
  the simulator itself, such as the parallel speedup demonstration.
- `log_viewer/` is an offline browser tool for viewing instruction
  traces.
- `debug/` holds the gdb commands for examining a running model.
- `docs/` holds the documentation's source (`source/`) and the
  prebuilt site (`generated_site/`, open `index.html` directly), and
  `compliance/`, the documented differences between this model and the
  AJIT project's reference results.

## What are Sitar and SPARC V8?

[Sitar](https://sitar-sim.github.io/sitar/) is a framework for modeling
and parallel simulation of synchronous (clocked) discrete-event
systems: a modeling language plus a lightweight C++ simulation kernel.
This repository is one model built with it.

SPARC (Scalable Processor ARChitecture) is a RISC instruction-set
architecture from Sun Microsystems, derived from the Berkeley RISC
designs and known for its register windows. SPARC V8 is its 32-bit
version, specified in *The SPARC Architecture Manual, Version 8*,
included here at
[`docs/source/sparcv8_Architecture_reference_Manual.pdf`](docs/source/sparcv8_Architecture_reference_Manual.pdf).

## Acknowledgments

Most of the functional validation suite under `validation/asm/` (and
the toolchain scripts that build and run it under `compiler/`) is
adapted from the **AJIT processor project** (IIT Bombay), specifically
its `ajit32` instruction-level verification suite. See
`validation/asm/README.md` for details, per-file author credit, and the
quad-precision tests that are this project's own (AJIT's suite assumes
quad operations are unimplemented, and this project implements them).
The peripheral devices and the multicore system follow AJIT's
documentation and C model, and the APARA engine was designed at IIT
Bombay. `docs/compliance/README.md` documents the specific,
well-understood differences between AJIT's expected test results and
this model's, intended to be shared with AJIT's authors.

## Authors and License

See [`AUTHORS`](AUTHORS) and [`LICENSE`](LICENSE). Released under the
MIT License.

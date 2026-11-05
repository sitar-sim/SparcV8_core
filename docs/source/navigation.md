---
hide:
  - toc
---

# Navigation

## Introduction

| Page | Description |
|---|---|
| [Overview](index.md) | What this project is, the two models it provides, and how the repository is organized. |
| [Installation](installation.md) | What to install for what you want to do: the basic tools and the code, then, optionally, Sitar, the cross-toolchain, gdb, and MkDocs. |
| [Getting Started](getting_started.md) | A hands-on walkthrough: build the models, run a first program, view its trace, run the validation suite, compile a program yourself, and debug with gdb. |

## The Models

What the models contain: the architecture, the configurations, and
their components.

| Page | Description |
|---|---|
| [SPARC V8 Architecture](sparcv8_architecture.md) | A page-indexed guide into the bundled SPARC V8 manual PDF. |
| [Model Configurations](model_configurations.md) | A block-diagram-level summary of each testbench configuration. |
| [Model Components](model_components.md) | Describes each component in detail: SparcCore, Mmu, Memory, Caches, Devices, the system bus, and the APARA engine. |
| [Peripheral Devices](peripheral_devices.md) | Overview, connection diagram, address map, and interrupt levels for the peripherals below. |
| [Timer](peripheral_devices_timer.md) | Register format, one-shot behavior, and state machine. |
| [Interrupt Controller](peripheral_devices_interrupt_controller.md) | The shared, multi-thread IRC: one slot per hardware thread, interrupt sources, priority, and inter-processor interrupts. |
| [Serial Device](peripheral_devices_serial_device.md) | UART register format, baud-rate calculation, and the Tx/Rx state machines. |
| [Scratch-pad](peripheral_devices_scratch_pad.md) | 32 words of uncached storage shared by every core, for flags between cores. |
| [Model Components Reference](model_components_reference.md) | A complete, per-file table of every Sitar module/procedure. |

## Using the Models

How to write programs for any configuration, set and measure a model,
and log and debug a run. These pages apply to every configuration,
including the multicore system and the APARA configurations.

### Writing Programs

| Page | Description |
|---|---|
| [Assembly Programs](writing_and_running_assembly_programs.md) | How to write, assemble, and run your own assembly test programs. |
| [C Programs](writing_and_running_c_programs.md) | How to write, compile, and run freestanding C test programs. |
| [Cross Compiler](cross_compiler.md) | The bundled `sparc-elf` toolchain used to assemble and compile test programs. |

### Settings and Performance

| Page | Description |
|---|---|
| [Model Configuration Settings](model_configuration_settings.md) | Every structural and timing setting in the model, where to set it, compile time or runtime. |
| [Performance Modeling](performance_modeling.md) | How to print the model's performance measures with `--stats`, and the table of what's reported. |
| [Parallel Simulation](parallel_simulation.md) | Running a Sitar model on several host threads: why the result does not change, what a barrier costs, when a parallel run is faster, and a 64-core speedup demonstration. |

### Logging and Debugging

| Page | Description |
|---|---|
| [Logging](logging.md) | How instruction-trace logging works, compile-time and runtime, and the log viewer. |
| [Examining Core State with GDB](examining_core_state_with_gdb.md) | A beginner-facing walkthrough of debugging a running model with gdb. |
| [GDB Command Reference](gdb_command_reference.md) | The exhaustive reference for every `sparc-*` gdb command. |
| [Debug Support Internals](debug_support_internals.md) | How gdb support is actually built, for anyone extending `debug/sparc.gdb` itself. |

## Validation Suite

| Page | Description |
|---|---|
| [Validation Suite](validation_suite.md) | What's in a test, which suites run on which configuration, how to run them, and how to add a new test. |

The multicore system and the APARA engine each have a validation page
of their own, in their sections below.

## The Multicore System

Several SPARC cores, each with its own caches and MMU, sharing one main
memory and one set of devices (the `multicore` configuration).

| Page | Description |
|---|---|
| [Overview](multicore/index.md) | The system at a glance, the stages it is built in, building and running, and its compile-time knobs. |
| [Model Structure and Assumptions](multicore/structure.md) | How the cpp_model and the sitar_model are built, the shared bus, interrupts, and where the model makes its own assumptions. |
| [Execution Model](multicore/execution_model.md) | How each model runs several cores, what a cycle means in each, and why results can differ between them. |
| [Programming the System](multicore/programming.md) | The startup file, the core ID, sharing data with and without coherent caches, locks and other synchronization, interrupts on several cores, and the routines provided. |
| [Example Programs](multicore/examples.md) | A parallel array sum and a parallel matrix multiply, explained. |
| [Logging and Debugging](multicore/debugging.md) | Per-core traces, gdb with several cores, statistics, and finding data races. |
| [Validation Suite](multicore/validation.md) | The multicore tests, how each core's results are checked, and how to run them. |
| [Parallel Simulation](multicore/parallel_simulation.md) | Building and running the sitar_model on several host threads, and dividing its modules among them. |

## The APARA Accelerator

APARA is a vector compute engine designed to work alongside a SPARC
processor as an accelerator. These pages cover the engine on its own
(`apara`) and next to the SPARC core (`sparc_apara`).

| Page | Description |
|---|---|
| [The APARA Engine](apara/index.md) | Overview of the APARA vector compute engine, and its two configurations. |
| [APARA Instruction Set](apara/isa.md) | The engine's state, data types, bundles, and every instruction. |
| [APARA Assembly Language and Tools](apara/assembly_and_tools.md) | mcode, the assembler and disassembler, and the file formats. |
| [Writing and Running APARA Programs](apara/running.md) | Running an engine program on its own, and how the pipeline handles hazards. |
| [The APARA C Compiler](apara/compiler.md) | `apcc.py`: the C subset, the intrinsics and inline mcode, and running linear algebra programs on the engine. |
| [APARA Timing Model](apara/timing_model.md) | The engine's five-stage pipeline in the Sitar model, and its timing rules and knobs. |
| [The Engine in a System](apara/system.md) | The hardware of `sparc_apara`. Its components, how they are connected, the address map, the control and DMA units, the interrupt, and the two models. |
| [Programming the System](apara/system_programming.md) | How a SPARC program uses the engine. An example offload explained, the ready-made routines, the setup protocol, and a new program built step by step. |
| [APARA Validation Suite](apara/validation.md) | The engine suites and the system suites. What they contain, how to run them on both models, and how to add a test. |
| [APARA Deviations and Findings](apara/deviations.md) | The model's sources, where it deliberately departs from them, and the open questions (for the model's authors). |

## More

| Page | Description |
|---|---|
| [Development Notes](development_notes.md) | For contributors: repository layout, extending the core, adding tests. |
| [Authors](authors.md) | Who built this project, and credits for the adapted validation suite. |
| [License](license.md) | The MIT License this project is released under. |

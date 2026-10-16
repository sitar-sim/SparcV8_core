---
hide:
  - toc
---

# Navigation

## Introduction

| Page | Description |
|---|---|
| [Overview](index.md) | What this project is, the two models it provides, and how the repository is organized. |
| [Installation](installation.md) | Prerequisites and setup steps for building and running the models. |
| [Getting Started](getting_started.md) | A hands-on walkthrough: build both models, run a simple test, view the trace, and run the validation suite. |

## Writing and Running Programs

| Page | Description |
|---|---|
| [Assembly Programs](writing_and_running_assembly_programs.md) | How to write, assemble, and run your own assembly test programs. |
| [C Programs](writing_and_running_c_programs.md) | How to write, compile, and run freestanding C test programs. |
| [Validation Suite](validation_suite.md) | What's in a test, which suites run on which configuration, how to run them, and how to add a new test. |
| [Cross Compiler](cross_compiler.md) | The bundled `sparc-elf` toolchain used to assemble and compile test programs. |

## Logging and Monitoring

| Page | Description |
|---|---|
| [Logging](logging.md) | How instruction-trace logging works, compile-time and runtime, and the log viewer. |
| [Examining Core State with GDB](examining_core_state_with_gdb.md) | A beginner-facing walkthrough of debugging a running model with gdb. |
| [GDB Command Reference](gdb_command_reference.md) | The exhaustive reference for every `sparc-*` gdb command. |
| [Debug Support Internals](debug_support_internals.md) | How gdb support is actually built, for anyone extending `debug/sparc.gdb` itself. |

## The Model

| Page | Description |
|---|---|
| [SPARC V8 Architecture](sparcv8_architecture.md) | A page-indexed guide into the bundled SPARC V8 manual PDF. |
| [Model Configurations](model_configurations.md) | A block-diagram-level summary of each testbench configuration. |
| [Model Components](model_components.md) | Describes each component in detail: SparcCore, Mmu, Memory, Caches, Devices, the system bus, and the APARA engine. |
| [Peripheral Devices](peripheral_devices.md) | Overview, connection diagram, address map, and interrupt levels for the peripherals below. |
| [Timer](peripheral_devices_timer.md) | Register format, one-shot behavior, and state machine. |
| [Interrupt Controller](peripheral_devices_interrupt_controller.md) | The shared, multi-thread IRC: one slot per hardware thread, interrupt sources, priority, and inter-processor interrupts. |
| [Serial Device](peripheral_devices_serial_device.md) | UART register format, baud-rate calculation, and the Tx/Rx state machines. |
| [The APARA Engine](apara/index.md) | Overview of the APARA vector compute engine, and its two configurations. |
| [APARA Instruction Set](apara/isa.md) | The engine's state, data types, bundles, and every instruction. |
| [APARA Assembly Language and Tools](apara/assembly_and_tools.md) | mcode, the assembler and disassembler, and the file formats. |
| [Writing and Running APARA Programs](apara/running.md) | Running an engine program on its own, the engine's test suites, and how the pipeline handles hazards. |
| [The APARA C Compiler](apara/compiler.md) | `apcc.py`: the C subset, the intrinsics and inline mcode, and running linear algebra programs on the engine. |
| [APARA Timing Model](apara/timing_model.md) | The engine's five-stage pipeline in the Sitar model, and its timing rules and knobs. |
| [The Engine in a System](apara/system.md) | `sparc_apara`: how the SPARC and the engine are connected and communicate, the setup protocol, the control and DMA units, the C routines, and the tests. |
| [APARA Deviations and Findings](apara/deviations.md) | The model's sources, where it deliberately departs from them, and the open questions (for the model's authors). |
| [Model Components Reference](model_components_reference.md) | A complete, per-file table of every Sitar module/procedure. |
| [Model Configuration Settings](model_configuration_settings.md) | Every structural and timing setting in the model, where to set it, compile time or runtime. |
| [Performance Modeling](performance_modeling.md) | How to print the model's performance measures with `--stats`, and the table of what's reported. |

## More

| Page | Description |
|---|---|
| [Development Notes](development_notes.md) | For contributors: repository layout, extending the core, adding tests. |
| [Authors](authors.md) | Who built this project, and credits for the adapted validation suite. |
| [License](license.md) | The MIT License this project is released under. |

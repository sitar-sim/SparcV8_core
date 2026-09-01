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
| [Validation Suite](validation_suite.md) | What's in a test, how to run the suite, and how to add a new test. |
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
| [Model Configurations](model_configurations.md) | A block-diagram-level summary of each testbench configuration, current and planned. |
| [Model Components](model_components.md) | Describes each component in detail: SparcCore, Mmu, Memory, Caches, and Devices. |
| [Model Components Reference](model_components_reference.md) | A complete, per-file table of every Sitar module/procedure. |
| [Model Configuration Settings](model_configuration_settings.md) | Every structural and timing setting in the model, where to set it, compile time or runtime. |
| [Performance Modeling](performance_modeling.md) | How to print the model's performance measures with `--stats`, and the table of what's reported. |

## More

| Page | Description |
|---|---|
| [Development Notes](development_notes.md) | For contributors: repository layout, extending the core, adding tests. |
| [Authors](authors.md) | Who built this project, and credits for the adapted validation suite. |
| [License](license.md) | The MIT License this project is released under. |

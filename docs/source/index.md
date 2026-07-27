# Sitar model of a SPARC V8 core

This repository provides software **simulation models** of a
[SPARC V8](sparcv8_Architecture_reference_Manual.pdf) processor core.
SPARC V8 is a 32-bit RISC instruction set architecture, standardized as
ANSI/IEEE Std 1754-1994.

Two models of the core are provided.

1. **A C++ only functional model**  
    A fast, zero-latency instruction-set simulator of the core.

2. **A Sitar cycle-based timing model**  
    The same functional core, driven inside a cycle-based timing model
    built using the [Sitar](https://sitar-sim.github.io/sitar/) parallel simulation
    framework.

Both models provide only the processor core (no MMU/cache/devices). The
full executable testbenches provided here connect the cores to a simple
array-like byte addressable memory that allows a user to run programs.
These models are meant to be used as:

- Educational simulation models, to run programs on the core and observe their execution.  
    ...and, most importantly,  
- As a component in large-scale many-core/SoC cycle based simulation models.

## This repository also provides

1. **A bundled toolchain**  
    For compiling and running programs on the simulated models. See
    [Installation](installation.md).

2. **Extensive support for logging**  
    Along with a visualizer tool for stepping through an execution trace
    and viewing the processor state at each step. Logging can be disabled
    at compile time, for significantly faster long simulations. See
    [Logging](logging.md).

3. **Intuitive GDB-based runtime inspection of the processor state**  
    Independent of logging. See [Examining Core State at Runtime Using
    GDB](examining_core_state_with_gdb.md).

4. **A large number of assembly and C test programs**  
    Serving both as educational examples and as a validation suite for
    the processor. See "Validation Suite" below.

---

## What is Sitar?

[Sitar](https://sitar-sim.github.io/sitar/) is a framework for modeling and
parallel simulation of synchronous (clocked) discrete-event systems. It
combines a domain-specific modeling language with a lightweight C++
simulation kernel. It is the framework this project's timing model is
built with.

- Sitar documentation: [sitar-sim.github.io/sitar](https://sitar-sim.github.io/sitar/)
- Sitar repository: [github.com/sitar-sim/sitar](https://github.com/sitar-sim/sitar)

This project's own repository is a *model built using Sitar*, not part of
Sitar itself. If you're looking for the modeling language and simulation
kernel, follow the links above.

---

## What is SPARC V8?

SPARC (Scalable Processor ARChitecture) is a RISC instruction set
architecture originally developed at Sun Microsystems, derived from the
Berkeley RISC I/II research designs. SPARC V8 is the 32-bit revision of
this architecture, standardized as ANSI/IEEE Std 1754-1994. See the
[Wikipedia SPARC article](https://en.wikipedia.org/wiki/SPARC) for general
background and history.

SPARC's most distinctive architectural feature is a **register window**
file. A procedure call can get a fresh set of registers without spilling
to memory, simply by advancing a circular window into a larger physical
register file.

The authoritative specification for SPARC V8 is *The SPARC Architecture
Manual, Version 8*, included in this repository at
[`docs/source/sparcv8_Architecture_reference_Manual.pdf`](sparcv8_Architecture_reference_Manual.pdf).
This project's model follows it closely, with section references cited
throughout the source (`model/cpp_common_code/SparcCore.cpp` in
particular).

---

## Models

Both models described above are built on the same core implementation
(`model/cpp_common_code/`): an integer unit, a floating-point unit
(including quad-precision), register windows, and the full trap and
memory-access instruction set, with no notion of cycles, timing, or
pipelining of its own. The two models differ only in how they drive this
common code.

- **The C++ only functional model** lives in `model/cpp_model/`.
- **The Sitar cycle-based timing model** lives in `model/sitar_model/`.

Because both models drive the same underlying code, a bug fix or new
instruction in the core is automatically reflected in both.

See [Model Components](model_components.md) for how the core, the
memory, and any other components fit together, including a stub example
of connecting an external component such as a cache.

---

## Validation Suite

*(stub, more detail to come)*

A large number of assembly and C test programs validate both models,
adapted in large part from the AJIT processor project's own test suite.
See [Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
and [Writing and Running C Programs](writing_and_running_c_programs.md).

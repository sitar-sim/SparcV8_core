# Sitar model of a SPARC V8 core

This project is a [Sitar](https://sitar-sim.github.io/sitar/) model of a
**SPARC V8** processor core: a timing-agnostic C++ functional model of the
core, plus a simple cycle-driven timing model built on top of it using
Sitar, both validated against the same instruction-level test suite.

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

SPARC (**S**calable **P**rocessor **AR**Chitecture) is a RISC instruction-set
architecture originally developed at Sun Microsystems, derived from the
Berkeley RISC I/II research designs. Its most distinctive architectural
feature is a **register-window** file: procedure calls can get a fresh set
of registers without spilling to memory, by advancing a circular window
into a larger physical register file.

SPARC V8 is the 32-bit revision of the architecture. The authoritative
specification is *The SPARC Architecture Manual, Version 8*, included in
this repository at
[`docs/source/sparcv8_Architecture_reference_Manual.pdf`](sparcv8_Architecture_reference_Manual.pdf).
This project's model follows it closely, with section references cited
throughout the source (`model/cpp_common_code/SparcCore.cpp` in
particular). See also the
[Wikipedia SPARC article](https://en.wikipedia.org/wiki/SPARC) for general
background and history.

---

## What this project offers

A SPARC V8 **core** is modeled at two levels, both built on the same
timing-agnostic core implementation. The core includes an integer unit, a
floating-point unit (including quad-precision), register windows, and the
full trap and memory-access instruction set.

!!! tip "Two models, one core"
    Both models below drive the *same* `SparcCore` C++ class
    (`model/cpp_common_code/`), which implements SPARC V8 instruction
    semantics with no notion of cycles, timing, or pipelining of its own.
    The two models differ only in how they *drive* it. One applies no
    modeled delay at all. The other drives it through Sitar with a
    configurable, non-pipelined cycle-level timing model. This means a bug
    fix or new instruction in the core is automatically reflected in both.

1. **A plain C++ functional model** (`model/cpp_model/`). This is a
   fetch-decode-execute loop with zero modeled latency. It is fast and
   simple, has no Sitar dependency at all, and is useful for pure
   ISA-correctness testing.

2. **A Sitar-timed model** (`model/sitar_model/`). This drives the same
   core through Sitar with a **simple, non-pipelined cycle-level timing
   model**:
   a fixed, configurable per-opcode delay, plus separate, independently
   configurable latencies for the memory interconnect and the memory
   itself (so loads/stores/instruction-fetch can be given realistic,
   detailed timing without modeling a pipeline).

**This project models the core only.** There is no MMU, cache, or
peripheral/device model here. A full SoC-level model built around this
core, with those components, is planned as a separate repository or
version. This repository's own documentation does include one
illustrative example of connecting an external component (a cache) to the
core, as a pattern for anyone wanting to build a larger model around it.
See [Model Components](model_components.md#connecting-other-components)
for a stub of this (not yet a full worked example).

Both models are validated against the same instruction-level assembly test
suite, and against a planned suite of bare-metal C test programs. See
[Writing and Running Programs](writing_and_running_assembly_programs.md).

---

## Where to go next

- New to this project? Start with [Installation](installation.md) and
  [Getting Started](getting_started.md).
- Want to write your own test program? See
  [Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
  and [Writing and Running C Programs](writing_and_running_c_programs.md).
- Want to understand how the pieces fit together? See
  [Model Components](model_components.md).
- Want to change the timing model? See
  [Performance Modeling](performance_modeling.md).

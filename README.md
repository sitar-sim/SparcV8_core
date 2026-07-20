# SparcV8_core

A [Sitar](https://sitar-sim.github.io/sitar/) model of a SPARC V8 processor
core: a timing-agnostic C++ functional model, plus a simple cycle-driven
timing model built on top of it, both validated against a
[SPARC V8](https://en.wikipedia.org/wiki/SPARC) instruction-level test
suite.

## What is Sitar?

[Sitar](https://sitar-sim.github.io/sitar/) is a framework for modeling and
parallel simulation of synchronous (clocked) discrete-event systems -- a
domain-specific modeling language plus a lightweight C++ simulation kernel.
See the [Sitar documentation](https://sitar-sim.github.io/sitar/) and its
[repository](https://github.com/sitar-sim/sitar) for the framework itself;
this repository is one model built using it.

## What is SPARC V8?

SPARC (Scalable Processor ARChitecture) is a RISC instruction-set
architecture originally developed at Sun Microsystems, derived from the
Berkeley RISC I/II designs, and notable for its register-window
architecture. Version 8 (SPARC V8) is a 32-bit revision of the
architecture, specified in *The SPARC Architecture Manual, Version 8*
(included in this repository at
[`docs/sparcv8_Architecture_reference_Manual.pdf`](docs/sparcv8_Architecture_reference_Manual.pdf)).
See also the [Wikipedia SPARC article](https://en.wikipedia.org/wiki/SPARC)
for general background.

## What this repository offers

A SPARC V8 **core** -- integer unit, floating-point unit (including
quad-precision), register windows, traps, and the full memory-access
instruction set -- modeled at two levels:

1. **`model/cpp_common_code/`** -- `SparcCore`, a pure C++ functional model
   of the core: correct instruction semantics per the manual, with no
   notion of cycles, timing, or pipelining at all. Driven directly by
   **`model/cpp_model/`**'s `SparcStateMachine`, a plain fetch-decode-execute
   loop with zero modeled latency -- useful for fast functional testing.
2. **`model/sitar_model/`** -- the same `SparcCore`, driven instead through
   Sitar, with a simple (non-pipelined) cycle-level timing model: a fixed,
   configurable per-opcode delay, plus separately configurable
   interconnect and memory-service latencies for loads/stores/instruction
   fetch. See `model/sitar_model/README.md` for the three latency knobs.

**This repository models the core only** -- there is no MMU, cache, or
peripheral/device model here; those (and a full SoC-level model built
around this core) are planned for a separate repository/version. This
repository's own documentation does, however, include one illustrative
example of connecting an external component (a cache) to the core, to
demonstrate the pattern for anyone wanting to build a larger model around
it -- see "Connecting other components" in the documentation (a stub for
now; the worked example is planned).

Both models are validated against the same instruction-level test suite
(`validation/`, `validation/run_tests.py`, currently 230/230 passing on
both) -- see `validation/README.md`.

## Documentation

Full documentation -- installation, getting started, writing and running
your own assembly and C test programs (with logging on/off), an overview
of the model's components, and how to tune the timing model -- is built
with [MkDocs](https://www.mkdocs.org/) from the `docs/` folder. See
`docs/README` for how to build/preview it locally, or read the source
`.md` files directly under `docs/`.

For a quick start without building the docs site:

```sh
# build the plain C++ model and run the validation suite against it
model/cpp_model/build.sh
validation/run_tests.py validation/asm

# build the Sitar-timed model and run the same suite against it
# (requires the sitar CLI on PATH -- see the sitar repository above)
model/sitar_model/build.py
validation/run_tests.py validation/asm --sitar
```

## Repository layout

- `model/` -- the two models described above (`cpp_common_code/`,
  `cpp_model/`, `sitar_model/`), each with its own `README.md`.
- `validation/` -- the instruction-level test suite (`asm/`, hand-written
  assembly; `C/`, bare-metal C, not yet populated) and the scripts that
  build and run it.
- `compliance/` -- documented, specific divergences between this model's
  behavior and the AJIT project's own reference test results (see below).
- `compiler/` -- the SPARC V8 cross-toolchain (assembler/linker) used to
  build test programs, and the scripts that drive it.
- `docs/` -- the MkDocs documentation source.

## Acknowledgments

Most of the functional validation suite under `validation/asm/`
(and the toolchain scripts that build/run it under `compiler/`) is adapted
from the **AJIT processor project** (IIT Bombay) -- specifically its `ajit32`
instruction-level verification suite. See `validation/README.md` for
details, per-file author credit, and the quad-precision tests that are this
project's own (AJIT's own suite assumes quad ops are unimplemented; this
project implements them). `compliance/README.md` documents three specific,
well-understood divergences between AJIT's expected test results and this
model's (accrued-inexact FSR tracking, PSR impl/ver field writability, and
quad-precision support), intended to be shared with AJIT's authors.

## Authors and License

See [`AUTHORS`](AUTHORS) and [`LICENSE`](LICENSE). Released under the MIT
License.

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
[`docs/source/sparcv8_Architecture_reference_Manual.pdf`](docs/source/sparcv8_Architecture_reference_Manual.pdf)).
See also the [Wikipedia SPARC article](https://en.wikipedia.org/wiki/SPARC)
for general background.

## What this repository offers

A SPARC V8 **core** -- integer unit, floating-point unit (including
quad-precision), register windows, traps, and the full memory-access
instruction set -- modeled at two levels:

1. **`model/cpp_common_code/`** -- `SparcCore`, a pure C++ functional model
   of the core: correct instruction semantics per the manual, with no
   notion of cycles, timing, or pipelining at all. Driven directly by
   the same folder's `SparcStateMachine`, a plain fetch-decode-execute
   loop with zero modeled latency -- useful for fast functional testing.
   Each configuration's own `cpp_model` build lives under
   `model/system_models/<config>/cpp_model/`, e.g.
   `model/system_models/core_only/cpp_model/`.
2. **`model/sitar_component_models/`** -- the same `SparcCore`, driven
   instead through Sitar, with a simple (non-pipelined) cycle-level
   timing model: a fixed, configurable per-opcode delay, plus separately
   configurable interconnect and memory-service latencies for
   loads/stores/instruction fetch. Each configuration's own `sitar_model`
   build lives under `model/system_models/<config>/sitar_model/`; see
   `model/system_models/core_only/sitar_model/README.md` for the three
   latency knobs.

**This repository models the core only** -- there is no MMU, cache, or
peripheral/device model here; those (and a full SoC-level model built
around this core) are planned for a separate repository/version. This
repository's own documentation does, however, include one illustrative
example of connecting an external component (a cache) to the core, to
demonstrate the pattern for anyone wanting to build a larger model around
it -- see "Connecting other components" in the documentation (a stub for
now; the worked example is planned).

Both models are validated against the same instruction-level test suite
(`validation/`, `validation/run_tests.py`, currently 240/240 passing on
both) -- see `validation/README.md`.

## Documentation

Detailed documentation and examples are available here:
https://sitar-sim.github.io/SparcV8_core/

## Repository layout

- `model/` -- the two models described above (`cpp_common_code/`,
  `sitar_component_models/`), and `system_models/` (one folder per
  configuration, e.g. `system_models/core_only/`, each with its own
  `cpp_model/`/`sitar_model/` subfolders and `README.md`). See
  `model/README.md`.
- `validation/` -- the instruction-level test suite (`asm/`, hand-written
  assembly; `C/`, bare-metal C) and the scripts that build and run it.
- `compiler/` -- the SPARC V8 cross-toolchain (assembler/linker/objdump,
  plus a minimal bundled C compiler for `validation/C/`) used to build
  test programs, and the scripts that drive it.
- `log_viewer/` -- a self-contained, offline browser tool for viewing the
  instruction/state trace either model can produce (`--logging` builds --
  see `model/system_models/core_only/cpp_model/README.md`/
  `.../sitar_model/README.md`); see its own `README.md`.
- `docs/` -- the MkDocs documentation: `source/` (the `.md` pages),
  `generated_site/` (prebuilt, committed output -- open `index.html`
  directly), `mkdocs.yml`, the vendored `sitar_pygments_lexer/`, and
  `compliance/` (documented, specific divergences between this model's
  behavior and the AJIT project's own reference test results; see below).

## Acknowledgments

Most of the functional validation suite under `validation/asm/`
(and the toolchain scripts that build/run it under `compiler/`) is adapted
from the **AJIT processor project** (IIT Bombay) -- specifically its `ajit32`
instruction-level verification suite. See `validation/asm/README.md` for
details, per-file author credit, and the quad-precision tests that are this
project's own (AJIT's own suite assumes quad ops are unimplemented; this
project implements them). `docs/compliance/README.md` documents three specific,
well-understood divergences between AJIT's expected test results and this
model's (accrued-inexact FSR tracking, PSR impl/ver field writability, and
quad-precision support), intended to be shared with AJIT's authors.

## Authors and License

See [`AUTHORS`](AUTHORS) and [`LICENSE`](LICENSE). Released under the MIT
License.

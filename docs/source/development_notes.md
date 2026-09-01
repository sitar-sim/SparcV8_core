# Development Notes

This page is for contributors. It covers extending the core, adding
tests, or building on this model for a larger system.

---

## Repository layout

```
SparcV8_core/
  model/
    cpp_common_code/          SparcCore, the core, timing-agnostic. Shared by both drivers.
                                mmu/ holds the MMU's own MmuCore class.
    sitar_component_models/    The reusable Sitar procedures every configuration is built from.
    system_models/              One folder per configuration (core_only/, core_mmu/), each with
                                  its own cpp_model/ (0-delay driver) and sitar_model/
                                  (Sitar-timed driver) subfolders.
    build_scripts/               Shared build logic every configuration's own build.sh invokes.
  validation/
    asm/                Instruction-level assembly test suite.
    C/                  Self-validating bare-metal C mini-benchmark suite, including C/mmu/.
    test_simple_ADD/    Canonical copy of the bundled walkthrough example.
  compiler/               SPARC V8 cross-toolchain + build scripts.
  debug/                   gdb convenience commands (sparc.gdb) for runtime inspection.
  docs/                    This documentation site.
    source/                  The .md pages you're reading (MkDocs docs_dir).
    generated_site/           Prebuilt, committed output. See "Building the docs site" below.
    mkdocs.yml, requirements.txt, sitar_pygments_lexer/, sparc_pygments_lexer/  Build config,
      pinned dependencies, and vendored syntax lexers (Sitar, SPARC assembly).
    compliance/               Documented, specific divergences from AJIT's own reference results.
  log_viewer/              Offline browser tool for viewing an instruction/state trace.
```

Each of `model/cpp_common_code/`, `model/sitar_component_models/`, and
every `model/system_models/<config>/{cpp_model,sitar_model}/` has its own
`README.md` with a per-file breakdown. Start there for source-level
detail. See also [Model Components](model_components.md) for the
per-component picture, and [Model
Configurations](model_configurations.md) for how they're assembled
into each testbench.

---

## Building the docs site

`docs/requirements.txt` pins `mkdocs`, `mkdocs-material`, and this
project's own vendored Pygments lexers (Sitar and SPARC assembly
syntax highlighting). Set up a virtualenv once, from `docs/`:

```sh
python3 -m venv .venv
./.venv/bin/pip install -r requirements.txt
```

Then, from `docs/`:

```sh
./.venv/bin/mkdocs build    # regenerates generated_site/
./.venv/bin/mkdocs serve    # live preview at http://127.0.0.1:8000
```

`generated_site/` is committed, not gitignored. Rebuild and commit it
alongside any `source/` change, so it stays in sync.

---

## Where ISA semantics live

`SparcCore` (`model/cpp_common_code/SparcCore.cpp`) is the single source
of truth for instruction behavior, closely following the SPARC V8 manual
with section citations throughout. Both drivers call the same methods in
the same order. If you're fixing a semantics bug or adding an
instruction, it belongs here, not in either driver. The fix then applies
to both models automatically, and `validation/asm/` runs against both
(see [Getting Started](getting_started.md)) and will catch a regression
in either.

## Where timing lives

Timing is deliberately kept out of `cpp_common_code/` entirely.
`SparcThread.sitar` and its supporting files (`OpcodeLatencies.h`,
`VirtualMainMemoryInterface.sitar`, `VirtualMainMemory.sitar`, and,
where an MMU is present, `Mmu.sitar`, `PhysicalMainMemoryInterface.sitar`,
`PhysicalMainMemory.sitar`, and each configuration's own top-level
composition file, e.g. `System.sitar` in `core_mmu`) are the only place
cycle counts exist. See [Performance Modeling](performance_modeling.md).

## Linking against libquadmath

`FloatingPointFunctions.h` needs `libquadmath` for quad-precision support.
`sitar compile --cflags` only reaches the compile step (`CCFLAGS`), never
the link step, so linking an extra library needs `sitar compile`'s
separate `-l`/`--libs` option instead.
`model/build_scripts/build_sitar_model.py` builds with `-l quadmath`. If
you're writing your own build script against this model instead of using
it, do the same.

## Test-suite conventions

See [Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
for the full test-authoring format. A few conventions worth knowing if
you're reading existing tests rather than writing new ones:

- Every test always halts via `ta 0` with traps disabled, landing the
  core in `error_mode`. This is the deliberate, universal "done" signal
  described on that page, not a failure indicator by itself.

---

## Compatibility with the AJIT Processor

[AJIT](https://github.com/adhuliya/ajit-toolchain) is a SPARC V8
processor developed at IIT Bombay. The models in this project serve as
an approximate timing model of AJIT, for its design exploration and
software development.

Some components and validation tests are adapted directly from the
AJIT project, particularly the MMU, the devices, and the assembly
validation suite. The core model itself is developed independently.
There are several divergences between the two models and their tests.
These divergences are documented in detail in `docs/compliance/`.

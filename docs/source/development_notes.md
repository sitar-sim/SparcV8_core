# Development Notes

This page is for contributors. It covers extending the core, adding
tests, or building on this model for a larger system.

---

## Repository layout

```
SparcV8_core/
  model/
    cpp_common_code/          SparcCore, the core, timing-agnostic. Shared by both drivers.
    sitar_component_models/    The reusable Sitar procedures every configuration is built from.
    system_models/              One folder per configuration (e.g. core_only/), each with its
                                  own cpp_model/ (0-delay driver) and sitar_model/ (Sitar-timed
                                  driver) subfolders.
    build_scripts/               Shared build logic every configuration's own build.sh invokes.
  validation/
    asm/                Instruction-level assembly test suite.
    C/                  Self-validating bare-metal C mini-benchmark suite.
    test_simple_ADD/    Canonical copy of the bundled walkthrough example.
  compiler/               SPARC V8 cross-toolchain + build scripts.
  debug/                   gdb convenience commands (sparc.gdb) for runtime inspection.
  docs/                    This documentation site.
    source/                  The .md pages you're reading (MkDocs docs_dir).
    generated_site/           Prebuilt, committed output. Open index.html directly.
    mkdocs.yml, sitar_pygments_lexer/, sparc_pygments_lexer/  Build config
      and vendored syntax lexers (Sitar, SPARC assembly).
    compliance/               Documented, specific divergences from AJIT's own reference results.
  log_viewer/              Offline browser tool for viewing an instruction/state trace.
```

Each of `model/cpp_common_code/`, `model/sitar_component_models/`, and
every `model/system_models/<config>/{cpp_model,sitar_model}/` has its own
`README.md` with a per-file breakdown. Start there for source-level
detail. See also [Model Components](model_components.md) for the
higher-level picture.

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
- `docs/compliance/` exists specifically so that a documented, understood
  divergence from an external reference (AJIT, in this project's case)
  doesn't get silently "fixed" by editing the test to match a reference
  that's actually wrong. See `docs/compliance/README.md` for worked
  examples of this reasoning. The same pattern is worth following for any
  future external reference comparison.

## Reporting issues

This project doesn't yet have a formal issue tracker convention. For
now, `TODO.md` at the repo root is the single place project status and
open items are tracked.

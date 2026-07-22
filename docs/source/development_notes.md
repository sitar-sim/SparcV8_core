# Development Notes

This page is for contributors -- extending the core, adding tests, or
building on this model for a larger system.

---

## Repository layout

```
SparcV8_core/
  model/
    cpp_common_code/   SparcCore -- the core, timing-agnostic. Shared by both drivers.
    cpp_model/          0-delay C++ driver, no Sitar dependency.
    sitar_model/         Sitar-timed driver.
  validation/
    asm/                Instruction-level assembly test suite.
    C/                  Bare-metal C test suite (planned, not yet populated).
  compiler/               SPARC V8 cross-toolchain + build scripts.
  docs/                    This documentation site.
    source/                  The .md pages you're reading (MkDocs docs_dir).
    generated_site/           Prebuilt, committed output -- open index.html directly.
    mkdocs.yml, sitar_pygments_lexer/  Build config and vendored syntax lexer.
    compliance/               Documented, specific divergences from AJIT's own reference results.
```

Each of `model/cpp_common_code/`, `model/cpp_model/`, and
`model/sitar_model/` has its own `README.md` with a per-file breakdown --
start there for source-level detail. See also
[Model Components](model_components.md) for the higher-level picture.

---

## Where ISA semantics live

`SparcCore` (`model/cpp_common_code/SparcCore.cpp`) is the single source
of truth for instruction behavior, closely following the SPARC V8 manual
with section citations throughout -- both drivers call the same methods
in the same order. If you're fixing a semantics bug or adding an
instruction, it belongs here, not in either driver; the fix then applies
to both models automatically, and `validation/asm/` (run against both --
see [Getting Started](getting_started.md)) will catch a regression in
either.

## Where timing lives

Deliberately kept out of `cpp_common_code/` entirely -- `SparcThread.sitar`
and its supporting files (`OpcodeLatencies.h`, `MemoryInterface.sitar`,
`MainMemory.sitar`) are the only place cycle counts exist. See
[Performance Modeling](performance_modeling.md).

## A known Sitar CLI wrinkle

`sitar compile --cflags` currently only reaches the compile step
(`CCFLAGS`), not the link step (`LIBS`/`LINKFLAGS`) -- filed in the
separate `sitar` repository's own `TODO.md`, not yet fixed there.
`model/sitar_model/build.py` works around this by letting the `sitar
compile` link step fail as expected, then manually re-invoking `g++` with
`-lquadmath` appended (needed for `FloatingPointFunctions.h`'s quad-
precision support). If you're writing your own build script against this
model instead of using `build.py`, you'll hit the same issue.

## Test-suite conventions

See [Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
for the full test-authoring format. A few conventions worth knowing if
you're reading existing tests rather than writing new ones:

- Every test always halts via `ta 0` with traps disabled, landing the
  core in `error_mode` -- this is the deliberate, universal "done" signal
  described on that page, not a failure indicator by itself.
- `docs/compliance/` exists specifically so that a documented, understood
  divergence from an external reference (AJIT, in this project's case)
  doesn't get silently "fixed" by editing the test to match a reference
  that's actually wrong -- see `docs/compliance/README.md` for three worked
  examples of this reasoning. The same pattern is worth following for any
  future external reference comparison.

## Reporting issues

This project doesn't yet have a formal issue tracker convention -- for
now, `TODO.md` at the repo root is the single place project status and
open items are tracked.

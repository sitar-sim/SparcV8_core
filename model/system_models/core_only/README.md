# system_models/core_only/

The SPARC V8 core on its own: no MMU, no cache, no peripherals. This is
the existing model, unchanged in behavior, just reorganized to fit the
same layout every later configuration (core and MMU, core and MMU and
devices, and so on) will follow.

Two subfolders, one per driver:

- **`cpp_model/`** -- the 0-delay functional driver (`SparcStateMachine`,
  from `../../cpp_common_code/`, driving memory directly through a plain
  `MemCore`). Fast, no timing, useful for checking ISA-level correctness.
  See `cpp_model/README.md`.
- **`sitar_model/`** -- the Sitar-timed driver, built from
  `../../sitar_component_models/`'s reusable procedures plus this
  configuration's own `Top.sitar`/`Core.sitar` composition. See
  `sitar_model/README.md`.

Both are validated against the same instruction-level test suite (see
`../../../validation/README.md`); either can run it via
`validation/run_tests.py` (`--sitar` for this one).

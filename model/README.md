# model/

Three top-level folders, mirroring a parts library plus the specific
systems assembled from it (see `../Plan_SoC_Integration_Roadmap.md`'s
"Model code organization" section for the full rationale):

- **`cpp_common_code/`** -- the reusable, timing-agnostic implementation:
  `SparcCore` (the SPARC V8 core itself) and `SparcStateMachine` (the
  reusable 0-delay fetch-decode-execute driver every `cpp_model`
  configuration uses), plus their shared support code (`MemCore`,
  `Decoder`, `Registers`, ...). See `cpp_common_code/README.md`.
- **`sitar_component_models/`** -- the reusable Sitar procedures every
  `sitar_model` configuration is built from (`SparcThread.sitar`,
  `MemoryInterface.sitar`, `MainMemory.sitar` today), plus
  `cpp_code/` for sitar-only C++ glue (`MemAccessInterface.h`,
  `OpcodeLatencies.h`).
- **`system_models/`** -- one folder per assembled configuration, e.g.
  `system_models/core_only/`, each holding `cpp_model/` and
  `sitar_model/` subfolders: that configuration's own composition
  (`Top.sitar`/`Core.sitar` for the timed model, an entry point for the
  0-delay one), any per-configuration glue code, build scripts, and a
  bundled smoke test. See each configuration's own `README.md`.

`build_scripts/build_cpp_model.sh` and `build_scripts/build_sitar_model.py`
are the shared build logic every configuration's own thin `build.sh`
wrapper invokes -- see `system_models/core_only/cpp_model/build.sh` for
the pattern.

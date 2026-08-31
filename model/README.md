# model/

Three top-level folders, mirroring a parts library plus the specific
systems assembled from it (see `../Plan_SoC_Integration_Roadmap.md`'s
"Model code organization" section for the full rationale):

- **`cpp_common_code/`** -- the reusable, timing-agnostic implementation:
  `SparcCore` (the SPARC V8 core itself) and `SparcStateMachine` (the
  reusable 0-delay fetch-decode-execute driver every `cpp_model`
  configuration uses), plus their shared support code (`MemCore`,
  `Decoder`, `Registers`, ...). See `cpp_common_code/README.md`.
- **`sitar_component_models/`** -- the reusable Sitar procedures and
  modules every `sitar_model` configuration is built from
  (`SparcThread.sitar`, `VirtualMainMemoryInterface.sitar`,
  `VirtualMainMemory.sitar` always; where an MMU is present, also
  `Mmu.sitar`, `PhysicalMainMemoryInterface.sitar`, and the module
  `PhysicalMainMemory.sitar`; `PullAToken.sitar`/`PushAToken.sitar`, two
  generic single-token I/O procedures used by anything talking to a
  module over nets), plus `cpp_code/` for sitar-only C++ glue
  (`OpcodeLatencies.h`). See `../docs/source/model_components_reference.md`
  for the full per-file table.
- **`system_models/`** -- one folder per assembled configuration, e.g.
  `system_models/core_only/`, each holding `cpp_model/` and
  `sitar_model/` subfolders: that configuration's own composition
  (`Top.sitar` plus one or more further module files for the timed
  model, an entry point for the 0-delay one), any per-configuration glue
  code, build scripts, and a bundled smoke test. See each
  configuration's own `README.md`, and `../docs/source/model_configurations.md`
  for a block diagram of each one.

`build_scripts/build_cpp_model.sh` and `build_scripts/build_sitar_model.py`
are the shared build logic every configuration's own thin `build.sh`
wrapper invokes -- see `system_models/core_only/cpp_model/build.sh` for
the pattern.

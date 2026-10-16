# validation/

The validation suites. The SPARC suites check functional correctness
only (no SPARC timing/pipeline tests); the APARA engine's own suites,
`apara/`, also check the engine's timing model.

## What's here

- `asm/` -- hand-written, opcode-level assembly tests. See `asm/README.md`.
- `C/` -- bare-metal C tests. See `C/README.md`. Besides the
  benchmarks, it holds one folder per component suite: `mmu/`,
  `devices/`, `caches/`, each needing a configuration that has that
  component.
- `sparc_apara/` -- C programs for the SPARC that use an APARA engine:
  setup, threads, interference, linear algebra (the `sparc_apara`
  configuration). See `sparc_apara/README.md`.
- `apara/` -- the APARA engine's own tests (mcode and C programs,
  functional and timing, hazards, the branch predictor), on the
  standalone `apara` configuration, with their own runner,
  `apara/run_tests.py`. See `apara/README.md`.
- `test_simple_ADD/` -- one more `.vprj` test, but its main job is as
  the small example program used throughout the docs and both models'
  own `run_simple_test.sh` scripts
  (`model/system_models/core_only/cpp_model/`,
  `model/system_models/core_only/sitar_model/`), which read it from here
  directly rather than keeping their own duplicate `.s`/`.hex`/`.objdump`.
  Its two reference traces (`test_simple_ADD.cpp_model.log`,
  `test_simple_ADD.sitar_model.log`) run the other way: each is a
  symlink back to `test_simple_ADD.log` in the model folder that
  actually produces it (a trace file is always named after the hex file
  it ran, see `../docs/source/logging.md`), so building and running the
  example there keeps the tracked trace here up to date directly,
  nothing to manually copy. `log_viewer/test_simple_ADD.log` symlinks to
  the cpp one, for the log viewer's own demo (same name throughout, not
  a differently-named copy).

Every SPARC test is a `<TEST>.<s|c>` + `<TEST>.vprj` pair. `.vprj`
lists the expected final state as `REG`/`MEM` checks. (The APARA
engine's tests have their own `.vprj` format, Ref `apara/apara_vprj.py`.)

## Which suites run on which configuration

A suite folder's `REQUIRES` file lists what its tests need (`sparc`,
`mmu`, `devices`, `caches`, `apara`, or `apara_standalone` for the
engine's own suites); requirements add up down the tree. Each
configuration lists what it has in its `COMPONENTS` file
(`../model/system_models/<config>/COMPONENTS`). `run_tests.py --config
<config>` runs the tests whose requirements the configuration meets, and
lists the folders it skipped, so the whole tree can be run against any
configuration:

```bash
python3 validation/run_tests.py validation --config core_only     # asm/, C/ benchmarks
python3 validation/run_tests.py validation --config sparc_apara   # everything but apara/
python3 validation/apara/run_tests.py                             # apara/, on the apara configuration
```

A new configuration needs only its `COMPONENTS` file; a new suite, a
`REQUIRES` file if it needs more than the SPARC core.

## Scripts

Roughly in the order you'd use them:

1. `source ../compiler/toolchain_env.sh` -- puts the sparc-elf toolchain on
   `PATH` (needed for step 2, and to build a model). See
   `../compiler/README.md`.
2. `build_hex.py <root_folder>` -- assembles/compiles each test's `.s`/`.c`
   source into a `.hex` memory image. Needs the toolchain. Only needed if
   you've added or edited a test; `.hex` files are committed to git, so
   this step isn't needed just to run the existing suite.
3. `../model/system_models/core_only/cpp_model/build.sh` or
   `../model/system_models/core_only/sitar_model/build.sh` -- build the
   checker binary to run tests against (not a script in this directory,
   listed here since it's the next step).
4. `run_tests.py <root_folder> [--config NAME] [--sitar] [--max-cycles N] [-v]`
   -- runs each test's `.hex` against the checker and reports PASS/FAIL.
   `--config` picks the configuration (default `core_only`), and the
   tests it cannot run are skipped (above). Doesn't need the toolchain.
5. `clean.sh [root_folder]` -- removes generated build byproducts (`.o`,
   `.elf`, `.expected`). Leaves `.hex`/`.s`/`.c`/`.vprj`/`.objdump` alone.

`vprj.py` is a shared `.vprj`-parsing module used by `build_hex.py` and
`run_tests.py`, not something you run directly.

---

Credit: some validation scripts and tests are from the AJIT project, IIT
Bombay. See `AUTHORS` in the repo root.

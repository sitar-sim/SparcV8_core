# validation/

Functional validation suite for the SPARC V8 core model. No timing/pipeline
tests here, functional correctness only.

## What's here

- `asm/` -- hand-written, opcode-level assembly tests. See `asm/README.md`.
- `C/` -- bare-metal C tests. See `C/README.md`.
- `test_simple_ADD/` -- one more `.vprj` test, but its main job is as
  the small example program used throughout the docs and both models'
  own bundled walkthroughs (`model/cpp_model/test/`,
  `model/sitar_model/executable/`), which symlink to it rather than
  keeping their own duplicate `.s`/`.hex`/`.expected`/`.objdump`. Its two
  reference traces (`test_simple_ADD.cpp_model.log`,
  `test_simple_ADD.sitar_model.log`) run the other way: each is a
  symlink back to `test_simple_ADD.log` in the model folder that
  actually produces it (a trace file is always named after the hex file
  it ran, see `../docs/source/logging.md`), so building and running the
  example there keeps the tracked trace here up to date directly,
  nothing to manually copy. `log_viewer/test_simple_ADD.log` symlinks to
  the cpp one, for the log viewer's own demo (same name throughout, not
  a differently-named copy).

Every test in `asm/`/`C/` is a `<TEST>.<s|c>` + `<TEST>.vprj` pair.
`.vprj` lists the expected final state as `REG`/`MEM` checks.

## Scripts

Roughly in the order you'd use them:

1. `source ../compiler/toolchain_env.sh` -- puts the sparc-elf toolchain on
   `PATH` (needed for step 2, and to build a model). See
   `../compiler/README.md`.
2. `build_hex.py <root_folder>` -- assembles/compiles each test's `.s`/`.c`
   source into a `.hex` memory image. Needs the toolchain. Only needed if
   you've added or edited a test; `.hex` files are committed to git, so
   this step isn't needed just to run the existing suite.
3. `../model/cpp_model/build.sh` or `../model/sitar_model/build.py` --
   build the checker binary to run tests against (not a script in this
   directory, listed here since it's the next step).
4. `run_tests.py <root_folder> [--sitar] [--max-cycles N] [-v]` -- runs
   each test's `.hex` against the checker and reports PASS/FAIL. Doesn't
   need the toolchain.
5. `clean.sh [root_folder]` -- removes generated build byproducts (`.o`,
   `.elf`, `.expected`). Leaves `.hex`/`.s`/`.c`/`.vprj`/`.objdump` alone.

`vprj.py` is a shared `.vprj`-parsing module used by `build_hex.py` and
`run_tests.py`, not something you run directly.

---

Credit: some validation scripts and tests are from the AJIT project, IIT
Bombay. See `AUTHORS` in the repo root.

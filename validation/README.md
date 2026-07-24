# validation/

Functional validation suite for the SPARC V8 core model. No timing/pipeline
tests here, functional correctness only.

## What's here

- `asm/` -- hand-written, opcode-level assembly tests. See `asm/README.md`.
- `C/` -- bare-metal C tests. See `C/README.md`.

Every test is a `<TEST>.<s|c>` + `<TEST>.vprj` pair. `.vprj` lists the
expected final state as `REG`/`MEM` checks.

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

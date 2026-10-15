# validation/apara/

The APARA engine's tests, and their runner.

- **`tests/`** -- one test per instruction class, threads, bundle
  semantics; `dev_*.mcode` test the model's deviations from the APARA
  reference model.
- **`timing/`** -- microbenchmarks for the timing model, each with its
  cycle count derived by hand in its header.
- **`run_tests.py`** -- assembles and runs them: `python3 run_tests.py
  [paths] [--sitar] [--reference --mcode-run <mcode_run>]`.
- **`build/`** -- gitignored: each test's generated object, data,
  register and results files.

Each test is one mcode file with `//@` lines saying how to run it and
what to expect. See [Writing and Running APARA
Programs](https://sitar-sim.github.io/SparcV8_core/apara/running.html).

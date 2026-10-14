# apara/cpp_model/

The functional model of a standalone APARA engine: `AparaCore`
(`../../../cpp_common_code/apara/`) run bundle by bundle, its threads in
round-robin order.

## What's what

- **`src/apara_sim.cpp`** -- the entry point (command line, files and
  report shared with the sitar_model: `AparaRun.h`).
- **`build.sh`** -- thin wrapper around the shared
  `../../../build_scripts/build_cpp_model.sh`.
- **`executable/`** -- gitignored build output.

## How to run it

```sh
./build.sh
python3 ../../../../compiler/apara/apara_as.py prog.mcode
./executable/apara_sim_cpp -p 0x0 -i prog.obj [-d data.map] [-a registers.txt] \
        [-r results.txt] [--dump-results file] [--trace] [--stats] [--max-bundles n]
```

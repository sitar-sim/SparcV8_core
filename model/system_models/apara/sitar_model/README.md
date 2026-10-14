# apara/sitar_model/

The timing model of a standalone APARA engine: `Top` holds one
`AparaEngine` (`../../../sitar_component_models/AparaEngine.sitar`), the
engine's five-stage pipeline, one module per stage. The functional state
is the same `AparaCore` the cpp_model runs, inside the EXEC stage.

## What's what

- **`src/Top.sitar`** -- the top module, and the one place for the
  timing knobs.
- **`src/apara_sim.cpp`** -- the entry point.
- **`build.sh`** -- thin wrapper around the shared
  `../../../build_scripts/build_sitar_model.py` (needs the `sitar` CLI).
- **`executable/`**, **`build/`** -- gitignored build output.

## How to run it

```sh
./build.sh
./executable/apara_sim_sitar -p 0x0 -i prog.obj [-d data.map] [-a registers.txt] \
        [-r results.txt] [--stats] [--max-cycles n] [--latency-file file]
```

It prints the cycles the run took. See the documentation's "APARA Timing
Model" page for the pipeline, its timing rules and knobs.

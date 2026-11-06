# validation/multicore/openmp/

Tests of the OpenMP runtime, `compiler/sparc_common_routines/omp.h`, through real pragmas. Each
one is a self-checking program. Core 0 reports `%o0` = 1 and one bit per check in `%o1`, and each
worker halts with `%o0` = 1. The "OpenMP Programs" page of the documentation explains the runtime,
and the "Validation Suite" page lists what each test checks.

```sh
validation/build_hex.py validation/multicore/openmp
validation/run_tests.py validation/multicore/openmp --config multicore
validation/run_tests.py validation/multicore/openmp --config multicore --sitar
SPARC_ALWAYS_CACHEABLE=1 validation/run_tests.py validation/multicore/openmp --config multicore --sitar
```

Every test sets `RUN_OPTIONS = --coherent`, since OpenMP's threads expect to share memory, and
`COMPILE_OPTIONS = -fopenmp`.

The tests that fit on a host also build with its own compiler and OpenMP. `check_on_host.py` runs
them with four threads and compares their results with the `.vprj` files, so that a test holds
the simulators to what a real OpenMP implementation does.

```sh
python3 validation/multicore/openmp/check_on_host.py
```

It skips tests that depend on this system, which are those not using `openmp_common.h`, those using
`multicore_platform.h`, and those running with `--run-cores`.

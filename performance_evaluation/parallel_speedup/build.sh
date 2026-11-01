#!/bin/bash
# Builds the parallel speedup demo (executable/speedup_sim_openmp) with
# the shared sitar_model build script. The demo's own Top.sitar holds 16
# copies of the multicore configuration's System, so that
# configuration's System.sitar and Core.sitar are added to the build
# with --extra-sitar. Always built with OpenMP. Extra options (e.g.
# --logging) are passed on to the build script.
# Requires the `sitar` CLI on PATH (see the separate sitar repo).
HERE="$(cd "$(dirname "$0")" && pwd)"
MULTICORE="$HERE/../../model/system_models/multicore/sitar_model/src"
MAIN_FILE=speedup_sim.cpp EXECUTABLE_BASENAME=speedup_sim \
exec python3 "$HERE/../../model/build_scripts/build_sitar_model.py" "$HERE" --openmp \
	--extra-sitar "$MULTICORE/System.sitar" --extra-sitar "$MULTICORE/Core.sitar" "$@"

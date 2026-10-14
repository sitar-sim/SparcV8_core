#!/bin/bash
# Thin wrapper: builds this configuration (apara, a standalone APARA
# engine with its timing model) via the shared sitar_model build script.
# See model/build_scripts/build_sitar_model.py for the build logic and
# flags. Requires the `sitar` CLI on PATH (see the separate sitar repo).
MAIN_FILE=apara_sim.cpp EXECUTABLE_BASENAME=apara_sim_sitar \
	exec python3 "$(dirname "$0")/../../../build_scripts/build_sitar_model.py" "$(dirname "$0")" "$@"

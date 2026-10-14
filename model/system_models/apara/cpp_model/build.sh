#!/bin/bash
# Thin wrapper: builds this configuration (apara, a standalone APARA
# engine) via the shared cpp_model build script. See
# model/build_scripts/build_cpp_model.sh for the build logic and flags.
EXECUTABLE_BASENAME=apara_sim_cpp exec "$(dirname "$0")/../../../build_scripts/build_cpp_model.sh" "$(dirname "$0")" "$@"

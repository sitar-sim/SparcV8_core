#!/bin/bash
# Thin wrapper: builds this configuration (core_l1cache_mmu_devices) via the shared
# cpp_model build script. See model/build_scripts/build_cpp_model.sh for
# the actual build logic and flags (--logging, --debug, --debug-o0).
exec "$(dirname "$0")/../../../build_scripts/build_cpp_model.sh" "$(dirname "$0")" "$@"

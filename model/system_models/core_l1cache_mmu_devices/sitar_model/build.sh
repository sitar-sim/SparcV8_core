#!/bin/bash
# Thin wrapper: builds this configuration (core_mmu) via the shared
# sitar_model build script. See model/build_scripts/build_sitar_model.py
# for the actual build logic and flags (--logging, --debug, --debug-o0).
# Requires the `sitar` CLI on PATH (see the separate sitar repo).
exec python3 "$(dirname "$0")/../../../build_scripts/build_sitar_model.py" "$(dirname "$0")" "$@"

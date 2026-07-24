#!/bin/bash
# clean.sh [root_folder]
#
# Removes generated temp files under root_folder (default: this script's
# own directory, i.e. validation/) that build_hex.py/run_tests.py produce
# as byproducts: assembler/linker intermediates (.o, .elf) and the
# normalized expected-results file (.expected), plus any stray Python
# bytecode cache.
#
# Deliberately does NOT remove .hex files -- those are committed to git
# (see validation/README.md) specifically so the test suite can be run
# without a cross-compiler installed; only .s/.c/.vprj changes should
# require regenerating them, via build_hex.py. Also deliberately does NOT
# remove C/'s compiler-generated .s or .objdump (see compiler/compile_c.sh)
# -- unlike a .o/.elf, both are human-readable and committed on purpose, so
# someone can step through a small C test's actual generated code without
# needing the toolchain installed.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$SCRIPT_DIR}"

find "$ROOT" -type f \( -name '*.o' -o -name '*.elf' -o -name '*.expected' \) -print -delete
find "$ROOT" -type d -name '__pycache__' -print -exec rm -rf {} +

echo "Cleaned generated temp files under $ROOT (.hex/.s/.c/.vprj/.objdump left untouched)."

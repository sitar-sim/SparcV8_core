#!/bin/bash
# Runs this configuration's default build (no --logging/--debug) against
# the bundled test_simple_ADD example (validation/test_simple_ADD/, the
# canonical copy, not a local one). Build first with ./build.sh.
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="$DIR/../../../../validation/test_simple_ADD"
EXE="$DIR/executable/sparc_sim_sitar_core_only"
if [ ! -x "$EXE" ]; then
	echo "error: $EXE not found -- run ./build.sh first"
	exit 1
fi
"$EXE" "$TEST_DIR/test_simple_ADD.hex" "$TEST_DIR/test_simple_ADD.expected" --stats

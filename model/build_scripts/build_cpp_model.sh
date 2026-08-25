#!/bin/bash
# build_cpp_model.sh <config_folder> [--logging|--no-logging] [--debug|--debug-o0|--no-debug]
#
# Shared build logic for every cpp_model configuration under
# model/system_models/*/cpp_model/. Takes the path to that configuration's
# own cpp_model/ folder and builds entirely relative to it: compiles
# cpp_common_code/*.cpp (always, every configuration needs the same
# architectural core) plus whatever *.cpp files exist in <config_folder>/src/
# (that configuration's own entry point and any per-configuration glue),
# and writes the executable into <config_folder>/executable/.
#
# No configuration is named or special-cased here -- a new configuration
# folder needs no change to this script, only its own src/ files and a
# one-line build.sh wrapper (see model/system_models/core_only/cpp_model/build.sh
# for the pattern).
#
# The executable name is derived from <config_folder>'s own parent
# directory name (the configuration's name), e.g. sparc_sim_cpp_core_only,
# with variant suffixes appended for --logging/--debug so multiple builds
# can coexist in the same executable/ folder.
#
# --logging / --no-logging (default: --no-logging): whether the built
# binary is compiled with the per-cycle instruction/state trace
# (SparcCore::logger, a CoreLogger -- see cpp_common_code/CoreLogger.h).
# Compile-time choice, via -DSPARC_LOGGING_ENABLED.
#
# --debug / --no-debug (default: --no-debug): adds -g and
# -DSPARC_DEBUG_HOOKS_ENABLED (real, noinline debug_hook_*() functions --
# see cpp_common_code/DebugHooks.h). Stays at -O3; the handful of functions
# meant to be called live from gdb are individually pinned to -O0 at their
# own definitions.
#
# --debug-o0: like --debug, but the whole binary at -O0, for debugging
# something that isn't one of the pinned functions above.
#
# --logging and --debug are independent -- any combination is valid.

set -e

if [ -z "$1" ]; then
	echo "Usage: $0 <config_folder> [--logging|--no-logging] [--debug|--debug-o0|--no-debug]"
	exit 1
fi
CONFIG_DIR="$(cd "$1" && pwd)"
shift

LOGGING=0
DEBUG=0
DEBUG_O0=0
for arg in "$@"; do
	case "$arg" in
		--logging)    LOGGING=1 ;;
		--no-logging) LOGGING=0 ;;
		--debug)      DEBUG=1; DEBUG_O0=0 ;;
		--debug-o0)   DEBUG=1; DEBUG_O0=1 ;;
		--no-debug)   DEBUG=0; DEBUG_O0=0 ;;
		*) echo "Usage: $0 <config_folder> [--logging|--no-logging] [--debug|--debug-o0|--no-debug]"; exit 1 ;;
	esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPP_COMMON_CODE_DIR="$SCRIPT_DIR/../cpp_common_code"
SRC_DIR="$CONFIG_DIR/src"
EXECUTABLE_DIR="$CONFIG_DIR/executable"
# CONFIG_DIR is .../system_models/<config_name>/cpp_model -- the
# configuration's own name is its grandparent's basename, not
# CONFIG_DIR's own ("cpp_model" for every configuration alike).
CONFIG_NAME="$(basename "$(dirname "$CONFIG_DIR")")"

mkdir -p "$EXECUTABLE_DIR"

if [ "$DEBUG" = "1" ]; then
	if [ "$DEBUG_O0" = "1" ]; then
		CXXFLAGS="-std=c++11 -Wall -O0 -g -DSPARC_DEBUG_HOOKS_ENABLED -I$CPP_COMMON_CODE_DIR"
	else
		CXXFLAGS="-std=c++11 -Wall -O3 -g -DSPARC_DEBUG_HOOKS_ENABLED -I$CPP_COMMON_CODE_DIR"
	fi
else
	CXXFLAGS="-std=c++11 -Wall -O2 -I$CPP_COMMON_CODE_DIR"
fi
if [ "$LOGGING" = "1" ]; then
	CXXFLAGS="$CXXFLAGS -DSPARC_LOGGING_ENABLED"
fi

# See model/cpp_common_code's own build history for why these are silenced
# here rather than in the source: benign warnings (unused decoded fields on
# some code paths, an unimplemented-but-standard #pragma), not signs of a
# real bug.
CXXFLAGS="$CXXFLAGS -Wno-unused-variable -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unknown-pragmas"

CPP_COMMON_CODE_SOURCES="$CPP_COMMON_CODE_DIR"/*.cpp
CONFIG_SOURCES="$SRC_DIR"/*.cpp

EXECUTABLE_NAME="sparc_sim_cpp_${CONFIG_NAME}"
[ "$LOGGING" = "1" ] && EXECUTABLE_NAME="${EXECUTABLE_NAME}_logging"
[ "$DEBUG" = "1" ] && EXECUTABLE_NAME="${EXECUTABLE_NAME}_debug"
[ "$DEBUG_O0" = "1" ] && EXECUTABLE_NAME="${EXECUTABLE_NAME}o0"

g++ $CXXFLAGS $CONFIG_SOURCES $CPP_COMMON_CODE_SOURCES \
	-lquadmath -o "$EXECUTABLE_DIR/$EXECUTABLE_NAME"
echo "Built $EXECUTABLE_DIR/$EXECUTABLE_NAME"

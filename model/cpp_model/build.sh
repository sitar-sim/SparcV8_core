#!/bin/bash
# build.sh
#
# Builds sparc_sim_cpp, the standalone functional model of the SPARC V8
# core: runs a memory image, and either just prints the final register
# state, or -- if given an expected-results file -- checks it and prints
# a PASS/FAIL verdict (see sparc_sim.cpp).
#
# This links against libquadmath, needed by cpp_common_code/FloatingPointFunctions.h
# for quad-precision (128-bit) floating point support (FSQRTq and friends).
#
# --logging / --no-logging (default: --no-logging): whether sparc_sim_cpp
# is built with the per-cycle instruction/state trace (SparcCore::logger,
# a CoreLogger -- see cpp_common_code/CoreLogger.h). This is a compile-time
# choice, via -DSPARC_LOGGING_ENABLED: a --no-logging build's CoreLogger
# methods are all trivial stubs, none of the real formatting code exists
# in the binary. See CoreLogger.cpp and sparc_sim.cpp.
#
# --debug / --no-debug (default: --no-debug): whether the build is meant to
# be examined under a debugger (gdb -- see
# docs/source/examining_core_state_with_gdb.md -- but nothing here is
# actually gdb-specific) -- adds -g (debug symbols) and
# -DSPARC_DEBUG_HOOKS_ENABLED (real, noinline debug_hook_*() functions
# instead of empty stubs -- see cpp_common_code/DebugHooks.h). Stays at -O3
# (not -O2, not -O0): a debugger's `call`/`print` of a live function is
# generally unreliable against optimized code, but the handful of functions
# actually meant to be called this way (Registers::R_r(),
# CoreLogger::print_state()) are individually pinned to -O0 via
# __attribute__((optimize("O0"))) at their own definitions, so the rest of
# the simulator stays fast without needing the whole binary de-optimized.
#
# --debug-o0: like --debug, but the whole binary at -O0 -- for debugging
# something that isn't one of the hook points or pinned functions above
# (arbitrary breakpoints/single-stepping/local-variable inspection
# elsewhere), where the debugger needs reliable, unoptimized code
# throughout. Slower; only worth it for that kind of deep-dive.
# --logging and --debug are independent -- any combination is valid.

set -e

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
		*) echo "Usage: $0 [--logging|--no-logging] [--debug|--debug-o0|--no-debug]"; exit 1 ;;
	esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPP_CODE_DIR="$SCRIPT_DIR/../cpp_common_code"

if [ "$DEBUG" = "1" ]; then
	if [ "$DEBUG_O0" = "1" ]; then
		CXXFLAGS="-std=c++11 -Wall -O0 -g -DSPARC_DEBUG_HOOKS_ENABLED -I$CPP_CODE_DIR"
	else
		CXXFLAGS="-std=c++11 -Wall -O3 -g -DSPARC_DEBUG_HOOKS_ENABLED -I$CPP_CODE_DIR"
	fi
else
	CXXFLAGS="-std=c++11 -Wall -O2 -I$CPP_CODE_DIR"
fi
if [ "$LOGGING" = "1" ]; then
	CXXFLAGS="$CXXFLAGS -DSPARC_LOGGING_ENABLED"
fi

# A handful of locals/parameters in cpp_common_code (e.g. some decoded
# register-address fields in execute_FPop()) are computed but not read
# on every code path, benign, not a sign of a real bug, but -Wall flags
# them and alarms a first-time builder. Silenced here rather than in the
# source.
CXXFLAGS="$CXXFLAGS -Wno-unused-variable -Wno-unused-but-set-variable -Wno-unused-parameter"

# FloatingPointFunctions.h's #pragma STDC FENV_ACCESS ON is standard
# C99/C11, but GCC doesn't implement it, silently ignoring it rather than
# acting on it. -Wall flags that as an unknown pragma; benign, not a sign
# of a real bug, so silenced here rather than in the source.
CXXFLAGS="$CXXFLAGS -Wno-unknown-pragmas"

CPP_CODE_SOURCES="$CPP_CODE_DIR/BitManipulation.cpp \
	$CPP_CODE_DIR/Decoder.cpp \
	$CPP_CODE_DIR/MemCore.cpp \
	$CPP_CODE_DIR/Opcodes.cpp \
	$CPP_CODE_DIR/SparcCore.cpp \
	$CPP_CODE_DIR/CoreLogger.cpp \
	$CPP_CODE_DIR/DebugHooks.cpp \
	$CPP_CODE_DIR/DebugRegistry.cpp"

g++ $CXXFLAGS "$SCRIPT_DIR/sparc_sim.cpp" "$SCRIPT_DIR/SparcStateMachine.cpp" $CPP_CODE_SOURCES \
	-lquadmath -o "$SCRIPT_DIR/sparc_sim_cpp"
echo "Built $SCRIPT_DIR/sparc_sim_cpp"

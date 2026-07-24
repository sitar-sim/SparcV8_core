#!/bin/bash
# build.sh
#
# Builds the standalone functional model of the SPARC V8 core:
#   sparc_cpp_sim -- run a memory image, print final register state
#   check_test    -- run a memory image and check final state
#                     against an expected-results file (pass/fail)
#
# This links against libquadmath, needed by cpp_common_code/FloatingPointFunctions.h
# for quad-precision (128-bit) floating point support (FSQRTq and friends).
#
# --logging / --no-logging (default: --no-logging): whether sparc_cpp_sim
# is built with the per-cycle instruction/state trace (SparcCore::logger,
# a CoreLogger -- see cpp_common_code/CoreLogger.h). This is a compile-time
# choice, via -DSPARC_LOGGING_ENABLED: a --no-logging build's CoreLogger
# methods are all trivial stubs, none of the real formatting code exists
# in the binary. See CoreLogger.cpp and main.cpp.

set -e

LOGGING=0
for arg in "$@"; do
	case "$arg" in
		--logging)    LOGGING=1 ;;
		--no-logging) LOGGING=0 ;;
		*) echo "Usage: $0 [--logging|--no-logging]"; exit 1 ;;
	esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPP_CODE_DIR="$SCRIPT_DIR/../cpp_common_code"

CXXFLAGS="-std=c++11 -Wall -O2 -g -I$CPP_CODE_DIR"
if [ "$LOGGING" = "1" ]; then
	CXXFLAGS="$CXXFLAGS -DSPARC_LOGGING_ENABLED"
fi

CPP_CODE_SOURCES="$CPP_CODE_DIR/BitManipulation.cpp \
	$CPP_CODE_DIR/Decoder.cpp \
	$CPP_CODE_DIR/MemCore.cpp \
	$CPP_CODE_DIR/Opcodes.cpp \
	$CPP_CODE_DIR/SparcCore.cpp \
	$CPP_CODE_DIR/CoreLogger.cpp"

g++ $CXXFLAGS "$SCRIPT_DIR/main.cpp" "$SCRIPT_DIR/SparcStateMachine.cpp" $CPP_CODE_SOURCES \
	-lquadmath -o "$SCRIPT_DIR/sparc_cpp_sim"
echo "Built $SCRIPT_DIR/sparc_cpp_sim"

g++ $CXXFLAGS "$SCRIPT_DIR/check_test.cpp" "$SCRIPT_DIR/SparcStateMachine.cpp" $CPP_CODE_SOURCES \
	-lquadmath -o "$SCRIPT_DIR/check_test"
echo "Built $SCRIPT_DIR/check_test"

#!/bin/bash
# build.sh
#
# Builds the standalone functional model of the SPARC V8 core:
#   sparc_standalone_sim -- run a memory image, print final register state
#   check_test            -- run a memory image and check final state
#                             against an expected-results file (pass/fail)
#
# This links against libquadmath, needed by cpp_code/FloatingPointFunctions.h
# for quad-precision (128-bit) floating point support (FSQRTq and friends).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPP_CODE_DIR="$SCRIPT_DIR/../cpp_code"

CXXFLAGS="-std=c++11 -Wall -O2 -g -I$CPP_CODE_DIR"

CPP_CODE_SOURCES="$CPP_CODE_DIR/BitManipulation.cpp \
	$CPP_CODE_DIR/Decoder.cpp \
	$CPP_CODE_DIR/MemCore.cpp \
	$CPP_CODE_DIR/Opcodes.cpp \
	$CPP_CODE_DIR/SparcCore.cpp"

g++ $CXXFLAGS "$SCRIPT_DIR/main.cpp" "$SCRIPT_DIR/Runner.cpp" $CPP_CODE_SOURCES \
	-lquadmath -o "$SCRIPT_DIR/sparc_standalone_sim"
echo "Built $SCRIPT_DIR/sparc_standalone_sim"

g++ $CXXFLAGS "$SCRIPT_DIR/check_test.cpp" "$SCRIPT_DIR/Runner.cpp" $CPP_CODE_SOURCES \
	-lquadmath -o "$SCRIPT_DIR/check_test"
echo "Built $SCRIPT_DIR/check_test"

#!/usr/bin/env python3
"""
build.py

Builds sitar_check_test: the Sitar-driven counterpart to
../cpp_model/check_test -- same CLI, same expected-results format, same
PASS/FAIL/OVERALL output (see src/sitar_check_test.cpp) -- but runs a
memory image through the actual Sitar Top/Core/SparcThread model instead
of the standalone C++ SparcStateMachine. Lets validation/run_tests.py
--sitar point the exact same test suite at either model.

Requires the `sitar` CLI on PATH (see the separate sitar repo).

Links against libquadmath, needed by cpp_common_code/FloatingPointFunctions.h
for quad-precision (128-bit) floating point support, via `sitar compile`'s
`-l`/`--libs` option.
"""
import argparse
import glob
import os
import shutil
import subprocess
import sys

SCRIPT_DIR          = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR           = os.path.dirname(SCRIPT_DIR)
SITAR_CODE_DIR      = os.path.join(SCRIPT_DIR, 'src', 'sitar_code')
CPP_CODE_DIR        = os.path.join(SCRIPT_DIR, 'src', 'cpp_code')
CPP_COMMON_CODE_DIR = os.path.join(MODEL_DIR, 'cpp_common_code')
MAIN_FILE           = os.path.join(SCRIPT_DIR, 'src', 'sitar_check_test.cpp')
BUILD_DIR           = os.path.join(SCRIPT_DIR, 'build')       # scratch, gitignored
OUTPUT_DIR          = os.path.join(BUILD_DIR, 'Output')       # translated .sitar -> .cpp/.h
EXECUTABLE_DIR      = os.path.join(SCRIPT_DIR, 'executable')
EXECUTABLE          = os.path.join(EXECUTABLE_DIR, 'sitar_check_test')

SITAR_FILES = ['Top.sitar', 'Core.sitar', 'SparcThread.sitar', 'MemoryInterface.sitar', 'MainMemory.sitar']


def run(cmd, **kwargs):
    print('+ ' + ' '.join(cmd))
    return subprocess.run(cmd, **kwargs)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--logging', action='store_true',
                     help="build with Sitar's per-cycle logging enabled (off by default -- "
                          "noisy and slower; useful for debugging timing, e.g. delay parameters)")
    args = ap.parse_args()

    if not shutil.which('sitar'):
        print("error: `sitar` not found on PATH -- see the separate sitar repo")
        sys.exit(1)

    if os.path.isdir(OUTPUT_DIR):
        shutil.rmtree(OUTPUT_DIR)
    os.makedirs(OUTPUT_DIR)
    os.makedirs(EXECUTABLE_DIR, exist_ok=True)
    stale_objects = (glob.glob(os.path.join(CPP_CODE_DIR, '*.o'))
                     + glob.glob(os.path.join(CPP_COMMON_CODE_DIR, '*.o'))
                     + glob.glob(MAIN_FILE[:-4] + '.o'))
    for stale_o in stale_objects:
        os.remove(stale_o)

    print("Translating .sitar files...")
    for f in SITAR_FILES:
        r = run(['sitar', 'translate', os.path.join(SITAR_CODE_DIR, f), '-o', OUTPUT_DIR])
        if r.returncode != 0:
            print("error: translating %s failed" % f)
            sys.exit(1)

    print("Compiling...")
    r = run(['sitar', 'compile',
             '-o', EXECUTABLE,
             '-d', OUTPUT_DIR,
             '-d', CPP_CODE_DIR,
             '-d', CPP_COMMON_CODE_DIR,
             '-m', MAIN_FILE,
             '-l', 'quadmath',
             '--logging' if args.logging else '--no-logging'],
            cwd=SCRIPT_DIR)
    if r.returncode != 0:
        print("error: compile/link failed")
        sys.exit(1)

    print("Built %s" % EXECUTABLE)


if __name__ == '__main__':
    main()

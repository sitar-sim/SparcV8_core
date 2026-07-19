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
for quad-precision (128-bit) floating point support. Worked around here by
re-linking manually with -lquadmath appended, because `sitar compile
--cflags` currently only reaches the compile step (CCFLAGS), never the
link step -- see the separate sitar repo's TODO.md for the root cause;
not fixed there yet.
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

    sitar_bin = shutil.which('sitar')
    if not sitar_bin:
        print("error: `sitar` not found on PATH -- see the separate sitar repo")
        sys.exit(1)
    sitar_core_dir = os.path.join(os.path.dirname(os.path.dirname(sitar_bin)), 'core')

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

    print("Compiling (link step is expected to fail here -- see re-link below)...")
    run(['sitar', 'compile',
         '-o', EXECUTABLE,
         '-d', OUTPUT_DIR,
         '-d', CPP_CODE_DIR,
         '-d', CPP_COMMON_CODE_DIR,
         '-m', MAIN_FILE,
         '--cflags=-lquadmath',
         '--logging' if args.logging else '--no-logging'],
        cwd=SCRIPT_DIR)
    # (sitar's own exit code is ignored -- the link step above is known to
    # fail, see the module docstring; we re-link manually below instead of
    # trying to distinguish that expected failure from a real compile error.)

    print("Re-linking with -lquadmath...")
    objects = (glob.glob(os.path.join(OUTPUT_DIR, '*.o'))
               + glob.glob(os.path.join(CPP_CODE_DIR, '*.o'))
               + glob.glob(os.path.join(CPP_COMMON_CODE_DIR, '*.o'))
               + glob.glob(os.path.join(sitar_core_dir, '*.o'))
               + [MAIN_FILE[:-4] + '.o'])
    r = run(['g++', '-g', '-o', EXECUTABLE] + objects + ['-lquadmath'])
    if r.returncode != 0:
        print("error: link failed")
        sys.exit(1)

    print("Built %s" % EXECUTABLE)


if __name__ == '__main__':
    main()

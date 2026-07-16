#!/usr/bin/env python3
"""
run_tests.py <root_folder> [--max-cycles N] [-v]

Phase 2 of the test pipeline. Recursively finds .vprj files under
<root_folder>, and for each one:
  1. parses its SOURCES (the .s file) and RESULTS block,
  2. writes a normalized expected-results file from RESULTS,
  3. runs model/cpp_standalone_model/check_test against the already-built
     .hex file (see build_hex.py -- phase 1),
and reports a pass/fail summary.

Point this at any subfolder to run only a subset of the suite, e.g.:
    validation/run_tests.py validation/instruction_tests/floating_point
    validation/run_tests.py validation/instruction_tests/integer_alu/Arithmetic

Does NOT require the sparc-elf toolchain -- only model/cpp_standalone_model's
check_test needs to be built (see model/cpp_standalone_model/build.sh), and
each test's .hex file (committed to git) needs to already exist. If you've
changed a .s source (or added a new test) and its .hex is stale/missing, run
build_hex.py on the same root first.
"""
import argparse
import os
import subprocess
import sys

import vprj

CHECK_TEST = os.path.join(vprj.REPO_ROOT, 'model', 'cpp_standalone_model', 'check_test')


def run_one_test(vprj_path, max_cycles, env):
    test_dir = os.path.dirname(vprj_path)
    source, expected_lines = vprj.parse_vprj(vprj_path)
    source_path = os.path.join(test_dir, source)
    prefix = os.path.splitext(source_path)[0]

    hex_path = prefix + '.hex'
    if not os.path.isfile(hex_path):
        return False, ("MISSING .hex FILE: %s\n"
                        "Run validation/build_hex.py on this test (or its containing folder) "
                        "first -- it requires the sparc-elf toolchain, see compiler/README.md."
                        % hex_path)

    expected_path = prefix + '.expected'
    with open(expected_path, 'w') as f:
        f.write('\n'.join(expected_lines) + '\n')

    check = subprocess.run([CHECK_TEST, hex_path, expected_path, str(max_cycles)],
                            capture_output=True, text=True, env=env)
    return check.returncode == 0, check.stdout + check.stderr


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('root', help="folder to search for .vprj files (recursively)")
    ap.add_argument('--max-cycles', type=int, default=10000, help="cycle limit per test (default: 10000)")
    ap.add_argument('-v', '--verbose', action='store_true', help="show per-check output for every test, not just failures")
    args = ap.parse_args()

    if not os.path.isfile(CHECK_TEST):
        print("error: %s not found -- run model/cpp_standalone_model/build.sh first" % CHECK_TEST)
        sys.exit(1)

    vprj_files = vprj.find_vprj_files(args.root)
    if not vprj_files:
        print("No .vprj files found under %s" % args.root)
        sys.exit(1)

    env = vprj.subprocess_env()
    passed_count = 0
    failed = []
    for vprj_path in vprj_files:
        rel = os.path.relpath(vprj_path, vprj.REPO_ROOT)
        try:
            ok, output = run_one_test(vprj_path, args.max_cycles, env)
        except Exception as e:
            ok, output = False, "ERROR: %s" % e

        if ok:
            passed_count += 1
            status = "PASS"
        else:
            failed.append(rel)
            status = "FAIL"
        print("[%s] %s" % (status, rel))
        if args.verbose or not ok:
            for line in output.strip().splitlines():
                print("    " + line)

    total = len(vprj_files)
    print("\n%d/%d tests passed" % (passed_count, total))
    if failed:
        print("\nFailed tests:")
        for f in failed:
            print("  " + f)

    sys.exit(0 if not failed else 1)


if __name__ == '__main__':
    main()

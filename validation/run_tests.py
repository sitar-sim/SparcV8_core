#!/usr/bin/env python3
"""
run_tests.py <root_folder> [--max-cycles N] [-v] [--sitar] [--config NAME]

Phase 2 of the test pipeline. Recursively finds .vprj files under
<root_folder>, and for each one:
  1. parses its SOURCES (the .s file) and RESULTS block,
  2. writes a normalized expected-results file from RESULTS,
  3. runs a checker binary against the already-built .hex file (see
     build_hex.py -- phase 1),
and reports a pass/fail summary.

Point this at any subfolder to run only a subset of the suite, e.g.:
    validation/run_tests.py validation/asm/floating_point
    validation/run_tests.py validation/asm/integer_alu/Arithmetic

By default this drives
model/system_models/core_only/cpp_model/executable/sparc_sim_cpp_core_only
(the plain C++ core + SparcStateMachine, no Sitar). Pass --sitar to instead
drive that configuration's own sitar_model executable (the actual Sitar
Top/Core/SparcThread model) -- same CLI, same expected-results format,
same PASS/FAIL/OVERALL output, so the exact same suite runs against
either model unchanged.

Not every test suits every configuration: a folder's REQUIRES file lists
what its tests need (e.g. "mmu"), and a configuration's COMPONENTS file
(model/system_models/<config>/COMPONENTS) what it has. Tests that need
something --config lacks are skipped, and listed at the end, so
run_tests.py validation --config core_only is safe.

Pass --config NAME (default: core_only) to instead drive another
system_models configuration, e.g. --config core_mmu runs against
model/system_models/core_mmu/cpp_model/executable/sparc_sim_cpp_core_mmu
(or .../core_mmu/sitar_model/executable/sparc_sim_sitar_core_mmu with
--sitar too). --sitar and --config are independent axes: every
configuration's cpp_model and (if it has one) sitar_model share the same
CLI and expected-results format, so this is just a path swap.

Does NOT require the sparc-elf toolchain -- only the checker binary needs to
be built, and each test's .hex file (committed to git) needs to already
exist. If you've changed a .s source (or added a new test) and its .hex is
stale/missing, run build_hex.py on the same root first.
"""
import argparse
import os
import subprocess
import sys

import vprj


def check_test_cpp(config):
    return os.path.join(vprj.REPO_ROOT, 'model', 'system_models', config, 'cpp_model',
                         'executable', 'sparc_sim_cpp_%s' % config)


def check_test_sitar(config):
    return os.path.join(vprj.REPO_ROOT, 'model', 'system_models', config, 'sitar_model',
                         'executable', 'sparc_sim_sitar_%s' % config)


def run_one_test(vprj_path, max_cycles, env, check_test):
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

    max_cycles = max(max_cycles, vprj.parse_max_cycles(vprj_path) or 0)
    check = subprocess.run([check_test, hex_path, expected_path, str(max_cycles)],
                            capture_output=True, text=True, env=env)
    return check.returncode == 0, check.stdout + check.stderr


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('root', help="folder to search for .vprj files (recursively)")
    ap.add_argument('--max-cycles', type=int, default=200000, help="cycle limit per test (default: 200000 -- core_mmu's sitar_model needs this much headroom, since every physical access, including every instruction fetch, now crosses two nets)")
    ap.add_argument('-v', '--verbose', action='store_true', help="show per-check output for every test, not just failures")
    ap.add_argument('--sitar', action='store_true',
                     help="drive --config's sitar_model executable (the actual Sitar model) instead "
                          "of its cpp_model's (the default)")
    ap.add_argument('--config', default='core_only',
                     help="which system_models configuration to drive (default: core_only)")
    args = ap.parse_args()

    if 'apara_standalone' in (vprj.config_components(args.config) or set()):
        print("error: %s is the engine alone, with no SPARC core: its tests run with "
              "validation/apara/run_tests.py" % args.config)
        sys.exit(1)

    check_test = check_test_sitar(args.config) if args.sitar else check_test_cpp(args.config)
    build_hint = ("model/system_models/%s/sitar_model/build.sh" % args.config if args.sitar
                  else "model/system_models/%s/cpp_model/build.sh" % args.config)
    if not os.path.isfile(check_test):
        print("error: %s not found -- run %s first" % (check_test, build_hint))
        sys.exit(1)

    vprj_files = vprj.find_vprj_files(args.root)
    if not vprj_files:
        print("No .vprj files found under %s" % args.root)
        sys.exit(1)

    # Each test's REQUIRES (its folder's and its parents') against what the
    # configuration has (its COMPONENTS file): skip the tests it cannot run.
    have = vprj.config_components(args.config)
    skipped = {}
    if have is None:
        print("note: %s has no COMPONENTS file: running every test" % args.config)
    else:
        runnable = []
        for v in vprj_files:
            missing = vprj.requirements(v) - have
            if missing:
                folder = os.path.relpath(vprj.requiring_folder(v, missing), vprj.REPO_ROOT)
                key = (folder, ', '.join(sorted(missing)))
                skipped[key] = skipped.get(key, 0) + 1
            else:
                runnable.append(v)
        vprj_files = runnable

    env = vprj.subprocess_env()
    passed_count = 0
    failed = []
    for vprj_path in vprj_files:
        rel = os.path.relpath(vprj_path, vprj.REPO_ROOT)
        try:
            ok, output = run_one_test(vprj_path, args.max_cycles, env, check_test)
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
    for (folder, missing), n in sorted(skipped.items()):
        print("skipped %d test(s) under %s: %s has no %s" % (n, folder, args.config, missing))
    print("\n%d/%d tests passed" % (passed_count, total) +
          (" (%d skipped)" % sum(skipped.values()) if skipped else ""))
    if failed:
        print("\nFailed tests:")
        for f in failed:
            print("  " + f)

    sys.exit(0 if not failed else 1)


if __name__ == '__main__':
    main()

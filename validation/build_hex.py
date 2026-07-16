#!/usr/bin/env python3
"""
build_hex.py <root_folder>

Phase 1 of the test pipeline. Recursively finds .vprj files under
<root_folder>, and for each one, assembles/links/hex-dumps its paired .s
file (via compiler/assemble.sh) into a .hex memory image next to it.

Requires the sparc-elf toolchain (see compiler/README.md). Automatically
uses compiler/toolchain/bin if compiler/install_toolchain.sh has been run;
otherwise falls back to whatever is already on PATH.

Only needed when a test's .s source has changed, or for a fresh test added
to the suite -- the resulting .hex files are committed to git specifically
so that run_tests.py (phase 2, the actual simulation) can be used on its
own, with no cross-compiler installed, by anyone who only wants to run the
existing tests against a modified model. Run this script again and commit
the updated .hex whenever a .s file changes.
"""
import argparse
import os
import subprocess
import sys

import vprj

ASSEMBLE_SH = os.path.join(vprj.REPO_ROOT, 'compiler', 'assemble.sh')


def build_one(vprj_path, env):
    test_dir = os.path.dirname(vprj_path)
    source, _ = vprj.parse_vprj(vprj_path)
    source_path = os.path.join(test_dir, source)

    asm = subprocess.run([ASSEMBLE_SH, source_path], capture_output=True, text=True, env=env)
    return asm.returncode == 0, asm.stdout + asm.stderr


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('root', help="folder to search for .vprj files (recursively)")
    ap.add_argument('-v', '--verbose', action='store_true', help="show assembler output for every test, not just failures")
    args = ap.parse_args()

    vprj_files = vprj.find_vprj_files(args.root)
    if not vprj_files:
        print("No .vprj files found under %s" % args.root)
        sys.exit(1)

    env = vprj.subprocess_env()
    ok_count = 0
    failed = []
    for vprj_path in vprj_files:
        rel = os.path.relpath(vprj_path, vprj.REPO_ROOT)
        try:
            ok, output = build_one(vprj_path, env)
        except Exception as e:
            ok, output = False, "ERROR: %s" % e

        if ok:
            ok_count += 1
            status = "OK"
        else:
            failed.append(rel)
            status = "FAIL"
        print("[%s] %s" % (status, rel))
        if args.verbose or not ok:
            for line in output.strip().splitlines():
                print("    " + line)

    total = len(vprj_files)
    print("\n%d/%d assembled" % (ok_count, total))
    if failed:
        print("\nFailed to assemble:")
        for f in failed:
            print("  " + f)

    sys.exit(0 if not failed else 1)


if __name__ == '__main__':
    main()

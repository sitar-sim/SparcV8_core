#!/usr/bin/env python3
"""
check_on_host.py

Compiles each OpenMP test in this folder with the host's gcc -fopenmp, runs it with four
threads, and compares the %o0 and %o1 it prints with the values in its .vprj, which the
simulators are held to. So the bare-metal runtime in compiler/sparc_common_routines/omp.h
and a real OpenMP implementation are checked to agree on every test.

Tests that exercise only the bare metal side (a RUN_OPTIONS of --run-cores, or a test not
including openmp_common.h) are skipped, and listed.
"""
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))


def expected(vprj):
    return dict(re.findall(r'^(o[01])\s*=\s*(0x[0-9a-fA-F]+)', vprj, re.M))


def main():
    failed = []
    passed = skipped = 0
    env = dict(os.environ, OMP_NUM_THREADS='4')
    with tempfile.TemporaryDirectory() as tmp:
        for name in sorted(os.listdir(HERE)):
            source = os.path.join(HERE, name, name + '.c')
            if not os.path.exists(source):
                continue
            with open(os.path.join(HERE, name, name + '.vprj')) as f:
                vprj = f.read()
            with open(source) as f:
                text = f.read()
            if '--run-cores' in vprj or 'openmp_common.h' not in text or 'multicore_platform.h' in text:
                print('[SKIP] %s' % name)
                skipped += 1
                continue
            program = os.path.join(tmp, name)
            build = subprocess.run(['gcc', '-fopenmp', '-w', '-I' + HERE, source, '-o', program],
                                   capture_output=True, text=True)
            if build.returncode != 0:
                print('[FAIL] %s: does not compile\n%s' % (name, build.stderr))
                failed.append(name)
                continue
            run = subprocess.run([program], capture_output=True, text=True, env=env, timeout=60)
            got = dict(re.findall(r'^(o[01])=(0x[0-9a-fA-F]+)', run.stdout, re.M))
            want = expected(vprj)
            same = all(int(got.get(k, '-1'), 0) == int(v, 0) for k, v in want.items())
            print('[%s] %s: host %s, .vprj %s' % ('OK' if same else 'FAIL', name, got, want))
            if same:
                passed += 1
            else:
                failed.append(name)
    print('%d agree with the host, %d differ, %d skipped' % (passed, len(failed), skipped))
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""
run_tests.py [paths...] [--sitar] [--reference] [--mcode-run PATH] [-v]

Runs the APARA engine tests: every .mcode file under the given paths
(default: this folder). Each test is one mcode program whose comment
lines starting with "//@" say how to run it and what to expect:

    //@ threads: 0x0 0x20         start a thread at each PC (default: one at 0x0)
    //@ data: 10: 0x0102030405060708    initial DMEM dword (index: value)
    //@ reg: 0 $r3 0x10           initial register (thread, register, value)
    //@ expect: 0 reg $r5 0x7     an expected result, in mcode_run's results
                                  format (Ref model/cpp_common_code/apara/AparaFiles.h),
                                  a register written $rN instead of in hex
    //@ deviation: <why>          the test depends on a documented deviation
                                  from the reference model (docs/source/apara/deviations.md)
    //@ cycles: 12                the run takes exactly this many cycles on the
                                  timing model (checked with --sitar only)

For each test, the runner assembles it with compiler/apara (our
assembler), writes the object, data, register and results files into
build/<test name>/, and runs the apara configuration's simulator on them
(the cpp_model, or with --sitar the sitar_model).

--reference also replays each test without a deviation line on the APARA
reference simulator (mcode_run, from --mcode-run or $MCODE_RUN): the
reference must reach the same final state as ours, PC, registers and
DMEM, which checks our model and the test's expectations at once.
"""
import argparse
import glob
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(REPO_ROOT, 'compiler', 'apara'))
import mcode  # noqa: E402

CPP_SIM = os.path.join(REPO_ROOT, 'model', 'system_models', 'apara', 'cpp_model', 'executable', 'apara_sim_cpp')
SITAR_SIM = os.path.join(REPO_ROOT, 'model', 'system_models', 'apara', 'sitar_model', 'executable', 'apara_sim_sitar')


def parse_directives(text):
    d = {'threads': [], 'data': [], 'reg': [], 'expect': [], 'deviation': [], 'cycles': []}
    for line in text.splitlines():
        m = re.match(r'^\s*//@\s*(\w+)\s*:\s*(.*?)\s*$', line)
        if not m:
            continue
        key, value = m.group(1), m.group(2)
        if key not in d:
            raise ValueError('unknown directive //@ %s' % key)
        if key == 'threads':
            d['threads'] += value.split()
        elif key in ('reg', 'expect'):
            # $rN to the files' hexadecimal register numbers; values to 0x hex
            words = [('0x%x' % int(w[2:])) if re.match(r'^\$r\d+$', w) else w for w in value.split()]
            if key == 'reg':
                if len(words) != 3:
                    raise ValueError('//@ reg: needs <thread> <register> <value>')
                words[2] = '0x%x' % (int(words[2], 0) & 0xFFFFFFFFFFFFFFFF)
            d[key].append(' '.join(words))
        else:
            d[key].append(value)
    if not d['threads']:
        d['threads'] = ['0x0']
    return d


def prepare(test_path):
    """Assembles the test and writes its files. Returns (build dir, directives)."""
    name = os.path.splitext(os.path.relpath(test_path, HERE))[0].replace(os.sep, '__')
    out = os.path.join(HERE, 'build', name)
    os.makedirs(out, exist_ok=True)
    with open(test_path) as f:
        text = f.read()
    d = parse_directives(text)
    bundles, _, _ = mcode.assemble(text)
    files = {
        'program.obj': mcode.format_object(mcode.object_words(bundles)),
        'data.map': ''.join(l + '\n' for l in d['data']),
        'registers.txt': ''.join(l + '\n' for l in d['reg']),
        'results.txt': ''.join(l + '\n' for l in d['expect']),
    }
    for fname, content in files.items():
        with open(os.path.join(out, fname), 'w') as f:
            f.write(content)
    return out, d


def sim_args(out, d):
    args = []
    for pc in d['threads']:
        args += ['-p', pc]
    return args + ['-i', os.path.join(out, 'program.obj'), '-d', os.path.join(out, 'data.map'),
                   '-a', os.path.join(out, 'registers.txt')]


def run_reference(mcode_run, out, d):
    """Replays our final state on the reference. Returns (ok, message)."""
    dump = os.path.join(out, 'ours.results')
    subprocess.run([CPP_SIM] + sim_args(out, d) + ['--dump-results', dump],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    r = subprocess.run([mcode_run] + sim_args(out, d) + ['-r', dump], cwd=out,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, timeout=60)
    mismatches = [l for l in r.stdout.splitlines() if 'expected' in l and 'PostCondition' in l]
    if mismatches:
        return False, mismatches[0]
    if 'PostCondition' not in r.stdout:
        return False, 'the reference checked nothing (did it run?)'
    return True, ''


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('paths', nargs='*', default=[HERE])
    ap.add_argument('--sitar', action='store_true')
    ap.add_argument('--reference', action='store_true')
    ap.add_argument('--mcode-run', default=os.environ.get('MCODE_RUN'))
    ap.add_argument('-v', '--verbose', action='store_true')
    a = ap.parse_args()

    sim = SITAR_SIM if a.sitar else CPP_SIM
    if not os.path.isfile(sim):
        sys.exit('error: %s not found -- build the apara configuration first' % sim)
    if a.reference and not (a.mcode_run and os.path.isfile(a.mcode_run)):
        sys.exit('error: --reference needs the reference mcode_run (--mcode-run or $MCODE_RUN)')

    tests = []
    for p in a.paths:
        if os.path.isdir(p):
            tests += sorted(t for t in glob.glob(os.path.join(p, '**', '*.mcode'), recursive=True)
                            if os.sep + 'build' + os.sep not in t)
        else:
            tests.append(p)

    passed = failed = 0
    for t in tests:
        rel = os.path.relpath(t, HERE)
        try:
            out, d = prepare(t)
        except (mcode.AsmError, ValueError) as e:
            print('FAIL  %s: %s' % (rel, getattr(e, 'message', e)))
            failed += 1
            continue
        r = subprocess.run([sim] + sim_args(out, d) + ['-r', os.path.join(out, 'results.txt')],
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
        ok = r.returncode == 0 and r.stdout.rstrip().endswith('PASS') and 'internal error' not in r.stdout
        note = ''
        if ok and a.sitar and d['cycles']:
            m = re.search(r'in (\d+) cycles', r.stdout)
            took = int(m.group(1)) if m else -1
            if took != int(d['cycles'][0]):
                ok, note = False, 'took %d cycles, expected %s' % (took, d['cycles'][0])
            else:
                note = '(%d cycles)' % took
        if ok and a.reference and not d['deviation']:
            ok, note = run_reference(a.mcode_run, out, d)
            note = 'reference: ' + note if note else '(reference agrees)'
        elif a.reference and d['deviation']:
            note = '(not replayed: deviation)'
        print('%s  %s %s' % ('PASS' if ok else 'FAIL', rel, note))
        if not ok or a.verbose:
            for line in r.stdout.splitlines():
                if not ok and (line.startswith('mismatch') or 'stopped' in line or 'error' in line) or a.verbose:
                    print('        ' + line)
        passed += ok
        failed += not ok
    print('OVERALL: %d passed, %d failed' % (passed, failed))
    return 0 if failed == 0 else 1


if __name__ == '__main__':
    sys.exit(main())

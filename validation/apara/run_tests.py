#!/usr/bin/env python3
"""
run_tests.py [paths...] [--sitar] [--reference] [--mcode-run PATH] [-v]

Runs the APARA engine's own tests on the apara configuration: every
.vprj file under the given paths (default: this folder). Each test is a
source file and a .vprj file saying how to run it and what to expect
(Ref apara_vprj.py for the format). The source is an mcode program; a
C program, which compiler/apara/apcc.py first compiles to mcode; or an
object file (.obj), run as it is, for bundles the assembler would
reject.

For each test, the runner assembles the program with compiler/apara
(our assembler), writes the object, data, register and results files
into build/<test name>/, and runs the apara configuration's simulator
on them (the cpp_model, or with --sitar the sitar_model). With --sitar
it also checks the timing model's figures the .vprj gives: CYCLES,
MISPREDICTS, BTB_PREDICTIONS and the hazard count (HAZARDS_UNLOCKED),
all for the timing model's default knobs (Ref timing/README.md).

A test with ASM_ERROR is a test of the assembler: it passes when the
source fails to assemble with that message.

--reference also replays each test without a DEVIATION line on the
APARA reference simulator (mcode_run, from --mcode-run or $MCODE_RUN):
the reference must reach the same final state as ours, PC, registers
and DMEM, which checks our model and the test's expectations at once.
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
import apara_vprj  # noqa: E402

CPP_SIM = os.path.join(REPO_ROOT, 'model', 'system_models', 'apara', 'cpp_model', 'executable', 'apara_sim_cpp')
SITAR_SIM = os.path.join(REPO_ROOT, 'model', 'system_models', 'apara', 'sitar_model', 'executable', 'apara_sim_sitar')

STAT_KEYS = {  # .vprj key: the --stats line it is checked against
    'MISPREDICTS': 'mispredicts',
    'BTB_PREDICTIONS': 'BTB-predicted fetches',
}


class Skip(Exception):
    pass


def source_program(src_path, flags=None):
    """The source as mcode text, plus the DMEM lines and symbols a C
    program brings (none for mcode)."""
    with open(src_path) as f:
        text = f.read()
    if src_path.endswith('.c'):
        import apcc
        r = apcc.compile_source(text, src_path, 0 if (flags or '').strip() == '-O0' else 1)
        return r.mcode, r.data_lines, r.symbols
    return text, [], {}


def prepare(vprj_path):
    """Returns (build dir, parsed vprj, thread PCs), or raises Skip(message)
    for an ASM_ERROR test (whose outcome is already known)."""
    d = apara_vprj.parse(vprj_path)
    test_dir = os.path.dirname(vprj_path)
    src = os.path.join(test_dir, d['SOURCES'])
    name = os.path.splitext(os.path.relpath(vprj_path, HERE))[0].replace(os.sep, '__')
    out = os.path.join(HERE, 'build', name)
    os.makedirs(out, exist_ok=True)

    if src.endswith('.obj'):  # a hand-made object: run as it is, unchecked by the assembler
        with open(src) as f:
            obj_text = f.read()
        text, data_lines, symbols, labels = None, [], {}, {}
    else:
        text, data_lines, symbols = source_program(src, d['APCC_FLAGS'])
    if src.endswith('.c'):
        with open(os.path.join(out, 'program.mcode'), 'w') as f:
            f.write(text)
    try:
        if text is not None:
            bundles, labels, _ = mcode.assemble(text)
            obj_text = mcode.format_object(mcode.object_words(bundles))
    except mcode.AsmError as e:
        if d['ASM_ERROR'] and d['ASM_ERROR'] in e.message:
            raise Skip('PASS', '(rejected: %s)' % e.message)
        raise
    if d['ASM_ERROR']:
        raise Skip('FAIL', 'assembled, but the assembler should have rejected it (%s)' % d['ASM_ERROR'])

    threads = []
    for t in (d['THREADS'] or '0x0').split():
        if t in labels:
            threads.append('0x%x' % labels[t])
        else:
            try:
                threads.append('0x%x' % apara_vprj.number(t))
            except ValueError:
                raise apara_vprj.VprjError('THREADS: no label %s' % t)

    data, regs, results = apara_vprj.write_files(d, vprj_path, symbols, data_lines)
    files = {
        'program.obj': obj_text,
        'data.map': data,
        'registers.txt': regs,
        'results.txt': results,
    }
    for fname, content in files.items():
        with open(os.path.join(out, fname), 'w') as f:
            f.write(content)
    return out, d, threads


def sim_args(out, threads):
    args = []
    for pc in threads:
        args += ['-p', pc]
    return args + ['-i', os.path.join(out, 'program.obj'), '-d', os.path.join(out, 'data.map'),
                   '-a', os.path.join(out, 'registers.txt')]


def run_reference(mcode_run, out, threads):
    """Replays our final state on the reference. Returns (ok, message)."""
    dump = os.path.join(out, 'ours.results')
    subprocess.run([CPP_SIM] + sim_args(out, threads) + ['--dump-results', dump],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    r = subprocess.run([mcode_run] + sim_args(out, threads) + ['-r', dump], cwd=out,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, timeout=60)
    mismatches = [l for l in r.stdout.splitlines() if 'expected' in l and 'PostCondition' in l]
    if mismatches:
        return False, mismatches[0]
    if 'PostCondition' not in r.stdout:
        return False, 'the reference checked nothing (did it run?)'
    return True, ''


def stat(stdout, label):
    m = re.search(r'^%s\s+(\d+)' % re.escape(label), stdout, re.M)
    return int(m.group(1)) if m else None


def check_timing(d, stdout):
    """The timing model's figures against the .vprj. Returns (ok, note).
    CYCLES and the predictor counts hold for the default knobs; with the
    interlock off (a debugging knob) only the hazard count is checked."""
    notes = []
    m = re.search(r'in (\d+) cycles', stdout)
    took = int(m.group(1)) if m else -1
    interlock_off = re.search(r'^REGFILE interlock\s+off', stdout, re.M) is not None
    if d['CYCLES'] is not None and not interlock_off:
        if took != int(d['CYCLES'], 0):
            return False, 'took %d cycles, expected %s' % (took, d['CYCLES'])
    notes.append('%d cycles' % took)
    for key, label in STAT_KEYS.items():
        if d[key] is not None and not interlock_off:
            got = stat(stdout, label)
            if got != int(d[key], 0):
                return False, '%s: %s, expected %s' % (label, got, d[key])
            notes.append('%s %d' % (label, got))
    violations = stat(stdout, 'lock-mask violations')
    if violations is None:
        return False, 'the timing model reported no lock-mask count'
    if violations:
        return False, '%d bundle(s) used registers outside their lock masks' % violations
    hazards = stat(stdout, 'RAW hazards')
    if hazards is None:
        return False, 'the timing model reported no hazard count'
    want = int(d['HAZARDS_UNLOCKED'], 0) if (interlock_off and d['HAZARDS_UNLOCKED']) else 0
    if hazards != want:
        return False, 'RAW hazards: %d, expected %d (interlock %s)' % (hazards, want, 'off' if interlock_off else 'on')
    if interlock_off:
        notes.append('%d hazards, interlock off' % hazards)
    return True, '(' + ', '.join(notes) + ')'


def find_tests(paths):
    tests = []
    for p in paths:
        if os.path.isdir(p):
            tests += sorted(t for t in glob.glob(os.path.join(p, '**', '*.vprj'), recursive=True)
                            if os.sep + 'build' + os.sep not in t)
        else:
            tests.append(p)
    return tests


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('paths', nargs='*', default=[HERE])
    ap.add_argument('--sitar', action='store_true', help="run the sitar_model (and check timing figures)")
    ap.add_argument('--reference', action='store_true', help="also replay each test on the reference simulator")
    ap.add_argument('--mcode-run', default=os.environ.get('MCODE_RUN'))
    ap.add_argument('-v', '--verbose', action='store_true')
    a = ap.parse_args()

    sim = SITAR_SIM if a.sitar else CPP_SIM
    if not os.path.isfile(sim):
        sys.exit('error: %s not found -- build the apara configuration first' % sim)
    if a.reference and not (a.mcode_run and os.path.isfile(a.mcode_run)):
        sys.exit('error: --reference needs the reference mcode_run (--mcode-run or $MCODE_RUN)')

    tests = find_tests(a.paths)
    if not tests:
        sys.exit('No .vprj files found under %s' % ' '.join(a.paths))

    per_suite = {}
    failed = []
    for t in tests:
        rel = os.path.relpath(t, HERE)
        suite = rel.split(os.sep)[0] if os.sep in rel else '.'
        out_lines = []
        try:
            out, d, threads = prepare(t)
        except Skip as s:
            ok, note = s.args[0] == 'PASS', s.args[1]
        except (mcode.AsmError, apara_vprj.VprjError, ValueError, Exception) as e:
            ok, note = False, str(getattr(e, 'message', e))
        else:
            cmd = [sim] + sim_args(out, threads) + ['-r', os.path.join(out, 'results.txt')]
            if a.sitar:
                cmd.append('--stats')
            if d['MAX_CYCLES']:
                cmd += ['--max-cycles' if a.sitar else '--max-bundles', d['MAX_CYCLES']]
            r = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
            out_lines = r.stdout.splitlines()
            ok = r.returncode == 0 and 'PASS' in out_lines and 'internal error' not in r.stdout
            note = ''
            if ok and a.sitar:
                ok, note = check_timing(d, r.stdout)
            if ok and a.reference and not d['DEVIATION']:
                ok, note = run_reference(a.mcode_run, out, threads)
                note = 'reference: ' + note if note else '(reference agrees)'
            elif a.reference and d['DEVIATION']:
                note = '(not replayed: deviation)'
        print('%s  %s %s' % ('PASS' if ok else 'FAIL', rel, note))
        if not ok or a.verbose:
            for line in out_lines:
                if a.verbose or line.startswith('mismatch') or 'stopped' in line or 'error' in line \
                        or 'hazard' in line:
                    print('        ' + line)
        s = per_suite.setdefault(suite, [0, 0])
        s[0] += ok
        s[1] += 1
        if not ok:
            failed.append(rel)

    print()
    for suite in sorted(per_suite):
        print('  %-14s %d/%d passed' % (suite, per_suite[suite][0], per_suite[suite][1]))
    passed = sum(s[0] for s in per_suite.values())
    print('OVERALL: %d passed, %d failed' % (passed, len(tests) - passed))
    return 0 if not failed else 1


if __name__ == '__main__':
    sys.exit(main())

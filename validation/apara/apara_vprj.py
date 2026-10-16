#!/usr/bin/env python3
"""
apara_vprj.py

Parses an APARA test's .vprj file, the engine's counterpart of the SPARC
tests' .vprj (Ref ../vprj.py). Not a standalone script: imported by
run_tests.py.

A test is a source file (an mcode program, or a C program for
compiler/apara/apcc.py) and a .vprj file of the same name:

    SOURCES = dot_product.mcode
    THREADS = 0x0 worker          start a thread at each PC or label (default: one at 0x0)
    INIT =                        the state before the run:
    r3 = 0x10                       thread 0's $r3 (t1.r3 for thread 1)
    m[0x80] = 0x0102030405060708    the DMEM dword at byte address 0x80
    RESULTS =                     the expected state after the run:
    r5 = 0x7                        a register, with an optional mask: r5 = 0x7 0xff
    t1.pc = 0x9                     a thread's PC
    error = 0x2000000               a thread's ERROR register
    m[0x80] = 0x2a                  a DMEM dword (byte address)
    m[C+0x8] = 0x2a                 ... at a symbol of a C program plus an offset
    CYCLES = 12                   the exact cycle count (timing model, default knobs)
    MISPREDICTS = 2               the timing model's mispredict count
    BTB_PREDICTIONS = 7           the timing model's BTB-predicted fetches
    HAZARDS_UNLOCKED = 3          the RAW hazards the timing model must report when its
                                  REGFILE interlock is turned off (0 with it on)
    ASM_ERROR = written twice     the source must NOT assemble: the assembler's error
                                  message must contain this text (nothing is run)
    DEVIATION = <why>             the test depends on a deviation from the engine's
                                  reference model (not replayed on it)
    MAX_CYCLES = 1000000          the run limit (default: the simulators' own)
    APCC_FLAGS = -O0              compiler options for a C source (default: -O1)

Every number is hexadecimal with a 0x prefix, or decimal without one.
Lines starting with '#' are comments.
"""
import re

KEY_RE     = re.compile(r'^([A-Z][A-Z_]*)\s*=\s*(.*?)\s*$')
REG_RE     = re.compile(r'^(?:t([0-3])\.)?r(\d+)\s*=\s*(\S+)(?:\s+(\S+))?\s*$')
PC_RE      = re.compile(r'^(?:t([0-3])\.)?(pc|error)\s*=\s*(\S+)(?:\s+(\S+))?\s*$')
MEM_RE     = re.compile(r'^m\[\s*([^\]]+?)\s*\]\s*=\s*(\S+)(?:\s+(\S+))?\s*$')

SECTIONS = ('INIT', 'RESULTS')
SCALARS = ('SOURCES', 'THREADS', 'CYCLES', 'MISPREDICTS', 'BTB_PREDICTIONS',
           'HAZARDS_UNLOCKED', 'ASM_ERROR', 'DEVIATION', 'MAX_CYCLES', 'APCC_FLAGS')

MASK64 = (1 << 64) - 1


class VprjError(Exception):
    pass


def number(s):
    s = s.strip()
    v = int(s, 16) if s.lower().startswith(('0x', '-0x')) else int(s, 10)
    return v & MASK64


def address(expr, symbols):
    """A DMEM byte address: a number, or SYMBOL[+offset]."""
    m = re.match(r'^([A-Za-z_]\w*)\s*(?:\+\s*(\S+))?$', expr)
    if m:
        if m.group(1) not in symbols:
            raise VprjError('unknown symbol %s in m[%s]' % (m.group(1), expr))
        return symbols[m.group(1)] + (number(m.group(2)) if m.group(2) else 0)
    return number(expr)


def parse(path):
    """Returns a dict: the scalar keys above (strings, or None), and
    'INIT'/'RESULTS' as lists of (kind, thread, what, value, mask, line):
    kind 'reg' (what: register number), 'pc', 'error', or 'mem' (what: the
    address expression, resolved later with resolve())."""
    d = {k: None for k in SCALARS}
    d['INIT'], d['RESULTS'] = [], []
    section = None
    with open(path) as f:
        for n, raw in enumerate(f, 1):
            line = raw.split('#', 1)[0].strip()
            if not line:
                continue
            m = KEY_RE.match(line)
            if m:
                key, value = m.group(1), m.group(2)
                if key in SECTIONS:
                    section = key
                    continue
                if key not in SCALARS:
                    raise VprjError('%s:%d: unknown key %s' % (path, n, key))
                d[key] = value
                section = None
                continue
            if section is None:
                raise VprjError('%s:%d: "%s" is outside INIT/RESULTS' % (path, n, line))
            entry = None
            m = REG_RE.match(line)
            if m:
                r = int(m.group(2))
                if r > 31:
                    raise VprjError('%s:%d: no register r%d' % (path, n, r))
                entry = ('reg', int(m.group(1) or 0), r, number(m.group(3)),
                         number(m.group(4)) if m.group(4) else None, n)
            m = m or PC_RE.match(line)
            if entry is None and m:
                entry = (m.group(2), int(m.group(1) or 0), None, number(m.group(3)),
                         number(m.group(4)) if m.group(4) else None, n)
            mm = MEM_RE.match(line)
            if entry is None and mm:
                entry = ('mem', 0, mm.group(1), number(mm.group(2)),
                         number(mm.group(3)) if mm.group(3) else None, n)
            if entry is None:
                raise VprjError('%s:%d: cannot read "%s"' % (path, n, line))
            if section == 'INIT' and entry[0] in ('pc', 'error'):
                raise VprjError('%s:%d: INIT sets registers and memory only' % (path, n))
            d[section].append(entry)
    if not d['SOURCES']:
        raise VprjError('%s: no SOURCES line' % path)
    return d


def dword_index(addr, path, n):
    if addr % 8:
        raise VprjError('%s:%d: m[0x%x] is not a dword (multiple of 8) address' % (path, n, addr))
    return addr // 8


def write_files(d, path, symbols, data_lines):
    """The simulator's data, register and results files (Ref
    model/cpp_common_code/apara/AparaFiles.h), as strings.
    data_lines: initial DMEM lines the source itself contributes (a C
    program's initialized globals)."""
    data, regs, results = list(data_lines), [], []
    for kind, t, what, value, mask, n in d['INIT']:
        if kind == 'reg':
            regs.append('%d 0x%x 0x%x' % (t, what, value))
        else:
            data.append('%x: 0x%016x' % (dword_index(address(what, symbols), path, n), value))
    for kind, t, what, value, mask, n in d['RESULTS']:
        m = '' if mask is None else ' 0x%x' % mask
        if kind == 'reg':
            results.append('%d reg 0x%x 0x%x%s' % (t, what, value, m))
        elif kind == 'mem':
            results.append('0 mem 0x%x 0x%x%s' % (dword_index(address(what, symbols), path, n), value, m))
        else:
            results.append('%d %s 0x%x%s' % (t, kind, value, m))
    text = lambda ls: ''.join(l + '\n' for l in ls)
    return text(data), text(regs), text(results)

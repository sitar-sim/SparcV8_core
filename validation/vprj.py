#!/usr/bin/env python3
"""
vprj.py

Shared .vprj-parsing helpers used by both build_hex.py and run_tests.py.
Not a standalone script -- imported by the two.
"""
import os
import re

REPO_ROOT     = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
TOOLCHAIN_BIN = os.path.join(REPO_ROOT, 'compiler', 'toolchain', 'bin')

SOURCES_LINE_RE = re.compile(r'^SOURCES\s*=\s*(\S+)')
# Optional: a startup file to link instead of compiler/crt0.s (C tests
# only), e.g. `STARTUP = crt0_interrupts.s`.
STARTUP_LINE_RE = re.compile(r'^STARTUP\s*=\s*(\S+)')
# Optional RESULTS line: the exact bytes the program must have sent out
# through the Serial device, as a double-quoted string with C-style
# escapes (\n, \t, \\, \", \xHH). Only configurations with devices
# check it.
SERIAL_OUT_LINE_RE = re.compile(r'^serial_out\s*=\s*"((?:[^"\\]|\\.)*)"\s*$')
MEM_LINE_RE     = re.compile(r'^m\[\s*([0-9A-Fa-fx]+)\s*\]\s*=\s*([0-9A-Fa-fx]+)(?:\s+([0-9A-Fa-fx]+))?\s*$')
REG_LINE_RE     = re.compile(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([0-9A-Fa-fx]+)(?:\s+([0-9A-Fa-fx]+))?\s*$')
ASI_LINE_RE     = re.compile(r'^asi\s*=', re.IGNORECASE)


def parse_hexlike(s):
    """Every numeric value in this test corpus is hex, with or without a
    leading 0x -- never treat a leading-zero value as octal."""
    s = s.strip()
    if s.lower().startswith('0x'):
        s = s[2:]
    return int(s, 16)


# An APARA engine program the C test loads (C tests only, any number of
# lines), e.g. `MCODE = kernel.mcode`: build_hex.py writes it as
# kernel.mcode.h (Ref compiler/apara/apara_obj_to_c.py) before compiling.
MCODE_LINE_RE = re.compile(r'^MCODE\s*=\s*(\S+)')


def parse_mcode(path):
    """Returns the MCODE files named in a .vprj."""
    found = []
    with open(path) as f:
        for line in f:
            m = MCODE_LINE_RE.match(line)
            if m:
                found.append(m.group(1))
    return found


def parse_startup(path):
    """Returns the STARTUP file named in a .vprj, or None."""
    with open(path) as f:
        for line in f:
            m = STARTUP_LINE_RE.match(line)
            if m:
                return m.group(1)
    return None


def decode_serial_string(s):
    """C-style escapes in a serial_out string -> bytes."""
    out = bytearray()
    i = 0
    simple = {'n': 10, 't': 9, 'r': 13, '0': 0, '\\': 92, '"': 34}
    while i < len(s):
        c = s[i]
        if c == '\\' and i + 1 < len(s):
            e = s[i + 1]
            if e == 'x' and i + 3 < len(s):
                out.append(int(s[i + 2:i + 4], 16))
                i += 4
                continue
            if e in simple:
                out.append(simple[e])
                i += 2
                continue
        out.extend(c.encode('latin-1'))
        i += 1
    return bytes(out)


def parse_vprj(path):
    """Returns (source_filename, [normalized 'REG name val mask' / 'MEM addr val mask' lines])."""
    with open(path) as f:
        lines = f.readlines()

    source = None
    results_start = None
    for i, line in enumerate(lines):
        m = SOURCES_LINE_RE.match(line)
        if m:
            source = m.group(1)
        if line.strip().startswith('RESULTS'):
            results_start = i + 1

    if source is None:
        raise ValueError("%s: no SOURCES line found" % path)
    if results_start is None:
        raise ValueError("%s: no RESULTS line found" % path)

    normalized = []
    for line in lines[results_start:]:
        line = line.strip()
        if not line or ASI_LINE_RE.match(line):
            continue  # blank, or an asi=... line (ignored: MemCore is a
                      # single flat address space, with no ASI distinction)
        m = SERIAL_OUT_LINE_RE.match(line)
        if m:
            data = decode_serial_string(m.group(1))
            normalized.append('SERIAL_OUT %s' % (data.hex() if data else '-'))
            continue
        m = MEM_LINE_RE.match(line)
        if m:
            addr  = parse_hexlike(m.group(1))
            value = parse_hexlike(m.group(2))
            mask  = parse_hexlike(m.group(3)) if m.group(3) else 0xffffffff
            normalized.append('MEM 0x%x 0x%x 0x%x' % (addr, value, mask))
            continue
        m = REG_LINE_RE.match(line)
        if m:
            name  = m.group(1).lower()
            value = parse_hexlike(m.group(2))
            mask  = parse_hexlike(m.group(3)) if m.group(3) else 0xffffffff
            normalized.append('REG %s 0x%x 0x%x' % (name, value, mask))
            continue
        raise ValueError("%s: unrecognized RESULTS line: %r" % (path, line))

    return source, normalized


def find_vprj_files(root):
    vprj_files = []
    for dirpath, _, filenames in os.walk(root):
        for fn in filenames:
            if fn.endswith('.vprj'):
                vprj_files.append(os.path.join(dirpath, fn))
    vprj_files.sort()
    return vprj_files


def subprocess_env():
    env = dict(os.environ)
    if os.path.isdir(TOOLCHAIN_BIN):
        env['PATH'] = TOOLCHAIN_BIN + os.pathsep + env.get('PATH', '')
    return env

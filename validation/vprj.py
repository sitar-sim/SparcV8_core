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

#!/usr/bin/env python3
"""
hexdump_to_memimage.py

Reads GNU readelf --hex-dump output (as produced for one or more ELF
sections, e.g. `readelf --hex-dump=.text --hex-dump=.rodata --hex-dump=.data`)
on stdin, and writes a cleaned-up memory image on stdout in the
"<hex address> <word> <word> <word> <word>" format expected by
MemCore::initializeMemory() (see model/cpp_common_code/MemCore.cpp).

readelf always emits up to 4 words per line, but a section's length need
not be a multiple of 16 bytes, so the last line of a section may have
fewer than 4 -- those are zero-padded here (harmless, since MemCore
initializes all of memory to 0 anyway). Section-header lines ("Hex dump
of section ..."), blank lines, and readelf warnings (e.g. for a section
that doesn't exist in this particular test program) are skipped.
"""
import re
import sys

WORD_RE = re.compile(r'[0-9a-fA-F]{1,8}')


def parse_line(line):
    tokens = line.split()
    if not tokens or not tokens[0].startswith('0x'):
        return None
    try:
        addr = int(tokens[0], 16)
    except ValueError:
        return None

    words = []
    for tok in tokens[1:5]:  # at most 4 data words follow the address
        if WORD_RE.fullmatch(tok):
            words.append(tok)
        else:
            break
    if not words:
        return None
    return addr, words


def main():
    for line in sys.stdin:
        parsed = parse_line(line)
        if parsed is None:
            continue
        addr, words = parsed
        while len(words) < 4:
            words.append('00000000')
        words = [w.zfill(8) for w in words[:4]]
        print('0x%08x %s %s %s %s' % (addr, words[0], words[1], words[2], words[3]))


if __name__ == '__main__':
    main()

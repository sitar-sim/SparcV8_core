#!/usr/bin/env python3
"""apara_as.py: the APARA engine assembler.

    apara_as.py prog.mcode [-o prog.obj] [--aligned prog.aligned.mcode]
                           [--listing prog.lst]

Reads one mcode source file and writes its object file (default: the
source name with .obj in place of .mcode). The object file has one line
per instruction word, "<word index>: <word>" in hexadecimal, as the APARA
reference assembler (mcode_assemble) writes it.

--aligned writes the program after bundle closing, placement and lane
arrangement (what the reference mcode_align prints, in our layout);
--listing writes each word's address and encoding next to its
instruction. Errors are reported as "<file>:<line>: error: <message>";
the exit status is 1 if there was one.

The language and the assembly passes: Ref mcode.py and docs/source/apara/.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mcode


def listing(bundles):
    out = []
    for b in bundles:
        if b.label:
            out.append('%s:' % b.label)
        for lane, i in enumerate(b.instructions):
            w = i.encode() | ((1 << 31) if lane == 0 else 0)
            out.append('%5x: %08x  %s %s' % (b.address + lane, w, '||' if lane == 0 else '  ', i.text()))
    return '\n'.join(out) + '\n'


def main():
    ap = argparse.ArgumentParser(description='Assemble an APARA mcode program.')
    ap.add_argument('source')
    ap.add_argument('-o', '--output', help='object file (default: <source>.obj)')
    ap.add_argument('--aligned', help='also write the placed and arranged program here')
    ap.add_argument('--listing', help='also write a listing here')
    a = ap.parse_args()

    try:
        with open(a.source) as f:
            text = f.read()
    except OSError as e:
        sys.exit('error: %s' % e)
    try:
        bundles, labels, warnings = mcode.assemble(text)
    except mcode.AsmError as e:
        sys.stderr.write('%s:%d: error: %s\n' % (a.source, e.line, e.message))
        return 1
    for line, msg in warnings:
        sys.stderr.write('%s:%d: warning: %s\n' % (a.source, line, msg))

    out = a.output or (os.path.splitext(a.source)[0] + '.obj')
    with open(out, 'w') as f:
        f.write(mcode.format_object(mcode.object_words(bundles)))
    if a.aligned:
        with open(a.aligned, 'w') as f:
            f.write(mcode.format_source(bundles))
    if a.listing:
        with open(a.listing, 'w') as f:
            f.write(listing(bundles))
    return 0


if __name__ == '__main__':
    sys.exit(main())

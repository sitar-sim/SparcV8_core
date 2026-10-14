#!/usr/bin/env python3
"""apara_dis.py: the APARA engine disassembler.

    apara_dis.py prog.obj [-o prog.dis.mcode]

Reads an object file ("<word index>: <word>" lines) and writes it as
mcode source (default: standard output). A bundle starts at each word
with bit 31 set; branch and call targets get labels L_<address>. The
output assembles back to the same object file.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mcode


def main():
    ap = argparse.ArgumentParser(description='Disassemble an APARA object file.')
    ap.add_argument('object')
    ap.add_argument('-o', '--output')
    a = ap.parse_args()
    try:
        with open(a.object) as f:
            words = mcode.read_object(f.read())
    except OSError as e:
        sys.exit('error: %s' % e)
    except mcode.AsmError as e:
        sys.exit('%s:%d: error: %s' % (a.object, e.line, e.message))
    text = mcode.disassemble(words)
    if a.output:
        with open(a.output, 'w') as f:
            f.write(text)
    else:
        sys.stdout.write(text)
    return 0


if __name__ == '__main__':
    sys.exit(main())

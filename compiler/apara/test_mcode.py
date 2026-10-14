#!/usr/bin/env python3
"""Unit tests of the mcode assembler library: run "python3 test_mcode.py".

Encodings are checked against words the APARA reference assembler
(mcode_assemble) produced; the error cases are ones its grammar accepts
silently or with a garbled result.
"""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mcode


def words(src):
    return [w for _, w in mcode.object_words(mcode.assemble(src)[0])]


class Encoding(unittest.TestCase):
    def test_reference_words(self):
        # (source bundle, words from the reference assembler)
        cases = [
            ('|| $set $r1 0 1 ;', [0xd4010001]),
            ('|| + $r1 ($i8) $r0 8 ;', [0x90210408]),
            ('|| $pack 64 $r8 32 $r0 ;', [0xe0086a00]),
            ('|| $slice $r20 31 15 $r8 ;', [0xe5f49e08]),
            ('|| $halt ;', [0xec000000]),
        ]
        for src, expected in cases:
            self.assertEqual(words(src), expected, src)

    def test_lanes(self):
        # a store goes to lane 4, the branch to lane 0, the rest fill in order
        ins = mcode.assemble('l: || + $r1 ($i64) $r1 1  $st ($i64) [$r0 + 0] $r1  '
                             '? ($i64) $r1 == $goto l ;')[0][0].instructions
        self.assertEqual([i.op for i in ins],
                         ['BRANCH', 'ADD', 'NULL', 'NULL', 'STORE', 'NULL', 'NULL', 'NULL'])

    def test_padding(self):
        bundles = mcode.assemble('|| $null ; || $halt $ld ($i64) $r1 [$r0 + 0] ;')[0]
        self.assertEqual([(b.address, len(b.instructions)) for b in bundles],
                         [(0, 1), (1, 1), (2, 2), (4, 4), (8, 8)])

    def test_branch_offset_is_from_its_own_lane(self):
        bundles = mcode.assemble('top: || $null ; || $null $null ? ($i64) $r1 == $goto top ;')[0]
        branch = [i for b in bundles for i in b.instructions if i.op == 'BRANCH'][0]
        self.assertEqual(branch.jump, -8)  # top = 0, the branch is at 8 + lane 0

    def test_disassembly_round_trip(self):
        src = ('a: || $v + $r3 ($vi8) $r1 $r2 $replicate  $dot $accumulate $r4 ($vf16) $r1 $r2 ; '
               '|| $cmov ($i8) $r1 >= ++1 $r5 $r6  $ld ($u128) $r8 [$r1 + $r2 --3]  $call a ; '
               '|| $vreduce ~^ $r9 ($vi16) $r1  $cast ($vi16) $r10 ($vi8) $r1  $set $r12 2 _hbeef ;')
        w = mcode.object_words(mcode.assemble(src)[0])
        again = mcode.object_words(mcode.assemble(mcode.disassemble(w))[0])
        self.assertEqual(w, again)


class Errors(unittest.TestCase):
    def check(self, src, fragment):
        with self.assertRaises(mcode.AsmError) as e:
            mcode.assemble(src)
        self.assertIn(fragment, e.exception.message)

    def test_errors(self):
        self.check('|| + $r40 ($i64) $r0 1 ;', 'no register')
        self.check('|| + $r1 ($i64) $r0 600 ;', 'out of range')
        self.check('|| ? ($i64) $r1 == $goto nowhere ;', 'undefined label')
        self.check('|| + $r1 ($i64) $r0 1  - $r1 ($i64) $r0 1 ;', 'written twice')
        self.check('|| $return  $call $r1 ;', 'at most one branch')
        self.check('|| / $r1 ($i64) $r2 $r3  / $r4 ($i64) $r2 $r3 ;', 'at most one divide')
        self.check('|| $fsqrt $r1 ($f16) $r2 ;', '$fsqrt takes')
        self.check('|| $ld ($u256) $r30 [$r0 + 0] ;', 'past $r31')
        self.check('|| $cast ($vi32) $r1 ($vi8) $r2 ;', 'one step')
        self.check('|| ? ($i64) $r1 > ++2 $goto x ; x: || $halt ;', 'out of range')
        self.check('|| | $r1 ($f32) $r2 $r3 ;', 'floats have only')
        self.check('|| + $r1 ($i64) $r2 $r3', 'not closed')


if __name__ == '__main__':
    unittest.main()

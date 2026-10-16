#!/usr/bin/env python3
"""Unit tests of apcc.py, the APARA C compiler: run "python3 test_apcc.py".

Programs that compile are also assembled (the compiler's output must be
valid mcode); their behavior is tested by validation/apara/c_programs/.
The error cases are the language's documented limits.
"""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import apcc
import mcode


def compile_ok(src, **kw):
    r = apcc.compile_source(src, 'test.c', **kw)
    mcode.assemble(r.mcode)  # must assemble
    return r


class Compiles(unittest.TestCase):
    def test_layout(self):
        r = compile_ok('int8_t a[3]; int64_t b; int32_t c[2][2] = {{1, 2}, {3, 4}}; '
                       'int16_t d[4] __at(0x400); void main(void) {}')
        # each global 8-byte aligned, in order; __at places one
        self.assertEqual(r.symbols, {'a': 0, 'b': 8, 'c': 16, 'd': 0x400})
        # 2x2 int32 = 16 bytes, big-endian, row by row
        self.assertIn('2: 0x0000000100000002', r.data_lines)
        self.assertIn('3: 0x0000000300000004', r.data_lines)

    def test_hex_literals_keep_f_digits(self):
        r = compile_ok('int64_t x; void main(void) { x = 0x7fffffff; }')
        self.assertIn('_h7fff', r.mcode)
        self.assertIn('_hffff', r.mcode)

    def test_dmem_base(self):
        # in a system, DMEM is a window: addresses include its base, the symbols stay offsets
        r = compile_ok('int64_t x; void main(void) { x = 1; }', dmem_base=0x01000000)
        self.assertEqual(r.symbols, {'x': 0})
        self.assertIn('_h100', r.mcode)

    def test_O0_one_instruction_per_bundle(self):
        src = 'int64_t r; void main(void) { int64_t a = 1; int64_t b = 2; r = a + b; }'
        b0 = mcode.assemble(compile_ok(src, optimize=0).mcode)[0]
        b1 = mcode.assemble(compile_ok(src, optimize=1).mcode)[0]
        self.assertTrue(all(sum(i.op != 'NULL' for i in b.instructions) <= 1 for b in b0))
        self.assertLess(len(b1), len(b0))

    def test_nested_calls_are_hoisted(self):
        compile_ok('int64_t f(int64_t x) { return x + 1; } int64_t r; '
                   'void main(void) { r = f(1) + f(2) * 10; }')

    def test_entry_parameters_in_r1(self):
        r = compile_ok('int64_t out[4]; __entry void work(int64_t t, int64_t v) { out[t] = v; }')
        self.assertIn('$r1', r.mcode)
        self.assertIn('$r2', r.mcode)


class Errors(unittest.TestCase):
    def check(self, src, message):
        with self.assertRaises(apcc.CompileError) as e:
            apcc.compile_source(src, 'test.c')
        self.assertIn(message, e.exception.args[0])

    def test_recursion(self):
        self.check('int64_t f(int64_t n) { return f(n - 1); } void main(void) { f(3); }', 'recursion')

    def test_local_array(self):
        self.check('void main(void) { int64_t a[4]; }', 'arrays must be global')

    def test_undefined(self):
        self.check('void main(void) { x = 1; }', 'x is not defined')

    def test_no_entry(self):
        self.check('void f(void) {}', 'no entry function')

    def test_overlap(self):
        self.check('int64_t a[4]; int64_t b __at(0x8); void main(void) {}', 'overlaps')

    def test_call_in_condition_operand(self):
        self.check('int64_t f(int64_t x) { return x; } int64_t r; '
                   'void main(void) { r = 1 && (f(1) + 2); }', 'assigned to a variable first')

    def test_too_many_registers(self):
        decls = ' '.join('int64_t v%d = %d;' % (i, i) for i in range(32))
        self.check('void main(void) { %s }' % decls, 'out of registers')


if __name__ == '__main__':
    unittest.main()

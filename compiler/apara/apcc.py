#!/usr/bin/env python3
"""
apcc.py: a small C compiler for the APARA engine.

    python3 compiler/apara/apcc.py prog.c                 # writes prog.mcode and prog.data
    python3 compiler/apara/apcc.py prog.c -o out.mcode --data out.data --symbols out.sym -O0

Compiles a C subset to mcode, the engine's assembly language (Ref
docs/source/apara/compiler.md for the language, and
compiler/apara/include/apara.h for the intrinsics). The program and its
data are assumed to be in the engine's own IMEM and DMEM already: the
compiler writes the program (.mcode, for apara_as.py), and the initial
DMEM contents of its global arrays (.data, a data file) and their
addresses (.sym).

The language, in brief:
- Types: int8_t .. int64_t, uint8_t .. uint64_t (and char, short, int,
  long, unsigned ...), float (f32), double (f64), void.
- Global variables and 1-D or 2-D arrays live in DMEM, laid out from
  address 0 in declaration order (each 8-byte aligned), or at a fixed
  address with __at(addr). They may have initializers.
- Local variables and parameters are scalars, each kept in a register.
- Statements: declarations, assignments (= += -= *= /= %= &= |= ^= <<= >>=),
  ++/--, if/else, while, do/while, for, break, continue, return, blocks,
  and __asm__("mcode") with %name standing for a variable's register.
- Expressions: the usual arithmetic, bitwise, shift, comparison and
  logical operators, casts, array indexing, &array[i] (a DMEM byte
  address), and calls.
- Functions: no recursion. A function marked __entry is a thread's
  entry point: its parameters arrive in $r1, $r2, ... (set before the
  thread starts), and returning from it halts the thread. Without any
  __entry, main is the entry. Other functions are called with $call.
- #define NAME value (object-like macros), other preprocessor lines ignored.

Limits, by design (it is a teaching compiler): comparisons test the sign
of the difference, so 64-bit operands must differ by less than 2^63;
there is no stack (variables live in registers, at most about 28 at a
time along any call chain); no pointers other than integer addresses.

Code generation: every variable has its own register, expressions use
temporaries, and loops test at the bottom (one branch per iteration,
which the branch predictor learns). With -O1 (the default) a scheduler
packs consecutive independent instructions into one bundle, never two
that depend on each other: the engine's bundle semantics (every
instruction reads the registers as they were before the bundle) then
give the same result as running them one by one. -O0 gives one
instruction per bundle.
"""
import argparse
import os
import re
import struct
import sys

# ----------------------------------------------------------------------
# Types
# ----------------------------------------------------------------------


class CType:
    def __init__(self, kind, bits=64, signed=True):
        self.kind, self.bits, self.signed = kind, bits, signed

    @property
    def is_float(self):
        return self.kind == 'float'

    @property
    def is_int(self):
        return self.kind == 'int'

    @property
    def size(self):
        return self.bits // 8

    def mcode(self):
        if self.is_float:
            return '($f%d)' % self.bits
        return '(%s%d)' % ('$i' if self.signed else '$u', self.bits)

    def __eq__(self, o):
        return isinstance(o, CType) and (self.kind, self.bits, self.signed) == (o.kind, o.bits, o.signed)

    def __repr__(self):
        if self.kind == 'void':
            return 'void'
        if self.is_float:
            return 'float' if self.bits == 32 else 'double'
        return '%sint%d_t' % ('' if self.signed else 'u', self.bits)


VOID = CType('void', 0)
I64, U64 = CType('int', 64, True), CType('int', 64, False)
F32, F64 = CType('float', 32), CType('float', 64)

BASE_TYPES = {
    'int8_t': CType('int', 8), 'int16_t': CType('int', 16), 'int32_t': CType('int', 32), 'int64_t': I64,
    'uint8_t': CType('int', 8, False), 'uint16_t': CType('int', 16, False),
    'uint32_t': CType('int', 32, False), 'uint64_t': U64,
    'char': CType('int', 8), 'short': CType('int', 16), 'int': CType('int', 32), 'long': I64,
    'float': F32, 'double': F64, 'void': VOID,
}
UNSIGNED_OF = {'char': 'uint8_t', 'short': 'uint16_t', 'int': 'uint32_t', 'long': 'uint64_t'}

INTRINSICS = {
    # name: (number of string (mcode type/operator) arguments, number of value arguments)
    '__dot': (1, 2), '__dot_acc': (1, 3),
    '__vadd': (1, 2), '__vsub': (1, 2), '__vmul': (1, 2),
    '__vadd_rep': (1, 2), '__vsub_rep': (1, 2), '__vmul_rep': (1, 2),
    '__vreduce': (2, 1), '__fsqrt': (0, 1), '__slice': (0, 3),
    '__ld64': (0, 1), '__st64': (0, 2), '__halt': (0, 0),
}
VECTOR_TYPES = {'v%s%d' % (k, b) for k in 'iuf' for b in (4, 8, 16, 32)}


class CompileError(Exception):
    def __init__(self, line, message):
        Exception.__init__(self, '%d: %s' % (line, message))
        self.line, self.message = line, message


# ----------------------------------------------------------------------
# Lexer and a minimal preprocessor
# ----------------------------------------------------------------------

TOKEN_RE = re.compile(r'''
    (?P<ws>[ \t\r]+) |
    (?P<nl>\n) |
    (?P<comment>//[^\n]*|/\*.*?\*/) |
    (?P<pp>\#[^\n]*) |
    (?P<num>(?:0[xX][0-9a-fA-F]+|(?:\d+\.\d*|\.\d+|\d+)(?:[eE][+-]?\d+)?)[uUlLfF]*) |
    (?P<str>"(?:[^"\\\n]|\\.)*") |
    (?P<id>[A-Za-z_]\w*) |
    (?P<op><<=|>>=|\+\+|--|\+=|-=|\*=|/=|%=|&=|\|=|\^=|<<|>>|<=|>=|==|!=|&&|\|\||[-+*/%&|^~!<>=?:;,(){}\[\]])
''', re.S | re.X)


class Tok:
    def __init__(self, kind, text, line):
        self.kind, self.text, self.line = kind, text, line

    def __repr__(self):
        return '%s(%r)' % (self.kind, self.text)


def tokenize(text):
    toks, line, pos, defines = [], 1, 0, {}
    while pos < len(text):
        m = TOKEN_RE.match(text, pos)
        if not m:
            raise CompileError(line, 'unexpected character %r' % text[pos])
        kind, s = m.lastgroup, m.group()
        pos = m.end()
        if kind == 'nl':
            line += 1
        elif kind == 'comment':
            line += s.count('\n')
        elif kind == 'pp':
            d = re.match(r'#\s*define\s+([A-Za-z_]\w*)\s+(.*)$', s)
            if d:
                body = [t for t in tokenize_plain(d.group(2), line)]
                defines[d.group(1)] = body
        elif kind != 'ws':
            if kind == 'id' and s in defines:
                for t in defines[s]:
                    toks.append(Tok(t.kind, t.text, line))
            else:
                toks.append(Tok(kind, s, line))
    return toks


def tokenize_plain(text, line):
    out = []
    for m in TOKEN_RE.finditer(text):
        if m.lastgroup in ('num', 'str', 'id', 'op'):
            out.append(Tok(m.lastgroup, m.group(), line))
    return out


# ----------------------------------------------------------------------
# AST
# ----------------------------------------------------------------------


class Node:
    def __init__(self, kind, line, **kw):
        self.kind, self.line = kind, line
        self.__dict__.update(kw)


# ----------------------------------------------------------------------
# Parser
# ----------------------------------------------------------------------

BINARY_PRECEDENCE = [
    ['||'], ['&&'], ['|'], ['^'], ['&'], ['==', '!='], ['<', '>', '<=', '>='],
    ['<<', '>>'], ['+', '-'], ['*', '/', '%'],
]
ASSIGN_OPS = ('=', '+=', '-=', '*=', '/=', '%=', '&=', '|=', '^=', '<<=', '>>=')


class Parser:
    def __init__(self, toks):
        self.toks, self.i = toks, 0

    def peek(self, k=0):
        j = self.i + k
        return self.toks[j] if j < len(self.toks) else None

    def line(self):
        t = self.peek()
        return t.line if t else (self.toks[-1].line if self.toks else 0)

    def next(self, what='a token'):
        t = self.peek()
        if t is None:
            raise CompileError(self.line(), 'expected %s, found the end of the file' % what)
        self.i += 1
        return t

    def accept(self, text):
        t = self.peek()
        if t is not None and t.text == text and t.kind != 'str':
            self.i += 1
            return True
        return False

    def expect(self, text):
        t = self.next(repr(text))
        if t.text != text:
            raise CompileError(t.line, 'expected %r, found %r' % (text, t.text))
        return t

    def ident(self):
        t = self.next('a name')
        if t.kind != 'id':
            raise CompileError(t.line, 'expected a name, found %r' % t.text)
        return t.text

    def at_type(self):
        t = self.peek()
        return t is not None and t.kind == 'id' and (t.text in BASE_TYPES or t.text in ('unsigned', 'signed', 'const'))

    def type_name(self):
        while self.accept('const'):
            pass
        line = self.line()
        if self.accept('unsigned'):
            t = self.peek()
            if t is not None and t.text in UNSIGNED_OF:
                self.next()
                if t.text == 'long':
                    self.accept('long')
                return BASE_TYPES[UNSIGNED_OF[t.text]]
            return BASE_TYPES['uint32_t']
        if self.accept('signed'):
            t = self.peek()
            if t is not None and t.text in UNSIGNED_OF:
                self.next()
                return BASE_TYPES[t.text]
            return BASE_TYPES['int']
        name = self.ident()
        if name not in BASE_TYPES:
            raise CompileError(line, 'unknown type %s' % name)
        if name == 'long':
            self.accept('long')
        while self.accept('const'):
            pass
        return BASE_TYPES[name]

    # -- top level --------------------------------------------------------

    def program(self):
        globals_, functions = [], []
        while self.peek() is not None:
            line = self.line()
            entry = self.accept('__entry')
            static = self.accept('static')
            entry = entry or self.accept('__entry')
            t = self.type_name()
            name = self.ident()
            if self.accept('('):
                functions.append(self.function(t, name, entry, line))
            else:
                if entry:
                    raise CompileError(line, '__entry marks a function')
                globals_ += self.global_decl(t, name, line)
            del static
        return globals_, functions

    def function(self, rtype, name, entry, line):
        params = []
        if self.peek() is not None and self.peek().text == 'void' and \
                self.peek(1) is not None and self.peek(1).text == ')':
            self.next()
        if not self.accept(')'):
            while True:
                pt = self.type_name()
                params.append((pt, self.ident()))
                if self.accept(')'):
                    break
                self.expect(',')
        if len(params) > 8:
            raise CompileError(line, '%s: at most 8 parameters' % name)
        body = self.block()
        return Node('function', line, rtype=rtype, name=name, params=params, body=body, entry=entry)

    def global_decl(self, t, name, line):
        decls = []
        while True:
            dims = []
            while self.accept('['):
                dims.append(self.const_int())
                self.expect(']')
            at = None
            if self.accept('__at'):
                self.expect('(')
                at = self.const_int()
                self.expect(')')
            init = None
            if self.accept('='):
                init = self.initializer()
            decls.append(Node('global', line, ctype=t, name=name, dims=dims, at=at, init=init))
            if self.accept(';'):
                return decls
            self.expect(',')
            name = self.ident()

    def initializer(self):
        if self.accept('{'):
            items = []
            while not self.accept('}'):
                items.append(self.initializer())
                if not self.accept(','):
                    self.expect('}')
                    break
            return items
        return self.const_value()

    def const_value(self):
        e = self.expr()
        v = const_eval(e)
        if v is None:
            raise CompileError(e.line, 'an initializer must be a constant')
        return v

    def const_int(self):
        e = self.conditional()
        v = const_eval(e)
        if not isinstance(v, int):
            raise CompileError(e.line, 'expected an integer constant')
        return v

    # -- statements -------------------------------------------------------

    def block(self):
        line = self.expect('{').line
        stmts = []
        while not self.accept('}'):
            stmts.append(self.statement())
        return Node('block', line, stmts=stmts)

    def statement(self):
        t = self.peek()
        line = self.line()
        if t is None:
            raise CompileError(line, 'unexpected end of file')
        if t.text == '{':
            return self.block()
        if self.at_type():
            ctype = self.type_name()
            decls = []
            while True:
                name = self.ident()
                if self.peek() is not None and self.peek().text == '[':
                    raise CompileError(line, 'arrays must be global (they live in DMEM)')
                init = self.expr() if self.accept('=') else None
                decls.append(Node('local', line, ctype=ctype, name=name, init=init))
                if self.accept(';'):
                    break
                self.expect(',')
            return Node('block', line, stmts=decls, scope=False)
        if self.accept('if'):
            self.expect('(')
            cond = self.expr()
            self.expect(')')
            then = self.statement()
            other = self.statement() if self.accept('else') else None
            return Node('if', line, cond=cond, then=then, other=other)
        if self.accept('while'):
            self.expect('(')
            cond = self.expr()
            self.expect(')')
            return Node('for', line, init=None, cond=cond, step=None, body=self.statement(), test_first=True)
        if self.accept('do'):
            body = self.statement()
            self.expect('while')
            self.expect('(')
            cond = self.expr()
            self.expect(')')
            self.expect(';')
            return Node('for', line, init=None, cond=cond, step=None, body=body, test_first=False)
        if self.accept('for'):
            self.expect('(')
            init = None
            if not self.accept(';'):
                init = self.statement() if self.at_type() else Node('expr', line, expr=self.expr())
                if init.kind == 'expr':
                    self.expect(';')
            cond = None if self.peek().text == ';' else self.expr()
            self.expect(';')
            step = None if self.peek().text == ')' else self.expr()
            self.expect(')')
            return Node('for', line, init=init, cond=cond, step=step, body=self.statement(), test_first=True)
        if self.accept('break'):
            self.expect(';')
            return Node('break', line)
        if self.accept('continue'):
            self.expect(';')
            return Node('continue', line)
        if self.accept('return'):
            value = None if self.peek().text == ';' else self.expr()
            self.expect(';')
            return Node('return', line, value=value)
        if self.accept('__asm__') or self.accept('asm'):
            self.expect('(')
            parts = []
            while self.peek().kind == 'str':
                parts.append(unquote(self.next().text))
            self.expect(')')
            self.expect(';')
            return Node('asm', line, text=''.join(parts))
        if self.accept(';'):
            return Node('block', line, stmts=[])
        e = self.expr()
        self.expect(';')
        return Node('expr', line, expr=e)

    # -- expressions ------------------------------------------------------

    def expr(self):
        return self.assignment()

    def assignment(self):
        left = self.conditional()
        t = self.peek()
        if t is not None and t.text in ASSIGN_OPS:
            self.next()
            if left.kind not in ('var', 'index'):
                raise CompileError(t.line, 'cannot assign to this expression')
            return Node('assign', t.line, op=t.text, target=left, value=self.assignment())
        return left

    def conditional(self):
        c = self.binary(0)
        if self.accept('?'):
            a = self.expr()
            self.expect(':')
            b = self.conditional()
            return Node('ternary', c.line, cond=c, a=a, b=b)
        return c

    def binary(self, level):
        if level == len(BINARY_PRECEDENCE):
            return self.unary()
        left = self.binary(level + 1)
        while True:
            t = self.peek()
            if t is None or t.kind != 'op' or t.text not in BINARY_PRECEDENCE[level]:
                return left
            self.next()
            right = self.binary(level + 1)
            left = Node('binary', t.line, op=t.text, left=left, right=right)

    def unary(self):
        t = self.peek()
        line = self.line()
        if t is not None and t.kind == 'op':
            if t.text in ('-', '~', '!', '+'):
                self.next()
                e = self.unary()
                return e if t.text == '+' else Node('unary', line, op=t.text, e=e)
            if t.text in ('++', '--'):
                self.next()
                return Node('incdec', line, op=t.text, target=self.unary(), prefix=True)
            if t.text == '&':
                self.next()
                e = self.unary()
                if e.kind not in ('index', 'var'):
                    raise CompileError(line, '& applies to a global array element')
                return Node('addr', line, e=e)
            if t.text == '(' and self.peek(1) is not None and self.peek(1).kind == 'id' and \
                    (self.peek(1).text in BASE_TYPES or self.peek(1).text in ('unsigned', 'signed', 'const')):
                self.next()
                ctype = self.type_name()
                self.expect(')')
                return Node('cast', line, ctype=ctype, e=self.unary())
        return self.postfix()

    def postfix(self):
        e = self.primary()
        while True:
            t = self.peek()
            if t is None:
                return e
            if t.text == '[':
                idx = []
                while self.accept('['):
                    idx.append(self.expr())
                    self.expect(']')
                if e.kind != 'var':
                    raise CompileError(t.line, 'only a global array can be indexed')
                e = Node('index', t.line, name=e.name, idx=idx)
            elif t.text in ('++', '--') and t.kind == 'op':
                self.next()
                e = Node('incdec', t.line, op=t.text, target=e, prefix=False)
            else:
                return e

    def primary(self):
        t = self.next('an expression')
        if t.kind == 'num':
            return Node('num', t.line, value=parse_number(t.text), text=t.text)
        if t.kind == 'str':
            return Node('str', t.line, value=unquote(t.text))
        if t.kind == 'id':
            if self.accept('('):
                args = []
                if not self.accept(')'):
                    while True:
                        args.append(self.expr())
                        if self.accept(')'):
                            break
                        self.expect(',')
                return Node('call', t.line, name=t.text, args=args)
            return Node('var', t.line, name=t.text)
        if t.text == '(':
            e = self.expr()
            self.expect(')')
            return e
        raise CompileError(t.line, 'unexpected %r' % t.text)


def unquote(s):
    return bytes(s[1:-1], 'utf-8').decode('unicode_escape')


def parse_number(text):
    if text.lower().startswith('0x'):  # f is a hex digit here, not a suffix
        t = text.rstrip('uUlL')
        return ('int', int(t, 16), 'u' in text[len(t):].lower())
    t = text.rstrip('uUlLfF')
    suffix = text[len(t):].lower()
    if '.' in t or 'e' in t.lower() or 'f' in suffix:
        return ('float', float(t), 'f' in suffix)
    return ('int', int(t, 10), 'u' in suffix)


def const_eval(e):
    """A constant expression's value (int or float), or None."""
    if e.kind == 'num':
        return e.value[1]
    if e.kind == 'unary':
        v = const_eval(e.e)
        if v is None:
            return None
        if e.op == '-':
            return -v
        if e.op == '~' and isinstance(v, int):
            return ~v
        if e.op == '!':
            return int(not v)
        return None
    if e.kind == 'cast':
        v = const_eval(e.e)
        if v is None:
            return None
        return float(v) if e.ctype.is_float else int(v)
    if e.kind == 'binary':
        a, b = const_eval(e.left), const_eval(e.right)
        if a is None or b is None:
            return None
        ops = {'+': lambda: a + b, '-': lambda: a - b, '*': lambda: a * b,
               '/': lambda: (int(a / b) if isinstance(a, int) and isinstance(b, int) else a / b),
               '%': lambda: a - int(a / b) * b, '<<': lambda: a << b, '>>': lambda: a >> b,
               '&': lambda: a & b, '|': lambda: a | b, '^': lambda: a ^ b,
               '<': lambda: int(a < b), '>': lambda: int(a > b), '<=': lambda: int(a <= b),
               '>=': lambda: int(a >= b), '==': lambda: int(a == b), '!=': lambda: int(a != b)}
        return ops[e.op]() if e.op in ops else None
    return None


# ----------------------------------------------------------------------
# Code generation
# ----------------------------------------------------------------------


class Ins:
    """One mcode instruction, with what the scheduler needs to know."""

    def __init__(self, text, dst=(), src=(), kind='alu', line=0):
        self.text, self.line = text, line
        self.dst, self.src = set(r for r in dst if r), set(r for r in src if r)
        self.kind = kind  # alu, mem, store, div, ctl, label

    def __repr__(self):
        return self.text


class Operand:
    def __init__(self, reg, ctype, temp):
        self.reg, self.ctype, self.temp = reg, ctype, temp


def R(n):
    return '$r%d' % n


def float_bits(v, bits):
    if bits == 32:
        return struct.unpack('>I', struct.pack('>f', v))[0]
    return struct.unpack('>Q', struct.pack('>d', v))[0]


class Function:
    def __init__(self, node):
        self.node = node
        self.name = node.name
        self.vars = {}       # name -> (reg, ctype)
        self.ret_reg = None
        self.calls = set()


class Compiler:
    def __init__(self, globals_, functions, optimize=1, dmem_base=0):
        self.optimize = optimize
        self.dmem_base = dmem_base
        self.code = []      # Ins list (labels are kind 'label')
        self.label_count = 0
        self.globals = {}
        self.data = {}      # dword index -> value
        self.layout(globals_)
        self.functions = {f.name: Function(f) for f in functions}
        if len(self.functions) != len(functions):
            raise CompileError(0, 'a function is defined twice')
        entries = [f for f in functions if f.entry]
        if not entries:
            if 'main' not in self.functions:
                raise CompileError(0, 'no entry function (__entry, or main)')
            entries = [self.functions['main'].node]
        self.entries = [f.name for f in entries]
        for f in functions:
            self.hoisted = 0
            hoist_calls(f.body, self)
        self.allocate()

    # -- data layout ------------------------------------------------------

    def layout(self, globals_):
        addr = 0
        used = []
        for g in globals_:
            if g.name in self.globals:
                raise CompileError(g.line, '%s is defined twice' % g.name)
            if g.ctype == VOID:
                raise CompileError(g.line, 'a variable cannot be void')
            n = 1
            for d in g.dims:
                if d <= 0:
                    raise CompileError(g.line, 'an array size must be positive')
                n *= d
            size = n * g.ctype.size
            base = g.at if g.at is not None else addr
            if base % 8:
                raise CompileError(g.line, '__at(0x%x) is not a multiple of 8' % base)
            if base + size > 65536:
                raise CompileError(g.line, '%s does not fit in DMEM (64 KB)' % g.name)
            for (b, s, name) in used:
                if base < b + s and b < base + size:
                    raise CompileError(g.line, '%s overlaps %s in DMEM' % (g.name, name))
            used.append((base, size, g.name))
            if g.at is None:
                addr = (base + size + 7) & ~7
            self.globals[g.name] = (base + self.dmem_base, g.ctype, g.dims)
            if g.init is not None:
                values = flatten(g.init) if isinstance(g.init, list) else [g.init]
                if len(values) > n:
                    raise CompileError(g.line, 'too many initializers for %s' % g.name)
                for k, v in enumerate(values):
                    self.put_data(base + k * g.ctype.size, g.ctype, v)

    def put_data(self, addr, ctype, v):
        """addr: a DMEM byte offset."""
        if ctype.is_float:
            bits = float_bits(float(v), ctype.bits)
        else:
            bits = int(v) & ((1 << ctype.bits) - 1)
        index, offset = addr // 8, addr % 8
        shift = (8 - offset - ctype.size) * 8  # big-endian: lower address, higher bits
        word = self.data.get(index, 0)
        mask = ((1 << ctype.bits) - 1) << shift
        self.data[index] = (word & ~mask) | (bits << shift)

    # -- register allocation ----------------------------------------------

    def allocate(self):
        """Every variable gets a register for the function's whole life,
        disjoint from those of every function on a call chain through it
        (there is no stack). Entry functions' parameters are $r1, $r2..."""
        for f in self.functions.values():
            f.locals = []
            collect_locals(f.node.body, f.locals)
            find_calls(f.node.body, f.calls)
            for c in f.calls:
                if c not in self.functions and c not in INTRINSICS:
                    raise CompileError(f.node.line, '%s calls %s, which is not defined' % (f.name, c))
            f.calls &= set(self.functions)
        # ancestors, and a recursion check
        order = []
        state = {}

        def visit(name, path):
            if state.get(name) == 'done':
                return
            if state.get(name) == 'active':
                raise CompileError(self.functions[name].node.line,
                                   'recursion (%s) is not supported' % ' -> '.join(path + [name]))
            state[name] = 'active'
            for c in sorted(self.functions[name].calls):
                visit(c, path + [name])
            state[name] = 'done'
            order.append(name)
        for name in self.functions:
            visit(name, [])
        order.reverse()  # callers before callees
        ancestors = {n: set() for n in self.functions}
        for n in order:
            for c in self.functions[n].calls:
                ancestors[c] |= ancestors[n] | {n}
        self.ancestors = ancestors
        for n in order:
            f = self.functions[n]
            taken = set()
            for a in ancestors[n]:
                taken |= {r for r, _ in self.functions[a].vars.values()}
            is_entry = n in self.entries
            if is_entry and ancestors[n]:
                raise CompileError(f.node.line, 'an entry function (%s) cannot be called' % n)
            free = [r for r in range(1, 32) if r not in taken]

            def grab(what):
                if not free:
                    raise CompileError(f.node.line, 'out of registers in %s (at %s): use fewer variables' % (n, what))
                return free.pop(0)
            if is_entry:
                for k, (pt, pn) in enumerate(f.node.params):
                    f.vars[pn] = (k + 1, pt)
                    free.remove(k + 1)
            else:
                for pt, pn in f.node.params:
                    f.vars[pn] = (grab(pn), pt)
                if f.node.rtype != VOID:
                    f.ret_reg = grab('the return value')
            for loc in f.locals:
                if loc.name in f.vars:
                    raise CompileError(loc.line, '%s is declared twice in %s (one name per function)' % (loc.name, n))
                if loc.ctype == VOID:
                    raise CompileError(loc.line, 'a variable cannot be void')
                f.vars[loc.name] = (grab(loc.name), loc.ctype)
            # temporaries: anything the function and its callers do not hold
            f.temps = [r for r in range(1, 32) if r not in taken and r not in {v for v, _ in f.vars.values()}]

    # -- emission helpers -------------------------------------------------

    def emit(self, text, dst=(), src=(), kind='alu'):
        self.code.append(Ins(text, dst, src, kind, self.cur_line))

    def new_label(self, what):
        self.label_count += 1
        return 'L%d_%s' % (self.label_count, what)

    def place_label(self, name):
        self.code.append(Ins(name, kind='label'))

    def temp(self, ctype):
        for r in self.f.temps:
            if r not in self.busy:
                self.busy.add(r)
                return Operand(r, ctype, True)
        raise CompileError(self.cur_line, 'expression too complex: out of temporary registers')

    def free(self, op):
        if op is not None and op.temp:
            self.busy.discard(op.reg)

    def jump(self, label):
        self.emit('? ($i64) $r0 == $goto %s' % label, kind='ctl')

    def load_const(self, value, ctype, op=None):
        op = op or self.temp(ctype)
        if ctype.is_float:
            bits = float_bits(float(value), ctype.bits)
        else:
            bits = int(value) & ((1 << 64) - 1)
            signed = bits - (1 << 64) if bits >> 63 else bits
            if -512 <= signed <= 511:
                self.emit('+ %s ($i64) $r0 %d' % (R(op.reg), signed), dst=[op.reg])
                return op
        pieces = [(k, (bits >> (16 * k)) & 0xFFFF) for k in range(4) if (bits >> (16 * k)) & 0xFFFF]
        if not pieces:
            self.emit('+ %s ($i64) $r0 0' % R(op.reg), dst=[op.reg])
            return op
        k, v = pieces[0]
        self.emit('$set %s %d _h%x' % (R(op.reg), 2 * k, v), dst=[op.reg])
        for k, v in pieces[1:]:
            t = self.temp(I64)
            self.emit('$set %s %d _h%x' % (R(t.reg), 2 * k, v), dst=[t.reg])
            self.emit('| %s ($i64) %s %s' % (R(op.reg), R(op.reg), R(t.reg)), dst=[op.reg], src=[op.reg, t.reg])
            self.free(t)
        return op

    def move(self, dst_reg, src_reg):
        if dst_reg != src_reg:
            self.emit('+ %s ($i64) %s $r0' % (R(dst_reg), R(src_reg)), dst=[dst_reg], src=[src_reg])

    # -- types ------------------------------------------------------------

    def arith_type(self, a, b):
        if a.is_float or b.is_float:
            return F64 if (a == F64 or b == F64) else F32
        return U64 if (not a.signed and a.bits == 64) or (not b.signed and b.bits == 64) else I64

    def convert(self, op, to):
        """op's value as type `to` (a new temp unless no change is needed)."""
        fr = op.ctype
        if fr == to:
            return op
        if fr.is_float == to.is_float and (not to.is_float or fr.bits == to.bits):
            if to.is_int and to.bits < 64:
                return self.normalize(op, to)
            return Operand(op.reg, to, op.temp)
        t = self.temp(to)
        src = fr if fr.is_float else (I64 if fr.signed else U64)
        dst = to if to.is_float else (I64 if to.signed else U64)
        self.emit('$cast %s %s %s %s' % (dst.mcode(), R(t.reg), src.mcode(), R(op.reg)), dst=[t.reg], src=[op.reg])
        self.free(op)
        if to.is_int and to.bits < 64:
            return self.normalize(t, to)
        return t

    def normalize(self, op, to):
        """Wrap a 64-bit integer to `to`'s width, sign- or zero-extended."""
        shift = 64 - to.bits
        t = op if op.temp else self.temp(to)
        self.emit('<< %s ($i64) %s %d' % (R(t.reg), R(op.reg), shift), dst=[t.reg], src=[op.reg])
        self.emit('>> %s %s %s %d' % (R(t.reg), '($i64)' if to.signed else '($u64)', R(t.reg), shift),
                  dst=[t.reg], src=[t.reg])
        return Operand(t.reg, to, True)

    # -- expressions ------------------------------------------------------

    def lookup(self, name, line):
        if name in self.f.vars:
            return self.f.vars[name]
        raise CompileError(line, '%s is not a variable here' % name)

    def gen(self, e, want=None):
        """Evaluates e. Returns an Operand (a temp, or a variable's own
        register, which the caller must not modify)."""
        self.cur_line = e.line
        k = e.kind
        if k == 'num':
            kind, v, flag = e.value
            if kind == 'float':
                return self.load_const(v, F32 if flag else F64)
            return self.load_const(v, U64 if flag else I64)
        if k == 'var':
            if e.name in self.f.vars:
                reg, ct = self.f.vars[e.name]
                return Operand(reg, ct, False)
            if e.name in self.globals:
                base, ct, dims = self.globals[e.name]
                if dims:  # an array name is its address
                    return self.load_const(base, I64)
                return self.load_global(base, ct, None)
            raise CompileError(e.line, '%s is not defined' % e.name)
        if k == 'index':
            base, ct, idx = self.element(e)
            return self.load_global(base, ct, idx)
        if k == 'addr':
            if e.e.kind == 'var':
                if e.e.name not in self.globals:
                    raise CompileError(e.line, '& applies to globals only')
                return self.load_const(self.globals[e.e.name][0], I64)
            base, ct, idx = self.element(e.e)
            if idx is None:
                return self.load_const(base, I64)
            b = self.load_const(base, I64)
            self.emit('+ %s ($i64) %s %s' % (R(b.reg), R(b.reg), R(idx.reg)), dst=[b.reg], src=[b.reg, idx.reg])
            self.free(idx)
            return b
        if k == 'cast':
            return self.convert(self.gen(e.e), e.ctype)
        if k == 'unary':
            if e.op == '!':
                return self.bool_value(e)
            a = self.gen(e.e)
            ct = a.ctype if a.ctype.is_float else (I64 if a.ctype.signed or a.ctype.bits < 64 else U64)
            t = self.temp(ct)
            if e.op == '-':
                self.emit('- %s %s $r0 %s' % (R(t.reg), ct.mcode() if ct.is_float else '($i64)', R(a.reg)),
                          dst=[t.reg], src=[a.reg])
            else:  # ~
                if ct.is_float:
                    raise CompileError(e.line, '~ needs an integer')
                self.emit('~| %s ($i64) %s $r0' % (R(t.reg), R(a.reg)), dst=[t.reg], src=[a.reg])
            self.free(a)
            return t
        if k == 'binary':
            if e.op in ('<', '>', '<=', '>=', '==', '!=', '&&', '||'):
                return self.bool_value(e)
            return self.binary(e.op, e.left, e.right, e.line)
        if k == 'assign':
            return self.assign(e)
        if k == 'incdec':
            one = Node('num', e.line, value=('int', 1, False))
            if e.prefix:
                return self.assign(Node('assign', e.line, op='+=' if e.op == '++' else '-=', target=e.target, value=one))
            old = self.gen(e.target)
            keep = self.temp(old.ctype)
            self.move(keep.reg, old.reg)
            self.free(old)
            self.free(self.assign(Node('assign', e.line, op='+=' if e.op == '++' else '-=', target=e.target, value=one)))
            return keep
        if k == 'ternary':
            out = self.temp(I64)
            l_else, l_end = self.new_label('else'), self.new_label('end')
            self.branch(e.cond, l_else, False)
            a = self.gen(e.a)
            self.move(out.reg, a.reg)
            out.ctype = a.ctype
            self.free(a)
            self.jump(l_end)
            self.place_label(l_else)
            b = self.gen(e.b)
            if b.ctype.is_float != a.ctype.is_float:
                raise CompileError(e.line, 'both sides of ?: must be integers, or both floats')
            self.move(out.reg, b.reg)
            self.free(b)
            self.place_label(l_end)
            return out
        if k == 'call':
            return self.call(e)
        if k == 'str':
            raise CompileError(e.line, 'a string is only an intrinsic\'s type or operator argument')
        raise CompileError(e.line, 'cannot compile %s' % k)

    def element(self, e):
        """(base address, element type, byte-offset operand or None) of a global array element."""
        if e.name not in self.globals:
            raise CompileError(e.line, '%s is not a global array' % e.name)
        base, ct, dims = self.globals[e.name]
        if len(e.idx) != len(dims):
            raise CompileError(e.line, '%s has %d dimension(s)' % (e.name, len(dims)))
        consts = [const_eval(i) for i in e.idx]
        if all(isinstance(c, int) for c in consts):
            flat = 0
            for c, d in zip(consts, dims):
                flat = flat * d + c
            return base + flat * ct.size, ct, None
        off = None
        shift = {1: 0, 2: 1, 4: 2, 8: 3}[ct.size]
        if len(e.idx) == 1:
            v = self.convert(self.gen(e.idx[0]), I64)
            if shift == 0:
                return base, ct, v if v.temp else self.copy(v)
            t = v if v.temp else self.temp(I64)
            self.emit('<< %s ($i64) %s %d' % (R(t.reg), R(v.reg), shift), dst=[t.reg], src=[v.reg])
            return base, ct, t
        for n, (i, d) in enumerate(zip(e.idx, dims)):
            v = self.convert(self.gen(i), I64)
            if off is None:
                off = v if v.temp else self.copy(v)
            else:
                if d & (d - 1) == 0:
                    self.emit('<< %s ($i64) %s %d' % (R(off.reg), R(off.reg), d.bit_length() - 1), dst=[off.reg], src=[off.reg])
                elif d <= 511:
                    self.emit('* %s ($i64) %s %d' % (R(off.reg), R(off.reg), d), dst=[off.reg], src=[off.reg])
                else:
                    dd = self.load_const(d, I64)
                    self.emit('* %s ($i64) %s %s' % (R(off.reg), R(off.reg), R(dd.reg)), dst=[off.reg], src=[off.reg, dd.reg])
                    self.free(dd)
                self.emit('+ %s ($i64) %s %s' % (R(off.reg), R(off.reg), R(v.reg)), dst=[off.reg], src=[off.reg, v.reg])
                self.free(v)
        if shift:
            self.emit('<< %s ($i64) %s %d' % (R(off.reg), R(off.reg), shift), dst=[off.reg], src=[off.reg])
        return base, ct, off

    def copy(self, op):
        t = self.temp(op.ctype)
        self.move(t.reg, op.reg)
        return t

    def mem_type(self, ct):
        if ct.is_float:
            return '($u%d)' % ct.bits  # the bits, zero-extended
        return ct.mcode()

    def address_operands(self, base, idx):
        """(rs1 register, '+ ...' text, srcs, temps to free) for a load/store."""
        if idx is None:
            if -512 <= base <= 511:
                return '[$r0 + %d]' % base, [], []
            b = self.load_const(base, I64)
            return '[%s + 0]' % R(b.reg), [b.reg], [b]
        if -512 <= base <= 511:
            return '[%s + %d]' % (R(idx.reg), base), [idx.reg], [idx]
        b = self.load_const(base, I64)
        return '[%s + %s]' % (R(b.reg), R(idx.reg)), [b.reg, idx.reg], [b, idx]

    def load_global(self, base, ct, idx):
        addr, srcs, temps = self.address_operands(base, idx)
        t = self.temp(ct)
        self.emit('$ld %s %s %s' % (self.mem_type(ct), R(t.reg), addr), dst=[t.reg], src=srcs, kind='mem')
        for x in temps:
            self.free(x)
        return t

    def store_global(self, base, ct, idx, value):
        addr, srcs, temps = self.address_operands(base, idx)
        self.emit('$st %s %s %s' % (self.mem_type(ct), addr, R(value.reg)), src=srcs + [value.reg], kind='store')
        for x in temps:
            self.free(x)

    def small_int(self, e):
        v = const_eval(e)
        if isinstance(v, int) and -512 <= v <= 511 and e.kind in ('num', 'unary'):
            return v
        return None

    def binary(self, op, left, right, line, dest=None):
        a = self.gen(left)
        imm = self.small_int(right)
        if imm is not None and (a.ctype.is_int and op in ('+', '-', '*', '|', '&', '^', '<<', '>>')
                                and not (op in ('<<', '>>') and not 0 <= imm < 64)):
            ct = I64 if (a.ctype.signed or a.ctype.bits < 64) else U64
            t = dest if dest is not None else (a if a.temp else self.temp(ct))
            tc = '($u64)' if (ct == U64 and op == '>>') else '($i64)'
            self.emit('%s %s %s %s %d' % (op, R(t.reg), tc, R(a.reg), imm), dst=[t.reg], src=[a.reg])
            if a is not t:
                self.free(a)
            return Operand(t.reg, ct, t.temp)
        b = self.gen(right)
        ct = self.arith_type(a.ctype, b.ctype)
        if ct.is_float and op in ('%', '&', '|', '^', '<<', '>>'):
            raise CompileError(line, '%s needs integers' % op)
        if op in ('<<', '>>'):
            ct = I64 if (a.ctype.signed or a.ctype.bits < 64) else U64
            a = self.convert(a, ct) if a.ctype.is_float else a
        else:
            a, b = self.convert(a, ct), self.convert(b, ct)
        if dest is not None:
            t = dest
        else:
            t = a if a.temp else (b if b.temp and op not in ('-', '/', '%', '<<', '>>') else self.temp(ct))
            if t is b and op in ('-', '/', '%', '<<', '>>'):
                t = self.temp(ct)
        tc = ct.mcode() if ct.is_float else ('($u64)' if ct == U64 and op in ('/', '%', '>>') else '($i64)')
        if op == '%':
            q = self.temp(ct)
            self.emit('/ %s %s %s %s' % (R(q.reg), tc, R(a.reg), R(b.reg)), dst=[q.reg], src=[a.reg, b.reg], kind='div')
            self.emit('* %s ($i64) %s %s' % (R(q.reg), R(q.reg), R(b.reg)), dst=[q.reg], src=[q.reg, b.reg])
            self.emit('- %s ($i64) %s %s' % (R(t.reg), R(a.reg), R(q.reg)), dst=[t.reg], src=[a.reg, q.reg])
            self.free(q)
        else:
            sym = op
            self.emit('%s %s %s %s %s' % (sym, R(t.reg), tc, R(a.reg), R(b.reg)), dst=[t.reg], src=[a.reg, b.reg],
                      kind='div' if op == '/' else 'alu')
        for x in (a, b):
            if x.reg != t.reg:
                self.free(x)
        return Operand(t.reg, ct, t.temp)

    def compare(self, e):
        """For a relational e: (difference operand, its test type, condition)."""
        a = self.gen(e.left)
        imm = self.small_int(e.right)
        if imm is not None and a.ctype.is_int:
            t = a if a.temp else self.temp(I64)
            self.emit('- %s ($i64) %s %d' % (R(t.reg), R(a.reg), imm), dst=[t.reg], src=[a.reg])
            if a is not t:
                self.free(a)
            return t, '($i64)', e.op
        b = self.gen(e.right)
        ct = self.arith_type(a.ctype, b.ctype)
        a, b = self.convert(a, ct), self.convert(b, ct)
        t = self.temp(ct)
        tc = ct.mcode() if ct.is_float else '($i64)'
        self.emit('- %s %s %s %s' % (R(t.reg), tc, R(a.reg), R(b.reg)), dst=[t.reg], src=[a.reg, b.reg])
        self.free(a)
        self.free(b)
        return t, tc, e.op

    def bool_value(self, e):
        """0 or 1."""
        out = self.temp(I64)
        if e.kind == 'binary' and e.op in ('<', '>', '<=', '>=', '==', '!='):
            d, tc, cond = self.compare(e)
            one = self.load_const(1, I64)
            self.emit('+ %s ($i64) $r0 0' % R(out.reg), dst=[out.reg])
            self.emit('$cmov %s %s %s %s %s' % (tc, R(one.reg), cond, R(out.reg), R(d.reg)),
                      dst=[out.reg], src=[one.reg, out.reg, d.reg])
            self.free(one)
            self.free(d)
            return out
        l_false, l_end = self.new_label('false'), self.new_label('end')
        self.branch(e, l_false, False)
        self.emit('+ %s ($i64) $r0 1' % R(out.reg), dst=[out.reg])
        self.jump(l_end)
        self.place_label(l_false)
        self.emit('+ %s ($i64) $r0 0' % R(out.reg), dst=[out.reg])
        self.place_label(l_end)
        return out

    INVERSE = {'<': '>=', '>': '<=', '<=': '>', '>=': '<', '==': '!=', '!=': '=='}

    def branch(self, e, label, when):
        """Jumps to label if e's truth equals `when`, else falls through."""
        self.cur_line = e.line
        if e.kind == 'unary' and e.op == '!':
            return self.branch(e.e, label, not when)
        if e.kind == 'binary' and e.op in ('&&', '||'):
            if (e.op == '&&') == when:
                # both must hold (&& true) / both must fail (|| false)
                skip = self.new_label('skip')
                self.branch(e.left, skip, not when)
                self.branch(e.right, label, when)
                self.place_label(skip)
            else:
                self.branch(e.left, label, when)
                self.branch(e.right, label, when)
            return
        if e.kind == 'binary' and e.op in self.INVERSE:
            d, tc, cond = self.compare(e)
            if not when:
                cond = self.INVERSE[cond]
                if tc.startswith('($f'):  # NaN: neither a < b nor a >= b; keep it simple, like the integers
                    pass
            self.emit('? %s %s %s $goto %s' % (tc, R(d.reg), cond, label), src=[d.reg], kind='ctl')
            self.free(d)
            return
        v = const_eval(e)
        if v is not None:
            if bool(v) == when:
                self.jump(label)
            return
        a = self.gen(e)
        tc = a.ctype.mcode() if a.ctype.is_float else '($i64)'
        self.emit('? %s %s %s $goto %s' % (tc, R(a.reg), '!=' if when else '==', label), src=[a.reg], kind='ctl')
        self.free(a)

    def assign(self, e):
        target = e.target
        if e.op == '=':
            value = e.value
        else:
            value = Node('binary', e.line, op=e.op[:-1], left=target, right=e.value)
        if target.kind == 'var' and target.name in self.f.vars:
            reg, ct = self.f.vars[target.name]
            # x = __dot_acc(T, x, a, b): accumulate in place
            if (value.kind == 'call' and value.name == '__dot_acc' and len(value.args) == 4 and
                    value.args[1].kind == 'var' and value.args[1].name == target.name):
                a, b = self.gen(value.args[2]), self.gen(value.args[3])
                self.emit('$dot $accumulate %s %s %s %s' % (R(reg), vtype(value.args[0]), R(a.reg), R(b.reg)),
                          dst=[reg], src=[reg, a.reg, b.reg])
                self.free(a)
                self.free(b)
                return Operand(reg, ct, False)
            dest = Operand(reg, ct, False)
            c = const_eval(value)
            if c is not None and value.kind in ('num', 'unary', 'cast'):
                self.load_const(c, ct, dest)
                return dest
            if value.kind == 'binary' and value.op in ('+', '-', '*', '/', '%', '&', '|', '^', '<<', '>>') \
                    and ct.bits == 64:
                v = self.binary(value.op, value.left, value.right, value.line, dest)
                if v.ctype == ct or (ct.is_int and v.ctype.is_int):
                    return dest
                v = self.convert(Operand(reg, v.ctype, False), ct)
                self.move(reg, v.reg)
                self.free(v)
                return dest
            v = self.convert(self.gen(value), ct)
            self.move(reg, v.reg)
            self.free(v)
            return dest
        if target.kind == 'var' and target.name in self.globals and not self.globals[target.name][2]:
            base, ct, _ = self.globals[target.name]
            v = self.convert(self.gen(value), ct)
            self.store_global(base, ct, None, v)
            return v
        if target.kind == 'index':
            v = self.convert(self.gen(value), self.globals.get(target.name, (0, I64, []))[1])
            base, ct, idx = self.element(target)
            self.store_global(base, ct, idx, v)
            return v
        name = getattr(target, 'name', None)
        if name is not None and name not in self.f.vars and name not in self.globals:
            raise CompileError(e.line, '%s is not defined' % name)
        raise CompileError(e.line, 'cannot assign to %s' % (name or 'this'))

    def call(self, e):
        if e.name in INTRINSICS:
            return self.intrinsic(e)
        if e.name not in self.functions:
            raise CompileError(e.line, '%s is not defined' % e.name)
        callee = self.functions[e.name]
        if e.name in self.entries:
            raise CompileError(e.line, 'an entry function (%s) cannot be called' % e.name)
        params = callee.node.params
        if len(e.args) != len(params):
            raise CompileError(e.line, '%s takes %d argument(s)' % (e.name, len(params)))
        values = []
        for arg, (pt, pn) in zip(e.args, params):
            values.append(self.convert(self.gen(arg), pt))
        if any(r in self.busy for r in self.f.temps if r not in {v.reg for v in values}):
            raise CompileError(e.line, 'a call inside &&, ||, ?: or a loop condition must be '
                                       'assigned to a variable first')
        # one bundle of moves: every move reads the registers as they were
        # before it, so an argument already in another parameter's register
        # is not overwritten before it is moved
        moves = [Ins('+ %s ($i64) %s $r0' % (R(callee.vars[pn][0]), R(v.reg)), dst=[callee.vars[pn][0]], src=[v.reg])
                 for v, (pt, pn) in zip(values, params) if callee.vars[pn][0] != v.reg]
        if moves:
            self.code.append(Ins('|| ' + '  '.join(m.text for m in moves) + ' ;', kind='asm', line=e.line))
        for v in values:
            self.free(v)
        callee_regs = {r for r, _ in callee.vars.values()}
        self.emit('$call %s' % e.name, kind='ctl', dst=callee_regs, src=callee_regs)
        if callee.node.rtype == VOID:
            return Operand(0, VOID, False)
        t = self.temp(callee.node.rtype)
        self.move(t.reg, callee.ret_reg)
        return t

    def intrinsic(self, e):
        nstr, nval = INTRINSICS[e.name]
        if len(e.args) != nstr + nval:
            raise CompileError(e.line, '%s takes %d argument(s)' % (e.name, nstr + nval))
        strs = e.args[:nstr]
        for s in strs:
            if s.kind != 'str':
                raise CompileError(e.line, '%s: the first argument(s) must be strings' % e.name)
        n = e.name
        if n == '__halt':
            self.emit('$halt', kind='ctl')
            return Operand(0, VOID, False)
        if n == '__slice':
            hi, lo = const_eval(e.args[1]), const_eval(e.args[2])
            if not (isinstance(hi, int) and isinstance(lo, int)):
                raise CompileError(e.line, '__slice needs constant bit positions')
            a = self.gen(e.args[0])
            t = self.temp(I64)
            self.emit('$slice %s %d %d %s' % (R(t.reg), hi, lo, R(a.reg)), dst=[t.reg], src=[a.reg])
            self.free(a)
            return t
        if n == '__ld64':
            a = self.convert(self.gen(e.args[0]), I64)
            t = self.temp(I64)
            self.emit('$ld ($i64) %s [%s + 0]' % (R(t.reg), R(a.reg)), dst=[t.reg], src=[a.reg], kind='mem')
            self.free(a)
            return t
        if n == '__st64':
            a = self.convert(self.gen(e.args[0]), I64)
            v = self.gen(e.args[1])
            self.emit('$st ($i64) [%s + 0] %s' % (R(a.reg), R(v.reg)), src=[a.reg, v.reg], kind='store')
            self.free(a)
            self.free(v)
            return Operand(0, VOID, False)
        if n == '__fsqrt':
            a = self.gen(e.args[0])
            if not a.ctype.is_float:
                raise CompileError(e.line, '__fsqrt needs a float or a double')
            t = self.temp(a.ctype)
            self.emit('$fsqrt %s %s %s' % (R(t.reg), a.ctype.mcode(), R(a.reg)), dst=[t.reg], src=[a.reg], kind='div')
            self.free(a)
            return t
        if n == '__vreduce':
            op = strs[0].value
            a = self.gen(e.args[2])
            t = self.temp(I64)
            self.emit('$vreduce %s %s %s %s' % (op, R(t.reg), vtype(strs[1]), R(a.reg)), dst=[t.reg], src=[a.reg])
            self.free(a)
            return t
        vt = vtype(strs[0])
        if n == '__dot':
            a, b = self.gen(e.args[1]), self.gen(e.args[2])
            t = self.temp(F32 if vt.startswith('($vf') else I64)
            self.emit('$dot %s %s %s %s' % (R(t.reg), vt, R(a.reg), R(b.reg)), dst=[t.reg], src=[a.reg, b.reg])
            self.free(a)
            self.free(b)
            return t
        if n == '__dot_acc':
            acc = self.gen(e.args[1])
            t = self.copy(acc)
            self.free(acc)
            a, b = self.gen(e.args[2]), self.gen(e.args[3])
            self.emit('$dot $accumulate %s %s %s %s' % (R(t.reg), vt, R(a.reg), R(b.reg)),
                      dst=[t.reg], src=[t.reg, a.reg, b.reg])
            self.free(a)
            self.free(b)
            t.ctype = F32 if vt.startswith('($vf') else I64
            return t
        # element-wise
        sym = {'__vadd': '+', '__vsub': '-', '__vmul': '*'}[n.replace('_rep', '')]
        a, b = self.gen(e.args[1]), self.gen(e.args[2])
        t = self.temp(I64)
        self.emit('$v %s %s %s %s %s%s' % (sym, R(t.reg), vt, R(a.reg), R(b.reg), ' $replicate' if n.endswith('_rep') else ''),
                  dst=[t.reg], src=[a.reg, b.reg])
        self.free(a)
        self.free(b)
        return t

    # -- statements -------------------------------------------------------

    def stmt(self, s):
        self.cur_line = s.line
        k = s.kind
        if k == 'block':
            for x in s.stmts:
                self.stmt(x)
        elif k == 'local':
            if s.init is not None:
                self.free(self.assign(Node('assign', s.line, op='=', target=Node('var', s.line, name=s.name),
                                           value=s.init)))
        elif k == 'expr':
            self.free(self.gen(as_statement(s.expr)))
        elif k == 'if':
            l_else = self.new_label('else')
            self.branch(s.cond, l_else, False)
            self.stmt(s.then)
            if s.other is not None:
                l_end = self.new_label('endif')
                self.jump(l_end)
                self.place_label(l_else)
                self.stmt(s.other)
                self.place_label(l_end)
            else:
                self.place_label(l_else)
        elif k == 'for':
            if s.init is not None:
                self.stmt(s.init)
            l_body, l_cont, l_end = self.new_label('loop'), self.new_label('next'), self.new_label('done')
            if s.test_first and s.cond is not None:
                self.branch(s.cond, l_end, False)
            self.loops.append((l_cont, l_end))
            self.place_label(l_body)
            self.stmt(s.body)
            self.loops.pop()
            self.place_label(l_cont)
            if s.step is not None:
                self.free(self.gen(as_statement(s.step)))
            if s.cond is None:
                self.jump(l_body)
            else:
                self.branch(s.cond, l_body, True)
            self.place_label(l_end)
        elif k in ('break', 'continue'):
            if not self.loops:
                raise CompileError(s.line, '%s outside a loop' % k)
            self.jump(self.loops[-1][1 if k == 'break' else 0])
        elif k == 'return':
            if s.value is not None:
                if self.f.node.rtype == VOID:
                    raise CompileError(s.line, '%s returns no value' % self.f.name)
                v = self.convert(self.gen(s.value), self.f.node.rtype)
                if self.f.ret_reg is not None:
                    self.move(self.f.ret_reg, v.reg)
                self.free(v)
            self.leave()
        elif k == 'asm':
            self.inline_asm(s)
        else:
            raise CompileError(s.line, 'cannot compile %s' % k)

    def leave(self):
        if self.f.name in self.entries:
            self.emit('$halt', kind='ctl')
        else:
            self.emit('$return', kind='ctl')

    def inline_asm(self, s):
        def sub(m):
            name = m.group(1)
            return R(self.lookup(name, s.line)[0])
        text = re.sub(r'%([A-Za-z_]\w*)', sub, s.text)
        # the scheduler treats inline mcode as a barrier: its own bundles, as written
        self.code.append(Ins(text, kind='asm', line=s.line))

    # -- driver -----------------------------------------------------------

    def compile(self):
        self.cur_line = 0
        for name in self.entries + [n for n in self.functions if n not in self.entries]:
            f = self.functions[name]
            self.f, self.busy, self.loops = f, set(), []
            self.place_label(name)
            self.stmt(f.node.body)
            if not self.code or self.code[-1].text not in ('$halt', '$return'):
                self.leave()
        return self.schedule()

    def schedule(self):
        """Groups the instructions into bundles. Returns mcode text."""
        out = ['// Generated by apcc.py (-O%d). Edit the C source, not this file.' % self.optimize, '']
        group, label, srcline = [], None, None
        written, mem, div = set(), 0, 0

        def flush():
            nonlocal group, label, written, mem, div
            if not group and label is None:
                return
            if not group:
                group = [Ins('$null')]
            head = (label + ':\n') if label else ''
            out.append(head + '    || ' + '  '.join(i.text for i in group) + ' ;')
            group, label, written, mem, div = [], None, set(), 0, 0

        for ins in self.code:
            if ins.kind == 'label':
                flush()
                if label is not None:  # two labels in a row: an empty bundle for the first
                    flush()
                label = ins.text
                continue
            if ins.kind == 'asm':
                flush()
                text = ins.text.strip()
                if label is not None:
                    out.append(label + ':')
                    label = None
                if '||' not in text:
                    text = '|| ' + text.rstrip(';').strip() + ' ;'
                out.append('    ' + text)
                continue
            if self.optimize == 0 and group:
                flush()
            fits = (len(group) < 8 and not (ins.src & written) and not (ins.dst & written)
                    and not (ins.kind in ('mem', 'store') and mem >= 4)
                    and not (ins.kind == 'div' and div >= 1))
            if not fits:
                flush()
            if srcline != ins.line and ins.line:
                out.append('    // line %d' % ins.line)
                srcline = ins.line
            group.append(ins)
            written |= ins.dst
            mem += ins.kind in ('mem', 'store')
            div += ins.kind == 'div'
            if ins.kind == 'ctl':
                flush()
        flush()
        return '\n'.join(out) + '\n'


def hoist_calls(node, c):
    """Rewrites calls nested inside expressions (f(x) + 1) as hidden local
    variables assigned just before the statement: a variable has its own
    register, which the callee does not touch, while a temporary would
    not survive the call. Calls under && || ?: stay (hoisting would
    change which calls run); so do loop conditions and steps, which are
    evaluated more than once."""
    if not isinstance(node, Node):
        return
    if node.kind == 'block':
        out = []
        for s in node.stmts:
            pre = []
            for field in {'expr': ['expr'], 'local': ['init'], 'return': ['value'], 'if': ['cond']}.get(s.kind, []):
                e = getattr(s, field)
                if e is not None:
                    setattr(s, field, lift(e, pre, c, top=True))
            out += pre + [s]
            for v in s.__dict__.values():
                hoist_calls(v, c)
        node.stmts = out
        return
    for v in node.__dict__.values():
        if isinstance(v, Node):
            hoist_calls(v, c)


def lift(e, pre, c, top=False):
    """e with each nested call replaced by a hidden variable (Ref hoist_calls)."""
    if not isinstance(e, Node):
        return e
    if e.kind == 'binary' and e.op in ('&&', '||') or e.kind == 'ternary':
        return e
    if e.kind == 'call':
        e.args = [lift(a, pre, c) for a in e.args]
        if top or e.name in INTRINSICS or e.name not in c.functions:
            return e
        rtype = c.functions[e.name].node.rtype
        if rtype == VOID:
            raise CompileError(e.line, '%s returns no value' % e.name)
        c.hoisted += 1
        name = '__call%d' % c.hoisted
        pre.append(Node('local', e.line, ctype=rtype, name=name, init=e))
        return Node('var', e.line, name=name)
    if e.kind == 'assign':
        e.value = lift(e.value, pre, c, top=e.value.kind == 'call')
        return e
    for k, v in list(e.__dict__.items()):
        if isinstance(v, Node):
            setattr(e, k, lift(v, pre, c))
        elif isinstance(v, list):
            setattr(e, k, [lift(x, pre, c) for x in v])
    return e


def as_statement(e):
    """An expression whose value is unused: x++ is then ++x (no copy)."""
    if e.kind == 'incdec' and not e.prefix:
        return Node('incdec', e.line, op=e.op, target=e.target, prefix=True)
    return e


def vtype(node):
    if node.kind != 'str' or node.value not in VECTOR_TYPES:
        raise CompileError(node.line, 'expected a vector type string such as "vi8" (vi/vu/vf 4..32)')
    return '($%s)' % node.value


def flatten(items):
    out = []
    for x in items:
        out += flatten(x) if isinstance(x, list) else [x]
    return out


def collect_locals(node, out):
    if isinstance(node, Node):
        if node.kind == 'local':
            out.append(node)
        for v in node.__dict__.values():
            collect_locals(v, out)
    elif isinstance(node, list):
        for x in node:
            collect_locals(x, out)


def find_calls(node, out):
    if isinstance(node, Node):
        if node.kind == 'call':
            out.add(node.name)
        for v in node.__dict__.values():
            find_calls(v, out)
    elif isinstance(node, list):
        for x in node:
            find_calls(x, out)


# ----------------------------------------------------------------------
# Interface
# ----------------------------------------------------------------------


class Result:
    def __init__(self, mcode, data_lines, symbols):
        self.mcode, self.data_lines, self.symbols = mcode, data_lines, symbols


def compile_source(text, filename='<source>', optimize=1, dmem_base=0):
    """Compiles C text. Returns a Result: mcode text, data-file lines
    (DMEM offsets), and {global name: DMEM byte offset}. dmem_base: the
    address the engine's program uses for DMEM byte 0 (0 for the
    standalone engine; the DMEM window's address in a system, where only
    that window is local). Raises CompileError (with the file name in its
    message)."""
    try:
        globals_, functions = Parser(tokenize(text)).program()
        c = Compiler(globals_, functions, optimize, dmem_base)
        code = c.compile()
    except CompileError as e:
        located = CompileError(e.line, e.message)
        located.args = ('%s:%d: %s' % (filename, e.line, e.message),)
        raise located from None
    header = ['// DMEM layout (byte offsets%s):' % (', DMEM at 0x%x' % dmem_base if dmem_base else '')] + \
        ['//   %-16s 0x%04x  %r%s' % (n, b - dmem_base, t, ''.join('[%d]' % d for d in dims))
         for n, (b, t, dims) in sorted(c.globals.items(), key=lambda x: x[1][0])]
    data = ['%x: 0x%016x' % (i, v) for i, v in sorted(c.data.items())]
    r = Result('\n'.join(header) + '\n' + code, data, {n: b - dmem_base for n, (b, t, d) in c.globals.items()})
    r.entries = c.entries
    return r


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('source')
    ap.add_argument('-o', '--output', help='the mcode file (default: the source with .mcode)')
    ap.add_argument('--data', help='the data file (default: the source with .data)')
    ap.add_argument('--symbols', help='also write the globals\' DMEM addresses here')
    ap.add_argument('-O', dest='optimize', type=int, default=1, choices=(0, 1),
                    help='0: one instruction per bundle; 1 (default): pack independent instructions')
    ap.add_argument('--dmem-base', type=lambda v: int(v, 0), default=0,
                    help='the address of DMEM byte 0 for the program (default 0: the standalone engine; '
                         '0x01000000 for engine 0 in sparc_apara, whose DMEM is a window)')
    a = ap.parse_args()
    with open(a.source) as f:
        text = f.read()
    try:
        r = compile_source(text, a.source, a.optimize, a.dmem_base)
    except CompileError as e:
        sys.exit('%s: error: %s' % (os.path.basename(sys.argv[0]), e.args[0]))
    stem = os.path.splitext(a.source)[0]
    with open(a.output or stem + '.mcode', 'w') as f:
        f.write(r.mcode)
    with open(a.data or stem + '.data', 'w') as f:
        f.write(''.join(l + '\n' for l in r.data_lines))
    if a.symbols:
        with open(a.symbols, 'w') as f:
            for n, b in sorted(r.symbols.items(), key=lambda x: x[1]):
                f.write('%s 0x%x\n' % (n, b))


if __name__ == '__main__':
    main()

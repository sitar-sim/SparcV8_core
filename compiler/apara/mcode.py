"""mcode.py: the APARA engine's assembly language (mcode), as a library.

Used by apara_as.py (assembler), apara_dis.py (disassembler) and the
tests. Our own implementation of the language defined by the APARA
reference tools (engine_isp/assembler/grammar/isa.g and the reference
mcode_align/mcode_assemble in the APARA repository): for any program the
reference tools accept, the object file is the same, word for word,
except where docs/source/apara/deviations.md says otherwise.

A program is a sequence of bundles:

    label:              (optional)
        ||
            <instruction>
            ...         (1 to 8 instructions, run in parallel)
        ;

Comments run from // to the end of the line.

Assembling a program (the order of the reference tools' passes):
  1. parse and check every instruction;
  2. close each bundle with $null instructions up to its capacity: 8 if it
     holds a control transfer, a load/store, a divide or a square root,
     otherwise the next power of two (1, 2, 4, 8);
  3. place the bundles: each at an address that is a multiple of its
     capacity, gaps filled with $null pad bundles of 4, 2 and 1 slots;
  4. arrange each 8-slot bundle into its lanes: a control transfer in
     lane 0, a divide or square root in lane 1, loads and stores in lanes
     4 to 7, the other instructions (in source order) in the free lanes;
  5. resolve labels: a branch or call holds its target relative to its
     own address (the bundle's address plus its lane);
  6. encode: one 32-bit word per instruction, bit 31 set on the first
     word of each bundle.
"""

import re

# ----------------------------------------------------------------------
# ISA tables (Ref the APARA ISA, engine_isp/isa/isa.txt)
# ----------------------------------------------------------------------

OPCODES = {
    'NOP': 0x00, 'CALL': 0x01, 'BRANCH': 0x02, 'RETURN': 0x03,
    'ADD': 0x04, 'SUB': 0x05, 'MUL': 0x06, 'DIV': 0x07,
    'OR': 0x08, 'AND': 0x09, 'XOR': 0x0A, 'NOR': 0x0B, 'NAND': 0x0C, 'XNOR': 0x0D,
    'SHL': 0x0E, 'SHR': 0x0F, 'FSQRT': 0x10, 'DOT': 0x11, 'CAST': 0x12,
    'LOAD': 0x13, 'STORE': 0x14, 'SET': 0x15, 'VREDUCE': 0x16, 'CMOV': 0x17,
    'PACK': 0x18, 'SLICE': 0x19, 'NULL': 0x1A, 'HALT': 0x1B,
}
OPCODE_NAMES = {v: k for k, v in OPCODES.items()}

# ALU operator symbols.
ALU_SYMBOLS = {'+': 'ADD', '-': 'SUB', '*': 'MUL', '/': 'DIV', '|': 'OR', '&': 'AND',
               '^': 'XOR', '~|': 'NOR', '~&': 'NAND', '~^': 'XNOR', '<<': 'SHL', '>>': 'SHR'}
ALU_OPERATORS = {v: k for k, v in ALU_SYMBOLS.items()}

CONDITIONS = {'==': 1, '>': 2, '<': 3, '>=': 4, '<=': 5, '!=': 6}
CONDITION_SYMBOLS = {v: k for k, v in CONDITIONS.items()}

# Type name -> (code, bits, unsigned, float, vector)
TYPES = {}
for _code, _name, _bits, _u, _f, _v in [
        (0x00, 'i4', 4, 0, 0, 0), (0x01, 'i8', 8, 0, 0, 0), (0x02, 'i16', 16, 0, 0, 0),
        (0x03, 'i32', 32, 0, 0, 0), (0x04, 'i64', 64, 0, 0, 0),
        (0x05, 'u4', 4, 1, 0, 0), (0x06, 'u8', 8, 1, 0, 0), (0x07, 'u16', 16, 1, 0, 0),
        (0x08, 'u32', 32, 1, 0, 0), (0x09, 'u64', 64, 1, 0, 0),
        (0x0A, 'f4', 4, 0, 1, 0), (0x0B, 'f8', 8, 0, 1, 0), (0x0C, 'f16', 16, 0, 1, 0),
        (0x0D, 'f32', 32, 0, 1, 0), (0x0E, 'f64', 64, 0, 1, 0),
        (0x0F, 'u128', 128, 1, 0, 0), (0x10, 'u256', 256, 1, 0, 0),
        (0x11, 'vu4', 4, 1, 0, 1), (0x12, 'vu8', 8, 1, 0, 1), (0x13, 'vu16', 16, 1, 0, 1),
        (0x14, 'vu32', 32, 1, 0, 1),
        (0x15, 'vf4', 4, 0, 1, 1), (0x16, 'vf8', 8, 0, 1, 1), (0x17, 'vf16', 16, 0, 1, 1),
        (0x18, 'vf32', 32, 0, 1, 1),
        (0x19, 'vi4', 4, 0, 0, 1), (0x1A, 'vi8', 8, 0, 0, 1), (0x1B, 'vi16', 16, 0, 0, 1),
        (0x1C, 'vi32', 32, 0, 0, 1)]:
    TYPES['$' + _name] = (_code, _bits, bool(_u), bool(_f), bool(_v))
TYPE_BY_CODE = {v[0]: k for k, v in TYPES.items()}


class Type:
    def __init__(self, name):
        self.name = name
        self.code, self.bits, self.unsigned, self.float, self.vector = TYPES[name]

    @staticmethod
    def from_code(code):
        return Type(TYPE_BY_CODE[code]) if code in TYPE_BY_CODE else None

    @property
    def signed(self):
        return not self.unsigned and not self.float

    def __str__(self):
        return '(' + self.name + ')'


class AsmError(Exception):
    def __init__(self, line, message):
        Exception.__init__(self, message)
        self.line = line
        self.message = message


# ----------------------------------------------------------------------
# Lexer
# ----------------------------------------------------------------------

_TOKEN_RE = re.compile(r'''
    (?P<ws>[ \t\r\f]+) |
    (?P<newline>\n) |
    (?P<comment>//[^\n]*) |
    (?P<reg>\$r[0-9]+\b) |
    (?P<kw>\$[a-z][a-z0-9]*) |
    (?P<hex>_h[0-9a-fA-F]+) |
    (?P<nint>-[0-9]+) |
    (?P<uint>[0-9]+) |
    (?P<ident>[A-Za-z][A-Za-z0-9_.]*) |
    (?P<sym>\|\||\+\+|--|==|>=|<=|!=|<<|>>|~\||~&|~\^|[;:()\[\]?+\-*/|&^<>])
''', re.VERBOSE)


class Token:
    def __init__(self, kind, text, line):
        self.kind, self.text, self.line = kind, text, line

    def __repr__(self):
        return '%s(%r)' % (self.kind, self.text)


def tokenize(text):
    tokens, line, pos = [], 1, 0
    while pos < len(text):
        m = _TOKEN_RE.match(text, pos)
        if not m:
            raise AsmError(line, 'unexpected character %r' % text[pos])
        kind = m.lastgroup
        if kind == 'newline':
            line += 1
        elif kind not in ('ws', 'comment'):
            t = m.group(kind)
            # "--3" and "++3" are increments; "-3" after them cannot occur.
            tokens.append(Token(kind, t, line))
        pos = m.end()
    return tokens


# ----------------------------------------------------------------------
# Instructions
# ----------------------------------------------------------------------

class Instruction:
    """One instruction. `op` is an OPCODES key; the other fields depend
    on it (unused ones stay at their defaults)."""

    def __init__(self, op, line=0):
        self.op = op
        self.line = line
        self.type = None          # source/test/transfer/destination type
        self.src_type = None      # CAST source type
        self.rd = self.rs1 = self.rs2 = 0
        self.imm = None           # ALU/LOAD/STORE immediate (None: register form)
        self.increment = 0
        self.condition = 0
        self.label = None         # BRANCH, CALL (label form)
        self.jump = 0             # resolved PC-relative offset
        self.flag = False         # DOT accumulate, VALU replicate
        self.vector = False       # VALU
        self.subop = None         # VREDUCE
        self.packed_bits = self.word_bits = 0
        self.byte_index = self.value = 0  # SET
        self.high = self.low = 0  # SLICE

    # classes used by the bundle rules
    def is_control(self):
        return self.op in ('BRANCH', 'CALL', 'RETURN')

    def is_memory(self):
        return self.op in ('LOAD', 'STORE')

    def is_div_sqrt(self):
        return self.op in ('DIV', 'FSQRT')

    def transfer_registers(self):
        return 1 if self.type.bits <= 64 else self.type.bits // 64

    def cast_counts(self):
        i = o = 1
        if self.src_type.vector:
            if self.type.bits < self.src_type.bits:
                i = self.src_type.bits // self.type.bits
            elif self.src_type.bits < self.type.bits:
                o = self.type.bits // self.src_type.bits
        return i, o

    def written_registers(self):
        """Registers this instruction writes (for the one-writer rule)."""
        op, w = self.op, []
        if op in ALU_OPERATORS or op in ('DOT', 'FSQRT', 'VREDUCE', 'SET', 'SLICE'):
            w = [self.rd]
        elif op == 'CAST':
            w = [(self.rd + k) & 31 for k in range(self.cast_counts()[1])]
        elif op == 'PACK':
            n = 1 if self.packed_bits < 64 else self.packed_bits // 64
            w = [(self.rd + k) & 31 for k in range(n)]
        elif op == 'CMOV':
            w = [self.rd] + ([self.rs2] if self.increment else [])
        elif op == 'BRANCH':
            w = [self.rs2] if self.increment else []
        elif op == 'LOAD':
            w = [self.rd + k for k in range(self.transfer_registers())]
            if self.imm is None and self.increment:
                w.append(self.rs2)
        elif op == 'STORE':
            w = [self.rs2] if self.imm is None and self.increment else []
        return [r for r in w if r != 0]

    # ------------------------------------------------------------------
    # encoding (the reference assembler's layouts, McodeBinaryCode.cpp)
    # ------------------------------------------------------------------
    def encode(self):
        op = self.op
        w = OPCODES[op] << 26
        if op in ('NULL', 'HALT', 'RETURN', 'NOP'):
            return w
        if op == 'CALL':
            if self.label is not None:
                return w | (1 << 25) | (self.jump & 0x1FFFFFF)
            return w | self.rs2
        if op == 'BRANCH':
            return (w | ((self.type.code & 0x1F) << 22) | (self.condition << 19) |
                    ((self.increment & 3) << 17) | ((self.jump & 0xFFF) << 5) | self.rs2)
        if op == 'CMOV':
            return (w | (self.type.code << 21) | (self.rd << 16) | (self.rs1 << 11) |
                    (self.condition << 8) | ((self.increment & 3) << 6) | self.rs2)
        if op == 'PACK':
            return (w | (self.rd << 16) | (log2(self.packed_bits) << 12) |
                    (log2(self.word_bits) << 9) | self.rs2)
        if op == 'SET':
            return w | (self.byte_index << 21) | (self.rd << 16) | (self.value & 0xFFFF)
        if op == 'SLICE':
            return (w | ((self.high >> 1) << 21) | (self.rd << 16) | ((self.high & 1) << 15) |
                    (self.low << 9) | self.rs2)
        if op == 'CAST':
            return w | (self.type.code << 21) | (self.rd << 16) | (self.src_type.code << 10) | self.rs2
        w |= (self.type.code << 21) | (self.rd << 16) | (self.rs1 << 11)
        if op == 'FSQRT':
            return w
        if op == 'VREDUCE':
            return w | (OPCODES[self.subop] << 6)
        if op == 'DOT':
            return w | (int(self.flag) << 10) | self.rs2
        if op in ('LOAD', 'STORE'):
            if self.imm is not None:
                return w | (1 << 10) | (self.imm & 0x3FF)
            return w | ((self.increment & 0x1F) << 5) | self.rs2
        # ALU, VALU
        if self.vector:
            return w | (int(self.flag) << 10) | self.rs2
        if self.imm is not None:
            return w | (1 << 10) | (self.imm & 0x3FF)
        return w | self.rs2

    # ------------------------------------------------------------------
    # assembly text (parses back to the same instruction)
    # ------------------------------------------------------------------
    def text(self, target=None):
        """`target`: the text to use for a branch/call label."""
        op = self.op
        r = lambda n: '$r%d' % n
        incr = '' if not self.increment else (
            ' ++%d' % self.increment if self.increment > 0 else ' --%d' % -self.increment)
        tgt = target if target is not None else (self.label or 'pc%+d' % self.jump)
        if op in ('NULL', 'HALT', 'RETURN'):
            return {'NULL': '$null', 'HALT': '$halt', 'RETURN': '$return'}[op]
        if op == 'NOP':
            return '$null'
        if op == 'CALL':
            return '$call ' + (tgt if self.label is not None or target is not None else r(self.rs2))
        if op == 'BRANCH':
            return '? %s %s %s%s $goto %s' % (self.type, r(self.rs2), CONDITION_SYMBOLS.get(self.condition, '?'),
                                             incr, tgt)
        if op == 'CMOV':
            return '$cmov %s %s %s%s %s %s' % (self.type, r(self.rs1), CONDITION_SYMBOLS.get(self.condition, '?'),
                                             incr, r(self.rd), r(self.rs2))
        if op == 'PACK':
            return '$pack %d %s %d %s' % (self.packed_bits, r(self.rd), self.word_bits, r(self.rs2))
        if op == 'SET':
            return '$set %s %d _h%x' % (r(self.rd), self.byte_index, self.value & 0xFFFF)
        if op == 'SLICE':
            return '$slice %s %d %d %s' % (r(self.rd), self.high, self.low, r(self.rs2))
        if op == 'CAST':
            return '$cast %s %s %s %s' % (self.type, r(self.rd), self.src_type, r(self.rs2))
        if op == 'FSQRT':
            return '$fsqrt %s %s %s' % (r(self.rd), self.type, r(self.rs1))
        if op == 'VREDUCE':
            return '$vreduce %s %s %s %s' % (ALU_OPERATORS[self.subop], r(self.rd), self.type, r(self.rs1))
        if op == 'DOT':
            return '$dot %s%s %s %s %s' % ('$accumulate ' if self.flag else '', r(self.rd), self.type,
                                           r(self.rs1), r(self.rs2))
        if op in ('LOAD', 'STORE'):
            addr = '[%s + %s]' % (r(self.rs1), str(self.imm) if self.imm is not None else r(self.rs2) + incr)
            if op == 'LOAD':
                return '$ld %s %s %s' % (self.type, r(self.rd), addr)
            return '$st %s %s %s' % (self.type, addr, r(self.rd))
        if self.vector:
            return '$v %s %s %s %s %s%s' % (ALU_OPERATORS[op], r(self.rd), self.type, r(self.rs1), r(self.rs2),
                                           ' $replicate' if self.flag else '')
        return '%s %s %s %s %s' % (ALU_OPERATORS[op], r(self.rd), self.type, r(self.rs1),
                                   str(self.imm) if self.imm is not None else r(self.rs2))


def log2(v):
    return v.bit_length() - 1


def sign_extend(v, bits):
    v &= (1 << bits) - 1
    return v - (1 << bits) if v >> (bits - 1) else v


# ----------------------------------------------------------------------
# Parser
# ----------------------------------------------------------------------

class Bundle:
    def __init__(self, label=None, line=0):
        self.label = label
        self.line = line
        self.instructions = []
        self.address = 0
        self.pad = False

    def needs_full(self):
        return any(i.is_control() or i.is_memory() or i.is_div_sqrt() for i in self.instructions)

    def capacity(self):
        if self.needs_full():
            return 8
        n = len(self.instructions)
        return 1 if n <= 1 else 2 if n <= 2 else 4 if n <= 4 else 8


class Parser:
    def __init__(self, tokens):
        self.tokens = tokens
        self.pos = 0

    def peek(self, k=0):
        i = self.pos + k
        return self.tokens[i] if i < len(self.tokens) else None

    def line(self):
        t = self.peek() or (self.tokens[-1] if self.tokens else None)
        return t.line if t else 0

    def next(self, what='a token'):
        t = self.peek()
        if t is None:
            raise AsmError(self.line(), 'unexpected end of file, expected ' + what)
        self.pos += 1
        return t

    def expect(self, text):
        t = self.next(repr(text))
        if t.text != text:
            raise AsmError(t.line, 'expected %r, found %r' % (text, t.text))
        return t

    def accept(self, text):
        t = self.peek()
        if t is not None and t.text == text:
            self.pos += 1
            return True
        return False

    def reg(self):
        t = self.next('a register')
        if t.kind != 'reg':
            raise AsmError(t.line, 'expected a register ($r0..$r31), found %r' % t.text)
        n = int(t.text[2:])
        if n > 31:
            raise AsmError(t.line, 'no register %s (registers are $r0..$r31)' % t.text)
        return n

    def type(self):
        self.expect('(')
        t = self.next('a type')
        if t.text not in TYPES:
            raise AsmError(t.line, 'expected a type such as $i32 or $vf16, found %r' % t.text)
        self.expect(')')
        return Type(t.text)

    def uint(self, what):
        t = self.next(what)
        if t.kind != 'uint':
            raise AsmError(t.line, 'expected %s, found %r' % (what, t.text))
        return int(t.text)

    def integer(self, what):
        t = self.next(what)
        if t.kind == 'uint':
            return int(t.text)
        if t.kind == 'nint':
            return int(t.text)
        if t.kind == 'sym' and t.text == '+' and self.peek() is not None and self.peek().kind == 'uint':
            return int(self.next().text)
        raise AsmError(t.line, 'expected %s, found %r' % (what, t.text))

    def condition(self):
        t = self.next('a condition')
        if t.text not in CONDITIONS:
            raise AsmError(t.line, 'expected a condition (== > < >= <= !=), found %r' % t.text)
        return CONDITIONS[t.text]

    def increment(self):
        if self.accept('++'):
            return self.uint('an increment')
        if self.accept('--'):
            return -self.uint('an increment')
        return 0

    def ident(self, what):
        t = self.next(what)
        if t.kind != 'ident':
            raise AsmError(t.line, 'expected %s, found %r' % (what, t.text))
        return t.text

    def program(self):
        bundles = []
        while self.peek() is not None:
            bundles.append(self.bundle())
        return bundles

    def bundle(self):
        label = None
        line = self.line()
        if self.peek().kind == 'ident' and self.peek(1) is not None and self.peek(1).text == ':':
            label = self.next().text
            self.next()
        self.expect('||')
        b = Bundle(label, line)
        while not self.accept(';'):
            if self.peek() is None:
                raise AsmError(line, 'bundle not closed with ";"')
            b.instructions.append(self.instruction())
        if not b.instructions:
            raise AsmError(line, 'empty bundle')
        return b

    def address(self, i):
        """[ $rs1 + ($rs2 [incr] | imm) ]"""
        self.expect('[')
        i.rs1 = self.reg()
        t = self.peek()
        if t is not None and t.kind == 'nint':  # "[$r1 -4]": allowed as "+ -4"
            i.imm = int(self.next().text)
        else:
            self.expect('+')
            if self.peek() is not None and self.peek().kind == 'reg':
                i.rs2 = self.reg()
                i.increment = self.increment()
            else:
                i.imm = self.integer('a register or an immediate')
        self.expect(']')

    def instruction(self):
        t = self.next('an instruction')
        k, line = t.text, t.line
        if k == '?':
            i = Instruction('BRANCH', line)
            i.type = self.type()
            i.rs2 = self.reg()
            i.condition = self.condition()
            i.increment = self.increment()
            self.expect('$goto')
            i.label = self.ident('a label')
        elif k == '$call':
            i = Instruction('CALL', line)
            if self.peek() is not None and self.peek().kind == 'reg':
                i.rs2 = self.reg()
            else:
                i.label = self.ident('a label or a register')
        elif k == '$return':
            i = Instruction('RETURN', line)
        elif k == '$null':
            i = Instruction('NULL', line)
        elif k == '$halt':
            i = Instruction('HALT', line)
        elif k == '$ld':
            i = Instruction('LOAD', line)
            i.type = self.type()
            i.rd = self.reg()
            self.address(i)
        elif k == '$st':
            i = Instruction('STORE', line)
            i.type = self.type()
            self.address(i)
            i.rd = self.reg()
        elif k == '$cast':
            i = Instruction('CAST', line)
            i.type = self.type()
            i.rd = self.reg()
            i.src_type = self.type()
            i.rs2 = self.reg()
        elif k == '$cmov':
            i = Instruction('CMOV', line)
            i.type = self.type()
            i.rs1 = self.reg()
            i.condition = self.condition()
            i.increment = self.increment()
            i.rd = self.reg()
            i.rs2 = self.reg()
        elif k == '$pack':
            i = Instruction('PACK', line)
            i.packed_bits = self.uint('the packed width')
            i.rd = self.reg()
            i.word_bits = self.uint('the word width')
            i.rs2 = self.reg()
        elif k == '$set':
            i = Instruction('SET', line)
            i.rd = self.reg()
            i.byte_index = self.uint('a byte index')
            v = self.next('a value')
            if v.kind == 'hex':
                i.value = int(v.text[2:], 16)
            elif v.kind in ('uint', 'nint'):
                i.value = int(v.text)
            else:
                raise AsmError(v.line, 'expected a value, found %r' % v.text)
        elif k == '$slice':
            i = Instruction('SLICE', line)
            i.rd = self.reg()
            i.high = self.uint('the high bit index')
            i.low = self.uint('the low bit index')
            i.rs2 = self.reg()
        elif k == '$dot':
            i = Instruction('DOT', line)
            i.flag = self.accept('$accumulate')
            i.rd = self.reg()
            i.type = self.type()
            i.rs1 = self.reg()
            i.rs2 = self.reg()
        elif k == '$fsqrt':
            i = Instruction('FSQRT', line)
            i.rd = self.reg()
            i.type = self.type()
            i.rs1 = self.reg()
        elif k == '$vreduce':
            i = Instruction('VREDUCE', line)
            s = self.next('a reduction operator')
            if s.text not in ('+', '*', '|', '&', '^', '~^'):
                raise AsmError(s.line, 'expected a reduction operator (+ * | & ^ ~^), found %r' % s.text)
            i.subop = ALU_SYMBOLS[s.text]
            i.rd = self.reg()
            i.type = self.type()
            i.rs1 = self.reg()
        elif k == '$v':
            s = self.next('a vector operator')
            if s.text not in ('+', '-', '*'):
                raise AsmError(s.line, 'expected a vector operator (+ - *), found %r' % s.text)
            i = Instruction(ALU_SYMBOLS[s.text], line)
            i.vector = True
            i.rd = self.reg()
            i.type = self.type()
            i.rs1 = self.reg()
            i.rs2 = self.reg()
            i.flag = self.accept('$replicate')
        elif k in ALU_SYMBOLS:
            i = Instruction(ALU_SYMBOLS[k], line)
            i.rd = self.reg()
            i.type = self.type()
            i.rs1 = self.reg()
            if self.peek() is not None and self.peek().kind == 'reg':
                i.rs2 = self.reg()
            else:
                i.imm = self.integer('a register or an immediate')
        else:
            raise AsmError(line, 'unknown instruction %r' % k)
        return i


# ----------------------------------------------------------------------
# Checks (Ref docs/source/apara/isa.md for the rules)
# ----------------------------------------------------------------------

def check_instruction(i, warnings):
    """Raises AsmError if the instruction cannot be encoded or executed."""
    op, t = i.op, i.type

    def need(cond, msg):
        if not cond:
            raise AsmError(i.line, msg)

    def in_range(v, lo, hi, what):
        need(lo <= v <= hi, '%s %d is out of range (%d to %d)' % (what, v, lo, hi))

    if i.vector:
        need(t.vector, 'a $v instruction needs a vector type')
    elif op in ALU_OPERATORS:
        need(not t.vector, 'use "$v %s" for a vector type' % ALU_OPERATORS[op])
        need(t.bits <= 64, 'type %s is wider than a register' % t.name)
        if t.float:
            need(op in ('ADD', 'SUB', 'MUL', 'DIV'), 'floats have only + - * /')
        if i.imm is not None:
            in_range(i.imm, -512, 511, 'immediate')
    if op in ('BRANCH', 'CMOV'):
        need(not t.vector and t.bits <= 64, 'a %s tests a scalar of at most 64 bits' % op.lower())
        in_range(i.increment, -2, 1, 'increment')
        need(not (t.float and i.increment), 'no increment with a float test type')
    if op in ('LOAD', 'STORE'):
        need(t.bits >= 8, 'a load or store moves at least 8 bits')
        need(i.rd + i.transfer_registers() <= 32, 'the registers from $r%d run past $r31' % i.rd)
        if i.imm is not None:
            in_range(i.imm, -512, 511, 'offset')
        else:
            in_range(i.increment, -16, 15, 'increment')
        if t.vector:
            warnings.append((i.line, 'a load/store moves one %d-bit element of a vector type' % t.bits))
    if op == 'CAST':
        s = i.src_type
        need(t.vector == s.vector, 'a cast is scalar to scalar or vector to vector')
        need(t.bits <= 64 and s.bits <= 64, 'a cast converts types of at most 64 bits')
        a, b = i.cast_counts()
        need(a <= 2 and b <= 2, 'a vector cast changes the element width by one step')
    if op == 'FSQRT':
        need(t.float and not t.vector and t.bits in (32, 64), '$fsqrt takes ($f32) or ($f64)')
    if op == 'VREDUCE':
        need(t.bits < 64, '$vreduce takes a type narrower than 64 bits')
        need(not t.float or i.subop in ('ADD', 'MUL'), 'float reductions are + and *')
    if op == 'DOT':
        need(t.bits <= 64, '$dot takes a type of at most 64 bits')
    if op == 'PACK':
        for v, what in ((i.packed_bits, 'packed width'), (i.word_bits, 'word width')):
            need(v > 0 and v & (v - 1) == 0, 'the %s must be a power of two' % what)
        need(i.word_bits <= 64 and i.word_bits <= i.packed_bits <= 256,
             'pack needs word width <= 64 and word width <= packed width <= 256')
    if op == 'SET':
        in_range(i.byte_index, 0, 7, 'byte index')
        in_range(i.value, -32768, 65535, 'value')
    if op == 'SLICE':
        need(0 <= i.low <= i.high <= 63, 'a slice needs 0 <= low <= high <= 63')


def check_bundle(b):
    ins = b.instructions
    if len(ins) > 8:
        raise AsmError(b.line, 'a bundle holds at most 8 instructions (this one has %d)' % len(ins))
    if sum(i.is_control() for i in ins) > 1:
        raise AsmError(b.line, 'a bundle holds at most one branch/call/return')
    if sum(i.is_memory() for i in ins) > 4:
        raise AsmError(b.line, 'a bundle holds at most 4 loads/stores')
    if sum(i.is_div_sqrt() for i in ins) > 1:
        raise AsmError(b.line, 'a bundle holds at most one divide or square root')
    written = {}
    for i in ins:
        for r in i.written_registers():
            if r in written:
                raise AsmError(i.line, '$r%d is written twice in this bundle (also at line %d)' % (r, written[r]))
            written[r] = i.line


# ----------------------------------------------------------------------
# Close, place, arrange, resolve
# ----------------------------------------------------------------------

def close_with_nulls(b):
    while len(b.instructions) < b.capacity():
        b.instructions.append(Instruction('NULL', b.line))


def arrange_lanes(b):
    """Lane rules of a full bundle (Ref the module comment)."""
    ins = b.instructions
    lanes = [None] * 8
    memory = [i for i in ins if i.is_memory()]
    for k, i in enumerate(memory):
        lanes[4 + k] = i
    ds = [i for i in ins if i.is_div_sqrt()]
    if ds:
        lanes[1] = ds[0]
    cti = [i for i in ins if i.is_control()]
    if cti:
        lanes[0] = cti[0]
    others = [i for i in ins if not (i.is_memory() or i.is_div_sqrt() or i.is_control())]
    for k in range(8):
        if lanes[k] is None:
            lanes[k] = others.pop(0)
    b.instructions = lanes


def place(bundles):
    """Returns the bundles with $null pad bundles inserted so each starts
    at a multiple of its size, and sets their addresses."""
    out, address, pads = [], 0, 0
    for b in bundles:
        size = len(b.instructions)
        gap = (size - address % size) % size
        while gap > 0:
            n = 4 if gap >= 4 and address % 4 == 0 else 2 if gap >= 2 and address % 2 == 0 else 1
            p = Bundle('pad_%d__%d' % (n, pads), b.line)
            p.pad = True
            p.instructions = [Instruction('NULL', b.line) for _ in range(n)]
            p.address = address
            out.append(p)
            pads += 1
            address += n
            gap -= n
        b.address = address
        out.append(b)
        address += size
    return out


def resolve_labels(bundles):
    labels = {}
    for b in bundles:
        if b.label is not None and not b.pad:
            if b.label in labels:
                raise AsmError(b.line, 'label %s defined twice' % b.label)
            labels[b.label] = b.address
    for b in bundles:
        for lane, i in enumerate(b.instructions):
            if i.label is None:
                continue
            if i.label not in labels:
                raise AsmError(i.line, 'undefined label %s' % i.label)
            i.jump = labels[i.label] - (b.address + lane)
            lo, hi = (-2048, 2047) if i.op == 'BRANCH' else (-(1 << 24), (1 << 24) - 1)
            if not lo <= i.jump <= hi:
                raise AsmError(i.line, 'label %s is too far (%d words) for a %s' % (i.label, i.jump, i.op.lower()))
    return labels


def assemble(text):
    """Returns (bundles, labels, warnings): placed bundles, encodable.
    Raises AsmError on the first error."""
    bundles = Parser(tokenize(text)).program()
    warnings = []
    for b in bundles:
        for i in b.instructions:
            check_instruction(i, warnings)
        check_bundle(b)
        close_with_nulls(b)
        if len(b.instructions) == 8:
            arrange_lanes(b)
    bundles = place(bundles)
    labels = resolve_labels(bundles)
    return bundles, labels, warnings


def object_words(bundles):
    """[(word index, instruction word)]"""
    words = []
    for b in bundles:
        for lane, i in enumerate(b.instructions):
            w = i.encode() | ((1 << 31) if lane == 0 else 0)
            words.append((b.address + lane, w))
    return words


def format_object(words):
    return ''.join('%x: %x\n' % (a, w) for a, w in words)


def format_source(bundles):
    """The placed, arranged program as assembly text."""
    out = []
    for b in bundles:
        if b.label:
            out.append('%s:' % b.label)
        out.append('    ||   // %#x' % b.address)
        for i in b.instructions:
            out.append('        ' + i.text())
        out.append('    ;')
    return '\n'.join(out) + '\n'


# ----------------------------------------------------------------------
# Decoding (Ref model/cpp_common_code/apara/AparaInstruction.cpp)
# ----------------------------------------------------------------------

def _f(w, hi, lo):
    return (w >> lo) & ((1 << (hi - lo + 1)) - 1)


def decode(word):
    """An Instruction from a 32-bit word, or None if it is not one."""
    code = _f(word, 30, 26)
    op = OPCODE_NAMES.get(code)
    if op is None:
        return None
    i = Instruction(op)
    i.rd, i.rs1, i.rs2 = _f(word, 20, 16), _f(word, 15, 11), _f(word, 4, 0)
    typ = lambda hi, lo: Type.from_code(_f(word, hi, lo))
    if op in ('NOP', 'NULL', 'HALT', 'RETURN'):
        pass
    elif op == 'CALL':
        if _f(word, 25, 25):
            i.jump = sign_extend(_f(word, 24, 0), 25)
            i.label = ''
    elif op == 'BRANCH':
        i.type = typ(25, 22)
        i.condition = _f(word, 21, 19)
        i.increment = sign_extend(_f(word, 18, 17), 2)
        i.jump = sign_extend(_f(word, 16, 5), 12)
        i.label = ''
    elif op == 'CMOV':
        i.type = typ(25, 21)
        i.condition = _f(word, 10, 8)
        i.increment = sign_extend(_f(word, 7, 6), 2)
    elif op == 'PACK':
        i.packed_bits, i.word_bits = 1 << _f(word, 15, 12), 1 << _f(word, 11, 9)
    elif op == 'SET':
        i.byte_index, i.value = _f(word, 23, 21), _f(word, 15, 0)
    elif op == 'SLICE':
        i.high, i.low = (_f(word, 25, 21) << 1) | _f(word, 15, 15), _f(word, 14, 9)
    elif op == 'CAST':
        i.type, i.src_type = typ(25, 21), typ(14, 10)
    elif op == 'FSQRT':
        i.type = typ(25, 21)
    elif op == 'VREDUCE':
        i.type = typ(25, 21)
        i.subop = OPCODE_NAMES.get(_f(word, 10, 6))
        if i.subop not in ALU_OPERATORS:
            return None
    elif op == 'DOT':
        i.type, i.flag = typ(25, 21), bool(_f(word, 10, 10))
    elif op in ('LOAD', 'STORE'):
        i.type = typ(25, 21)
        if _f(word, 10, 10):
            i.imm = sign_extend(_f(word, 9, 0), 10)
        else:
            i.increment = sign_extend(_f(word, 9, 5), 5)
    else:  # ALU, VALU
        i.type = typ(25, 21)
        if i.type is not None and i.type.vector:
            i.vector, i.flag = True, bool(_f(word, 10, 10))
        elif _f(word, 10, 10):
            i.imm = sign_extend(_f(word, 9, 0), 10)
    if op in ('BRANCH', 'CMOV', 'CAST', 'FSQRT', 'VREDUCE', 'DOT', 'LOAD', 'STORE') or op in ALU_OPERATORS:
        if i.type is None or (op == 'CAST' and i.src_type is None):
            return None
    return i


def read_object(text):
    """[(word index, word)] from object-file text."""
    words = []
    for n, line in enumerate(text.splitlines(), 1):
        line = line.split('!', 1)[0].strip()
        if not line:
            continue
        m = re.match(r'^([0-9a-fA-F]+)\s*:\s*(?:0x)?([0-9a-fA-F]+)$', line)
        if not m:
            raise AsmError(n, 'expected "<index>: <word>"')
        words.append((int(m.group(1), 16), int(m.group(2), 16)))
    return words


def disassemble(words):
    """Assembly text for object-file words (bundles cut at start bits)."""
    words = sorted(words)
    bundles, current = [], None
    for addr, w in words:
        if (w >> 31) or current is None or addr != current[0] + len(current[1]):
            current = (addr, [])
            bundles.append(current)
        current[1].append((addr, w))
    targets = set()
    decoded = []
    for start, ws in bundles:
        ins = []
        for addr, w in ws:
            i = decode(w & 0x7FFFFFFF)
            if i is not None and i.label is not None:
                targets.add(addr + i.jump)
            ins.append((addr, w, i))
        decoded.append((start, ins))
    out = []
    for start, ins in decoded:
        if start in targets:
            out.append('L_%x:' % start)
        out.append('    ||   // %#x' % start)
        for addr, w, i in ins:
            if i is None:
                out.append('        // %#x: %08x is not an instruction' % (addr, w))
            else:
                tgt = 'L_%x' % (addr + i.jump) if i.label is not None else None
                out.append('        ' + i.text(tgt))
        out.append('    ;')
    return '\n'.join(out) + '\n'

# sparc_pygments_lexer/sparc.py

import re

from pygments.lexer import RegexLexer, bygroups
from pygments.token import (
    Keyword,
    Name,
    Comment,
    Number,
    Punctuation,
    Text,
)


class SparcLexer(RegexLexer):
    """
    Pygments lexer for SPARC V8 assembly, as used throughout this
    project's own .s test programs.

    The one thing that actually matters here, and that no built-in
    Pygments assembly lexer gets right: SPARC comments start with `!`,
    not `#`/`;`. Feeding this syntax to Pygments' generic "asm"
    (GasLexer) turns every `!` into an Error token and highlights
    comment text as if it were code.

    Mnemonics vs. labels are told apart structurally, matching this
    project's own convention (see any validation/asm/*.s file):
    instructions are indented, labels and directives are not.
    """

    name = "SPARC"
    aliases = ["sparc"]
    filenames = ["*.s"]
    mimetypes = ["text/x-sparc-asm"]
    url = ""
    version_added = ""

    flags = re.MULTILINE | re.UNICODE

    tokens = {
        "root": [
            # An instruction mnemonic: the first identifier on an
            # indented line (mov, add, wr, ta, nop, and every synthetic
            # instruction the assembler accepts, no need to enumerate
            # them, this project's sources are consistent about
            # indenting every real instruction and nothing else). Tried
            # before the generic whitespace rule below, which would
            # otherwise consume the leading indent first and leave `^`
            # nothing to anchor to.
            (r"^([ \t]+)([A-Za-z][A-Za-z0-9]*)", bygroups(Text, Keyword)),

            # A second mnemonic packed onto the same line after a label
            # or a previous instruction, SPARC's trap tables do this
            # (see validation/asm/*/traps/*.s):
            #   HW_trap_0x00: mov 0x00, %g1; restore; ta 0; nop
            (r"(?<=[:;])[ \t]*([A-Za-z][A-Za-z0-9]*)", Keyword),

            # Whitespace
            (r"[ \t]+", Text),
            (r"\n", Text),

            # Comments: `!` to end of line, whether the whole line or
            # just a trailing note after an instruction.
            (r"!.*$", Comment.Single),

            # Assembler directives at the start of a line (.global,
            # .align, .word, ...), never indented in this project's own
            # test sources.
            (r"^\.[A-Za-z_][A-Za-z0-9_]*", Keyword.Pseudo),

            # Labels: an identifier immediately followed by `:` at the
            # start of a line (main:, _start:, trap_table_base:, ...).
            (r"^[A-Za-z_.$][A-Za-z0-9_.$]*(?=:)", Name.Label),

            # Registers and state/control registers: %g0-%g7, %o0-%o7,
            # %l0-%l7, %i0-%i7, %r0-%r31, %f0-%f31, %asrN, and the named
            # ones (%psr, %wim, %tbr, %y, %fsr, %pc, %npc, ...).
            (r"%[A-Za-z][A-Za-z0-9]*", Name.Variable),

            # Numbers: hex first (so the 0x prefix doesn't get split
            # off as a bare 0), then decimal.
            (r"\b0[xX][0-9a-fA-F]+\b", Number.Hex),
            (r"\b\d+\b", Number.Integer),

            # Punctuation between operands, and between instructions
            # (`;`) or after a label (`:`).
            (r"[,;:\[\]+\-]", Punctuation),

            # Anything else identifier-shaped: operand symbols (branch
            # targets, `set`'s symbol operand, ...), not a mnemonic
            # since those are only matched at the start of a line above.
            (r"[A-Za-z_.$][A-Za-z0-9_.$]*", Name),

            # Anything left over.
            (r".", Text),
        ],
    }

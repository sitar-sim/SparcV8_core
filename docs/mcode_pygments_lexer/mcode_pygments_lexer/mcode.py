# mcode_pygments_lexer/mcode.py

import re

from pygments.lexer import RegexLexer
from pygments.token import Comment, Keyword, Name, Number, Operator, Punctuation, Text


class McodeLexer(RegexLexer):
    """
    Pygments lexer for mcode, the APARA engine's assembly language (Ref
    compiler/apara/mcode.py for the language). Highlights the bundle
    delimiters (|| and ;), instruction keywords ($ld, $cast, ...), types
    (($i32), ($vf16), ...), registers ($r0..$r31), labels, numbers and
    // comments.
    """

    name = "mcode"
    aliases = ["mcode", "apara"]
    filenames = ["*.mcode"]
    mimetypes = ["text/x-mcode"]

    flags = re.MULTILINE | re.UNICODE

    tokens = {
        "root": [
            (r"[ \t\r\f\n]+", Text),
            (r"//.*$", Comment.Single),
            (r"\|\|", Keyword.Pseudo),                  # bundle start
            (r";", Keyword.Pseudo),                     # bundle end
            (r"^[A-Za-z][A-Za-z0-9_.]*(?=\s*:)", Name.Label),
            (r"\$r[0-9]+\b", Name.Variable),            # registers
            (r"\$v?[iuf][0-9]+\b", Keyword.Type),       # types
            (r"\$goto\b", Keyword),
            (r"\$(accumulate|replicate)\b", Keyword.Pseudo),
            (r"\$[a-z]+\b", Keyword),                   # $ld $st $cast $null $halt ...
            (r"_h[0-9a-fA-F]+", Number.Hex),
            (r"-?[0-9]+", Number.Integer),
            (r"\+\+|--|==|>=|<=|!=|<<|>>|~\||~&|~\^|[?+\-*/|&^<>]", Operator),
            (r"[()\[\]:]", Punctuation),
            (r"[A-Za-z][A-Za-z0-9_.]*", Name.Label),    # label references
        ],
    }

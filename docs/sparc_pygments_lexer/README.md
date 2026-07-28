# sparc_pygments_lexer/

A small Pygments lexer for SPARC V8 assembly, written for this repo's
own MkDocs documentation. Provides syntax highlighting for
```sparc ... ``` code blocks (see `docs/README.md` for how it's
installed).

Not a general-purpose SPARC assembler syntax lexer, just enough to
correctly highlight this project's own `.s` test programs, see any
`validation/asm/*.s` file. Pygments' built-in `asm` lexer (`GasLexer`)
gets this syntax wrong in a way that actually matters: it expects
`#`/`;`-style comments, not SPARC's `!`, so every `!` becomes an Error
token and the comment text after it gets highlighted as if it were code.

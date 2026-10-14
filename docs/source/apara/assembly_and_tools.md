# APARA Assembly Language and Tools

APARA programs are written in **mcode**, the engine's assembly language,
and assembled with our own tools in `compiler/apara/` (Python 3, standard
library only). For any program the APARA reference assembler accepts, the
tools write the same object file, word for word: they were checked on
every valid program in the APARA repository's test and verification
folders.

## A first program

```mcode
// Sum the 8-bit elements of a vector, store the result.
//@ reg: 0 $r1 0x0102030405060708

sum:
    ||
        $vreduce + $r2 ($vi8) $r1       // 1+2+...+8 = 36
    ;
store:
    ||
        $st ($i64) [$r0 + 16] $r2       // DMEM bytes 16..23
    ;
    || $halt ;
```

A program is a sequence of **bundles**, each `||`, one to eight
instructions, `;`. A bundle may have a label (`sum:`). `//` starts a
comment. Lines starting `//@` are directions for the test runner (Ref
[Writing and Running Programs](running.md)); the assembler ignores them.
Every instruction is listed in [APARA Instruction Set](isa.md).

## What the assembler does

1. **Parses and checks** every instruction: register numbers, types,
   immediate and increment ranges, the operations each type allows
   (Ref the error messages below).
2. **Checks each bundle**: at most 8 instructions, one branch/call/return,
   4 loads/stores, one divide or square root, and no register written by
   two instructions.
3. **Closes** each bundle with `$null`s up to its capacity: 8 if it holds a
   control transfer, load/store, divide or square root, else the next
   power of two.
4. **Places** the bundles, each at a multiple of its size, filling gaps
   with `$null` pad bundles of 4, 2 and 1 slots.
5. **Arranges the lanes** of each 8-slot bundle: the control transfer in
   lane 0, a divide or square root in lane 1, loads and stores in lanes 4
   to 7, the other instructions in source order in the free lanes.
6. **Resolves labels**: a branch or call holds its target relative to its
   own address (its bundle's address plus its lane).
7. **Encodes**, setting bit 31 on each bundle's first word.

These are the reference tools' passes (`mcode_align` then
`mcode_assemble`) in one step.

## The tools

```bash
python3 compiler/apara/apara_as.py prog.mcode                 # writes prog.obj
python3 compiler/apara/apara_as.py prog.mcode -o out.obj \
        --aligned prog.aligned.mcode --listing prog.lst
python3 compiler/apara/apara_dis.py prog.obj                  # mcode to standard output
```

- `--aligned` writes the program as placed and arranged, every bundle
  with its address: the program the engine actually runs.
- `--listing` writes each word's address, encoding and instruction.
- `apara_dis.py` turns an object file back into mcode, with labels `L_<address>`
  for branch and call targets. Its output assembles back to the same object
  file.

An error stops the assembly:

```text
prog.mcode:12: error: $r2 is written twice in this bundle (also at line 11)
```

Some messages and what they mean:

| Message | Cause |
|---|---|
| `immediate 600 is out of range (-512 to 511)` | immediates are 10-bit signed |
| `a bundle holds at most one divide or square root` | the engine has one shared divider |
| `floats have only + - * /` | no logic or shifts on float types |
| `the registers from $r30 run past $r31` | a `$u256` transfer needs 4 consecutive registers |
| `a vector cast changes the element width by one step` | `($vi8)` to `($vi32)` needs two casts |
| `undefined label x` | (the reference assembler silently uses 0) |

`python3 compiler/apara/test_mcode.py` runs the tools' own unit tests.

## File formats

The formats of the reference tools, so files move freely between the two
tool sets. Numbers are hexadecimal; `!` starts a comment.

| File | Lines | Example |
|---|---|---|
| object (`.obj`) | `<word index>: <instruction word>` | `8: 80000000` |
| data (`data.map`) | `<dword index>: <64-bit value>` | `10: 0x0102030405060708` |
| registers | `<thread> <register> <value>` | `0 1f 0x10` |
| results | `<thread> pc <pc> [mask]` | `0 pc 0x21` |
| | `<thread> reg <register> <value> [mask]` | `0 reg 0x5 0x67` |
| | `<thread> mem <dword index> <value> [mask]` | `0 mem 0x4 0x00aa000000001234` |
| | `<thread> error <ERROR> [mask]` (ours) | `0 error 0x2000000` |

A mask, if given, selects the bits compared. A data file's dword index is
taken modulo the DMEM size: index `0x10` is DMEM bytes 0x80 to 0x87.

## Editor support

- vim: `compiler/apara/vim/mcode.vim` (copy to `~/.vim/syntax/`, and add
  `au BufRead,BufNewFile *.mcode set filetype=mcode` to `~/.vimrc`).
- These pages highlight ```` ```mcode ```` blocks with the Pygments lexer in
  `docs/mcode_pygments_lexer/`.

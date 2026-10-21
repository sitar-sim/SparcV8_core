# APARA Assembly Language and Tools

APARA programs are written in **mcode**, the engine's assembly language,
and assembled with this project's own tools in `compiler/apara/`. (They
can also be written in a subset of C, see [The C Compiler](compiler.md),
which writes mcode for these tools.) The
tools are plain Python 3, using only the standard library, so there is
nothing to install.

The assembler checks programs strictly: it stops with an error on
anything it cannot encode exactly, rather than producing a wrong
program (see [Error messages](#error-messages)).

---

## A first program

```mcode
// Sum the 8-bit elements of a vector in $r1, store the result.

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

The program's three bundles run one after another:

1. `$vreduce` reads `$r1` as a vector of eight 8-bit signed elements and
   adds them up, into `$r2`.
2. `$st` stores `$r2`, as a 64-bit integer, at DMEM address `$r0 + 16`,
   that is, 16 (`$r0` is always 0).
3. `$halt` stops the thread.

`$r1` is set before the run: by a registers file given to the
simulator (see [File formats](#file-formats)), or, in a test, by the
`INIT` section of its `.vprj` (see [APARA Validation
Suite](validation.md#a-test)).

### Program structure

- **Bundles**  
    A program is a sequence of bundles. Each starts with `||`, holds one
    to eight instructions, and ends with `;`. A bundle may be written on
    one line or span several.
- **Labels**  
    A bundle may have a label (`sum:`), which branches and calls can name
    as their target.
- **Comments**  
    `//` starts a comment, to the end of the line.
- **Instructions**  
    Every instruction is listed in [APARA Instruction Set](isa.md).

---

## What the assembler does

Beyond translating each instruction, the assembler turns the bundles as
written into bundles the engine can run. It does this in seven steps:

1. **Parses and checks** every instruction: register numbers, types,
   immediate and increment ranges, and whether each operation is
   allowed for its type.
2. **Checks each bundle**: at most 8 instructions, at most one
   branch/call/return, at most 4 loads and stores, at most one divide or
   square root, and no register written by two instructions.
3. **Closes** each bundle, filling it with `$null`s up to its size: 8
   slots if it holds a control transfer, load or store, divide, or square
   root, otherwise the smallest power of two that fits.
4. **Places** the bundles in IMEM, each at an address that is a multiple
   of its size, filling any gaps with `$null` bundles.
5. **Arranges the slots** of each 8-slot bundle: the control transfer in
   slot 0, a divide or square root in slot 1, loads and stores in slots 4
   to 7, and the other instructions, in source order, in the free slots.
6. **Resolves labels**: a branch or call holds its target relative to its
   own address (its bundle's address plus its slot).
7. **Encodes** every instruction, setting bit 31 on each bundle's first
   word.

---

## The tools

The tools are run with `python3`, from the repository root. The
assembler and the disassembler translate between mcode and object files,
which the simulators load. Two more tools build on the assembler. One
writes a program as a C header for the SPARC side of `sparc_apara`, and
the other is the C compiler.

| Tool | Reads | Writes |
|---|---|---|
| `apara_as.py`, the assembler | mcode | an object file (`.obj`) |
| `apara_dis.py`, the disassembler | an object file | mcode |
| `apara_obj_to_c.py` | mcode, C, or an object file | a C header |
| `apcc.py`, the C compiler | C | mcode |

The assembler names its object file after the source, so the first
command below writes `prog.obj`. The option `-o` gives it another name.
Two more options write extra files. `--aligned` writes the program as
placed and arranged, with every bundle's address, which is the program
the engine actually runs. `--listing` writes each word's address,
encoding and instruction.

```bash
python3 compiler/apara/apara_as.py prog.mcode
python3 compiler/apara/apara_as.py prog.mcode --aligned prog.aligned.mcode --listing prog.lst
```

The disassembler writes mcode to standard output, and names branch and
call targets `L_<address>`. Its output assembles back to the same object
file.

```bash
python3 compiler/apara/apara_dis.py prog.obj
```

`apara_obj_to_c.py` is described in [Programming the
System](system_programming.md#carrying-the-engines-program), and
`apcc.py` in [The C Compiler](compiler.md).

`python3 compiler/apara/test_mcode.py` runs the assembler's and
disassembler's own unit tests. The `validation/apara/asm_errors/` suite
tests the assembler's checks. Each of its programs breaks one rule on
purpose, and passes only when the assembler rejects it with the expected
message.

### Error messages

Any error stops the assembly, with the file, the line, and the reason:

```text
prog.mcode:12: error: $r2 is written twice in this bundle (also at line 11)
```

Some messages, and what they mean:

| Message | Cause |
|---|---|
| `immediate 600 is out of range (-512 to 511)` | Immediates are 10-bit signed. |
| `a bundle holds at most one divide or square root` | The engine has one divider, shared by divides and square roots. |
| `floats have only + - * /` | No logic operations or shifts on float types. |
| `the registers from $r30 run past $r31` | A `$u256` transfer needs 4 consecutive registers. |
| `a vector cast changes the element width by one step` | `($vi8)` to `($vi32)` needs two casts. |
| `undefined label x` | A misspelled label. |

---

## File formats

The tools and the simulators share these file formats. In every
format, numbers are hexadecimal and `!` starts a comment.

| File | Lines | Example |
|---|---|---|
| object (`.obj`) | `<word index>: <instruction word>` | `8: 80000000` |
| data (`data.map`) | `<dword index>: <64-bit value>` | `10: 0x0102030405060708` |
| registers | `<thread> <register> <value>` | `0 1f 0x10` |
| results | `<thread> pc <pc> [mask]` | `0 pc 0x21` |
| | `<thread> reg <register> <value> [mask]` | `0 reg 0x5 0x67` |
| | `<thread> mem <dword index> <value> [mask]` | `0 mem 0x4 0x00aa000000001234` |
| | `<thread> error <ERROR> [mask]` (this project's addition) | `0 error 0x2000000` |

A data file gives DMEM's initial contents by dword (8-byte word) index,
taken modulo the DMEM size: index `0x10` is DMEM bytes 0x80 to 0x87. A
results file lists the expected final state, and a mask, if given,
selects the bits compared.

---

## Editor support

- **vim**: `compiler/apara/vim/mcode.vim`. Copy it to `~/.vim/syntax/`, and
  add `au BufRead,BufNewFile *.mcode set filetype=mcode` to `~/.vimrc`.
- **This documentation** highlights ```` ```mcode ```` code blocks with the
  Pygments lexer in `docs/mcode_pygments_lexer/`.

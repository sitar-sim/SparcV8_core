# APARA Instruction Set

This page is the programmer's reference for the APARA engine, as this
project models it: what state a program sees, the data types its
instructions work on, how instructions are grouped into bundles, and
every instruction, with its assembly syntax and its encoding.

Where this description departs from the engine's own documents, the
choice is listed in [Deviations and Findings](deviations.md).

---

## Engine state

### Threads

An engine runs up to **four hardware threads**. They share the
engine's memories and its pipeline, but each thread has its own
architectural state:

| State | Size | Notes |
|---|---|---|
| PC | 32 bits | The address of the thread's next bundle, as an instruction-word index into IMEM, not a byte address. |
| `$r0` .. `$r31` | 64 bits each | General-purpose registers. `$r0` always reads as 0, and writes to it are dropped. |
| Return-address stack (RAS) | 64 entries | Return addresses: `$call` pushes one, `$return` pops one. |
| ERROR | 32 bits | Why the thread stopped, see below. |

Four threads let the engine stay busy: while one thread waits (for a
result, a memory access, or a mispredicted branch), the pipeline runs
the others.

### Memories

| Memory | Size | Organization |
|---|---|---|
| IMEM | 16 KB, 4096 instruction words | The program, shared by all four threads. The pipeline reads it 8 words (one *line*) at a time. |
| DMEM | 64 KB, 8192 64-bit words | The data, shared by all four threads. Two banks of 32 KB (address bit 15 selects the bank), each accessed through its own port. **Big-endian**. |

DMEM addresses are byte addresses. Each 64-bit word ("dword") is stored
big-endian: the byte at an address with `(address & 7) == 0` is the
dword's most significant byte, bits [63:56].

What an address outside DMEM means depends on where the engine is:

- **On its own** (the `apara` configuration), every data address
  aliases into DMEM, modulo 64 KB.
- **In a system** (the `sparc_apara` configuration), DMEM appears at a
  window in the system's physical address space, and only addresses in
  that window are local. Every other address goes out to the system's
  memory, see [The Engine in a System](system.md#address-map).

### How a thread runs and stops

A thread is **inactive** until it is started at some PC. It is then
**running**, until it either executes `$halt` or meets an exception.
Either way it is then **halted**, and its ERROR register says why:

| ERROR bits | Meaning |
|---|---|
| 26 | Return-address stack error: a `$call` with the RAS full, or a `$return` with it empty. |
| 25 | The thread executed `$halt`. |
| 24 | An exception stopped the thread. |
| [23:0] | One 3-bit exception code per bundle slot: slot *s*'s code is in bits [3s+2 : 3s]. |

The exception codes:

| Code | Exception |
|---|---|
| 1 | Integer divide by zero. |
| 2 | Float divide by zero. |
| 3 | A float arithmetic result is not a number (NaN). |
| 4 | Reserved. The hardware's table lists "integer square root of a negative number", but there is no integer square root instruction. |
| 5 | Float square root of a negative number. |
| 6 | A memory address that is not a multiple of the transfer size. |
| 7 | An illegal instruction, an instruction in a slot it may not use (see [Bundles](#bundles)), or no valid bundle at the PC (reported in slot 0). |

A bundle that raises an exception **changes nothing**: no register,
memory, or PC update happens, and the thread halts with its PC at that
bundle. This makes the stopped state easy to examine: the PC names the
bundle that failed, and the registers are as they were before it.

---

## Data types

Every instruction that operates on data names a type, written in
parentheses: `($i32)`, `($vf16)`. A type gives an element width, and
whether the elements are integers or floats, signed or unsigned, and
one per register (a scalar) or packed several to a register (a vector).

| Types | Meaning |
|---|---|
| `$i4 $i8 $i16 $i32 $i64` | Signed integers. |
| `$u4 $u8 $u16 $u32 $u64` | Unsigned integers. |
| `$u128 $u256` | 2 and 4 registers, for memory transfers only. |
| `$f4 $f8 $f16 $f32 $f64` | Floats. |
| `$vi4 .. $vi32`, `$vu4 .. $vu32`, `$vf4 .. $vf32` | Vectors of signed, unsigned, or float elements. |

### Scalars

A scalar narrower than 64 bits lives in the low bits of a register. A
signed operation sign-extends its operands from the type's width, and an
unsigned integer operation uses the full 64-bit register values. Integer
ALU results are always 64 bits. Float results are in the type's own
format, in the register's low bits.

### Vectors

A vector packs `64 / width` elements into one register, with **element
0 in the most significant bits**. For example, `$r1 =
0x0102030405060708`, read as `($vi8)`, holds the eight elements 1, 2, 3,
4, 5, 6, 7, 8, in that order. A vector operation works on every element
at once, which is where the engine's speed on small data types comes
from: one `($vi8)` add is eight additions.

### Floats

`f32` and `f64` are IEEE single and double precision. The narrow formats
are for low-precision work:

- **`f16`** is IEEE half precision (5 exponent bits, 10 mantissa bits,
  bias 15).
- **`f8`** has 4 exponent bits and 3 mantissa bits (bias 7).
- **`f4`** holds just the values ±{0, 0.5, 1, 1.5, 2, 3, ∞, NaN}.

Arithmetic on the narrow formats is done in double precision and rounded
back to the narrow format with one round bit (round half up on the
magnitude), saturating to infinity, and flushing to zero below the
smallest subnormal.

---

## Bundles

The engine is a VLIW (very long instruction word) machine: instead of
discovering parallelism in hardware, it executes **bundles** of
instructions that the program has already grouped to run together. A
bundle holds 1, 2, 4, or 8 instructions of 32 bits each, all executed in
the same step:

- Every instruction of a bundle reads the registers **as they were
  before the bundle**. So a bundle that copies `$r1` into `$r2` and
  `$r2` into `$r1` swaps them.
- Memory accesses happen in slot order: a load sees a store of an
  earlier slot of the same bundle.
- No two instructions of a bundle may write the same register (the
  assembler checks this).

### Sizes and slots

A bundle's size, and which slot each instruction may occupy, follow the
hardware's execution lanes:

- A bundle that holds a branch, call, return, load, store, divide, or
  square root must have **8 slots**. Any other bundle has the smallest
  power of two (1, 2, 4, or 8) that fits its instructions. Unused slots
  hold `$null`.
- A bundle's address is a multiple of its size.
- In an 8-slot bundle, a branch, call, or return must be in **slot 0**, a
  divide or square root in **slot 1** (the engine has one shared divider),
  and loads and stores in **slots 4 to 7** (the memory lanes).

You don't have to arrange any of this by hand. The assembler closes,
pads, places, and arranges every bundle (see [What the assembler
does](assembly_and_tools.md#what-the-assembler-does)), and the engine
checks the rules when it runs the bundle (exception 7 if one is broken).

In the encoded program, bit 31 of an instruction word is set on the
first instruction of each bundle, which is how the engine finds bundle
boundaries. Bits [30:26] are the opcode.

---

## Instructions

The instructions below are shown in the syntax the assembler accepts.
`$rd` is the destination register, `$rs1` and `$rs2` the sources, and
`imm` a signed 10-bit immediate (-512 to 511).

### Arithmetic and logic (scalar)

```mcode
+  $rd (type) $rs1 $rs2       // also: - * / | & ^ ~| ~& ~^ << >>
+  $rd (type) $rs1 imm
```

`$rd = $rs1 op $rs2` (or `$rs1 op imm`). `~|`, `~&`, and `~^` are NOR,
NAND, and XNOR.

- **Integer types** have every operation. A signed `>>` is an arithmetic
  shift, shift counts use their low 6 bits, and `/` truncates toward
  zero. Dividing by zero raises exception 1.
- **Float types** have only `+ - * /`. Dividing by zero raises exception
  2, and a NaN result exception 3.

### Vector arithmetic

```mcode
$v + $rd (vtype) $rs1 $rs2                // also: - *
$v + $rd (vtype) $rs1 $rs2 $replicate     // $rs2's low element, used for every element
```

Element by element: element *i* of `$rd` is element *i* of `$rs1` plus
element *i* of `$rs2`. Integer results wrap around at the element width.
With `$replicate`, every element of `$rs1` is combined with the same
value, `$rs2`'s lowest element, for example to scale a vector.

### Dot product and reduction

```mcode
$dot $rd (vtype) $rs1 $rs2                // the sum of the element products
$dot $accumulate $rd (vtype) $rs1 $rs2    // the same, plus $rd
$vreduce + $rd (vtype) $rs1               // also: * | & ^ ~^
```

`$dot` multiplies two vectors element by element and adds up the
products. `$vreduce` combines all the elements of one vector with one
operation. Integer dot products and reductions give a 64-bit result.
Float ones give an `f32`, accumulated in single precision, one element
at a time.

### Square root

```mcode
$fsqrt $rd ($f32) $rs1                    // or ($f64)
```

A negative operand raises exception 5.

### Casts

```mcode
$cast (dtype) $rd (stype) $rs2
```

Converts `$rs2`, of type `stype`, to type `dtype`. Both types are
scalars, or both are vectors.

- **A scalar cast** converts the low bits of `$rs2`. Between integers,
  the value is sign- or zero-extended by the source type, then truncated
  to the destination width. Between integers and floats, the value is
  converted. A float-to-integer conversion truncates toward zero and
  saturates, and a NaN gives 0.
- **A vector cast** converts every element, and may change the element
  width by one step at most (`$vi8` to `$vi16`, for example, but not to
  `$vi32`). Widening doubles the data, so it writes two registers, `$rd`
  and `$rd+1`. Narrowing reads two, `$rs2` and `$rs2+1`.

### Moving and arranging bits

```mcode
$set   $rd index value          // $rd = value << (8*index); value 16 bits, index 0 to 7
$slice $rd high low $rs2        // $rd = bits [high:low] of $rs2
$pack  P $rd W $rs2             // the low W bits of $rs2, $rs2+1, ... packed into P bits
$cmov  (type) $rs1 cond [incr] $rd $rs2   // if $rs2 cond 0, then $rd = $rs1
```

- **`$set`** loads a constant. `value` may be decimal, or hexadecimal
  written `_h1234`.
- **`$pack`** gathers fields from consecutive registers: `$pack 64 $r8 16
  $r2` builds `$r8` from the low 16 bits of `$r2`, `$r3`, `$r4`, and
  `$r5`, with `$r2`'s field in the most significant position. A `P`
  larger than 64 writes `P/64` registers.
- **`$cmov`** is a conditional move. It tests its **last** register,
  `$rs2`, against 0. An optional increment (`++1`, `--1`, `--2`) is
  added to `$rs2` after the test, which makes `$cmov` useful as a loop
  step too.

The conditions, for `$cmov` and for branches, compare a value with 0:
`==  >  <  >=  <=  !=`. Signed integers compare as values of the type's
width, unsigned integers as 64-bit unsigned values, and floats by value
(a NaN satisfies only `!=`).

### Loads and stores

```mcode
$ld (type) $rd [$rs1 + $rs2]        $st (type) [$rs1 + $rs2] $rd
$ld (type) $rd [$rs1 + $rs2 ++n]    // then $rs2 += n * the transfer size (n: -16 to 15)
$ld (type) $rd [$rs1 + imm]
```

The address is `$rs1 + $rs2` (or `$rs1 + imm`), and must be a multiple of
the transfer size (exception 6 otherwise). The `++n` form also steps
`$rs2` on, for walking through an array.

- 1-, 2-, 4-, and 8-byte transfers move one register. Signed loads
  sign-extend.
- `$u128` and `$u256` move 2 and 4 registers, from `$rd` upward.
- A vector type moves one element.

### Control transfer

```mcode
? (type) $rs2 cond [incr] $goto label   // branch if $rs2 cond 0; then $rs2 += incr
$call label                             // or $call $rs2: the target is this address + $rs2
$return
$halt
$null
```

Branch and call targets are relative to the instruction's own address.
`$call` pushes the address of the next bundle onto the RAS, and
`$return` pops it. A branch's optional increment is -2 to 1, and is not
allowed with a float test type. Like `$cmov`'s, it lets one instruction
both count a loop down and test it.

`$halt` stops the thread. `$null` does nothing, and fills the unused
slots of a bundle.

---

## Encodings

The field layouts, as the assembler writes them. In every
instruction word, bit 31 is the bundle start bit and bits [30:26] the
opcode.

| Instruction | Opcode | Fields |
|---|---|---|
| ALU | 0x04-0x0F | type[25:21] rd[20:16] rs1[15:11] imm-flag[10] rs2[4:0] or imm10[9:0] |
| VALU | (ALU) | as ALU, with a vector type, and replicate[10] |
| FSQRT | 0x10 | type rd rs1 |
| DOT | 0x11 | type rd rs1 accumulate[10] rs2 |
| CAST | 0x12 | dest type[25:21] rd source type[14:10] rs2 |
| LOAD, STORE | 0x13, 0x14 | type rd rs1 imm-flag[10] incr[9:5] rs2, or imm10[9:0] |
| SET | 0x15 | byte index[23:21] rd value[15:0] |
| VREDUCE | 0x16 | type rd rs1 operation[10:6] (an ALU opcode) |
| CMOV | 0x17 | type rd rs1 cond[10:8] incr[7:6] rs2 |
| PACK | 0x18 | rd log2(P)[15:12] log2(W)[11:9] rs2 |
| SLICE | 0x19 | high[5:1] in [25:21], rd, high[0] in [15], low[14:9], rs2 |
| BRANCH | 0x02 | type[25:22] cond[21:19] incr[18:17] offset12[16:5] rs2 |
| CALL | 0x01 | label-flag[25], offset25[24:0] or rs2 |
| RETURN, NULL, HALT | 0x03, 0x1A, 0x1B | |

ALU opcodes: `+` 0x04, `-` 0x05, `*` 0x06, `/` 0x07, `|` 0x08, `&` 0x09,
`^` 0x0A, `~|` 0x0B, `~&` 0x0C, `~^` 0x0D, `<<` 0x0E, `>>` 0x0F.

Type codes: `$i4`..`$i64` 0x00-0x04, `$u4`..`$u64` 0x05-0x09,
`$f4`..`$f64` 0x0A-0x0E, `$u128` 0x0F, `$u256` 0x10, `$vu4`..`$vu32`
0x11-0x14, `$vf4`..`$vf32` 0x15-0x18, `$vi4`..`$vi32` 0x19-0x1C.

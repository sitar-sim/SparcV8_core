# APARA Instruction Set

This page is the programmer's reference for the APARA engine as this
model implements it: its state, its data types, bundles, and every
instruction. The model follows the APARA ISA (`engine_isp/isa/isa.txt` in
the APARA repository) and the reference model, McodeMachine; where the two
disagree, or the reference model has a defect, the model's choice is
listed in [Deviations and Findings](deviations.md).

## Engine state

An engine runs up to **four threads**. They share the engine's two local
memories and its execution pipeline, and each has its own architectural
state:

| State | Size | Notes |
|---|---|---|
| PC | 32 bits | a **word** index into IMEM, not a byte address |
| `$r0` .. `$r31` | 64 bits each | `$r0` reads as 0; writes to it are dropped |
| return-address stack (RAS) | 64 entries | pushed by `$call`, popped by `$return` |
| ERROR | 32 bits | why the thread stopped (below) |

| Memory | Size | Organization |
|---|---|---|
| IMEM | 16 KB, 4096 instruction words | read by the pipeline 8 words (one *line*) at a time |
| DMEM | 64 KB, 8192 64-bit words | two 32 KB banks (address bit 15), **big-endian** |

DMEM addresses are byte addresses. Each 64-bit word ("dword") is
big-endian: the byte at an address with `(address & 7) == 0` is bits
[63:56]. In the standalone engine every data address aliases into DMEM
(modulo 64 KB). In a system (the `sparc_apara` configuration), other
addresses reach system memory.

A thread is *inactive* until started, then *running* until it executes
`$halt` or meets an exception, after which it is *halted*. ERROR tells
which:

| ERROR bits | Meaning |
|---|---|
| 26 | return-address stack error: `$call` with the RAS full, or `$return` with it empty |
| 25 | the thread executed `$halt` |
| 24 | an exception stopped the thread |
| [23:0] | one 3-bit exception code per bundle slot, slot *s* in bits [3s+2 : 3s] |

| Code | Exception |
|---|---|
| 1 | integer divide by zero |
| 2 | float divide by zero |
| 3 | a float arithmetic result is not a number (NaN) |
| 4 | (reserved: integer square root of a negative number in the hardware's table; there is no integer square root) |
| 5 | float square root of a negative number |
| 6 | memory address not a multiple of the transfer size |
| 7 | illegal instruction, an instruction in a slot it cannot use, or no valid bundle at the PC (slot 0) |

A bundle that raises an exception **changes nothing**: no register,
memory or PC update happens, and the thread halts with its PC at that
bundle.

## Data types

Every instruction that operates on data names a type, written in
parentheses: `($i32)`, `($vf16)`. A type is an element width and three
flags.

| Types | Meaning |
|---|---|
| `$i4 $i8 $i16 $i32 $i64` | signed integers |
| `$u4 $u8 $u16 $u32 $u64` | unsigned integers |
| `$u128 $u256` | 2 and 4 registers, for memory transfers only |
| `$f4 $f8 $f16 $f32 $f64` | floats |
| `$vi4 .. $vi32`, `$vu4 .. $vu32`, `$vf4 .. $vf32` | vectors of signed, unsigned or float elements |

**Scalars** narrower than 64 bits live in the low bits of a register.
A signed operation sign-extends its operands from the type's width; an
unsigned integer operation uses the full 64-bit register values. Integer
ALU results are 64 bits. Float results are in the type's format, in the
low bits.

**Vectors** pack `64/width` elements in one register, **element 0 in the
most significant bits**: `$r1 = 0x0102030405060708` as `($vi8)` holds the
elements 1, 2, 3, 4, 5, 6, 7, 8 in that order.

**Floats**: f32 and f64 are IEEE single and double precision. f16 is IEEE
half precision (E5M10, bias 15), f8 is E4M3 (bias 7), and f4 holds the
values ±{0, 0.5, 1, 1.5, 2, 3, ∞, NaN}. Arithmetic on narrow floats is done
in double precision and rounded back with one round bit (round half up on
the magnitude), saturating to infinity, flushing to zero below the smallest
subnormal: the reference model's conversion rules exactly.

## Bundles

Instructions are 32 bits. They run in **bundles** of 1, 2, 4 or 8, all
the instructions of a bundle in parallel:

- Every instruction of a bundle reads the registers as they were before
  the bundle. A bundle that swaps two registers just copies each into the
  other.
- Memory accesses happen in slot order: a load sees a store of an earlier
  slot of the same bundle.
- Register writes apply in slot order, but no two instructions of a bundle
  may write the same register (the assembler checks this).

A bundle that holds a branch, call, return, load, store, divide or square
root must have **8 slots**; any other bundle has the next power of two
(1, 2, 4 or 8) at least as large as its instruction count. Unused slots
hold `$null`. A bundle's address is a multiple of its size. In an 8-slot
bundle, a branch/call/return must be in slot 0, a divide or square root in
slot 1, and loads and stores in slots 4 to 7. The assembler does all of
this (closing, padding, placing, arranging); the engine checks it.

Bit 31 of an instruction word is set on the first instruction of each
bundle; bits [30:26] are the opcode.

## Instructions

Syntax in the forms the assembler accepts. `$rd` is the destination,
`$rs1`/`$rs2` the sources, `imm` a signed 10-bit immediate (-512 to 511).

### Arithmetic and logic (scalar)

```mcode
+  $rd (type) $rs1 $rs2       // also: - * / | & ^ ~| ~& ~^ << >>
+  $rd (type) $rs1 imm
```

`$rd = $rs1 op $rs2` (or `imm`). `~|`, `~&`, `~^` are NOR, NAND, XNOR. For
integer types, every operation; a signed `>>` is arithmetic, shift counts
use their low 6 bits, and `/` truncates toward zero (divide by zero is
exception 1). For float types, only `+ - * /` (divide by zero is
exception 2, a NaN result exception 3).

### Vector arithmetic

```mcode
$v + $rd (vtype) $rs1 $rs2                // also: - *
$v + $rd (vtype) $rs1 $rs2 $replicate     // $rs2's low element for every element
```

Element by element, results wrapping at the element width.

### Dot product and reduction

```mcode
$dot $rd (vtype) $rs1 $rs2                // sum of element products
$dot $accumulate $rd (vtype) $rs1 $rs2    // ... plus $rd
$vreduce + $rd (vtype) $rs1               // also: * | & ^ ~^
```

Integer dot products and reductions give a 64-bit result; float ones an
f32, accumulated in single precision one element at a time.

### Square root

```mcode
$fsqrt $rd ($f32) $rs1                    // or ($f64)
```

### Casts

```mcode
$cast (dtype) $rd (stype) $rs2
```

Scalar to scalar, or vector to vector. A scalar cast converts the low bits
of `$rs2`: integers are sign- or zero-extended by the source type, then
truncated to the destination width; integer/float conversions convert the
value (float to integer truncates toward zero and saturates; NaN gives 0).
A vector cast converts every element and may change the element width by
one step: widening writes `$rd` and `$rd+1`, narrowing reads `$rs2` and
`$rs2+1`.

### Moving and arranging bits

```mcode
$set   $rd index value          // $rd = value << (8*index), value 16 bits, index 0-7
$slice $rd high low $rs2        // $rd = bits [high:low] of $rs2
$pack  P $rd W $rs2             // the low W bits of $rs2, $rs2+1, ... packed into P bits
$cmov  (type) $rs1 cond [incr] $rd $rs2   // if $rs2 cond 0 then $rd = $rs1
```

`$pack 64 $r8 16 $r2` builds `$r8` from the low 16 bits of `$r2` .. `$r5`,
`$r2` in the most significant position; `P` above 64 writes `P/64`
registers. `$cmov` tests its **last** register (`$rs2`), and an optional
increment (`++1`, `--1`, `--2`) is added to `$rs2` after the test.
`value` may be decimal or hexadecimal written `_h1234`.

Conditions, for `$cmov` and branches, compare a value with 0: `==  >  <
>=  <=  !=`. Signed integers compare as values of the type's width,
unsigned integers as 64-bit unsigned values, floats by value (a NaN
satisfies only `!=`).

### Loads and stores

```mcode
$ld (type) $rd [$rs1 + $rs2]        $st (type) [$rs1 + $rs2] $rd
$ld (type) $rd [$rs1 + $rs2 ++n]    // then $rs2 += n * transfer size (n: -16..15)
$ld (type) $rd [$rs1 + imm]
```

The address is `$rs1 + $rs2` (or `+ imm`), and must be a multiple of the
transfer size (exception 6). 1-, 2-, 4- and 8-byte transfers move one
register (signed loads sign-extend); `$u128` and `$u256` move 2 and 4
registers, `$rd` up. A vector type moves one element.

### Control transfer

```mcode
? (type) $rs2 cond [incr] $goto label   // branch if $rs2 cond 0; then $rs2 += incr
$call label                             // or $call $rs2: target = this address + $rs2
$return
$halt
$null
```

Branch and call targets are relative to the instruction's own address.
`$call` pushes the address of the next bundle on the RAS; `$return` pops
it. A branch increment is -2 to 1, and not allowed with a float test type.

## Encodings

The field layouts, as the reference assembler writes them (bit 31 is the
bundle start bit, bits [30:26] the opcode):

| Instruction | Opcode | Fields |
|---|---|---|
| ALU | 0x04-0x0F | type[25:21] rd[20:16] rs1[15:11] imm-flag[10] rs2[4:0] or imm10[9:0] |
| VALU | (ALU) | vector type, replicate[10] |
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
`^` 0x0A, `~|` 0x0B, `~&` 0x0C, `~^` 0x0D, `<<` 0x0E, `>>` 0x0F. Type codes:
`$i4`..`$i64` 0x00-0x04, `$u4`..`$u64` 0x05-0x09, `$f4`..`$f64`
0x0A-0x0E, `$u128` 0x0F, `$u256` 0x10, `$vu4`..`$vu32` 0x11-0x14,
`$vf4`..`$vf32` 0x15-0x18, `$vi4`..`$vi32` 0x19-0x1C.

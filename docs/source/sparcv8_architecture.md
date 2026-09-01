# SPARC V8 Architecture

SPARC (Scalable Processor ARChitecture) is a RISC instruction set
architecture originally developed at Sun Microsystems, derived from the
Berkeley RISC I/II research designs. SPARC V8 is the 32-bit revision of
this architecture, standardized as ANSI/IEEE Std 1754-1994. See the
[Wikipedia SPARC article](https://en.wikipedia.org/wiki/SPARC) for
general background and history.

SPARC's most distinctive architectural feature is a **register window**
file. A procedure call can get a fresh set of registers without
spilling to memory, simply by advancing a circular window into a larger
physical register file.

The authoritative specification is
[*The SPARC Architecture Manual, Version 8*](sparcv8_Architecture_reference_Manual.pdf),
included in this repository. This project's model follows it closely,
with section references cited throughout the source
(`model/cpp_common_code/SparcCore.cpp` in particular).

---

## Why this page exists

The manual PDF has no hyperlinked table of contents or bookmarks of its
own, so jumping to a specific chapter or section means scrolling through
295 pages by hand. Every entry in the tables below links directly to
that chapter, appendix, or section's own starting page in the bundled
PDF.

Page numbers below are the manual's own printed page numbers (the
ones in each page's footer, also what this project's own source
comments cite), not the PDF file's raw page count. The two drift apart
by the end of the document.

---

## Chapters

| Chapter | Title | What it's about | Pages |
|---|---|---|---|
| 1 | [Introduction](sparcv8_Architecture_reference_Manual.pdf#page=4) | What SPARC is, its design goals and principal features, and how conformance/compliance is defined. | 1-8 |
| 2 | [Overview](sparcv8_Architecture_reference_Manual.pdf#page=11) | The architecture end to end, briefly: registers, instruction categories, traps, memory. The best single starting point for a first read. | 9-16 |
| 3 | [Data Formats](sparcv8_Architecture_reference_Manual.pdf#page=18) | Integer, floating-point (single/double/quad), and tagged-arithmetic data formats. | 17-22 |
| 4 | [Registers](sparcv8_Architecture_reference_Manual.pdf#page=23) | The register file and windowing mechanism in full detail, `PSR`/`WIM`/`TBR` and every other state register. | 23-42 |
| 5 | [Instructions](sparcv8_Architecture_reference_Manual.pdf#page=42) | The instruction set itself: formats, addressing modes, every opcode. | 43-58 |
| 6 | [Memory Model](sparcv8_Architecture_reference_Manual.pdf#page=57) | Total Store Ordering (TSO) and Partial Store Ordering (PSO), and what ordering guarantees software can rely on. | 59-68 |
| 7 | [Traps](sparcv8_Architecture_reference_Manual.pdf#page=67) | Trap handling, priorities, and the trap table, directly relevant to how every test program in this repository halts. See [Writing and Running Assembly Programs](writing_and_running_assembly_programs.md#the-pass-fail-convention). | 69-80 |

---

## Appendices

The manual skips the letter I (to avoid confusion with the numeral 1),
so there is no Appendix I.

| Appendix | Title | What it's about | Pages |
|---|---|---|---|
| A | [Suggested Assembly Language Syntax](sparcv8_Architecture_reference_Manual.pdf#page=79) | The assembly mnemonics and operand syntax used throughout the rest of the manual, and by this project's own `.s` test programs. | 81-86 |
| B | [Instruction Definitions](sparcv8_Architecture_reference_Manual.pdf#page=85) | Every instruction, one by one: encoding, operands, and a plain-language description. The reference to look an opcode up in. | 87-150 |
| C | [ISP Descriptions](sparcv8_Architecture_reference_Manual.pdf#page=148) | The same instructions again, but as precise pseudocode (ISP notation). This is what `model/cpp_common_code/SparcCore.cpp` implements almost line for line, see the table below. | 151-188 |
| D | [Software Considerations](sparcv8_Architecture_reference_Manual.pdf#page=185) | Conventions and assumptions a compiler or operating system can rely on, e.g. register-window overflow/underflow handling. | 189-204 |
| E | [Example Integer Multiplication and Division Routines](sparcv8_Architecture_reference_Manual.pdf#page=201) | Worked software routines for multiply/divide/remainder, for implementations that don't have them in hardware. | 205-226 |
| F | [Opcodes and Condition Codes](sparcv8_Architecture_reference_Manual.pdf#page=223) | Tables of every opcode's bit encoding and every condition code's meaning. Handy as a quick lookup alongside Appendix B. | 227-232 |
| G | [SPARC ABI Software Considerations](sparcv8_Architecture_reference_Manual.pdf#page=228) | The calling convention and binary-compatibility rules SPARC application binaries follow. | 233-240 |
| H | [SPARC Reference MMU Architecture](sparcv8_Architecture_reference_Manual.pdf#page=236) | A suggested (not mandatory) MMU design. See [Model Components](model_components.md). | 241-268 |
| J | [Programming with the Memory Model](sparcv8_Architecture_reference_Manual.pdf#page=262) | An intuitive, example-driven companion to Chapter 6's memory model. | 269-280 |
| K | [Formal Specification of the Memory Model](sparcv8_Architecture_reference_Manual.pdf#page=273) | The same memory model again, stated formally and precisely. | 281-288 |
| L | [Implementation Characteristics](sparcv8_Architecture_reference_Manual.pdf#page=281) | How specific historical SPARC chips actually implemented the architecture, including which instructions they left unimplemented in hardware. | 289-296 |
| M | [Instruction Set Summary](sparcv8_Architecture_reference_Manual.pdf#page=289) | A compact, one-line-per-instruction summary table of the entire instruction set. | 297-298 |
| N | [SPARC IEEE 754 Implementation Recommendations](sparcv8_Architecture_reference_Manual.pdf#page=291) | How the floating-point unit should handle IEEE 754 details the standard itself leaves open. | 299-303 |

---

## Appendix C in detail

Appendix C is the one this project's core implementation
(`model/cpp_common_code/SparcCore.cpp`) cites most, its section numbers
appear directly in source comments throughout that file and
`model/cpp_common_code/SparcStateMachine.cpp`.

| Section | Title | What it's about | Page |
|---|---|---|---|
| C.1 | [ISP Notation](sparcv8_Architecture_reference_Manual.pdf#page=148) | The pseudocode notation itself, adapted from Bell and Newell's 1971 ISP notation. | 151 |
| C.2 | [Processor External Interface Definition](sparcv8_Architecture_reference_Manual.pdf#page=149) | The signals and macros the rest of Appendix C's pseudocode is built from. | 152 |
| C.3 | [Register Field Definitions](sparcv8_Architecture_reference_Manual.pdf#page=151) | How register bit-fields are named and addressed in the pseudocode that follows. | 154 |
| C.4 | [Instruction Field Definitions](sparcv8_Architecture_reference_Manual.pdf#page=153) | How instruction-word bit-fields (`op`, `rd`, `rs1`, `simm13`, and so on) are named in the pseudocode that follows. | 156 |
| C.5 | [Processor States and Instruction Dispatch](sparcv8_Architecture_reference_Manual.pdf#page=153) | The top-level `execute_mode`/`reset_mode`/`error_mode` state machine and fetch-decode-execute-trap loop. `SparcStateMachine::runOneCycle()` implements this loop directly. | 156 |
| C.6 | [Instruction Dispatch](sparcv8_Architecture_reference_Manual.pdf#page=156) | The `dispatch_instruction` macro: how an instruction is routed to integer, FPop, or CPop execution. | 159 |
| C.7 | [Floating-point Execution](sparcv8_Architecture_reference_Manual.pdf#page=157) | The `complete_fp_execution` macro: floating-point trap checks and the Floating-point State Register (`FSR`). | 160 |
| C.8 | [Traps](sparcv8_Architecture_reference_Manual.pdf#page=158) | The `execute_trap` macro: how the highest-priority pending trap is selected and dispatched. `SparcCore::executeTraps()` implements this. | 161 |
| C.9 | [Instruction Definitions](sparcv8_Architecture_reference_Manual.pdf#page=160) | The ISP pseudocode for every instruction, one by one. This is the definition each `SparcCore::execute_*()` function follows. | 163 |
| C.10 | [Floating-Point Operate Instructions](sparcv8_Architecture_reference_Manual.pdf#page=181) | Notation specific to the multiple-precision floating-point instructions (register-pair/quad alignment). | 184 |

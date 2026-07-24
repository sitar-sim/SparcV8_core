#!/bin/bash
# compile_c.sh <input.c> [output_prefix]
#
# Compiles, links, and hex-dumps a standalone, freestanding SPARC V8 C test
# program, producing a memory-image hex-dump file (<output_prefix>.hex)
# directly loadable via MemCore::initializeMemory() -- same format, same
# linker script (sparc.ld), same hex-dump step as assemble.sh uses for
# assembly test programs, so both kinds of test produce an identical kind
# of memory image.
#
# Links crt0.s ahead of the test's own object. crt0.s sets up the stack,
# enables traps, and installs the same 256-entry trap table every
# validation/asm/ test has, then calls the test's main() (see crt0.s for
# why all of this is needed). The linker's entry point is overridden to
# crt0.s's _start (sparc.ld's own ENTRY(main) is for assembly tests, which
# are their own entry point with no separate startup code).
#
# Also produces <output_prefix>.objdump, a readable disassembly of the
# linked program, useful for seeing what the compiler actually generated
# (unlike a hand-written .s file, this isn't something the test's author
# wrote directly).
#
# Requires the sparc-elf toolchain on PATH -- run
#     source compiler/toolchain_env.sh
# first (after compiler/install_toolchain.sh, if not done already).
#
# The compile step is deliberately split in two: gcc compiles down to
# assembly text only (-S), and never invokes an assembler or linker of its
# own. The bundled sparc-elf-gcc's own internal calls to `as`/`ld` resolve
# to the host's native assembler/linker instead of the sparc-elf ones, so
# assembling and linking are always done here as separate, explicit steps
# with sparc-elf-as/sparc-elf-ld, the same tools assemble.sh uses.
#
# This split-step approach, and the overall compile/link/hex-dump/objdump
# sequence, follows the AJIT processor project's own compileToSparc.py
# script (see AUTHORS and validation/README.md).

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -lt 1 ]; then
	echo "Usage: $0 <input.c> [output_prefix]"
	exit 1
fi

INPUT="$1"
PREFIX="${2:-${INPUT%.c}}"

sparc-elf-as -Av8 -am "$SCRIPT_DIR/crt0.s" -o "$PREFIX.crt0.o"
sparc-elf-gcc -S -O0 -Wall -mcpu=v8 -ffreestanding -nostdlib "$INPUT" -o "$PREFIX.s"
sparc-elf-as -Av8 -am "$PREFIX.s" -o "$PREFIX.o"
sparc-elf-ld -T "$SCRIPT_DIR/sparc.ld" -e _start "$PREFIX.crt0.o" "$PREFIX.o" -o "$PREFIX.elf"
sparc-elf-readelf --hex-dump=.text --hex-dump=.rodata --hex-dump=.data "$PREFIX.elf" \
	| python3 "$SCRIPT_DIR/hexdump_to_memimage.py" > "$PREFIX.hex"
sparc-elf-objdump -d "$PREFIX.elf" > "$PREFIX.objdump"

echo "Built $PREFIX.hex"

#!/bin/bash
# assemble.sh <input.s> [output_prefix]
#
# Assembles and links a standalone SPARC V8 assembly test program, and
# produces a memory-image hex-dump file (<output_prefix>.hex) directly
# loadable via MemCore::initializeMemory().
#
# Also produces <output_prefix>.objdump: a readable disassembly of the
# linked program, followed by its full symbol table (see compile_c.sh's own
# file comment for why -- same reasoning applies here).
#
# Requires the sparc-elf toolchain on PATH -- run
#     source compiler/toolchain_env.sh
# first (after compiler/install_toolchain.sh, if not done already).

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -lt 1 ]; then
	echo "Usage: $0 <input.s> [output_prefix]"
	exit 1
fi

INPUT="$1"
PREFIX="${2:-${INPUT%.s}}"

sparc-elf-as -Av8 -am "$INPUT" -o "$PREFIX.o"
sparc-elf-ld -T "$SCRIPT_DIR/sparc.ld" -e main "$PREFIX.o" -o "$PREFIX.elf"
sparc-elf-readelf --hex-dump=.text --hex-dump=.rodata --hex-dump=.data "$PREFIX.elf" \
	| python3 "$SCRIPT_DIR/hexdump_to_memimage.py" > "$PREFIX.hex"
sparc-elf-objdump -d "$PREFIX.elf" > "$PREFIX.objdump"
echo "" >> "$PREFIX.objdump"
echo "Symbol table:" >> "$PREFIX.objdump"
echo "" >> "$PREFIX.objdump"
sparc-elf-readelf -s "$PREFIX.elf" >> "$PREFIX.objdump"

echo "Built $PREFIX.hex"

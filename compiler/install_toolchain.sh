#!/bin/bash
# install_toolchain.sh
#
# Unpacks the prebuilt sparc-elf cross-assembler/linker/readelf (see
# README.md for exact versions, source citation, and platform support)
# into compiler/toolchain/.
#
# After running this once, add the toolchain to your PATH for a shell
# session with:
#     source compiler/toolchain_env.sh
# (add that same line to your shell rc file to make it permanent).

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"
unzip -o -q sparc-elf-toolchain-i386.zip -d toolchain
chmod +x toolchain/bin/*

echo "Installed toolchain to $SCRIPT_DIR/toolchain/bin"
echo "Run:  source $SCRIPT_DIR/toolchain_env.sh"
echo "to add it to your PATH for this shell session."

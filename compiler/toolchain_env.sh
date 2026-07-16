# toolchain_env.sh
#
# Source this file (do not execute it) to add the sparc-elf cross toolchain
# to your PATH for the current shell session:
#
#     source compiler/toolchain_env.sh
#
# Add the same line to your shell rc file (~/.bashrc etc.) to make it
# permanent. Run install_toolchain.sh first if compiler/toolchain/ doesn't
# exist yet.

SPARC_TOOLCHAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/toolchain/bin"
export PATH="$SPARC_TOOLCHAIN_DIR:$PATH"

#!/usr/bin/env bash
# check.sh: build and check @NAME@ without a board (tinygo-box run bash check.sh). Exit 3 = a sibling tool is missing.
set -euo pipefail
cd "$(dirname "$0")"
: "${TINYGO_BOX_ROOT:?run through: tinygo-box run bash check.sh}"
mkdir -p build
artifact() { local mode=$1 file; file=$(realpath "$2"); shift 2; go -C "$TINYGO_BOX_ROOT/tools/elfinfo" run . "$mode" "$file" "$@"; }
target=${TARGET:-esp32c3-supermini}   # also: esp32c3-generic, xiao-esp32c3, qtpy-esp32c3, m5stamp-c3
tinygo build -target "$target" -size short -o build/@NAME@.bin .
tinygo build -target "$target" -o build/@NAME@.elf .
artifact esp build/@NAME@.bin -chip esp32c3
artifact elf build/@NAME@.elf -machine riscv -sym main.main
echo "PASS @NAME@ (flash build/@NAME@.bin at 0x0 with esptool/espflash: 32_15_flashers)"

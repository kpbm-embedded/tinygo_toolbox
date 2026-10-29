#!/usr/bin/env bash
# check.sh: build and check @NAME@ without a board (tinygo-box run bash check.sh). Exit 3 = a sibling tool is missing.
set -euo pipefail
cd "$(dirname "$0")"
: "${TINYGO_BOX_ROOT:?run through: tinygo-box run bash check.sh}"
mkdir -p build
artifact() { local mode=$1 file; file=$(realpath "$2"); shift 2; go -C "$TINYGO_BOX_ROOT/tools/elfinfo" run . "$mode" "$file" "$@"; }
tinygo build -target ./blackpill-f411.json -size short -o build/@NAME@.elf .
tinygo build -target ./blackpill-f411.json -o build/@NAME@.bin .
artifact elf build/@NAME@.elf -machine arm -region 0x08000000:512K -region 0x20000000:128K -sym main.main
echo "PASS @NAME@ (flash build/@NAME@.bin at 0x08000000: ST-Link/probe-rs or DFU, 32_15_flashers)"

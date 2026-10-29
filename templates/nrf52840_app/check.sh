#!/usr/bin/env bash
# check.sh: build and check @NAME@ without a board (tinygo-box run bash check.sh). Exit 3 = a sibling tool is missing.
set -euo pipefail
cd "$(dirname "$0")"
: "${TINYGO_BOX_ROOT:?run through: tinygo-box run bash check.sh}"
mkdir -p build
artifact() { local mode=$1 file; file=$(realpath "$2"); shift 2; go -C "$TINYGO_BOX_ROOT/tools/elfinfo" run . "$mode" "$file" "$@"; }
target=${TARGET:-nicenano}   # other nRF52840 boards: xiao-ble, nrf52840-s140v6-uf2-generic, pca10059
tinygo build -target "$target" -size short -o build/@NAME@.uf2 .
tinygo build -target "$target" -o build/@NAME@.elf .
artifact uf2 build/@NAME@.uf2 -family 0xADA52840
artifact elf build/@NAME@.elf -machine arm -region 0x26000:0xCE000 -region 0x20000000:256K
echo "PASS @NAME@ (flash: double-tap reset, copy build/@NAME@.uf2 to the bootloader drive)"

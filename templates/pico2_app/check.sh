#!/usr/bin/env bash
# check.sh: build and check @NAME@ without a board (tinygo-box run bash check.sh). Exit 3 = a sibling tool is missing.
set -euo pipefail
cd "$(dirname "$0")"
: "${TINYGO_BOX_ROOT:?run through: tinygo-box run bash check.sh}"
mkdir -p build
artifact() { local mode=$1 file; file=$(realpath "$2"); shift 2; go -C "$TINYGO_BOX_ROOT/tools/elfinfo" run . "$mode" "$file" "$@"; }
tinygo test ./pattern
tinygo build -target pico2 -size short -o build/@NAME@.uf2 .
artifact uf2 build/@NAME@.uf2 -family 0xe48bff59
echo "PASS @NAME@ (flash: hold BOOTSEL, copy build/@NAME@.uf2 to the RP2350 drive)"

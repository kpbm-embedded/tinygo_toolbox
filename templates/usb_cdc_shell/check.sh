#!/usr/bin/env bash
# check.sh: build and check @NAME@ without a board (tinygo-box run bash check.sh). Exit 3 = a sibling tool is missing.
set -euo pipefail
cd "$(dirname "$0")"
: "${TINYGO_BOX_ROOT:?run through: tinygo-box run bash check.sh}"
mkdir -p build
artifact() { local mode=$1 file; file=$(realpath "$2"); shift 2; go -C "$TINYGO_BOX_ROOT/tools/elfinfo" run . "$mode" "$file" "$@"; }
tinygo test ./shell && go test -count=1 ./shell
for t in pico nicenano esp32c3-supermini; do tinygo build -target "$t" -size short -o "build/@NAME@-$t.elf" .; done
echo "PASS @NAME@ (open the port with 32_11_serial or: picocom /dev/ttyACM0)"

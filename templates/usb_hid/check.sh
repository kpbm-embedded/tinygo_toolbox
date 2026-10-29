#!/usr/bin/env bash
# check.sh: build and check @NAME@ without a board (tinygo-box run bash check.sh). Exit 3 = a sibling tool is missing.
set -euo pipefail
cd "$(dirname "$0")"
: "${TINYGO_BOX_ROOT:?run through: tinygo-box run bash check.sh}"
mkdir -p build
artifact() { local mode=$1 file; file=$(realpath "$2"); shift 2; go -C "$TINYGO_BOX_ROOT/tools/elfinfo" run . "$mode" "$file" "$@"; }
for t in ${TARGETS:-pico pico2}; do   # GP14/GP15 are RP2xxx pin names; change them for other boards
  tinygo build -target "$t" -size short -o "build/@NAME@-$t.uf2" .
  tinygo build -target "$t" -o "build/@NAME@-$t.elf" .
  syms=$(go tool nm "build/@NAME@-$t.elf")
  for s in "keyboard.keyboard).sendKey" "machine/usb/hid/mouse" "machine/usb/hid.setupHandler" "machine/usb/cdc"; do   # Move is inlined
    grep -qF "$s" <<<"$syms" || { echo "FAIL: $s missing on $t"; exit 1; }
  done
  grep -aq "@NAME@" "build/@NAME@-$t.uf2" || { echo "FAIL: product string missing"; exit 1; }
done
echo "PASS @NAME@ (enumeration needs a board: copy the UF2 in BOOTSEL mode, then lsusb)"

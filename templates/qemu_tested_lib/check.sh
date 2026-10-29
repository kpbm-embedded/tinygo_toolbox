#!/usr/bin/env bash
# check.sh: build and check @NAME@ without a board (tinygo-box run bash check.sh). Exit 3 = a sibling tool is missing.
set -euo pipefail
cd "$(dirname "$0")"
: "${TINYGO_BOX_ROOT:?run through: tinygo-box run bash check.sh}"
mkdir -p build
artifact() { local mode=$1 file; file=$(realpath "$2"); shift 2; go -C "$TINYGO_BOX_ROOT/tools/elfinfo" run . "$mode" "$file" "$@"; }
{ command -v qemu-system-arm && command -v qemu-system-riscv32; } >/dev/null || { echo "skip: QEMU not found (32_10_qemu: BOX_QEMU_EMBEDDED)"; exit 3; }
tinygo test ./codec                          # host, TinyGo compiler
go test -count=1 ./codec                     # host, standard Go
for t in cortex-m-qemu riscv-qemu; do        # the same tests on emulated MCUs
  timeout 180 tinygo test -target "$t" ./codec
done
echo "PASS @NAME@"

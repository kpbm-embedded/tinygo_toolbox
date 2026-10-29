#!/usr/bin/env bash
# check.sh: build and check @NAME@ without a board (tinygo-box run bash check.sh). Exit 3 = a sibling tool is missing.
set -euo pipefail
cd "$(dirname "$0")"
: "${TINYGO_BOX_ROOT:?run through: tinygo-box run bash check.sh}"
mkdir -p build
[[ -x "${ZIG_ID:-}/microzig-box" ]] || { echo "skip: 32_24_microzig not found (BOX_MICROZIG)"; exit 3; }
command -v qemu-system-riscv32 >/dev/null || { echo "skip: qemu-system-riscv32 not found (32_10_qemu: BOX_QEMU_EMBEDDED)"; exit 3; }
# riscv-qemu here; for a board use its CPU, e.g. thumb-freestanding-eabi -mcpu cortex_m0plus + "inherits": ["pico"]
"$ZIG_ID/microzig-box" zig build-obj -target riscv32-freestanding-none -mcpu generic_rv32+m+a+c -O ReleaseSmall \
  -fno-stack-check --cache-dir "$PWD/build/zig-cache" -femit-bin="$PWD/build/filter.o" zig/filter.zig
printf '{"inherits": ["riscv-qemu"], "ldflags": ["%s"]}\n' "$PWD/build/filter.o" >build/riscv-qemu-zig.json
out=$(timeout 120 tinygo run -target "$PWD/build/riscv-qemu-zig.json" . 2>&1); echo "$out"
grep -q "@NAME@: ema 99[0-9]" <<<"$out" || { echo "FAIL: unexpected output"; exit 1; }
echo "PASS @NAME@"

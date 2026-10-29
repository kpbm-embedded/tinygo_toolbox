#!/usr/bin/env bash
# check.sh: build and check @NAME@ without a board (tinygo-box run bash check.sh). Exit 3 = a sibling tool is missing.
set -euo pipefail
cd "$(dirname "$0")"
: "${TINYGO_BOX_ROOT:?run through: tinygo-box run bash check.sh}"
mkdir -p build
[[ -x "${RUST_ID:-}/rust-box" ]] || { echo "skip: 32_17_embedded_rust not found (BOX_EMBEDDED_RUST)"; exit 3; }
command -v qemu-system-riscv32 >/dev/null || { echo "skip: qemu-system-riscv32 not found (32_10_qemu: BOX_QEMU_EMBEDDED)"; exit 3; }
# riscv-qemu here; for a board use its triple, e.g. thumbv6m-none-eabi + "inherits": ["pico"]
"$RUST_ID/rust-box" run rustc --edition 2021 --target riscv32imac-unknown-none-elf --crate-type lib --emit obj \
  -C opt-level=s -C panic=abort -o "$PWD/build/pi.o" "$PWD/rust/lib.rs"
printf '{"inherits": ["riscv-qemu"], "ldflags": ["%s"]}\n' "$PWD/build/pi.o" >build/riscv-qemu-rust.json
out=$(timeout 120 tinygo run -target "$PWD/build/riscv-qemu-rust.json" . 2>&1); echo "$out"
grep -q "@NAME@: step 20 100" <<<"$out" || { echo "FAIL: unexpected output"; exit 1; }
echo "PASS @NAME@"

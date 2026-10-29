#!/usr/bin/env bash
# about: Zig code in TinyGo firmware: crc8.zig -> riscv32 object with Zig from 32_24_microzig, cgo call, run on riscv-qemu (32_10_qemu); results compared with Go
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
need_zig; need_qemu qemu-system-riscv32
build() {
  "$ZIG_ID/microzig-box" zig build-obj -target riscv32-freestanding-none -mcpu generic_rv32+m+a+c -O ReleaseSmall \
    -fno-stack-check --cache-dir "$OUT/zig-cache" -femit-bin="$OUT/crc8.o" "$EX_DIR/crc8.zig"
  printf '{"inherits": ["riscv-qemu"], "ldflags": ["%s"]}\n' "$OUT/crc8.o" >"$OUT/riscv-qemu-zig.json"
}
case "${1:-run}" in
  build) build; tinygo build -target "$OUT/riscv-qemu-zig.json" -o "$OUT/ffi_zig.elf" . ;;
  run|test)
    build
    out=$(timeout 120 tinygo run -target "$OUT/riscv-qemu-zig.json" . 2>&1); printf '%s\n' "$out"
    expect "123456789 zig 244" "$out"; expect "ffi_zig_qemu: match" "$out"
    echo "PASS ffi_zig_qemu" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

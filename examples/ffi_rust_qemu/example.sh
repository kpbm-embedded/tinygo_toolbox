#!/usr/bin/env bash
# about: no_std Rust in TinyGo firmware: fletcher.rs -> riscv32imac object with rustc from 32_17_embedded_rust, cgo call, run on riscv-qemu (32_10_qemu); compared with Go
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
need_rust; need_qemu qemu-system-riscv32
build() {
  "$RUST_ID/rust-box" run rustc --edition 2021 --target riscv32imac-unknown-none-elf --crate-type lib --emit obj \
    -C opt-level=s -C panic=abort -o "$OUT/fletcher.o" "$EX_DIR/fletcher.rs"
  printf '{"inherits": ["riscv-qemu"], "ldflags": ["%s"]}\n' "$OUT/fletcher.o" >"$OUT/riscv-qemu-rust.json"
}
case "${1:-run}" in
  build) build; tinygo build -target "$OUT/riscv-qemu-rust.json" -o "$OUT/ffi_rust.elf" . ;;
  run|test)
    build
    out=$(timeout 120 tinygo run -target "$OUT/riscv-qemu-rust.json" . 2>&1); printf '%s\n' "$out"
    expect "123456789 rust 7902" "$out"; expect "abcde rust 51440" "$out"; expect "ffi_rust_qemu: match" "$out"
    echo "PASS ffi_rust_qemu" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

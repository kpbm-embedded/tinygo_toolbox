#!/usr/bin/env bash
# about: WebAssembly module for WAMR: -target wasm-unknown exports add/pid_step, no imports; size + exports checked, called with iwasm -f (32_26_wasm)
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
build() { tinygo build -target wasm-unknown -opt z -no-debug -o "$OUT/control.wasm" .; }
case "${1:-run}" in
  build) build ;;
  run|test)
    build
    artifact wasm "$OUT/control.wasm" -export add -export pid_step
    [[ $(stat -c %s "$OUT/control.wasm") -lt 4096 ]] || { echo "FAIL: module over 4 KB"; exit 1; }
    need_iwasm
    out=$("$TINYGO_BOX_IWASM" -f add "$OUT/control.wasm" 2 40); expect "0x2a:i32" "$out"
    out=$("$TINYGO_BOX_IWASM" -f pid_step "$OUT/control.wasm" 100 80); printf '%s\n' "$out"
    expect "0x20:i32" "$out"   # err 20: 30 + 2 = 32
    echo "PASS wasm_wamr_export" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

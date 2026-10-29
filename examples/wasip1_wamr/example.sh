#!/usr/bin/env bash
# about: WASI preview 1 program: -target wasip1, run in iwasm (32_26_wasm) with --env and args; output and exit status checked
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
build() { tinygo build -target wasip1 -opt z -no-debug -o "$OUT/app.wasm" .; }
case "${1:-run}" in
  build) build ;;
  run|test)
    build
    artifact wasm "$OUT/app.wasm" -import wasi_snapshot_preview1 -export _start
    need_iwasm
    out=$("$TINYGO_BOX_IWASM" --env=BOARD=pico2 "$OUT/app.wasm" a b); printf '%s\n' "$out"
    expect "board=pico2 args=a,b" "$out"
    rc=0; "$TINYGO_BOX_IWASM" "$OUT/app.wasm" fail >/dev/null || rc=$?
    [[ $rc -eq 3 ]] || { echo "FAIL: exit status $rc, want 3"; exit 1; }
    echo "PASS wasip1_wamr" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

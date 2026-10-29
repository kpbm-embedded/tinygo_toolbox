#!/usr/bin/env bash
# check.sh: build and check @NAME@ without a board (tinygo-box run bash check.sh). Exit 3 = a sibling tool is missing.
set -euo pipefail
cd "$(dirname "$0")"
: "${TINYGO_BOX_ROOT:?run through: tinygo-box run bash check.sh}"
mkdir -p build
artifact() { local mode=$1 file; file=$(realpath "$2"); shift 2; go -C "$TINYGO_BOX_ROOT/tools/elfinfo" run . "$mode" "$file" "$@"; }
[[ -x "${TINYGO_BOX_IWASM:-}" ]] || { echo "skip: iwasm not found (32_26_wasm: BOX_WAMR)"; exit 3; }
tinygo build -target wasm-unknown -opt z -no-debug -o build/@NAME@.wasm .
artifact wasm build/@NAME@.wasm -export next -export seed -export clamp
out=$("$TINYGO_BOX_IWASM" -f clamp build/@NAME@.wasm 500 0 255); grep -q "0xff:i32" <<<"$out" || { echo "FAIL clamp: $out"; exit 1; }
out=$("$TINYGO_BOX_IWASM" -f next build/@NAME@.wasm); grep -q "0x42021:i32" <<<"$out" || { echo "FAIL next: $out"; exit 1; }
echo "PASS @NAME@ ($(stat -c %s build/@NAME@.wasm) bytes)"

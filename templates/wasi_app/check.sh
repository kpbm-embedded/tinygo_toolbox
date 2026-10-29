#!/usr/bin/env bash
# check.sh: build and check @NAME@ without a board (tinygo-box run bash check.sh). Exit 3 = a sibling tool is missing.
set -euo pipefail
cd "$(dirname "$0")"
: "${TINYGO_BOX_ROOT:?run through: tinygo-box run bash check.sh}"
mkdir -p build
artifact() { local mode=$1 file; file=$(realpath "$2"); shift 2; go -C "$TINYGO_BOX_ROOT/tools/elfinfo" run . "$mode" "$file" "$@"; }
[[ -x "${TINYGO_BOX_IWASM:-}" ]] || { echo "skip: iwasm not found (32_26_wasm: BOX_WAMR)"; exit 3; }
tinygo build -target wasip1 -opt z -no-debug -o build/@NAME@.wasm .
artifact wasm build/@NAME@.wasm -import wasi_snapshot_preview1 -export _start
printf 'one\ntwo\nthree\n' >build/input.txt
out=$("$TINYGO_BOX_IWASM" --dir=build build/@NAME@.wasm build/input.txt); echo "$out"
grep -q "3 lines, 14 bytes" <<<"$out" || { echo "FAIL: unexpected output"; exit 1; }
rc=0; "$TINYGO_BOX_IWASM" build/@NAME@.wasm 2>/dev/null || rc=$?
[[ $rc -eq 2 ]] || { echo "FAIL: usage exit $rc, want 2"; exit 1; }
echo "PASS @NAME@"

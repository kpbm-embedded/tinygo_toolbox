#!/usr/bin/env bash
# about: ESP32-S3 DevKitC-1 (Xtensa LX7): GPIO2 toggle + println, -target esp32s3-generic -> flash image .bin
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./tinygo-box examples}
build() { tinygo build -target esp32s3-generic -size short -o "$OUT/esp32s3_blinky.bin" .; }
case "$act" in
  build) build ;;
  run) build; echo "built $OUT/esp32s3_blinky.bin (flash: ./tinygo-box plan esp32s3-generic $EX_DIR)" ;;
  test)
    build
    f="$OUT/esp32s3_blinky.bin"
    [[ -s "$f" ]] || { echo "FAIL: no $f"; exit 1; }
    grep -q e9 <<<"$(head -c 1 "$f" | od -An -tx1)" || { echo "FAIL: not an ESP image (magic 0xE9)"; exit 1; }
    echo "PASS esp32s3_blinky" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

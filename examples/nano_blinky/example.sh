#!/usr/bin/env bash
# about: Arduino Nano (ATmega328P): LED D13 + println, -target arduino-nano -> Intel HEX (fits 30 KB)
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./tinygo-box examples}
build() { tinygo build -target arduino-nano -size short -o "$OUT/nano_blinky.hex" .; }
case "$act" in
  build) build ;;
  run) build; echo "built $OUT/nano_blinky.hex (flash: ./tinygo-box plan arduino-nano $EX_DIR)" ;;
  test)
    build
    f="$OUT/nano_blinky.hex"
    [[ -s "$f" ]] || { echo "FAIL: no $f"; exit 1; }
    grep -q "^:00000001FF" "$f" || { echo "FAIL: not Intel HEX"; exit 1; }; b=$(awk 'substr($0,8,2)=="00"{n+=strtonum("0x" substr($0,2,2))} END{print n}' "$f"); echo "flash bytes: $b"; [[ "$b" -lt 30720 ]] || { echo "FAIL: too big for the Nano"; exit 1; }
    echo "PASS nano_blinky" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

#!/usr/bin/env bash
# about: Raspberry Pi Pico (RP2040): LED GP25 + println, -target pico -> .uf2
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./tinygo-box examples}
build() { tinygo build -target pico -size short -o "$OUT/pico_blinky.uf2" .; }
case "$act" in
  build) build ;;
  run) build; echo "built $OUT/pico_blinky.uf2 (flash: ./tinygo-box plan pico $EX_DIR)" ;;
  test)
    build
    f="$OUT/pico_blinky.uf2"
    [[ -s "$f" ]] || { echo "FAIL: no $f"; exit 1; }
    grep -q "UF2" <<<"$(head -c 4 "$f")" || { echo "FAIL: not a UF2 image"; exit 1; }
    echo "PASS pico_blinky" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

#!/usr/bin/env bash
# about: STM32F4 Cortex-M4F (stm32f4disco target, closest to BlackPill F411): blink + float + println -> ELF
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./tinygo-box examples}
build() { tinygo build -target stm32f4disco -size short -o "$OUT/blackpill_f4.elf" .; }
case "$act" in
  build) build ;;
  run) build; echo "built $OUT/blackpill_f4.elf (flash: ./tinygo-box plan stm32f4disco $EX_DIR)" ;;
  test)
    build
    f="$OUT/blackpill_f4.elf"
    [[ -s "$f" ]] || { echo "FAIL: no $f"; exit 1; }
    grep -q "28 00" <<<"$(od -An -tx1 -j18 -N2 "$f")" || { echo "FAIL: not an ARM ELF"; exit 1; }
    echo "PASS blackpill_f4" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

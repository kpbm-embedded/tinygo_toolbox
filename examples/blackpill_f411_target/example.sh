#!/usr/bin/env bash
# about: BlackPill F411: custom target JSON (inherits stm32f4disco) + 512K/128K linker script, LED PC13; sections checked against the F411 map; build check only (F407 clock setup assumes an 8 MHz crystal, see README)
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
build() { tinygo build -target ./blackpill-f411.json -size short -o "$OUT/blackpill_f411.elf" . && tinygo build -target ./blackpill-f411.json -o "$OUT/blackpill_f411.bin" .; }
case "${1:-run}" in
  build) build ;;
  run) build; echo "built $OUT/blackpill_f411.bin (flash at 0x08000000 with a probe or DFU: 32_15_flashers)" ;;
  test)
    build
    artifact elf "$OUT/blackpill_f411.elf" -machine arm -region 0x08000000:512K -region 0x20000000:128K -sym main.main -sym Reset_Handler
    [[ $(stat -c %s "$OUT/blackpill_f411.bin") -lt 524288 ]] || { echo "FAIL: bin over 512 KB"; exit 1; }
    echo "PASS blackpill_f411_target" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

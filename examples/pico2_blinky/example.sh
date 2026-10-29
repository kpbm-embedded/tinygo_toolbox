#!/usr/bin/env bash
# about: Raspberry Pi Pico 2 (RP2350 Arm): LED GP25, -target pico2 -> .uf2 (family 0xe48bff59 checked); flashing is not run
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
build() { tinygo build -target pico2 -size short -o "$OUT/pico2_blinky.uf2" . && tinygo build -target pico2 -o "$OUT/pico2_blinky.elf" .; }
case "${1:-run}" in
  build) build ;;
  run) build; echo "built $OUT/pico2_blinky.uf2 (flash: ./tinygo-box plan pico2 $EX_DIR)" ;;
  test)
    build
    artifact uf2 "$OUT/pico2_blinky.uf2" -family 0xe48bff59
    artifact elf "$OUT/pico2_blinky.elf" -machine arm -region 0x10000000:4M -region 0x20000000:520K -sym main.main
    echo "PASS pico2_blinky" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

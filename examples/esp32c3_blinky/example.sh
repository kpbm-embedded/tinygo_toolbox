#!/usr/bin/env bash
# about: ESP32-C3 SuperMini (RISC-V): LED GPIO8, -target esp32c3-supermini -> ESP image (magic 0xE9, chip id esp32c3) + RISC-V ELF; flashing is not run
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
build() { tinygo build -target esp32c3-supermini -size short -o "$OUT/esp32c3_blinky.bin" . && tinygo build -target esp32c3-supermini -o "$OUT/esp32c3_blinky.elf" .; }
case "${1:-run}" in
  build) build ;;
  run) build; echo "built $OUT/esp32c3_blinky.bin (flash with esptool at 0x0: see ./tinygo-box plan esp32c3-supermini)" ;;
  test)
    build
    artifact esp "$OUT/esp32c3_blinky.bin" -chip esp32c3
    artifact elf "$OUT/esp32c3_blinky.elf" -machine riscv -sym main.main
    echo "PASS esp32c3_blinky" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

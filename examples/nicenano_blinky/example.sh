#!/usr/bin/env bash
# about: nice!nano / Pro Micro nRF52840: LED + USB-CDC, -target nicenano -> .uf2 (family 0xADA52840, above the S140 SoftDevice); flashing is not run
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
build() { tinygo build -target nicenano -size short -o "$OUT/nicenano_blinky.uf2" . && tinygo build -target nicenano -o "$OUT/nicenano_blinky.elf" .; }
case "${1:-run}" in
  build) build ;;
  run) build; echo "built $OUT/nicenano_blinky.uf2 (double-tap reset, copy to the NICENANO drive)" ;;
  test)
    build
    artifact uf2 "$OUT/nicenano_blinky.uf2" -family 0xADA52840
    # S140 v6 SoftDevice occupies 0x0..0x26000: the app must start above it and stay below the bootloader (0xF4000)
    artifact elf "$OUT/nicenano_blinky.elf" -machine arm -region 0x26000:0xCE000 -region 0x20000000:256K -sym main.main
    echo "PASS nicenano_blinky" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

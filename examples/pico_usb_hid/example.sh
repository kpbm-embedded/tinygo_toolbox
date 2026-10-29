#!/usr/bin/env bash
# about: Pico as USB HID keyboard (machine/usb/hid/keyboard, CDC+HID composite): build + UF2 + HID symbols checked; enumeration needs a board (not run)
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
build() { tinygo build -target pico -size short -o "$OUT/pico_usb_hid.uf2" . && tinygo build -target pico -o "$OUT/pico_usb_hid.elf" .; }
case "${1:-run}" in
  build) build ;;
  run) build; echo "built $OUT/pico_usb_hid.uf2 (BOOTSEL + copy; GP15 to GND types a line)" ;;
  test)
    build
    artifact uf2 "$OUT/pico_usb_hid.uf2" -family 0xe48bff56
    out=$(go tool nm "$OUT/pico_usb_hid.elf")
    expect "keyboard.keyboard).sendKey" "$out"; expect "USBCTRL_IRQ_IRQHandler" "$out"; expect "machine/usb/cdc" "$out"
    grep -aq "tinygo-box HID demo" "$OUT/pico_usb_hid.uf2" || { echo "FAIL: product string not in the image"; exit 1; }
    echo "PASS pico_usb_hid" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

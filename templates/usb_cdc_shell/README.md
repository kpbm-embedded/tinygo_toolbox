# @NAME@

Serial command shell (`tinygo-box new usb_cdc_shell @NAME@`, 32_23_tinygo). The parser in `shell/` is
hardware-free and unit-tested; `main.go` wires it to `machine.Serial` (USB-CDC on Pico / nRF52840 / ESP32-C3).

    tinygo-box run bash check.sh                  # host tests + builds for pico, nicenano, esp32c3-supermini

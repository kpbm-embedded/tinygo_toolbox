# @NAME@

Pico 2 (RP2350) firmware from `tinygo-box new pico2_app @NAME@` (32_23_tinygo). The LED pattern lives in
`pattern/` (no hardware access) and is unit-tested on the host.

    tinygo-box run bash check.sh                                  # host test + UF2 build + UF2 family check
    tinygo-box tinygo build -target pico2 -o build/@NAME@.uf2 .   # hold BOOTSEL, copy to the drive

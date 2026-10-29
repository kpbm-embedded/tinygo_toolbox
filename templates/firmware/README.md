# @NAME@

TinyGo firmware from `tinygo-box new firmware @NAME@` (32_23_tinygo). Board-independent: pick the target.

    tinygo-box tinygo test ./blink                                   # host unit test
    tinygo-box tinygo build -target pico -o build/@NAME@.uf2 .       # Raspberry Pi Pico
    tinygo-box tinygo build -target arduino-nano -o build/@NAME@.hex .
    tinygo-box tinygo build -target stm32f4disco -o build/@NAME@.elf .   # closest to BlackPill F411
    tinygo-box tinygo build -target esp32s3-generic -o build/@NAME@.bin .
    tinygo-box plan pico .                                           # prints the flash steps (runs nothing)

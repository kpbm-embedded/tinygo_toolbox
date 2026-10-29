# @NAME@

TinyGo + Zig through cgo (`tinygo-box new zig_ffi @NAME@`, 32_23_tinygo; Zig from 32_24_microzig, QEMU from
32_10_qemu). Zig code is built to an object for the target CPU; a small target JSON that inherits the board
target adds it to the link.

    tinygo-box run bash check.sh      # zig build-obj (riscv32) + tinygo run -target build/riscv-qemu-zig.json
For the Pico: `zig build-obj -target thumb-freestanding-eabi -mcpu cortex_m0plus ...` and `"inherits": ["pico"]`.

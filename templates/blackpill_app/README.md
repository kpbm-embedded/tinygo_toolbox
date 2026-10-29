# @NAME@

BlackPill F411 firmware from `tinygo-box new blackpill_app @NAME@` (32_23_tinygo). TinyGo 0.43 has no F411
target, so `blackpill-f411.json` inherits `stm32f4disco` and `blackpill-f411.ld` sets 512 KB flash / 128 KB RAM.
**Build check only.** The clock setup is the Discovery's (8 MHz crystal, PLL to 168 MHz); the BlackPill has a
25 MHz crystal and a 100 MHz limit, so this firmware is not expected to run correctly on the board until TinyGo
gets an F411 machine package (or you patch `board_stm32f4disco.go`/the PLL table). Use it for size and memory-map
checks, or run Go on the BlackPill another way (32_17_embedded_rust, 32_24_microzig, 32_03_zephyr).

    tinygo-box run bash check.sh       # builds and checks every section against the F411 memory map

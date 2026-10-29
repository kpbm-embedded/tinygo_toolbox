# @NAME@

Board-free firmware logic run in QEMU (`tinygo-box new qemu_app @NAME@`, 32_23_tinygo; QEMU from 32_10_qemu).

    tinygo-box tinygo run -target cortex-m-qemu .    # Cortex-M3 (lm3s6965evb), semihosting output
    tinygo-box tinygo run -target riscv-qemu .       # RISC-V virt, 4 harts
    tinygo-box run bash check.sh                     # both, output compared

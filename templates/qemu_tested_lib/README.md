# @NAME@

A hardware-free library (COBS framing) with tests that run on the host and on emulated MCUs
(`tinygo-box new qemu_tested_lib @NAME@`, 32_23_tinygo; QEMU from 32_10_qemu). Put your own packages next to `codec/`.

    tinygo-box run bash check.sh                          # tinygo test, go test, tests in cortex-m-qemu and riscv-qemu
    tinygo-box tinygo test -target cortex-m-qemu -v ./codec

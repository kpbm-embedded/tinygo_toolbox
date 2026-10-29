#!/usr/bin/env bash
# about: RISC-V in QEMU virt (qemu from 32_10_qemu): -target riscv-qemu with the 4-hart "cores" scheduler, WaitGroup + atomics, output checked
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
need_qemu qemu-system-riscv32
run() { timeout 120 tinygo run -target riscv-qemu . 2>&1; }
case "${1:-run}" in
  build) tinygo build -target riscv-qemu -size short -o "$OUT/qemu_riscv_cores.elf" . ;;
  run) run ;;
  test)
    out=$(run); printf '%s\n' "$out"
    expect "cpus 4 total 4000" "$out"
    echo "PASS qemu_riscv_cores" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

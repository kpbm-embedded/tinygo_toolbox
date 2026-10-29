#!/usr/bin/env bash
# about: Cortex-M3 in QEMU (lm3s6965evb, qemu from 32_10_qemu): tinygo run -target cortex-m-qemu, goroutines/channels/timers, output checked
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
need_qemu qemu-system-arm
run() { timeout 120 tinygo run -target cortex-m-qemu . 2>&1; }
case "${1:-run}" in
  build) tinygo build -target cortex-m-qemu -size short -o "$OUT/qemu_cortexm.elf" . ;;
  run) run ;;
  test)
    out=$(run); printf '%s\n' "$out"
    expect "sum 55" "$out"; expect "timeout ok" "$out"; expect "done" "$out"
    echo "PASS qemu_cortexm" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

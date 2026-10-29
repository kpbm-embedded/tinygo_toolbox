#!/usr/bin/env bash
# about: unit tests run inside QEMU: tinygo test -target cortex-m-qemu and riscv-qemu (32_10_qemu), then on the host; same CRC package, three runs
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
need_qemu qemu-system-arm; need_qemu qemu-system-riscv32
case "${1:-run}" in
  build) go vet ./crc ;;
  run|test)
    for t in cortex-m-qemu riscv-qemu; do
      out=$(timeout 180 tinygo test -target "$t" -v ./crc 2>&1); printf '%s\n' "$out"
      expect "--- PASS: TestCCITT" "$out"; expect "--- PASS: TestEmpty" "$out"
    done
    tinygo test ./crc
    echo "PASS qemu_unit_tests" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

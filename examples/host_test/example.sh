#!/usr/bin/env bash
# about: host unit tests of an MCU ring buffer with `tinygo test` (and `go test` for comparison)
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
case "$act" in
  build) go vet . ;;
  run|test) tinygo test -v . && go test -count=1 . && echo "PASS host_test" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

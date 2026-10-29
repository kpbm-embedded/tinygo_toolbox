#!/usr/bin/env bash
# about: flash/RAM cost of -opt z|s|2, -gc conservative|leaking, -scheduler tasks, -panic trap on the Pico: size table in size.tsv; checks opt z <= opt 2
# Usage (through ./tinygo-box examples ...): example.sh build | run | test
set -euo pipefail
# shellcheck source=../common/ex.bash
. ../common/ex.bash
# variant name -> extra tinygo flags (-no-debug is left out: it changes no flash bytes and -size needs debug info)
variants=("opt-z|-opt z" "opt-s|-opt s" "opt-2|-opt 2" "gc-leaking|-opt z -gc leaking" "sched-tasks|-opt z -scheduler tasks" "panic-trap|-opt z -panic trap")
flash() { tinygo build -target pico -size short "$@" -o "$OUT/tmp.elf" . | awk 'NR==2{print $5, $6}'; }
table() {
  printf 'variant\tflash\tram\n' >"$OUT/size.tsv"
  local v
  for v in "${variants[@]}"; do
    # shellcheck disable=SC2086
    read -r f r < <(flash ${v#*|})
    printf '%s\t%s\t%s\n' "${v%%|*}" "$f" "$r" >>"$OUT/size.tsv"
  done
  column -t "$OUT/size.tsv"
}
case "${1:-run}" in
  build|run) table ;;
  test)
    table
    z=$(awk '$1=="opt-z"{print $2}' "$OUT/size.tsv"); o2=$(awk '$1=="opt-2"{print $2}' "$OUT/size.tsv")
    [[ "$z" =~ ^[0-9]+$ && "$z" -le "$o2" ]] || { echo "FAIL: opt z ($z) larger than opt 2 ($o2)"; exit 1; }
    echo "PASS size_profile" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac

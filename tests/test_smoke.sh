#!/usr/bin/env bash
# Smoke test of the installed tinygo-box: go and tinygo run, the firmware template is generated,
# its host test passes and it builds for pico and arduino-nano; every other template is generated and its
# check.sh passes (exit 3 = a sibling ID is missing: counted as skip); caches stay out of $HOME.
# Usage: tests/test_smoke.sh
# shellcheck disable=SC2015  # ok() always returns 0
set -uo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd -P)
Q="$HERE/tinygo-box"
pass=0; failn=0; skipn=0
ok()  { printf 'ok    %s\n' "$*"; pass=$((pass+1)); }
bad() { printf 'FAIL  %s\n' "$*"; failn=$((failn+1)); }
tmp=$(mktemp -d)
cleanup() { if command -v trash-put >/dev/null; then trash-put "$tmp"; fi; }   # own temp dir; never rm
trap cleanup EXIT
v=$("$Q" go version 2>&1) && grep -q 'go1\.' <<<"$v" && ok "$v" || bad "go: $v"
v=$("$Q" tinygo version 2>&1) && grep -q 'tinygo version' <<<"$v" && ok "$v" || bad "tinygo: $v"
if "$Q" new firmware smoke_fw --dir "$tmp" >/dev/null 2>&1; then
  out=$("$Q" run bash -c "cd '$tmp/smoke_fw' && tinygo test ./blink" 2>&1) && ok "template: tinygo test ./blink" || bad "template test: $(tail -3 <<<"$out")"
  for t in pico:uf2 arduino-nano:hex; do
    out=$("$Q" run bash -c "cd '$tmp/smoke_fw' && tinygo build -target ${t%%:*} -o build/fw.${t#*:} ." 2>&1) && [[ -s "$tmp/smoke_fw/build/fw.${t#*:}" ]] \
      && ok "template builds for ${t%%:*}" || bad "template ${t%%:*}: $(tail -3 <<<"$out")"
  done
else bad "template firmware not generated"; fi
for kdir in "$HERE"/templates/*/; do
  kind=$(basename "$kdir")
  [[ "$kind" = firmware ]] && continue
  if ! "$Q" new "$kind" "t_$kind" --dir "$tmp" >/dev/null 2>&1; then bad "template $kind not generated"; continue; fi
  rc=0; out=$("$Q" run bash "$tmp/t_$kind/check.sh" 2>&1) || rc=$?
  case $rc in
    0) ok "template $kind: check.sh" ;;
    3) printf 'skip  template %s: %s\n' "$kind" "$(tail -1 <<<"$out")"; skipn=$((skipn+1)) ;;
    *) bad "template $kind: $(tail -3 <<<"$out")" ;;
  esac
done
[[ ! -e "$HOME/go" ]] && ok "no ~/go created" || bad "$HOME/go exists"
echo "smoke: $pass ok, $skipn skipped, $failn failed"
[[ "$failn" -eq 0 ]]

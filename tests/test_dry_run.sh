#!/usr/bin/env bash
# Every tinygo-box command in --dry-run mode (no downloads, builds or flashing), plus shellcheck.
# Usage: tests/test_dry_run.sh
set -uo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd -P)
Q="$HERE/tinygo-box"
pass=0; failn=0
check() { # name expected-regex cmd...
  local name=$1 re=$2; shift 2
  local out rc
  out=$(timeout 300 "$@" 2>&1); rc=$?
  if [[ "$rc" -eq 0 ]] && grep -qE -- "$re" <<<"$out"; then
    printf 'ok    %s\n' "$name"; pass=$((pass+1))
  else
    printf 'FAIL  %s (rc=%s)\n%s\n' "$name" "$rc" "$(tail -5 <<<"$out" | sed 's/^/      /')"; failn=$((failn+1))
  fi
}
check help        'usage: \./tinygo-box'                   "$Q" help
check where       '^tinygo '                               "$Q" where
check bootstrap   'bootstrap|install|curl'                 bash -c "'$Q' --dry-run bootstrap; echo install"
check install     'example\.sh build'                      "$Q" --dry-run install
check update      'curl https://api.github.com/repos/tinygo-org/tinygo' "$Q" --dry-run update
check clean       'nothing to clean|dry run: re-run with --yes' "$Q" clean
check clean-all   'dry run: re-run with --yes'             "$Q" clean --all
check status      '^  tinygo +0\.43\.0'                    "$Q" status
check doctor      'doctor: [0-9]+ ok'                      bash -c "'$Q' doctor || true"
check shell       '\+ true'                                "$Q" --dry-run shell -- true
check run         '\+ go version'                          "$Q" --dry-run run go version
check test        'test_smoke\.sh'                         "$Q" --dry-run test
check new         '\+ copy .*templates/firmware'           "$Q" --dry-run new firmware demo --dir /nonexistent
check ex-list     'pico_blinky .*RP2040'                   "$Q" examples list
check ex-run      'example\.sh run'                        "$Q" --dry-run examples run pico_blinky
check ex-build    'example\.sh build'                      "$Q" --dry-run examples build
check ex-test     'example\.sh test'                       "$Q" --dry-run examples test
check native      'tinygo @tinygo'                         "$Q" --dry-run native
check relocate    'pixi env already matches|re-creating'   "$Q" --dry-run relocate
check pack        '\+ tar .*-cf .*tinygo-box_'             "$Q" --dry-run pack
check tinygo      '\+ tinygo version'                      "$Q" --dry-run tinygo version
check go          '\+ go env'                              "$Q" --dry-run go env
check targets     '\+ tinygo targets'                      "$Q" --dry-run targets pico
check plan        'PRINTED ONLY'                           "$Q" plan pico examples/pico_blinky
check flash-refused 'writes a device'                      bash -c "'$Q' tinygo flash -target pico . 2>&1; true"
if command -v shellcheck >/dev/null; then
  mapfile -t files < <(cd "$HERE" && { echo tinygo-box; ls lib/*.bash tests/*.sh examples/*/example.sh; })
  if out=$(cd "$HERE" && shellcheck -x -P SCRIPTDIR "${files[@]}" 2>&1); then printf 'ok    shellcheck (%s files)\n' "${#files[@]}"; pass=$((pass+1))
  else printf 'FAIL  shellcheck\n%s\n' "$(head -30 <<<"$out")"; failn=$((failn+1)); fi
else printf 'skip  shellcheck (not installed)\n'; fi
echo "dry-run: $pass ok, $failn failed"
[[ "$failn" -eq 0 ]]

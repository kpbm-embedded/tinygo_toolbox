# shellcheck shell=bash disable=SC2034  # OUT is used by the example scripts that source this
# Helpers sourced by examples/*/example.sh (run through ./tinygo-box examples ...).
# need_* exit 3 (= skip) with a clear message when a sibling ID is missing.
OUT=${EX_OUT:?run through ./tinygo-box examples}
ELFINFO_DIR="${TINYGO_BOX_ROOT:?run through ./tinygo-box}/tools/elfinfo"
artifact() { go -C "$ELFINFO_DIR" run . "$@"; }   # elfinfo elf|uf2|esp|wasm FILE [checks]
need_qemu() {
  command -v "$1" >/dev/null || { echo "skip: $1 not found (32_10_qemu: set BOX_QEMU_EMBEDDED or install it next to this ID)"; exit 3; }
}
need_iwasm() {
  [[ -x "${TINYGO_BOX_IWASM:-}" ]] || { echo "skip: iwasm not found (32_26_wasm: set BOX_WAMR)"; exit 3; }
}
need_rust() { [[ -x "${RUST_ID:-}/rust-box" ]] || { echo "skip: 32_17_embedded_rust not found (set BOX_EMBEDDED_RUST)"; exit 3; }; }
need_zig() { [[ -x "${ZIG_ID:-}/microzig-box" ]] || { echo "skip: 32_24_microzig not found (set BOX_MICROZIG)"; exit 3; }; }
expect() { # expect "text" "output": fail unless output contains text
  grep -qF -- "$1" <<<"$2" || { printf '%s\n' "$2"; echo "FAIL: expected '$1'"; exit 1; }
}

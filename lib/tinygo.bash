# shellcheck shell=bash disable=SC2015,SC2034  # d_* return 0; TOOL_* are read by boxtool.bash
# tinygo-box: tool part (hooks for lib/boxtool.bash). TinyGo + Go from pinned release tarballs
# (sha256). No pixi env: TinyGo bundles LLVM/lld/clang, picolibc and its own targets. GOPATH and
# the module cache live in ./cache (offline reinstall); GOCACHE and TinyGo's build cache under
# $OUT on idisk03 (big, regenerable). Flashing (`tinygo flash`) is never run by this launcher:
# `plan` prints the command.
TOOL_TITLE="32_23_tinygo: TinyGo $(sed -n 's/^tinygo\t\([^\t]*\)\t.*/\1/p' "${BOXT_ROOT:?}/config/pins.tsv" | head -1) + Go $(sed -n 's/^go\t\([^\t]*\)\t.*/\1/p' "$BOXT_ROOT/config/pins.tsv" | head -1)"
TOOL_INSTALL_WHAT="the example builds (examples build)"
TOOL_HELP_USE="  tinygo [args]           the pinned TinyGo (build/test/targets/info; flash: use plan)
  go [args]               the pinned Go (tinygo's GOROOT)
  targets [filter]        TinyGo target names (tinygo targets)
  plan <target> <pkg-dir> PRINT the build + flash commands for a board (runs nothing)"
hook_help() { # printed after boxtool's help: tool-specific examples and environment
  cat <<EOF

tool examples
  ./$BOXT_NAME tinygo build -target pico -o fw.uf2 ./examples/pico_blinky
  ./$BOXT_NAME plan arduino-nano ./mydir
tool environment (set by the launcher)
  GOROOT, TINYGOROOT, GOPATH=cache/gopath, GOCACHE/XDG_CACHE_HOME under \$OUT, GOTOOLCHAIN=local
  BOX_QEMU_EMBEDDED, BOX_WAMR, BOX_EMBEDDED_RUST, BOX_MICROZIG   sibling IDs for the qemu/wasm/Rust/Zig
                          examples (default: the sibling folders; missing -> those examples exit 3 = skip)
EOF
}
# shellcheck source-path=SCRIPTDIR source=boxtool.bash
. "$BOXT_ROOT/lib/boxtool.bash"

TG="$INST/tinygo"
GOR="$INST/go"

sibling_id() { # ENV_VAR FOLDER MARKER -> another tool ID: the variable's folder (or one above it) holding
  # MARKER, else ../FOLDER next to this ID, else nothing (the examples that need it exit 3 = skip)
  local d=${!1:-} i
  for i in 1 2 3; do
    [[ -n "$d" && -e "$d/$3" ]] && { (cd -P "$d" && pwd -P); return 0; }
    d=${d%/*}
  done
  if [[ -e "$ROOT/../$2/$3" ]]; then (cd -P "$ROOT/../$2" && pwd -P); fi
}
QEMU_ID=$(sibling_id BOX_QEMU_EMBEDDED 32_10_qemu qemu-box)       # qemu-system-arm/riscv32 for tinygo run/test
WAMR_ID=$(sibling_id BOX_WAMR 32_26_wasm wamr-box)                 # iwasm for the wasm examples
RUST_ID=$(sibling_id BOX_EMBEDDED_RUST 32_17_embedded_rust rust-box)  # rustc for the Rust FFI example
ZIG_ID=$(sibling_id BOX_MICROZIG 32_24_microzig microzig-box)      # zig for the Zig FFI example

hook_env() {
  export GOROOT="$GOR" TINYGOROOT="$TG"
  export GOPATH="$ROOT/cache/gopath" GOMODCACHE="$ROOT/cache/gopath/pkg/mod"
  export GOCACHE="$BUILD/cache/go-build" XDG_CACHE_HOME="$BUILD/cache/xdg"   # tinygo's cache: $XDG_CACHE_HOME/tinygo
  export GOTOOLCHAIN=local GOFLAGS="-modcacherw" GOTELEMETRY=off GOENV="$ROOT/config/go.env" XDG_CONFIG_HOME="$ROOT/cache/xdg-config"
  PATH="$TG/bin:$GOR/bin:$PATH"; export PATH
  [[ "$DRY" = 1 ]] || mkdir -p "$GOPATH" "$GOCACHE" "$XDG_CACHE_HOME" 2>/dev/null || true
  export TINYGO_BOX_ROOT="$ROOT"
  # Sibling IDs (reached, never copied): empty when missing; examples/common/ex.bash skips with exit 3.
  local q
  for q in "$QEMU_ID/install/qemu-arm/bin" "$QEMU_ID/install/qemu-riscv/bin"; do
    [[ -n "$QEMU_ID" && -d "$q" ]] && PATH="$PATH:$q"
  done
  export PATH QEMU_ID WAMR_ID RUST_ID ZIG_ID
  export TINYGO_BOX_IWASM="${WAMR_ID:+$WAMR_ID/install/iwasm-built/iwasm}"
}
hook_bootstrap() {
  cachedir_tag "$ROOT/cache"
  [[ "$DRY" = 1 ]] || { cachedir_tag "$BUILD/cache"; [[ -e "$ROOT/config/go.env" ]] || printf '# go env file for tinygo-box (GOENV); empty on purpose\n' >"$ROOT/config/go.env"; }
}
hook_install() { cmd_native; info "building the examples (examples build)"; cmd_examples build; }
hook_status() {
  local e n=0
  for e in $(ex_list); do [[ -d "$BUILD/examples/$e" ]] && n=$((n+1)); done
  printf '  %-22s %s of %s built in %s\n' examples "$n" "$(ex_list | wc -l)" "$BUILD/examples"
  printf '  %-22s %s (GOPATH, modules) | go/tinygo build cache %s\n' gopath "$(human_size "$ROOT/cache/gopath")" "$(human_size "$BUILD/cache")"
}
hook_doctor() {
  local v t
  v=$(go version 2>/dev/null) && d_ok "$v" || d_fail "go not runnable ($GOR)"
  v=$(tinygo version 2>/dev/null) && d_ok "$v" || d_fail "tinygo not runnable ($TG)"
  [[ "$(go env GOROOT 2>/dev/null)" = "$GOR" ]] && d_ok "GOROOT inside the ID" || d_fail "GOROOT is $(go env GOROOT 2>/dev/null)"
  [[ "$(go env GOMODCACHE 2>/dev/null)" = "$ROOT/cache/gopath/pkg/mod" ]] && d_ok "GOMODCACHE inside the ID" || d_fail "GOMODCACHE elsewhere"
  case "$(go env GOCACHE 2>/dev/null)" in "$BUILD"/*) d_ok "GOCACHE under \$OUT ($BUILD/cache)" ;; *) d_fail "GOCACHE elsewhere" ;; esac
  [[ -n "$QEMU_ID" && -x "$QEMU_ID/install/qemu-arm/bin/qemu-system-arm" ]] && d_ok "qemu: $QEMU_ID (32_10_qemu)" \
    || d_warn "32_10_qemu not found (BOX_QEMU_EMBEDDED): the qemu examples skip"
  [[ -x "${TINYGO_BOX_IWASM:-}" ]] && d_ok "iwasm: $TINYGO_BOX_IWASM (32_26_wasm)" || d_warn "32_26_wasm iwasm not found (BOX_WAMR): the wasm examples skip"
  [[ -n "$RUST_ID" ]] && d_ok "rust: $RUST_ID (32_17_embedded_rust)" || d_warn "32_17_embedded_rust not found (BOX_EMBEDDED_RUST): ffi_rust_qemu skips"
  [[ -n "$ZIG_ID" ]] && d_ok "zig: $ZIG_ID (32_24_microzig)" || d_warn "32_24_microzig not found (BOX_MICROZIG): ffi_zig_qemu skips"
  for t in pico pico2 nicenano esp32c3-supermini arduino-nano stm32f4disco esp32s3-generic cortex-m-qemu riscv-qemu wasm-unknown wasip1; do
    tinygo info -target "$t" >/dev/null 2>&1 && d_ok "target $t" || d_fail "target $t missing"
  done
}
hook_native_bins() {
  echo "tinygo @tinygo"
  echo "tinygo-go @go"
}
tool_cmd_tinygo() {
  activate
  [[ "${1:-}" = flash ]] && usage_error "tinygo flash writes a device: use ./$NAME plan <target> <dir> and run the printed command yourself"
  [[ "$DRY" = 1 ]] && { printf '+ tinygo %s\n' "$*"; return 0; }
  exec tinygo "$@"
}
tool_cmd_go() { activate; [[ "$DRY" = 1 ]] && { printf '+ go %s\n' "$*"; return 0; }; exec go "$@"; }
tool_cmd_targets() {
  activate; [[ "$DRY" = 1 ]] && { printf '+ tinygo targets\n'; return 0; }
  tinygo targets | grep -i -- "${1:-}" || true
}
tool_cmd_plan() {
  local t=${1:-} d=${2:-.}
  [[ -n "$t" ]] || usage_error "usage: ./$NAME plan <target> [pkg-dir]  (e.g. pico, arduino-nano, stm32f4disco, esp32s3-generic)"
  echo "# TinyGo plan for target $t: PRINTED ONLY, nothing was run."
  echo "./$NAME tinygo build -target $t -o fw.$( [[ "$t" = arduino-nano ]] && echo hex || echo elf ) $d"
  case "$t" in
    pico|pico2|pico-w) echo "./$NAME tinygo build -target $t -o fw.uf2 $d   # hold BOOTSEL, plug in, copy fw.uf2 to the RPI-RP2 drive" ;;
    arduino-nano) echo "avrdude -c arduino -p atmega328p -b 57600 -P /dev/ttyUSB0 -U flash:w:fw.hex:i   # old bootloader; arduino-nano-new: -b 115200 (avrdude is not in this ID)" ;;
    stm32f4disco*) echo "./$NAME tinygo build -target $t -o fw.bin $d   # BlackPill F411: flash with a probe at 0x08000000 (st-flash/openocd/probe-rs, not in this ID)" ;;
    esp32s3*) echo "./$NAME tinygo build -target $t -o fw.bin $d   # flash with esptool (not in this ID) at 0x0" ;;
  esac
  echo "# tinygo flash -target $t -port <port> $d   # what tinygo itself would run; tinygo-box refuses 'flash'"
}
boxt_main "$@"

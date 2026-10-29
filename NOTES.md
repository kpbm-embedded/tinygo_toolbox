# 32_23_tinygo: notes

## 2026-10-25: created
- Box tool style (launcher `tinygo-box`, `lib/boxtool.bash` copied unchanged, md5 b938d4f9...).
- TinyGo 0.43.0 + Go 1.27.3; sha256 from GitHub's asset digests and go.dev's JSON. No pixi env:
  TinyGo bundles LLVM 22, lld and picolibc, so AVR (arduino-nano) and Xtensa (esp32s3-generic)
  build without avr-gcc or the Espressif toolchain.
- No STM32F411/BlackPill target in TinyGo: stm32f4disco (F407) used, README explains the differences.
- GOCACHE and TinyGo's cache under $OUT (idisk03); GOPATH/module cache in ./cache.
  Go creates `$XDG_CONFIG_HOME/go/telemetry`; XDG_CONFIG_HOME is set into the ID (the existing
  ~/.config/go dates from 2026-10-23, not from this ID).
- Mistake: the first attempt to write the examples ran in zsh, where `gm` is an alias (git merge);
  the function definition failed before anything was written; redone in bash.
- Results: doctor 15 ok / 0 failed; examples test 5/5; test_smoke 6/6; test_dry_run 26/26 (shellcheck incl.).

## 2026-10-25: script style pass (00_09_meta/04_agents/script_style.md)
- lib/boxtool.bash replaced by the cleaned shared version (md5 0c5ba426..., same as 32_06..32_10):
  usage errors exit 2, help has examples + environment sections.
- Tool lib: usage problems via `usage_error` (exit 2); tool-specific environment variables and
  examples added to the help text; `[ ]` -> `[[ ]]` in the lib, tests and example scripts
  (POSIX `sh` launcher and `#!/bin/sh` fixtures unchanged); dead code removed.

## 2026-10-25: readability pass 2 (script_style.md, scripts/README)
- lib/boxtool.bash (reference `00_09_meta/05_policy/templates/tool/lib/boxtool.bash`, synced to all 24 copies):
  `where`/`status`/`doctor`/`bootstrap`/`relocate` reject extra arguments (exit 2); colour only on a terminal
  and never with `NO_COLOR`; help lists `NO_COLOR`.
- examples blackpill_f4, pico_blinky, esp32s3_blinky: `| grep -q` -> here-string (pipefail).
- README: exit codes, `BOX_INTEGRATION` and `NO_COLOR` rows. Backups:
  `00_09_meta/02_logs/config_backups/2026_10_25_readability2_embedded_tools/`.

## 2026-10-29: 13 examples, 13 templates, Rust/Zig, git (repo tinygo_toolbox)
- New examples (18 in all): pico2_blinky, nicenano_blinky, esp32c3_blinky, blackpill_f411_target, pico_usb_hid,
  size_profile, qemu_cortexm, qemu_riscv_cores, qemu_unit_tests, wasm_wamr_export, wasip1_wamr, ffi_zig_qemu,
  ffi_rust_qemu. No board attached: board examples are built and the artifacts checked by `tools/elfinfo`
  (new, Go standard library only: ELF machine, sections inside the memory map, symbols, UF2 family, ESP image
  chip id, wasm exports/imports); QEMU (32_10_qemu) and iwasm (32_26_wasm) examples run.
- New templates (14 in all): pico2_app, nrf52840_app, esp32c3_app, blackpill_app, qemu_app, qemu_tested_lib,
  i2c_driver, usb_cdc_shell, usb_hid, wasm_module, wasi_app, zig_ffi, rust_ffi. Each has a `check.sh`;
  tests/test_smoke.sh generates every template and runs it.
- Sibling IDs are reached, not copied: lib/tinygo.bash looks up 32_10_qemu, 32_26_wasm, 32_17_embedded_rust and
  32_24_microzig (`$BOX_*`, else the sibling folder) and puts QEMU on PATH; doctor reports them (warn if missing).
  Missing sibling -> the example exits 3 (skip); `examples test` in the shared lib/boxtool.bash counts that as FAIL.
- Rust and Zig: objects with the C ABI linked into TinyGo through cgo. TinyGo ignores `CGO_LDFLAGS`; a generated
  target JSON `{"inherits": ["riscv-qemu"], "ldflags": ["<obj>"]}` adds the object. Rust `--emit obj` holds no
  `core`: anything that can panic (i32::clamp asserts) left undefined core::fmt symbols; the template avoids it.
  Bend: not added (its C output needs a heap and threads; no fit for TinyGo firmware). BEAM: not added (user correction).
- BlackPill F411: the custom target (inherits stm32f4disco, F411 linker script) builds and fits, but TinyGo's F40x
  clock code takes the Discovery's 8 MHz crystal (`xtalHz` in board_stm32f4disco.go); the BlackPill has 25 MHz.
  Documented as build/memory-map check only.
- Findings: `-size short` needs debug info (fails with `-no-debug`); `tinygo test -target cortex-m-qemu` exits 1
  on a failing test (checked); `tinygo run -target riscv-qemu` uses 4 harts with the `cores` scheduler.
- .gitignore: `/cache` without trailing slash (also ignores a symlinked cache), `.zig-cache/`.

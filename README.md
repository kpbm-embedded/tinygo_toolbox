# 32_23_tinygo - TinyGo (Go for microcontrollers)

**TinyGo** compiles Go for microcontrollers (LLVM-based) and ships with its own pinned Go. Use it to write
firmware in Go for the Raspberry Pi Pico, Arduino Nano, ESP32-S3 and STM32F4 (closest target to the BlackPill),
and to run host unit tests of MCU code. Everything sits in this folder: no sudo, no system packages, no `~/go`.
The launcher is called `tinygo-box` so it never shadows `tinygo`.

Status: **ready** (doctor 26 ok, examples 18/18, templates 14/14, 2026-10-29). No STM32F411/BlackPill target exists
in TinyGo 0.43 (see "Limitations"). Launcher: `./tinygo-box`. Repository: `tinygo_toolbox`.

## What's included

| Component | Version | Notes |
|---|---|---|
| TinyGo | 0.43.0 (2026-10-09) | bundles LLVM 22.1.4, lld, clang, picolibc, binaryen; sha256 = GitHub asset digests; 1.3 GB |
| Go | 1.27.3 | TinyGo 0.43 accepts Go 1.25..1.27; sha256 from go.dev; 283 MB |
| pixi | 0.81.0 | launcher only; no env is needed |

Pinned for linux-x64, linux-arm64, darwin-x64, darwin-arm64 and win-x64 (`config/pins.tsv`). Licences: BSD-3-Clause
(TinyGo, Go; LLVM Apache-2.0 with LLVM exception).

## Quick start

```sh
cd "$BOX_TINYGO"                              # or: cd $BOX/30_39_tools/32_embedded/32_23_tinygo
./tinygo-box install && ./tinygo-box doctor   # first setup (downloads once), then health checks
./tinygo-box examples test                    # 18 examples: boards (build + artifact checks), QEMU, WASM/WAMR, Rust/Zig FFI
./tinygo-box tinygo build -target pico -o fw.uf2 ./examples/pico_blinky   # your own build
./tinygo-box plan pico ./examples/pico_blinky # PRINTS the build + flash steps; runs nothing
```

With the Box shell set up once (`box shell install --apply`), the `tinygo-box` shim works from any folder,
and `box test|doctor|status tinygo` run this launcher (`box clean tinygo` is a dry run until `--apply`).
Standalone (no Box, or `BOX_INTEGRATION=0`), `./tinygo-box` keeps its output in this folder.

## Commands

Global option: `--dry-run` / `-n` prints what a command would do. Exit codes: 0 ok, 1 failure, 2 usage error (unknown command or option, or arguments given to `where`, `status`, `doctor`, `bootstrap` or `relocate`), 3 not applicable. `help` ends with this tool's own examples and variables (`tool examples`, `tool environment`).

| Command | What it does | Example |
|---|---|---|
| `bootstrap` | pinned pixi + TinyGo + Go (checksum-checked) | `./tinygo-box bootstrap` |
| `install [--no-demos]` | bootstrap + demo downloads + build the examples | `./tinygo-box install` |
| `update [--check\|--env]` | `--check` (default): compare pins with newest upstream; `--env`: re-solve the env | `./tinygo-box update --check` |
| `clean [--all] [--yes]` | move build/log output (`--all`: also install/, native/, downloads) to the Trash; dry run unless `--yes` | `./tinygo-box --dry-run clean --all` |
| `status`, `where`, `doctor` | versions and sizes, paths, health checks (exit 1 on failure) | `./tinygo-box doctor` |
| `shell [-- cmd ...]` | bash (or a command) with tinygo and go on PATH (GOPATH etc. set) | `./tinygo-box shell` |
| `run <cmd> [args]` | one command inside the environment | `./tinygo-box run tinygo version` |
| `tinygo [args]` | the pinned TinyGo (build, test, targets, info); `flash` is refused: use `plan` | `./tinygo-box tinygo test ./pkg` |
| `go [args]` | the pinned Go (TinyGo's GOROOT) | `./tinygo-box go version` |
| `targets [filter]` | TinyGo target names | `./tinygo-box targets stm32` |
| `plan <target> <pkg-dir>` | PRINT the build + flash commands for a board; runs nothing | `./tinygo-box plan arduino-nano ./mydir` |
| `test [--all]` | `tests/test_smoke.sh`; `--all` adds the dry-run test and the examples test | `./tinygo-box test` |
| `new <kind> <name> [--dir D] [--force]` | create a project from `templates/` (kind: `firmware`) | `./tinygo-box new firmware my_fw` |
| `examples list \| run <ex> [args] \| build [ex...] \| test [ex...]` | list, run, build or test the examples | `./tinygo-box examples test` |
| `native [--print]` | write `native/{native.zsh,native.bash,bin/}` | `./tinygo-box native` |
| `relocate` | after moving the folder: rewrite `native/` (no env to fix) | `./tinygo-box relocate` |
| `pack [--with-cache] [--out F]` | tarball of this folder (minus build) for another machine | `./tinygo-box pack --out /tmp/g.tgz` |
| `help`, `-h`, `--help` | the command list | `./tinygo-box help` |

## Examples and templates

`./tinygo-box examples list | run <ex> | build [ex...] | test [ex...]`. No board is needed: board examples are
built and their artifacts checked (`tools/elfinfo`: ELF machine, every section inside the chip's memory map,
symbols, UF2 family ids, ESP image magic and chip id, wasm exports/imports); QEMU and WAMR examples run.
Flashing is never done (use `plan`).

| Example | Board / target | What the test checks |
|---|---|---|
| `pico_blinky` | Raspberry Pi Pico RP2040, `-target pico` | `.uf2` (UF2 magic); 11.8 KB / 6.2 KB |
| `nano_blinky` | Arduino Nano ATmega328P (AVR via LLVM + ld.lld + picolibc, no avr-gcc) | Intel HEX under 30 KB |
| `blackpill_f4` | STM32F4 Cortex-M4F, `-target stm32f4disco` | ARM ELF |
| `esp32s3_blinky` | ESP32-S3 DevKitC-1, `-target esp32s3-generic` (Xtensa LX7) | ESP image magic 0xE9 |
| `host_test` | host | `tinygo test -v` + `go test` of an MCU ring buffer |
| `pico2_blinky` | Pico 2 RP2350 (Arm), `-target pico2` | UF2 family 0xe48bff59; sections in 4 MB flash / 520 KB RAM |
| `nicenano_blinky` | nice!nano / Pro Micro nRF52840, `-target nicenano` | UF2 family 0xADA52840; app above the S140 SoftDevice (0x26000) |
| `esp32c3_blinky` | ESP32-C3 SuperMini (RISC-V), `-target esp32c3-supermini` | ESP image, chip id esp32c3; RISC-V ELF |
| `blackpill_f411_target` | BlackPill F411: custom target JSON (inherits stm32f4disco) + 512K/128K linker script | sections inside the F411 map; `.bin` under 512 KB (build check only, see Limitations) |
| `pico_usb_hid` | Pico as USB HID keyboard (CDC+HID composite) | UF2, HID/USB symbols, product string (enumeration needs a board) |
| `size_profile` | Pico | flash/RAM table for `-opt z/s/2`, `-gc leaking`, `-scheduler tasks`, `-panic trap`; opt z <= opt 2 |
| `qemu_cortexm` | Cortex-M3 in QEMU (`cortex-m-qemu`, lm3s6965evb) | goroutines, channels, timers: output |
| `qemu_riscv_cores` | RISC-V virt in QEMU (`riscv-qemu`, 4 harts, `cores` scheduler) | WaitGroup + atomics: `cpus 4 total 4000` |
| `qemu_unit_tests` | `tinygo test -target cortex-m-qemu` and `riscv-qemu`, then host | CRC unit tests pass in both emulators |
| `wasm_wamr_export` | `-target wasm-unknown` (no imports) for WAMR | exports, size < 4 KB, `iwasm -f add/pid_step` results |
| `wasip1_wamr` | `-target wasip1` in WAMR's iwasm | args, env, stdout, exit status |
| `ffi_zig_qemu` | Zig object (32_24_microzig) linked into TinyGo via cgo, riscv-qemu | Zig CRC-8 = Go CRC-8 |
| `ffi_rust_qemu` | no_std Rust object (32_17_embedded_rust) via cgo, riscv-qemu | Rust Fletcher-16 = Go, known vectors |

QEMU comes from `32_10_qemu`, iwasm from `32_26_wasm`, Zig from `32_24_microzig`, rustc from
`32_17_embedded_rust`: they are reached, not copied (`$BOX_QEMU_EMBEDDED`, `$BOX_WAMR`, `$BOX_MICROZIG`,
`$BOX_EMBEDDED_RUST`, else the sibling folder next to this ID). When one is missing the examples that need it
exit 3 (skip) with the reason; `examples test` then reports them as FAIL (shared `lib/boxtool.bash` behaviour).
The FFI examples use a generated target JSON (`{"inherits": ["riscv-qemu"], "ldflags": ["<obj>"]}`) because
TinyGo ignores `CGO_LDFLAGS`.

Templates (`./tinygo-box new <kind> <name> [--dir D]`); each new one has a `check.sh` (run it with
`./tinygo-box run bash <dir>/check.sh`) that the smoke test runs on a fresh copy:

| Template | What you get | `check.sh` |
|---|---|---|
| `firmware` | `main.go` blinking `machine.LED`, `blink/` package with a host test, build lines for four boards | (smoke test: host test + pico/nano builds) |
| `pico2_app` | RP2350 firmware + `pattern/` package with host tests | host test, UF2 family |
| `nrf52840_app` | nice!nano / Pro Micro nRF52840 (LED + die temperature on USB-CDC); `TARGET=` for other boards | UF2 family, sections above the SoftDevice |
| `esp32c3_app` | ESP32-C3: BOOT button toggles the LED | ESP image chip id, RISC-V ELF |
| `blackpill_app` | BlackPill F411 custom target (`blackpill-f411.json` + `.ld`), LED PC13, KEY PA0 | sections in the F411 map (build check only) |
| `qemu_app` | board-free logic run in QEMU | output on cortex-m-qemu and riscv-qemu |
| `qemu_tested_lib` | COBS framing library with tests | `tinygo test`, `go test`, tests in both QEMU targets |
| `i2c_driver` | TMP102-style I2C driver against a `Bus` interface, fake-bus tests, firmware using `machine.I2C0` | host tests, builds for pico, pico2, nicenano, esp32c3 |
| `usb_cdc_shell` | serial command shell (`shell/` parser with tests) on `machine.Serial` | host tests, builds for pico, nicenano, esp32c3 |
| `usb_hid` | USB HID keyboard + mouse | builds for pico/pico2, HID symbols, product string |
| `wasm_module` | `wasm-unknown` module with exports (xorshift, clamp) for WAMR | exports, `iwasm -f` results |
| `wasi_app` | WASI preview-1 command reading a preopened file | iwasm run, usage exit status |
| `zig_ffi` | TinyGo + Zig (fixed-point EMA) through cgo | zig build-obj + run on riscv-qemu |
| `rust_ffi` | TinyGo + no_std Rust (saturating PI controller) through cgo | rustc --emit obj + run on riscv-qemu |

**Rust, Zig, Bend:** Rust and Zig get examples and templates through the C ABI (cgo objects, above); TinyGo
itself compiles only Go and C. Bend: not supported; Bend's C output needs its own heap and threads (host
programs), and TinyGo links C only through cgo on an MCU, so there is no real fit here.

## Configuration and environment variables

Set by the launcher (do not export them yourself):

| Variable | Value | Meaning |
|---|---|---|
| `GOROOT` / `TINYGOROOT` | `install/go`, `install/tinygo` | the pinned toolchains |
| `GOPATH` | `cache/gopath` | module cache; allows offline reinstall |
| `GOCACHE`, `XDG_CACHE_HOME` | under `$BOX_V3/.../32_23_tinygo/build/cache` | Go and TinyGo caches (regenerable) |
| `GOTOOLCHAIN`, `GOTELEMETRY`, `GOENV` | `local`, `off`, `config/go.env` | no toolchain downloads, no telemetry |

Your own settings:

| Variable | Default | Meaning |
|---|---|---|
| `BOXT_OUT` | same ID path on idisk03, else the ID folder | output root (`build/`, `log/`); also settable in `config/local.env` |
| `BOXT_JOBS` | 8 (also the maximum) | parallel jobs |
| `BOXT_MIN_FREE_GB` | 8 | pause builds while less RAM is free; `BOXT_RAM_WAIT_MAX` (3600 s) gives up |
| `BOXT_NET_TIMEOUT` | 3600 | seconds for one download |
| `BOXT_PLATFORM` | detected (`linux-x64`) | override the platform |
| `GITHUB_TOKEN` | unset | optional; lifts the GitHub API limit for `update --check` |
| `BOX_INTEGRATION` | 1 | `0` = standalone: ignore `$BOX`/`$BOX_V3`, keep output in this folder |
| `NO_COLOR` | unset | set to print plain text (colour is only used on a terminal anyway) |
| `BOX_TINYGO` | set by `box_env.sh` | path of this ID, used by the native snippet |
| `BOX_NATIVE_OFF_TINYGO` | unset | `1` skips native mode for one shell (old name `TINYGO_BOX_NATIVE_OFF` still honoured) |

## Where files go

| What | Where |
|---|---|
| Source, launcher, examples, templates, `tools/elfinfo` (artifact checker, Go standard library only) | this ID |
| Tools | `install/tinygo-0.43.0` (1.3 GB), `install/go-1.27.3` (283 MB), `.bin/` (pinned pixi) |
| Cache | `cache/` (246 MB: downloads + GOPATH, `CACHEDIR.TAG`) |
| Build output, caches, logs | `$BOX_V3/30_39_tools/32_embedded/32_23_tinygo/{build,log}` (about 130 MB) |

Total in the ID about 1.9 GB. Nothing is written to `~/.cache` or `~/go`.

## Native mode

`./tinygo-box native` writes `native/native.{zsh,bash}` and `native/bin/{tinygo,tinygo-go}` (through the launcher, so
the in-ID GOPATH/GOCACHE apply). Load it in every shell (zsh, bash, fish) with `box native enable tinygo --apply`: it
runs `./tinygo-box native` when the files are missing and rebuilds `box_env.d/native.*` (without `--apply` it only
shows the plan; `box native disable tinygo --apply` undoes it). `BOX_NATIVE_OFF_TINYGO=1` skips it for one shell (the
old `TINYGO_BOX_NATIVE_OFF` still works for now). Without Box, source `native/native.zsh` or `native/native.bash` from
your shell rc.

## Tests

```sh
./tinygo-box test --all          # smoke + dry-run + examples
tests/test_smoke.sh              # versions, firmware template (host test + pico/nano), every other template's check.sh, no ~/go
tests/test_dry_run.sh            # every command in --dry-run + shellcheck
```

Last known (2026-10-29): doctor 26 ok / 0 failed; `examples test` 18/18; `test_smoke.sh` 19/19 (13 template
checks); `test_dry_run.sh` 26/26.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `tinygo flash` is refused | by design: use `./tinygo-box plan <target> <dir>` and run the printed commands yourself |
| No target for the BlackPill F411 | TinyGo 0.43 has none; use `stm32f4disco` (see Limitations) |
| Go tries to download a toolchain | the launcher sets `GOTOOLCHAIN=local`; run through `tinygo-box` |
| `~/go` or `~/.cache` appears | you ran a bare `go`/`tinygo`; use the launcher or native mode |
| `update --check` hits an API limit | export `GITHUB_TOKEN` |

## Limitations / needs you

- **BlackPill:** TinyGo 0.43 has no STM32F411/BlackPill target. `stm32f4disco` (STM32F407, same Cortex-M4F core) is the closest; its memory map (1 MB flash / 192 KB RAM) is larger than the F411's (512 KB / 128 KB) and its LED is PD12 (BlackPill: PC13, active low). `blackpill_f411_target` / `blackpill_app` add a custom target JSON with the F411 memory map, but the clock setup stays the Discovery's (8 MHz crystal, PLL to 168 MHz; the BlackPill has 25 MHz and a 100 MHz limit), so they are build and memory-map checks: not expected to run correctly on the board without patching TinyGo's machine package.
- **Not verified without a board:** flashing, USB enumeration (HID, CDC), I2C traffic, LEDs/buttons. These are build + artifact checks; the QEMU and WAMR examples are the only ones that execute.
- **Flashing is never done here.** `plan` prints the commands (UF2 copy for the Pico, avrdude for the Nano, probe/esptool hints for the others); avrdude, esptool and probe tools are not part of this ID (see `32_15_flashers`).
- Serial access for monitoring needs the `uucp` group (`sudo usermod -aG uucp "$USER"`, log in again); no udev rules ship with this ID.
- Linux x64 is tested; other OSes are pinned (Windows: run from Git Bash/MSYS2). No licence or sudo needed.
- Open items: `$BOX/00_09_meta/02_logs/2026_10_25_open_items.md` (uucp group).

## Scripts

Each script has a `[scripts.*]` descriptor in `.box.toml` (`box scripts show 32_23`; `box scripts check 32_23` must stay clean).

- `tinygo-box`: the launcher (POSIX sh); bootstraps the pinned pixi, keeps caches inside this folder, then runs lib/; `./tinygo-box help` lists the commands
- `lib/boxtool.bash`: shared launcher framework (boxtool 3: bootstrap, pinned downloads, pixi env, every common command); byte-identical copy of `$BOX/00_09_meta/05_policy/templates/tool/lib/boxtool.bash` (edit there, then sync)
- `lib/tinygo.bash`: this tool's part: TOOL_* settings, environment, hooks and the extra commands (`tinygo`, `go`, `targets`, `plan`)
- `examples/<ex>/example.sh`: build/run/test for each of the 18 examples; `examples/common/ex.bash`: their helpers (sibling lookups exit 3, `artifact`, `expect`)
- `templates/<kind>/check.sh`: board-free check of a generated project (run by `tests/test_smoke.sh`)
- `tools/elfinfo/`: Go program that checks ELF/UF2/ESP/wasm artifacts (`go -C tools/elfinfo run . elf|uf2|esp|wasm FILE ...`)
- `tests/test_smoke.sh`: smoke test of the tools, every template and the pico/nano builds
- `tests/test_dry_run.sh`: every launcher command in --dry-run mode, plus shellcheck
- `native/`: written by `./tinygo-box native`; regenerate, do not edit

## Links

- TinyGo: <https://github.com/tinygo-org/tinygo/releases/tag/v0.43.0>, <https://tinygo.org>; Go: <https://go.dev/dl/>; pixi: <https://github.com/prefix-dev/pixi>
- Talks: <https://archive.fosdem.org/2025/schedule/speaker/ayke_van_laethem/>, <https://tinygo.org/media/video>
- Why TinyGo (trending pick): 17.8k GitHub stars, 6 releases in the last 12 months (0.40.0 2025-12-15 to 0.43.0 2026-10-09).
- History: `NOTES.md`. Reports: `$BOX/00_09_meta/02_logs/2026_10_25_embedded_tools2_report.md`.
- Sibling tools: `32_13_arduino`, `32_24_microzig`, `32_25_micropython` (other languages on the same boards); used by the examples: `32_10_qemu`, `32_26_wasm`, `32_17_embedded_rust`, `32_24_microzig`.

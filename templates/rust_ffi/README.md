# @NAME@

TinyGo + no_std Rust through cgo (`tinygo-box new rust_ffi @NAME@`, 32_23_tinygo; rustc from
32_17_embedded_rust, QEMU from 32_10_qemu). `rustc --emit obj` gives one object with the `extern "C"` functions;
a target JSON that inherits the board target adds it to the link. Keep the Rust side free of `alloc`, `std` and anything that can panic
(`clamp`, indexing, `/` by a variable): a panic path pulls `core::fmt` in, which the single object does not contain.

    tinygo-box run bash check.sh      # rustc (riscv32imac) + tinygo run -target build/riscv-qemu-rust.json
For the Pico: `--target thumbv6m-none-eabi` and `"inherits": ["pico"]`.

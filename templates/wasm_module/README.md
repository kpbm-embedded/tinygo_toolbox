# @NAME@

WebAssembly module with exported functions (`tinygo-box new wasm_module @NAME@`, 32_23_tinygo), sized for WAMR on
an MCU (32_26_wasm: `wamrc` can AOT-compile it for thumbv7em/riscv32).

    tinygo-box run bash check.sh                                  # build, exports, calls through iwasm
    tinygo-box tinygo build -target wasm-unknown -opt z -no-debug -o build/@NAME@.wasm .

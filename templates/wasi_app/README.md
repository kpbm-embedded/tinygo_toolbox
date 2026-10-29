# @NAME@

WASI preview-1 command-line program (`tinygo-box new wasi_app @NAME@`, 32_23_tinygo).

    tinygo-box run bash check.sh                                     # build + run in iwasm with a preopened dir
    tinygo-box tinygo build -target wasip1 -o build/@NAME@.wasm .
    iwasm --dir=. build/@NAME@.wasm FILE                             # 32_26_wasm

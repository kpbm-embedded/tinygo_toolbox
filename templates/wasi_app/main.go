// @NAME@: WASI preview-1 command (tinygo-box new wasi_app @NAME@): reads a file from a preopened directory,
// counts lines and bytes, writes the result to stdout. Runs in iwasm (32_26_wasm), wasmtime or node.
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: @NAME@ FILE")
		os.Exit(2)
	}
	f, err := os.Open(os.Args[1])
	if err != nil {
		fmt.Fprintln(os.Stderr, "@NAME@:", err)
		os.Exit(1)
	}
	defer f.Close()
	lines, bytes := 0, 0
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		lines++
		bytes += len(sc.Bytes()) + 1
	}
	fmt.Printf("@NAME@: %d lines, %d bytes\n", lines, bytes)
}

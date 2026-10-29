// ffi_rust_qemu: TinyGo calls no_std Rust through cgo (C ABI). rustc from 32_17_embedded_rust emits a
// riscv32imac object; a generated target JSON (inherits riscv-qemu) adds it to the link; QEMU runs it.
package main

/*
#include <stdint.h>
#include <stddef.h>
uint16_t rust_fletcher16(const uint8_t *p, size_t n);
*/
import "C"

import "unsafe"

func goFletcher16(data []byte) uint16 { // reference implementation in Go
	var a, b uint16
	for _, x := range data {
		a = (a + uint16(x)) % 255
		b = (b + a) % 255
	}
	return b<<8 | a
}

func main() {
	ok := true
	for _, s := range []string{"123456789", "abcde", "abcdef"} {
		d := []byte(s)
		r := uint16(C.rust_fletcher16((*C.uint8_t)(unsafe.Pointer(&d[0])), C.size_t(len(d))))
		println("ffi_rust_qemu:", s, "rust", r, "go", goFletcher16(d))
		ok = ok && r == goFletcher16(d)
	}
	if ok {
		println("ffi_rust_qemu: match")
	}
}

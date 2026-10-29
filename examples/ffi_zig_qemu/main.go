// ffi_zig_qemu: TinyGo calls a Zig function through cgo (C ABI). Zig (32_24_microzig) compiles crc8.zig to a
// riscv32 object; a generated target JSON (inherits riscv-qemu) adds it to the link; QEMU runs the result.
package main

/*
#include <stdint.h>
#include <stddef.h>
uint8_t zig_crc8(const uint8_t *p, size_t n);
*/
import "C"

import "unsafe"

func goCRC8(data []byte) uint8 { // reference implementation in Go
	c := uint8(0)
	for _, b := range data {
		c ^= b
		for i := 0; i < 8; i++ {
			if c&0x80 != 0 {
				c = c<<1 ^ 0x07
			} else {
				c <<= 1
			}
		}
	}
	return c
}

func main() {
	ok := true
	for _, s := range []string{"123456789", "tinygo", "\x00\xff\x55"} {
		name := s
		if s[0] == 0 {
			name = "binary"
		}
		b := []byte(s)
		z := uint8(C.zig_crc8((*C.uint8_t)(unsafe.Pointer(&b[0])), C.size_t(len(b))))
		println("ffi_zig_qemu:", name, "zig", z, "go", goCRC8(b))
		ok = ok && z == goCRC8(b)
	}
	if ok {
		println("ffi_zig_qemu: match")
	}
}

// @NAME@: TinyGo firmware calling no_std Rust through cgo (tinygo-box new rust_ffi @NAME@). rust/lib.rs is
// compiled to an object by check.sh (rustc from 32_17_embedded_rust) and linked through a generated target JSON.
package main

/*
#include <stdint.h>
typedef struct { int32_t kp, ki, integ, limit; } pi_t;
void pi_init(pi_t *p, int32_t kp, int32_t ki, int32_t limit);
int32_t pi_step(pi_t *p, int32_t err);
*/
import "C"

func main() {
	var pi C.pi_t
	C.pi_init(&pi, 32, 4, 100) // kp 2.0, ki 0.25, output limit 100
	println("@NAME@: step", int32(C.pi_step(&pi, 10)), int32(C.pi_step(&pi, 1000)))
}

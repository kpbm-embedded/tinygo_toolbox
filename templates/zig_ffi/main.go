// @NAME@: TinyGo firmware calling Zig through cgo (tinygo-box new zig_ffi @NAME@). zig/filter.zig is compiled
// to an object per target by check.sh and linked through a generated target JSON ("ldflags").
package main

/*
#include <stdint.h>
typedef struct { int32_t acc; uint8_t shift; } ema_t;
void ema_init(ema_t *e, uint8_t shift, int32_t first);
int32_t ema_step(ema_t *e, int32_t x);
*/
import "C"

func main() {
	var e C.ema_t
	C.ema_init(&e, 2, 0)
	var y C.int32_t
	for i := 0; i < 20; i++ {
		y = C.ema_step(&e, 1000)
	}
	println("@NAME@: ema", int32(y))
}

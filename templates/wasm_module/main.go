// @NAME@: freestanding WebAssembly module (tinygo-box new wasm_module @NAME@) for WAMR (32_26_wasm) or any
// runtime: -target wasm-unknown, no imports. The host calls the exported functions.
package main

var state uint32 = 1

//export seed
func seed(s uint32) { state = s | 1 }

// next: xorshift32, a deterministic pseudo-random source the host can replay.
//
//export next
func next() uint32 {
	state ^= state << 13
	state ^= state >> 17
	state ^= state << 5
	return state
}

//export clamp
func clamp(v, lo, hi int32) int32 {
	if v < lo {
		return lo
	}
	if v > hi {
		return hi
	}
	return v
}

func main() {}

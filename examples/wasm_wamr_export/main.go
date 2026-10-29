// wasm_wamr_export: a freestanding WebAssembly module (-target wasm-unknown: no WASI, no imports) with
// exported functions, the shape WAMR (32_26_wasm) embeds on an MCU and calls from C.
package main

// Integer-only fixed-point PID step: what a host firmware could load as a replaceable control law.
var integ int32

//export pid_step
func pidStep(setpoint, measured int32) int32 {
	err := setpoint - measured
	integ += err
	if integ > 10000 {
		integ = 10000
	} else if integ < -10000 {
		integ = -10000
	}
	return (err*3)/2 + integ/10 // Kp = 1.5, Ki = 0.1
}

//export add
func add(a, b int32) int32 { return a + b }

func main() {}

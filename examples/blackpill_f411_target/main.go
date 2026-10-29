// blackpill_f411_target: custom TinyGo target for the WeAct BlackPill F411 (no built-in target in TinyGo 0.43).
// The target inherits stm32f4disco (same Cortex-M4F peripheral set) and swaps in the F411 memory map;
// the LED is PC13, active low, instead of the Discovery's PD12. Limitation: the inherited clock setup assumes
// the Discovery's 8 MHz crystal (BlackPill: 25 MHz), so this is a build and memory-map check, not a working image.
package main

import (
	"machine"
	"time"
)

const led = machine.PC13

func main() {
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})
	for {
		led.Low() // on
		time.Sleep(100 * time.Millisecond)
		led.High()
		time.Sleep(900 * time.Millisecond)
	}
}

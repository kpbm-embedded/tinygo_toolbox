// @NAME@: Raspberry Pi Pico 2 (RP2350) firmware (tinygo-box new pico2_app @NAME@). LED GP25 follows a pattern.
package main

import (
	"machine"
	"time"

	"@NAME@/pattern"
)

func main() {
	led := machine.LED
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})
	p := pattern.SOS()
	for i := 0; ; i++ {
		on, d := p.At(i)
		led.Set(on)
		time.Sleep(d)
	}
}

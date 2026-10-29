// pico2_blinky: Raspberry Pi Pico 2 (RP2350, Cortex-M33) LED on GP25 + println.
package main

import (
	"machine"
	"time"
)

func main() {
	led := machine.LED
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})
	for i := 0; ; i++ {
		led.Set(i%2 == 0)
		println("pico2_blinky: tick", i)
		time.Sleep(250 * time.Millisecond)
	}
}

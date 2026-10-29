// pico_blinky: Raspberry Pi Pico (RP2040) LED on GP25 + USB-CDC/UART print.
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
		println("pico_blinky: tick", i)
		time.Sleep(500 * time.Millisecond)
	}
}

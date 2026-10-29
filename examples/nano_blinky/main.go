// nano_blinky: Arduino Nano (ATmega328P) LED on D13 + println on the UART.
package main

import (
	"machine"
	"time"
)

func main() {
	led := machine.LED
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})
	n := uint8(0)
	for {
		led.High()
		time.Sleep(250 * time.Millisecond)
		led.Low()
		time.Sleep(250 * time.Millisecond)
		n++
		println("nano_blinky", n)
	}
}

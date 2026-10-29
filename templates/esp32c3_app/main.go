// @NAME@: ESP32-C3 firmware (tinygo-box new esp32c3_app @NAME@). Button on GPIO9 (BOOT) toggles the LED on GPIO8.
package main

import (
	"machine"
	"time"
)

func main() {
	led, btn := machine.GPIO8, machine.GPIO9
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})
	btn.Configure(machine.PinConfig{Mode: machine.PinInputPullup})
	on, last := false, true
	for {
		now := btn.Get()
		if last && !now { // falling edge: pressed
			on = !on
			led.Set(!on) // active low
			println("@NAME@: led", on)
		}
		last = now
		time.Sleep(20 * time.Millisecond)
	}
}

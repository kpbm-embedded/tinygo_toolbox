// @NAME@: nice!nano / Pro Micro nRF52840 firmware (tinygo-box new nrf52840_app @NAME@).
// Blinks the LED and reports the die temperature over USB-CDC.
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
		if i%10 == 0 {
			println("@NAME@: temp mC", machine.ReadTemperature())
		}
		time.Sleep(500 * time.Millisecond)
	}
}

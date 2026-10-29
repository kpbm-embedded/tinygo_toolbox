// @NAME@: WeAct BlackPill STM32F411 firmware (tinygo-box new blackpill_app @NAME@), custom target
// blackpill-f411.json (inherits stm32f4disco, F411 memory map). LED PC13 (active low), KEY button PA0.
package main

import (
	"machine"
	"time"
)

const (
	led = machine.PC13
	key = machine.PA0
)

func main() {
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})
	key.Configure(machine.PinConfig{Mode: machine.PinInputPullup})
	for {
		period := 500 * time.Millisecond
		if !key.Get() {
			period = 100 * time.Millisecond
		}
		led.Low()
		time.Sleep(period)
		led.High()
		time.Sleep(period)
	}
}

// @NAME@: TinyGo firmware (tinygo-box new firmware @NAME@). Blinks machine.LED and prints.
package main

import (
	"machine"
	"time"

	"@NAME@/blink"
)

func main() {
	led := machine.LED
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})
	var b blink.Pattern = blink.Heartbeat
	for i := 0; ; i++ {
		on, d := b.Step(i)
		led.Set(on)
		if i%len(b) == 0 {
			println("@NAME@: cycle", i/len(b))
		}
		time.Sleep(d)
	}
}

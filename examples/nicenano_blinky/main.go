// nicenano_blinky: nice!nano (nRF52840) blue LED P0.15 + USB-CDC println; UF2 for the Adafruit bootloader.
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
		println("nicenano_blinky: tick", i)
		time.Sleep(500 * time.Millisecond)
	}
}

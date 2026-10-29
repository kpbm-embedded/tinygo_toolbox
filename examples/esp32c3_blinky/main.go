// esp32c3_blinky: ESP32-C3 SuperMini (RISC-V) LED on GPIO8 (active low) + println on USB-Serial/JTAG.
package main

import (
	"machine"
	"time"
)

func main() {
	led := machine.GPIO8
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})
	for i := 0; ; i++ {
		led.Set(i%2 != 0)
		println("esp32c3_blinky: tick", i)
		time.Sleep(500 * time.Millisecond)
	}
}

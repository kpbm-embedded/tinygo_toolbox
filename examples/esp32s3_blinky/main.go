// esp32s3_blinky: ESP32-S3 DevKitC-1 (Xtensa LX7) GPIO toggle + UART0 print.
// The DevKitC-1 RGB LED (GPIO48) is a WS2812, so a plain GPIO (GPIO2) is toggled here.
package main

import (
	"machine"
	"time"
)

func main() {
	pin := machine.GPIO2
	pin.Configure(machine.PinConfig{Mode: machine.PinOutput})
	for i := 0; ; i++ {
		pin.Set(i%2 == 0)
		println("esp32s3_blinky: tick", i)
		time.Sleep(500 * time.Millisecond)
	}
}

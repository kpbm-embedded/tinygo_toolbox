// blackpill_f4: STM32F4 (Cortex-M4F) blink + UART. TinyGo has no BlackPill F411 target; the closest
// STM32F4 target is stm32f4disco (STM32F407). On a BlackPill the LED is PC13 (active low); the
// memory map differs (F411: 512K flash/128K RAM, F407: 1M/192K), see README.
package main

import (
	"machine"
	"time"
)

var led = machine.LED // stm32f4disco: PD12; BlackPill: machine.PC13

func main() {
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})
	var x float32 = 1
	for i := 0; ; i++ {
		led.Set(i%2 == 0)
		x = x*1.5 + 0.25 // Cortex-M4F hardware float
		println("blackpill_f4: tick", i, int(x)%1000)
		time.Sleep(time.Second)
	}
}

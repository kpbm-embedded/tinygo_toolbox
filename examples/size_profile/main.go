// size_profile: the same small program (goroutine + channel + fmt-free printing) built with different
// optimisation, GC and scheduler settings to see what each costs in flash and RAM on the Pico.
package main

import (
	"machine"
	"time"
)

func main() {
	led := machine.LED
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})
	ticks := make(chan int, 1)
	go func() {
		for i := 0; ; i++ {
			ticks <- i
			time.Sleep(100 * time.Millisecond)
		}
	}()
	buf := make([]byte, 0, 16)
	for i := range ticks {
		led.Set(i%2 == 0)
		buf = append(buf[:0], byte('0'+i%10))
		println("tick", string(buf))
	}
}

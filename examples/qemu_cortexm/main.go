// qemu_cortexm: goroutines, channels, select with timeout and a timer on Cortex-M3 (lm3s6965evb in QEMU).
package main

import "time"

func producer(n int, out chan<- int) {
	for i := 1; i <= n; i++ {
		out <- i
		time.Sleep(time.Millisecond)
	}
	close(out)
}

func main() {
	ch := make(chan int)
	go producer(10, ch)
	sum := 0
	for v := range ch {
		sum += v
	}
	println("qemu_cortexm: sum", sum)
	select {
	case <-time.After(20 * time.Millisecond):
		println("qemu_cortexm: timeout ok")
	case <-make(chan int):
	}
	println("qemu_cortexm: done")
}

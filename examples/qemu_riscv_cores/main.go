// qemu_riscv_cores: TinyGo's multicore scheduler ("cores") on 4 RISC-V harts in QEMU virt:
// goroutines run in parallel, sync.WaitGroup and sync/atomic keep the result exact.
package main

import (
	"runtime"
	"sync"
	"sync/atomic"
)

func main() {
	var wg sync.WaitGroup
	var total atomic.Uint32
	for w := 0; w < 4; w++ {
		wg.Add(1)
		go func(w int) {
			defer wg.Done()
			for i := 0; i < 1000; i++ {
				total.Add(1)
			}
		}(w)
	}
	wg.Wait()
	println("qemu_riscv_cores: cpus", runtime.NumCPU(), "total", total.Load())
}

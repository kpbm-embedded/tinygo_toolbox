// @NAME@: firmware logic run in QEMU (tinygo-box new qemu_app @NAME@): Cortex-M3 (cortex-m-qemu) or
// RISC-V (riscv-qemu). Prints results; check.sh compares them. Exit by returning from main.
package main

import "time"

type sample struct {
	at  time.Duration
	val int
}

// movingAverage over the last n values: integer-only, typical sensor smoothing.
func movingAverage(in []int, n int) []int {
	out := make([]int, 0, len(in))
	sum := 0
	for i, v := range in {
		sum += v
		if i >= n {
			sum -= in[i-n]
		}
		k := n
		if i+1 < n {
			k = i + 1
		}
		out = append(out, sum/k)
	}
	return out
}

func main() {
	start := time.Now()
	samples := make(chan sample, 4)
	go func() {
		for i, v := range []int{10, 20, 30, 40, 50} {
			samples <- sample{time.Duration(i) * time.Millisecond, v}
			time.Sleep(time.Millisecond)
		}
		close(samples)
	}()
	var vals []int
	for s := range samples {
		vals = append(vals, s.val)
	}
	avg := movingAverage(vals, 3)
	println("@NAME@: avg", avg[0], avg[1], avg[2], avg[3], avg[4])
	println("@NAME@: elapsed_ok", time.Since(start) >= 4*time.Millisecond)
	println("@NAME@: ok")
}

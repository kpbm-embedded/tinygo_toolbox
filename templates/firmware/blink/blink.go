// Package blink: LED patterns, hardware-free so `tinygo test ./blink` runs on the host.
package blink

import "time"

// Pattern: alternating on/off durations in milliseconds, starting with on.
type Pattern []uint16

var Heartbeat = Pattern{80, 120, 80, 720}

// Step returns the LED state and how long to hold it for step i.
func (p Pattern) Step(i int) (bool, time.Duration) {
	k := i % len(p)
	return k%2 == 0, time.Duration(p[k]) * time.Millisecond
}

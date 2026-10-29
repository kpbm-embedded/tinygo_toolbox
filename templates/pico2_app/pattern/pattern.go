// Package pattern: LED timing without hardware access, so it is tested on the host.
package pattern

import "time"

// Pattern: alternating on/off durations (on first).
type Pattern []time.Duration

// SOS: ... --- ... with 150 ms units.
func SOS() Pattern {
	u := 150 * time.Millisecond
	var p Pattern
	for _, n := range []time.Duration{1, 1, 1, 3, 3, 3, 1, 1, 1} {
		p = append(p, n*u, u)
	}
	p[len(p)-1] = 7 * u
	return p
}

// At returns the LED state and the hold time for step i.
func (p Pattern) At(i int) (bool, time.Duration) { k := i % len(p); return k%2 == 0, p[k] }

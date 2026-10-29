package blink

import "testing"

func TestHeartbeat(t *testing.T) {
	on, d := Heartbeat.Step(0)
	if !on || d.Milliseconds() != 80 {
		t.Fatal("step 0")
	}
	on, d = Heartbeat.Step(5)
	if on || d.Milliseconds() != 120 {
		t.Fatal("step 5 wraps to index 1")
	}
}

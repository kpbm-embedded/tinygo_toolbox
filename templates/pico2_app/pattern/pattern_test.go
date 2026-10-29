package pattern

import "testing"

func TestSOS(t *testing.T) {
	p := SOS()
	if len(p) != 18 {
		t.Fatalf("len %d", len(p))
	}
	if on, d := p.At(6); !on || d.Milliseconds() != 450 {
		t.Fatal("first dash")
	}
	if on, d := p.At(17); on || d.Milliseconds() != 1050 {
		t.Fatal("word gap")
	}
}

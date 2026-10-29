package ring

import "testing"

func TestFIFO(t *testing.T) {
	var r Ring
	for i := 0; i < 10; i++ {
		r.Put(byte(i))
	}
	for i := 0; i < 10; i++ {
		b, ok := r.Get()
		if !ok || b != byte(i) {
			t.Fatalf("got %d,%v want %d", b, ok, i)
		}
	}
}

func TestFullAndWrap(t *testing.T) {
	var r Ring
	for i := 0; i < 16; i++ {
		if !r.Put(byte(i)) {
			t.Fatal("put failed before full")
		}
	}
	if r.Put(99) {
		t.Fatal("put succeeded when full")
	}
	for k := 0; k < 40; k++ {
		b, _ := r.Get()
		r.Put(b)
	}
	if r.Len() != 16 {
		t.Fatalf("len %d", r.Len())
	}
}

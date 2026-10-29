package shell

import "testing"

func TestFeed(t *testing.T) {
	s := New()
	s.Register("add", func(a []string) string {
		x, _ := Atoi(a[0])
		y, _ := Atoi(a[1])
		return "= " + itoa(x+y)
	})
	var got string
	for _, b := range []byte("add  2 4x\x7f0\r") {
		if r, ok := s.Feed(b); ok {
			got = r
		}
	}
	if got != "= 42" {
		t.Fatalf("got %q", got)
	}
	if r := s.Run("nope"); r != "error: unknown command nope" {
		t.Fatal(r)
	}
}

func itoa(v int) string {
	if v == 0 {
		return "0"
	}
	var b []byte
	for ; v > 0; v /= 10 {
		b = append([]byte{byte('0' + v%10)}, b...)
	}
	return string(b)
}

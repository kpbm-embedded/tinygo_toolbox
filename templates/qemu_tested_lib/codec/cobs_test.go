package codec

import (
	"bytes"
	"testing"
)

func TestVectors(t *testing.T) {
	cases := []struct{ in, enc []byte }{
		{[]byte{0}, []byte{1, 1}},
		{[]byte{0, 0}, []byte{1, 1, 1}},
		{[]byte{0x11, 0x22, 0, 0x33}, []byte{3, 0x11, 0x22, 2, 0x33}},
		{[]byte{0x11, 0x22, 0x33, 0x44}, []byte{5, 0x11, 0x22, 0x33, 0x44}},
	}
	for _, c := range cases {
		if got := Encode(c.in); !bytes.Equal(got, c.enc) {
			t.Fatalf("Encode(%x) = %x, want %x", c.in, got, c.enc)
		}
		if got, ok := Decode(c.enc); !ok || !bytes.Equal(got, c.in) {
			t.Fatalf("Decode(%x) = %x", c.enc, got)
		}
	}
}

func TestLongRun(t *testing.T) {
	in := make([]byte, 600)
	for i := range in {
		in[i] = byte(i%255 + 1)
	}
	enc := Encode(in)
	if bytes.IndexByte(enc, 0) >= 0 {
		t.Fatal("zero in encoded data")
	}
	if got, ok := Decode(enc); !ok || !bytes.Equal(got, in) {
		t.Fatal("round trip")
	}
}

func TestMalformed(t *testing.T) {
	if _, ok := Decode([]byte{5, 1}); ok {
		t.Fatal("short frame accepted")
	}
}

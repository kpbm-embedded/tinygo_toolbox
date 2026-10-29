package crc

import "testing"

var check = []byte("123456789")

func TestCCITT(t *testing.T) {
	if got := CCITT(check); got != 0x29B1 {
		t.Fatalf("CCITT = %#x, want 0x29b1", got)
	}
}

func TestCRC8(t *testing.T) {
	if got := CRC8(check); got != 0xF4 {
		t.Fatalf("CRC8 = %#x, want 0xf4", got)
	}
}

func TestEmpty(t *testing.T) {
	if CCITT(nil) != 0xFFFF || CRC8(nil) != 0 {
		t.Fatal("empty input")
	}
}

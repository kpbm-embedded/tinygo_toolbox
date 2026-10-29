package sensor

import "testing"

type fakeBus struct{ regs map[byte][2]byte }

func (f *fakeBus) Tx(addr uint16, w, r []byte) error {
	if addr != DefaultAddress {
		return ErrNoDevice
	}
	v := f.regs[w[0]]
	copy(r, v[:])
	return nil
}

func TestRead(t *testing.T) {
	bus := &fakeBus{regs: map[byte][2]byte{regConfig: {0x60, 0xA0}}}
	d := New(bus)
	if err := d.Configure(); err != nil {
		t.Fatal(err)
	}
	for _, c := range []struct {
		raw [2]byte
		mc  int32
	}{{[2]byte{0x19, 0x00}, 25000}, {[2]byte{0xFF, 0xF0}, -62}, {[2]byte{0xE7, 0x00}, -25000}} {
		bus.regs[regTemp] = c.raw
		if got, _ := d.ReadMilliCelsius(); got != c.mc {
			t.Fatalf("%x: got %d, want %d", c.raw, got, c.mc)
		}
	}
}

func TestNoDevice(t *testing.T) {
	d := New(&fakeBus{regs: map[byte][2]byte{}})
	if d.Configure() != ErrNoDevice {
		t.Fatal("missing device not reported")
	}
}

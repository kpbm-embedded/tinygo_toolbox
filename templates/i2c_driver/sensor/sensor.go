// Package sensor: driver for a TMP102-style I2C temperature sensor, written against a small Bus
// interface so it runs on any board (machine.I2C satisfies it) and is tested with a fake bus.
package sensor

import "errors"

// Bus is the part of machine.I2C (and tinygo.org/x/drivers' drivers.I2C) the driver needs.
type Bus interface {
	Tx(addr uint16, w, r []byte) error
}

const (
	DefaultAddress = 0x48
	regTemp        = 0x00
	regConfig      = 0x01
)

var ErrNoDevice = errors.New("sensor: no device")

type Device struct {
	bus  Bus
	Addr uint16
}

func New(bus Bus) *Device { return &Device{bus: bus, Addr: DefaultAddress} }

// Configure checks the device answers (config register has the power-on value 0x60A0).
func (d *Device) Configure() error {
	var b [2]byte
	if err := d.bus.Tx(d.Addr, []byte{regConfig}, b[:]); err != nil {
		return err
	}
	if b[0] != 0x60 {
		return ErrNoDevice
	}
	return nil
}

// ReadMilliCelsius: 12-bit two's complement, 0.0625 C per LSB.
func (d *Device) ReadMilliCelsius() (int32, error) {
	var b [2]byte
	if err := d.bus.Tx(d.Addr, []byte{regTemp}, b[:]); err != nil {
		return 0, err
	}
	raw := int16(uint16(b[0])<<8|uint16(b[1])) >> 4
	return int32(raw) * 625 / 10, nil
}

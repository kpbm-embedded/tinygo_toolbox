// Package crc: CRC-16/CCITT-FALSE and CRC-8 (poly 0x07), table-free so it fits small MCUs.
package crc

// CCITT computes CRC-16/CCITT-FALSE (poly 0x1021, init 0xFFFF).
func CCITT(data []byte) uint16 {
	c := uint16(0xFFFF)
	for _, b := range data {
		c ^= uint16(b) << 8
		for i := 0; i < 8; i++ {
			if c&0x8000 != 0 {
				c = c<<1 ^ 0x1021
			} else {
				c <<= 1
			}
		}
	}
	return c
}

// CRC8 computes CRC-8 (poly 0x07, init 0), as used by SMBus PEC.
func CRC8(data []byte) uint8 {
	c := uint8(0)
	for _, b := range data {
		c ^= b
		for i := 0; i < 8; i++ {
			if c&0x80 != 0 {
				c = c<<1 ^ 0x07
			} else {
				c <<= 1
			}
		}
	}
	return c
}

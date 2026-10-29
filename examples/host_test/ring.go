// Package ring: a fixed-size byte ring buffer (the kind used for UART RX on an MCU), tested on
// the host with `tinygo test` (same compiler as the firmware) and `go test`.
package ring

type Ring struct {
	buf        [16]byte
	head, tail uint8
	n          uint8
}

func (r *Ring) Put(b byte) bool {
	if r.n == uint8(len(r.buf)) {
		return false
	}
	r.buf[r.head] = b
	r.head = (r.head + 1) % uint8(len(r.buf))
	r.n++
	return true
}

func (r *Ring) Get() (byte, bool) {
	if r.n == 0 {
		return 0, false
	}
	b := r.buf[r.tail]
	r.tail = (r.tail + 1) % uint8(len(r.buf))
	r.n--
	return b, true
}

func (r *Ring) Len() int { return int(r.n) }

// Package codec: COBS framing (zero-free packets for UART links), allocation-light for MCUs.
package codec

// Encode returns data COBS-encoded (no trailing 0 delimiter).
func Encode(data []byte) []byte {
	out := make([]byte, 1, len(data)+len(data)/254+2)
	code, ci := byte(1), 0
	for _, b := range data {
		if b == 0 {
			out[ci], code, ci = code, 1, len(out)
			out = append(out, 0)
			continue
		}
		out = append(out, b)
		code++
		if code == 0xFF {
			out[ci], code, ci = code, 1, len(out)
			out = append(out, 0)
		}
	}
	out[ci] = code
	return out
}

// Decode reverses Encode; ok is false on a malformed frame.
func Decode(enc []byte) (out []byte, ok bool) {
	for i := 0; i < len(enc); {
		code := int(enc[i])
		if code == 0 || i+code > len(enc) {
			return nil, false
		}
		out = append(out, enc[i+1:i+code]...)
		i += code
		if code < 0xFF && i < len(enc) {
			out = append(out, 0)
		}
	}
	return out, true
}
